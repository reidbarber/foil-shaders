#include <metal_stdlib>
#include "Common.metal"

using namespace metal;

constant int kPulsingBorderMaxColorCount = 5;
constant int kPulsingBorderMaxSpots = 4;

struct PulsingBorderUniforms {
    float u_time;
    float4 u_colorBack;
    float4 u_colors[kPulsingBorderMaxColorCount];
    float u_colorsCount;
    float u_roundness;
    float u_thickness;
    float u_marginLeft;
    float u_marginRight;
    float u_marginTop;
    float u_marginBottom;
    float u_aspectRatio;
    float u_softness;
    float u_intensity;
    float u_bloom;
    float u_spots;
    float u_spotSize;
    float u_pulse;
    float u_smoke;
    float u_smokeSize;
};

inline float beat(float time) {
    float first = pow(abs(sin(time * TWO_PI)), 10.0);
    float second = pow(abs(sin((time - 0.15) * TWO_PI)), 10.0);
    return clamp(first + 0.6 * second, 0.0, 1.0);
}

inline float sst(float edge0, float edge1, float x) {
    return smoothstep(edge0, edge1, x);
}

inline float roundedBox(float2 uv, float2 halfSize, float distance, float cornerDistance, float thickness, float softness) {
    float borderDistance = abs(distance);
    float aa = 2.0 * fwidth(distance);
    float border = 1.0 - sst(min(mix(thickness, -thickness, softness), thickness + aa),
                             max(mix(thickness, -thickness, softness), thickness + aa),
                             borderDistance);
    float cornerFadeCircles = 0.0;
    cornerFadeCircles = mix(1.0, cornerFadeCircles, sst(0.0, 1.0, length((uv + halfSize) / thickness)));
    cornerFadeCircles = mix(1.0, cornerFadeCircles, sst(0.0, 1.0, length((uv - float2(-halfSize.x, halfSize.y)) / thickness)));
    cornerFadeCircles = mix(1.0, cornerFadeCircles, sst(0.0, 1.0, length((uv - float2(halfSize.x, -halfSize.y)) / thickness)));
    cornerFadeCircles = mix(1.0, cornerFadeCircles, sst(0.0, 1.0, length((uv - halfSize) / thickness)));
    aa = fwidth(cornerDistance);
    float cornerFade = sst(0.0, mix(aa, thickness, softness), cornerDistance);
    cornerFade *= cornerFadeCircles;
    border += cornerFade;
    return border;
}

inline float2 randomGB(texture2d<float> noiseTexture, float2 p) {
    float2 uv = floor(p) / 100.0 + 0.5;
    float4 sample = noiseTexture.sample(linearSampler, fract(uv));
    return sample.gb;
}

inline float randomG(texture2d<float> noiseTexture, float2 p) {
    float2 uv = floor(p) / 100.0 + 0.5;
    return noiseTexture.sample(linearSampler, fract(uv)).g;
}

inline float valueNoise(float2 st, texture2d<float> noiseTexture) {
    float2 i = floor(st);
    float2 f = fract(st);
    float a = randomG(noiseTexture, i);
    float b = randomG(noiseTexture, i + float2(1.0, 0.0));
    float c = randomG(noiseTexture, i + float2(0.0, 1.0));
    float d = randomG(noiseTexture, i + float2(1.0, 1.0));
    float2 u = f * f * (3.0 - 2.0 * f);
    float x1 = mix(a, b, u.x);
    float x2 = mix(c, d, u.x);
    return mix(x1, x2, u.y);
}

fragment float4 pulsing_border_fragment(VertexOutput in [[stage_in]],
                                       constant PulsingBorderUniforms &uniforms [[buffer(0)]],
                                       texture2d<float> noiseTexture [[texture(1)]]) {
    float t = 1.2 * (uniforms.u_time + 109.0);
    float2 borderUV = in.responsiveUV;
    float pulse = uniforms.u_pulse * beat(0.18 * uniforms.u_time);

    float canvasRatio = in.responsiveBoxGivenSize.x / in.responsiveBoxGivenSize.y;
    float2 halfSize = float2(0.5);
    borderUV.x *= max(canvasRatio, 1.0);
    borderUV.y /= min(canvasRatio, 1.0);
    halfSize.x *= max(canvasRatio, 1.0);
    halfSize.y /= min(canvasRatio, 1.0);

    float mL = uniforms.u_marginLeft;
    float mR = uniforms.u_marginRight;
    float mT = uniforms.u_marginTop;
    float mB = uniforms.u_marginBottom;
    float mX = mL + mR;
    float mY = mT + mB;

    if (uniforms.u_aspectRatio > 0.0) {
        float shapeRatio = canvasRatio * (1.0 - mX) / max(1.0 - mY, 1e-6);
        float freeX = shapeRatio > 1.0 ? (1.0 - mX) * (1.0 - 1.0 / max(abs(shapeRatio), 1e-6)) : 0.0;
        float freeY = shapeRatio < 1.0 ? (1.0 - mY) * (1.0 - shapeRatio) : 0.0;
        mL += freeX * 0.5;
        mR += freeX * 0.5;
        mT += freeY * 0.5;
        mB += freeY * 0.5;
        mX = mL + mR;
        mY = mT + mB;
    }

    float thickness = 0.5 * uniforms.u_thickness * min(halfSize.x, halfSize.y);
    halfSize.x *= (1.0 - mX);
    halfSize.y *= (1.0 - mY);

    float2 centerShift = float2(
        (mL - mR) * max(canvasRatio, 1.0) * 0.5,
        (mB - mT) / min(canvasRatio, 1.0) * 0.5
    );

    borderUV -= centerShift;
    halfSize -= mix(thickness, 0.0, uniforms.u_softness);

    float radius = mix(0.0, min(halfSize.x, halfSize.y), uniforms.u_roundness);
    float2 d = abs(borderUV) - halfSize + radius;
    float outsideDistance = length(max(d, 0.0001)) - radius;
    float insideDistance = min(max(d.x, d.y), 0.0001);
    float cornerDistance = abs(min(max(d.x, d.y) - 0.45 * radius, 0.0));
    float distance = outsideDistance + insideDistance;

    float borderThickness = mix(thickness, 3.0 * thickness, uniforms.u_softness);
    float border = roundedBox(borderUV, halfSize, distance, cornerDistance, borderThickness, uniforms.u_softness);
    border = pow(border, 1.0 + uniforms.u_softness);

    float2 smokeUV = 0.3 * uniforms.u_smokeSize * in.patternUV;
    float smoke = clamp(3.0 * valueNoise(2.7 * smokeUV + 0.5 * t, noiseTexture), 0.0, 1.0);
    smoke -= valueNoise(3.4 * smokeUV - 0.5 * t, noiseTexture);
    float smokeThickness = thickness + 0.2;
    smokeThickness = min(0.4, max(smokeThickness, 0.1));
    smoke *= roundedBox(borderUV, halfSize, distance, cornerDistance, smokeThickness, 1.0);
    smoke = 30.0 * smoke * smoke;
    smoke *= mix(0.0, 0.5, pow(uniforms.u_smoke, 2.0));
    smoke *= mix(1.0, pulse, uniforms.u_pulse);
    smoke = clamp(smoke, 0.0, 1.0);
    border += smoke;
    border = clamp(border, 0.0, 1.0);

    float3 blendColor = float3(0.0);
    float blendAlpha = 0.0;
    float3 addColor = float3(0.0);
    float addAlpha = 0.0;

    float bloom = 4.0 * uniforms.u_bloom;
    float intensity = 1.0 + (1.0 + 4.0 * uniforms.u_softness) * uniforms.u_intensity;
    float angle = atan2(borderUV.y, borderUV.x) / TWO_PI;

    for (int colorIdx = 0; colorIdx < kPulsingBorderMaxColorCount; colorIdx++) {
        if (colorIdx >= int(uniforms.u_colorsCount)) { break; }
        float colorIdxF = float(colorIdx);
        float3 c = uniforms.u_colors[colorIdx].rgb * uniforms.u_colors[colorIdx].a;
        float a = uniforms.u_colors[colorIdx].a;
        for (int spotIdx = 0; spotIdx < kPulsingBorderMaxSpots; spotIdx++) {
            if (spotIdx >= int(uniforms.u_spots)) { break; }
            float spotIdxF = float(spotIdx);
            float2 randVal = randomGB(noiseTexture, float2(spotIdxF * 10.0 + 2.0, 40.0 + colorIdxF));
            float time = (0.1 + 0.15 * abs(sin(spotIdxF * (2.0 + colorIdxF)) * cos(spotIdxF * (2.0 + 2.5 * colorIdxF)))) * t + randVal.x * 3.0;
            time *= mix(1.0, -1.0, step(0.5, randVal.y));
            float mask = 0.5 + 0.5 * mix(
                sin(t + spotIdxF * (5.0 - 1.5 * colorIdxF)),
                cos(t + spotIdxF * (3.0 + 1.3 * colorIdxF)),
                step(fmod(colorIdxF, 2.0), 0.5)
            );
            float p = clamp(2.0 * uniforms.u_pulse - randVal.x, 0.0, 1.0);
            mask = mix(mask, pulse, p);
            float atg1 = fract(angle + time);
            float spotSize = 0.05 + 0.6 * pow(uniforms.u_spotSize, 2.0) + 0.05 * randVal.x;
            spotSize = mix(spotSize, 0.1, p);
            float sector = sst(0.5 - spotSize, 0.5, atg1) * (1.0 - sst(0.5, 0.5 + spotSize, atg1));
            sector *= mask;
            sector *= border;
            sector *= intensity;
            sector = clamp(sector, 0.0, 1.0);
            float3 srcColor = c * sector;
            float srcAlpha = a * sector;
            blendColor += ((1.0 - blendAlpha) * srcColor);
            blendAlpha = blendAlpha + (1.0 - blendAlpha) * srcAlpha;
            addColor += srcColor;
            addAlpha += srcAlpha;
        }
    }

    float3 accumColor = mix(blendColor, addColor, bloom);
    float accumAlpha = mix(blendAlpha, addAlpha, bloom);
    accumAlpha = clamp(accumAlpha, 0.0, 1.0);
    float3 bgColor = uniforms.u_colorBack.rgb * uniforms.u_colorBack.a;
    float3 color = accumColor + (1.0 - accumAlpha) * bgColor;
    float opacity = accumAlpha + (1.0 - accumAlpha) * uniforms.u_colorBack.a;
    color = applyColorBandingFix(color, in.position.xy);
    return float4(color, opacity);
}
