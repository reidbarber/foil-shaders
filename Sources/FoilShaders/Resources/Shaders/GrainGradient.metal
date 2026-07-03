#include <metal_stdlib>
#include "Common.metal"

using namespace metal;

constant int kGrainGradientMaxColorCount = 7;

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

struct GrainGradientUniforms {
    float u_time;
    float4 u_colorBack;
    float4 u_colors[kGrainGradientMaxColorCount];
    float u_colorsCount;
    float u_softness;
    float u_intensity;
    float u_noise;
    float u_shape;
};

inline float randomR(texture2d<float> noiseTexture, float2 p) {
    float2 uv = floor(p) / 100.0 + 0.5;
    return noiseTexture.sample(linearSampler, fract(uv)).r;
}

inline float valueNoiseR(float2 st, texture2d<float> noiseTexture) {
    float2 i = floor(st);
    float2 f = fract(st);
    float a = randomR(noiseTexture, i);
    float b = randomR(noiseTexture, i + float2(1.0, 0.0));
    float c = randomR(noiseTexture, i + float2(0.0, 1.0));
    float d = randomR(noiseTexture, i + float2(1.0, 1.0));
    float2 u = f * f * (3.0 - 2.0 * f);
    float x1 = mix(a, b, u.x);
    float x2 = mix(c, d, u.x);
    return mix(x1, x2, u.y);
}

inline float4 fbmR(float2 n0, float2 n1, float2 n2, float2 n3, texture2d<float> noiseTexture) {
    float amplitude = 0.2;
    float4 total = float4(0.0);
    for (int i = 0; i < 3; i++) {
        n0 = rotate(n0, 0.3);
        n1 = rotate(n1, 0.3);
        n2 = rotate(n2, 0.3);
        n3 = rotate(n3, 0.3);
        total.x += valueNoiseR(n0, noiseTexture) * amplitude;
        total.y += valueNoiseR(n1, noiseTexture) * amplitude;
        total.z += valueNoiseR(n2, noiseTexture) * amplitude;
        total.z += valueNoiseR(n3, noiseTexture) * amplitude;
        n0 *= 1.99;
        n1 *= 1.99;
        n2 *= 1.99;
        n3 *= 1.99;
        amplitude *= 0.6;
    }
    return total;
}

inline float2 truchet(float2 uv, float idx) {
    idx = fract(((idx - 0.5) * 2.0));
    if (idx > 0.75) {
        uv = float2(1.0) - uv;
    } else if (idx > 0.5) {
        uv = float2(1.0 - uv.x, uv.y);
    } else if (idx > 0.25) {
        uv = 1.0 - float2(1.0 - uv.x, uv.y);
    }
    return uv;
}

inline float blobReferenceClamp(float x) {
    return max(min(0.0, x), 1.0);
}

fragment float4 grain_gradient_fragment(VertexOutput in [[stage_in]],
                                       constant GrainGradientUniforms &uniforms [[buffer(0)]],
                                       constant FragmentVertexUniforms &vertexUniforms [[buffer(1)]],
                                       texture2d<float> noiseTexture [[texture(1)]]) {
    float t = 0.1 * (uniforms.u_time + 7.0);
    float2 shape_uv = float2(0.0);
    float2 grain_uv = float2(0.0);
    float r = vertexUniforms.u_rotation * PI / 180.0;
    float cr = cos(r);
    float sr = sin(r);
    float2x2 graphicRotation = float2x2(cr, sr, -sr, cr);
    float2 graphicOffset = float2(-vertexUniforms.u_offsetX, vertexUniforms.u_offsetY);

    if (uniforms.u_shape > 3.5) {
        shape_uv = in.objectUV;
        grain_uv = shape_uv;
        float2x2 invRotation = transpose(graphicRotation);
        grain_uv = invRotation * grain_uv;
        grain_uv *= vertexUniforms.u_scale;
        grain_uv -= graphicOffset;
        grain_uv *= in.objectBoxSize;
        grain_uv *= 0.7;
    } else {
        shape_uv = 0.5 * in.patternUV;
        grain_uv = 100.0 * in.patternUV;
        float2x2 invRotation = transpose(graphicRotation);
        grain_uv = invRotation * grain_uv;
        grain_uv *= vertexUniforms.u_scale;
        if (vertexUniforms.u_fit > 0.0) {
            float2 givenBoxSize = float2(vertexUniforms.u_worldWidth, vertexUniforms.u_worldHeight);
            givenBoxSize = max(givenBoxSize, float2(1.0)) * vertexUniforms.u_pixelRatio;
            float patternBoxRatio = givenBoxSize.x / givenBoxSize.y;
            float2 patternBoxGivenSize = float2(
                (vertexUniforms.u_worldWidth == 0.0) ? vertexUniforms.u_resolution.x : givenBoxSize.x,
                (vertexUniforms.u_worldHeight == 0.0) ? vertexUniforms.u_resolution.y : givenBoxSize.y
            );
            patternBoxRatio = patternBoxGivenSize.x / patternBoxGivenSize.y;
            float patternBoxNoFitBoxWidth = patternBoxRatio * min(patternBoxGivenSize.x / patternBoxRatio, patternBoxGivenSize.y);
            grain_uv /= (patternBoxNoFitBoxWidth / in.patternBoxSize.x);
        }
        float2 patternBoxScale = vertexUniforms.u_resolution / in.patternBoxSize;
        grain_uv -= graphicOffset / patternBoxScale;
        grain_uv *= 1.6;
    }

    float shape = 0.0;
    if (uniforms.u_shape < 1.5) {
        float wave = cos(0.5 * shape_uv.x - 4.0 * t) * sin(1.5 * shape_uv.x + 2.0 * t) * (0.75 + 0.25 * cos(6.0 * t));
        shape = 1.0 - smoothstep(-1.0, 1.0, shape_uv.y + wave);
    } else if (uniforms.u_shape < 2.5) {
        float stripeIdx = floor(2.0 * shape_uv.x / TWO_PI);
        float rand = hash11(stripeIdx * 100.0);
        rand = sign(rand - 0.5) * pow(4.0 * abs(rand), 0.3);
        shape = sin(shape_uv.x) * cos(shape_uv.y - 5.0 * rand * t);
        shape = pow(abs(shape), 4.0);
    } else if (uniforms.u_shape < 3.5) {
        float n2 = valueNoiseR(shape_uv * 0.4 - 3.75 * t, noiseTexture);
        shape_uv.x += 10.0;
        shape_uv *= 0.6;
        float2 tile = truchet(fract(shape_uv), randomR(noiseTexture, floor(shape_uv)));
        float distance1 = length(tile);
        float distance2 = length(tile - float2(1.0));
        n2 -= 0.5;
        n2 *= 0.1;
        shape = smoothstep(0.2, 0.55, distance1 + n2) * (1.0 - smoothstep(0.45, 0.8, distance1 - n2));
        shape += smoothstep(0.2, 0.55, distance2 + n2) * (1.0 - smoothstep(0.45, 0.8, distance2 - n2));
        shape = pow(shape, 1.5);
    } else if (uniforms.u_shape < 4.5) {
        shape_uv *= 0.6;
        float2 outer = float2(0.5);
        float2 bl = smoothstep(float2(0.0), outer, shape_uv + float2(0.1 + 0.1 * sin(3.0 * t), 0.2 - 0.1 * sin(5.25 * t)));
        float2 tr = smoothstep(float2(0.0), outer, 1.0 - shape_uv);
        shape = 1.0 - bl.x * bl.y * tr.x * tr.y;
        shape_uv = -shape_uv;
        bl = smoothstep(float2(0.0), outer, shape_uv + float2(0.1 + 0.1 * sin(3.0 * t), 0.2 - 0.1 * cos(5.25 * t)));
        tr = smoothstep(float2(0.0), outer, 1.0 - shape_uv);
        shape -= bl.x * bl.y * tr.x * tr.y;
        shape = 1.0 - smoothstep(0.0, 1.0, shape);
    } else if (uniforms.u_shape < 5.5) {
        shape_uv *= 2.0;
        float dist = length(0.4 * shape_uv);
        float waves = sin(pow(dist, 1.2) * 5.0 - 3.0 * t) * 0.5 + 0.5;
        shape = waves;
    } else if (uniforms.u_shape < 6.5) {
        t *= 2.0;
        float2 f1_traj = 0.25 * float2(1.3 * sin(t), 0.2 + 1.3 * cos(0.6 * t + 4.0));
        float2 f2_traj = 0.2 * float2(1.2 * sin(-t), 1.3 * sin(1.6 * t));
        float2 f3_traj = 0.25 * float2(1.7 * cos(-0.6 * t), cos(-1.6 * t));
        float2 f4_traj = 0.3 * float2(1.4 * cos(0.8 * t), 1.2 * sin(-0.6 * t - 3.0));
        shape = 0.5 * pow(1.0 - blobReferenceClamp(length(shape_uv + f1_traj)), 5.0);
        shape += 0.5 * pow(1.0 - blobReferenceClamp(length(shape_uv + f2_traj)), 5.0);
        shape += 0.5 * pow(1.0 - blobReferenceClamp(length(shape_uv + f3_traj)), 5.0);
        shape += 0.5 * pow(1.0 - blobReferenceClamp(length(shape_uv + f4_traj)), 5.0);
        shape = smoothstep(0.0, 0.9, shape);
        float edge = smoothstep(0.25, 0.3, shape);
        shape = mix(0.0, shape, edge);
    } else {
        shape_uv *= 2.0;
        float d = 1.0 - pow(length(shape_uv), 2.0);
        float3 pos = float3(shape_uv, sqrt(max(d, 0.0)));
        float3 lightPos = normalize(float3(cos(1.5 * t), 0.8, sin(1.25 * t)));
        shape = 0.5 + 0.5 * dot(lightPos, pos);
        shape *= step(0.0, d);
    }

    float baseNoise = snoise(grain_uv * 0.5);
    float4 fbmVals = fbmR(
        0.002 * grain_uv + 10.0,
        0.003 * grain_uv,
        0.001 * grain_uv,
        rotate(0.4 * grain_uv, 2.0),
        noiseTexture
    );
    float grainDist = baseNoise * snoise(grain_uv * 0.2) - fbmVals.x - fbmVals.y;
    float rawNoise = 0.75 * baseNoise - fbmVals.w - fbmVals.z;
    float noise = clamp(rawNoise, 0.0, 1.0);

    shape += uniforms.u_intensity * 2.0 / uniforms.u_colorsCount * (grainDist + 0.5);
    shape += uniforms.u_noise * 10.0 / uniforms.u_colorsCount * noise;

    float aa = fwidth(shape);
    shape = clamp(shape - 0.5 / uniforms.u_colorsCount, 0.0, 1.0);
    float totalShape = smoothstep(0.0, uniforms.u_softness + 2.0 * aa,
                                  clamp(shape * uniforms.u_colorsCount, 0.0, 1.0));
    float mixer = shape * (uniforms.u_colorsCount - 1.0);
    int cntStop = int(uniforms.u_colorsCount) - 1;
    float4 gradient = uniforms.u_colors[0];
    gradient.rgb *= gradient.a;
    for (int i = 1; i < kGrainGradientMaxColorCount; i++) {
        if (i > cntStop) { break; }
        float localT = clamp(mixer - float(i - 1), 0.0, 1.0);
        localT = smoothstep(0.5 - 0.5 * uniforms.u_softness - aa,
                            0.5 + 0.5 * uniforms.u_softness + aa,
                            localT);
        float4 c = uniforms.u_colors[i];
        c.rgb *= c.a;
        gradient = mix(gradient, c, localT);
    }

    float3 color = gradient.rgb * totalShape;
    float opacity = gradient.a * totalShape;
    float3 bgColor = uniforms.u_colorBack.rgb * uniforms.u_colorBack.a;
    color = color + bgColor * (1.0 - opacity);
    opacity = opacity + uniforms.u_colorBack.a * (1.0 - opacity);
    return float4(color, opacity);
}
