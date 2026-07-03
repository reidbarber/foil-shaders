#include <metal_stdlib>
#include "Common.metal"

using namespace metal;

constant int kMetaballsMaxColorCount = 8;
constant int kMetaballsMaxBallsCount = 20;

struct MetaballsUniforms {
    float u_time;
    float4 u_colorBack;
    float4 u_colors[kMetaballsMaxColorCount];
    float u_colorsCount;
    float u_size;
    float u_sizeRange;
    float u_count;
};

inline float randomR(texture2d<float> noiseTexture, float2 p) {
    float2 uv = floor(p) / 100.0 + 0.5;
    return noiseTexture.sample(linearSampler, fract(uv)).r;
}

inline float noise1(float x, texture2d<float> noiseTexture) {
    float i = floor(x);
    float f = fract(x);
    float u = f * f * (3.0 - 2.0 * f);
    float2 p0 = float2(i, 0.0);
    float2 p1 = float2(i + 1.0, 0.0);
    return mix(randomR(noiseTexture, p0), randomR(noiseTexture, p1), u);
}

inline float getBallShape(float2 uv, float2 c, float p) {
    float s = 0.5 * length(uv - c);
    s = 1.0 - clamp(s, 0.0, 1.0);
    s = pow(s, p);
    return s;
}

fragment float4 metaballs_fragment(VertexOutput in [[stage_in]],
                                  constant MetaballsUniforms &uniforms [[buffer(0)]],
                                  texture2d<float> noiseTexture [[texture(1)]]) {
    float2 shape_uv = in.objectUV + 0.5;
    float t = 0.2 * (uniforms.u_time + 2503.4);
    float3 totalColor = float3(0.0);
    float totalShape = 0.0;
    float totalOpacity = 0.0;

    for (int i = 0; i < kMetaballsMaxBallsCount; i++) {
        if (i >= int(ceil(uniforms.u_count))) { break; }
        float idxFract = float(i) / float(kMetaballsMaxBallsCount);
        float angle = TWO_PI * idxFract;
        float speed = 1.0 - 0.2 * idxFract;
        float noiseX = noise1(angle * 10.0 + float(i) + t * speed, noiseTexture);
        float noiseY = noise1(angle * 20.0 + float(i) - t * speed, noiseTexture);
        float2 pos = float2(0.5) + 1e-4 + 0.9 * (float2(noiseX, noiseY) - 0.5);

        int safeIndex = i % int(uniforms.u_colorsCount + 0.5);
        float4 ballColor = uniforms.u_colors[safeIndex];
        ballColor.rgb *= ballColor.a;

        float sizeFrac = 1.0;
        if (float(i) > floor(uniforms.u_count - 1.0)) {
            sizeFrac *= fract(uniforms.u_count);
        }
        float shape = getBallShape(shape_uv, pos, 45.0 - 30.0 * uniforms.u_size * sizeFrac);
        shape *= pow(uniforms.u_size, 0.2);
        shape = smoothstep(0.0, 1.0, shape);

        totalColor += ballColor.rgb * shape;
        totalShape += shape;
        totalOpacity += ballColor.a * shape;
    }

    totalColor /= max(totalShape, 1e-4);
    totalOpacity /= max(totalShape, 1e-4);
    float edge_width = fwidth(totalShape);
    float finalShape = smoothstep(0.4, 0.4 + edge_width, totalShape);

    float3 color = totalColor * finalShape;
    float opacity = totalOpacity * finalShape;
    float3 bgColor = uniforms.u_colorBack.rgb * uniforms.u_colorBack.a;
    color = color + bgColor * (1.0 - opacity);
    opacity = opacity + uniforms.u_colorBack.a * (1.0 - opacity);
    color = applyColorBandingFix(color, in.position.xy);
    return float4(color, opacity);
}
