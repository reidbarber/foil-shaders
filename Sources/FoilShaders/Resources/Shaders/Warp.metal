#include <metal_stdlib>
#include "Common.metal"

using namespace metal;

constant int kWarpMaxColorCount = 10;

struct WarpUniforms {
    float u_time;
    float u_scale;
    float4 u_colors[kWarpMaxColorCount];
    float u_colorsCount;
    float u_proportion;
    float u_softness;
    float u_shape;
    float u_shapeScale;
    float u_distortion;
    float u_swirl;
    float u_swirlIterations;
};

inline float randomG(texture2d<float> noiseTexture, float2 p) {
    float2 uv = floor(p) / 100.0 + 0.5;
    return noiseTexture.sample(linearSampler, fract(uv)).g;
}

inline float valueNoise(float2 st, texture2d<float> noiseTexture) {
    float2 i = floor(st);
    float2 f = fract(st);
    float a = randomG(noiseTexture, i);
    float b = randomG(noiseTexture, i + float2(1.0, 0.0));
    float c = randomG(noiseTexture, i + float2(0.0, 1.0));
    float d = randomG(noiseTexture, i + float2(1.0, 1.0));
    float2 u = f * f * (3.0 - 2.0 * f);
    float x1 = mix(a, b, u.x);
    float x2 = mix(c, d, u.x);
    return mix(x1, x2, u.y);
}

fragment float4 warp_fragment(VertexOutput in [[stage_in]],
                             constant WarpUniforms &uniforms [[buffer(0)]],
                             texture2d<float> noiseTexture [[texture(1)]]) {
    float2 uv = in.patternUV * 0.5;
    float t = 0.0625 * (uniforms.u_time + 118.0);
    float n1 = valueNoise(uv * 1.0 + t, noiseTexture);
    float n2 = valueNoise(uv * 2.0 - t, noiseTexture);
    float angle = n1 * TWO_PI;
    uv.x += 4.0 * uniforms.u_distortion * n2 * cos(angle);
    uv.y += 4.0 * uniforms.u_distortion * n2 * sin(angle);

    float swirl = uniforms.u_swirl;
    for (int i = 1; i <= 20; i++) {
        if (i >= int(uniforms.u_swirlIterations)) { break; }
        float iFloat = float(i);
        uv.x += swirl / iFloat * cos(t + iFloat * 1.5 * uv.y);
        uv.y += swirl / iFloat * cos(t + iFloat * 1.0 * uv.x);
    }

    float proportion = clamp(uniforms.u_proportion, 0.0, 1.0);
    float shape = 0.0;
    if (uniforms.u_shape < 0.5) {
        float2 checksShape_uv = uv * (0.5 + 3.5 * uniforms.u_shapeScale);
        shape = 0.5 + 0.5 * sin(checksShape_uv.x) * cos(checksShape_uv.y);
        shape += 0.48 * sign(proportion - 0.5) * pow(abs(proportion - 0.5), 0.5);
    } else if (uniforms.u_shape < 1.5) {
        float2 stripesShape_uv = uv * (2.0 * uniforms.u_shapeScale);
        float f = fract(stripesShape_uv.y);
        shape = smoothstep(0.0, 0.55, f) * (1.0 - smoothstep(0.45, 1.0, f));
        shape += 0.48 * sign(proportion - 0.5) * pow(abs(proportion - 0.5), 0.5);
    } else {
        float shapeScaling = 5.0 * (1.0 - uniforms.u_shapeScale);
        float e0 = 0.45 - shapeScaling;
        float e1 = 0.55 + shapeScaling;
        shape = smoothstep(min(e0, e1), max(e0, e1), 1.0 - uv.y + 0.3 * (proportion - 0.5));
    }

    float mixer = shape * (uniforms.u_colorsCount - 1.0);
    float4 gradient = uniforms.u_colors[0];
    gradient.rgb *= gradient.a;
    float aa = fwidth(shape);
    for (int i = 1; i < kWarpMaxColorCount; i++) {
        if (i >= int(uniforms.u_colorsCount)) { break; }
        float m = clamp(mixer - float(i - 1), 0.0, 1.0);
        float localMixerStart = floor(m);
        float softness = 0.5 * uniforms.u_softness + fwidth(m);
        float smoothed = smoothstep(max(0.0, 0.5 - softness - aa), min(1.0, 0.5 + softness + aa), m - localMixerStart);
        float stepped = localMixerStart + smoothed;
        m = mix(stepped, m, uniforms.u_softness);
        float4 c = uniforms.u_colors[i];
        c.rgb *= c.a;
        gradient = mix(gradient, c, m);
    }

    float3 color = gradient.rgb;
    float opacity = gradient.a;
    color = applyColorBandingFix(color, in.position.xy);
    return float4(color, opacity);
}
