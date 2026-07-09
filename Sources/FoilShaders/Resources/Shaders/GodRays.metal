#include <metal_stdlib>
#include "Common.h"
#include "ShaderTypes.h"

using namespace metal;

constant int kGodRaysMaxColorCount = 5;

struct GodRaysUniforms {
    float u_time;
    float4 u_colorBack;
    float4 u_colorBloom;
    float4 u_colors[kGodRaysMaxColorCount];
    float u_colorsCount;
    float u_density;
    float u_spotty;
    float u_midSize;
    float u_midIntensity;
    float u_intensity;
    float u_bloom;
};

static inline float randomR(texture2d<float> noiseTexture, float2 p) {
    float2 uv = floor(p) / 100.0 + 0.5;
    return noiseTexture.sample(linearSampler, fract(uv)).r;
}

static inline float valueNoise(float2 st, texture2d<float> noiseTexture) {
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

static inline float raysShape(float2 uv, float r, float freq, float intensity, float radius, texture2d<float> noiseTexture) {
    float a = atan2(uv.y, uv.x);
    float2 left = float2(a * freq, r);
    float2 right = float2(fract(a / TWO_PI) * TWO_PI * freq, r);
    float n_left = pow(valueNoise(left, noiseTexture), intensity);
    float n_right = pow(valueNoise(right, noiseTexture), intensity);
    float shape = mix(n_right, n_left, smoothstep(-0.15, 0.15, uv.x));
    return shape;
}

fragment float4 god_rays_fragment(VertexOutput in [[stage_in]],
                                 constant GodRaysUniforms &uniforms [[buffer(0)]],
                                 texture2d<float> noiseTexture [[texture(1)]]) {
    float2 shape_uv = in.objectUV;
    float t = 0.2 * uniforms.u_time;
    float radius = length(shape_uv);
    float spots = 6.5 * abs(uniforms.u_spotty);
    float intensity = 4.0 - 3.0 * clamp(uniforms.u_intensity, 0.0, 1.0);
    float midSize = 10.0 * abs(uniforms.u_midSize);
    float ms_lo = 0.02 * midSize;
    float ms_hi = max(midSize, 1e-6);
    float middleShape = pow(uniforms.u_midIntensity, 0.3) * (1.0 - smoothstep(ms_lo, ms_hi, 3.0 * radius));
    middleShape = pow(middleShape, 5.0);

    float3 accumColor = float3(0.0);
    float accumAlpha = 0.0;

    for (int i = 0; i < kGodRaysMaxColorCount; i++) {
        if (i >= int(uniforms.u_colorsCount)) { break; }
        float2 rotatedUV = rotate(shape_uv, float(i) + 1.0);
        float r1 = radius * (1.0 + 0.4 * float(i)) - 3.0 * t;
        float r2 = 0.5 * radius * (1.0 + spots) - 2.0 * t;
        float density = 6.0 * uniforms.u_density + step(0.5, uniforms.u_density) * pow(4.5 * (uniforms.u_density - 0.5), 4.0);
        float f = mix(1.0, 3.0 + 0.5 * float(i), hash11(float(i) * 15.0)) * density;

        float ray = raysShape(rotatedUV, r1, 5.0 * f, intensity, radius, noiseTexture);
        ray *= raysShape(rotatedUV, r2, 4.0 * f, intensity, radius, noiseTexture);
        ray += (1.0 + 4.0 * ray) * middleShape;
        ray = clamp(ray, 0.0, 1.0);

        float srcAlpha = uniforms.u_colors[i].a * ray;
        float3 srcColor = uniforms.u_colors[i].rgb * srcAlpha;

        float3 alphaBlendColor = accumColor + (1.0 - accumAlpha) * srcColor;
        float alphaBlendAlpha = accumAlpha + (1.0 - accumAlpha) * srcAlpha;

        float3 addBlendColor = accumColor + srcColor;
        float addBlendAlpha = accumAlpha + srcAlpha;

        accumColor = mix(alphaBlendColor, addBlendColor, uniforms.u_bloom);
        accumAlpha = mix(alphaBlendAlpha, addBlendAlpha, uniforms.u_bloom);
    }

    float overlayAlpha = uniforms.u_colorBloom.a;
    float3 overlayColor = uniforms.u_colorBloom.rgb * overlayAlpha;
    float3 colorWithOverlay = accumColor + accumAlpha * overlayColor;
    accumColor = mix(accumColor, colorWithOverlay, uniforms.u_bloom);

    float3 bgColor = uniforms.u_colorBack.rgb * uniforms.u_colorBack.a;
    float3 color = accumColor + (1.0 - accumAlpha) * bgColor;
    float opacity = accumAlpha + (1.0 - accumAlpha) * uniforms.u_colorBack.a;
    color = clamp(color, 0.0, 1.0);
    opacity = clamp(opacity, 0.0, 1.0);

    color = applyColorBandingFix(color, in.position.xy);
    return float4(color, opacity);
}
