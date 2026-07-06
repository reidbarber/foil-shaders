#include <metal_stdlib>
#include "Common.metal"

using namespace metal;

constant int kHeatmapMaxColorCount = 10;

struct HeatmapUniforms {
    float u_time;
    float4 u_colorBack;
    float4 u_colors[kHeatmapMaxColorCount];
    float u_colorsCount;
    float u_contour;
    float u_angle;
    float u_noise;
    float u_innerGlow;
    float u_outerGlow;
};

inline float getImgFrame(float2 uv, float th) {
    float frame = 1.0;
    frame *= smoothstep(0.0, th, uv.y);
    frame *= 1.0 - smoothstep(1.0 - th, 1.0, uv.y);
    frame *= smoothstep(0.0, th, uv.x);
    frame *= 1.0 - smoothstep(1.0 - th, 1.0, uv.x);
    return frame;
}

inline float circle(float2 uv, float2 c, float2 r) {
    return 1.0 - smoothstep(r.x, r.y, length(uv - c));
}

inline float lst(float edge0, float edge1, float x) {
    return clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0);
}

inline float sst(float edge0, float edge1, float x) {
    // SwiftShader's WebGL path treats these reversed-edge smoothsteps as zero;
    // Metal evaluates the undefined GLSL case differently and overheats the map.
    if (edge1 < edge0) {
        return 0.0;
    }
    return smoothstep(edge0, edge1, x);
}

inline float shadowShape(float2 uv, float t, float contour) {
    float2 scaledUV = uv;
    float posY = mix(-1.0, 2.0, t);
    scaledUV.y -= 0.5;
    float mainCircleScale = sst(0.0, 0.8, posY) * lst(1.4, 0.9, posY);
    scaledUV *= float2(1.0, 1.0 + 1.5 * mainCircleScale);
    scaledUV.y += 0.5;

    float innerR = 0.4;
    float outerR = 1.0 - 0.3 * (sst(0.1, 0.2, t) * (1.0 - sst(0.2, 0.5, t)));
    float s = circle(scaledUV, float2(0.5, posY - 0.2), float2(innerR, outerR));
    s = pow(s, 1.4) * 1.2;

    float topFlattener = 0.0;
    {
        float pos = posY - uv.y;
        float edge = 1.2;
        topFlattener = lst(-0.4, 0.0, pos) * (1.0 - sst(0.0, edge, pos));
        topFlattener = pow(topFlattener, 3.0);
        float topFlattenerMixer = (1.0 - sst(0.0, 0.3, pos));
        s = mix(topFlattener, s, topFlattenerMixer);
    }

    {
        float visibility = sst(0.6, 0.7, t) * (1.0 - sst(0.8, 0.9, t));
        float angle = -2.0 - t * TWO_PI;
        float rightCircle = circle(uv, float2(0.95 - 0.2 * cos(angle), 0.4 - 0.1 * sin(angle)), float2(0.15, 0.3));
        s = mix(s, 0.0, rightCircle * visibility);
    }

    {
        float topCircle = circle(uv, float2(0.5, 0.19), float2(0.05, 0.25));
        topCircle += 2.0 * contour * circle(uv, float2(0.5, 0.19), float2(0.2, 0.5));
        float visibility = 0.55 * sst(0.2, 0.3, t) * (1.0 - sst(0.3, 0.45, t));
        topCircle *= visibility;
        s = mix(s, 0.0, topCircle);
    }

    float leafMask = circle(uv, float2(0.53, 0.13), float2(0.08, 0.19));
    leafMask = mix(leafMask, 0.0, 1.0 - sst(0.4, 0.54, uv.x));
    leafMask = mix(0.0, leafMask, sst(0.0, 0.2, uv.y));
    leafMask *= (sst(0.5, 1.1, posY) * sst(1.5, 1.3, posY));
    s += leafMask;

    {
        float visibility = sst(0.0, 0.4, t) * (1.0 - sst(0.6, 0.8, t));
        s = mix(s, 0.0, visibility * circle(uv, float2(0.52, 0.92), float2(0.09, 0.25)));
    }

    {
        float pos = sst(0.0, 0.6, t) * (1.0 - sst(0.6, 1.0, t));
        s = mix(s, 0.5, circle(uv, float2(0.0, 1.2 - 0.5 * pos), float2(0.1, 0.3)));
        s = mix(s, 0.0, circle(uv, float2(1.0, 0.5 + 0.5 * pos), float2(0.1, 0.3)));
        s = mix(s, 1.0, circle(uv, float2(0.95, 0.2 + 0.2 * sst(0.3, 0.4, t) * sst(0.7, 0.5, t)), float2(0.07, 0.22)));
        s = mix(s, 1.0, circle(uv, float2(0.95, 0.2 + 0.2 * sst(0.3, 0.4, t) * (1.0 - sst(0.5, 0.7, t))), float2(0.07, 0.22)));
        s /= max(1e-4, sst(1.0, 0.85, uv.y));
    }

    s = clamp(0.0, 1.0, s);
    return s;
}

inline float blurEdge3x3(texture2d<float> tex, float2 uv, float2 dudx, float2 dudy, float radius, float centerSample) {
    float2 texel = 1.0 / float2(tex.get_width(), tex.get_height());
    float2 r = radius * texel;
    float w1 = 1.0, w2 = 2.0, w4 = 4.0;
    float norm = 16.0;
    float sum = w4 * centerSample;
    sum += w2 * tex.sample(linearMipSampler, uv + float2(0.0, -r.y), gradient2d(dudx, dudy)).g;
    sum += w2 * tex.sample(linearMipSampler, uv + float2(0.0, r.y), gradient2d(dudx, dudy)).g;
    sum += w2 * tex.sample(linearMipSampler, uv + float2(-r.x, 0.0), gradient2d(dudx, dudy)).g;
    sum += w2 * tex.sample(linearMipSampler, uv + float2(r.x, 0.0), gradient2d(dudx, dudy)).g;
    sum += w1 * tex.sample(linearMipSampler, uv + float2(-r.x, -r.y), gradient2d(dudx, dudy)).g;
    sum += w1 * tex.sample(linearMipSampler, uv + float2(r.x, -r.y), gradient2d(dudx, dudy)).g;
    sum += w1 * tex.sample(linearMipSampler, uv + float2(-r.x, r.y), gradient2d(dudx, dudy)).g;
    sum += w1 * tex.sample(linearMipSampler, uv + float2(r.x, r.y), gradient2d(dudx, dudy)).g;
    return sum / norm;
}

fragment float4 heatmap_fragment(VertexOutput in [[stage_in]],
                                constant HeatmapUniforms &uniforms [[buffer(0)]],
                                texture2d<float> imageTexture [[texture(0)]]) {
    float2 uv = in.objectUV + 0.5;
    uv.y = 1.0 - uv.y;
    float2 imgUV = in.imageUV;
    imgUV -= 0.5;
    imgUV *= 0.5714285714285714;
    imgUV += 0.5;
    float imgSoftFrame = getImgFrame(imgUV, 0.03);

    float4 img = imageTexture.sample(linearMipSampler, imgUV);
    float2 dudx = dfdx(imgUV);
    float2 dudy = dfdy(imgUV);
    if (img.a == 0.0) {
        return uniforms.u_colorBack;
    }

    float t = 0.1 * uniforms.u_time - 0.3;
    float tCopy = t + 1.0 / 3.0;
    float tCopy2 = t + 2.0 / 3.0;
    t = mod(t, 1.0);
    tCopy = mod(tCopy, 1.0);
    tCopy2 = mod(tCopy2, 1.0);

    float2 animationUV = imgUV - float2(0.5);
    float angle = -uniforms.u_angle * PI / 180.0;
    float cosA = cos(angle);
    float sinA = sin(angle);
    animationUV = float2(animationUV.x * cosA - animationUV.y * sinA,
                         animationUV.x * sinA + animationUV.y * cosA) + float2(0.5);

    float shape = img[0];
    img[1] = blurEdge3x3(imageTexture, imgUV, dudx, dudy, 8.0, img[1]);
    float outerBlur = 1.0 - mix(1.0, img[1], shape);
    float innerBlur = mix(img[1], 0.0, shape);
    float contour = mix(img[2], 0.0, shape);
    outerBlur *= imgSoftFrame;

    float shadow = shadowShape(animationUV, t, innerBlur);
    float shadowCopy = shadowShape(animationUV, tCopy, innerBlur);
    float shadowCopy2 = shadowShape(animationUV, tCopy2, innerBlur);

    float inner = 0.8 + 0.8 * innerBlur;
    inner = mix(inner, 0.0, shadow);
    inner = mix(inner, 0.0, shadowCopy);
    inner = mix(inner, 0.0, shadowCopy2);
    inner *= mix(0.0, 2.0, uniforms.u_innerGlow);
    inner += (uniforms.u_contour * 2.0) * contour;
    inner = min(1.0, inner);
    inner *= (1.0 - shape);

    float outer = 0.0;
    {
        float tt = mod(t * 3.0 - 0.1, 1.0);
        outer = 0.9 * pow(outerBlur, 0.8);
        float y = mod(animationUV.y - tt, 1.0);
        float animatedMask = sst(0.3, 0.65, y) * (1.0 - sst(0.65, 1.0, y));
        animatedMask = 0.5 + animatedMask;
        outer *= animatedMask;
        outer *= mix(0.0, 5.0, pow(uniforms.u_outerGlow, 2.0));
        outer *= imgSoftFrame;
    }

    inner = pow(inner, 1.2);
    float heat = clamp(inner + outer, 0.0, 1.0);
    heat += (0.005 + 0.35 * uniforms.u_noise) * (fract(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453123) - 0.5);

    float mixer = heat * uniforms.u_colorsCount;
    float4 gradient = uniforms.u_colors[0];
    gradient.rgb *= gradient.a;
    float outerShape = 0.0;
    for (int i = 1; i < kHeatmapMaxColorCount + 1; i++) {
        if (i > int(uniforms.u_colorsCount)) { break; }
        float m = clamp(mixer - float(i - 1), 0.0, 1.0);
        if (i == 1) {
            outerShape = m;
        }
        float4 c = uniforms.u_colors[i - 1];
        c.rgb *= c.a;
        gradient = mix(gradient, c, m);
    }

    float3 color = gradient.rgb * outerShape;
    float opacity = gradient.a * outerShape;
    float3 bgColor = uniforms.u_colorBack.rgb * uniforms.u_colorBack.a;
    color = color + bgColor * (1.0 - opacity);
    opacity = opacity + uniforms.u_colorBack.a * (1.0 - opacity);
    color += 0.02 * (fract(sin(dot(uv + 1.0, float2(12.9898, 78.233))) * 43758.5453123) - 0.5);
    return float4(color, opacity);
}
