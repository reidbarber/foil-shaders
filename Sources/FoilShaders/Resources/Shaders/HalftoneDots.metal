#include <metal_stdlib>
#include "Common.h"
#include "ShaderTypes.h"

using namespace metal;

struct HalftoneDotsUniforms {
    float u_time;
    float4 u_colorFront;
    float4 u_colorBack;
    float u_radius;
    float u_contrast;
    float u_size;
    float u_grainMixer;
    float u_grainOverlay;
    float u_grainSize;
    float u_grid;
    float u_originalColors;
    float u_inverted;
    float u_type;
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

static inline float valueNoise(float2 st) {
    float2 i = floor(st);
    float2 f = fract(st);
    float a = hash21(i);
    float b = hash21(i + float2(1.0, 0.0));
    float c = hash21(i + float2(0.0, 1.0));
    float d = hash21(i + float2(1.0, 1.0));
    float2 u = f * f * (3.0 - 2.0 * f);
    float x1 = mix(a, b, u.x);
    float x2 = mix(c, d, u.x);
    return mix(x1, x2, u.y);
}

static inline float getCircle(float2 uv, float r, float baseR) {
    r = mix(0.25 * baseR, 0.0, r);
    float d = length(uv - 0.5);
    float aa = fwidth(d);
    return 1.0 - smoothstep(r - aa, r + aa, d);
}

static inline float getCell(float2 uv) {
    float insideX = step(0.0, uv.x) * (1.0 - step(1.0, uv.x));
    float insideY = step(0.0, uv.y) * (1.0 - step(1.0, uv.y));
    return insideX * insideY;
}

static inline float getCircleWithHole(float2 uv, float r, float baseR) {
    float cell = getCell(uv);
    r = mix(0.75 * baseR, 0.0, r);
    float rMod = fmod(r, 0.5);
    float d = length(uv - 0.5);
    float aa = fwidth(d);
    float circle = 1.0 - smoothstep(rMod - aa, rMod + aa, d);
    if (r < 0.5) {
        return circle;
    }
    return cell - circle;
}

static inline float getGooeyBall(float2 uv, float r, float baseR, float grid) {
    float d = length(uv - 0.5);
    float sizeRadius = 0.3;
    if (grid == 1.0) {
        sizeRadius = 0.42;
    }
    sizeRadius = mix(sizeRadius * baseR, 0.0, r);
    d = 1.0 - smoothstep(0.0, sizeRadius, d);
    d = pow(d, 2.0 + baseR);
    return d;
}

static inline float getSoftBall(float2 uv, float r, float baseR) {
    float d = length(uv - 0.5);
    float sizeRadius = clamp(baseR, 0.0, 1.0);
    sizeRadius = mix(0.5 * sizeRadius, 0.0, r);
    d = 1.0 - clamp((d - 0.0) / (sizeRadius - 0.0), 0.0, 1.0);
    float powRadius = 1.0 - clamp((baseR - 0.0) / (2.0 - 0.0), 0.0, 1.0);
    d = pow(d, 4.0 + 3.0 * powRadius);
    return d;
}

static inline float getUvFrame(float2 uv, float2 pad) {
    float aa = 0.0001;
    float left = smoothstep(-pad.x, -pad.x + aa, uv.x);
    float right = smoothstep(1.0 + pad.x, 1.0 + pad.x - aa, uv.x);
    float bottom = smoothstep(-pad.y, -pad.y + aa, uv.y);
    float top = smoothstep(1.0 + pad.y, 1.0 + pad.y - aa, uv.y);
    return left * right * bottom * top;
}

static inline float sigmoid(float x, float k) {
    return 1.0 / (1.0 + exp(-k * (x - 0.5)));
}

static inline float getLumAtPx(texture2d<float> imageTexture, float2 uv, float contrast, bool inverted) {
    float4 tex = imageTexture.sample(linearSampler, uv);
    float3 color = float3(
        sigmoid(tex.r, contrast),
        sigmoid(tex.g, contrast),
        sigmoid(tex.b, contrast)
    );
    float lum = dot(float3(0.2126, 0.7152, 0.0722), color);
    lum = mix(1.0, lum, tex.a);
    lum = inverted ? (1.0 - lum) : lum;
    return lum;
}

static inline float getLumBall(texture2d<float> imageTexture,
                        float2 p,
                        float2 pad,
                        float2 inCellOffset,
                        float contrast,
                        float baseR,
                        float stepSize,
                        bool inverted,
                        float grid,
                        float type,
                        thread float4 &ballColor) {
    p += inCellOffset;
    float2 uv_i = floor(p);
    float2 uv_f = fract(p);
    float2 samplingUV = (uv_i + 0.5 - inCellOffset) * pad + float2(0.5);
    float outOfFrame = getUvFrame(samplingUV, pad * stepSize);
    float lum = getLumAtPx(imageTexture, samplingUV, contrast, inverted);
    ballColor = imageTexture.sample(linearSampler, samplingUV);
    ballColor.rgb *= ballColor.a;
    ballColor *= outOfFrame;

    float ball = 0.0;
    if (type < 0.5) {
        ball = getCircle(uv_f, lum, baseR);
    } else if (type < 1.5) {
        ball = getGooeyBall(uv_f, lum, baseR, grid);
    } else if (type < 2.5) {
        ball = getCircleWithHole(uv_f, lum, baseR);
    } else {
        ball = getSoftBall(uv_f, lum, baseR);
    }
    return ball * outOfFrame;
}

fragment float4 halftone_dots_fragment(VertexOutput in [[stage_in]],
                                      constant HalftoneDotsUniforms &uniforms [[buffer(0)]],
                                      constant FragmentVertexUniforms &vertexUniforms [[buffer(1)]],
                                      texture2d<float> imageTexture [[texture(0)]]) {
    float stepMultiplier = 1.0;
    if (uniforms.u_type < 0.5) {
        stepMultiplier = 2.0;
    } else if (uniforms.u_type < 1.5 || uniforms.u_type > 2.5) {
        stepMultiplier = 6.0;
    }

    float cellsPerSide = mix(300.0, 7.0, pow(uniforms.u_size, 0.7));
    cellsPerSide /= stepMultiplier;
    float cellSizeY = 1.0 / cellsPerSide;
    float2 pad = cellSizeY * float2(1.0 / vertexUniforms.u_imageAspectRatio, 1.0);
    if (uniforms.u_type > 0.5 && uniforms.u_type < 1.5 && uniforms.u_grid > 0.5) {
        pad *= 0.7;
    }

    float2 uv = in.imageUV;
    uv -= 0.5;
    uv /= pad;

    float contrast = mix(0.0, 15.0, pow(uniforms.u_contrast, 1.5));
    float baseRadius = uniforms.u_radius;
    if (uniforms.u_originalColors > 0.5) {
        contrast = mix(0.1, 4.0, pow(uniforms.u_contrast, 2.0));
        baseRadius = 2.0 * pow(0.5 * uniforms.u_radius, 0.3);
    }

    float totalShape = 0.0;
    float3 totalColor = float3(0.0);
    float totalOpacity = 0.0;

    float4 ballColor;
    float stepSize = 1.0 / stepMultiplier;
    for (float x = -0.5; x < 0.5; x += stepSize) {
        for (float y = -0.5; y < 0.5; y += stepSize) {
            float2 offset = float2(x, y);
            if (uniforms.u_grid > 0.5) {
                float rowIndex = floor((y + 0.5) / stepSize);
                float colIndex = floor((x + 0.5) / stepSize);
                if (stepSize == 1.0) {
                    rowIndex = floor(uv.y + y + 1.0);
                    if (uniforms.u_type > 0.5 && uniforms.u_type < 1.5) {
                        colIndex = floor(uv.x + x + 1.0);
                    }
                }
                if (uniforms.u_type > 0.5 && uniforms.u_type < 1.5) {
                    if (mod(rowIndex + colIndex, 2.0) == 1.0) {
                        continue;
                    }
                } else {
                    if (mod(rowIndex, 2.0) == 1.0) {
                        offset.x += 0.5 * stepSize;
                    }
                }
            }

            float shape = getLumBall(imageTexture, uv, pad, offset, contrast, baseRadius, stepSize,
                                     uniforms.u_inverted > 0.5, uniforms.u_grid, uniforms.u_type, ballColor);
            totalColor += ballColor.rgb * shape;
            totalShape += shape;
            totalOpacity += shape;
        }
    }

    const float eps = 1e-4;
    totalColor /= max(totalShape, eps);
    totalOpacity /= max(totalShape, eps);

    float finalShape = 0.0;
    if (uniforms.u_type < 0.5) {
        finalShape = min(1.0, totalShape);
    } else if (uniforms.u_type < 1.5) {
        float aa = fwidth(totalShape);
        float th = 0.5;
        finalShape = smoothstep(th - aa, th + aa, totalShape);
    } else if (uniforms.u_type < 2.5) {
        finalShape = min(1.0, totalShape);
    } else {
        finalShape = totalShape;
    }

    float2 grainSize = mix(2000.0, 200.0, uniforms.u_grainSize) * float2(1.0, 1.0 / vertexUniforms.u_imageAspectRatio);
    float2 grainUV = in.imageUV - 0.5;
    grainUV *= grainSize;
    grainUV += 0.5;
    float grain = valueNoise(grainUV);
    grain = smoothstep(0.55, 0.7 + 0.2 * uniforms.u_grainMixer, grain);
    grain *= uniforms.u_grainMixer;
    finalShape = mix(finalShape, 0.0, grain);

    float3 color = float3(0.0);
    float opacity = 0.0;
    if (uniforms.u_originalColors > 0.5) {
        color = totalColor * finalShape;
        opacity = totalOpacity * finalShape;
        float3 bgColor = uniforms.u_colorBack.rgb * uniforms.u_colorBack.a;
        color = color + bgColor * (1.0 - opacity);
        opacity = opacity + uniforms.u_colorBack.a * (1.0 - opacity);
    } else {
        float3 fgColor = uniforms.u_colorFront.rgb * uniforms.u_colorFront.a;
        float fgOpacity = uniforms.u_colorFront.a;
        float3 bgColor = uniforms.u_colorBack.rgb * uniforms.u_colorBack.a;
        float bgOpacity = uniforms.u_colorBack.a;
        color = fgColor * finalShape;
        opacity = fgOpacity * finalShape;
        color += bgColor * (1.0 - opacity);
        opacity += bgOpacity * (1.0 - opacity);
    }

    float grainOverlay = valueNoise(rotate(grainUV, 1.0) + float2(3.0));
    grainOverlay = mix(grainOverlay, valueNoise(rotate(grainUV, 2.0) + float2(-1.0)), 0.5);
    grainOverlay = pow(grainOverlay, 1.3);
    float grainOverlayV = grainOverlay * 2.0 - 1.0;
    float3 grainOverlayColor = float3(step(0.0, grainOverlayV));
    float grainOverlayStrength = uniforms.u_grainOverlay * abs(grainOverlayV);
    grainOverlayStrength = pow(grainOverlayStrength, 0.8);
    color = mix(color, grainOverlayColor, 0.5 * grainOverlayStrength);
    opacity += 0.5 * grainOverlayStrength;
    opacity = clamp(opacity, 0.0, 1.0);
    return float4(color, opacity);
}
