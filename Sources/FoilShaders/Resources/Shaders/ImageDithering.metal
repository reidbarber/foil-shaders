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

struct ImageDitheringUniforms {
    float4 u_colorFront;
    float4 u_colorBack;
    float4 u_colorHighlight;
    float u_type;
    float u_pxSize;
    float u_originalColors;
    float u_inverted;
    float u_colorSteps;
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

inline float getUvFrame(float2 uv, float2 pad) {
    float aa = 0.0001;
    float left = smoothstep(-pad.x, -pad.x + aa, uv.x);
    float right = smoothstep(1.0 + pad.x, 1.0 + pad.x - aa, uv.x);
    float bottom = smoothstep(-pad.y, -pad.y + aa, uv.y);
    float top = smoothstep(1.0 + pad.y, 1.0 + pad.y - aa, uv.y);
    return left * right * bottom * top;
}

inline float2 getImageUV(float2 uv, constant FragmentVertexUniforms &vertexUniforms) {
    float2 boxOrigin = float2(0.5 - vertexUniforms.u_originX, vertexUniforms.u_originY - 0.5);
    float r = vertexUniforms.u_rotation * PI / 180.0;
    float2x2 graphicRotation = float2x2(cos(r), sin(r), -sin(r), cos(r));
    float2 graphicOffset = float2(-vertexUniforms.u_offsetX, vertexUniforms.u_offsetY);

    float2 imageBoxSize;
    if (vertexUniforms.u_fit == 1.0) {
        imageBoxSize.x = min(vertexUniforms.u_resolution.x / vertexUniforms.u_imageAspectRatio, vertexUniforms.u_resolution.y) * vertexUniforms.u_imageAspectRatio;
    } else if (vertexUniforms.u_fit == 2.0) {
        imageBoxSize.x = max(vertexUniforms.u_resolution.x / vertexUniforms.u_imageAspectRatio, vertexUniforms.u_resolution.y) * vertexUniforms.u_imageAspectRatio;
    } else {
        imageBoxSize.x = min(10.0, 10.0 / vertexUniforms.u_imageAspectRatio * vertexUniforms.u_imageAspectRatio);
    }
    imageBoxSize.y = imageBoxSize.x / vertexUniforms.u_imageAspectRatio;
    float2 imageBoxScale = vertexUniforms.u_resolution / imageBoxSize;

    float2 imageUV = uv;
    imageUV *= imageBoxScale;
    imageUV += boxOrigin * (imageBoxScale - 1.0);
    imageUV += graphicOffset;
    imageUV /= vertexUniforms.u_scale;
    imageUV.x *= vertexUniforms.u_imageAspectRatio;
    imageUV = graphicRotation * imageUV;
    imageUV.x /= vertexUniforms.u_imageAspectRatio;
    imageUV += 0.5;
    imageUV.y = 1.0 - imageUV.y;
    return imageUV;
}

inline float getBayerValue(float2 uv, int size) {
    int2 pos = int2(fract(uv / float(size)) * float(size));
    int index = pos.y * size + pos.x;
    if (size == 2) { return float(bayer2x2[index]) / 4.0; }
    if (size == 4) { return float(bayer4x4[index]) / 16.0; }
    if (size == 8) { return float(bayer8x8[index]) / 64.0; }
    return 0.0;
}

fragment float4 image_dithering_fragment(VertexOutput in [[stage_in]],
                                        constant ImageDitheringUniforms &uniforms [[buffer(0)]],
                                        constant FragmentVertexUniforms &vertexUniforms [[buffer(1)]],
                                        texture2d<float> imageTexture [[texture(0)]]) {
    float pxSize = uniforms.u_pxSize * vertexUniforms.u_pixelRatio;
    float2 fragCoord = float2(in.position.x, vertexUniforms.u_resolution.y - in.position.y);
    float2 pxSizeUV = fragCoord - 0.5 * vertexUniforms.u_resolution;
    pxSizeUV /= pxSize;
    float2 canvasPixelizedUV = (floor(pxSizeUV) + 0.5) * pxSize;
    float2 normalizedUV = canvasPixelizedUV / vertexUniforms.u_resolution;

    float2 imageUV = getImageUV(normalizedUV, vertexUniforms);
    float2 ditheringNoiseUV = canvasPixelizedUV;
    float4 image = imageTexture.sample(linearSampler, imageUV);
    float frame = getUvFrame(imageUV, pxSize / vertexUniforms.u_resolution);

    int type = int(floor(uniforms.u_type));
    float dithering = 0.0;
    float lum = dot(float3(0.2126, 0.7152, 0.0722), image.rgb);
    lum = uniforms.u_inverted > 0.5 ? (1.0 - lum) : lum;
    switch (type) {
        case 1:
            dithering = step(hash21(ditheringNoiseUV), lum);
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

    float colorSteps = max(floor(uniforms.u_colorSteps), 1.0);
    float3 color = float3(0.0);
    float opacity = 1.0;

    dithering -= 0.5;
    float brightness = clamp(lum + dithering / colorSteps, 0.0, 1.0);
    brightness = mix(0.0, brightness, frame);
    brightness = mix(0.0, brightness, image.a);
    float quantLum = floor(brightness * colorSteps + 0.5) / colorSteps;
    quantLum = mix(0.0, quantLum, frame);

    if (uniforms.u_originalColors > 0.5) {
        float3 normColor = image.rgb / max(lum, 0.001);
        color = normColor * quantLum;
        float quantAlpha = floor(image.a * colorSteps + 0.5) / colorSteps;
        opacity = mix(quantLum, 1.0, quantAlpha);
    } else {
        float3 fgColor = uniforms.u_colorFront.rgb * uniforms.u_colorFront.a;
        float fgOpacity = uniforms.u_colorFront.a;
        float3 bgColor = uniforms.u_colorBack.rgb * uniforms.u_colorBack.a;
        float bgOpacity = uniforms.u_colorBack.a;
        float3 hlColor = uniforms.u_colorHighlight.rgb * uniforms.u_colorHighlight.a;
        float hlOpacity = uniforms.u_colorHighlight.a;
        fgColor = mix(fgColor, hlColor, step(1.02 - 0.02 * uniforms.u_colorSteps, brightness));
        fgOpacity = mix(fgOpacity, hlOpacity, step(1.02 - 0.02 * uniforms.u_colorSteps, brightness));
        color = fgColor * quantLum;
        opacity = fgOpacity * quantLum;
        color += bgColor * (1.0 - opacity);
        opacity += bgOpacity * (1.0 - opacity);
    }

    return float4(color, opacity);
}
