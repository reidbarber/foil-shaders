#include <metal_stdlib>
#include "Common.h"
#include "ShaderTypes.h"

using namespace metal;

struct NeuroNoiseUniforms {
    float u_time;
    float4 u_colorFront;
    float4 u_colorMid;
    float4 u_colorBack;
    float u_brightness;
    float u_contrast;
};

static inline float neuroShape(float2 uv, float t) {
    float2 sine_acc = float2(0.0);
    float2 res = float2(0.0);
    float scale = 8.0;
    for (int j = 0; j < 15; j++) {
        uv = rotate(uv, 1.0);
        sine_acc = rotate(sine_acc, 1.0);
        float2 layer = uv * scale + float(j) + sine_acc - t;
        sine_acc += sin(layer);
        res += (0.5 + 0.5 * cos(layer)) / scale;
        scale *= 1.2;
    }
    return res.x + res.y;
}

fragment float4 neuro_noise_fragment(VertexOutput in [[stage_in]],
                                    constant NeuroNoiseUniforms &uniforms [[buffer(0)]]) {
    float2 shape_uv = in.patternUV * 0.13;
    float t = 0.5 * uniforms.u_time;
    float noise = neuroShape(shape_uv, t);
    noise = (1.0 + uniforms.u_brightness) * noise * noise;
    noise = pow(noise, 0.7 + 6.0 * uniforms.u_contrast);
    noise = min(1.4, noise);
    float blend = smoothstep(0.7, 1.4, noise);

    float4 frontC = uniforms.u_colorFront;
    frontC.rgb *= frontC.a;
    float4 midC = uniforms.u_colorMid;
    midC.rgb *= midC.a;
    float4 blendFront = mix(midC, frontC, blend);

    float safeNoise = max(noise, 0.0);
    float3 color = blendFront.rgb * safeNoise;
    float opacity = clamp(blendFront.a * safeNoise, 0.0, 1.0);
    float3 bgColor = uniforms.u_colorBack.rgb * uniforms.u_colorBack.a;
    color = color + bgColor * (1.0 - opacity);
    opacity = opacity + uniforms.u_colorBack.a * (1.0 - opacity);

    color = applyColorBandingFix(color, in.position.xy);
    return float4(color, opacity);
}
