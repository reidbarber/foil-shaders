import SwiftUI

@MainActor
private func shaderBody(_ configuration: ShaderConfiguration) -> some SwiftUI.View {
  FoilShadersShaderView(configuration: configuration)
}

public struct MeshGradient: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = meshGradientPresets

  public init(_ preset: MeshGradientPreset = MeshGradientPreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }

  public init(
    params: MeshGradientParams, sizing: ShaderSizingParams = .defaultPatternSizing,
    motion: ShaderMotionParams = ShaderMotionParams(),
    renderOptions: ShaderRenderOptions = .default, image: ShaderImage? = nil
  ) {
    configuration = ShaderConfiguration(
      parameters: .meshGradient(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }

  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct SmokeRing: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = smokeRingPresets
  public init(_ preset: SmokeRingPreset = SmokeRingPreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: SmokeRingParams, sizing: ShaderSizingParams = .defaultPatternSizing,
    motion: ShaderMotionParams = ShaderMotionParams(),
    renderOptions: ShaderRenderOptions = .default, image: ShaderImage? = nil
  ) {
    configuration = ShaderConfiguration(
      parameters: .smokeRing(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct NeuroNoise: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = neuroNoisePresets
  public init(_ preset: NeuroNoisePreset = NeuroNoisePreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: NeuroNoiseParams, sizing: ShaderSizingParams = .defaultPatternSizing,
    motion: ShaderMotionParams = ShaderMotionParams(),
    renderOptions: ShaderRenderOptions = .default, image: ShaderImage? = nil
  ) {
    configuration = ShaderConfiguration(
      parameters: .neuroNoise(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct DotOrbit: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = dotOrbitPresets
  public init(_ preset: DotOrbitPreset = DotOrbitPreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: DotOrbitParams, sizing: ShaderSizingParams = .defaultPatternSizing,
    motion: ShaderMotionParams = ShaderMotionParams(),
    renderOptions: ShaderRenderOptions = .default, image: ShaderImage? = nil
  ) {
    configuration = ShaderConfiguration(
      parameters: .dotOrbit(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct DotGrid: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = dotGridPresets
  public init(_ preset: DotGridPreset = DotGridPreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: DotGridParams, sizing: ShaderSizingParams = .defaultPatternSizing,
    motion: ShaderMotionParams = ShaderMotionParams(),
    renderOptions: ShaderRenderOptions = .default, image: ShaderImage? = nil
  ) {
    configuration = ShaderConfiguration(
      parameters: .dotGrid(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct SimplexNoise: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = simplexNoisePresets
  public init(_ preset: SimplexNoisePreset = SimplexNoisePreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: SimplexNoiseParams, sizing: ShaderSizingParams = .defaultPatternSizing,
    motion: ShaderMotionParams = ShaderMotionParams(),
    renderOptions: ShaderRenderOptions = .default, image: ShaderImage? = nil
  ) {
    configuration = ShaderConfiguration(
      parameters: .simplexNoise(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct Metaballs: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = metaballsPresets
  public init(_ preset: MetaballsPreset = MetaballsPreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: MetaballsParams, sizing: ShaderSizingParams = .defaultPatternSizing,
    motion: ShaderMotionParams = ShaderMotionParams(),
    renderOptions: ShaderRenderOptions = .default, image: ShaderImage? = nil
  ) {
    configuration = ShaderConfiguration(
      parameters: .metaballs(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct Waves: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = wavesPresets
  public init(_ preset: WavesPreset = WavesPreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: WavesParams, sizing: ShaderSizingParams = .defaultPatternSizing,
    motion: ShaderMotionParams = ShaderMotionParams(),
    renderOptions: ShaderRenderOptions = .default, image: ShaderImage? = nil
  ) {
    configuration = ShaderConfiguration(
      parameters: .waves(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct PerlinNoise: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = perlinNoisePresets
  public init(_ preset: PerlinNoisePreset = PerlinNoisePreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: PerlinNoiseParams, sizing: ShaderSizingParams = .defaultPatternSizing,
    motion: ShaderMotionParams = ShaderMotionParams(),
    renderOptions: ShaderRenderOptions = .default, image: ShaderImage? = nil
  ) {
    configuration = ShaderConfiguration(
      parameters: .perlinNoise(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct Voronoi: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = voronoiPresets
  public init(_ preset: VoronoiPreset = VoronoiPreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: VoronoiParams, sizing: ShaderSizingParams = .defaultPatternSizing,
    motion: ShaderMotionParams = ShaderMotionParams(),
    renderOptions: ShaderRenderOptions = .default, image: ShaderImage? = nil
  ) {
    configuration = ShaderConfiguration(
      parameters: .voronoi(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct Warp: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = warpPresets
  public init(_ preset: WarpPreset = WarpPreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: WarpParams, sizing: ShaderSizingParams = .defaultPatternSizing,
    motion: ShaderMotionParams = ShaderMotionParams(),
    renderOptions: ShaderRenderOptions = .default, image: ShaderImage? = nil
  ) {
    configuration = ShaderConfiguration(
      parameters: .warp(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct GodRays: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = godRaysPresets
  public init(_ preset: GodRaysPreset = GodRaysPreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: GodRaysParams, sizing: ShaderSizingParams = .defaultPatternSizing,
    motion: ShaderMotionParams = ShaderMotionParams(),
    renderOptions: ShaderRenderOptions = .default, image: ShaderImage? = nil
  ) {
    configuration = ShaderConfiguration(
      parameters: .godRays(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct Spiral: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = spiralPresets
  public init(_ preset: SpiralPreset = SpiralPreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: SpiralParams, sizing: ShaderSizingParams = .defaultPatternSizing,
    motion: ShaderMotionParams = ShaderMotionParams(),
    renderOptions: ShaderRenderOptions = .default, image: ShaderImage? = nil
  ) {
    configuration = ShaderConfiguration(
      parameters: .spiral(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct Swirl: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = swirlPresets
  public init(_ preset: SwirlPreset = SwirlPreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: SwirlParams, sizing: ShaderSizingParams = .defaultPatternSizing,
    motion: ShaderMotionParams = ShaderMotionParams(),
    renderOptions: ShaderRenderOptions = .default, image: ShaderImage? = nil
  ) {
    configuration = ShaderConfiguration(
      parameters: .swirl(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct Dithering: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = ditheringPresets
  public init(_ preset: DitheringPreset = DitheringPreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: DitheringParams, sizing: ShaderSizingParams = .defaultPatternSizing,
    motion: ShaderMotionParams = ShaderMotionParams(),
    renderOptions: ShaderRenderOptions = .default, image: ShaderImage? = nil
  ) {
    configuration = ShaderConfiguration(
      parameters: .dithering(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct GrainGradient: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = grainGradientPresets
  public init(_ preset: GrainGradientPreset = GrainGradientPreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: GrainGradientParams, sizing: ShaderSizingParams = .defaultPatternSizing,
    motion: ShaderMotionParams = ShaderMotionParams(),
    renderOptions: ShaderRenderOptions = .default, image: ShaderImage? = nil
  ) {
    configuration = ShaderConfiguration(
      parameters: .grainGradient(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct PulsingBorder: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = pulsingBorderPresets
  public init(_ preset: PulsingBorderPreset = PulsingBorderPreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: PulsingBorderParams, sizing: ShaderSizingParams = .defaultPatternSizing,
    motion: ShaderMotionParams = ShaderMotionParams(),
    renderOptions: ShaderRenderOptions = .default, image: ShaderImage? = nil
  ) {
    configuration = ShaderConfiguration(
      parameters: .pulsingBorder(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct ColorPanels: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = colorPanelsPresets
  public init(_ preset: ColorPanelsPreset = ColorPanelsPreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: ColorPanelsParams, sizing: ShaderSizingParams = .defaultPatternSizing,
    motion: ShaderMotionParams = ShaderMotionParams(),
    renderOptions: ShaderRenderOptions = .default, image: ShaderImage? = nil
  ) {
    configuration = ShaderConfiguration(
      parameters: .colorPanels(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct StaticMeshGradient: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = staticMeshGradientPresets
  public init(_ preset: StaticMeshGradientPreset = StaticMeshGradientPreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: StaticMeshGradientParams, sizing: ShaderSizingParams = .defaultPatternSizing,
    motion: ShaderMotionParams = ShaderMotionParams(),
    renderOptions: ShaderRenderOptions = .default, image: ShaderImage? = nil
  ) {
    configuration = ShaderConfiguration(
      parameters: .staticMeshGradient(params), sizing: sizing,
      motion: motion, renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct StaticRadialGradient: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = staticRadialGradientPresets
  public init(_ preset: StaticRadialGradientPreset = StaticRadialGradientPreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: StaticRadialGradientParams, sizing: ShaderSizingParams = .defaultPatternSizing,
    motion: ShaderMotionParams = ShaderMotionParams(),
    renderOptions: ShaderRenderOptions = .default, image: ShaderImage? = nil
  ) {
    configuration = ShaderConfiguration(
      parameters: .staticRadialGradient(params), sizing: sizing,
      motion: motion, renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct PaperTexture: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = paperTexturePresets
  public init(_ preset: PaperTexturePreset = PaperTexturePreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: PaperTextureParams, sizing: ShaderSizingParams = .defaultPatternSizing,
    motion: ShaderMotionParams = ShaderMotionParams(),
    renderOptions: ShaderRenderOptions = .default, image: ShaderImage? = nil
  ) {
    configuration = ShaderConfiguration(
      parameters: .paperTexture(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct FlutedGlass: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = flutedGlassPresets
  public init(_ preset: FlutedGlassPreset = FlutedGlassPreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: FlutedGlassParams, sizing: ShaderSizingParams = .defaultObjectSizing,
    motion: ShaderMotionParams = ShaderMotionParams(),
    renderOptions: ShaderRenderOptions = .default, image: ShaderImage? = nil
  ) {
    configuration = ShaderConfiguration(
      parameters: .flutedGlass(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct Water: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = waterPresets
  public init(_ preset: WaterPreset = WaterPreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: WaterParams, sizing: ShaderSizingParams = .defaultObjectSizing,
    motion: ShaderMotionParams = ShaderMotionParams(),
    renderOptions: ShaderRenderOptions = .default, image: ShaderImage? = nil
  ) {
    configuration = ShaderConfiguration(
      parameters: .water(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct ImageDithering: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = imageDitheringPresets
  public init(_ preset: ImageDitheringPreset = ImageDitheringPreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: ImageDitheringParams, sizing: ShaderSizingParams = .defaultObjectSizing,
    motion: ShaderMotionParams = ShaderMotionParams(),
    renderOptions: ShaderRenderOptions = .default, image: ShaderImage? = nil
  ) {
    configuration = ShaderConfiguration(
      parameters: .imageDithering(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct Heatmap: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = heatmapPresets
  public init(_ preset: HeatmapPreset = HeatmapPreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: HeatmapParams, sizing: ShaderSizingParams = .defaultObjectSizing,
    motion: ShaderMotionParams = ShaderMotionParams(),
    renderOptions: ShaderRenderOptions = .default, image: ShaderImage? = nil
  ) {
    configuration = ShaderConfiguration(
      parameters: .heatmap(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct LiquidMetal: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = liquidMetalPresets
  public init(_ preset: LiquidMetalPreset = LiquidMetalPreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: LiquidMetalParams, sizing: ShaderSizingParams = .defaultObjectSizing,
    motion: ShaderMotionParams = ShaderMotionParams(),
    renderOptions: ShaderRenderOptions = .default, image: ShaderImage? = nil
  ) {
    configuration = ShaderConfiguration(
      parameters: .liquidMetal(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct HalftoneDots: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = halftoneDotsPresets
  public init(_ preset: HalftoneDotsPreset = HalftoneDotsPreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: HalftoneDotsParams, sizing: ShaderSizingParams = .defaultObjectSizing,
    motion: ShaderMotionParams = ShaderMotionParams(),
    renderOptions: ShaderRenderOptions = .default, image: ShaderImage? = nil
  ) {
    configuration = ShaderConfiguration(
      parameters: .halftoneDots(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct HalftoneCmyk: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = halftoneCmykPresets
  public init(_ preset: HalftoneCmykPreset = HalftoneCmykPreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: HalftoneCmykParams, sizing: ShaderSizingParams = .defaultObjectSizing,
    motion: ShaderMotionParams = ShaderMotionParams(),
    renderOptions: ShaderRenderOptions = .default, image: ShaderImage? = nil
  ) {
    configuration = ShaderConfiguration(
      parameters: .halftoneCmyk(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct GemSmoke: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public nonisolated static let presets = gemSmokePresets
  public init(_ preset: GemSmokePreset = GemSmokePreset.default) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }
  public init(
    params: GemSmokeParams, sizing: ShaderSizingParams = .defaultObjectSizing,
    motion: ShaderMotionParams = ShaderMotionParams(),
    renderOptions: ShaderRenderOptions = .default, image: ShaderImage? = nil
  ) {
    configuration = ShaderConfiguration(
      parameters: .gemSmoke(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}
