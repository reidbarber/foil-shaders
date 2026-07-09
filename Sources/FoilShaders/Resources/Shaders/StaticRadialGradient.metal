#include <metal_stdlib>
#include "Common.h"
#include "ShaderTypes.h"

using namespace metal;

constant int kStaticRadialGradientMaxColorCount = 10;

struct StaticRadialGradientUniforms {
    float4 u_colorBack;
    float4 u_colors[kStaticRadialGradientMaxColorCount];
    float u_colorsCount;
    float u_radius;
    float u_focalDistance;
    float u_focalAngle;
    float u_falloff;
    float u_mixing;
    float u_distortion;
    float u_distortionShift;
    float u_distortionFreq;
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

fragment float4 static_radial_gradient_fragment(VertexOutput in [[stage_in]],
                                               constant StaticRadialGradientUniforms &uniforms [[buffer(0)]]) {
    float2 uv = 2.0 * in.objectUV;
    float2 grainUV = uv * 1000.0;

    float2 center = float2(0.0);
    float angleRad = -radians(uniforms.u_focalAngle + 90.0);
    float2 focalPoint = float2(cos(angleRad), sin(angleRad)) * uniforms.u_focalDistance;
    float radius = uniforms.u_radius;

    float2 c_to_uv = uv - center;
    float2 f_to_uv = uv - focalPoint;
    float2 f_to_c = center - focalPoint;
    float r = length(c_to_uv);

    float fragAngle = atan2(c_to_uv.y, c_to_uv.x);
    float angleDiff = fract((fragAngle - angleRad + PI) / TWO_PI) * TWO_PI - PI;

    float halfAngle = acos(clamp(radius / max(uniforms.u_focalDistance, 1e-4), 0.0, 1.0));
    float e0 = 0.6 * PI;
    float e1 = halfAngle;
    float lo = min(e0, e1);
    float hi = max(e0, e1);
    float s = smoothstep(lo, hi, abs(angleDiff));
    float isInSector = (e1 >= e0) ? (1.0 - s) : s;

    float a = dot(f_to_uv, f_to_uv);
    float b = -2.0 * dot(f_to_uv, f_to_c);
    float c = dot(f_to_c, f_to_c) - radius * radius;

    float discriminant = b * b - 4.0 * a * c;
    float t = 1.0;
    if (discriminant >= 0.0) {
        float sqrtD = sqrt(discriminant);
        float div = max(1e-4, 2.0 * a);
        float t0 = (-b - sqrtD) / div;
        float t1 = (-b + sqrtD) / div;
        t = max(t0, t1);
        if (t < 0.0) t = 0.0;
    }

    float dist = length(f_to_uv);
    float normalized = dist / max(1e-4, length(f_to_uv * t));
    float shape = clamp(normalized, 0.0, 1.0);

    float falloffMapped = mix(0.2 + 0.8 * max(0.0, uniforms.u_falloff + 1.0),
                              mix(1.0, 15.0, uniforms.u_falloff * uniforms.u_falloff),
                              step(0.0, uniforms.u_falloff));
    float falloffExp = mix(falloffMapped, 1.0, shape);
    shape = pow(shape, falloffExp);
    shape = 1.0 - clamp(shape, 0.0, 1.0);

    float outerMask = 0.002;
    float outer = 1.0 - smoothstep(radius - outerMask, radius + outerMask, r);
    outer = mix(outer, 1.0, isInSector);

    shape = mix(0.0, shape, outer);
    shape *= 1.0 - smoothstep(radius - 0.01, radius, r);

    float angle = atan2(f_to_uv.y, f_to_uv.x);
    shape -= pow(uniforms.u_distortion, 2.0) * shape
        * pow(abs(sin(PI * clamp(length(f_to_uv) - 0.2 + uniforms.u_distortionShift, 0.0, 1.0))), 4.0)
        * (sin(uniforms.u_distortionFreq * angle) + cos(floor(0.65 * uniforms.u_distortionFreq) * angle));

    float grain = noise(grainUV, float2(0.0));
    float mixerGrain = 0.4 * uniforms.u_grainMixer * (grain - 0.5);

    float mixer = shape * uniforms.u_colorsCount + mixerGrain;
    float4 gradient = uniforms.u_colors[0];
    gradient.rgb *= gradient.a;

    float outerShape = 0.0;
    for (int i = 1; i < kStaticRadialGradientMaxColorCount + 1; i++) {
        if (i > int(uniforms.u_colorsCount)) break;
        float mLinear = clamp(mixer - float(i - 1), 0.0, 1.0);

        float aa = fwidth(mLinear);
        float width = min(uniforms.u_mixing, 0.5);
        float t = clamp((mLinear - (0.5 - width - aa)) / (2.0 * width + 2.0 * aa), 0.0, 1.0);
        float p = mix(2.0, 1.0, clamp((uniforms.u_mixing - 0.5) * 2.0, 0.0, 1.0));
        float m = t < 0.5 ? 0.5 * pow(2.0 * t, p) : 1.0 - 0.5 * pow(2.0 * (1.0 - t), p);
        float quadBlend = clamp((uniforms.u_mixing - 0.5) * 2.0, 0.0, 1.0);
        m = mix(m, m * m, 0.5 * quadBlend);

        if (i == 1) outerShape = m;

        float4 c = uniforms.u_colors[i - 1];
        c.rgb *= c.a;
        gradient = mix(gradient, c, m);
    }

    float3 color = gradient.rgb * outerShape;
    float opacity = gradient.a * outerShape;

    float3 bgColor = uniforms.u_colorBack.rgb * uniforms.u_colorBack.a;
    color = color + bgColor * (1.0 - opacity);
    opacity = opacity + uniforms.u_colorBack.a * (1.0 - opacity);

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
