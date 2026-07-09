#include <metal_stdlib>
#include "Common.h"
#include "ShaderTypes.h"

using namespace metal;

struct FlutedGlassUniforms {
    float2 u_resolution;
    float u_pixelRatio;
    float u_rotation;
    float4 u_colorBack;
    float4 u_colorShadow;
    float4 u_colorHighlight;
    float u_shadows;
    float u_size;
    float u_angle;
    float u_stretch;
    float u_shape;
    float u_distortion;
    float u_highlights;
    float u_distortionShape;
    float u_shift;
    float u_blur;
    float u_edges;
    float u_marginLeft;
    float u_marginRight;
    float u_marginTop;
    float u_marginBottom;
    float u_grainMixer;
    float u_grainOverlay;
};

struct FragmentVertexUniforms {
    float2 u_resolution;
    float u_pixelRatio;
    float u_imageAspectRatio;
    float u_originX;
    float u_originY;
    float u_worldWidth;
    float u_worldHeight;
    float u_fit;
    float u_scale;
    float u_rotation;
    float u_offsetX;
    float u_offsetY;
};

static inline float valueNoise(float2 st) {
    float2 i = floor(st);
    float2 f = fract(st);
    float a = hash21(i);
    float b = hash21(i + float2(1.0, 0.0));
    float c = hash21(i + float2(0.0, 1.0));
    float d = hash21(i + float2(1.0, 1.0));
    float2 u = f * f * (3.0 - 2.0 * f);
    float x1 = mix(a, b, u.x);
    float x2 = mix(c, d, u.x);
    return mix(x1, x2, u.y);
}

static inline float getUvFrame(float2 uv, float softness) {
    float aax = 2.0 * fwidth(uv.x);
    float aay = 2.0 * fwidth(uv.y);
    float left = smoothstep(0.0, aax + softness, uv.x);
    float right = 1.0 - smoothstep(1.0 - softness - aax, 1.0, uv.x);
    float bottom = smoothstep(0.0, aay + softness, uv.y);
    float top = 1.0 - smoothstep(1.0 - softness - aay, 1.0, uv.y);
    return left * right * bottom * top;
}

static inline float4 samplePremultiplied(texture2d<float> tex, float2 uv) {
    float4 c = tex.sample(linearSampler, uv);
    c.rgb *= c.a;
    return c;
}

static inline float4 getBlur(texture2d<float> tex, float2 uv, float2 texelSize, float2 dir, float sigma) {
    if (sigma <= 0.5) { return tex.sample(linearSampler, uv); }
    const int MAX_RADIUS = 50;
    int radius = int(min(float(MAX_RADIUS), ceil(3.0 * sigma)));
    float twoSigma2 = 2.0 * sigma * sigma;
    float gaussianNorm = 1.0 / sqrt(TWO_PI * sigma * sigma);
    float4 sum = samplePremultiplied(tex, uv) * gaussianNorm;
    float weightSum = gaussianNorm;
    for (int i = 1; i <= MAX_RADIUS; i++) {
        if (i > radius) { break; }
        float x = float(i);
        float w = exp(-(x * x) / twoSigma2) * gaussianNorm;
        float2 offset = dir * texelSize * x;
        float4 s1 = samplePremultiplied(tex, uv + offset);
        float4 s2 = samplePremultiplied(tex, uv - offset);
        sum += (s1 + s2) * w;
        weightSum += 2.0 * w;
    }
    float4 result = sum / weightSum;
    if (result.a > 0.0) { result.rgb /= result.a; }
    return result;
}

static inline float2 rotateAspect(float2 p, float a, float aspect) {
    p.x *= aspect;
    p = rotate(p, a);
    p.x /= aspect;
    return p;
}

static inline float smoothFract(float x) {
    float f = fract(x);
    float w = fwidth(x);
    float edge = abs(f - 0.5) - 0.5;
    float band = smoothstep(-w, w, edge);
    return mix(f, 1.0 - f, band);
}

fragment float4 fluted_glass_fragment(VertexOutput in [[stage_in]],
                                     constant FlutedGlassUniforms &uniforms [[buffer(0)]],
                                     constant FragmentVertexUniforms &vertexUniforms [[buffer(1)]],
                                     texture2d<float> imageTexture [[texture(0)]]) {
    float patternRotation = -uniforms.u_angle * PI / 180.0;
    float patternSize = mix(200.0, 5.0, uniforms.u_size);
    float2 uv = in.imageUV;

    float2 uvMask = in.position.xy / uniforms.u_resolution;
    float2 sw = float2(0.005);
    float4 margins = float4(uniforms.u_marginLeft, uniforms.u_marginTop, uniforms.u_marginRight, uniforms.u_marginBottom);
    float mask = smoothstep(margins.x, margins.x + sw.x, uvMask.x + sw.x) *
                 smoothstep(margins.z, margins.z + sw.x, 1.0 - uvMask.x + sw.x) *
                 smoothstep(margins.y, margins.y + sw.y, uvMask.y + sw.y) *
                 smoothstep(margins.w, margins.w + sw.y, 1.0 - uvMask.y + sw.y);
    float maskOuter = smoothstep(margins.x - sw.x, margins.x, uvMask.x + sw.x) *
                      smoothstep(margins.z - sw.x, margins.z, 1.0 - uvMask.x + sw.x) *
                      smoothstep(margins.y - sw.y, margins.y, uvMask.y + sw.y) *
                      smoothstep(margins.w - sw.y, margins.w, 1.0 - uvMask.y + sw.y);
    float maskStroke = maskOuter - mask;
    float maskInner = smoothstep(margins.x - 2.0 * sw.x, margins.x, uvMask.x) *
                      smoothstep(margins.z - 2.0 * sw.x, margins.z, 1.0 - uvMask.x) *
                      smoothstep(margins.y - 2.0 * sw.y, margins.y, uvMask.y) *
                      smoothstep(margins.w - 2.0 * sw.y, margins.w, 1.0 - uvMask.y);
    float maskStrokeInner = maskInner - mask;

    uv -= 0.5;
    uv *= patternSize;
    uv = rotateAspect(uv, patternRotation, vertexUniforms.u_imageAspectRatio);

    float curve = 0.0;
    float patternY = uv.y / vertexUniforms.u_imageAspectRatio;
    if (uniforms.u_shape > 4.5) {
        curve = 0.5 + 0.5 * sin(0.5 * PI * uv.x) * cos(0.5 * PI * patternY);
    } else if (uniforms.u_shape > 3.5) {
        curve = 10.0 * abs(fract(0.1 * patternY) - 0.5);
    } else if (uniforms.u_shape > 2.5) {
        curve = 4.0 * sin(0.23 * patternY);
    } else if (uniforms.u_shape > 1.5) {
        curve = 0.5 + 0.5 * sin(0.5 * uv.x) * sin(1.7 * uv.x);
    }

    float2 UvToFract = uv + curve;
    float2 fractOrigUV = fract(uv);
    float2 floorOrigUV = floor(uv);

    float x = smoothFract(UvToFract.x);
    float xNonSmooth = fract(UvToFract.x) + 0.0001;
    float highlightsWidth = 2.0 * max(0.001, fwidth(UvToFract.x));
    highlightsWidth += 2.0 * maskStrokeInner;
    float highlights = smoothstep(0.0, highlightsWidth, xNonSmooth);
    highlights *= smoothstep(1.0, 1.0 - highlightsWidth, xNonSmooth);
    highlights = 1.0 - highlights;
    highlights *= uniforms.u_highlights;
    highlights = clamp(highlights, 0.0, 1.0);
    highlights *= mask;

    float shadows = pow(x, 1.3);
    float distortion = 0.0;
    float fadeX = 1.0;
    float frameFade = 0.0;
    float aa = max(fwidth(xNonSmooth), fwidth(uv.x));
    aa = max(aa, fwidth(UvToFract.x));
    aa = max(aa, 0.0001);

    if (uniforms.u_distortionShape < 1.5) {
        distortion = -pow(1.5 * x, 3.0);
        distortion += (0.5 - uniforms.u_shift);
        frameFade = pow(1.5 * x, 3.0);
        aa = max(0.2, aa);
        aa += mix(0.2, 0.0, uniforms.u_size);
        fadeX = smoothstep(0.0, aa, xNonSmooth) * smoothstep(1.0, 1.0 - aa, xNonSmooth);
        distortion = mix(0.5, distortion, fadeX);
    } else if (uniforms.u_distortionShape < 2.5) {
        distortion = 2.0 * pow(x, 2.0);
        distortion -= (0.5 + uniforms.u_shift);
        frameFade = pow(abs(x - 0.5), 4.0);
        aa = max(0.2, aa);
        aa += mix(0.2, 0.0, uniforms.u_size);
        fadeX = smoothstep(0.0, aa, xNonSmooth) * smoothstep(1.0, 1.0 - aa, xNonSmooth);
        distortion = mix(0.5, distortion, fadeX);
        frameFade = mix(1.0, frameFade, 0.5 * fadeX);
    } else if (uniforms.u_distortionShape < 3.5) {
        distortion = pow(2.0 * (xNonSmooth - 0.5), 6.0);
        distortion -= 0.25;
        distortion -= uniforms.u_shift;
        frameFade = 1.0 - 2.0 * pow(abs(x - 0.4), 2.0);
        aa = 0.15;
        aa += mix(0.1, 0.0, uniforms.u_size);
        fadeX = smoothstep(0.0, aa, xNonSmooth) * smoothstep(1.0, 1.0 - aa, xNonSmooth);
        frameFade = mix(1.0, frameFade, fadeX);
    } else if (uniforms.u_distortionShape < 4.5) {
        x = xNonSmooth;
        distortion = sin((x + 0.25) * TWO_PI);
        shadows = 0.5 + 0.5 * asin(distortion) / (0.5 * PI);
        distortion *= 0.5;
        distortion -= uniforms.u_shift;
        frameFade = 0.5 + 0.5 * sin(x * TWO_PI);
    } else {
        distortion -= pow(abs(x), 0.2) * x;
        distortion += 0.33;
        distortion -= 3.0 * uniforms.u_shift;
        distortion *= 0.33;
        frameFade = 0.3 * smoothstep(0.0, 1.0, x);
        shadows = pow(x, 2.5);
        aa = max(0.1, aa);
        aa += mix(0.1, 0.0, uniforms.u_size);
        fadeX = smoothstep(0.0, aa, xNonSmooth) * smoothstep(1.0, 1.0 - aa, xNonSmooth);
        distortion *= fadeX;
    }

    float2 dudx = dfdx(in.imageUV);
    float2 dudy = dfdy(in.imageUV);
    float2 grainUV = in.imageUV - 0.5;
    grainUV *= (0.8 / float2(length(dudx), length(dudy)));
    grainUV += 0.5;
    float grain = valueNoise(grainUV);
    grain = smoothstep(0.4, 0.7, grain);
    grain *= uniforms.u_grainMixer;
    distortion = mix(distortion, 0.0, grain);

    shadows = min(shadows, 1.0);
    shadows += maskStrokeInner;
    shadows *= mask;
    shadows = min(shadows, 1.0);
    shadows *= pow(uniforms.u_shadows, 2.0);
    shadows = clamp(shadows, 0.0, 1.0);

    distortion *= 3.0 * uniforms.u_distortion;
    frameFade *= uniforms.u_distortion;
    fractOrigUV.x += distortion;
    floorOrigUV = rotateAspect(floorOrigUV, -patternRotation, vertexUniforms.u_imageAspectRatio);
    fractOrigUV = rotateAspect(fractOrigUV, -patternRotation, vertexUniforms.u_imageAspectRatio);
    uv = (floorOrigUV + fractOrigUV) / patternSize;
    uv += pow(maskStroke, 4.0);
    uv += float2(0.5);

    uv = mix(in.imageUV, uv, smoothstep(0.0, 0.7, mask));
    float blur = mix(0.0, 50.0, uniforms.u_blur);
    blur = mix(0.0, blur, smoothstep(0.5, 1.0, mask));

    float edgeDistortion = mix(0.0, 0.04, uniforms.u_edges);
    edgeDistortion += 0.06 * frameFade * uniforms.u_edges;
    edgeDistortion *= mask;
    float frame = getUvFrame(uv, edgeDistortion);

    float stretch = 1.0 - smoothstep(0.0, 0.5, xNonSmooth) * smoothstep(1.0, 1.0 - 0.5, xNonSmooth);
    stretch = pow(stretch, 2.0);
    stretch *= mask;
    stretch *= getUvFrame(uv, 0.1 + 0.05 * mask * frameFade);
    uv.y = mix(uv.y, 0.5, uniforms.u_stretch * stretch);

    float4 image = getBlur(imageTexture, uv, 1.0 / uniforms.u_resolution / uniforms.u_pixelRatio, float2(0.0, 1.0), blur);
    image.rgb *= image.a;
    float4 backColor = uniforms.u_colorBack;
    backColor.rgb *= backColor.a;
    float4 highlightColor = uniforms.u_colorHighlight;
    highlightColor.rgb *= highlightColor.a;
    float4 shadowColor = uniforms.u_colorShadow;

    float3 color = highlightColor.rgb * highlights;
    float opacity = highlightColor.a * highlights;
    shadows = mix(shadows * shadowColor.a, 0.0, highlights);
    color = mix(color, shadowColor.rgb * shadowColor.a, 0.5 * shadows);
    color += 0.5 * pow(shadows, 0.5) * shadowColor.rgb;
    opacity += shadows;
    color = clamp(color, float3(0.0), float3(1.0));
    opacity = clamp(opacity, 0.0, 1.0);

    color += image.rgb * (1.0 - opacity) * frame;
    opacity += image.a * (1.0 - opacity) * frame;
    color += backColor.rgb * (1.0 - opacity);
    opacity += backColor.a * (1.0 - opacity);

    float grainOverlay = valueNoise(rotate(grainUV, 1.0) + float2(3.0));
    grainOverlay = mix(grainOverlay, valueNoise(rotate(grainUV, 2.0) + float2(-1.0)), 0.5);
    grainOverlay = pow(grainOverlay, 1.3);
    float grainOverlayV = grainOverlay * 2.0 - 1.0;
    float3 grainOverlayColor = float3(step(0.0, grainOverlayV));
    float grainOverlayStrength = uniforms.u_grainOverlay * abs(grainOverlayV);
    grainOverlayStrength = pow(grainOverlayStrength, 0.8);
    grainOverlayStrength *= mask;
    color = mix(color, grainOverlayColor, 0.35 * grainOverlayStrength);

    opacity += 0.5 * grainOverlayStrength;
    opacity = clamp(opacity, 0.0, 1.0);
    return float4(color, opacity);
}
