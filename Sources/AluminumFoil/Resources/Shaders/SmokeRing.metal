#include <metal_stdlib>
#include "Common.metal"

using namespace metal;

constant int kSmokeRingMaxColorCount = 10;
constant int kSmokeRingMaxNoiseIterations = 8;

struct SmokeRingUniforms {
    float u_time;
    float4 u_colorBack;
    float4 u_colors[kSmokeRingMaxColorCount];
    float u_colorsCount;
    float u_thickness;
    float u_radius;
    float u_innerShape;
    float u_noiseScale;
    float u_noiseIterations;
};

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

inline float2 fbm(float2 n0, float2 n1, float iterations, texture2d<float> noiseTexture) {
    float2 total = float2(0.0);
    float amplitude = 0.4;
    for (int i = 0; i < kSmokeRingMaxNoiseIterations; i++) {
        if (i >= int(iterations)) { break; }
        total.x += valueNoise(n0, noiseTexture) * amplitude;
        total.y += valueNoise(n1, noiseTexture) * amplitude;
        n0 *= 1.99;
        n1 *= 1.99;
        amplitude *= 0.65;
    }
    return total;
}

inline float getNoise(float2 uv, float2 pUv, float t, constant SmokeRingUniforms &uniforms, texture2d<float> noiseTexture) {
    float2 pUvLeft = pUv + 0.03 * t;
    float period = max(abs(uniforms.u_noiseScale * TWO_PI), 1e-6);
    float2 pUvRight = float2(fract(pUv.x / period) * period, pUv.y) + 0.03 * t;
    float2 noise = fbm(pUvLeft, pUvRight, uniforms.u_noiseIterations, noiseTexture);
    return mix(noise.y, noise.x, smoothstep(-0.25, 0.25, uv.x));
}

inline float getRingShape(float2 uv, constant SmokeRingUniforms &uniforms) {
    float radius = uniforms.u_radius;
    float thickness = uniforms.u_thickness;
    float distance = length(uv);
    float ringValue = 1.0 - smoothstep(radius, radius + thickness, distance);
    ringValue *= smoothstep(radius - pow(uniforms.u_innerShape, 3.0) * thickness, radius, distance);
    return ringValue;
}

fragment float4 smoke_ring_fragment(VertexOutput in [[stage_in]],
                                   constant SmokeRingUniforms &uniforms [[buffer(0)]],
                                   texture2d<float> noiseTexture [[texture(1)]]) {
    float2 shape_uv = in.objectUV;
    float t = uniforms.u_time;
    float cycleDuration = 3.0;
    float period2 = 2.0 * cycleDuration;
    float localTime1 = fract((0.1 * t + cycleDuration) / period2) * period2;
    float localTime2 = fract((0.1 * t) / period2) * period2;
    float timeBlend = 0.5 + 0.5 * sin(0.1 * t * PI / cycleDuration - 0.5 * PI);

    float atg = atan2(shape_uv.y, shape_uv.x) + 0.001;
    float l = length(shape_uv);
    float radialOffset = 0.5 * l - rsqrt(max(1e-4, l));
    float2 polar_uv1 = float2(atg, localTime1 - radialOffset) * uniforms.u_noiseScale;
    float2 polar_uv2 = float2(atg, localTime2 - radialOffset) * uniforms.u_noiseScale;

    float noise1 = getNoise(shape_uv, polar_uv1, t, uniforms, noiseTexture);
    float noise2 = getNoise(shape_uv, polar_uv2, t, uniforms, noiseTexture);
    float noise = mix(noise1, noise2, timeBlend);

    shape_uv *= (0.8 + 1.2 * noise);
    float ringShape = getRingShape(shape_uv, uniforms);

    float mixer = ringShape * ringShape * (uniforms.u_colorsCount - 1.0);
    int idxLast = int(uniforms.u_colorsCount) - 1;
    float4 gradient = uniforms.u_colors[idxLast];
    gradient.rgb *= gradient.a;
    for (int i = kSmokeRingMaxColorCount - 2; i >= 0; i--) {
        float localT = clamp(mixer - float(idxLast - i - 1), 0.0, 1.0);
        float4 c = uniforms.u_colors[i];
        c.rgb *= c.a;
        gradient = mix(gradient, c, localT);
    }

    float3 color = gradient.rgb * ringShape;
    float opacity = gradient.a * ringShape;
    float3 bgColor = uniforms.u_colorBack.rgb * uniforms.u_colorBack.a;
    color = color + bgColor * (1.0 - opacity);
    opacity = opacity + uniforms.u_colorBack.a * (1.0 - opacity);
    color = applyColorBandingFix(color, in.position.xy);
    return float4(color, opacity);
}
