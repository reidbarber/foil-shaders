#ifndef PaperShadersCommon_metal
#define PaperShadersCommon_metal

#include <metal_stdlib>
using namespace metal;

// MARK: - Constants

constant float PI = 3.14159265358979323846;
constant float TWO_PI = 6.28318530718;
constexpr sampler linearSampler(coord::normalized, address::clamp_to_edge, filter::linear);

// MARK: - GLSL-like helpers

inline float mod(float x, float y) { return x - y * floor(x / y); }
inline float2 mod(float2 x, float2 y) { return x - y * floor(x / y); }
inline float3 mod(float3 x, float3 y) { return x - y * floor(x / y); }
inline float4 mod(float4 x, float4 y) { return x - y * floor(x / y); }
inline float radians(float degrees) { return degrees * (PI / 180.0); }

// MARK: - Rotation

inline float2 rotate(float2 uv, float th) {
    float cosTh = cos(th);
    float sinTh = sin(th);
    float2x2 rotationMatrix = float2x2(cosTh, sinTh,
                                       -sinTh, cosTh);
    return rotationMatrix * uv;
}

// MARK: - Procedural hash functions

inline float hash11(float p) {
    p = fract(p * 0.3183099) + 0.1;
    p *= p + 19.19;
    return fract(p * p);
}

inline float hash21(float2 p) {
    p = fract(p * float2(0.3183099, 0.3678794)) + 0.1;
    p += dot(p, p + 19.19);
    return fract(p.x * p.y);
}

inline float2 hash22(float2 p) {
    p = fract(p * float2(0.3183099, 0.3678794)) + 0.1;
    p += dot(p, p.yx + 19.19);
    return fract(float2(p.x * p.y, p.x + p.y));
}

// MARK: - Simplex noise (2D)

inline float3 permute(float3 x) {
    return mod(((x * 34.0) + 1.0) * x, 289.0);
}

inline float snoise(float2 v) {
    const float4 C = float4(0.211324865405187, 0.366025403784439,
                            -0.577350269189626, 0.024390243902439);
    float2 i = floor(v + dot(v, C.yy));
    float2 x0 = v - i + dot(i, C.xx);
    float2 i1;
    i1 = (x0.x > x0.y) ? float2(1.0, 0.0) : float2(0.0, 1.0);
    float4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;
    i = mod(i, 289.0);
    float3 p = permute(permute(i.y + float3(0.0, i1.y, 1.0))
                       + i.x + float3(0.0, i1.x, 1.0));
    float3 m = max(0.5 - float3(dot(x0, x0), dot(x12.xy, x12.xy),
                                dot(x12.zw, x12.zw)), 0.0);
    m = m * m;
    m = m * m;
    float3 x = 2.0 * fract(p * C.www) - 1.0;
    float3 h = abs(x) - 0.5;
    float3 ox = floor(x + 0.5);
    float3 a0 = x - ox;
    m *= 1.79284291400159 - 0.85373472095314 * (a0 * a0 + h * h);
    float3 g;
    g.x = a0.x * x0.x + h.x * x0.y;
    g.yz = a0.yz * x12.xz + h.yz * x12.yw;
    return 130.0 * dot(m, g);
}

// MARK: - Color banding fix

inline float3 applyColorBandingFix(float3 color, float2 fragCoord) {
    float n = fract(sin(dot(0.014 * fragCoord, float2(12.9898, 78.233))) * 43758.5453123) - 0.5;
    return color + (1.0 / 256.0) * n;
}

#endif /* PaperShadersCommon_metal */
