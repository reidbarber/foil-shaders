import SwiftUI

@MainActor
private func shaderBody(_ configuration: ShaderConfiguration) -> some SwiftUI.View {
  FoilShadersShaderView(configuration: configuration)
}

/// A SwiftUI view that renders the animated Mesh Gradient shader.
///
/// Named `AnimatedMeshGradient` to avoid colliding with SwiftUI's `MeshGradient`.
/// It pairs with ``StaticMeshGradient``.
///
/// See <doc:MeshGradientShader> for usage examples, previews, and parameter ranges.
public struct AnimatedMeshGradient: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = meshGradientPresets

  public init(_ preset: MeshGradientPreset = MeshGradientPreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }

  public init(
    params: MeshGradientParams,
    sizing: ShaderSizingParams = MeshGradientPreset.default.sizing,
    motion: ShaderMotionParams = MeshGradientPreset.default.motion,
    renderOptions: ShaderRenderOptions = MeshGradientPreset.default.renderOptions,
    image: ShaderImage? = MeshGradientPreset.default.image
  ) {
    configuration = ShaderConfiguration(
      parameters: .meshGradient(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }

  public var body: some SwiftUI.View { shaderBody(configuration) }
}

/// A SwiftUI view that renders the Smoke Ring shader.
///
/// See <doc:SmokeRingShader> for usage examples, previews, and parameter ranges.
public struct SmokeRing: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = smokeRingPresets
  public init(_ preset: SmokeRingPreset = SmokeRingPreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: SmokeRingParams,
    sizing: ShaderSizingParams = SmokeRingPreset.default.sizing,
    motion: ShaderMotionParams = SmokeRingPreset.default.motion,
    renderOptions: ShaderRenderOptions = SmokeRingPreset.default.renderOptions,
    image: ShaderImage? = SmokeRingPreset.default.image
  ) {
    configuration = ShaderConfiguration(
      parameters: .smokeRing(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

/// A SwiftUI view that renders the Neuro Noise shader.
///
/// See <doc:NeuroNoiseShader> for usage examples, previews, and parameter ranges.
public struct NeuroNoise: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = neuroNoisePresets
  public init(_ preset: NeuroNoisePreset = NeuroNoisePreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: NeuroNoiseParams,
    sizing: ShaderSizingParams = NeuroNoisePreset.default.sizing,
    motion: ShaderMotionParams = NeuroNoisePreset.default.motion,
    renderOptions: ShaderRenderOptions = NeuroNoisePreset.default.renderOptions,
    image: ShaderImage? = NeuroNoisePreset.default.image
  ) {
    configuration = ShaderConfiguration(
      parameters: .neuroNoise(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

/// A SwiftUI view that renders the Dot Orbit shader.
///
/// See <doc:DotOrbitShader> for usage examples, previews, and parameter ranges.
public struct DotOrbit: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = dotOrbitPresets
  public init(_ preset: DotOrbitPreset = DotOrbitPreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: DotOrbitParams,
    sizing: ShaderSizingParams = DotOrbitPreset.default.sizing,
    motion: ShaderMotionParams = DotOrbitPreset.default.motion,
    renderOptions: ShaderRenderOptions = DotOrbitPreset.default.renderOptions,
    image: ShaderImage? = DotOrbitPreset.default.image
  ) {
    configuration = ShaderConfiguration(
      parameters: .dotOrbit(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

/// A SwiftUI view that renders the Dot Grid shader.
///
/// See <doc:DotGridShader> for usage examples, previews, and parameter ranges.
public struct DotGrid: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = dotGridPresets
  public init(_ preset: DotGridPreset = DotGridPreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: DotGridParams,
    sizing: ShaderSizingParams = DotGridPreset.default.sizing,
    motion: ShaderMotionParams = DotGridPreset.default.motion,
    renderOptions: ShaderRenderOptions = DotGridPreset.default.renderOptions,
    image: ShaderImage? = DotGridPreset.default.image
  ) {
    configuration = ShaderConfiguration(
      parameters: .dotGrid(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

/// A SwiftUI view that renders the Simplex Noise shader.
///
/// See <doc:SimplexNoiseShader> for usage examples, previews, and parameter ranges.
public struct SimplexNoise: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = simplexNoisePresets
  public init(_ preset: SimplexNoisePreset = SimplexNoisePreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: SimplexNoiseParams,
    sizing: ShaderSizingParams = SimplexNoisePreset.default.sizing,
    motion: ShaderMotionParams = SimplexNoisePreset.default.motion,
    renderOptions: ShaderRenderOptions = SimplexNoisePreset.default.renderOptions,
    image: ShaderImage? = SimplexNoisePreset.default.image
  ) {
    configuration = ShaderConfiguration(
      parameters: .simplexNoise(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

/// A SwiftUI view that renders the Metaballs shader.
///
/// See <doc:MetaballsShader> for usage examples, previews, and parameter ranges.
public struct Metaballs: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = metaballsPresets
  public init(_ preset: MetaballsPreset = MetaballsPreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: MetaballsParams,
    sizing: ShaderSizingParams = MetaballsPreset.default.sizing,
    motion: ShaderMotionParams = MetaballsPreset.default.motion,
    renderOptions: ShaderRenderOptions = MetaballsPreset.default.renderOptions,
    image: ShaderImage? = MetaballsPreset.default.image
  ) {
    configuration = ShaderConfiguration(
      parameters: .metaballs(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

/// A SwiftUI view that renders the Waves shader.
///
/// See <doc:WavesShader> for usage examples, previews, and parameter ranges.
public struct Waves: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = wavesPresets
  public init(_ preset: WavesPreset = WavesPreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: WavesParams,
    sizing: ShaderSizingParams = WavesPreset.default.sizing,
    motion: ShaderMotionParams = WavesPreset.default.motion,
    renderOptions: ShaderRenderOptions = WavesPreset.default.renderOptions,
    image: ShaderImage? = WavesPreset.default.image
  ) {
    configuration = ShaderConfiguration(
      parameters: .waves(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

/// A SwiftUI view that renders the Perlin Noise shader.
///
/// See <doc:PerlinNoiseShader> for usage examples, previews, and parameter ranges.
public struct PerlinNoise: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = perlinNoisePresets
  public init(_ preset: PerlinNoisePreset = PerlinNoisePreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: PerlinNoiseParams,
    sizing: ShaderSizingParams = PerlinNoisePreset.default.sizing,
    motion: ShaderMotionParams = PerlinNoisePreset.default.motion,
    renderOptions: ShaderRenderOptions = PerlinNoisePreset.default.renderOptions,
    image: ShaderImage? = PerlinNoisePreset.default.image
  ) {
    configuration = ShaderConfiguration(
      parameters: .perlinNoise(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

/// A SwiftUI view that renders the Voronoi shader.
///
/// See <doc:VoronoiShader> for usage examples, previews, and parameter ranges.
public struct Voronoi: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = voronoiPresets
  public init(_ preset: VoronoiPreset = VoronoiPreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: VoronoiParams,
    sizing: ShaderSizingParams = VoronoiPreset.default.sizing,
    motion: ShaderMotionParams = VoronoiPreset.default.motion,
    renderOptions: ShaderRenderOptions = VoronoiPreset.default.renderOptions,
    image: ShaderImage? = VoronoiPreset.default.image
  ) {
    configuration = ShaderConfiguration(
      parameters: .voronoi(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

/// A SwiftUI view that renders the Warp shader.
///
/// See <doc:WarpShader> for usage examples, previews, and parameter ranges.
public struct Warp: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = warpPresets
  public init(_ preset: WarpPreset = WarpPreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: WarpParams,
    sizing: ShaderSizingParams = WarpPreset.default.sizing,
    motion: ShaderMotionParams = WarpPreset.default.motion,
    renderOptions: ShaderRenderOptions = WarpPreset.default.renderOptions,
    image: ShaderImage? = WarpPreset.default.image
  ) {
    configuration = ShaderConfiguration(
      parameters: .warp(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

/// A SwiftUI view that renders the God Rays shader.
///
/// See <doc:GodRaysShader> for usage examples, previews, and parameter ranges.
public struct GodRays: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = godRaysPresets
  public init(_ preset: GodRaysPreset = GodRaysPreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: GodRaysParams,
    sizing: ShaderSizingParams = GodRaysPreset.default.sizing,
    motion: ShaderMotionParams = GodRaysPreset.default.motion,
    renderOptions: ShaderRenderOptions = GodRaysPreset.default.renderOptions,
    image: ShaderImage? = GodRaysPreset.default.image
  ) {
    configuration = ShaderConfiguration(
      parameters: .godRays(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

/// A SwiftUI view that renders the Spiral shader.
///
/// See <doc:SpiralShader> for usage examples, previews, and parameter ranges.
public struct Spiral: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = spiralPresets
  public init(_ preset: SpiralPreset = SpiralPreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: SpiralParams,
    sizing: ShaderSizingParams = SpiralPreset.default.sizing,
    motion: ShaderMotionParams = SpiralPreset.default.motion,
    renderOptions: ShaderRenderOptions = SpiralPreset.default.renderOptions,
    image: ShaderImage? = SpiralPreset.default.image
  ) {
    configuration = ShaderConfiguration(
      parameters: .spiral(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

/// A SwiftUI view that renders the Swirl shader.
///
/// See <doc:SwirlShader> for usage examples, previews, and parameter ranges.
public struct Swirl: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = swirlPresets
  public init(_ preset: SwirlPreset = SwirlPreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: SwirlParams,
    sizing: ShaderSizingParams = SwirlPreset.default.sizing,
    motion: ShaderMotionParams = SwirlPreset.default.motion,
    renderOptions: ShaderRenderOptions = SwirlPreset.default.renderOptions,
    image: ShaderImage? = SwirlPreset.default.image
  ) {
    configuration = ShaderConfiguration(
      parameters: .swirl(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

/// A SwiftUI view that renders the procedural Dithering shader.
///
/// See <doc:DitheringShader> for usage examples, previews, and parameter ranges.
public struct Dithering: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = ditheringPresets
  public init(_ preset: DitheringPreset = DitheringPreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: DitheringParams,
    sizing: ShaderSizingParams = DitheringPreset.default.sizing,
    motion: ShaderMotionParams = DitheringPreset.default.motion,
    renderOptions: ShaderRenderOptions = DitheringPreset.default.renderOptions,
    image: ShaderImage? = DitheringPreset.default.image
  ) {
    configuration = ShaderConfiguration(
      parameters: .dithering(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

/// A SwiftUI view that renders the Grain Gradient shader.
///
/// See <doc:GrainGradientShader> for usage examples, previews, and parameter ranges.
public struct GrainGradient: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = grainGradientPresets
  public init(_ preset: GrainGradientPreset = GrainGradientPreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: GrainGradientParams,
    sizing: ShaderSizingParams = GrainGradientPreset.default.sizing,
    motion: ShaderMotionParams = GrainGradientPreset.default.motion,
    renderOptions: ShaderRenderOptions = GrainGradientPreset.default.renderOptions,
    image: ShaderImage? = GrainGradientPreset.default.image
  ) {
    configuration = ShaderConfiguration(
      parameters: .grainGradient(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

/// A SwiftUI view that renders the Pulsing Border shader.
///
/// See <doc:PulsingBorderShader> for usage examples, previews, and parameter ranges.
public struct PulsingBorder: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = pulsingBorderPresets
  public init(_ preset: PulsingBorderPreset = PulsingBorderPreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: PulsingBorderParams,
    sizing: ShaderSizingParams = PulsingBorderPreset.default.sizing,
    motion: ShaderMotionParams = PulsingBorderPreset.default.motion,
    renderOptions: ShaderRenderOptions = PulsingBorderPreset.default.renderOptions,
    image: ShaderImage? = PulsingBorderPreset.default.image
  ) {
    configuration = ShaderConfiguration(
      parameters: .pulsingBorder(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

/// A SwiftUI view that renders the Color Panels shader.
///
/// See <doc:ColorPanelsShader> for usage examples, previews, and parameter ranges.
public struct ColorPanels: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = colorPanelsPresets
  public init(_ preset: ColorPanelsPreset = ColorPanelsPreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: ColorPanelsParams,
    sizing: ShaderSizingParams = ColorPanelsPreset.default.sizing,
    motion: ShaderMotionParams = ColorPanelsPreset.default.motion,
    renderOptions: ShaderRenderOptions = ColorPanelsPreset.default.renderOptions,
    image: ShaderImage? = ColorPanelsPreset.default.image
  ) {
    configuration = ShaderConfiguration(
      parameters: .colorPanels(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

/// A SwiftUI view that renders the static Mesh Gradient shader.
///
/// See <doc:StaticMeshGradientShader> for usage examples, previews, and parameter ranges.
public struct StaticMeshGradient: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = staticMeshGradientPresets
  public init(_ preset: StaticMeshGradientPreset = StaticMeshGradientPreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: StaticMeshGradientParams,
    sizing: ShaderSizingParams = StaticMeshGradientPreset.default.sizing,
    motion: ShaderMotionParams = StaticMeshGradientPreset.default.motion,
    renderOptions: ShaderRenderOptions = StaticMeshGradientPreset.default.renderOptions,
    image: ShaderImage? = StaticMeshGradientPreset.default.image
  ) {
    configuration = ShaderConfiguration(
      parameters: .staticMeshGradient(params), sizing: sizing,
      motion: motion, renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

/// A SwiftUI view that renders the Static Radial Gradient shader.
///
/// See <doc:StaticRadialGradientShader> for usage examples, previews, and parameter ranges.
public struct StaticRadialGradient: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = staticRadialGradientPresets
  public init(_ preset: StaticRadialGradientPreset = StaticRadialGradientPreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: StaticRadialGradientParams,
    sizing: ShaderSizingParams = StaticRadialGradientPreset.default.sizing,
    motion: ShaderMotionParams = StaticRadialGradientPreset.default.motion,
    renderOptions: ShaderRenderOptions = StaticRadialGradientPreset.default.renderOptions,
    image: ShaderImage? = StaticRadialGradientPreset.default.image
  ) {
    configuration = ShaderConfiguration(
      parameters: .staticRadialGradient(params), sizing: sizing,
      motion: motion, renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

/// A SwiftUI view that renders the Paper Texture shader.
///
/// See <doc:PaperTextureShader> for usage examples, previews, and parameter ranges.
public struct PaperTexture: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = paperTexturePresets
  public init(_ preset: PaperTexturePreset = PaperTexturePreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: PaperTextureParams,
    sizing: ShaderSizingParams = PaperTexturePreset.default.sizing,
    motion: ShaderMotionParams = PaperTexturePreset.default.motion,
    renderOptions: ShaderRenderOptions = PaperTexturePreset.default.renderOptions,
    image: ShaderImage? = PaperTexturePreset.default.image
  ) {
    configuration = ShaderConfiguration(
      parameters: .paperTexture(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

/// A SwiftUI view that renders the Fluted Glass shader.
///
/// See <doc:FlutedGlassShader> for usage examples, previews, and parameter ranges.
public struct FlutedGlass: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = flutedGlassPresets
  public init(_ preset: FlutedGlassPreset = FlutedGlassPreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: FlutedGlassParams,
    sizing: ShaderSizingParams = FlutedGlassPreset.default.sizing,
    motion: ShaderMotionParams = FlutedGlassPreset.default.motion,
    renderOptions: ShaderRenderOptions = FlutedGlassPreset.default.renderOptions,
    image: ShaderImage? = FlutedGlassPreset.default.image
  ) {
    configuration = ShaderConfiguration(
      parameters: .flutedGlass(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

/// A SwiftUI view that renders the Water shader.
///
/// See <doc:WaterShader> for usage examples, previews, and parameter ranges.
public struct Water: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = waterPresets
  public init(_ preset: WaterPreset = WaterPreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: WaterParams,
    sizing: ShaderSizingParams = WaterPreset.default.sizing,
    motion: ShaderMotionParams = WaterPreset.default.motion,
    renderOptions: ShaderRenderOptions = WaterPreset.default.renderOptions,
    image: ShaderImage? = WaterPreset.default.image
  ) {
    configuration = ShaderConfiguration(
      parameters: .water(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

/// A SwiftUI view that renders the image-based Dithering shader.
///
/// See <doc:ImageDitheringShader> for usage examples, previews, and parameter ranges.
public struct ImageDithering: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = imageDitheringPresets
  public init(_ preset: ImageDitheringPreset = ImageDitheringPreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: ImageDitheringParams,
    sizing: ShaderSizingParams = ImageDitheringPreset.default.sizing,
    motion: ShaderMotionParams = ImageDitheringPreset.default.motion,
    renderOptions: ShaderRenderOptions = ImageDitheringPreset.default.renderOptions,
    image: ShaderImage? = ImageDitheringPreset.default.image
  ) {
    configuration = ShaderConfiguration(
      parameters: .imageDithering(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

/// A SwiftUI view that renders the Heatmap shader.
///
/// See <doc:HeatmapShader> for usage examples, previews, and parameter ranges.
public struct Heatmap: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = heatmapPresets
  public init(_ preset: HeatmapPreset = HeatmapPreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: HeatmapParams,
    sizing: ShaderSizingParams = HeatmapPreset.default.sizing,
    motion: ShaderMotionParams = HeatmapPreset.default.motion,
    renderOptions: ShaderRenderOptions = HeatmapPreset.default.renderOptions,
    image: ShaderImage? = HeatmapPreset.default.image
  ) {
    configuration = ShaderConfiguration(
      parameters: .heatmap(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

/// A SwiftUI view that renders the Liquid Metal shader.
///
/// See <doc:LiquidMetalShader> for usage examples, previews, and parameter ranges.
public struct LiquidMetal: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = liquidMetalPresets
  public init(_ preset: LiquidMetalPreset = LiquidMetalPreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: LiquidMetalParams,
    sizing: ShaderSizingParams = LiquidMetalPreset.default.sizing,
    motion: ShaderMotionParams = LiquidMetalPreset.default.motion,
    renderOptions: ShaderRenderOptions = LiquidMetalPreset.default.renderOptions,
    image: ShaderImage? = LiquidMetalPreset.default.image
  ) {
    configuration = ShaderConfiguration(
      parameters: .liquidMetal(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

/// A SwiftUI view that renders the Halftone Dots shader.
///
/// See <doc:HalftoneDotsShader> for usage examples, previews, and parameter ranges.
public struct HalftoneDots: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = halftoneDotsPresets
  public init(_ preset: HalftoneDotsPreset = HalftoneDotsPreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: HalftoneDotsParams,
    sizing: ShaderSizingParams = HalftoneDotsPreset.default.sizing,
    motion: ShaderMotionParams = HalftoneDotsPreset.default.motion,
    renderOptions: ShaderRenderOptions = HalftoneDotsPreset.default.renderOptions,
    image: ShaderImage? = HalftoneDotsPreset.default.image
  ) {
    configuration = ShaderConfiguration(
      parameters: .halftoneDots(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

/// A SwiftUI view that renders the Halftone CMYK shader.
///
/// See <doc:HalftoneCmykShader> for usage examples, previews, and parameter ranges.
public struct HalftoneCmyk: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = halftoneCmykPresets
  public init(_ preset: HalftoneCmykPreset = HalftoneCmykPreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: HalftoneCmykParams,
    sizing: ShaderSizingParams = HalftoneCmykPreset.default.sizing,
    motion: ShaderMotionParams = HalftoneCmykPreset.default.motion,
    renderOptions: ShaderRenderOptions = HalftoneCmykPreset.default.renderOptions,
    image: ShaderImage? = HalftoneCmykPreset.default.image
  ) {
    configuration = ShaderConfiguration(
      parameters: .halftoneCmyk(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

/// A SwiftUI view that renders the Gem Smoke shader.
///
/// See <doc:GemSmokeShader> for usage examples, previews, and parameter ranges.
public struct GemSmoke: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = gemSmokePresets
  public init(_ preset: GemSmokePreset = GemSmokePreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: GemSmokeParams,
    sizing: ShaderSizingParams = GemSmokePreset.default.sizing,
    motion: ShaderMotionParams = GemSmokePreset.default.motion,
    renderOptions: ShaderRenderOptions = GemSmokePreset.default.renderOptions,
    image: ShaderImage? = GemSmokePreset.default.image
  ) {
    configuration = ShaderConfiguration(
      parameters: .gemSmoke(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}
