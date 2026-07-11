#ifndef FoilShadersShaderTypes_h
#define FoilShadersShaderTypes_h

#include <metal_stdlib>
using namespace metal;

// Shared types passed between the vertex stage (Vertex.metal) and every
// fragment shader. Each .metal file compiles as a standalone translation
// unit, so anything referenced across files must live in a header.


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

#endif /* FoilShadersShaderTypes_h */
