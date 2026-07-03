#include <metal_stdlib>
#include "Common.metal"

using namespace metal;

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

struct DitheringUniforms {
    float u_time;
    float u_pxSize;
    float4 u_colorBack;
    float4 u_colorFront;
    float u_shape;
    float u_type;
};

constant int bayer2x2[4] = {0, 2, 3, 1};
constant int bayer4x4[16] = {
    0, 8, 2, 10,
    12, 4, 14, 6,
    3, 11, 1, 9,
    15, 7, 13, 5
};
constant int bayer8x8[64] = {
    0, 32, 8, 40, 2, 34, 10, 42,
    48, 16, 56, 24, 50, 18, 58, 26,
    12, 44, 4, 36, 14, 46, 6, 38,
    60, 28, 52, 20, 62, 30, 54, 22,
    3, 35, 11, 43, 1, 33, 9, 41,
    51, 19, 59, 27, 49, 17, 57, 25,
    15, 47, 7, 39, 13, 45, 5, 37,
    63, 31, 55, 23, 61, 29, 53, 21
};

inline float getSimplexNoise(float2 uv, float t) {
    float noise = 0.5 * snoise(uv - float2(0.0, 0.3 * t));
    noise += 0.5 * snoise(2.0 * uv + float2(0.0, 0.32 * t));
    return noise;
}

inline float getBayerValue(float2 uv, int size) {
    int2 pos = int2(fract(uv / float(size)) * float(size));
    int index = pos.y * size + pos.x;
    if (size == 2) { return float(bayer2x2[index]) / 4.0; }
    if (size == 4) { return float(bayer4x4[index]) / 16.0; }
    if (size == 8) { return float(bayer8x8[index]) / 64.0; }
    return 0.0;
}

fragment float4 dithering_fragment(VertexOutput in [[stage_in]],
                                  constant DitheringUniforms &uniforms [[buffer(0)]],
                                  constant FragmentVertexUniforms &vertexUniforms [[buffer(1)]]) {
    float t = 0.5 * uniforms.u_time;
    float pxSize = uniforms.u_pxSize * vertexUniforms.u_pixelRatio;
    float2 fragCoord = float2(in.position.x, vertexUniforms.u_resolution.y - in.position.y);
    float2 pxSizeUV = fragCoord - 0.5 * vertexUniforms.u_resolution;
    pxSizeUV /= pxSize;
    float2 canvasPixelizedUV = (floor(pxSizeUV) + 0.5) * pxSize;
    float2 normalizedUV = canvasPixelizedUV / vertexUniforms.u_resolution;

    float2 ditheringNoiseUV = canvasPixelizedUV;
    float2 shapeUV = normalizedUV;

    float2 boxOrigin = float2(0.5 - vertexUniforms.u_originX, vertexUniforms.u_originY - 0.5);
    float2 givenBoxSize = float2(vertexUniforms.u_worldWidth, vertexUniforms.u_worldHeight);
    givenBoxSize = max(givenBoxSize, float2(1.0)) * vertexUniforms.u_pixelRatio;
    float r = vertexUniforms.u_rotation * PI / 180.0;
    float2x2 graphicRotation = float2x2(cos(r), sin(r), -sin(r), cos(r));
    float2 graphicOffset = float2(-vertexUniforms.u_offsetX, vertexUniforms.u_offsetY);

    float patternBoxRatio = givenBoxSize.x / givenBoxSize.y;
    float2 boxSize = float2(
        (vertexUniforms.u_worldWidth == 0.0) ? vertexUniforms.u_resolution.x : givenBoxSize.x,
        (vertexUniforms.u_worldHeight == 0.0) ? vertexUniforms.u_resolution.y : givenBoxSize.y
    );

    if (uniforms.u_shape > 3.5) {
        float2 objectBoxSize = float2(0.0);
        objectBoxSize.x = min(boxSize.x, boxSize.y);
        if (vertexUniforms.u_fit == 1.0) {
            objectBoxSize.x = min(vertexUniforms.u_resolution.x, vertexUniforms.u_resolution.y);
        } else if (vertexUniforms.u_fit == 2.0) {
            objectBoxSize.x = max(vertexUniforms.u_resolution.x, vertexUniforms.u_resolution.y);
        }
        objectBoxSize.y = objectBoxSize.x;
        float2 objectWorldScale = vertexUniforms.u_resolution / objectBoxSize;

        shapeUV *= objectWorldScale;
        shapeUV += boxOrigin * (objectWorldScale - 1.0);
        shapeUV += graphicOffset;
        shapeUV /= vertexUniforms.u_scale;
        shapeUV = graphicRotation * shapeUV;
    } else {
        float2 patternBoxSize = float2(0.0);
        patternBoxSize.x = patternBoxRatio * min(boxSize.x / patternBoxRatio, boxSize.y);
        float patternWorldNoFitBoxWidth = patternBoxSize.x;
        if (vertexUniforms.u_fit == 1.0) {
            patternBoxSize.x = patternBoxRatio * min(vertexUniforms.u_resolution.x / patternBoxRatio, vertexUniforms.u_resolution.y);
        } else if (vertexUniforms.u_fit == 2.0) {
            patternBoxSize.x = patternBoxRatio * max(vertexUniforms.u_resolution.x / patternBoxRatio, vertexUniforms.u_resolution.y);
        }
        patternBoxSize.y = patternBoxSize.x / patternBoxRatio;
        float2 patternWorldScale = vertexUniforms.u_resolution / patternBoxSize;

        shapeUV += graphicOffset / patternWorldScale;
        shapeUV += boxOrigin;
        shapeUV -= boxOrigin / patternWorldScale;
        shapeUV *= vertexUniforms.u_resolution;
        shapeUV /= vertexUniforms.u_pixelRatio;
        if (vertexUniforms.u_fit > 0.0) {
            shapeUV *= (patternWorldNoFitBoxWidth / patternBoxSize.x);
        }
        shapeUV /= vertexUniforms.u_scale;
        shapeUV = graphicRotation * shapeUV;
        shapeUV += boxOrigin / patternWorldScale;
        shapeUV -= boxOrigin;
        shapeUV += 0.5;
    }

    float shape = 0.0;
    if (uniforms.u_shape < 1.5) {
        shapeUV *= 0.001;
        shape = 0.5 + 0.5 * getSimplexNoise(shapeUV, t);
        shape = smoothstep(0.3, 0.9, shape);
    } else if (uniforms.u_shape < 2.5) {
        shapeUV *= 0.003;
        for (float i = 1.0; i < 6.0; i++) {
            shapeUV.x += 0.6 / i * cos(i * 2.5 * shapeUV.y + t);
            shapeUV.y += 0.6 / i * cos(i * 1.5 * shapeUV.x + t);
        }
        shape = 0.15 / max(0.001, abs(sin(t - shapeUV.y - shapeUV.x)));
        shape = smoothstep(0.02, 1.0, shape);
    } else if (uniforms.u_shape < 3.5) {
        shapeUV *= 0.05;
        float stripeIdx = floor(2.0 * shapeUV.x / TWO_PI);
        float rand = hash11(stripeIdx * 10.0);
        rand = sign(rand - 0.5) * pow(0.1 + abs(rand), 0.4);
        shape = sin(shapeUV.x) * cos(shapeUV.y - 5.0 * rand * t);
        shape = pow(abs(shape), 6.0);
    } else if (uniforms.u_shape < 4.5) {
        shapeUV *= 4.0;
        float wave = cos(0.5 * shapeUV.x - 2.0 * t) * sin(1.5 * shapeUV.x + t) * (0.75 + 0.25 * cos(3.0 * t));
        shape = 1.0 - smoothstep(-1.0, 1.0, shapeUV.y + wave);
    } else if (uniforms.u_shape < 5.5) {
        float dist = length(shapeUV);
        float waves = sin(pow(dist, 1.7) * 7.0 - 3.0 * t) * 0.5 + 0.5;
        shape = waves;
    } else if (uniforms.u_shape < 6.5) {
        float l = length(shapeUV);
        float angle = 6.0 * atan2(shapeUV.y, shapeUV.x) + 4.0 * t;
        float twist = 1.2;
        float offset = 1.0 / pow(max(l, 1e-6), twist) + angle / TWO_PI;
        float mid = smoothstep(0.0, 1.0, pow(l, twist));
        shape = mix(0.0, fract(offset), mid);
    } else {
        shapeUV *= 2.0;
        float d = 1.0 - pow(length(shapeUV), 2.0);
        float3 pos = float3(shapeUV, sqrt(max(0.0, d)));
        float3 lightPos = normalize(float3(cos(1.5 * t), 0.8, sin(1.25 * t)));
        shape = 0.5 + 0.5 * dot(lightPos, pos);
        shape *= step(0.0, d);
    }

    int type = int(floor(uniforms.u_type));
    float dithering = 0.0;
    switch (type) {
        case 1:
            dithering = step(hash21(ditheringNoiseUV), shape);
            break;
        case 2:
            dithering = getBayerValue(pxSizeUV, 2);
            break;
        case 3:
            dithering = getBayerValue(pxSizeUV, 4);
            break;
        default:
            dithering = getBayerValue(pxSizeUV, 8);
            break;
    }

    dithering -= 0.5;
    float res = step(0.5, shape + dithering);

    float3 fgColor = uniforms.u_colorFront.rgb * uniforms.u_colorFront.a;
    float fgOpacity = uniforms.u_colorFront.a;
    float3 bgColor = uniforms.u_colorBack.rgb * uniforms.u_colorBack.a;
    float bgOpacity = uniforms.u_colorBack.a;

    float3 color = fgColor * res;
    float opacity = fgOpacity * res;
    color += bgColor * (1.0 - opacity);
    opacity += bgOpacity * (1.0 - opacity);

    return float4(color, opacity);
}
