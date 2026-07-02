import SwiftUI
import simd

private func shaderColors(_ values: [ShaderColor]) -> [SIMD4<Float>] {
  values.map(\.rgba)
}

@MainActor
private func shaderBody(_ configuration: ShaderConfiguration) -> some SwiftUI.View {
  AluminumFoilShaderView(configuration: configuration)
}

public struct MeshGradient: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public static let presets = meshGradientPresets

  public init(_ preset: MeshGradientPreset = meshGradientPresets[0]) {
    self.init(
      params: preset.params, sizing: preset.sizing, motion: preset.motion,
      renderOptions: preset.renderOptions, image: preset.image)
  }

  public init(
    colors: [ShaderColor] = ["#e0eaff", "#241d9a", "#f75092", "#9f50d3"],
    distortion: Float = 0.8,
    swirl: Float = 0.1,
    grainMixer: Float = 0,
    grainOverlay: Float = 0,
    speed: Float = 1,
    frame: Float = 0,
    scale: Float = 1,
    rotation: Float = 0,
    offsetX: Float = 0,
    offsetY: Float = 0,
    fit: ShaderFit = .contain,
    worldWidth: Float = 0,
    worldHeight: Float = 0,
    originX: Float = 0.5,
    originY: Float = 0.5,
    minPixelRatio: Float = 2,
    maxPixelCount: Int = ShaderRenderOptions.defaultMaxPixelCount,
    width: CGFloat? = nil,
    height: CGFloat? = nil
  ) {
    self.init(
      params: MeshGradientParams(
        colors: shaderColors(colors), distortion: distortion, swirl: swirl, grainMixer: grainMixer,
        grainOverlay: grainOverlay),
      sizing: ShaderSizingParams(
        fit: fit, scale: scale, rotation: rotation, originX: originX, originY: originY,
        offsetX: offsetX, offsetY: offsetY, worldWidth: worldWidth, worldHeight: worldHeight),
      motion: ShaderMotionParams(speed: speed, frame: frame),
      renderOptions: ShaderRenderOptions(
        minPixelRatio: minPixelRatio, maxPixelCount: maxPixelCount, width: width, height: height)
    )
  }

  public init(
    params: MeshGradientParams, sizing: ShaderSizingParams = .defaultPatternSizing,
    motion: ShaderMotionParams = ShaderMotionParams(),
    renderOptions: ShaderRenderOptions = .default, image: ShaderImage? = nil
  ) {
    configuration = ShaderConfiguration(
      kind: .meshGradient, parameters: .meshGradient(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }

  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct SmokeRing: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public static let presets = smokeRingPresets
  public init(_ preset: SmokeRingPreset = smokeRingPresets[0]) {
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
      kind: .smokeRing, parameters: .smokeRing(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct NeuroNoise: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public static let presets = neuroNoisePresets
  public init(_ preset: NeuroNoisePreset = neuroNoisePresets[0]) {
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
      kind: .neuroNoise, parameters: .neuroNoise(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct DotOrbit: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public static let presets = dotOrbitPresets
  public init(_ preset: DotOrbitPreset = dotOrbitPresets[0]) {
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
      kind: .dotOrbit, parameters: .dotOrbit(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct DotGrid: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public static let presets = dotGridPresets
  public init(_ preset: DotGridPreset = dotGridPresets[0]) {
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
      kind: .dotGrid, parameters: .dotGrid(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct SimplexNoise: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public static let presets = simplexNoisePresets
  public init(_ preset: SimplexNoisePreset = simplexNoisePresets[0]) {
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
      kind: .simplexNoise, parameters: .simplexNoise(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct Metaballs: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public static let presets = metaballsPresets
  public init(_ preset: MetaballsPreset = metaballsPresets[0]) {
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
      kind: .metaballs, parameters: .metaballs(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct Waves: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public static let presets = wavesPresets
  public init(_ preset: WavesPreset = wavesPresets[0]) {
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
      kind: .waves, parameters: .waves(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct PerlinNoise: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public static let presets = perlinNoisePresets
  public init(_ preset: PerlinNoisePreset = perlinNoisePresets[0]) {
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
      kind: .perlinNoise, parameters: .perlinNoise(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct Voronoi: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public static let presets = voronoiPresets
  public init(_ preset: VoronoiPreset = voronoiPresets[0]) {
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
      kind: .voronoi, parameters: .voronoi(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct Warp: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public static let presets = warpPresets
  public init(_ preset: WarpPreset = warpPresets[0]) {
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
      kind: .warp, parameters: .warp(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct GodRays: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public static let presets = godRaysPresets
  public init(_ preset: GodRaysPreset = godRaysPresets[0]) {
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
      kind: .godRays, parameters: .godRays(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct Spiral: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public static let presets = spiralPresets
  public init(_ preset: SpiralPreset = spiralPresets[0]) {
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
      kind: .spiral, parameters: .spiral(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct Swirl: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public static let presets = swirlPresets
  public init(_ preset: SwirlPreset = swirlPresets[0]) {
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
      kind: .swirl, parameters: .swirl(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct Dithering: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public static let presets = ditheringPresets
  public init(_ preset: DitheringPreset = ditheringPresets[0]) {
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
      kind: .dithering, parameters: .dithering(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct GrainGradient: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public static let presets = grainGradientPresets
  public init(_ preset: GrainGradientPreset = grainGradientPresets[0]) {
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
      kind: .grainGradient, parameters: .grainGradient(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct PulsingBorder: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public static let presets = pulsingBorderPresets
  public init(_ preset: PulsingBorderPreset = pulsingBorderPresets[0]) {
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
      kind: .pulsingBorder, parameters: .pulsingBorder(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct ColorPanels: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public static let presets = colorPanelsPresets
  public init(_ preset: ColorPanelsPreset = colorPanelsPresets[0]) {
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
      kind: .colorPanels, parameters: .colorPanels(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct StaticMeshGradient: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public static let presets = staticMeshGradientPresets
  public init(_ preset: StaticMeshGradientPreset = staticMeshGradientPresets[0]) {
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
      kind: .staticMeshGradient, parameters: .staticMeshGradient(params), sizing: sizing,
      motion: motion, renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct StaticRadialGradient: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public static let presets = staticRadialGradientPresets
  public init(_ preset: StaticRadialGradientPreset = staticRadialGradientPresets[0]) {
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
      kind: .staticRadialGradient, parameters: .staticRadialGradient(params), sizing: sizing,
      motion: motion, renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct PaperTexture: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public static let presets = paperTexturePresets
  public init(_ preset: PaperTexturePreset = paperTexturePresets[0]) {
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
      kind: .paperTexture, parameters: .paperTexture(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct FlutedGlass: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public static let presets = flutedGlassPresets
  public init(_ preset: FlutedGlassPreset = flutedGlassPresets[0]) {
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
      kind: .flutedGlass, parameters: .flutedGlass(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct Water: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public static let presets = waterPresets
  public init(_ preset: WaterPreset = waterPresets[0]) {
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
      kind: .water, parameters: .water(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct ImageDithering: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public static let presets = imageDitheringPresets
  public init(_ preset: ImageDitheringPreset = imageDitheringPresets[0]) {
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
      kind: .imageDithering, parameters: .imageDithering(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct Heatmap: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public static let presets = heatmapPresets
  public init(_ preset: HeatmapPreset = heatmapPresets[0]) {
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
      kind: .heatmap, parameters: .heatmap(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct LiquidMetal: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public static let presets = liquidMetalPresets
  public init(_ preset: LiquidMetalPreset = liquidMetalPresets[0]) {
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
      kind: .liquidMetal, parameters: .liquidMetal(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct HalftoneDots: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public static let presets = halftoneDotsPresets
  public init(_ preset: HalftoneDotsPreset = halftoneDotsPresets[0]) {
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
      kind: .halftoneDots, parameters: .halftoneDots(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct HalftoneCmyk: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public static let presets = halftoneCmykPresets
  public init(_ preset: HalftoneCmykPreset = halftoneCmykPresets[0]) {
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
      kind: .halftoneCmyk, parameters: .halftoneCmyk(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}

public struct GemSmoke: SwiftUI.View {
  public var configuration: ShaderConfiguration
  public static let presets = gemSmokePresets
  public init(_ preset: GemSmokePreset = gemSmokePresets[0]) {
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
      kind: .gemSmoke, parameters: .gemSmoke(params), sizing: sizing, motion: motion,
      renderOptions: renderOptions, image: image)
  }
  public var body: some SwiftUI.View { shaderBody(configuration) }
}
