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

inline float2 gaussBlur9x9RG(texture2d<float> tex, float2 uv, float2 dudx, float2 dudy, float radius) {
    float2 texel = 1.0 / float2(tex.get_width(), tex.get_height());
    float2 r = max(radius, 0.0) * texel;
    const float k[9] = {1.0, 8.0, 28.0, 56.0, 70.0, 56.0, 28.0, 8.0, 1.0};
    float2 sum = float2(0.0);
    for (int j = -4; j <= 4; ++j) {
        float wy = k[j + 4];
        for (int i = -4; i <= 4; ++i) {
            float w = k[i + 4] * wy;
            float2 off = float2(float(i) * r.x, float(j) * r.y);
            sum += w * tex.sample(linearMipSampler, uv + off, gradient2d(dudx, dudy)).rg;
        }
    }
    return sum / 65536.0;
}

inline float sst(float a, float b, float x) {
    return smoothstep(a, b, x);
}

fragment float4 gem_smoke_fragment(VertexOutput in [[stage_in]],
                                   constant GemSmokeUniforms &uniforms [[buffer(0)]],
                                   texture2d<float> imageTexture [[texture(0)]]) {
    float time = uniforms.u_time;
    float roundness = 0.0;
    float imgAlpha = 0.0;

    if (uniforms.u_isImage > 0.5) {
        float2 imageUV = (in.imageUV - 0.5) * 0.95 + 0.5;
        float2 dudx = dfdx(in.imageUV);
        float2 dudy = dfdy(in.imageUV);
        float2 blurred = gaussBlur9x9RG(imageTexture, imageUV, dudx, dudy, 10.0);
        roundness = 1.0 - blurred.x;
        float2 texel = 1.0 / float2(imageTexture.get_width(), imageTexture.get_height());
        const float k3[3] = {1.0, 2.0, 1.0};
        for (int j = -1; j <= 1; ++j) {
            for (int i = -1; i <= 1; ++i) {
                imgAlpha += k3[i + 1] * k3[j + 1] *
                    imageTexture.sample(linearMipSampler, imageUV + float2(float(i) * texel.x, float(j) * texel.y)).g;
            }
        }
        imgAlpha /= 16.0;
    } else {
        float edge = gemShapeEdge(in, uniforms.u_shape, time);
        imgAlpha = 1.0 - smoothstep(0.9 - 2.0 * fwidth(edge), 0.9, edge);
        roundness = 1.0 - edge;
    }

    float2 smokeUV = rotate(in.objectUV, uniforms.u_angle * PI / 180.0);
    smokeUV *= mix(4.0, 1.0, uniforms.u_size);

    float2 innerUV = smokeUV;
    float2 outerUV = smokeUV;

    innerUV.y += uniforms.u_innerDistortion * (1.0 - sst(0.0, 1.0, length(0.4 * innerUV)));
    innerUV.y -= 0.4 * uniforms.u_innerDistortion;
    innerUV.y += 0.7 * uniforms.u_offset * roundness;

    outerUV.y += uniforms.u_outerDistortion * (1.0 - sst(0.0, 1.0, length(0.4 * outerUV)));
    outerUV.y -= 0.4 * uniforms.u_outerDistortion;

    float innerSwirl = uniforms.u_innerDistortion * roundness;
    float outerSwirl = uniforms.u_outerDistortion;

    for (int i = 1; i < 5; i++) {
        float fi = float(i);

        float stretchIn = max(length(dfdx(innerUV)), length(dfdy(innerUV)));
        float dampenIn = 1.0 / (1.0 + stretchIn * 8.0);
        float sIn = innerSwirl * dampenIn;
        innerUV.x += sIn / fi * cos(time + fi * 2.9 * innerUV.y);
        innerUV.y += sIn / fi * cos(time + fi * 1.5 * innerUV.x);

        float stretchOut = max(length(dfdx(outerUV)), length(dfdy(outerUV)));
        float dampenOut = 1.0 / (1.0 + stretchOut * 8.0);
        float sOut = outerSwirl * dampenOut;
        outerUV.x += sOut / fi * cos(time + fi * 2.9 * outerUV.y);
        outerUV.y += sOut / fi * cos(time + fi * 1.5 * outerUV.x);
    }

    float innerShape = exp(-1.5 * dot(innerUV, innerUV));
    float outerShape = exp(-1.5 * dot(outerUV, outerUV));

    float outerMask = pow(uniforms.u_outerGlow, 2.0) * (1.0 - imgAlpha);
    float innerMask = (0.01 + 0.99 * uniforms.u_innerGlow) * imgAlpha;
    innerShape *= innerMask;
    outerShape *= outerMask;

    float mixer = (innerShape + outerShape) * uniforms.u_colorsCount;
    float4 gradient = gemColorAt(uniforms, 0);
    gradient.rgb *= gradient.a;

    float smokeMask = 0.0;
    for (int i = 1; i < 7; i++) {
        if (i > int(uniforms.u_colorsCount)) { break; }

        float m = sst(0.0, 1.0, clamp(mixer - float(i - 1), 0.0, 1.0));
        if (i == 1) { smokeMask = m; }

        float4 c = gemColorAt(uniforms, i - 1);
        c.rgb *= c.a;
        gradient = mix(gradient, c, m);
    }

    float3 color = gradient.rgb * smokeMask;
    float opacity = gradient.a * smokeMask;

    float innerOpacity = uniforms.u_colorInner.a * imgAlpha;
    float3 innerColor = uniforms.u_colorInner.rgb * innerOpacity;
    color += innerColor * (1.0 - opacity);
    opacity += innerOpacity * (1.0 - opacity);

    float3 backColor = uniforms.u_colorBack.rgb * uniforms.u_colorBack.a;
    color += backColor * (1.0 - opacity);
    opacity += uniforms.u_colorBack.a * (1.0 - opacity);

    return float4(color, opacity);
}
