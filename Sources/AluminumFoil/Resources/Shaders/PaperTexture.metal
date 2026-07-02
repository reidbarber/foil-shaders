#include <metal_stdlib>
#include "Common.metal"

using namespace metal;

struct PaperTextureUniforms {
    float4 u_colorFront;
    float4 u_colorBack;
    float u_contrast;
    float u_roughness;
    float u_fiber;
    float u_fiberSize;
    float u_crumples;
    float u_crumpleSize;
    float u_folds;
    float u_foldCount;
    float u_drops;
    float u_seed;
    float u_fade;
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

inline float getUvFrame(float2 uv) {
    float aax = 2.0 * fwidth(uv.x);
    float aay = 2.0 * fwidth(uv.y);
    float left = smoothstep(0.0, aax, uv.x);
    float right = 1.0 - smoothstep(1.0 - aax, 1.0, uv.x);
    float bottom = smoothstep(0.0, aay, uv.y);
    float top = 1.0 - smoothstep(1.0 - aay, 1.0, uv.y);
    return left * right * bottom * top;
}

inline float randomR(texture2d<float> noiseTexture, float2 p) {
    float2 uv = floor(p) / 100.0 + 0.5;
    return noiseTexture.sample(linearSampler, fract(uv)).r;
}

inline float valueNoise(float2 st, texture2d<float> noiseTexture) {
    float2 i = floor(st);
    float2 f = fract(st);
    float a = randomR(noiseTexture, i);
    float b = randomR(noiseTexture, i + float2(1.0, 0.0));
    float c = randomR(noiseTexture, i + float2(0.0, 1.0));
    float d = randomR(noiseTexture, i + float2(1.0, 1.0));
    float2 u = f * f * (3.0 - 2.0 * f);
    float x1 = mix(a, b, u.x);
    float x2 = mix(c, d, u.x);
    return mix(x1, x2, u.y);
}

inline float fbm(float2 n, texture2d<float> noiseTexture) {
    float total = 0.0;
    float amplitude = 0.4;
    for (int i = 0; i < 3; i++) {
        total += valueNoise(n, noiseTexture) * amplitude;
        n *= 1.99;
        amplitude *= 0.65;
    }
    return total;
}

inline float randomG(texture2d<float> noiseTexture, float2 p) {
    float2 uv = floor(p) / 50.0 + 0.5;
    return noiseTexture.sample(linearSampler, fract(uv)).g;
}

inline float roughnessValue(float2 p, texture2d<float> noiseTexture) {
    p *= 0.1;
    float o = 0.0;
    for (float i = 0.0; ++i < 4.0; p *= 2.1) {
        float4 w = float4(floor(p), ceil(p));
        float2 f = fract(p);
        o += mix(
            mix(randomG(noiseTexture, w.xy), randomG(noiseTexture, w.xw), f.y),
            mix(randomG(noiseTexture, w.zy), randomG(noiseTexture, w.zw), f.y),
            f.x
        );
        o += 0.2 / exp(2.0 * abs(sin(0.2 * p.x + 0.5 * p.y)));
    }
    return o / 3.0;
}

inline float2 randomGB(texture2d<float> noiseTexture, float2 p) {
    float2 uv = floor(p) / 50.0 + 0.5;
    float4 sample = noiseTexture.sample(linearSampler, fract(uv));
    return sample.gb;
}

inline float fiberRandom(texture2d<float> noiseTexture, float2 p) {
    float2 uv = floor(p) / 100.0;
    return noiseTexture.sample(linearSampler, fract(uv)).b;
}

inline float fiberValueNoise(texture2d<float> noiseTexture, float2 st) {
    float2 i = floor(st);
    float2 f = fract(st);
    float a = fiberRandom(noiseTexture, i);
    float b = fiberRandom(noiseTexture, i + float2(1.0, 0.0));
    float c = fiberRandom(noiseTexture, i + float2(0.0, 1.0));
    float d = fiberRandom(noiseTexture, i + float2(1.0, 1.0));
    float2 u = f * f * (3.0 - 2.0 * f);
    float x1 = mix(a, b, u.x);
    float x2 = mix(c, d, u.x);
    return mix(x1, x2, u.y);
}

inline float fiberNoiseFbm(texture2d<float> noiseTexture, float2 n, float2 seedOffset) {
    float total = 0.0;
    float amplitude = 1.0;
    for (int i = 0; i < 4; i++) {
        n = rotate(n, 0.7);
        total += fiberValueNoise(noiseTexture, n + seedOffset) * amplitude;
        n *= 2.0;
        amplitude *= 0.6;
    }
    return total;
}

inline float fiberNoise(texture2d<float> noiseTexture, float2 uv, float2 seedOffset) {
    float epsilon = 0.001;
    float n1 = fiberNoiseFbm(noiseTexture, uv + float2(epsilon, 0.0), seedOffset);
    float n2 = fiberNoiseFbm(noiseTexture, uv - float2(epsilon, 0.0), seedOffset);
    float n3 = fiberNoiseFbm(noiseTexture, uv + float2(0.0, epsilon), seedOffset);
    float n4 = fiberNoiseFbm(noiseTexture, uv - float2(0.0, epsilon), seedOffset);
    return length(float2(n1 - n2, n3 - n4)) / (2.0 * epsilon);
}

inline float crumpledNoise(float2 t, float pw, texture2d<float> noiseTexture) {
    float2 p = floor(t);
    float wsum = 0.0;
    float cl = 0.0;
    for (int y = -1; y < 2; y++) {
        for (int x = -1; x < 2; x++) {
            float2 b = float2(float(x), float(y));
            float2 q = b + p;
            float2 q2 = q - floor(q / 8.0) * 8.0;
            float2 c = q + randomGB(noiseTexture, q2);
            float2 r = c - t;
            float w = pow(smoothstep(0.0, 1.0, 1.0 - abs(r.x)), pw) *
                      pow(smoothstep(0.0, 1.0, 1.0 - abs(r.y)), pw);
            cl += (0.5 + 0.5 * sin((q2.x + q2.y * 5.0) * 8.0)) * w;
            wsum += w;
        }
    }
    return pow(wsum != 0.0 ? cl / wsum : 0.0, 0.5) * 2.0;
}

inline float crumplesShape(float2 uv, texture2d<float> noiseTexture) {
    return crumpledNoise(uv * 0.25, 16.0, noiseTexture) * crumpledNoise(uv * 0.5, 2.0, noiseTexture);
}

inline float2 folds(float2 uv, float seed, float foldCount, texture2d<float> noiseTexture) {
    float3 pp = float3(0.0);
    float l = 9.0;
    for (float i = 0.0; i < 15.0; i++) {
        if (i >= foldCount) { break; }
        float2 rand = randomGB(noiseTexture, float2(i, i * seed));
        float an = rand.x * TWO_PI;
        float2 p = float2(cos(an), sin(an)) * rand.y;
        float dist = distance(uv, p);
        l = min(l, dist);
        if (l == dist) {
            pp.xy = (uv - p.xy);
            pp.z = dist;
        }
    }
    return mix(pp.xy, float2(0.0), pow(pp.z, 0.25));
}

inline float drops(float2 uv, float seed, texture2d<float> noiseTexture) {
    float2 iDropsUV = floor(uv);
    float2 fDropsUV = fract(uv);
    float dropsMinDist = 1.0;
    for (int j = -1; j <= 1; j++) {
        for (int i = -1; i <= 1; i++) {
            float2 neighbor = float2(float(i), float(j));
            float2 offset = randomGB(noiseTexture, iDropsUV + neighbor);
            offset = 0.5 + 0.5 * sin(10.0 * seed + TWO_PI * offset);
            float2 pos = neighbor + offset - fDropsUV;
            float dist = length(pos);
            dropsMinDist = min(dropsMinDist, dropsMinDist * dist);
        }
    }
    return 1.0 - smoothstep(0.05, 0.09, pow(dropsMinDist, 0.5));
}

fragment float4 paper_texture_fragment(VertexOutput in [[stage_in]],
                                      constant PaperTextureUniforms &uniforms [[buffer(0)]],
                                      constant FragmentVertexUniforms &vertexUniforms [[buffer(1)]],
                                      texture2d<float> imageTexture [[texture(0)]],
                                      texture2d<float> noiseTexture [[texture(1)]]) {
    float2 imageUV = in.imageUV;
    float2 patternUV = in.imageUV - 0.5;
    patternUV = 5.0 * (patternUV * float2(vertexUniforms.u_imageAspectRatio, 1.0));

    float2 roughnessUv = 1.5 * (in.position.xy - 0.5 * vertexUniforms.u_resolution) / vertexUniforms.u_pixelRatio;
    float roughness = roughnessValue(roughnessUv + float2(1.0, 0.0), noiseTexture) -
                      roughnessValue(roughnessUv - float2(1.0, 0.0), noiseTexture);

    float2 crumplesUV = fract(patternUV * 0.02 / uniforms.u_crumpleSize - uniforms.u_seed) * 32.0;
    float crumples = uniforms.u_crumples * (crumplesShape(crumplesUV + float2(0.05, 0.0), noiseTexture) -
                                            crumplesShape(crumplesUV, noiseTexture));

    float2 fiberUV = 2.0 / uniforms.u_fiberSize * patternUV;
    float fiber = fiberNoise(noiseTexture, fiberUV, float2(0.0));
    fiber = 0.5 * uniforms.u_fiber * (fiber - 1.0);

    float2 normal = float2(0.0);
    float2 normalImage = float2(0.0);

    float2 foldsUV = patternUV * 0.12;
    foldsUV = rotate(foldsUV, 4.0 * uniforms.u_seed);
    float2 w = folds(foldsUV, uniforms.u_seed, uniforms.u_foldCount, noiseTexture);
    foldsUV = rotate(foldsUV + 0.007 * cos(uniforms.u_seed), 0.01 * sin(uniforms.u_seed));
    float2 w2 = folds(foldsUV, uniforms.u_seed, uniforms.u_foldCount, noiseTexture);

    float dropsV = uniforms.u_drops * drops(patternUV * 2.0, uniforms.u_seed, noiseTexture);
    float fade = uniforms.u_fade * fbm(0.17 * patternUV + 10.0 * uniforms.u_seed, noiseTexture);
    fade = clamp(8.0 * fade * fade * fade, 0.0, 1.0);

    w = mix(w, float2(0.0), fade);
    w2 = mix(w2, float2(0.0), fade);
    crumples = mix(crumples, 0.0, fade);
    dropsV = mix(dropsV, 0.0, fade);
    fiber *= mix(1.0, 0.5, fade);
    roughness *= mix(1.0, 0.5, fade);

    normal.xy += uniforms.u_folds * min(5.0 * uniforms.u_contrast, 1.0) * 4.0 * max(float2(0.0), w + w2);
    normalImage.xy += uniforms.u_folds * 2.0 * w;
    normal.xy += crumples;
    normalImage.xy += 1.5 * crumples;
    normal.xy += 3.0 * dropsV;
    normalImage.xy += 0.2 * dropsV;
    normal.xy += uniforms.u_roughness * 1.5 * roughness;
    normal.xy += fiber;
    normalImage += uniforms.u_roughness * 0.75 * roughness;
    normalImage += 0.2 * fiber;

    float3 lightPos = float3(1.0, 2.0, 1.0);
    float res = dot(normalize(float3(normal, 9.5 - 9.0 * pow(uniforms.u_contrast, 0.1))), normalize(lightPos));

    float3 fgColor = uniforms.u_colorFront.rgb * uniforms.u_colorFront.a;
    float fgOpacity = uniforms.u_colorFront.a;
    float3 bgColor = uniforms.u_colorBack.rgb * uniforms.u_colorBack.a;
    float bgOpacity = uniforms.u_colorBack.a;

    imageUV += 0.02 * normalImage;
    float frame = getUvFrame(imageUV);
    float4 image = imageTexture.sample(linearSampler, imageUV);
    image.rgb += 0.6 * pow(uniforms.u_contrast, 0.4) * (res - 0.7);
    frame *= image.a;

    float3 color = fgColor * res;
    float opacity = fgOpacity * res;
    color += bgColor * (1.0 - opacity);
    opacity += bgOpacity * (1.0 - opacity);
    opacity = mix(opacity, 1.0, frame);
    color -= 0.007 * dropsV;
    color = mix(color, image.rgb, frame);

    return float4(color, opacity);
}
