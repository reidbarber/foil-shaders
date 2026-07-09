#include <metal_stdlib>
#include "Common.h"
#include "ShaderTypes.h"

using namespace metal;

constant int kSimplexNoiseMaxColorCount = 10;

struct SimplexNoiseUniforms {
    float u_time;
    float4 u_colors[kSimplexNoiseMaxColorCount];
    float u_colorsCount;
    float u_stepsPerColor;
    float u_softness;
};

static inline float getNoise(float2 uv, float t) {
    float noise = 0.5 * snoise(uv - float2(0.0, 0.3 * t));
    noise += 0.5 * snoise(2.0 * uv + float2(0.0, 0.32 * t));
    return noise;
}

static inline float steppedSmooth(float m, float steps, float softness) {
    float stepT = floor(m * steps) / steps;
    float f = m * steps - floor(m * steps);
    float fw = steps * fwidth(m);
    float smoothed = smoothstep(0.5 - softness, min(1.0, 0.5 + softness + fw), f);
    return stepT + smoothed / steps;
}

fragment float4 simplex_noise_fragment(VertexOutput in [[stage_in]],
                                      constant SimplexNoiseUniforms &uniforms [[buffer(0)]]) {
    float2 shape_uv = in.patternUV * 0.1;
    float t = 0.2 * uniforms.u_time;
    float shape = 0.5 + 0.5 * getNoise(shape_uv, t);

    float mixer = shape * (uniforms.u_colorsCount - 1.0);
    mixer = (shape - 0.5 / uniforms.u_colorsCount) * uniforms.u_colorsCount;

    float steps = max(1.0, uniforms.u_stepsPerColor);

    float4 gradient = uniforms.u_colors[0];
    gradient.rgb *= gradient.a;
    for (int i = 1; i < kSimplexNoiseMaxColorCount; i++) {
        if (i >= int(uniforms.u_colorsCount)) { break; }
        float localM = clamp(mixer - float(i - 1), 0.0, 1.0);
        localM = steppedSmooth(localM, steps, 0.5 * uniforms.u_softness);
        float4 c = uniforms.u_colors[i];
        c.rgb *= c.a;
        gradient = mix(gradient, c, localM);
    }

    if ((mixer < 0.0) || (mixer > (uniforms.u_colorsCount - 1.0))) {
        float localM = mixer + 1.0;
        if (mixer > (uniforms.u_colorsCount - 1.0)) {
            localM = mixer - (uniforms.u_colorsCount - 1.0);
        }
        localM = steppedSmooth(localM, steps, 0.5 * uniforms.u_softness);
        float4 cFst = uniforms.u_colors[0];
        cFst.rgb *= cFst.a;
        float4 cLast = uniforms.u_colors[int(uniforms.u_colorsCount - 1.0)];
        cLast.rgb *= cLast.a;
        gradient = mix(cLast, cFst, localM);
    }

    float3 color = gradient.rgb;
    float opacity = gradient.a;
    color = applyColorBandingFix(color, in.position.xy);
    return float4(color, opacity);
}
