#include <metal_stdlib>
#include "Common.metal"

using namespace metal;

struct GemSmokeUniforms {
    float u_time;
    float4 u_colors0;
    float4 u_colors1;
    float4 u_colors2;
    float4 u_colors3;
    float4 u_colors4;
    float4 u_colors5;
    float u_colorsCount;
    float4 u_colorBack;
    float4 u_colorInner;
    float u_innerDistortion;
    float u_outerDistortion;
    float u_outerGlow;
    float u_innerGlow;
    float u_offset;
    float u_angle;
    float u_size;
    float u_shape;
    float u_isImage;
};

inline float4 gemColorAt(constant GemSmokeUniforms &u, int index) {
    if (index == 0) { return u.u_colors0; }
    if (index == 1) { return u.u_colors1; }
    if (index == 2) { return u.u_colors2; }
    if (index == 3) { return u.u_colors3; }
    if (index == 4) { return u.u_colors4; }
    return u.u_colors5;
}

inline float4 gemPalette(float value, constant GemSmokeUniforms &u) {
    int count = max(1, int(u.u_colorsCount));
    if (count == 1) {
        return gemColorAt(u, 0);
    }
    float scaled = clamp(value, 0.0, 0.9999) * float(count - 1);
    int index = int(floor(scaled));
    float t = fract(scaled);
    return mix(gemColorAt(u, index), gemColorAt(u, min(index + 1, count - 1)), smoothstep(0.0, 1.0, t));
}

inline float gemShapeEdge(VertexOutput in, float shape, float time) {
    float2 uv = in.objectUV + 0.5;
    uv.y = 1.0 - uv.y;

    if (shape < 1.0) {
        float2 borderUV = in.responsiveUV + 0.5;
        float2 mask = min(borderUV, 1.0 - borderUV);
        float2 pixelThickness = min(250.0 / in.responsiveBoxGivenSize, float2(0.5));
        float maskX = pow(smoothstep(0.0, pixelThickness.x, mask.x), 0.25);
        float maskY = pow(smoothstep(0.0, pixelThickness.y, mask.y), 0.25);
        return clamp(1.0 - maskX * maskY, 0.0, 1.0);
    }

    float2 shapeUV = uv - 0.5;
    if (shape < 2.0) {
        shapeUV *= 0.67;
        return pow(clamp(3.0 * length(shapeUV), 0.0, 1.0), 18.0);
    }

    if (shape < 3.0) {
        shapeUV *= 1.68;
        float r = length(shapeUV) * 2.0;
        float a = atan2(shapeUV.y, shapeUV.x) + 0.2;
        r *= 1.0 + 0.05 * sin(3.0 * a + 2.0 * time);
        float f = abs(cos(a * 3.0));
        float edge = smoothstep(f, f + 0.7, r);
        return edge * edge;
    }

    if (shape < 4.0) {
        shapeUV = rotate(shapeUV, 0.25 * PI);
        shapeUV *= 1.42;
        shapeUV += 0.5;
        float2 mask = min(shapeUV, 1.0 - shapeUV);
        float maskX = pow(smoothstep(0.0, 0.15, mask.x), 0.25);
        float maskY = pow(smoothstep(0.0, 0.15, mask.y), 0.25);
        return clamp(1.0 - maskX * maskY, 0.0, 1.0);
    }

    shapeUV *= 1.3;
    float field = 0.0;
    for (int i = 0; i < 5; i++) {
        float fi = float(i);
        float speed = 1.5 + 0.6667 * sin(fi * 12.345);
        float angle = -fi * 1.5;
        float2 dir1 = float2(cos(angle), sin(angle));
        float2 dir2 = float2(cos(angle + 1.57), sin(angle + 1.0));
        float2 traj = 0.4 * (dir1 * sin(time * speed + fi * 1.23) + dir2 * cos(time * speed * 0.7 + fi * 2.17));
        float d = length(shapeUV + traj);
        field += pow(1.0 - clamp(d, 0.0, 1.0), 4.0);
    }
    float edge = 1.0 - smoothstep(0.65, 0.9, field);
    return pow(edge, 4.0);
}

fragment float4 gem_smoke_fragment(VertexOutput in [[stage_in]],
                                   constant GemSmokeUniforms &uniforms [[buffer(0)]],
                                   texture2d<float> imageTexture [[texture(0)]]) {
    float time = uniforms.u_time;
    float edge = 0.0;
    float alpha = 1.0;

    if (uniforms.u_isImage > 0.5) {
        float2 imageUV = (in.imageUV - 0.5) * 0.95 + 0.5;
        float4 sample = imageTexture.sample(linearSampler, imageUV, gradient2d(dfdx(in.imageUV), dfdy(in.imageUV)));
        edge = 1.0 - sample.r;
        alpha = sample.g;
    } else {
        edge = gemShapeEdge(in, uniforms.u_shape, time);
        alpha = 1.0 - smoothstep(0.9 - 2.0 * fwidth(edge), 0.9, edge);
    }

    float roundness = 1.0 - edge;
    float2 smokeUV = rotate(in.objectUV, uniforms.u_angle * PI / 180.0);
    smokeUV *= mix(4.0, 1.0, uniforms.u_size);

    float innerNoise = 0.5 + 0.5 * snoise(smokeUV * 1.25 + float2(0.0, time * 0.32 + uniforms.u_offset));
    float outerNoise = 0.5 + 0.5 * snoise(smokeUV * 1.1 + float2(time * 0.22, -time * 0.18 - uniforms.u_offset));
    float innerField = smoothstep(0.15, 0.95, innerNoise + uniforms.u_innerDistortion * (1.0 - roundness));
    float outerField = smoothstep(0.1, 1.0, outerNoise + uniforms.u_outerDistortion * roundness);

    float4 innerSmoke = gemPalette(innerField, uniforms);
    float4 outerSmoke = gemPalette(outerField, uniforms);
    float4 smoke = mix(outerSmoke * uniforms.u_outerGlow, innerSmoke * uniforms.u_innerGlow, alpha);
    smoke.rgb = mix(smoke.rgb, uniforms.u_colorInner.rgb, alpha * uniforms.u_colorInner.a * (0.25 + 0.75 * innerField));

    float glow = smoothstep(0.2, 1.0, roundness) * uniforms.u_outerGlow * (1.0 - alpha);
    float4 color = mix(uniforms.u_colorBack, smoke, clamp(alpha + glow, 0.0, 1.0));
    color.a = max(uniforms.u_colorBack.a, smoke.a * clamp(alpha + glow, 0.0, 1.0));
    return color;
}
