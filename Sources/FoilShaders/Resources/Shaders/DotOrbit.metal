#include <metal_stdlib>
#include "Common.metal"

using namespace metal;

constant int kDotOrbitMaxColorCount = 10;

struct DotOrbitUniforms {
    float u_time;
    float4 u_colorBack;
    float4 u_colors[kDotOrbitMaxColorCount];
    float u_colorsCount;
    float u_stepsPerColor;
    float u_size;
    float u_sizeRange;
    float u_spreading;
};

inline float randomR(texture2d<float> noiseTexture, float2 p) {
    float2 uv = floor(p) / 100.0 + 0.5;
    return noiseTexture.sample(linearSampler, fract(uv)).r;
}

inline float2 randomGB(texture2d<float> noiseTexture, float2 p) {
    float2 uv = floor(p) / 100.0 + 0.5;
    float4 sample = noiseTexture.sample(linearSampler, fract(uv));
    return sample.gb;
}

inline float3 voronoiShape(float2 uv, float time,
                           constant DotOrbitUniforms &uniforms,
                           texture2d<float> noiseTexture) {
    float2 i_uv = floor(uv);
    float2 f_uv = fract(uv);
    float spreading = 0.25 * clamp(uniforms.u_spreading, 0.0, 1.0);
    float minDist = 1.0;
    float2 randomizer = float2(0.0);
    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            float2 tileOffset = float2(float(x), float(y));
            float2 rand = randomGB(noiseTexture, i_uv + tileOffset);
            float2 cellCenter = float2(0.5 + 1e-4);
            cellCenter += spreading * cos(time + TWO_PI * rand);
            cellCenter -= 0.5;
            cellCenter = rotate(cellCenter, randomR(noiseTexture, float2(rand.x, rand.y)) + 0.1 * time);
            cellCenter += 0.5;
            float dist = length(tileOffset + cellCenter - f_uv);
            if (dist < minDist) {
                minDist = dist;
                randomizer = rand;
            }
        }
    }
    return float3(minDist, randomizer);
}

fragment float4 dot_orbit_fragment(VertexOutput in [[stage_in]],
                                  constant DotOrbitUniforms &uniforms [[buffer(0)]],
                                  texture2d<float> noiseTexture [[texture(1)]]) {
    float2 shape_uv = in.patternUV * 1.5;
    float t = uniforms.u_time - 10.0;
    float3 voronoi = voronoiShape(shape_uv, t, uniforms, noiseTexture) + 1e-4;
    float radius = 0.25 * clamp(uniforms.u_size, 0.0, 1.0) - 0.5 * clamp(uniforms.u_sizeRange, 0.0, 1.0) * voronoi.z;
    float dist = voronoi.x;
    float edgeWidth = fwidth(dist);
    float dots = 1.0 - smoothstep(radius - edgeWidth, radius + edgeWidth, dist);

    float shape = voronoi.y;
    float mixer = shape * (uniforms.u_colorsCount - 1.0);
    mixer = (shape - 0.5 / uniforms.u_colorsCount) * uniforms.u_colorsCount;
    float steps = max(1.0, uniforms.u_stepsPerColor);

    float4 gradient = uniforms.u_colors[0];
    gradient.rgb *= gradient.a;
    for (int i = 1; i < kDotOrbitMaxColorCount; i++) {
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

    float3 color = gradient.rgb * dots;
    float opacity = gradient.a * dots;
    float3 bgColor = uniforms.u_colorBack.rgb * uniforms.u_colorBack.a;
    color = color + bgColor * (1.0 - opacity);
    opacity = opacity + uniforms.u_colorBack.a * (1.0 - opacity);
    return float4(color, opacity);
}
