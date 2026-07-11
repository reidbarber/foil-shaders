#include <metal_stdlib>
#include "Common.h"
#include "ShaderTypes.h"

using namespace metal;

struct HalftoneCmykUniforms {
    float4 u_colorBack;
    float4 u_colorC;
    float4 u_colorM;
    float4 u_colorY;
    float4 u_colorK;
    float u_size;
    float u_minDot;
    float u_contrast;
    float u_grainSize;
    float u_grainMixer;
    float u_grainOverlay;
    float u_gridNoise;
    float u_softness;
    float u_floodC;
    float u_floodM;
    float u_floodY;
    float u_floodK;
    float u_gainC;
    float u_gainM;
    float u_gainY;
    float u_gainK;
    float u_type;
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

static inline float2 randomRG(texture2d<float> noiseTexture, float2 p) {
    float2 uv = floor(p) / 100.0 + 0.5;
    float4 sample = noiseTexture.sample(linearSampler, fract(uv));
    return sample.rg;
}

static inline float3 hash23(float2 p) {
    float3 p3 = fract(float3(p.x, p.y, p.x) * float3(0.3183099, 0.3678794, 0.3141592)) + 0.1;
    p3 += dot(p3, p3.yzx + 19.19);
    return fract(float3(p3.x * p3.y, p3.y * p3.z, p3.z * p3.x));
}

static inline float sst(float edge0, float edge1, float x) {
    return smoothstep(edge0, edge1, x);
}

static inline float3 valueNoise3(float2 st) {
    float2 i = floor(st);
    float2 f = fract(st);
    float3 a = hash23(i);
    float3 b = hash23(i + float2(1.0, 0.0));
    float3 c = hash23(i + float2(0.0, 1.0));
    float3 d = hash23(i + float2(1.0, 1.0));
    float2 u = f * f * (3.0 - 2.0 * f);
    float3 x1 = mix(a, b, u.x);
    float3 x2 = mix(c, d, u.x);
    return mix(x1, x2, u.y);
}

static inline float getUvFrame(float2 uv, float2 pad) {
    float left = smoothstep(-pad.x, 0.0, uv.x);
    float right = smoothstep(1.0 + pad.x, 1.0, uv.x);
    float bottom = smoothstep(-pad.y, 0.0, uv.y);
    float top = smoothstep(1.0 + pad.y, 1.0, uv.y);
    return left * right * bottom * top;
}

static inline float4 RGBAtoCMYK(float4 rgba) {
    float k = 1.0 - max(max(rgba.r, rgba.g), rgba.b);
    float denom = 1.0 - k;
    float3 cmy = float3(0.0);
    if (denom > 1e-5) {
        cmy = (1.0 - rgba.rgb - float3(k)) / denom;
    }
    return float4(cmy, k) * rgba.a;
}

static inline float3 applyContrast(float3 rgb, float contrast) {
    return clamp((rgb - 0.5) * contrast + 0.5, 0.0, 1.0);
}

static inline float getCyan(float4 rgba, float contrast) {
    float3 c = applyContrast(rgba.rgb, contrast);
    float maxRGB = max(max(c.r, c.g), c.b);
    return (maxRGB > 1e-5 ? (maxRGB - c.r) / maxRGB : 0.0) * rgba.a;
}

static inline float getMagenta(float4 rgba, float contrast) {
    float3 c = applyContrast(rgba.rgb, contrast);
    float maxRGB = max(max(c.r, c.g), c.b);
    return (maxRGB > 1e-5 ? (maxRGB - c.g) / maxRGB : 0.0) * rgba.a;
}

static inline float getYellow(float4 rgba, float contrast) {
    float3 c = applyContrast(rgba.rgb, contrast);
    float maxRGB = max(max(c.r, c.g), c.b);
    return (maxRGB > 1e-5 ? (maxRGB - c.b) / maxRGB : 0.0) * rgba.a;
}

static inline float getBlack(float4 rgba, float contrast) {
    float3 c = applyContrast(rgba.rgb, contrast);
    return (1.0 - max(max(c.r, c.g), c.b)) * rgba.a;
}

static inline float2 cellCenterPos(float2 uv, float2 cellOffset, float channelIdx, float gridNoise, texture2d<float> noiseTexture) {
    float2 cellCenter = floor(uv) + 0.5 + cellOffset;
    return cellCenter + (randomRG(noiseTexture, cellCenter + channelIdx * 50.0) - 0.5) * gridNoise;
}

static inline float2 gridToImageUV(float2 cellCenter, float cosA, float sinA, float shift, float2 pad) {
    float2 shifted = cellCenter - shift;
    float2 uvGrid = float2(
        cosA * shifted.x + sinA * shifted.y,
        -sinA * shifted.x + cosA * shifted.y
    );
    return uvGrid * pad + 0.5;
}

static inline float colorMask(float2 pos,
                      float2 cellCenter,
                      float rad,
                      float outOfFrame,
                      float grain,
                      float channelAddon,
                      float channelGain,
                      float generalComp,
                      bool isJoined,
                      float softness,
                      float outMask) {
    float dist = length(pos - cellCenter);
    float radius = rad;
    radius *= (1.0 + generalComp);
    radius += 0.15 + channelGain * radius;
    radius = max(0.0, radius);
    radius = mix(0.0, radius, outOfFrame);
    radius += channelAddon;
    radius *= (1.0 - grain);
    float mask = 1.0 - sst(0.0, radius, dist);
    if (isJoined) {
        mask = pow(mask, 1.2);
    } else {
        mask = sst(0.5 - 0.5 * softness, 0.51 + 0.49 * softness, mask);
    }
    mask *= mix(1.0, mix(0.5, 1.0, 1.5 * radius), softness);
    return outMask + mask;
}

static inline float3 applyInk(float3 paper, float3 inkColor, float cov) {
    float3 inkEffect = mix(float3(1.0), inkColor, clamp(cov, 0.0, 1.0));
    return paper * inkEffect;
}

fragment float4 halftone_cmyk_fragment(VertexOutput in [[stage_in]],
                                      constant HalftoneCmykUniforms &uniforms [[buffer(0)]],
                                      constant FragmentVertexUniforms &vertexUniforms [[buffer(1)]],
                                      texture2d<float> imageTexture [[texture(0)]],
                                      texture2d<float> noiseTexture [[texture(1)]]) {
    float2 uv = in.imageUV;
    float cellsPerSide = mix(400.0, 7.0, pow(uniforms.u_size, 0.7));
    float cellSizeY = 1.0 / cellsPerSide;
    float2 pad = cellSizeY * float2(1.0 / vertexUniforms.u_imageAspectRatio, 1.0);
    float2 uvGrid = (uv - 0.5) / pad;
    float outOfFrame = getUvFrame(uv, pad);

    float generalComp = 0.1 * uniforms.u_softness + 0.1 * uniforms.u_gridNoise +
                        0.1 * (1.0 - step(0.5, uniforms.u_type)) * (1.5 - uniforms.u_softness);

    const float cosC = 0.9659258; const float sinC = 0.2588190;
    const float cosM = 0.2588190; const float sinM = 0.9659258;
    const float cosY = 1.0;       const float sinY = 0.0;
    const float cosK = 0.7071068; const float sinK = 0.7071068;
    const float shiftC = -0.5;
    const float shiftM = -0.25;
    const float shiftY = 0.2;
    const float shiftK = 0.0;

    float2 uvC = float2(cosC * uvGrid.x - sinC * uvGrid.y, sinC * uvGrid.x + cosC * uvGrid.y) + shiftC;
    float2 uvM = float2(cosM * uvGrid.x - sinM * uvGrid.y, sinM * uvGrid.x + cosM * uvGrid.y) + shiftM;
    float2 uvY = float2(cosY * uvGrid.x - sinY * uvGrid.y, sinY * uvGrid.x + cosY * uvGrid.y) + shiftY;
    float2 uvK = float2(cosK * uvGrid.x - sinK * uvGrid.y, sinK * uvGrid.x + cosK * uvGrid.y) + shiftK;

    float2 grainSize = mix(2000.0, 200.0, uniforms.u_grainSize) * float2(1.0, 1.0 / vertexUniforms.u_imageAspectRatio);
    float2 grainUV = (in.imageUV - 0.5) * grainSize + 0.5;
    float3 noiseValues = valueNoise3(grainUV);
    float grain = sst(0.55, 1.0, noiseValues.r);
    grain *= uniforms.u_grainMixer;

    float4 outMask = float4(0.0);
    bool isJoined = uniforms.u_type > 0.5;

    if (uniforms.u_type < 1.5) {
        for (int dy = -1; dy <= 1; dy++) {
            for (int dx = -1; dx <= 1; dx++) {
                float2 cellOffset = float2(float(dx), float(dy));
                float2 cellCenterC = cellCenterPos(uvC, cellOffset, 0.0, uniforms.u_gridNoise, noiseTexture);
                float4 texC = imageTexture.sample(linearSampler, gridToImageUV(cellCenterC, cosC, sinC, shiftC, pad));
                outMask.x = colorMask(uvC, cellCenterC, getCyan(texC, uniforms.u_contrast), outOfFrame * texC.a, grain, uniforms.u_floodC, uniforms.u_gainC, generalComp, isJoined, uniforms.u_softness, outMask.x);

                float2 cellCenterM = cellCenterPos(uvM, cellOffset, 1.0, uniforms.u_gridNoise, noiseTexture);
                float4 texM = imageTexture.sample(linearSampler, gridToImageUV(cellCenterM, cosM, sinM, shiftM, pad));
                outMask.y = colorMask(uvM, cellCenterM, getMagenta(texM, uniforms.u_contrast), outOfFrame * texM.a, grain, uniforms.u_floodM, uniforms.u_gainM, generalComp, isJoined, uniforms.u_softness, outMask.y);

                float2 cellCenterY = cellCenterPos(uvY, cellOffset, 2.0, uniforms.u_gridNoise, noiseTexture);
                float4 texY = imageTexture.sample(linearSampler, gridToImageUV(cellCenterY, cosY, sinY, shiftY, pad));
                outMask.z = colorMask(uvY, cellCenterY, getYellow(texY, uniforms.u_contrast), outOfFrame * texY.a, grain, uniforms.u_floodY, uniforms.u_gainY, generalComp, isJoined, uniforms.u_softness, outMask.z);

                float2 cellCenterK = cellCenterPos(uvK, cellOffset, 3.0, uniforms.u_gridNoise, noiseTexture);
                float4 texK = imageTexture.sample(linearSampler, gridToImageUV(cellCenterK, cosK, sinK, shiftK, pad));
                outMask.w = colorMask(uvK, cellCenterK, getBlack(texK, uniforms.u_contrast), outOfFrame * texK.a, grain, uniforms.u_floodK, uniforms.u_gainK, generalComp, isJoined, uniforms.u_softness, outMask.w);
            }
        }
    } else {
        float4 tex = imageTexture.sample(linearSampler, uv);
        tex.rgb = applyContrast(tex.rgb, uniforms.u_contrast);
        outOfFrame *= tex.a;
        float4 cmykOriginal = RGBAtoCMYK(tex);
        for (int dy = -1; dy <= 1; dy++) {
            for (int dx = -1; dx <= 1; dx++) {
                float2 cellOffset = float2(float(dx), float(dy));
                outMask.x = colorMask(uvC, cellCenterPos(uvC, cellOffset, 0.0, uniforms.u_gridNoise, noiseTexture), cmykOriginal.x, outOfFrame, grain, uniforms.u_floodC, uniforms.u_gainC, generalComp, isJoined, uniforms.u_softness, outMask.x);
                outMask.y = colorMask(uvM, cellCenterPos(uvM, cellOffset, 1.0, uniforms.u_gridNoise, noiseTexture), cmykOriginal.y, outOfFrame, grain, uniforms.u_floodM, uniforms.u_gainM, generalComp, isJoined, uniforms.u_softness, outMask.y);
                outMask.z = colorMask(uvY, cellCenterPos(uvY, cellOffset, 2.0, uniforms.u_gridNoise, noiseTexture), cmykOriginal.z, outOfFrame, grain, uniforms.u_floodY, uniforms.u_gainY, generalComp, isJoined, uniforms.u_softness, outMask.z);
                outMask.w = colorMask(uvK, cellCenterPos(uvK, cellOffset, 3.0, uniforms.u_gridNoise, noiseTexture), cmykOriginal.w, outOfFrame, grain, uniforms.u_floodK, uniforms.u_gainK, generalComp, isJoined, uniforms.u_softness, outMask.w);
            }
        }
    }

    float C = outMask.x;
    float M = outMask.y;
    float Y = outMask.z;
    float K = outMask.w;
    if (isJoined) {
        float th = 0.5;
        float sLeft = th * uniforms.u_softness;
        float sRight = (1.0 - th) * uniforms.u_softness + 0.01;
        C = smoothstep(th - sLeft - fwidth(C), th + sRight, C);
        M = smoothstep(th - sLeft - fwidth(M), th + sRight, M);
        Y = smoothstep(th - sLeft - fwidth(Y), th + sRight, Y);
        K = smoothstep(th - sLeft - fwidth(K), th + sRight, K);
    }

    C *= uniforms.u_colorC.a;
    M *= uniforms.u_colorM.a;
    Y *= uniforms.u_colorY.a;
    K *= uniforms.u_colorK.a;

    float3 ink = float3(1.0);
    ink = applyInk(ink, uniforms.u_colorK.rgb, K);
    ink = applyInk(ink, uniforms.u_colorC.rgb, C);
    ink = applyInk(ink, uniforms.u_colorM.rgb, M);
    ink = applyInk(ink, uniforms.u_colorY.rgb, Y);

    float shape = clamp(max(max(C, M), max(Y, K)), 0.0, 1.0);
    float3 color = uniforms.u_colorBack.rgb * uniforms.u_colorBack.a;
    float opacity = uniforms.u_colorBack.a;
    color = mix(color, ink, shape);
    opacity += shape;
    opacity = clamp(opacity, 0.0, 1.0);

    float grainOverlay = mix(noiseValues.g, noiseValues.b, 0.5);
    grainOverlay = pow(grainOverlay, 1.3);
    float grainOverlayV = grainOverlay * 2.0 - 1.0;
    float3 grainOverlayColor = float3(step(0.0, grainOverlayV));
    float grainOverlayStrength = uniforms.u_grainOverlay * abs(grainOverlayV);
    grainOverlayStrength = pow(grainOverlayStrength, 0.8);
    color = mix(color, grainOverlayColor, 0.5 * grainOverlayStrength);
    opacity += 0.5 * grainOverlayStrength;
    opacity = clamp(opacity, 0.0, 1.0);
    return float4(color, opacity);
}
