#include <metal_stdlib>
#include "Common.h"
#include "ShaderTypes.h"

using namespace metal;

constant int kStaticMeshGradientMaxColorCount = 10;

struct StaticMeshGradientUniforms {
    float4 u_colors[kStaticMeshGradientMaxColorCount];
    float u_colorsCount;
    float u_positions;
    float u_waveX;
    float u_waveXShift;
    float u_waveY;
    float u_waveYShift;
    float u_mixing;
    float u_grainMixer;
    float u_grainOverlay;
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

static inline float noise(float2 n, float2 seedOffset) {
    return valueNoise(n + seedOffset);
}

static inline float2 getPosition(int i, float t) {
    float a = float(i) * 0.37;
    float b = 0.6 + mod(float(i), 3.0) * 0.3;
    float c = 0.8 + mod(float(i + 1), 4.0) * 0.25;
    float x = sin(t * b + a);
    float y = cos(t * c + a * 1.5);
    return 0.5 + 0.5 * float2(x, y);
}

fragment float4 static_mesh_gradient_fragment(VertexOutput in [[stage_in]],
                                              constant StaticMeshGradientUniforms &uniforms [[buffer(0)]]) {
    float2 uv = in.objectUV + 0.5;
    float2 grainUV = uv * 1000.0;

    float grain = noise(grainUV, float2(0.0));
    float mixerGrain = 0.4 * uniforms.u_grainMixer * (grain - 0.5);

    float radius = smoothstep(0.0, 1.0, length(uv - 0.5));
    float center = 1.0 - radius;
    for (float i = 1.0; i <= 2.0; i += 1.0) {
        uv.x += uniforms.u_waveX * center / i * cos(TWO_PI * uniforms.u_waveXShift + i * 2.0 * smoothstep(0.0, 1.0, uv.y));
        uv.y += uniforms.u_waveY * center / i * cos(TWO_PI * uniforms.u_waveYShift + i * 2.0 * smoothstep(0.0, 1.0, uv.x));
    }

    float3 color = float3(0.0);
    float opacity = 0.0;
    float totalWeight = 0.0;
    float positionSeed = 25.0 + 0.33 * uniforms.u_positions;

    for (int i = 0; i < kStaticMeshGradientMaxColorCount; i++) {
        if (i >= int(uniforms.u_colorsCount)) { break; }
        float2 pos = getPosition(i, positionSeed) + mixerGrain;
        float dist = length(uv - pos);
        float3 colorFraction = uniforms.u_colors[i].rgb * uniforms.u_colors[i].a;
        float opacityFraction = uniforms.u_colors[i].a;

        float mixing = pow(uniforms.u_mixing, 0.7);
        float power = mix(2.0, 1.0, mixing);
        dist = pow(dist, power);

        float w = 1.0 / (dist + 1e-3);
        float baseSharpness = mix(0.0, 8.0, clamp(w, 0.0, 1.0));
        float sharpness = mix(baseSharpness, 1.0, mixing);
        w = pow(w, sharpness);
        color += colorFraction * w;
        opacity += opacityFraction * w;
        totalWeight += w;
    }

    color /= max(1e-4, totalWeight);
    opacity /= max(1e-4, totalWeight);

    float grainOverlay = valueNoise(rotate(grainUV, 1.0) + float2(3.0));
    grainOverlay = mix(grainOverlay, valueNoise(rotate(grainUV, 2.0) + float2(-1.0)), 0.5);
    grainOverlay = pow(grainOverlay, 1.3);

    float grainOverlayV = grainOverlay * 2.0 - 1.0;
    float3 grainOverlayColor = float3(step(0.0, grainOverlayV));
    float grainOverlayStrength = uniforms.u_grainOverlay * abs(grainOverlayV);
    grainOverlayStrength = pow(grainOverlayStrength, 0.8);
    color = mix(color, grainOverlayColor, 0.35 * grainOverlayStrength);

    opacity += 0.5 * grainOverlayStrength;
    opacity = clamp(opacity, 0.0, 1.0);

    return float4(color, opacity);
}
