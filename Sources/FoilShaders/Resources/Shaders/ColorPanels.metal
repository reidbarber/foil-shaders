#include <metal_stdlib>
#include "Common.metal"

using namespace metal;

constant int kColorPanelsMaxColorCount = 7;

struct ColorPanelsUniforms {
    float u_time;
    float u_scale;
    float4 u_colors[kColorPanelsMaxColorCount];
    float u_colorsCount;
    float4 u_colorBack;
    float u_density;
    float u_angle1;
    float u_angle2;
    float u_length;
    float u_edges;
    float u_blur;
    float u_fadeIn;
    float u_fadeOut;
    float u_gradient;
};

constant float kZLimit = 0.5;

inline float2 getPanel(float angle, float2 uv, float invLength, float aa,
                       constant ColorPanelsUniforms &uniforms) {
    float sinA = sin(angle);
    float cosA = cos(angle);
    float denom = sinA - uv.y * cosA;
    if (abs(denom) < 0.01) { return float2(0.0); }
    float z = uv.y / denom;
    if (z <= 0.0 || z > kZLimit) { return float2(0.0); }
    float zRatio = z / kZLimit;
    float panelMap = 1.0 - zRatio;
    float x = uv.x * (cosA * z + 1.0) * invLength;
    float zOffset = zRatio - 0.5;
    float left = -0.5 + zOffset * uniforms.u_angle1;
    float right = 0.5 - zOffset * uniforms.u_angle2;
    float blurX = aa + 2.0 * panelMap * uniforms.u_blur;
    float leftEdge1 = left - blurX;
    float leftEdge2 = left + 0.25 * blurX;
    float rightEdge1 = right - 0.25 * blurX;
    float rightEdge2 = right + blurX;
    float panel = smoothstep(leftEdge1, leftEdge2, x) * (1.0 - smoothstep(rightEdge1, rightEdge2, x));
    panel *= mix(0.0, panel, smoothstep(0.0, 0.01 / max(uniforms.u_scale, 1e-6), panelMap));
    float midScreen = abs(sinA);
    if (uniforms.u_edges > 0.5) {
        panelMap = mix(0.99, panelMap, panel * clamp(panelMap / (0.15 * (1.0 - pow(midScreen, 0.1))), 0.0, 1.0));
    } else if (midScreen < 0.07) {
        panel *= (midScreen * 15.0);
    }
    return float2(panel, panelMap);
}

inline float4 blendColor(float4 colorA, float panelMask, float panelMap,
                         constant ColorPanelsUniforms &uniforms) {
    float fade = 1.0 - smoothstep(0.97 - 0.97 * uniforms.u_fadeIn, 1.0, panelMap);
    fade *= smoothstep(-0.2 * (1.0 - uniforms.u_fadeOut), uniforms.u_fadeOut, panelMap);
    float3 blendedRGB = mix(float3(0.0), colorA.rgb, fade);
    float blendedAlpha = mix(0.0, colorA.a, fade);
    return float4(blendedRGB, blendedAlpha) * panelMask;
}

fragment float4 color_panels_fragment(VertexOutput in [[stage_in]],
                                     constant ColorPanelsUniforms &uniforms [[buffer(0)]]) {
    float2 uv = in.objectUV;
    uv *= 1.25;
    float t = 0.02 * uniforms.u_time;
    t = fract(t);
    bool reverseTime = (t < 0.5);

    float3 color = float3(0.0);
    float opacity = 0.0;
    float aa = 0.005 / max(uniforms.u_scale, 1e-6);
    int colorsCount = int(uniforms.u_colorsCount);

    float4 premultipliedColors[kColorPanelsMaxColorCount];
    for (int i = 0; i < kColorPanelsMaxColorCount; i++) {
        if (i >= colorsCount) { break; }
        float4 c = uniforms.u_colors[i];
        c.rgb *= c.a;
        premultipliedColors[i] = c;
    }

    float invLength = 1.5 / max(uniforms.u_length, 0.001);
    int panelsNumber = 12;
    float densityNormalizer = 1.0;
    if (colorsCount == 4) {
        panelsNumber = 16;
        densityNormalizer = 1.34;
    } else if (colorsCount == 5) {
        panelsNumber = 20;
        densityNormalizer = 1.67;
    } else if (colorsCount == 7) {
        panelsNumber = 14;
        densityNormalizer = 1.17;
    }

    float fPanelsNumber = float(panelsNumber);
    float panelGrad = 1.0 - clamp(uniforms.u_gradient, 0.0, 1.0);

    for (int set = 0; set < 2; set++) {
        bool isForward = (set == 0 && !reverseTime) || (set == 1 && reverseTime);
        if (!isForward) { continue; }
        for (int i = 0; i <= 20; i++) {
            if (i >= panelsNumber) { break; }
            int idx = panelsNumber - 1 - i;
            float offset = float(idx) / fPanelsNumber;
            if (set == 1) { offset += 0.5; }
            float densityFract = densityNormalizer * fract(t + offset);
            float angleNorm = densityFract / uniforms.u_density;
            if (densityFract >= 0.5 || angleNorm >= 0.3) { continue; }
            float smoothDensity = clamp((0.5 - densityFract) / 0.1, 0.0, 1.0) * clamp(densityFract / 0.01, 0.0, 1.0);
            float smoothAngle = clamp((0.3 - angleNorm) / 0.05, 0.0, 1.0);
            if (smoothDensity * smoothAngle < 0.001) { continue; }
            if (angleNorm > 0.5) { angleNorm = 0.5; }
            float2 panel = getPanel(angleNorm * TWO_PI + PI, uv, invLength, aa, uniforms);
            if (panel.x <= 0.001) { continue; }
            float panelMask = panel.x * smoothDensity * smoothAngle;
            float panelMap = panel.y;
            int colorIdx = idx % colorsCount;
            int nextColorIdx = (idx + 1) % colorsCount;
            float4 colorA = premultipliedColors[colorIdx];
            float4 colorB = premultipliedColors[nextColorIdx];
            colorA = mix(colorA, colorB, max(0.0, smoothstep(0.0, 0.45, panelMap) - panelGrad));
            float4 blended = blendColor(colorA, panelMask, panelMap, uniforms);
            color = blended.rgb + color * (1.0 - blended.a);
            opacity = blended.a + opacity * (1.0 - blended.a);
        }

        for (int i = 0; i <= 20; i++) {
            if (i >= panelsNumber) { break; }
            int idx = panelsNumber - 1 - i;
            float offset = float(idx) / fPanelsNumber;
            if (set == 0) { offset += 0.5; }
            float densityFract = densityNormalizer * fract(-t + offset);
            float angleNorm = -densityFract / uniforms.u_density;
            if (densityFract >= 0.5 || angleNorm < -0.3) { continue; }
            float smoothDensity = clamp((0.5 - densityFract) / 0.1, 0.0, 1.0) * clamp(densityFract / 0.01, 0.0, 1.0);
            float smoothAngle = clamp((angleNorm + 0.3) / 0.05, 0.0, 1.0);
            if (smoothDensity * smoothAngle < 0.001) { continue; }
            float2 panel = getPanel(angleNorm * TWO_PI + PI, uv, invLength, aa, uniforms);
            float panelMask = panel.x * smoothDensity * smoothAngle;
            if (panelMask <= 0.001) { continue; }
            float panelMap = panel.y;
            int colorIdx = (colorsCount - (idx % colorsCount)) % colorsCount;
            int nextColorIdx = (colorIdx + 1) % colorsCount;
            float4 colorA = premultipliedColors[colorIdx];
            float4 colorB = premultipliedColors[nextColorIdx];
            colorA = mix(colorA, colorB, max(0.0, smoothstep(0.0, 0.45, panelMap) - panelGrad));
            float4 blended = blendColor(colorA, panelMask, panelMap, uniforms);
            color = blended.rgb + color * (1.0 - blended.a);
            opacity = blended.a + opacity * (1.0 - blended.a);
        }
    }

    float3 bgColor = uniforms.u_colorBack.rgb * uniforms.u_colorBack.a;
    color = color + bgColor * (1.0 - opacity);
    opacity = opacity + uniforms.u_colorBack.a * (1.0 - opacity);
    color = applyColorBandingFix(color, in.position.xy);
    return float4(color, opacity);
}
