import Foundation
import simd

@testable import FoilShaders

/// Builds a `ShaderConfiguration` for a manifest case by looking up the preset
/// BY NAME in the generated `Presets.swift` arrays (the same data the golden
/// generator read from the paper repo), and cross-checks the resolved Swift
/// param values against the manifest so silent drift between the two repos
/// fails loudly instead of producing confusing pixel diffs.
enum ParityConfigurationFactory {

  static func configuration(for parityCase: ParityCase, fixture: ShaderImage?) throws
    -> ShaderConfiguration
  {
    func preset<Params>(_ presets: [ShaderPreset<Params>]) throws -> ShaderPreset<Params> {
      guard let preset = presets.first(where: { $0.name == parityCase.presetName }) else {
        throw ParityError.missingPreset(shader: parityCase.shader, preset: parityCase.presetName)
      }
      return preset
    }

    let parameters: ShaderParameters
    let sizing: ShaderSizingParams
    let motion: ShaderMotionParams
    let renderOptions: ShaderRenderOptions

    func unpack<Params>(
      _ presets: [ShaderPreset<Params>], _ wrap: (Params) -> ShaderParameters
    ) throws -> (ShaderParameters, ShaderSizingParams, ShaderMotionParams, ShaderRenderOptions) {
      let preset = try preset(presets)
      try crossCheckParams(parityCase, against: preset.params)
      try crossCheckSizing(parityCase, against: preset.sizing)
      return (wrap(preset.params), preset.sizing, preset.motion, preset.renderOptions)
    }

    switch parityCase.shader {
    case "mesh-gradient":
      (parameters, sizing, motion, renderOptions) = try unpack(meshGradientPresets) {
        .meshGradient($0)
      }
    case "smoke-ring":
      (parameters, sizing, motion, renderOptions) = try unpack(smokeRingPresets) { .smokeRing($0) }
    case "neuro-noise":
      (parameters, sizing, motion, renderOptions) = try unpack(neuroNoisePresets) {
        .neuroNoise($0)
      }
    case "dot-orbit":
      (parameters, sizing, motion, renderOptions) = try unpack(dotOrbitPresets) { .dotOrbit($0) }
    case "dot-grid":
      (parameters, sizing, motion, renderOptions) = try unpack(dotGridPresets) { .dotGrid($0) }
    case "simplex-noise":
      (parameters, sizing, motion, renderOptions) = try unpack(simplexNoisePresets) {
        .simplexNoise($0)
      }
    case "metaballs":
      (parameters, sizing, motion, renderOptions) = try unpack(metaballsPresets) { .metaballs($0) }
    case "waves":
      (parameters, sizing, motion, renderOptions) = try unpack(wavesPresets) { .waves($0) }
    case "perlin-noise":
      (parameters, sizing, motion, renderOptions) = try unpack(perlinNoisePresets) {
        .perlinNoise($0)
      }
    case "voronoi":
      (parameters, sizing, motion, renderOptions) = try unpack(voronoiPresets) { .voronoi($0) }
    case "warp":
      (parameters, sizing, motion, renderOptions) = try unpack(warpPresets) { .warp($0) }
    case "god-rays":
      (parameters, sizing, motion, renderOptions) = try unpack(godRaysPresets) { .godRays($0) }
    case "spiral":
      (parameters, sizing, motion, renderOptions) = try unpack(spiralPresets) { .spiral($0) }
    case "swirl":
      (parameters, sizing, motion, renderOptions) = try unpack(swirlPresets) { .swirl($0) }
    case "dithering":
      (parameters, sizing, motion, renderOptions) = try unpack(ditheringPresets) { .dithering($0) }
    case "grain-gradient":
      (parameters, sizing, motion, renderOptions) = try unpack(grainGradientPresets) {
        .grainGradient($0)
      }
    case "pulsing-border":
      (parameters, sizing, motion, renderOptions) = try unpack(pulsingBorderPresets) {
        .pulsingBorder($0)
      }
    case "color-panels":
      (parameters, sizing, motion, renderOptions) = try unpack(colorPanelsPresets) {
        .colorPanels($0)
      }
    case "static-mesh-gradient":
      (parameters, sizing, motion, renderOptions) = try unpack(staticMeshGradientPresets) {
        .staticMeshGradient($0)
      }
    case "static-radial-gradient":
      (parameters, sizing, motion, renderOptions) = try unpack(staticRadialGradientPresets) {
        .staticRadialGradient($0)
      }
    case "paper-texture":
      (parameters, sizing, motion, renderOptions) = try unpack(paperTexturePresets) {
        .paperTexture($0)
      }
    case "fluted-glass":
      (parameters, sizing, motion, renderOptions) = try unpack(flutedGlassPresets) {
        .flutedGlass($0)
      }
    case "water":
      (parameters, sizing, motion, renderOptions) = try unpack(waterPresets) { .water($0) }
    case "image-dithering":
      (parameters, sizing, motion, renderOptions) = try unpack(imageDitheringPresets) {
        .imageDithering($0)
      }
    case "heatmap":
      (parameters, sizing, motion, renderOptions) = try unpack(heatmapPresets) { .heatmap($0) }
    case "liquid-metal":
      (parameters, sizing, motion, renderOptions) = try unpack(liquidMetalPresets) {
        .liquidMetal($0)
      }
    case "halftone-dots":
      (parameters, sizing, motion, renderOptions) = try unpack(halftoneDotsPresets) {
        .halftoneDots($0)
      }
    case "halftone-cmyk":
      (parameters, sizing, motion, renderOptions) = try unpack(halftoneCmykPresets) {
        .halftoneCmyk($0)
      }
    case "gem-smoke":
      (parameters, sizing, motion, renderOptions) = try unpack(gemSmokePresets) { .gemSmoke($0) }
    default:
      throw ParityError.unknownShader(parityCase.shader)
    }

    return ShaderConfiguration(
      parameters: parameters,
      sizing: sizing,
      motion: motion,
      renderOptions: renderOptions,
      image: parityCase.usesImage ? fixture : nil
    )
  }

  // MARK: - Cross-checks

  private static let accuracy: Double = 1e-4

  /// Walks the params struct with Mirror and compares every stored property
  /// against the manifest's `swiftParams` (resolved by the actual paper
  /// implementation at golden-generation time).
  static func crossCheckParams(_ parityCase: ParityCase, against params: Any) throws {
    let mirror = Mirror(reflecting: params)
    var checkedKeys = Set<String>()

    for child in mirror.children {
      guard let label = child.label else { continue }
      guard let expected = parityCase.swiftParams[label] else {
        throw ParityError.paramsMismatch(
          "\(parityCase.id): Swift param \"\(label)\" missing from manifest")
      }
      checkedKeys.insert(label)
      try compare(child.value, to: expected, path: "\(parityCase.id).\(label)")
    }

    let unchecked = Set(parityCase.swiftParams.keys).subtracting(checkedKeys)
    if !unchecked.isEmpty {
      throw ParityError.paramsMismatch(
        "\(parityCase.id): manifest params not present on Swift struct: \(unchecked.sorted())")
    }
  }

  static func crossCheckSizing(_ parityCase: ParityCase, against sizing: ShaderSizingParams) throws
  {
    let expected = parityCase.sizing
    let pairs: [(String, Float, Float)] = [
      ("fit", sizing.fit.rawValue, expected.fit),
      ("scale", sizing.scale, expected.scale),
      ("rotation", sizing.rotation, expected.rotation),
      ("originX", sizing.originX, expected.originX),
      ("originY", sizing.originY, expected.originY),
      ("offsetX", sizing.offsetX, expected.offsetX),
      ("offsetY", sizing.offsetY, expected.offsetY),
      ("worldWidth", sizing.worldWidth, expected.worldWidth),
      ("worldHeight", sizing.worldHeight, expected.worldHeight),
    ]
    for (name, actual, want) in pairs {
      if abs(Double(actual) - Double(want)) > accuracy {
        throw ParityError.paramsMismatch(
          "\(parityCase.id): sizing.\(name) is \(actual), manifest says \(want)")
      }
    }
  }

  private static func compare(_ value: Any, to expected: ParityValue, path: String) throws {
    switch value {
    case let scalar as Float:
      guard let want = expected.doubleValue, abs(Double(scalar) - want) <= accuracy else {
        throw ParityError.paramsMismatch("\(path): Swift has \(scalar), manifest has \(expected)")
      }
    case let value as any RawRepresentable:
      guard let rawValue = value.rawValue as? Float else {
        throw ParityError.paramsMismatch(
          "\(path): unsupported enum raw value type \(type(of: value.rawValue))")
      }
      try compare(rawValue, to: expected, path: path)
    case let color as ShaderColor:
      try compare(color.rgba, to: expected, path: path)
    case let colors as [ShaderColor]:
      guard let want = expected.arrayValue, want.count == colors.count else {
        throw ParityError.paramsMismatch(
          "\(path): Swift has \(colors.count) colors, manifest disagrees")
      }
      for (index, color) in colors.enumerated() {
        try compare(color, to: want[index], path: "\(path)[\(index)]")
      }
    case let color as SIMD4<Float>:
      guard let want = expected.arrayValue, want.count == 4 else {
        throw ParityError.paramsMismatch("\(path): manifest value is not a 4-component color")
      }
      for (index, component) in [color.x, color.y, color.z, color.w].enumerated() {
        guard let expectedComponent = want[index].doubleValue,
          abs(Double(component) - expectedComponent) <= accuracy
        else {
          throw ParityError.paramsMismatch(
            "\(path)[\(index)]: Swift has \(component), manifest has \(want[index])")
        }
      }
    case let colors as [SIMD4<Float>]:
      guard let want = expected.arrayValue, want.count == colors.count else {
        throw ParityError.paramsMismatch(
          "\(path): Swift has \(colors.count) colors, manifest disagrees")
      }
      for (index, color) in colors.enumerated() {
        try compare(color, to: want[index], path: "\(path)[\(index)]")
      }
    default:
      throw ParityError.paramsMismatch(
        "\(path): unsupported Swift param type \(type(of: value)) — extend ParityConfigurationFactory.compare"
      )
    }
  }
}
