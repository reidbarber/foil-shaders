import CoreGraphics
import Foundation
import simd

private func color(_ value: String) -> SIMD4<Float> {
  (ShaderColor(value) ?? .black).rgba
}

private let defaultColors = [
  color("#eb619d"),
  color("#47a3f2"),
  color("#73dc99"),
]

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
      colors: defaultColors, distortion: 0.25, swirl: 0.25, grainMixer: 0.15, grainOverlay: 0.1),
    sizing: .defaultPatternSizing,
    motion: ShaderMotionParams(speed: 0.2)
  ),
  ShaderPreset(
    name: "Ink",
    params: MeshGradientParams(
      colors: [color("#0b0b0d"), color("#284cff"), color("#f04a7d")], distortion: 0.9, swirl: 0.75)
  ),
]

public let smokeRingPresets: [SmokeRingPreset] = [
  ShaderPreset(
    name: "Default", params: SmokeRingParams(colorBack: color("#050506"), colors: defaultColors),
    motion: ShaderMotionParams(speed: 0.35))
]

public let neuroNoisePresets: [NeuroNoisePreset] = [
  ShaderPreset(
    name: "Default",
    params: NeuroNoiseParams(
      colorFront: color("#f1d7a3"), colorMid: color("#59adf2"), colorBack: color("#0f1014")),
    motion: ShaderMotionParams(speed: 0.3)
  )
]

public let dotOrbitPresets: [DotOrbitPreset] = [
  ShaderPreset(
    name: "Default", params: DotOrbitParams(colorBack: color("#050506"), colors: defaultColors),
    motion: ShaderMotionParams(speed: 0.6))
]

public let dotGridPresets: [DotGridPreset] = [
  ShaderPreset(
    name: "Default",
    params: DotGridParams(
      colorBack: color("#0f0f10"), colorFill: color("#f2d99d"), colorStroke: color("#333333")),
    sizing: .defaultPatternSizing
  )
]

public let simplexNoisePresets: [SimplexNoisePreset] = [
  ShaderPreset(
    name: "Default", params: SimplexNoiseParams(colors: defaultColors),
    motion: ShaderMotionParams(speed: 0.25))
]

public let metaballsPresets: [MetaballsPreset] = [
  ShaderPreset(
    name: "Default", params: MetaballsParams(colorBack: color("#050506"), colors: defaultColors),
    motion: ShaderMotionParams(speed: 0.35))
]

public let wavesPresets: [WavesPreset] = [
  ShaderPreset(
    name: "Default", params: WavesParams(colorFront: color("#f2d9b7"), colorBack: color("#141414")),
    sizing: .defaultPatternSizing)
]

public let perlinNoisePresets: [PerlinNoisePreset] = [
  ShaderPreset(
    name: "Default",
    params: PerlinNoiseParams(colorFront: color("#ebc79e"), colorBack: color("#14141a")),
    motion: ShaderMotionParams(speed: 0.25))
]

public let voronoiPresets: [VoronoiPreset] = [
  ShaderPreset(
    name: "Default", params: VoronoiParams(colors: defaultColors),
    motion: ShaderMotionParams(speed: 0.3))
]

public let warpPresets: [WarpPreset] = [
  ShaderPreset(
    name: "Default", params: WarpParams(colors: defaultColors),
    motion: ShaderMotionParams(speed: 0.3))
]

public let godRaysPresets: [GodRaysPreset] = [
  ShaderPreset(
    name: "Default", params: GodRaysParams(colorBack: color("#050506"), colors: defaultColors),
    motion: ShaderMotionParams(speed: 0.35))
]

public let spiralPresets: [SpiralPreset] = [
  ShaderPreset(
    name: "Default",
    params: SpiralParams(colorBack: color("#101010"), colorFront: color("#f2cc99")),
    motion: ShaderMotionParams(speed: 0.35))
]

public let swirlPresets: [SwirlPreset] = [
  ShaderPreset(
    name: "Default", params: SwirlParams(colorBack: color("#0d0d10"), colors: defaultColors),
    motion: ShaderMotionParams(speed: 0.25))
]

public let ditheringPresets: [DitheringPreset] = [
  ShaderPreset(
    name: "Default",
    params: DitheringParams(colorBack: color("#0f0f10"), colorFront: color("#f2e6bf")),
    motion: ShaderMotionParams(speed: 0.25))
]

public let grainGradientPresets: [GrainGradientPreset] = [
  ShaderPreset(
    name: "Default",
    params: GrainGradientParams(colorBack: color("#050506"), colors: defaultColors),
    motion: ShaderMotionParams(speed: 0.25))
]

public let pulsingBorderPresets: [PulsingBorderPreset] = [
  ShaderPreset(
    name: "Default",
    params: PulsingBorderParams(colorBack: color("#050506"), colors: defaultColors),
    motion: ShaderMotionParams(speed: 0.35))
]

public let colorPanelsPresets: [ColorPanelsPreset] = [
  ShaderPreset(
    name: "Default", params: ColorPanelsParams(colors: defaultColors),
    motion: ShaderMotionParams(speed: 0.3))
]

public let staticMeshGradientPresets: [StaticMeshGradientPreset] = [
  ShaderPreset(
    name: "Default", params: StaticMeshGradientParams(colors: defaultColors),
    sizing: .defaultPatternSizing)
]

public let staticRadialGradientPresets: [StaticRadialGradientPreset] = [
  ShaderPreset(
    name: "Default",
    params: StaticRadialGradientParams(colorBack: color("#141414"), colors: defaultColors),
    sizing: .defaultPatternSizing)
]

public let paperTexturePresets: [PaperTexturePreset] = [
  ShaderPreset(name: "Default", params: PaperTextureParams(), sizing: .defaultPatternSizing)
]

public let flutedGlassPresets: [FlutedGlassPreset] = [
  ShaderPreset(
    name: "Default", params: FlutedGlassParams(), sizing: .defaultObjectSizing,
    image: .cgImage(AluminumFoilDefaultImageLoader.defaultImage() ?? fallbackCGImage()))
]

public let waterPresets: [WaterPreset] = [
  ShaderPreset(
    name: "Default", params: WaterParams(), sizing: .defaultObjectSizing,
    motion: ShaderMotionParams(speed: 0.35),
    image: .cgImage(AluminumFoilDefaultImageLoader.defaultImage() ?? fallbackCGImage()))
]

public let imageDitheringPresets: [ImageDitheringPreset] = [
  ShaderPreset(
    name: "Default", params: ImageDitheringParams(colorFront: color("#f2e6bf")),
    sizing: .defaultObjectSizing,
    image: .cgImage(AluminumFoilDefaultImageLoader.defaultImage() ?? fallbackCGImage()))
]

public let heatmapPresets: [HeatmapPreset] = [
  ShaderPreset(
    name: "Default",
    params: HeatmapParams(
      colorBack: color("#050506"), colors: [color("#3399ff"), color("#e68033"), color("#f2e6b3")]),
    sizing: .defaultObjectSizing, motion: ShaderMotionParams(speed: 0.3),
    image: .cgImage(AluminumFoilDefaultImageLoader.defaultImage() ?? fallbackCGImage()))
]

public let liquidMetalPresets: [LiquidMetalPreset] = [
  ShaderPreset(
    name: "Default", params: LiquidMetalParams(), sizing: .defaultObjectSizing,
    motion: ShaderMotionParams(speed: 0.3),
    image: .cgImage(AluminumFoilDefaultImageLoader.defaultImage() ?? fallbackCGImage()))
]

public let halftoneDotsPresets: [HalftoneDotsPreset] = [
  ShaderPreset(
    name: "Default", params: HalftoneDotsParams(colorFront: color("#f2e6bf")),
    sizing: .defaultObjectSizing,
    image: .cgImage(AluminumFoilDefaultImageLoader.defaultImage() ?? fallbackCGImage()))
]

public let halftoneCmykPresets: [HalftoneCmykPreset] = [
  ShaderPreset(
    name: "Default", params: HalftoneCmykParams(), sizing: .defaultObjectSizing,
    image: .cgImage(AluminumFoilDefaultImageLoader.defaultImage() ?? fallbackCGImage()))
]

public let gemSmokePresets: [GemSmokePreset] = [
  ShaderPreset(
    name: "Default",
    params: GemSmokeParams(
      colors: [color("#333333"), color("#e7e6df")], colorBack: color("#f0efea"),
      colorInner: color("#fafaf5")),
    sizing: ShaderSizingParams(fit: .contain, scale: 0.6),
    motion: ShaderMotionParams(speed: 1)
  )
]

private func fallbackCGImage() -> CGImage {
  let width = 1
  let height = 1
  let bytes = [UInt8](repeating: 255, count: 4)
  let data = Data(bytes)
  let provider = CGDataProvider(data: data as CFData)!
  return CGImage(
    width: width,
    height: height,
    bitsPerComponent: 8,
    bitsPerPixel: 32,
    bytesPerRow: 4,
    space: CGColorSpaceCreateDeviceRGB(),
    bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
    provider: provider,
    decode: nil,
    shouldInterpolate: false,
    intent: .defaultIntent
  )!
}
