#include <metal_stdlib>
#include "Common.metal"

using namespace metal;

struct SpiralUniforms {
    float u_time;
    float4 u_colorBack;
    float4 u_colorFront;
    float u_density;
    float u_distortion;
    float u_strokeWidth;
    float u_strokeCap;
    float u_strokeTaper;
    float u_noise;
    float u_noiseFrequency;
    float u_softness;
};

fragment float4 spiral_fragment(VertexOutput in [[stage_in]],
                                constant SpiralUniforms &uniforms [[buffer(0)]]) {
    float2 uv = 2.0 * in.patternUV;
    float t = uniforms.u_time;
    float l = length(uv);
    float density = clamp(uniforms.u_density, 0.0, 1.0);
    l = pow(max(l, 1e-6), density);
    float angle = atan2(uv.y, uv.x) - t;
    float angleNormalised = angle / TWO_PI;

    angleNormalised += 0.125 * uniforms.u_noise * snoise(16.0 * pow(uniforms.u_noiseFrequency, 3.0) * uv);

    float offset = l + angleNormalised;
    offset -= uniforms.u_distortion * (sin(4.0 * l - 0.5 * t) * cos(PI + l + 0.5 * t));
    float stripe = fract(offset);

    float shape = 2.0 * abs(stripe - 0.5);
    float width = 1.0 - clamp(uniforms.u_strokeWidth, 0.005 * uniforms.u_strokeTaper, 1.0);

    float wCap = mix(width, (1.0 - stripe) * (1.0 - step(0.5, stripe)), (1.0 - clamp(l, 0.0, 1.0)));
    width = mix(width, wCap, uniforms.u_strokeCap);
    width *= (1.0 - clamp(uniforms.u_strokeTaper, 0.0, 1.0) * l);

    float fw = fwidth(offset);
    float fwMult = 4.0 - 3.0 * (smoothstep(0.05, 0.4, 2.0 * uniforms.u_strokeWidth)
                                * smoothstep(0.05, 0.4, 2.0 * (1.0 - uniforms.u_strokeWidth)));
    float pixelSize = mix(fwMult * fw, fwidth(shape), clamp(fw, 0.0, 1.0));
    pixelSize = mix(pixelSize, 0.002, uniforms.u_strokeCap * (1.0 - clamp(l, 0.0, 1.0)));

    float res = smoothstep(width - pixelSize - uniforms.u_softness, width + pixelSize + uniforms.u_softness, shape);

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
