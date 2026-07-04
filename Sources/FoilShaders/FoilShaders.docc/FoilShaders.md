# ``FoilShaders``

@Metadata {
  @DisplayName("Foil Shaders")
}

Metal-based SwiftUI ports of Paper Shaders for iOS and macOS.

## Overview

Foil Shaders provides SwiftUI views backed by Metal fragment shaders. Each shader can be created from a Paper-derived preset, from a typed `*Params` value, or from the flat SwiftUI initializer generated for that component.

The documentation includes rendered previews from the parity golden suite, practical value ranges mined from the Paper-derived presets, and units verified against the Metal sources. Numeric shader values are generally passed through to Metal; the documented ranges are the tested ranges used by presets unless a row notes shader-side clamping.

## Topics

### Getting Started

- <doc:GettingStarted>
- <doc:ParameterRanges>

### Shader Pages

- <doc:MeshGradientShader>
- <doc:SmokeRingShader>
- <doc:NeuroNoiseShader>
- <doc:DotOrbitShader>
- <doc:DotGridShader>
- <doc:SimplexNoiseShader>
- <doc:MetaballsShader>
- <doc:WavesShader>
- <doc:PerlinNoiseShader>
- <doc:VoronoiShader>
- <doc:WarpShader>
- <doc:GodRaysShader>
- <doc:SpiralShader>
- <doc:SwirlShader>
- <doc:DitheringShader>
- <doc:GrainGradientShader>
- <doc:PulsingBorderShader>
- <doc:ColorPanelsShader>
- <doc:StaticMeshGradientShader>
- <doc:StaticRadialGradientShader>
- <doc:PaperTextureShader>
- <doc:FlutedGlassShader>
- <doc:WaterShader>
- <doc:ImageDitheringShader>
- <doc:HeatmapShader>
- <doc:LiquidMetalShader>
- <doc:HalftoneDotsShader>
- <doc:HalftoneCmykShader>
- <doc:GemSmokeShader>

### Shader Views

- ``MeshGradient``
- ``SmokeRing``
- ``NeuroNoise``
- ``DotOrbit``
- ``DotGrid``
- ``SimplexNoise``
- ``Metaballs``
- ``Waves``
- ``PerlinNoise``
- ``Voronoi``
- ``Warp``
- ``GodRays``
- ``Spiral``
- ``Swirl``
- ``Dithering``
- ``GrainGradient``
- ``PulsingBorder``
- ``ColorPanels``
- ``StaticMeshGradient``
- ``StaticRadialGradient``
- ``PaperTexture``
- ``FlutedGlass``
- ``Water``
- ``ImageDithering``
- ``Heatmap``
- ``LiquidMetal``
- ``HalftoneDots``
- ``HalftoneCmyk``
- ``GemSmoke``

### Parameter Types

- ``MeshGradientParams``
- ``SmokeRingParams``
- ``NeuroNoiseParams``
- ``DotOrbitParams``
- ``DotGridParams``
- ``SimplexNoiseParams``
- ``MetaballsParams``
- ``WavesParams``
- ``PerlinNoiseParams``
- ``VoronoiParams``
- ``WarpParams``
- ``GodRaysParams``
- ``SpiralParams``
- ``SwirlParams``
- ``DitheringParams``
- ``GrainGradientParams``
- ``PulsingBorderParams``
- ``ColorPanelsParams``
- ``StaticMeshGradientParams``
- ``StaticRadialGradientParams``
- ``PaperTextureParams``
- ``FlutedGlassParams``
- ``WaterParams``
- ``ImageDitheringParams``
- ``HeatmapParams``
- ``LiquidMetalParams``
- ``HalftoneDotsParams``
- ``HalftoneCmykParams``
- ``GemSmokeParams``

### Shared Configuration

- ``ShaderColor``
- ``ShaderImage``
- ``ShaderSizingParams``
- ``ShaderMotionParams``
- ``ShaderRenderOptions``
- ``ShaderPreset``
- ``ShaderConfiguration``
