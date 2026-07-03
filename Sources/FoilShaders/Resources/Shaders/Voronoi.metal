#include <metal_stdlib>
#include "Common.metal"

using namespace metal;

constant int kVoronoiMaxColorCount = 5;

struct VoronoiUniforms {
    float u_time;
    float u_scale;
    float4 u_colors[kVoronoiMaxColorCount];
    float u_colorsCount;
    float u_stepsPerColor;
    float4 u_colorGlow;
    float4 u_colorGap;
    float u_distortion;
    float u_gap;
    float u_glow;
};

inline float2 randomGB(texture2d<float> noiseTexture, float2 p) {
    float2 uv = floor(p) / 100.0 + 0.5;
    float4 sample = noiseTexture.sample(linearSampler, fract(uv));
    return sample.gb;
}

inline float4 voronoi(float2 x, float t, constant VoronoiUniforms &uniforms, texture2d<float> noiseTexture) {
    float2 ip = floor(x);
    float2 fp = fract(x);
    float2 mg = float2(0.0);
    float2 mr = float2(0.0);
    float md = 8.0;
    float rand = 0.0;
    for (int j = -1; j <= 1; j++) {
        for (int i = -1; i <= 1; i++) {
            float2 g = float2(float(i), float(j));
            float2 o = randomGB(noiseTexture, ip + g);
            float raw_hash = o.x;
            o = 0.5 + uniforms.u_distortion * sin(t + TWO_PI * o);
            float2 r = g + o - fp;
            float d = dot(r, r);
            if (d < md) {
                md = d;
                mr = r;
                mg = g;
                rand = raw_hash;
            }
        }
    }
    md = 8.0;
    for (int j = -2; j <= 2; j++) {
        for (int i = -2; i <= 2; i++) {
            float2 g = mg + float2(float(i), float(j));
            float2 o = randomGB(noiseTexture, ip + g);
            o = 0.5 + uniforms.u_distortion * sin(t + TWO_PI * o);
            float2 r = g + o - fp;
            if (dot(mr - r, mr - r) > 0.00001) {
                md = min(md, dot(0.5 * (mr + r), normalize(r - mr)));
            }
        }
    }
    return float4(md, mr, rand);
}

fragment float4 voronoi_fragment(VertexOutput in [[stage_in]],
                                constant VoronoiUniforms &uniforms [[buffer(0)]],
                                texture2d<float> noiseTexture [[texture(1)]]) {
    float2 shape_uv = in.patternUV * 1.25;
    float t = uniforms.u_time;
    float4 voronoiRes = voronoi(shape_uv, t, uniforms, noiseTexture);

    float shape = clamp(voronoiRes.w, 0.0, 1.0);
    float mixer = shape * (uniforms.u_colorsCount - 1.0);
    mixer = (shape - 0.5 / uniforms.u_colorsCount) * uniforms.u_colorsCount;
    float steps = max(1.0, uniforms.u_stepsPerColor);

    float4 gradient = uniforms.u_colors[0];
    gradient.rgb *= gradient.a;
    for (int i = 1; i < kVoronoiMaxColorCount; i++) {
        if (i >= int(uniforms.u_colorsCount)) { break; }
        float localT = clamp(mixer - float(i - 1), 0.0, 1.0);
        localT = round(localT * steps) / steps;
        float4 c = uniforms.u_colors[i];
        c.rgb *= c.a;
        gradient = mix(gradient, c, localT);
    }

    if ((mixer < 0.0) || (mixer > (uniforms.u_colorsCount - 1.0))) {
        float localT = mixer + 1.0;
        if (mixer > (uniforms.u_colorsCount - 1.0)) {
            localT = mixer - (uniforms.u_colorsCount - 1.0);
        }
        localT = round(localT * steps) / steps;
        float4 cFst = uniforms.u_colors[0];
        cFst.rgb *= cFst.a;
        float4 cLast = uniforms.u_colors[int(uniforms.u_colorsCount - 1.0)];
        cLast.rgb *= cLast.a;
        gradient = mix(cLast, cFst, localT);
    }

    float3 cellColor = gradient.rgb;
    float cellOpacity = gradient.a;
    float glows = length(voronoiRes.yz * uniforms.u_glow);
    glows = pow(glows, 1.5);
    float3 color = mix(cellColor, uniforms.u_colorGlow.rgb * uniforms.u_colorGlow.a, uniforms.u_colorGlow.a * glows);
    float opacity = cellOpacity + uniforms.u_colorGlow.a * glows;

    float edge = voronoiRes.x;
    float smoothEdge = 0.02 / (2.0 * uniforms.u_scale) * (1.0 + 0.5 * uniforms.u_gap);
    edge = smoothstep(uniforms.u_gap - smoothEdge, uniforms.u_gap + smoothEdge, edge);
    color = mix(uniforms.u_colorGap.rgb * uniforms.u_colorGap.a, color, edge);
    opacity = mix(uniforms.u_colorGap.a, opacity, edge);
    return float4(color, opacity);
}
