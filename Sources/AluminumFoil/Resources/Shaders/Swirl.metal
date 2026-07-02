#include <metal_stdlib>
#include "Common.metal"

using namespace metal;

constant int kSwirlMaxColorCount = 10;

struct SwirlUniforms {
    float u_time;
    float4 u_colorBack;
    float4 u_colors[kSwirlMaxColorCount];
    float u_colorsCount;
    float u_bandCount;
    float u_twist;
    float u_center;
    float u_proportion;
    float u_softness;
    float u_noise;
    float u_noiseFrequency;
};

fragment float4 swirl_fragment(VertexOutput in [[stage_in]],
                               constant SwirlUniforms &uniforms [[buffer(0)]]) {
    float2 shape_uv = in.objectUV;
    float l = max(1e-4, length(shape_uv));
    float t = uniforms.u_time;

    float angle = ceil(uniforms.u_bandCount) * atan2(shape_uv.y, shape_uv.x) + t;
    float angle_norm = angle / TWO_PI;

    float twist = 3.0 * clamp(uniforms.u_twist, 0.0, 1.0);
    float offset = pow(l, -twist) + angle_norm;

    float shape = fract(offset);
    shape = 1.0 - abs(2.0 * shape - 1.0);
    shape += uniforms.u_noise * snoise(15.0 * pow(uniforms.u_noiseFrequency, 2.0) * shape_uv);

    float mid = smoothstep(0.2, 0.2 + 0.8 * uniforms.u_center, pow(l, twist));
    shape = mix(0.0, shape, mid);

    float proportion = clamp(uniforms.u_proportion, 0.0, 1.0);
    float exponent = mix(0.25, 1.0, proportion * 2.0);
    exponent = mix(exponent, 10.0, max(0.0, proportion * 2.0 - 1.0));
    shape = pow(shape, exponent);

    float mixer = shape * uniforms.u_colorsCount;
    float4 gradient = uniforms.u_colors[0];
    gradient.rgb *= gradient.a;

    float outerShape = 0.0;
    for (int i = 1; i < kSwirlMaxColorCount + 1; i++) {
        if (i > int(uniforms.u_colorsCount)) break;
        float m = clamp(mixer - float(i - 1), 0.0, 1.0);
        float aa = fwidth(m);
        m = smoothstep(0.5 - 0.5 * uniforms.u_softness - aa, 0.5 + 0.5 * uniforms.u_softness + aa, m);
        if (i == 1) outerShape = m;
        float4 c = uniforms.u_colors[i - 1];
        c.rgb *= c.a;
        gradient = mix(gradient, c, m);
    }

    float midAA = 0.1 * fwidth(pow(l, -twist));
    float outerMid = smoothstep(0.2, 0.2 + midAA, pow(l, twist));
    outerShape = mix(0.0, outerShape, outerMid);

    float3 color = gradient.rgb * outerShape;
    float opacity = gradient.a * outerShape;

    float3 bgColor = uniforms.u_colorBack.rgb * uniforms.u_colorBack.a;
    color = color + bgColor * (1.0 - opacity);
    opacity = opacity + uniforms.u_colorBack.a * (1.0 - opacity);

    color = applyColorBandingFix(color, in.position.xy);

    return float4(color, opacity);
}
