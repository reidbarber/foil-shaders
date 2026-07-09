#include <metal_stdlib>
#include "Common.h"
#include "ShaderTypes.h"

using namespace metal;

struct PerlinNoiseUniforms {
    float u_time;
    float4 u_colorFront;
    float4 u_colorBack;
    float u_proportion;
    float u_softness;
    float u_octaveCount;
    float u_persistence;
    float u_lacunarity;
};

static inline float hash31(float3 p) {
    p = fract(p * 0.3183099) + 0.1;
    p += dot(p, p.yzx + 19.19);
    return fract(p.x * (p.y + p.z));
}

static inline float3 gradientPredefined(float hash) {
    int idx = int(hash * 12.0) % 12;
    if (idx == 0) return float3(1, 1, 0);
    if (idx == 1) return float3(-1, 1, 0);
    if (idx == 2) return float3(1, -1, 0);
    if (idx == 3) return float3(-1, -1, 0);
    if (idx == 4) return float3(1, 0, 1);
    if (idx == 5) return float3(-1, 0, 1);
    if (idx == 6) return float3(1, 0, -1);
    if (idx == 7) return float3(-1, 0, -1);
    if (idx == 8) return float3(0, 1, 1);
    if (idx == 9) return float3(0, -1, 1);
    if (idx == 10) return float3(0, 1, -1);
    return float3(0, -1, -1);
}

static inline float interpolateSafe(float v000, float v001, float v010, float v011,
                             float v100, float v101, float v110, float v111, float3 t) {
    t = clamp(t, 0.0, 1.0);
    float v00 = mix(v000, v100, t.x);
    float v01 = mix(v001, v101, t.x);
    float v10 = mix(v010, v110, t.x);
    float v11 = mix(v011, v111, t.x);
    float v0 = mix(v00, v10, t.y);
    float v1 = mix(v01, v11, t.y);
    return mix(v0, v1, t.z);
}

static inline float3 fade(float3 t) {
    return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
}

static inline float perlinNoise(float3 position, float seed) {
    position += float3(seed * 127.1, seed * 311.7, seed * 74.7);
    float3 i = floor(position);
    float3 f = fract(position);
    float h000 = hash31(i);
    float h001 = hash31(i + float3(0, 0, 1));
    float h010 = hash31(i + float3(0, 1, 0));
    float h011 = hash31(i + float3(0, 1, 1));
    float h100 = hash31(i + float3(1, 0, 0));
    float h101 = hash31(i + float3(1, 0, 1));
    float h110 = hash31(i + float3(1, 1, 0));
    float h111 = hash31(i + float3(1, 1, 1));
    float3 g000 = gradientPredefined(h000);
    float3 g001 = gradientPredefined(h001);
    float3 g010 = gradientPredefined(h010);
    float3 g011 = gradientPredefined(h011);
    float3 g100 = gradientPredefined(h100);
    float3 g101 = gradientPredefined(h101);
    float3 g110 = gradientPredefined(h110);
    float3 g111 = gradientPredefined(h111);
    float v000 = dot(g000, f - float3(0, 0, 0));
    float v001 = dot(g001, f - float3(0, 0, 1));
    float v010 = dot(g010, f - float3(0, 1, 0));
    float v011 = dot(g011, f - float3(0, 1, 1));
    float v100 = dot(g100, f - float3(1, 0, 0));
    float v101 = dot(g101, f - float3(1, 0, 1));
    float v110 = dot(g110, f - float3(1, 1, 0));
    float v111 = dot(g111, f - float3(1, 1, 1));
    float3 u = fade(f);
    return interpolateSafe(v000, v001, v010, v011, v100, v101, v110, v111, u);
}

static inline float p_noise(float3 position, int octaveCount, float persistence, float lacunarity) {
    float value = 0.0;
    float amplitude = 1.0;
    float frequency = 10.0;
    float maxValue = 0.0;
    octaveCount = clamp(octaveCount, 1, 8);
    for (int i = 0; i < octaveCount; i++) {
        float seed = float(i) * 0.7319;
        value += perlinNoise(position * frequency, seed) * amplitude;
        maxValue += amplitude;
        amplitude *= persistence;
        frequency *= lacunarity;
    }
    return value;
}

static inline float get_max_amp(float persistence, float octaveCount) {
    persistence = clamp(persistence * 0.999, 0.0, 0.999);
    octaveCount = clamp(octaveCount, 1.0, 8.0);
    if (abs(persistence - 1.0) < 0.001) {
        return octaveCount;
    }
    return (1.0 - pow(persistence, octaveCount)) / max(1e-4, (1.0 - persistence));
}

fragment float4 perlin_noise_fragment(VertexOutput in [[stage_in]],
                                     constant PerlinNoiseUniforms &uniforms [[buffer(0)]]) {
    float2 uv = in.patternUV * 0.5;
    float t = 0.2 * uniforms.u_time;
    float3 p = float3(uv, t);
    float octCount = floor(uniforms.u_octaveCount);
    float noise = p_noise(p, int(octCount), uniforms.u_persistence, uniforms.u_lacunarity);
    float max_amp = get_max_amp(uniforms.u_persistence, octCount);
    float noise_normalized = clamp((noise + max_amp) / max(1e-4, (2.0 * max_amp)) + (uniforms.u_proportion - 0.5), 0.0, 1.0);
    float sharpness = clamp(uniforms.u_softness, 0.0, 1.0);
    float smooth_w = 0.5 * max(fwidth(noise_normalized), 0.001);
    float res = smoothstep(0.5 - 0.5 * sharpness - smooth_w,
                           0.5 + 0.5 * sharpness + smooth_w,
                           noise_normalized);

    float3 fgColor = uniforms.u_colorFront.rgb * uniforms.u_colorFront.a;
    float fgOpacity = uniforms.u_colorFront.a;
    float3 bgColor = uniforms.u_colorBack.rgb * uniforms.u_colorBack.a;
    float bgOpacity = uniforms.u_colorBack.a;

    float3 color = fgColor * res;
    float opacity = fgOpacity * res;
    color += bgColor * (1.0 - opacity);
    opacity += bgOpacity * (1.0 - opacity);

    color = applyColorBandingFix(color, in.position.xy);
    return float4(color, opacity);
}
