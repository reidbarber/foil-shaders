@_spi(Studio) import FoilShaders

enum StudioShaderCategory: String, CaseIterable, Identifiable {
  case gradients = "Gradients"
  case noise = "Noise"
  case patterns = "Patterns"
  case imageEffects = "Image Effects"
  case materials = "Materials"

  var id: String { rawValue }
}

enum StudioShader: String, CaseIterable, Identifiable {
  case animatedMeshGradient
  case smokeRing
  case neuroNoise
  case dotOrbit
  case dotGrid
  case simplexNoise
  case metaballs
  case waves
  case perlinNoise
  case voronoi
  case warp
  case godRays
  case spiral
  case swirl
  case dithering
  case grainGradient
  case pulsingBorder
  case colorPanels
  case staticMeshGradient
  case staticRadialGradient
  case paperTexture
  case flutedGlass
  case water
  case imageDithering
  case heatmap
  case liquidMetal
  case halftoneDots
  case halftoneCMYK
  case gemSmoke

  var id: String { rawValue }

  var displayName: String {
    switch self {
    case .animatedMeshGradient: "Mesh Gradient"
    case .smokeRing: "Smoke Ring"
    case .neuroNoise: "Neuro Noise"
    case .dotOrbit: "Dot Orbit"
    case .dotGrid: "Dot Grid"
    case .simplexNoise: "Simplex Noise"
    case .metaballs: "Metaballs"
    case .waves: "Waves"
    case .perlinNoise: "Perlin Noise"
    case .voronoi: "Voronoi"
    case .warp: "Warp"
    case .godRays: "God Rays"
    case .spiral: "Spiral"
    case .swirl: "Swirl"
    case .dithering: "Dithering"
    case .grainGradient: "Grain Gradient"
    case .pulsingBorder: "Pulsing Border"
    case .colorPanels: "Color Panels"
    case .staticMeshGradient: "Static Mesh Gradient"
    case .staticRadialGradient: "Static Radial Gradient"
    case .paperTexture: "Paper Texture"
    case .flutedGlass: "Fluted Glass"
    case .water: "Water"
    case .imageDithering: "Image Dithering"
    case .heatmap: "Heatmap"
    case .liquidMetal: "Liquid Metal"
    case .halftoneDots: "Halftone Dots"
    case .halftoneCMYK: "Halftone CMYK"
    case .gemSmoke: "Gem Smoke"
    }
  }

  var componentName: String {
    switch self {
    case .animatedMeshGradient: "AnimatedMeshGradient"
    case .halftoneCMYK: "HalftoneCMYK"
    default: displayName.replacingOccurrences(of: " ", with: "")
    }
  }

  var category: StudioShaderCategory {
    switch self {
    case .animatedMeshGradient, .staticMeshGradient, .staticRadialGradient, .grainGradient:
      .gradients
    case .neuroNoise, .simplexNoise, .perlinNoise, .voronoi, .warp:
      .noise
    case .smokeRing, .dotOrbit, .dotGrid, .metaballs, .waves, .godRays, .spiral,
      .swirl, .dithering, .pulsingBorder, .colorPanels:
      .patterns
    case .imageDithering, .heatmap, .halftoneDots, .halftoneCMYK:
      .imageEffects
    case .paperTexture, .flutedGlass, .water, .liquidMetal, .gemSmoke:
      .materials
    }
  }

  var presetCount: Int {
    switch self {
    case .animatedMeshGradient: AnimatedMeshGradient.presets.count
    case .smokeRing: SmokeRing.presets.count
    case .neuroNoise: NeuroNoise.presets.count
    case .dotOrbit: DotOrbit.presets.count
    case .dotGrid: DotGrid.presets.count
    case .simplexNoise: SimplexNoise.presets.count
    case .metaballs: Metaballs.presets.count
    case .waves: Waves.presets.count
    case .perlinNoise: PerlinNoise.presets.count
    case .voronoi: Voronoi.presets.count
    case .warp: Warp.presets.count
    case .godRays: GodRays.presets.count
    case .spiral: Spiral.presets.count
    case .swirl: Swirl.presets.count
    case .dithering: Dithering.presets.count
    case .grainGradient: GrainGradient.presets.count
    case .pulsingBorder: PulsingBorder.presets.count
    case .colorPanels: ColorPanels.presets.count
    case .staticMeshGradient: StaticMeshGradient.presets.count
    case .staticRadialGradient: StaticRadialGradient.presets.count
    case .paperTexture: PaperTexture.presets.count
    case .flutedGlass: FlutedGlass.presets.count
    case .water: Water.presets.count
    case .imageDithering: ImageDithering.presets.count
    case .heatmap: Heatmap.presets.count
    case .liquidMetal: LiquidMetal.presets.count
    case .halftoneDots: HalftoneDots.presets.count
    case .halftoneCMYK: HalftoneCMYK.presets.count
    case .gemSmoke: GemSmoke.presets.count
    }
  }

  var usesImage: Bool {
    switch self {
    case .flutedGlass, .water, .imageDithering, .heatmap, .liquidMetal, .halftoneDots,
      .halftoneCMYK, .gemSmoke:
      true
    default:
      false
    }
  }

  func presetName(at index: Int) -> String {
    switch self {
    case .animatedMeshGradient: AnimatedMeshGradient.presets[index].name
    case .smokeRing: SmokeRing.presets[index].name
    case .neuroNoise: NeuroNoise.presets[index].name
    case .dotOrbit: DotOrbit.presets[index].name
    case .dotGrid: DotGrid.presets[index].name
    case .simplexNoise: SimplexNoise.presets[index].name
    case .metaballs: Metaballs.presets[index].name
    case .waves: Waves.presets[index].name
    case .perlinNoise: PerlinNoise.presets[index].name
    case .voronoi: Voronoi.presets[index].name
    case .warp: Warp.presets[index].name
    case .godRays: GodRays.presets[index].name
    case .spiral: Spiral.presets[index].name
    case .swirl: Swirl.presets[index].name
    case .dithering: Dithering.presets[index].name
    case .grainGradient: GrainGradient.presets[index].name
    case .pulsingBorder: PulsingBorder.presets[index].name
    case .colorPanels: ColorPanels.presets[index].name
    case .staticMeshGradient: StaticMeshGradient.presets[index].name
    case .staticRadialGradient: StaticRadialGradient.presets[index].name
    case .paperTexture: PaperTexture.presets[index].name
    case .flutedGlass: FlutedGlass.presets[index].name
    case .water: Water.presets[index].name
    case .imageDithering: ImageDithering.presets[index].name
    case .heatmap: Heatmap.presets[index].name
    case .liquidMetal: LiquidMetal.presets[index].name
    case .halftoneDots: HalftoneDots.presets[index].name
    case .halftoneCMYK: HalftoneCMYK.presets[index].name
    case .gemSmoke: GemSmoke.presets[index].name
    }
  }

  func presetReference(at index: Int) -> String {
    "\(componentName)Preset.\(Self.presetIdentifier(presetName(at: index)))"
  }

  @MainActor
  func configuration(at index: Int) -> ShaderConfiguration {
    switch self {
    case .animatedMeshGradient:
      AnimatedMeshGradient(AnimatedMeshGradient.presets[index]).configuration
    case .smokeRing: SmokeRing(SmokeRing.presets[index]).configuration
    case .neuroNoise: NeuroNoise(NeuroNoise.presets[index]).configuration
    case .dotOrbit: DotOrbit(DotOrbit.presets[index]).configuration
    case .dotGrid: DotGrid(DotGrid.presets[index]).configuration
    case .simplexNoise: SimplexNoise(SimplexNoise.presets[index]).configuration
    case .metaballs: Metaballs(Metaballs.presets[index]).configuration
    case .waves: Waves(Waves.presets[index]).configuration
    case .perlinNoise: PerlinNoise(PerlinNoise.presets[index]).configuration
    case .voronoi: Voronoi(Voronoi.presets[index]).configuration
    case .warp: Warp(Warp.presets[index]).configuration
    case .godRays: GodRays(GodRays.presets[index]).configuration
    case .spiral: Spiral(Spiral.presets[index]).configuration
    case .swirl: Swirl(Swirl.presets[index]).configuration
    case .dithering: Dithering(Dithering.presets[index]).configuration
    case .grainGradient: GrainGradient(GrainGradient.presets[index]).configuration
    case .pulsingBorder: PulsingBorder(PulsingBorder.presets[index]).configuration
    case .colorPanels: ColorPanels(ColorPanels.presets[index]).configuration
    case .staticMeshGradient: StaticMeshGradient(StaticMeshGradient.presets[index]).configuration
    case .staticRadialGradient:
      StaticRadialGradient(StaticRadialGradient.presets[index]).configuration
    case .paperTexture: PaperTexture(PaperTexture.presets[index]).configuration
    case .flutedGlass: FlutedGlass(FlutedGlass.presets[index]).configuration
    case .water: Water(Water.presets[index]).configuration
    case .imageDithering: ImageDithering(ImageDithering.presets[index]).configuration
    case .heatmap: Heatmap(Heatmap.presets[index]).configuration
    case .liquidMetal: LiquidMetal(LiquidMetal.presets[index]).configuration
    case .halftoneDots: HalftoneDots(HalftoneDots.presets[index]).configuration
    case .halftoneCMYK: HalftoneCMYK(HalftoneCMYK.presets[index]).configuration
    case .gemSmoke: GemSmoke(GemSmoke.presets[index]).configuration
    }
  }

  private static func presetIdentifier(_ name: String) -> String {
    let words = name.split { !$0.isLetter && !$0.isNumber }
    var identifier = words.enumerated().map { index, word in
      let text = String(word)
      let normalized =
        text.allSatisfy { $0.isNumber || $0.isUppercase }
        ? text.lowercased()
        : text.prefix(1).lowercased() + String(text.dropFirst())
      if index == 0 {
        return normalized
      }
      return normalized.prefix(1).uppercased() + String(normalized.dropFirst())
    }.joined()
    if identifier.isEmpty {
      identifier = "preset"
    }
    if identifier.first?.isNumber == true {
      identifier = "preset" + identifier.prefix(1).uppercased() + String(identifier.dropFirst())
    }
    return identifier
  }
}
