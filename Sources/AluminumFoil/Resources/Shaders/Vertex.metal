#include <metal_stdlib>
#include "Common.metal"

using namespace metal;

// MARK: - Vertex Shader Uniforms

struct VertexUniforms {
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

// MARK: - Vertex Input

struct VertexInput {
    float2 position [[attribute(0)]];
};

// MARK: - Vertex Output

struct VertexOutput {
    float4 position [[position]];
    float2 objectUV;
    float2 objectBoxSize;
    float2 responsiveUV;
    float2 responsiveBoxGivenSize;
    float2 patternUV;
    float2 patternBoxSize;
    float2 imageUV;
};

// MARK: - Helper Functions

float3 getBoxSize(float boxRatio, float2 givenBoxSize, float2 resolution, float fit) {
    float2 box = float2(0.0);
    // fit = none
    box.x = boxRatio * min(givenBoxSize.x / boxRatio, givenBoxSize.y);
    float noFitBoxWidth = box.x;
    if (fit == 1.0) { // fit = contain
        box.x = boxRatio * min(resolution.x / boxRatio, resolution.y);
    } else if (fit == 2.0) { // fit = cover
        box.x = boxRatio * max(resolution.x / boxRatio, resolution.y);
    }
    box.y = box.x / boxRatio;
    return float3(box, noFitBoxWidth);
}

// MARK: - Vertex Shader

vertex VertexOutput vertex_main(VertexInput in [[stage_in]],
                                constant VertexUniforms &uniforms [[buffer(1)]]) {
    VertexOutput out;
    
    // Position is already in NDC (-1 to 1), pass through
    out.position = float4(in.position, 0.0, 1.0);
    
    // Convert position to UV coordinates (matching GLSL: gl_Position.xy * 0.5)
    // This gives range [-0.5, 0.5] for a full-screen quad/triangle
    float2 uv = in.position * 0.5;
    
    float2 boxOrigin = float2(0.5 - uniforms.u_originX, uniforms.u_originY - 0.5);
    float2 givenBoxSize = float2(uniforms.u_worldWidth, uniforms.u_worldHeight);
    givenBoxSize = max(givenBoxSize, float2(1.0)) * uniforms.u_pixelRatio;
    float r = uniforms.u_rotation * PI / 180.0;
    float2x2 graphicRotation = float2x2(cos(r), sin(r), -sin(r), cos(r));
    float2 graphicOffset = float2(-uniforms.u_offsetX, uniforms.u_offsetY);
    
    // ===================================================
    // Object UV
    // ===================================================
    
    float fixedRatio = 1.0;
    float2 fixedRatioBoxGivenSize = float2(
        (uniforms.u_worldWidth == 0.0) ? uniforms.u_resolution.x : givenBoxSize.x,
        (uniforms.u_worldHeight == 0.0) ? uniforms.u_resolution.y : givenBoxSize.y
    );
    
    float3 objectBoxSizeData = getBoxSize(fixedRatio, fixedRatioBoxGivenSize, uniforms.u_resolution, uniforms.u_fit);
    out.objectBoxSize = objectBoxSizeData.xy;
    float2 objectWorldScale = uniforms.u_resolution / out.objectBoxSize;
    
    out.objectUV = uv; // uv is already in [-0.5, 0.5] range (matching GLSL gl_Position.xy * 0.5)
    out.objectUV *= objectWorldScale;
    out.objectUV += boxOrigin * (objectWorldScale - 1.0);
    out.objectUV += graphicOffset;
    out.objectUV /= uniforms.u_scale;
    out.objectUV = graphicRotation * out.objectUV;
    
    // ===================================================
    // Responsive UV
    // ===================================================
    
    out.responsiveBoxGivenSize = float2(
        (uniforms.u_worldWidth == 0.0) ? uniforms.u_resolution.x : givenBoxSize.x,
        (uniforms.u_worldHeight == 0.0) ? uniforms.u_resolution.y : givenBoxSize.y
    );
    float responsiveRatio = out.responsiveBoxGivenSize.x / out.responsiveBoxGivenSize.y;
    float2 responsiveBoxSize = getBoxSize(responsiveRatio, out.responsiveBoxGivenSize, uniforms.u_resolution, uniforms.u_fit).xy;
    float2 responsiveBoxScale = uniforms.u_resolution / responsiveBoxSize;
    
    out.responsiveUV = uv; // uv is already in [-0.5, 0.5] range
    out.responsiveUV *= responsiveBoxScale;
    out.responsiveUV += boxOrigin * (responsiveBoxScale - 1.0);
    out.responsiveUV += graphicOffset;
    out.responsiveUV /= uniforms.u_scale;
    out.responsiveUV.x *= responsiveRatio;
    out.responsiveUV = graphicRotation * out.responsiveUV;
    out.responsiveUV.x /= responsiveRatio;
    
    // ===================================================
    // Pattern UV
    // ===================================================
    
    float patternBoxRatio = givenBoxSize.x / givenBoxSize.y;
    float2 patternBoxGivenSize = float2(
        (uniforms.u_worldWidth == 0.0) ? uniforms.u_resolution.x : givenBoxSize.x,
        (uniforms.u_worldHeight == 0.0) ? uniforms.u_resolution.y : givenBoxSize.y
    );
    patternBoxRatio = patternBoxGivenSize.x / patternBoxGivenSize.y;
    
    float3 patternBoxSizeData = getBoxSize(patternBoxRatio, patternBoxGivenSize, uniforms.u_resolution, uniforms.u_fit);
    out.patternBoxSize = patternBoxSizeData.xy;
    float patternBoxNoFitBoxWidth = patternBoxSizeData.z;
    float2 patternBoxScale = uniforms.u_resolution / out.patternBoxSize;
    
    out.patternUV = uv; // uv is already in [-0.5, 0.5] range
    out.patternUV += graphicOffset / patternBoxScale;
    out.patternUV += boxOrigin;
    out.patternUV -= boxOrigin / patternBoxScale;
    out.patternUV *= uniforms.u_resolution;
    out.patternUV /= uniforms.u_pixelRatio;
    if (uniforms.u_fit > 0.0) {
        out.patternUV *= (patternBoxNoFitBoxWidth / out.patternBoxSize.x);
    }
    out.patternUV /= uniforms.u_scale;
    out.patternUV = graphicRotation * out.patternUV;
    out.patternUV += boxOrigin / patternBoxScale;
    out.patternUV -= boxOrigin;
    // x100 is a default multiplier between vertex and fragment shaders
    // we use it to avoid UV precision issues
    out.patternUV *= 0.01;
    
    // ===================================================
    // Image UV
    // ===================================================
    
    float2 imageBoxSize;
    if (uniforms.u_fit == 1.0) { // contain
        imageBoxSize.x = min(uniforms.u_resolution.x / uniforms.u_imageAspectRatio, uniforms.u_resolution.y) * uniforms.u_imageAspectRatio;
    } else if (uniforms.u_fit == 2.0) { // cover
        imageBoxSize.x = max(uniforms.u_resolution.x / uniforms.u_imageAspectRatio, uniforms.u_resolution.y) * uniforms.u_imageAspectRatio;
    } else {
        imageBoxSize.x = min(10.0, 10.0 / uniforms.u_imageAspectRatio * uniforms.u_imageAspectRatio);
    }
    imageBoxSize.y = imageBoxSize.x / uniforms.u_imageAspectRatio;
    float2 imageBoxScale = uniforms.u_resolution / imageBoxSize;
    
    out.imageUV = uv; // uv is already in [-0.5, 0.5] range
    out.imageUV *= imageBoxScale;
    out.imageUV += boxOrigin * (imageBoxScale - 1.0);
    out.imageUV += graphicOffset;
    out.imageUV /= uniforms.u_scale;
    out.imageUV.x *= uniforms.u_imageAspectRatio;
    out.imageUV = graphicRotation * out.imageUV;
    out.imageUV.x /= uniforms.u_imageAspectRatio;
    
    out.imageUV += 0.5;
    out.imageUV.y = 1.0 - out.imageUV.y;
    
    return out;
}
