#include <metal_stdlib>
#include "Common.h"
#include "ShaderTypes.h"

using namespace metal;

// MARK: - Mesh Gradient Uniforms

constant int kMeshGradientMaxColorCount = 10;

struct MeshGradientUniforms {
    float u_time;
    float4 u_colors[kMeshGradientMaxColorCount];
    float u_colorsCount;
    float u_distortion;
    float u_swirl;
    float u_grainMixer;
    float u_grainOverlay;
};

// MARK: - Noise Helpers

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
    float b = 0.6 + fract(float(i) / 3.0) * 0.9;
    float c = 0.8 + fract(float(i + 1) / 4.0);
    float x = sin(t * b + a);
    float y = cos(t * c + a * 1.5);
    return 0.5 + 0.5 * float2(x, y);
}

// MARK: - Fragment Shader

fragment float4 mesh_gradient_fragment(VertexOutput in [[stage_in]],
                                      constant MeshGradientUniforms &uniforms [[buffer(0)]]) {
    float2 uv = in.objectUV;
    uv += 0.5;
    float2 grainUV = uv * 1000.0;
    
    float grain = noise(grainUV, float2(0.0));
    float mixerGrain = 0.4 * uniforms.u_grainMixer * (grain - 0.5);
    
    const float firstFrameOffset = 41.5;
    float t = 0.5 * (uniforms.u_time + firstFrameOffset);
    
    float radius = smoothstep(0.0, 1.0, length(uv - 0.5));
    float center = 1.0 - radius;
    for (float i = 1.0; i <= 2.0; i += 1.0) {
        // Match the reference evaluation order: the uv.y update reads uv.x
        // *after* it has been mutated on the line above, so smoothX must be
        // recomputed here rather than hoisted before the uv.x update.
        float smoothY = smoothstep(0.0, 1.0, uv.y);
        uv.x += uniforms.u_distortion * center / i * sin(t + i * 0.4 * smoothY) * cos(0.2 * t + i * 2.4 * smoothY);
        float smoothX = smoothstep(0.0, 1.0, uv.x);
        uv.y += uniforms.u_distortion * center / i * cos(t + i * 2.0 * smoothX);
    }
    
    float2 uvRotated = uv;
    uvRotated -= float2(0.5);
    float angle = 3.0 * uniforms.u_swirl * radius;
    uvRotated = rotate(uvRotated, -angle);
    uvRotated += float2(0.5);
    
    float3 color = float3(0.0);
    float opacity = 0.0;
    float totalWeight = 0.0;
    
    for (int i = 0; i < kMeshGradientMaxColorCount; i++) {
        if (i >= int(uniforms.u_colorsCount)) {
            break;
        }
        float2 pos = getPosition(i, t) + mixerGrain;
        float3 colorFraction = uniforms.u_colors[i].rgb * uniforms.u_colors[i].a;
        float opacityFraction = uniforms.u_colors[i].a;
        
        float dist = length(uvRotated - pos);
        dist = pow(dist, 3.5);
        float weight = 1.0 / (dist + 1e-3);
        color += colorFraction * weight;
        opacity += opacityFraction * weight;
        totalWeight += weight;
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
