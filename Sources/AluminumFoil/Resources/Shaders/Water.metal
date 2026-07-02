#include <metal_stdlib>
#include "Common.metal"

using namespace metal;

struct WaterUniforms {
    float u_time;
    float4 u_colorBack;
    float4 u_colorHighlight;
    float u_highlights;
    float u_layering;
    float u_edges;
    float u_caustic;
    float u_waves;
    float u_size;
};

struct FragmentVertexUniforms {
    float2 u_resolution;
    float u_pixelRatio;
    float u_imageAspectRatio;
    float u_originX;
    float u_originY;
    float u_worldWidth;
    float u_worldHeight;
    float u_fit;
    float u_scale;
    float u_rotation;
    float u_offsetX;
    float u_offsetY;
};

inline float getUvFrame(float2 uv) {
    float aax = 2.0 * fwidth(uv.x);
    float aay = 2.0 * fwidth(uv.y);
    float left = smoothstep(0.0, aax, uv.x);
    float right = 1.0 - smoothstep(1.0 - aax, 1.0, uv.x);
    float bottom = smoothstep(0.0, aay, uv.y);
    float top = 1.0 - smoothstep(1.0 - aay, 1.0, uv.y);
    return left * right * bottom * top;
}

inline float2x2 rotate2D(float r) {
    return float2x2(cos(r), sin(r), -sin(r), cos(r));
}

inline float getCausticNoise(float2 uv, float t, float scale) {
    float2 n = float2(0.1);
    float2 N = float2(0.1);
    float2x2 m = rotate2D(0.5);
    for (int j = 0; j < 6; j++) {
        uv = m * uv;
        n = m * n;
        float2 q = uv * scale + float(j) + n + (0.5 + 0.5 * float(j)) * (fmod(float(j), 2.0) - 1.0) * t;
        n += sin(q);
        N += cos(q) / scale;
        scale *= 1.1;
    }
    return (N.x + N.y + 1.0);
}

fragment float4 water_fragment(VertexOutput in [[stage_in]],
                              constant WaterUniforms &uniforms [[buffer(0)]],
                              constant FragmentVertexUniforms &vertexUniforms [[buffer(1)]],
                              texture2d<float> imageTexture [[texture(0)]]) {
    float2 imageUV = in.imageUV;
    float2 patternUV = in.imageUV - 0.5;
    patternUV = (patternUV * float2(vertexUniforms.u_imageAspectRatio, 1.0));
    patternUV /= (0.01 + 0.09 * uniforms.u_size);

    float t = uniforms.u_time;
    float wavesNoise = snoise((0.3 + 0.1 * sin(t)) * 0.1 * patternUV + float2(0.0, 0.4 * t));
    float causticNoise = getCausticNoise(patternUV + uniforms.u_waves * float2(1.0, -1.0) * wavesNoise, 2.0 * t, 1.5);
    causticNoise += uniforms.u_layering * getCausticNoise(patternUV + 2.0 * uniforms.u_waves * float2(1.0, -1.0) * wavesNoise, 1.5 * t, 2.0);
    causticNoise = causticNoise * causticNoise;

    float edgesDistortion = smoothstep(0.0, 0.1, imageUV.x);
    edgesDistortion *= smoothstep(0.0, 0.1, imageUV.y);
    edgesDistortion *= (smoothstep(1.0, 1.1, imageUV.x) + (1.0 - smoothstep(0.8, 0.95, imageUV.x)));
    edgesDistortion *= (1.0 - smoothstep(0.9, 1.0, imageUV.y));
    edgesDistortion = mix(edgesDistortion, 1.0, uniforms.u_edges);

    float causticNoiseDistortion = 0.02 * causticNoise * edgesDistortion;
    float wavesDistortion = 0.1 * uniforms.u_waves * wavesNoise;
    imageUV += float2(wavesDistortion, -wavesDistortion);
    imageUV += uniforms.u_caustic * causticNoiseDistortion;

    float frame = getUvFrame(imageUV);
    float4 image = imageTexture.sample(linearSampler, imageUV);
    float4 backColor = uniforms.u_colorBack;
    backColor.rgb *= backColor.a;

    float3 color = mix(backColor.rgb, image.rgb, image.a * frame);
    float opacity = backColor.a + image.a * frame;

    causticNoise = max(-0.2, causticNoise);
    float highlight = 0.025 * uniforms.u_highlights * causticNoise;
    highlight *= uniforms.u_colorHighlight.a;
    color = mix(color, uniforms.u_colorHighlight.rgb, 0.05 * uniforms.u_highlights * causticNoise);
    opacity += highlight;
    color += highlight * (0.5 + 0.5 * wavesNoise);
    opacity += highlight * (0.5 + 0.5 * wavesNoise);
    opacity = clamp(opacity, 0.0, 1.0);
    return float4(color, opacity);
}
