import Foundation
import simd

// Generated from Paper Shaders preset metadata with Scripts/extract-paper-presets.mjs.
private func color(_ value: String) -> SIMD4<Float> {
  (ShaderColor(value) ?? .black).rgba
}

public typealias MeshGradientPreset = ShaderPreset<MeshGradientParams>
public typealias SmokeRingPreset = ShaderPreset<SmokeRingParams>
public typealias NeuroNoisePreset = ShaderPreset<NeuroNoiseParams>
public typealias DotOrbitPreset = ShaderPreset<DotOrbitParams>
public typealias DotGridPreset = ShaderPreset<DotGridParams>
public typealias SimplexNoisePreset = ShaderPreset<SimplexNoiseParams>
public typealias MetaballsPreset = ShaderPreset<MetaballsParams>
public typealias WavesPreset = ShaderPreset<WavesParams>
public typealias PerlinNoisePreset = ShaderPreset<PerlinNoiseParams>
public typealias VoronoiPreset = ShaderPreset<VoronoiParams>
public typealias WarpPreset = ShaderPreset<WarpParams>
public typealias GodRaysPreset = ShaderPreset<GodRaysParams>
public typealias SpiralPreset = ShaderPreset<SpiralParams>
public typealias SwirlPreset = ShaderPreset<SwirlParams>
public typealias DitheringPreset = ShaderPreset<DitheringParams>
public typealias GrainGradientPreset = ShaderPreset<GrainGradientParams>
public typealias PulsingBorderPreset = ShaderPreset<PulsingBorderParams>
public typealias ColorPanelsPreset = ShaderPreset<ColorPanelsParams>
public typealias StaticMeshGradientPreset = ShaderPreset<StaticMeshGradientParams>
public typealias StaticRadialGradientPreset = ShaderPreset<StaticRadialGradientParams>
public typealias PaperTexturePreset = ShaderPreset<PaperTextureParams>
public typealias FlutedGlassPreset = ShaderPreset<FlutedGlassParams>
public typealias WaterPreset = ShaderPreset<WaterParams>
public typealias ImageDitheringPreset = ShaderPreset<ImageDitheringParams>
public typealias HeatmapPreset = ShaderPreset<HeatmapParams>
public typealias LiquidMetalPreset = ShaderPreset<LiquidMetalParams>
public typealias HalftoneDotsPreset = ShaderPreset<HalftoneDotsParams>
public typealias HalftoneCmykPreset = ShaderPreset<HalftoneCmykParams>
public typealias GemSmokePreset = ShaderPreset<GemSmokeParams>

public let meshGradientPresets: [MeshGradientPreset] = [
  ShaderPreset(
    name: "Default",
    params: MeshGradientParams(
      colors: [color("#e0eaff"), color("#241d9a"), color("#f75092"), color("#9f50d3")],
      distortion: 0.8,
      swirl: 0.1,
      grainMixer: 0,
      grainOverlay: 0
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 1, frame: 0)
  ),
  ShaderPreset(
    name: "Ink",
    params: MeshGradientParams(
      colors: [color("#ffffff"), color("#000000")],
      distortion: 1,
      swirl: 0.2,
      grainMixer: 0,
      grainOverlay: 0
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 1, rotation: 90, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 1, frame: 0)
  ),
  ShaderPreset(
    name: "Purple",
    params: MeshGradientParams(
      colors: [color("#aaa7d7"), color("#3c2b8e")],
      distortion: 1,
      swirl: 1,
      grainMixer: 0,
      grainOverlay: 0
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0.6, frame: 0)
  ),
  ShaderPreset(
    name: "Beach",
    params: MeshGradientParams(
      colors: [color("#bcecf6"), color("#00aaff"), color("#00f7ff"), color("#ffd447")],
      distortion: 0.8,
      swirl: 0.35,
      grainMixer: 0,
      grainOverlay: 0
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0.1, frame: 0)
  ),
]

public let smokeRingPresets: [SmokeRingPreset] = [
  ShaderPreset(
    name: "Default",
    params: SmokeRingParams(
      colorBack: color("#000000"),
      colors: [color("#ffffff")],
      noiseScale: 3,
      thickness: 0.65,
      radius: 0.25,
      innerShape: 0.7,
      noiseIterations: 8
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 0.8, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0.5, frame: 0)
  ),
  ShaderPreset(
    name: "Line",
    params: SmokeRingParams(
      colorBack: color("#000000"),
      colors: [color("#4540a4"), color("#1fe8ff")],
      noiseScale: 1.1,
      thickness: 0.01,
      radius: 0.38,
      innerShape: 0.88,
      noiseIterations: 2
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 4, frame: 0)
  ),
  ShaderPreset(
    name: "Solar",
    params: SmokeRingParams(
      colorBack: color("#000000"),
      colors: [color("#ffffff"), color("#ffca0a"), color("#fc6203"), color("#fc620366")],
      noiseScale: 2,
      thickness: 0.8,
      radius: 0.4,
      innerShape: 4,
      noiseIterations: 3
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 2, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 1,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 1, frame: 0)
  ),
  ShaderPreset(
    name: "Cloud",
    params: SmokeRingParams(
      colorBack: color("#81ADEC"),
      colors: [color("#ffffff")],
      noiseScale: 3,
      thickness: 0.65,
      radius: 0.5,
      innerShape: 0.85,
      noiseIterations: 10
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 2.5, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0.5, frame: 0)
  ),
]

public let neuroNoisePresets: [NeuroNoisePreset] = [
  ShaderPreset(
    name: "Default",
    params: NeuroNoiseParams(
      colorFront: color("#ffffff"),
      colorMid: color("#47a6ff"),
      colorBack: color("#000000"),
      brightness: 0.05,
      contrast: 0.3
    ),
    sizing: ShaderSizingParams(
      fit: .none, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 1, frame: 0)
  ),
  ShaderPreset(
    name: "Sensation",
    params: NeuroNoiseParams(
      colorFront: color("#00c8ff"),
      colorMid: color("#fbff00"),
      colorBack: color("#8b42ff"),
      brightness: 0.19,
      contrast: 0.12
    ),
    sizing: ShaderSizingParams(
      fit: .none, scale: 3, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 1, frame: 0)
  ),
  ShaderPreset(
    name: "Bloodstream",
    params: NeuroNoiseParams(
      colorFront: color("#ff0000"),
      colorMid: color("#ff0000"),
      colorBack: color("#ffffff"),
      brightness: 0.24,
      contrast: 0.17
    ),
    sizing: ShaderSizingParams(
      fit: .none, scale: 0.7, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 1, frame: 0)
  ),
  ShaderPreset(
    name: "Ghost",
    params: NeuroNoiseParams(
      colorFront: color("#ffffff"),
      colorMid: color("#000000"),
      colorBack: color("#ffffff"),
      brightness: 0,
      contrast: 1
    ),
    sizing: ShaderSizingParams(
      fit: .none, scale: 0.55, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 1, frame: 0)
  ),
]

public let dotOrbitPresets: [DotOrbitPreset] = [
  ShaderPreset(
    name: "Default",
    params: DotOrbitParams(
      colorBack: color("#000000"),
      colors: [
        color("#ffc96b"), color("#ff6200"), color("#ff2f00"), color("#421100"), color("#1a0000"),
      ],
      stepsPerColor: 4,
      size: 1,
      sizeRange: 0,
      spreading: 1
    ),
    sizing: ShaderSizingParams(
      fit: .none, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 1.5, frame: 0)
  ),
  ShaderPreset(
    name: "Bubbles",
    params: DotOrbitParams(
      colorBack: color("#989CA4"),
      colors: [color("#D0D2D5")],
      stepsPerColor: 2,
      size: 0.9,
      sizeRange: 0.7,
      spreading: 1
    ),
    sizing: ShaderSizingParams(
      fit: .none, scale: 1.64, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0.4, frame: 0)
  ),
  ShaderPreset(
    name: "Shine",
    params: DotOrbitParams(
      colorBack: color("#000000"),
      colors: [color("#ffffff"), color("#006aff"), color("#fff675")],
      stepsPerColor: 4,
      size: 0.3,
      sizeRange: 0.2,
      spreading: 1
    ),
    sizing: ShaderSizingParams(
      fit: .none, scale: 0.4, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0.1, frame: 0)
  ),
  ShaderPreset(
    name: "Hallucinatory",
    params: DotOrbitParams(
      colorBack: color("#ffe500"),
      colors: [color("#000000")],
      stepsPerColor: 2,
      size: 0.65,
      sizeRange: 0,
      spreading: 0.3
    ),
    sizing: ShaderSizingParams(
      fit: .none, scale: 0.5, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 5, frame: 0)
  ),
]

public let dotGridPresets: [DotGridPreset] = [
  ShaderPreset(
    name: "Default",
    params: DotGridParams(
      colorBack: color("#000000"),
      colorFill: color("#ffffff"),
      colorStroke: color("#ffaa00"),
      dotSize: 2,
      gapX: 32,
      gapY: 32,
      strokeWidth: 0,
      sizeRange: 0,
      opacityRange: 0,
      shape: 0
    ),
    sizing: ShaderSizingParams(
      fit: .none, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0, frame: 0),
    renderOptions: ShaderRenderOptions(maxPixelCount: 6016 * 3384)
  ),
  ShaderPreset(
    name: "Triangles",
    params: DotGridParams(
      colorBack: color("#ffffff"),
      colorFill: color("#ffffff"),
      colorStroke: color("#808080"),
      dotSize: 5,
      gapX: 32,
      gapY: 32,
      strokeWidth: 1,
      sizeRange: 0,
      opacityRange: 0,
      shape: 3
    ),
    sizing: ShaderSizingParams(
      fit: .none, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0, frame: 0),
    renderOptions: ShaderRenderOptions(maxPixelCount: 6016 * 3384)
  ),
  ShaderPreset(
    name: "Tree line",
    params: DotGridParams(
      colorBack: color("#f4fce7"),
      colorFill: color("#052e19"),
      colorStroke: color("#000000"),
      dotSize: 8,
      gapX: 20,
      gapY: 90,
      strokeWidth: 0,
      sizeRange: 1,
      opacityRange: 0.6,
      shape: 0
    ),
    sizing: ShaderSizingParams(
      fit: .none, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0, frame: 0),
    renderOptions: ShaderRenderOptions(maxPixelCount: 6016 * 3384)
  ),
  ShaderPreset(
    name: "Wallpaper",
    params: DotGridParams(
      colorBack: color("#204030"),
      colorFill: color("#000000"),
      colorStroke: color("#bd955b"),
      dotSize: 9,
      gapX: 32,
      gapY: 32,
      strokeWidth: 1,
      sizeRange: 0,
      opacityRange: 0,
      shape: 1
    ),
    sizing: ShaderSizingParams(
      fit: .none, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0, frame: 0),
    renderOptions: ShaderRenderOptions(maxPixelCount: 6016 * 3384)
  ),
]

public let simplexNoisePresets: [SimplexNoisePreset] = [
  ShaderPreset(
    name: "Default",
    params: SimplexNoiseParams(
      colors: [
        color("#4449CF"), color("#FFD1E0"), color("#F94446"), color("#FFD36B"), color("#FFFFFF"),
      ],
      stepsPerColor: 2,
      softness: 0
    ),
    sizing: ShaderSizingParams(
      fit: .none, scale: 0.6, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0.5, frame: 0)
  ),
  ShaderPreset(
    name: "Spots",
    params: SimplexNoiseParams(
      colors: [color("#ff7b00"), color("#f9ffeb"), color("#320d82")],
      stepsPerColor: 1,
      softness: 0
    ),
    sizing: ShaderSizingParams(
      fit: .none, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0.6, frame: 0)
  ),
  ShaderPreset(
    name: "First contact",
    params: SimplexNoiseParams(
      colors: [
        color("#e8cce6"), color("#120d22"), color("#442c44"), color("#e6baba"), color("#fff5f5"),
      ],
      stepsPerColor: 2,
      softness: 0
    ),
    sizing: ShaderSizingParams(
      fit: .none, scale: 0.2, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 2, frame: 0)
  ),
  ShaderPreset(
    name: "Bubblegum",
    params: SimplexNoiseParams(
      colors: [color("#ffffff"), color("#ff9e9e"), color("#5f57ff"), color("#00f7ff")],
      stepsPerColor: 1,
      softness: 1
    ),
    sizing: ShaderSizingParams(
      fit: .none, scale: 1.6, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 2, frame: 0)
  ),
]

public let metaballsPresets: [MetaballsPreset] = [
  ShaderPreset(
    name: "Default",
    params: MetaballsParams(
      colorBack: color("#000000"),
      colors: [
        color("#6e33cc"), color("#ff5500"), color("#ffc105"), color("#ffc800"), color("#f585ff"),
      ],
      count: 10,
      size: 0.83,
      sizeRange: 0.2
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 1, frame: 0)
  ),
  ShaderPreset(
    name: "Ink Drops",
    params: MetaballsParams(
      colorBack: color("#ffffff00"),
      colors: [color("#000000")],
      count: 18,
      size: 0.1,
      sizeRange: 0.2
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 2, frame: 0)
  ),
  ShaderPreset(
    name: "Solar",
    params: MetaballsParams(
      colorBack: color("#102f84"),
      colors: [color("#ffc800"), color("#ff5500"), color("#ffc105")],
      count: 7,
      size: 0.75,
      sizeRange: 0.2
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 1, frame: 0)
  ),
  ShaderPreset(
    name: "Background",
    params: MetaballsParams(
      colorBack: color("#2a273f"),
      colors: [color("#ae00ff"), color("#00ff95"), color("#ffc105")],
      count: 13,
      size: 0.81,
      sizeRange: 0.2
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 4, rotation: 0, originX: 0.5, originY: 0.5, offsetX: -0.3, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0.5, frame: 0)
  ),
]

public let wavesPresets: [WavesPreset] = [
  ShaderPreset(
    name: "Default",
    params: WavesParams(
      colorFront: color("#ffbb00"),
      colorBack: color("#000000"),
      shape: 0,
      frequency: 0.5,
      amplitude: 0.5,
      spacing: 1.2,
      proportion: 0.1,
      softness: 0
    ),
    sizing: ShaderSizingParams(
      fit: .none, scale: 0.6, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0, frame: 0),
    renderOptions: ShaderRenderOptions(maxPixelCount: 6016 * 3384)
  ),
  ShaderPreset(
    name: "Groovy",
    params: WavesParams(
      colorFront: color("#fcfcee"),
      colorBack: color("#ff896b"),
      shape: 3,
      frequency: 0.2,
      amplitude: 0.25,
      spacing: 1.17,
      proportion: 0.57,
      softness: 0
    ),
    sizing: ShaderSizingParams(
      fit: .none, scale: 5, rotation: 90, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0, frame: 0),
    renderOptions: ShaderRenderOptions(maxPixelCount: 6016 * 3384)
  ),
  ShaderPreset(
    name: "Tangled up",
    params: WavesParams(
      colorFront: color("#133a41"),
      colorBack: color("#c2d8b6"),
      shape: 2.07,
      frequency: 0.44,
      amplitude: 0.57,
      spacing: 1.05,
      proportion: 0.75,
      softness: 0
    ),
    sizing: ShaderSizingParams(
      fit: .none, scale: 0.5, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0, frame: 0),
    renderOptions: ShaderRenderOptions(maxPixelCount: 6016 * 3384)
  ),
  ShaderPreset(
    name: "Ride the wave",
    params: WavesParams(
      colorFront: color("#fdffe6"),
      colorBack: color("#1f1f1f"),
      shape: 2.25,
      frequency: 0.2,
      amplitude: 1,
      spacing: 1.25,
      proportion: 1,
      softness: 0
    ),
    sizing: ShaderSizingParams(
      fit: .none, scale: 1.7, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0, frame: 0),
    renderOptions: ShaderRenderOptions(maxPixelCount: 6016 * 3384)
  ),
]

public let perlinNoisePresets: [PerlinNoisePreset] = [
  ShaderPreset(
    name: "Default",
    params: PerlinNoiseParams(
      colorFront: color("#fccff7"),
      colorBack: color("#632ad5"),
      proportion: 0.35,
      softness: 0.1,
      octaveCount: 1,
      persistence: 1,
      lacunarity: 1.5
    ),
    sizing: ShaderSizingParams(
      fit: .none, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0.5, frame: 0)
  ),
  ShaderPreset(
    name: "Nintendo Water",
    params: PerlinNoiseParams(
      colorFront: color("#d1eefc"),
      colorBack: color("#2d69d4"),
      proportion: 0.42,
      softness: 0,
      octaveCount: 2,
      persistence: 0.55,
      lacunarity: 1.8
    ),
    sizing: ShaderSizingParams(
      fit: .none, scale: 5, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0.4, frame: 0)
  ),
  ShaderPreset(
    name: "Moss",
    params: PerlinNoiseParams(
      colorFront: color("#262626"),
      colorBack: color("#05ff4a"),
      proportion: 0.65,
      softness: 0.35,
      octaveCount: 6,
      persistence: 1,
      lacunarity: 2.55
    ),
    sizing: ShaderSizingParams(
      fit: .none, scale: 6.666666666666667, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0,
      offsetY: 0, worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0.02, frame: 0)
  ),
  ShaderPreset(
    name: "Worms",
    params: PerlinNoiseParams(
      colorFront: color("#595959"),
      colorBack: color("#ffffff00"),
      proportion: 0.5,
      softness: 0,
      octaveCount: 1,
      persistence: 1,
      lacunarity: 1.5
    ),
    sizing: ShaderSizingParams(
      fit: .none, scale: 0.9, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0, frame: 0)
  ),
]

public let voronoiPresets: [VoronoiPreset] = [
  ShaderPreset(
    name: "Default",
    params: VoronoiParams(
      colors: [color("#ff8247"), color("#ffe53d")],
      stepsPerColor: 3,
      colorGap: color("#2e0000"),
      colorGlow: color("#ffffff"),
      distortion: 0.4,
      gap: 0.04,
      glow: 0
    ),
    sizing: ShaderSizingParams(
      fit: .none, scale: 0.5, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0.5, frame: 0)
  ),
  ShaderPreset(
    name: "Lights",
    params: VoronoiParams(
      colors: [color("#fffffffc"), color("#bbff00"), color("#00ffff")],
      stepsPerColor: 2,
      colorGap: color("#ff00d0"),
      colorGlow: color("#ff00d0"),
      distortion: 0.38,
      gap: 0,
      glow: 1
    ),
    sizing: ShaderSizingParams(
      fit: .none, scale: 3.3, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0.5, frame: 0)
  ),
  ShaderPreset(
    name: "Cells",
    params: VoronoiParams(
      colors: [color("#ffffff")],
      stepsPerColor: 1,
      colorGap: color("#000000"),
      colorGlow: color("#ffffff"),
      distortion: 0.5,
      gap: 0.03,
      glow: 0.8
    ),
    sizing: ShaderSizingParams(
      fit: .none, scale: 0.5, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0.5, frame: 0)
  ),
  ShaderPreset(
    name: "Bubbles",
    params: VoronoiParams(
      colors: [color("#83c9fb")],
      stepsPerColor: 1,
      colorGap: color("#ffffff"),
      colorGlow: color("#ffffff"),
      distortion: 0.4,
      gap: 0,
      glow: 1
    ),
    sizing: ShaderSizingParams(
      fit: .none, scale: 0.75, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0.5, frame: 0)
  ),
]

public let warpPresets: [WarpPreset] = [
  ShaderPreset(
    name: "Default",
    params: WarpParams(
      colors: [color("#121212"), color("#9470ff"), color("#121212"), color("#8838ff")],
      proportion: 0.45,
      softness: 1,
      shape: 0,
      shapeScale: 0.1,
      distortion: 0.25,
      swirl: 0.8,
      swirlIterations: 10
    ),
    sizing: ShaderSizingParams(
      fit: .none, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 1, frame: 0)
  ),
  ShaderPreset(
    name: "Cauldron Pot",
    params: WarpParams(
      colors: [color("#a7e58b"), color("#324472"), color("#0a180d")],
      proportion: 0.64,
      softness: 1.5,
      shape: 2,
      shapeScale: 0.6,
      distortion: 0.2,
      swirl: 0.86,
      swirlIterations: 7
    ),
    sizing: ShaderSizingParams(
      fit: .none, scale: 0.9, rotation: 160, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 10, frame: 0)
  ),
  ShaderPreset(
    name: "Live Ink",
    params: WarpParams(
      colors: [color("#111314"), color("#9faeab"), color("#f3fee7"), color("#f3fee7")],
      proportion: 0.05,
      softness: 0,
      shape: 0,
      shapeScale: 0.28,
      distortion: 0.25,
      swirl: 0.8,
      swirlIterations: 10
    ),
    sizing: ShaderSizingParams(
      fit: .none, scale: 1.2, rotation: 44, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: -0.3,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 2.5, frame: 0)
  ),
  ShaderPreset(
    name: "Kelp",
    params: WarpParams(
      colors: [color("#dbff8f"), color("#404f3e"), color("#091316")],
      proportion: 0.67,
      softness: 0,
      shape: 1,
      shapeScale: 1,
      distortion: 0,
      swirl: 0.2,
      swirlIterations: 3
    ),
    sizing: ShaderSizingParams(
      fit: .none, scale: 0.8, rotation: 50, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 20, frame: 0)
  ),
  ShaderPreset(
    name: "Nectar",
    params: WarpParams(
      colors: [color("#151310"), color("#d3a86b"), color("#f0edea")],
      proportion: 0.24,
      softness: 1,
      shape: 2,
      shapeScale: 0.75,
      distortion: 0.21,
      swirl: 0.57,
      swirlIterations: 10
    ),
    sizing: ShaderSizingParams(
      fit: .none, scale: 2, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0.6,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 4.2, frame: 0)
  ),
  ShaderPreset(
    name: "Passion",
    params: WarpParams(
      colors: [color("#3b1515"), color("#954751"), color("#ffc085")],
      proportion: 0.5,
      softness: 1,
      shape: 0,
      shapeScale: 0.25,
      distortion: 0.09,
      swirl: 0.9,
      swirlIterations: 6
    ),
    sizing: ShaderSizingParams(
      fit: .none, scale: 2.5, rotation: 1.35, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 3, frame: 0)
  ),
]

public let godRaysPresets: [GodRaysPreset] = [
  ShaderPreset(
    name: "Default",
    params: GodRaysParams(
      colorBack: color("#000000"),
      colorBloom: color("#0000ff"),
      colors: [color("#a600ff6e"), color("#6200fff0"), color("#ffffff"), color("#33fff5")],
      density: 0.3,
      spotty: 0.3,
      midSize: 0.2,
      midIntensity: 0.4,
      intensity: 0.8,
      bloom: 0.4
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: -0.55,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0.75, frame: 0)
  ),
  ShaderPreset(
    name: "Warp",
    params: GodRaysParams(
      colorBack: color("#000000"),
      colorBloom: color("#222288"),
      colors: [color("#ff47d4"), color("#ff8c00"), color("#ffffff")],
      density: 0.45,
      spotty: 0.15,
      midSize: 0.33,
      midIntensity: 0.4,
      intensity: 0.79,
      bloom: 0.4
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 2, frame: 0)
  ),
  ShaderPreset(
    name: "Linear",
    params: GodRaysParams(
      colorBack: color("#000000"),
      colorBloom: color("#eeeeee"),
      colors: [color("#ffffff1f"), color("#ffffff3d"), color("#ffffff29")],
      density: 0.41,
      spotty: 0.25,
      midSize: 0.1,
      midIntensity: 0.75,
      intensity: 0.79,
      bloom: 1
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0.2, offsetY: -0.8,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0.5, frame: 0)
  ),
  ShaderPreset(
    name: "Ether",
    params: GodRaysParams(
      colorBack: color("#090f1d"),
      colorBloom: color("#ffffff"),
      colors: [color("#148effa6"), color("#c4dffebe"), color("#232a47")],
      density: 0.03,
      spotty: 0.77,
      midSize: 0.1,
      midIntensity: 0.6,
      intensity: 0.6,
      bloom: 0.6
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: -0.6, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 1, frame: 0)
  ),
]

public let spiralPresets: [SpiralPreset] = [
  ShaderPreset(
    name: "Default",
    params: SpiralParams(
      colorBack: color("#001429"),
      colorFront: color("#79D1FF"),
      density: 1,
      distortion: 0,
      strokeWidth: 0.5,
      strokeTaper: 0,
      strokeCap: 0,
      noise: 0,
      noiseFrequency: 0,
      softness: 0
    ),
    sizing: ShaderSizingParams(
      fit: .none, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 1, frame: 0)
  ),
  ShaderPreset(
    name: "Jungle",
    params: SpiralParams(
      colorBack: color("#a0ef2a"),
      colorFront: color("#288b18"),
      density: 0.5,
      distortion: 0,
      strokeWidth: 0.5,
      strokeTaper: 0,
      strokeCap: 0,
      noise: 1,
      noiseFrequency: 0.25,
      softness: 0
    ),
    sizing: ShaderSizingParams(
      fit: .none, scale: 1.3, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0.75, frame: 0)
  ),
  ShaderPreset(
    name: "Droplet",
    params: SpiralParams(
      colorBack: color("#effafe"),
      colorFront: color("#bf40a0"),
      density: 0.9,
      distortion: 0,
      strokeWidth: 0.75,
      strokeTaper: 0.18,
      strokeCap: 1,
      noise: 0.74,
      noiseFrequency: 0.33,
      softness: 0.02
    ),
    sizing: ShaderSizingParams(
      fit: .none, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 1, frame: 0)
  ),
  ShaderPreset(
    name: "Swirl",
    params: SpiralParams(
      colorBack: color("#b3e6d9"),
      colorFront: color("#1a2b4d"),
      density: 0.2,
      distortion: 0,
      strokeWidth: 0.5,
      strokeTaper: 0,
      strokeCap: 0,
      noise: 0,
      noiseFrequency: 0.3,
      softness: 0.5
    ),
    sizing: ShaderSizingParams(
      fit: .none, scale: 0.45, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 1, frame: 0)
  ),
]

public let swirlPresets: [SwirlPreset] = [
  ShaderPreset(
    name: "Default",
    params: SwirlParams(
      colorBack: color("#330000"),
      colors: [color("#ffd1d1"), color("#ff8a8a"), color("#660000")],
      bandCount: 4,
      twist: 0.1,
      center: 0.2,
      proportion: 0.5,
      softness: 0,
      noise: 0.2,
      noiseFrequency: 0.4
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0.32, frame: 0)
  ),
  ShaderPreset(
    name: "007",
    params: SwirlParams(
      colorBack: color("#E9E7DA"),
      colors: [color("#000000")],
      bandCount: 5,
      twist: 0.3,
      center: 0,
      proportion: 0,
      softness: 0,
      noise: 0,
      noiseFrequency: 0.5
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 1, frame: 0)
  ),
  ShaderPreset(
    name: "Opening",
    params: SwirlParams(
      colorBack: color("#ff8b61"),
      colors: [color("#fefff0"), color("#ffd8bd"), color("#ff8b61")],
      bandCount: 2,
      twist: 0.3,
      center: 0.2,
      proportion: 0.5,
      softness: 0,
      noise: 0,
      noiseFrequency: 0
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: -0.4, offsetY: 1,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0.5, frame: 0)
  ),
  ShaderPreset(
    name: "Candy",
    params: SwirlParams(
      colorBack: color("#ffcd66"),
      colors: [color("#6bbceb"), color("#d7b3ff"), color("#ff9fff")],
      bandCount: 2,
      twist: 0.15,
      center: 0.2,
      proportion: 0.5,
      softness: 1,
      noise: 0,
      noiseFrequency: 0.5
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 1, frame: 0)
  ),
]

public let ditheringPresets: [DitheringPreset] = [
  ShaderPreset(
    name: "Default",
    params: DitheringParams(
      colorBack: color("#000000"),
      colorFront: color("#00b2ff"),
      shape: 7,
      type: 3,
      size: 2
    ),
    sizing: ShaderSizingParams(
      fit: .none, scale: 0.6, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 1, frame: 0)
  ),
  ShaderPreset(
    name: "Warp",
    params: DitheringParams(
      colorBack: color("#301c2a"),
      colorFront: color("#56ae6c"),
      shape: 2,
      type: 3,
      size: 2.5
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 1, frame: 0)
  ),
  ShaderPreset(
    name: "Sine Wave",
    params: DitheringParams(
      colorBack: color("#730d54"),
      colorFront: color("#00becc"),
      shape: 4,
      type: 3,
      size: 11
    ),
    sizing: ShaderSizingParams(
      fit: .none, scale: 1.2, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 1, frame: 0)
  ),
  ShaderPreset(
    name: "Ripple",
    params: DitheringParams(
      colorBack: color("#603520"),
      colorFront: color("#c67953"),
      shape: 5,
      type: 2,
      size: 3
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 1, frame: 0)
  ),
  ShaderPreset(
    name: "Bugs",
    params: DitheringParams(
      colorBack: color("#000000"),
      colorFront: color("#008000"),
      shape: 3,
      type: 1,
      size: 9
    ),
    sizing: ShaderSizingParams(
      fit: .none, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 1, frame: 0)
  ),
  ShaderPreset(
    name: "Swirl",
    params: DitheringParams(
      colorBack: color("#00000000"),
      colorFront: color("#47a8e1"),
      shape: 6,
      type: 4,
      size: 2
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 1, frame: 0)
  ),
]

public let grainGradientPresets: [GrainGradientPreset] = [
  ShaderPreset(
    name: "Default",
    params: GrainGradientParams(
      colorBack: color("#000000"),
      colors: [color("#7300ff"), color("#eba8ff"), color("#00bfff"), color("#2a00ff")],
      softness: 0.5,
      intensity: 0.5,
      noise: 0.25,
      shape: 4
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 1, frame: 0)
  ),
  ShaderPreset(
    name: "Wave",
    params: GrainGradientParams(
      colorBack: color("#000a0f"),
      colors: [color("#c4730b"), color("#bdad5f"), color("#d8ccc7")],
      softness: 0.7,
      intensity: 0.15,
      noise: 0.5,
      shape: 1
    ),
    sizing: ShaderSizingParams(
      fit: .none, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 1, frame: 0)
  ),
  ShaderPreset(
    name: "Dots",
    params: GrainGradientParams(
      colorBack: color("#0a0000"),
      colors: [color("#6f0000"), color("#0080ff"), color("#f2ebc9"), color("#33cc33")],
      softness: 1,
      intensity: 1,
      noise: 0.7,
      shape: 2
    ),
    sizing: ShaderSizingParams(
      fit: .none, scale: 0.6, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 1, frame: 0)
  ),
  ShaderPreset(
    name: "Truchet",
    params: GrainGradientParams(
      colorBack: color("#0a0000"),
      colors: [color("#6f2200"), color("#eabb7c"), color("#39b523")],
      softness: 0,
      intensity: 0.2,
      noise: 1,
      shape: 3
    ),
    sizing: ShaderSizingParams(
      fit: .none, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 1, frame: 0)
  ),
  ShaderPreset(
    name: "Ripple",
    params: GrainGradientParams(
      colorBack: color("#140a00"),
      colors: [color("#6f2d00"), color("#88ddae"), color("#2c0b1d")],
      softness: 0.5,
      intensity: 0.5,
      noise: 0.5,
      shape: 5
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 0.5, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 1, frame: 0)
  ),
  ShaderPreset(
    name: "Blob",
    params: GrainGradientParams(
      colorBack: color("#0f0e18"),
      colors: [color("#3e6172"), color("#a49b74"), color("#568c50")],
      softness: 0,
      intensity: 0.15,
      noise: 0.5,
      shape: 6
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 1.3, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 1, frame: 0)
  ),
]

public let pulsingBorderPresets: [PulsingBorderPreset] = [
  ShaderPreset(
    name: "Default",
    params: PulsingBorderParams(
      colorBack: color("#000000"),
      colors: [color("#0dc1fd"), color("#d915ef"), color("#ff3f2ecc")],
      roundness: 0.25,
      thickness: 0.1,
      marginLeft: 0,
      marginRight: 0,
      marginTop: 0,
      marginBottom: 0,
      aspectRatio: 0,
      softness: 0.75,
      intensity: 0.2,
      bloom: 0.25,
      spots: 5,
      spotSize: 0.5,
      pulse: 0.25,
      smoke: 0.3,
      smokeSize: 0.6
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 0.6, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 1, frame: 0)
  ),
  ShaderPreset(
    name: "Circle",
    params: PulsingBorderParams(
      colorBack: color("#000000"),
      colors: [color("#0dc1fd"), color("#d915ef"), color("#ff3f2ecc")],
      roundness: 1,
      thickness: 0,
      marginLeft: 0,
      marginRight: 0,
      marginTop: 0,
      marginBottom: 0,
      aspectRatio: 1,
      softness: 0.75,
      intensity: 0.2,
      bloom: 0.45,
      spots: 3,
      spotSize: 0.4,
      pulse: 0.5,
      smoke: 1,
      smokeSize: 0
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 0.6, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 1, frame: 0)
  ),
  ShaderPreset(
    name: "Northern lights",
    params: PulsingBorderParams(
      colorBack: color("#0c182c"),
      colors: [
        color("#4c4794"), color("#774a7d"), color("#12694a"), color("#0aff78"), color("#4733cc"),
      ],
      roundness: 0,
      thickness: 1,
      marginLeft: 0,
      marginRight: 0,
      marginTop: 0,
      marginBottom: 0,
      aspectRatio: 0,
      softness: 1,
      intensity: 0.1,
      bloom: 0.2,
      spots: 4,
      spotSize: 0.25,
      pulse: 0,
      smoke: 0.32,
      smokeSize: 0.5
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 1.1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0.18, frame: 0)
  ),
  ShaderPreset(
    name: "Solid line",
    params: PulsingBorderParams(
      colorBack: color("#00000000"),
      colors: [color("#81ADEC")],
      roundness: 0,
      thickness: 0.05,
      marginLeft: 0,
      marginRight: 0,
      marginTop: 0,
      marginBottom: 0,
      aspectRatio: 0,
      softness: 0,
      intensity: 0,
      bloom: 0.15,
      spots: 4,
      spotSize: 1,
      pulse: 0,
      smoke: 0,
      smokeSize: 0
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 1, frame: 0)
  ),
]

public let colorPanelsPresets: [ColorPanelsPreset] = [
  ShaderPreset(
    name: "Default",
    params: ColorPanelsParams(
      colors: [
        color("#ff9d00"), color("#fd4f30"), color("#809bff"), color("#6d2eff"), color("#333aff"),
        color("#f15cff"), color("#ffd557"),
      ],
      colorBack: color("#000000"),
      density: 3,
      angle1: 0,
      angle2: 0,
      length: 1.1,
      edges: 0,
      blur: 0,
      fadeIn: 1,
      fadeOut: 0.3,
      gradient: 0
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 0.8, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0.5, frame: 0)
  ),
  ShaderPreset(
    name: "Glass",
    params: ColorPanelsParams(
      colors: [color("#00cfff"), color("#ff2d55"), color("#34c759"), color("#af52de")],
      colorBack: color("#ffffff00"),
      density: 1.6,
      angle1: 0.3,
      angle2: 0.3,
      length: 1,
      edges: 1,
      blur: 0.25,
      fadeIn: 0.85,
      fadeOut: 0.3,
      gradient: 0
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 1, rotation: 112, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 1, frame: 0)
  ),
  ShaderPreset(
    name: "Gradient",
    params: ColorPanelsParams(
      colors: [
        color("#f2ff00"), color("#00000000"), color("#00000000"), color("#5a0283"),
        color("#005eff"),
      ],
      colorBack: color("#8ffff2"),
      density: 1.65,
      angle1: 0.4,
      angle2: 0.4,
      length: 3,
      edges: 0,
      blur: 0.5,
      fadeIn: 1,
      fadeOut: 0.39,
      gradient: 0.78
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 1.72, rotation: 270, originX: 0.5, originY: 0.5, offsetX: 0.18,
      offsetY: 0, worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0.5, frame: 0)
  ),
  ShaderPreset(
    name: "Opening",
    params: ColorPanelsParams(
      colors: [color("#00ffff")],
      colorBack: color("#570044"),
      density: 2.21,
      angle1: -1,
      angle2: -1,
      length: 0.52,
      edges: 0,
      blur: 0,
      fadeIn: 0,
      fadeOut: 1,
      gradient: 0
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 2.32, rotation: 360, originX: 0.5, originY: 0.5, offsetX: -0.3,
      offsetY: 0.6, worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 2, frame: 0)
  ),
]

public let staticMeshGradientPresets: [StaticMeshGradientPreset] = [
  ShaderPreset(
    name: "Default",
    params: StaticMeshGradientParams(
      colors: [color("#ffad0a"), color("#6200ff"), color("#e2a3ff"), color("#ff99fd")],
      positions: 2,
      waveX: 1,
      waveXShift: 0.6,
      waveY: 1,
      waveYShift: 0.21,
      mixing: 0.93,
      grainMixer: 0,
      grainOverlay: 0
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 1, rotation: 270, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0, frame: 0)
  ),
  ShaderPreset(
    name: "1960s",
    params: StaticMeshGradientParams(
      colors: [color("#000000"), color("#082400"), color("#b1aa91"), color("#8e8c15")],
      positions: 42,
      waveX: 0.45,
      waveXShift: 0,
      waveY: 1,
      waveYShift: 0,
      mixing: 0,
      grainMixer: 0.37,
      grainOverlay: 0.78
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0, frame: 0)
  ),
  ShaderPreset(
    name: "Sunset",
    params: StaticMeshGradientParams(
      colors: [color("#264653"), color("#9c2b2b"), color("#f4a261"), color("#ffffff")],
      positions: 0,
      waveX: 0.6,
      waveXShift: 0.7,
      waveY: 0.7,
      waveYShift: 0.7,
      mixing: 0.5,
      grainMixer: 0,
      grainOverlay: 0
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0, frame: 0)
  ),
  ShaderPreset(
    name: "Sea",
    params: StaticMeshGradientParams(
      colors: [color("#013b65"), color("#03738c"), color("#a3d3ff"), color("#f2faef")],
      positions: 0,
      waveX: 0.53,
      waveXShift: 0,
      waveY: 0.95,
      waveYShift: 0.64,
      mixing: 0.5,
      grainMixer: 0,
      grainOverlay: 0
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0, frame: 0)
  ),
]

public let staticRadialGradientPresets: [StaticRadialGradientPreset] = [
  ShaderPreset(
    name: "Default",
    params: StaticRadialGradientParams(
      colorBack: color("#000000"),
      colors: [color("#00bbff"), color("#00ffe1"), color("#ffffff")],
      radius: 0.8,
      focalDistance: 0.99,
      focalAngle: 0,
      falloff: 0.24,
      mixing: 0.5,
      distortion: 0,
      distortionShift: 0,
      distortionFreq: 12,
      grainMixer: 0,
      grainOverlay: 0
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0, frame: 0)
  ),
  ShaderPreset(
    name: "Lo-Fi",
    params: StaticRadialGradientParams(
      colorBack: color("#2e1f27"),
      colors: [color("#d72638"), color("#3f88c5"), color("#f49d37")],
      radius: 1,
      focalDistance: 0,
      focalAngle: 0,
      falloff: 0.9,
      mixing: 0.7,
      distortion: 0,
      distortionShift: 0,
      distortionFreq: 12,
      grainMixer: 1,
      grainOverlay: 0.5
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0, frame: 0)
  ),
  ShaderPreset(
    name: "Cross Section",
    params: StaticRadialGradientParams(
      colorBack: color("#3d348b"),
      colors: [color("#7678ed"), color("#f7b801"), color("#f18701"), color("#37a066")],
      radius: 1,
      focalDistance: 0,
      focalAngle: 0,
      falloff: 0,
      mixing: 0,
      distortion: 1,
      distortionShift: 0,
      distortionFreq: 12,
      grainMixer: 0,
      grainOverlay: 0
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0, frame: 0)
  ),
  ShaderPreset(
    name: "Radial",
    params: StaticRadialGradientParams(
      colorBack: color("#264653"),
      colors: [color("#9c2b2b"), color("#f4a261"), color("#ffffff")],
      radius: 1,
      focalDistance: 0,
      focalAngle: 0,
      falloff: 0,
      mixing: 1,
      distortion: 0,
      distortionShift: 0,
      distortionFreq: 12,
      grainMixer: 0,
      grainOverlay: 0
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0, frame: 0)
  ),
]

public let paperTexturePresets: [PaperTexturePreset] = [
  ShaderPreset(
    name: "Default",
    params: PaperTextureParams(
      colorFront: color("#9fadbc"),
      colorBack: color("#ffffff"),
      contrast: 0.3,
      roughness: 0.4,
      fiber: 0.3,
      fiberSize: 0.2,
      crumples: 0.3,
      foldCount: 5,
      folds: 0.65,
      fade: 0,
      crumpleSize: 0.35,
      drops: 0.2,
      seed: 5.8
    ),
    sizing: ShaderSizingParams(
      fit: .cover, scale: 0.6, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0, frame: 0)
  ),
  ShaderPreset(
    name: "Cardboard",
    params: PaperTextureParams(
      colorFront: color("#c7b89e"),
      colorBack: color("#999180"),
      contrast: 0.4,
      roughness: 0,
      fiber: 0.35,
      fiberSize: 0.14,
      crumples: 0.7,
      foldCount: 1,
      folds: 0,
      fade: 0,
      crumpleSize: 0.1,
      drops: 0.1,
      seed: 1.6
    ),
    sizing: ShaderSizingParams(
      fit: .cover, scale: 0.6, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0, frame: 0)
  ),
  ShaderPreset(
    name: "Abstract",
    params: PaperTextureParams(
      colorFront: color("#00eeff"),
      colorBack: color("#ff0a81"),
      contrast: 0.85,
      roughness: 0,
      fiber: 0.1,
      fiberSize: 0.2,
      crumples: 0,
      foldCount: 3,
      folds: 1,
      fade: 0,
      crumpleSize: 0.3,
      drops: 0.2,
      seed: 2.2
    ),
    sizing: ShaderSizingParams(
      fit: .cover, scale: 0.6, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0, frame: 0)
  ),
  ShaderPreset(
    name: "Details",
    params: PaperTextureParams(
      colorFront: color("#00000000"),
      colorBack: color("#00000000"),
      contrast: 0,
      roughness: 1,
      fiber: 0.27,
      fiberSize: 0.22,
      crumples: 1,
      foldCount: 15,
      folds: 1,
      fade: 0,
      crumpleSize: 0.5,
      drops: 0,
      seed: 6
    ),
    sizing: ShaderSizingParams(
      fit: .cover, scale: 3, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0, frame: 0)
  ),
]

public let flutedGlassPresets: [FlutedGlassPreset] = [
  ShaderPreset(
    name: "Default",
    params: FlutedGlassParams(
      colorBack: color("#00000000"),
      colorShadow: color("#000000"),
      colorHighlight: color("#ffffff"),
      shadows: 0.25,
      size: 0.5,
      angle: 0,
      distortion: 0.5,
      shift: 0,
      blur: 0,
      edges: 0.25,
      marginLeft: 0,
      marginRight: 0,
      marginTop: 0,
      marginBottom: 0,
      stretch: 0,
      distortionShape: 1,
      highlights: 0.1,
      shape: 1,
      grainMixer: 0,
      grainOverlay: 0
    ),
    sizing: ShaderSizingParams(
      fit: .cover, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0, frame: 0)
  ),
  ShaderPreset(
    name: "Abstract",
    params: FlutedGlassParams(
      colorBack: color("#00000000"),
      colorShadow: color("#000000"),
      colorHighlight: color("#ffffff"),
      shadows: 0,
      size: 0.7,
      angle: 30,
      distortion: 1,
      shift: 0,
      blur: 1,
      edges: 0.5,
      marginLeft: 0,
      marginRight: 0,
      marginTop: 0,
      marginBottom: 0,
      stretch: 1,
      distortionShape: 5,
      highlights: 0,
      shape: 2,
      grainMixer: 0.1,
      grainOverlay: 0.1
    ),
    sizing: ShaderSizingParams(
      fit: .cover, scale: 4, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0, frame: 0)
  ),
  ShaderPreset(
    name: "Waves",
    params: FlutedGlassParams(
      colorBack: color("#00000000"),
      colorShadow: color("#000000"),
      colorHighlight: color("#ffffff"),
      shadows: 0,
      size: 0.9,
      angle: 0,
      distortion: 0.5,
      shift: 0,
      blur: 0.1,
      edges: 0.5,
      marginLeft: 0,
      marginRight: 0,
      marginTop: 0,
      marginBottom: 0,
      stretch: 1,
      distortionShape: 3,
      highlights: 0,
      shape: 3,
      grainMixer: 0,
      grainOverlay: 0.05
    ),
    sizing: ShaderSizingParams(
      fit: .cover, scale: 1.2, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0, frame: 0)
  ),
  ShaderPreset(
    name: "Folds",
    params: FlutedGlassParams(
      colorBack: color("#00000000"),
      colorShadow: color("#000000"),
      colorHighlight: color("#ffffff"),
      shadows: 0.4,
      size: 0.4,
      angle: 0,
      distortion: 0.75,
      shift: 0,
      blur: 0.25,
      edges: 0.5,
      marginLeft: 0.1,
      marginRight: 0.1,
      marginTop: 0.1,
      marginBottom: 0.1,
      stretch: 0,
      distortionShape: 4,
      highlights: 0,
      shape: 1,
      grainMixer: 0,
      grainOverlay: 0
    ),
    sizing: ShaderSizingParams(
      fit: .cover, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0, frame: 0)
  ),
]

public let waterPresets: [WaterPreset] = [
  ShaderPreset(
    name: "Default",
    params: WaterParams(
      colorBack: color("#909090"),
      colorHighlight: color("#ffffff"),
      highlights: 0.07,
      layering: 0.5,
      edges: 0.8,
      caustic: 0.1,
      waves: 0.3,
      size: 1
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 0.8, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 1, frame: 0)
  ),
  ShaderPreset(
    name: "Slow-mo",
    params: WaterParams(
      colorBack: color("#909090"),
      colorHighlight: color("#ffffff"),
      highlights: 0.4,
      layering: 0,
      edges: 0,
      caustic: 0.2,
      waves: 0,
      size: 0.7
    ),
    sizing: ShaderSizingParams(
      fit: .cover, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0.1, frame: 0)
  ),
  ShaderPreset(
    name: "Abstract",
    params: WaterParams(
      colorBack: color("#909090"),
      colorHighlight: color("#ffffff"),
      highlights: 0,
      layering: 0,
      edges: 1,
      caustic: 0.4,
      waves: 1,
      size: 0.15
    ),
    sizing: ShaderSizingParams(
      fit: .cover, scale: 3, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 1, frame: 0)
  ),
  ShaderPreset(
    name: "Streaming",
    params: WaterParams(
      colorBack: color("#909090"),
      colorHighlight: color("#ffffff"),
      highlights: 0,
      layering: 0,
      edges: 0,
      caustic: 0,
      waves: 0.5,
      size: 0.5
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 0.4, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 2, frame: 0)
  ),
]

public let imageDitheringPresets: [ImageDitheringPreset] = [
  ShaderPreset(
    name: "Default",
    params: ImageDitheringParams(
      colorFront: color("#94ffaf"),
      colorBack: color("#000c38"),
      colorHighlight: color("#eaff94"),
      type: 4,
      size: 2,
      colorSteps: 2,
      originalColors: 0,
      inverted: 0
    ),
    sizing: ShaderSizingParams(
      fit: .cover, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0, frame: 0)
  ),
  ShaderPreset(
    name: "Noise",
    params: ImageDitheringParams(
      colorFront: color("#a2997c"),
      colorBack: color("#000000"),
      colorHighlight: color("#ededed"),
      type: 1,
      size: 1,
      colorSteps: 1,
      originalColors: 0,
      inverted: 0
    ),
    sizing: ShaderSizingParams(
      fit: .cover, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0, frame: 0)
  ),
  ShaderPreset(
    name: "Retro",
    params: ImageDitheringParams(
      colorFront: color("#eeeeee"),
      colorBack: color("#5452ff"),
      colorHighlight: color("#eeeeee"),
      type: 2,
      size: 3,
      colorSteps: 1,
      originalColors: 1,
      inverted: 0
    ),
    sizing: ShaderSizingParams(
      fit: .cover, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0, frame: 0)
  ),
  ShaderPreset(
    name: "Natural",
    params: ImageDitheringParams(
      colorFront: color("#ffffff"),
      colorBack: color("#000000"),
      colorHighlight: color("#ffffff"),
      type: 4,
      size: 2,
      colorSteps: 5,
      originalColors: 1,
      inverted: 0
    ),
    sizing: ShaderSizingParams(
      fit: .cover, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0, frame: 0)
  ),
]

public let heatmapPresets: [HeatmapPreset] = [
  ShaderPreset(
    name: "Default",
    params: HeatmapParams(
      colorBack: color("#000000"),
      colors: [
        color("#11206a"), color("#1f3ba2"), color("#2f63e7"), color("#6bd7ff"), color("#ffe679"),
        color("#ff991e"), color("#ff4c00"),
      ],
      contour: 0.5,
      angle: 0,
      noise: 0,
      innerGlow: 0.5,
      outerGlow: 0.5
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 0.75, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 1, frame: 0)
  ),
  ShaderPreset(
    name: "Sepia",
    params: HeatmapParams(
      colorBack: color("#000000"),
      colors: [color("#997F45"), color("#ffffff")],
      contour: 0.5,
      angle: 0,
      noise: 0.75,
      innerGlow: 0.5,
      outerGlow: 0.5
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 0.75, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0.5, frame: 0)
  ),
]

public let liquidMetalPresets: [LiquidMetalPreset] = [
  ShaderPreset(
    name: "Default",
    params: LiquidMetalParams(
      colorBack: color("#AAAAAC"),
      colorTint: color("#ffffff"),
      repetition: 2,
      softness: 0.1,
      shiftRed: 0.3,
      shiftBlue: 0.3,
      distortion: 0.07,
      contour: 0.4,
      angle: 70,
      shape: 3
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 0.6, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 1, frame: 0)
  ),
  ShaderPreset(
    name: "Noir",
    params: LiquidMetalParams(
      colorBack: color("#000000"),
      colorTint: color("#606060"),
      repetition: 1.5,
      softness: 0.45,
      shiftRed: 0,
      shiftBlue: 0,
      distortion: 0,
      contour: 0,
      angle: 90,
      shape: 3
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 0.6, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 1, frame: 0)
  ),
  ShaderPreset(
    name: "Backdrop",
    params: LiquidMetalParams(
      colorBack: color("#AAAAAC"),
      colorTint: color("#ffffff"),
      repetition: 1.5,
      softness: 0.05,
      shiftRed: 0.3,
      shiftBlue: 0.3,
      distortion: 0.1,
      contour: 0.4,
      angle: 90,
      shape: 0
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 1, frame: 0)
  ),
  ShaderPreset(
    name: "Stripes",
    params: LiquidMetalParams(
      colorBack: color("#000000"),
      colorTint: color("#2c5d72"),
      repetition: 6,
      softness: 0.8,
      shiftRed: 1,
      shiftBlue: -1,
      distortion: 0.4,
      contour: 0.4,
      angle: 0,
      shape: 1
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 0.6, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 1, frame: 0)
  ),
]

public let halftoneDotsPresets: [HalftoneDotsPreset] = [
  ShaderPreset(
    name: "Default",
    params: HalftoneDotsParams(
      colorFront: color("#2b2b2b"),
      colorBack: color("#f2f1e8"),
      size: 0.5,
      grid: 1,
      radius: 1.25,
      contrast: 0.4,
      originalColors: 0,
      inverted: 0,
      grainMixer: 0.2,
      grainOverlay: 0.2,
      grainSize: 0.5,
      type: 1
    ),
    sizing: ShaderSizingParams(
      fit: .cover, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0, frame: 0)
  ),
  ShaderPreset(
    name: "LED screen",
    params: HalftoneDotsParams(
      colorFront: color("#29ff7b"),
      colorBack: color("#000000"),
      size: 0.5,
      grid: 0,
      radius: 1.5,
      contrast: 0.3,
      originalColors: 0,
      inverted: 0,
      grainMixer: 0,
      grainOverlay: 0,
      grainSize: 0.5,
      type: 3
    ),
    sizing: ShaderSizingParams(
      fit: .cover, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0, frame: 0)
  ),
  ShaderPreset(
    name: "Mosaic",
    params: HalftoneDotsParams(
      colorFront: color("#b2aeae"),
      colorBack: color("#000000"),
      size: 0.6,
      grid: 1,
      radius: 2,
      contrast: 0.01,
      originalColors: 1,
      inverted: 0,
      grainMixer: 0,
      grainOverlay: 0,
      grainSize: 0.5,
      type: 0
    ),
    sizing: ShaderSizingParams(
      fit: .cover, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0, frame: 0)
  ),
  ShaderPreset(
    name: "Round and square",
    params: HalftoneDotsParams(
      colorFront: color("#ff8000"),
      colorBack: color("#141414"),
      size: 0.8,
      grid: 0,
      radius: 1,
      contrast: 1,
      originalColors: 0,
      inverted: 1,
      grainMixer: 0.05,
      grainOverlay: 0.3,
      grainSize: 0.5,
      type: 2
    ),
    sizing: ShaderSizingParams(
      fit: .cover, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0, frame: 0)
  ),
]

public let halftoneCmykPresets: [HalftoneCmykPreset] = [
  ShaderPreset(
    name: "Default",
    params: HalftoneCmykParams(
      colorBack: color("#fbfaf5"),
      colorC: color("#00b4ff"),
      colorM: color("#fc519f"),
      colorY: color("#ffd800"),
      colorK: color("#231f20"),
      size: 0.2,
      contrast: 1,
      softness: 1,
      grainSize: 0.5,
      grainMixer: 0,
      grainOverlay: 0,
      gridNoise: 0.2,
      floodC: 0.15,
      floodM: 0,
      floodY: 0,
      floodK: 0,
      gainC: 0.3,
      gainM: 0,
      gainY: 0.2,
      gainK: 0,
      type: 1
    ),
    sizing: ShaderSizingParams(
      fit: .cover, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0, frame: 0)
  ),
  ShaderPreset(
    name: "Drops",
    params: HalftoneCmykParams(
      colorBack: color("#eeefd7"),
      colorC: color("#00b2ff"),
      colorM: color("#fc4f4f"),
      colorY: color("#ffd900"),
      colorK: color("#231f20"),
      size: 0.88,
      contrast: 1.15,
      softness: 0,
      grainSize: 0.01,
      grainMixer: 0.05,
      grainOverlay: 0.25,
      gridNoise: 0.5,
      floodC: 0.15,
      floodM: 0,
      floodY: 0,
      floodK: 0,
      gainC: 1,
      gainM: 0.44,
      gainY: -1,
      gainK: 0,
      type: 1
    ),
    sizing: ShaderSizingParams(
      fit: .cover, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0, frame: 0)
  ),
  ShaderPreset(
    name: "Newspaper",
    params: HalftoneCmykParams(
      colorBack: color("#f2f1e8"),
      colorC: color("#7a7a75"),
      colorM: color("#7a7a75"),
      colorY: color("#7a7a75"),
      colorK: color("#231f20"),
      size: 0.01,
      contrast: 2,
      softness: 0.2,
      grainSize: 0,
      grainMixer: 0,
      grainOverlay: 0.2,
      gridNoise: 0.6,
      floodC: 0,
      floodM: 0,
      floodY: 0,
      floodK: 0.1,
      gainC: -0.17,
      gainM: -0.45,
      gainY: -0.45,
      gainK: 0,
      type: 0
    ),
    sizing: ShaderSizingParams(
      fit: .cover, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0, frame: 0)
  ),
  ShaderPreset(
    name: "Vintage",
    params: HalftoneCmykParams(
      colorBack: color("#fffaf0"),
      colorC: color("#59afc5"),
      colorM: color("#d8697c"),
      colorY: color("#fad85c"),
      colorK: color("#2d2824"),
      size: 0.2,
      contrast: 1.25,
      softness: 0.4,
      grainSize: 0.5,
      grainMixer: 0.15,
      grainOverlay: 0.1,
      gridNoise: 0.45,
      floodC: 0.15,
      floodM: 0,
      floodY: 0,
      floodK: 0,
      gainC: 0.3,
      gainM: 0,
      gainY: 0.2,
      gainK: 0,
      type: 2
    ),
    sizing: ShaderSizingParams(
      fit: .cover, scale: 1, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0, frame: 0)
  ),
]

public let gemSmokePresets: [GemSmokePreset] = [
  ShaderPreset(
    name: "Default",
    params: GemSmokeParams(
      colors: [color("#333333"), color("#e7e6df")],
      colorBack: color("#f0efea"),
      colorInner: color("#fafaf5"),
      innerDistortion: 0.8,
      outerDistortion: 0.6,
      outerGlow: 0.55,
      innerGlow: 1,
      offset: 0,
      angle: 0,
      size: 0.8,
      shape: 3
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 0.6, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 1, frame: 0)
  ),
  ShaderPreset(
    name: "Fire",
    params: GemSmokeParams(
      colors: [color("#fe5b16"), color("#f7ff61"), color("#ffffff")],
      colorBack: color("#000000"),
      colorInner: color("#000000"),
      innerDistortion: 0.6,
      outerDistortion: 0.8,
      outerGlow: 1,
      innerGlow: 0.65,
      offset: 0,
      angle: 0,
      size: 0.8,
      shape: 3
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 0.6, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 1, frame: 0)
  ),
  ShaderPreset(
    name: "Fluorescent",
    params: GemSmokeParams(
      colors: [color("#2fb64c"), color("#cdff61"), color("#ffffff")],
      colorBack: color("#000000"),
      colorInner: color("#000000"),
      innerDistortion: 1,
      outerDistortion: 0.8,
      outerGlow: 0,
      innerGlow: 1,
      offset: 0,
      angle: 0,
      size: 0.8,
      shape: 3
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 0.6, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 1, frame: 0)
  ),
  ShaderPreset(
    name: "Infrared",
    params: GemSmokeParams(
      colors: [
        color("#ff9900"), color("#fff67a"), color("#dcff52"), color("#00ffbb"), color("#0077ff"),
      ],
      colorBack: color("#cd28dc"),
      colorInner: color("#00000000"),
      innerDistortion: 1,
      outerDistortion: 1,
      outerGlow: 1,
      innerGlow: 1,
      offset: 0.2,
      angle: 0,
      size: 1,
      shape: 3
    ),
    sizing: ShaderSizingParams(
      fit: .contain, scale: 0.6, rotation: 0, originX: 0.5, originY: 0.5, offsetX: 0, offsetY: 0,
      worldWidth: 0, worldHeight: 0),
    motion: ShaderMotionParams(speed: 0.5, frame: 0)
  ),
]
