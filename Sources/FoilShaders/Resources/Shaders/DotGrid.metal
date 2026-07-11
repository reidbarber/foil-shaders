#include <metal_stdlib>
#include "Common.h"
#include "ShaderTypes.h"

using namespace metal;

struct DotGridUniforms {
    float4 u_colorBack;
    float4 u_colorFill;
    float4 u_colorStroke;
    float u_dotSize;
    float u_gapX;
    float u_gapY;
    float u_strokeWidth;
    float u_sizeRange;
    float u_opacityRange;
    float u_shape;
};

static inline float polygon(float2 p, float N, float rot) {
    float a = atan2(p.x, p.y) + rot;
    float r = TWO_PI / N;
    return cos(floor(0.5 + a / r) * r - a) * length(p);
}

fragment float4 dot_grid_fragment(VertexOutput in [[stage_in]],
                                  constant DotGridUniforms &uniforms [[buffer(0)]]) {
    float2 shape_uv = 100.0 * in.patternUV;

    float2 gap = max(abs(float2(uniforms.u_gapX, uniforms.u_gapY)), float2(1e-6));
    float2 grid = fract(shape_uv / gap) + 1e-4;
    float2 grid_idx = floor(shape_uv / gap);
    float sizeRandomizer = 0.5 + 0.8 * snoise(2.0 * float2(grid_idx.x * 100.0, grid_idx.y));
    float opacityRandomizer = 0.5 + 0.7 * snoise(2.0 * float2(grid_idx.y, grid_idx.x));

    float2 center = float2(0.5) - 1e-3;
    float2 p = (grid - center) * float2(uniforms.u_gapX, uniforms.u_gapY);

    float baseSize = uniforms.u_dotSize * (1.0 - sizeRandomizer * uniforms.u_sizeRange);
    float strokeWidth = uniforms.u_strokeWidth * (1.0 - sizeRandomizer * uniforms.u_sizeRange);

    float dist = 0.0;
    if (uniforms.u_shape < 0.5) {
        dist = length(p);
    } else if (uniforms.u_shape < 1.5) {
        strokeWidth *= 1.5;
        dist = polygon(1.5 * p, 4.0, 0.25 * PI);
    } else if (uniforms.u_shape < 2.5) {
        dist = polygon(1.03 * p, 4.0, 1e-3);
    } else {
        strokeWidth *= 1.5;
        float2 pp = p * 2.0 - 1.0;
        pp *= 0.9;
        pp.y = 1.0 - pp.y;
        pp.y -= 0.75 * baseSize;
        dist = polygon(pp, 3.0, 1e-3);
    }

    float edgeWidth = fwidth(dist);
    float shapeOuter = 1.0 - smoothstep(baseSize - edgeWidth, baseSize + edgeWidth, dist - strokeWidth);
    float shapeInner = 1.0 - smoothstep(baseSize - edgeWidth, baseSize + edgeWidth, dist);
    float stroke = shapeOuter - shapeInner;

    float dotOpacity = max(0.0, 1.0 - opacityRandomizer * uniforms.u_opacityRange);
    stroke *= dotOpacity;
    shapeInner *= dotOpacity;

    stroke *= uniforms.u_colorStroke.a;
    shapeInner *= uniforms.u_colorFill.a;

    float3 color = float3(0.0);
    color += stroke * uniforms.u_colorStroke.rgb;
    color += shapeInner * uniforms.u_colorFill.rgb;
    color += (1.0 - shapeInner - stroke) * uniforms.u_colorBack.rgb * uniforms.u_colorBack.a;

    float opacity = 0.0;
    opacity += stroke;
    opacity += shapeInner;
    opacity += (1.0 - opacity) * uniforms.u_colorBack.a;

    return float4(color, opacity);
}