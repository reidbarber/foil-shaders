#include <metal_stdlib>
#include "Common.h"
#include "ShaderTypes.h"

using namespace metal;

struct WavesUniforms {
    float4 u_colorFront;
    float4 u_colorBack;
    float u_shape;
    float u_frequency;
    float u_amplitude;
    float u_spacing;
    float u_proportion;
    float u_softness;
};

fragment float4 waves_fragment(VertexOutput in [[stage_in]],
                              constant WavesUniforms &uniforms [[buffer(0)]]) {
    float2 shape_uv = in.patternUV * 4.0;
    float wave = 0.5 * cos(shape_uv.x * uniforms.u_frequency * TWO_PI);
    float zigzag = 2.0 * abs(fract(shape_uv.x * uniforms.u_frequency) - 0.5);
    float irregular = sin(shape_uv.x * 0.25 * uniforms.u_frequency * TWO_PI) * cos(shape_uv.x * uniforms.u_frequency * TWO_PI);
    float irregular2 = 0.75 * (sin(shape_uv.x * uniforms.u_frequency * TWO_PI) +
                               0.5 * cos(shape_uv.x * 0.5 * uniforms.u_frequency * TWO_PI));

    float offset = mix(zigzag, wave, smoothstep(0.0, 1.0, uniforms.u_shape));
    offset = mix(offset, irregular, smoothstep(1.0, 2.0, uniforms.u_shape));
    offset = mix(offset, irregular2, smoothstep(2.0, 3.0, uniforms.u_shape));
    offset *= 2.0 * uniforms.u_amplitude;

    float spacing = (0.001 + uniforms.u_spacing);
    float shape = 0.5 + 0.5 * sin((shape_uv.y + offset) * PI / spacing);

    float aa = 0.0001 + fwidth(shape);
    float dc = 1.0 - clamp(uniforms.u_proportion, 0.0, 1.0);
    float e0 = dc - uniforms.u_softness - aa;
    float e1 = dc + uniforms.u_softness + aa;
    float res = smoothstep(min(e0, e1), max(e0, e1), shape);

    float3 fgColor = uniforms.u_colorFront.rgb * uniforms.u_colorFront.a;
    float fgOpacity = uniforms.u_colorFront.a;
    float3 bgColor = uniforms.u_colorBack.rgb * uniforms.u_colorBack.a;
    float bgOpacity = uniforms.u_colorBack.a;

    float3 color = fgColor * res;
    float opacity = fgOpacity * res;
    color += bgColor * (1.0 - opacity);
    opacity += bgOpacity * (1.0 - opacity);

    return float4(color, opacity);
}
