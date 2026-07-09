#include <metal_stdlib>
#include "Common.h"
#include "ShaderTypes.h"

using namespace metal;

struct LiquidMetalUniforms {
    float u_time;
    float4 u_colorBack;
    float4 u_colorTint;
    float u_repetition;
    float u_softness;
    float u_shiftRed;
    float u_shiftBlue;
    float u_distortion;
    float u_contour;
    float u_angle;
    float u_shape;
    float u_isImage;
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

static inline float getColorChanges(float c1, float c2, float stripe_p, float3 w, float blur, float bump, float tint, float tintAlpha, bool isImage) {
    float ch = mix(c2, c1, smoothstep(0.0, 2.0 * blur, stripe_p));
    float border = w.x;
    ch = mix(ch, c2, smoothstep(border, border + 2.0 * blur, stripe_p));
    if (isImage) {
        bump = smoothstep(0.2, 0.8, bump);
    }
    border = w.x + 0.4 * (1.0 - bump) * w.y;
    ch = mix(ch, c1, smoothstep(border, border + 2.0 * blur, stripe_p));
    border = w.x + 0.5 * (1.0 - bump) * w.y;
    ch = mix(ch, c2, smoothstep(border, border + 2.0 * blur, stripe_p));
    border = w.x + w.y;
    ch = mix(ch, c1, smoothstep(border, border + 2.0 * blur, stripe_p));
    float gradient_t = (stripe_p - w.x - w.y) / w.z;
    float gradient = mix(c1, c2, smoothstep(0.0, 1.0, gradient_t));
    ch = mix(ch, gradient, smoothstep(border, border + 0.5 * blur, stripe_p));
    ch = mix(ch, 1.0 - min(1.0, (1.0 - ch) / max(tint, 0.0001)), tintAlpha);
    return ch;
}

static inline float getImgFrame(float2 uv, float th) {
    float frame = 1.0;
    frame *= smoothstep(0.0, th, uv.y);
    frame *= 1.0 - smoothstep(1.0 - th, 1.0, uv.y);
    frame *= smoothstep(0.0, th, uv.x);
    frame *= 1.0 - smoothstep(1.0 - th, 1.0, uv.x);
    return frame;
}

static inline float blurEdge3x3(texture2d<float> tex, float2 uv, float2 dudx, float2 dudy, float radius, float centerSample) {
    float2 texel = 1.0 / float2(tex.get_width(), tex.get_height());
    float2 r = radius * texel;
    float w1 = 1.0, w2 = 2.0, w4 = 4.0;
    float norm = 16.0;
    float sum = w4 * centerSample;
    sum += w2 * tex.sample(linearSampler, uv + float2(0.0, -r.y), gradient2d(dudx, dudy)).r;
    sum += w2 * tex.sample(linearSampler, uv + float2(0.0, r.y), gradient2d(dudx, dudy)).r;
    sum += w2 * tex.sample(linearSampler, uv + float2(-r.x, 0.0), gradient2d(dudx, dudy)).r;
    sum += w2 * tex.sample(linearSampler, uv + float2(r.x, 0.0), gradient2d(dudx, dudy)).r;
    sum += w1 * tex.sample(linearSampler, uv + float2(-r.x, -r.y), gradient2d(dudx, dudy)).r;
    sum += w1 * tex.sample(linearSampler, uv + float2(r.x, -r.y), gradient2d(dudx, dudy)).r;
    sum += w1 * tex.sample(linearSampler, uv + float2(-r.x, r.y), gradient2d(dudx, dudy)).r;
    sum += w1 * tex.sample(linearSampler, uv + float2(r.x, r.y), gradient2d(dudx, dudy)).r;
    return sum / norm;
}

fragment float4 liquid_metal_fragment(VertexOutput in [[stage_in]],
                                     constant LiquidMetalUniforms &uniforms [[buffer(0)]],
                                     constant FragmentVertexUniforms &vertexUniforms [[buffer(1)]],
                                     texture2d<float> imageTexture [[texture(0)]]) {
    float t = 0.3 * (uniforms.u_time + 2.8);
    float2 uv = in.imageUV;
    float2 dudx = dfdx(in.imageUV);
    float2 dudy = dfdy(in.imageUV);
    float4 img = imageTexture.sample(linearSampler, uv, gradient2d(dudx, dudy));

    if (uniforms.u_isImage < 0.5) {
        uv = in.objectUV + 0.5;
        uv.y = 1.0 - uv.y;
    }

    float cycleWidth = uniforms.u_repetition;
    float edge = 0.0;
    float contOffset = 1.0;

    float2 rotatedUV = uv - float2(0.5);
    float angle = (-uniforms.u_angle + 70.0) * PI / 180.0;
    float cosA = cos(angle);
    float sinA = sin(angle);
    rotatedUV = float2(rotatedUV.x * cosA - rotatedUV.y * sinA,
                       rotatedUV.x * sinA + rotatedUV.y * cosA) + float2(0.5);

    if (uniforms.u_isImage > 0.5) {
        float edgeRaw = img.r;
        edge = blurEdge3x3(imageTexture, uv, dudx, dudy, 6.0, edgeRaw);
        edge = pow(edge, 1.6);
        edge *= mix(0.0, 1.0, smoothstep(0.0, 0.4, uniforms.u_contour));
    } else {
        if (uniforms.u_shape < 1.0) {
            float2 borderUV = in.responsiveUV + 0.5;
            float ratio = in.responsiveBoxGivenSize.x / in.responsiveBoxGivenSize.y;
            float2 mask = min(borderUV, 1.0 - borderUV);
            float2 pixel_thickness = min(250.0 / in.responsiveBoxGivenSize, float2(0.5));
            float maskX = smoothstep(0.0, pixel_thickness.x, mask.x);
            float maskY = smoothstep(0.0, pixel_thickness.y, mask.y);
            maskX = pow(maskX, 0.25);
            maskY = pow(maskY, 0.25);
            edge = clamp(1.0 - maskX * maskY, 0.0, 1.0);

            uv = in.responsiveUV;
            if (ratio > 1.0) {
                uv.y /= ratio;
            } else {
                uv.x *= ratio;
            }
            uv += 0.5;
            uv.y = 1.0 - uv.y;

            cycleWidth *= 2.0;
            contOffset = 1.5;
        } else if (uniforms.u_shape < 2.0) {
            float2 shapeUV = uv - 0.5;
            shapeUV *= 0.67;
            edge = pow(clamp(3.0 * length(shapeUV), 0.0, 1.0), 18.0);
        } else if (uniforms.u_shape < 3.0) {
            float2 shapeUV = uv - 0.5;
            shapeUV *= 1.68;
            float r = length(shapeUV) * 2.0;
            float a = atan2(shapeUV.y, shapeUV.x) + 0.2;
            r *= (1.0 + 0.05 * sin(3.0 * a + 2.0 * t));
            float f = abs(cos(a * 3.0));
            edge = smoothstep(f, f + 0.7, r);
            edge *= edge;
            uv *= 0.8;
            cycleWidth *= 1.6;
        } else if (uniforms.u_shape < 4.0) {
            float2 shapeUV = uv - 0.5;
            shapeUV = rotate(shapeUV, 0.25 * PI);
            shapeUV *= 1.42;
            shapeUV += 0.5;
            float2 mask = min(shapeUV, 1.0 - shapeUV);
            float2 pixel_thickness = float2(0.15);
            float maskX = smoothstep(0.0, pixel_thickness.x, mask.x);
            float maskY = smoothstep(0.0, pixel_thickness.y, mask.y);
            maskX = pow(maskX, 0.25);
            maskY = pow(maskY, 0.25);
            edge = clamp(1.0 - maskX * maskY, 0.0, 1.0);
        } else if (uniforms.u_shape < 5.0) {
            float2 shapeUV = uv - 0.5;
            shapeUV *= 1.3;
            edge = 0.0;
            for (int i = 0; i < 5; i++) {
                float fi = float(i);
                float speed = 1.5 + 2.0 / 3.0 * sin(fi * 12.345);
                float angle2 = -fi * 1.5;
                float2 dir1 = float2(cos(angle2), sin(angle2));
                float2 dir2 = float2(cos(angle2 + 1.57), sin(angle2 + 1.0));
                float2 traj = 0.4 * (dir1 * sin(t * speed + fi * 1.23) + dir2 * cos(t * (speed * 0.7) + fi * 2.17));
                float d = length(shapeUV + traj);
                edge += pow(1.0 - clamp(d, 0.0, 1.0), 4.0);
            }
            edge = 1.0 - smoothstep(0.65, 0.9, edge);
            edge = pow(edge, 4.0);
        }

        edge = mix(smoothstep(0.9 - 2.0 * fwidth(edge), 0.9, edge), edge, smoothstep(0.0, 0.4, uniforms.u_contour));
    }

    float opacity = 0.0;
    if (uniforms.u_isImage > 0.5) {
        opacity = img.g;
        float frame = getImgFrame(in.imageUV, 0.0);
        opacity *= frame;
    } else {
        opacity = 1.0 - smoothstep(0.9 - 2.0 * fwidth(edge), 0.9, edge);
        if (uniforms.u_shape < 2.0) {
            edge = 1.2 * edge;
        } else if (uniforms.u_shape < 5.0) {
            edge = 1.8 * pow(edge, 1.5);
        }
    }

    float diagBLtoTR = rotatedUV.x - rotatedUV.y;
    float diagTLtoBR = rotatedUV.x + rotatedUV.y;
    float3 color1 = float3(0.98, 0.98, 1.0);
    float3 color2 = float3(0.1, 0.1, 0.1 + 0.1 * smoothstep(0.7, 1.3, diagTLtoBR));

    float2 grad_uv = uv - 0.5;
    float dist = length(grad_uv + float2(0.0, 0.2 * diagBLtoTR));
    grad_uv = rotate(grad_uv, (0.25 - 0.2 * diagBLtoTR) * PI);
    float direction = grad_uv.x;
    float bump = pow(1.8 * dist, 1.2);
    bump = 1.0 - bump;
    bump *= pow(uv.y, 0.3);

    float thin_strip_1_ratio = 0.12 / cycleWidth * (1.0 - 0.4 * bump);
    float thin_strip_2_ratio = 0.07 / cycleWidth * (1.0 + 0.4 * bump);
    float wide_strip_ratio = (1.0 - thin_strip_1_ratio - thin_strip_2_ratio);
    float thin_strip_1_width = cycleWidth * thin_strip_1_ratio;
    float thin_strip_2_width = cycleWidth * thin_strip_2_ratio;

    float noise = snoise(uv - t);
    edge += (1.0 - edge) * uniforms.u_distortion * noise;

    direction += diagBLtoTR;
    float contour = 0.0;
    direction -= 2.0 * noise * diagBLtoTR * (smoothstep(0.0, 1.0, edge) * (1.0 - smoothstep(0.0, 1.0, edge)));
    direction *= mix(1.0, 1.0 - edge, smoothstep(0.5, 1.0, uniforms.u_contour));
    direction -= 1.7 * edge * smoothstep(0.5, 1.0, uniforms.u_contour);
    direction += 0.2 * pow(uniforms.u_contour, 4.0) * (1.0 - smoothstep(0.0, 1.0, edge));

    bump *= clamp(pow(uv.y, 0.1), 0.3, 1.0);
    direction *= (0.1 + (1.1 - edge) * bump);
    direction *= (0.4 + 0.6 * (1.0 - smoothstep(0.5, 1.0, edge)));
    direction += 0.18 * (smoothstep(0.1, 0.2, uv.y) * (1.0 - smoothstep(0.2, 0.4, uv.y)));
    direction += 0.03 * (smoothstep(0.1, 0.2, 1.0 - uv.y) * (1.0 - smoothstep(0.2, 0.4, 1.0 - uv.y)));
    direction *= (0.5 + 0.5 * pow(uv.y, 2.0));
    direction *= cycleWidth;
    direction -= t;

    float colorDispersion = (1.0 - bump);
    colorDispersion = clamp(colorDispersion, 0.0, 1.0);
    float dispersionRed = colorDispersion;
    dispersionRed += 0.03 * bump * noise;
    dispersionRed += 5.0 * (smoothstep(-0.1, 0.2, uv.y) * (1.0 - smoothstep(0.1, 0.5, uv.y))) *
                     (smoothstep(0.4, 0.6, bump) * (1.0 - smoothstep(0.4, 1.0, bump)));
    dispersionRed -= diagBLtoTR;

    float dispersionBlue = colorDispersion;
    dispersionBlue *= 1.3;
    dispersionBlue += (smoothstep(0.0, 0.4, uv.y) * (1.0 - smoothstep(0.1, 0.8, uv.y))) *
                      (smoothstep(0.4, 0.6, bump) * (1.0 - smoothstep(0.4, 0.8, bump)));
    dispersionBlue -= 0.2 * edge;
    dispersionRed *= (uniforms.u_shiftRed / 20.0);
    dispersionBlue *= (uniforms.u_shiftBlue / 20.0);

    float blur = 0.0;
    float rExtraBlur = 0.0;
    float gExtraBlur = 0.0;
    if (uniforms.u_isImage > 0.5) {
        float softness = 0.05 * uniforms.u_softness;
        blur = softness + 0.5 * smoothstep(1.0, 10.0, uniforms.u_repetition) * smoothstep(0.0, 1.0, edge);
        float smallCanvasT = 1.0 - smoothstep(100.0, 500.0, min(vertexUniforms.u_resolution.x, vertexUniforms.u_resolution.y));
        blur += smallCanvasT * smoothstep(0.0, 1.0, edge);
        rExtraBlur = softness * (0.05 + 0.1 * (uniforms.u_shiftRed / 20.0) * bump);
        gExtraBlur = softness * 0.05 / max(0.001, abs(1.0 - diagBLtoTR));
    } else {
        blur = uniforms.u_softness / 15.0 + 0.3 * contour;
    }

    float3 w = float3(thin_strip_1_width, thin_strip_2_width, wide_strip_ratio);
    w.y -= 0.02 * smoothstep(0.0, 1.0, edge + bump);
    float stripe_r = fract(direction + dispersionRed);
    float r = getColorChanges(color1.r, color2.r, stripe_r, w, blur + fwidth(stripe_r) + rExtraBlur, bump, uniforms.u_colorTint.r, uniforms.u_colorTint.a, uniforms.u_isImage > 0.5);
    float stripe_g = fract(direction);
    float g = getColorChanges(color1.g, color2.g, stripe_g, w, blur + fwidth(stripe_g) + gExtraBlur, bump, uniforms.u_colorTint.g, uniforms.u_colorTint.a, uniforms.u_isImage > 0.5);
    float stripe_b = fract(direction - dispersionBlue);
    float b = getColorChanges(color1.b, color2.b, stripe_b, w, blur + fwidth(stripe_b), bump, uniforms.u_colorTint.b, uniforms.u_colorTint.a, uniforms.u_isImage > 0.5);

    float3 color = float3(r, g, b);
    color *= opacity;
    float3 bgColor = uniforms.u_colorBack.rgb * uniforms.u_colorBack.a;
    color = color + bgColor * (1.0 - opacity);
    opacity = opacity + uniforms.u_colorBack.a * (1.0 - opacity);
    color = applyColorBandingFix(color, in.position.xy);
    return float4(color, opacity);
}
