import Foundation
import OSLog
import simd

#if DEBUG
  private let shaderParamsDiagnosticsLogger = Logger(
    subsystem: "FoilShaders",
    category: "ShaderParams"
  )
#endif

private func clampedShaderColors(
  _ colors: [ShaderColor],
  maxColorCount: Int,
  paramsType: Any.Type
) -> [ShaderColor] {
  #if DEBUG
    if colors.count > maxColorCount {
      shaderParamsDiagnosticsLogger.warning(
        "\(String(describing: paramsType), privacy: .public) received \(colors.count, privacy: .public) colors; keeping the first \(maxColorCount, privacy: .public)."
      )
    }
  #endif
  return Array(colors.prefix(maxColorCount))
}

// MARK: - Shader Sizing

/// Layout mode for mapping shader pattern or image coordinates into a view.
public enum ShaderFit: Float, Equatable, Sendable, Codable {
  /// Use shader-native coordinates without contain or cover scaling.
  case none = 0.0
  /// Scale the shader coordinate box to fit inside the view while preserving aspect ratio.
  case contain = 1.0
  /// Scale the shader coordinate box to cover the view while preserving aspect ratio.
  case cover = 2.0
}

/// Shared spatial controls applied before shader-specific parameters.
///
/// Origins and offsets are normalized against the rendered view. Rotation uses degrees.
public struct ShaderSizingParams: Equatable, Sendable, Codable {
  /// Coordinate fitting behavior.
  public var fit: ShaderFit
  /// Pattern or image scale multiplier. Values above `1` zoom in; values below `1` zoom out.
  public var scale: Float
  /// Clockwise rotation in degrees.
  public var rotation: Float
  /// Horizontal origin as a normalized fraction of the view; `0.5` is centered.
  public var originX: Float
  /// Vertical origin as a normalized fraction of the view; `0.5` is centered.
  public var originY: Float
  /// Horizontal offset in normalized shader coordinates.
  public var offsetX: Float
  /// Vertical offset in normalized shader coordinates.
  public var offsetY: Float
  /// Optional explicit content width. `0` means use the rendered view width.
  public var worldWidth: Float
  /// Optional explicit content height. `0` means use the rendered view height.
  public var worldHeight: Float

  /// Default sizing for object-like image shaders.
  public static let `default` = ShaderSizingParams(
    fit: .contain,
    scale: 1.0,
    rotation: 0.0,
    originX: 0.5,
    originY: 0.5,
    offsetX: 0.0,
    offsetY: 0.0,
    worldWidth: 0.0,
    worldHeight: 0.0
  )

  /// Creates shared shader sizing controls.
  ///
  /// - Parameters:
  ///   - fit: Coordinate fitting behavior.
  ///   - scale: Pattern or image scale multiplier. Values above `1` zoom in;
  ///     values below `1` zoom out.
  ///   - rotation: Clockwise rotation in degrees.
  ///   - originX: Horizontal origin as a normalized fraction of the view.
  ///   - originY: Vertical origin as a normalized fraction of the view.
  ///   - offsetX: Horizontal offset in normalized shader coordinates.
  ///   - offsetY: Vertical offset in normalized shader coordinates.
  ///   - worldWidth: Optional explicit content width. `0` uses the rendered view width.
  ///   - worldHeight: Optional explicit content height. `0` uses the rendered view height.
  public init(
    fit: ShaderFit = .contain,
    scale: Float = 1.0,
    rotation: Float = 0.0,
    originX: Float = 0.5,
    originY: Float = 0.5,
    offsetX: Float = 0.0,
    offsetY: Float = 0.0,
    worldWidth: Float = 0.0,
    worldHeight: Float = 0.0
  ) {
    self.fit = fit
    self.scale = scale
    self.rotation = rotation
    self.originX = originX
    self.originY = originY
    self.offsetX = offsetX
    self.offsetY = offsetY
    self.worldWidth = worldWidth
    self.worldHeight = worldHeight
  }
}

/// Animation controls shared by shaders that use time.
public struct ShaderMotionParams: Equatable, Sendable, Codable {
  /// Animation speed multiplier. `0` freezes automatic time progression.
  public var speed: Float
  /// Fixed timeline position in milliseconds. Presets and parity tests commonly use `0` and `5000`.
  public var frame: Float

  /// Creates shared animation controls.
  ///
  /// - Parameters:
  ///   - speed: Animation speed multiplier. `0` freezes automatic time progression.
  ///   - frame: Fixed timeline position in milliseconds.
  public init(speed: Float = 0.0, frame: Float = 0.0) {
    self.speed = speed
    self.frame = frame
  }
}

// MARK: - Mesh Gradient

/// Parameters for the animated mesh gradient shader.
///
/// See <doc:ParameterRanges#Mesh-Gradient> for value ranges and units.
/// Initializers keep the first `maxColorCount` colors and ignore extras.
public struct MeshGradientParams: Equatable, Sendable, Codable {
  /// Maximum number of colors stored by this params type.
  public static let maxColorCount = 10
  /// Shader colors after applying `maxColorCount` truncation.
  public var colors: [ShaderColor]
  public var distortion: Float
  public var swirl: Float
  public var grainMixer: Float
  public var grainOverlay: Float

  /// Creates mesh gradient shader parameters.
  ///
  /// See <doc:ParameterRanges#Mesh-Gradient> for each parameter's value range and unit.
  public init(
    colors: [ShaderColor],
    distortion: Float = 0.8,
    swirl: Float = 0.1,
    grainMixer: Float = 0,
    grainOverlay: Float = 0
  ) {
    self.colors = clampedShaderColors(
      colors, maxColorCount: Self.maxColorCount, paramsType: Self.self)
    self.distortion = distortion
    self.swirl = swirl
    self.grainMixer = grainMixer
    self.grainOverlay = grainOverlay
  }
}

// MARK: - Static Mesh Gradient

/// Parameters for the static mesh gradient shader.
///
/// See <doc:ParameterRanges#Static-Mesh-Gradient> for value ranges and units.
/// Initializers keep the first `maxColorCount` colors and ignore extras.
public struct StaticMeshGradientParams: Equatable, Sendable, Codable {
  /// Maximum number of colors stored by this params type.
  public static let maxColorCount = 10
  /// Shader colors after applying `maxColorCount` truncation.
  public var colors: [ShaderColor]
  public var positions: Float
  public var waveX: Float
  public var waveXShift: Float
  public var waveY: Float
  public var waveYShift: Float
  public var mixing: Float
  public var grainMixer: Float
  public var grainOverlay: Float

  /// Creates static mesh gradient shader parameters.
  ///
  /// See <doc:ParameterRanges#Static-Mesh-Gradient> for each parameter's value range and unit.
  public init(
    colors: [ShaderColor],
    positions: Float = 2.0,
    waveX: Float = 1.0,
    waveXShift: Float = 0.6,
    waveY: Float = 1.0,
    waveYShift: Float = 0.21,
    mixing: Float = 0.93,
    grainMixer: Float = 0,
    grainOverlay: Float = 0
  ) {
    self.colors = clampedShaderColors(
      colors, maxColorCount: Self.maxColorCount, paramsType: Self.self)
    self.positions = positions
    self.waveX = waveX
    self.waveXShift = waveXShift
    self.waveY = waveY
    self.waveYShift = waveYShift
    self.mixing = mixing
    self.grainMixer = grainMixer
    self.grainOverlay = grainOverlay
  }
}

// MARK: - Static Radial Gradient

/// Parameters for the static radial gradient shader.
///
/// See <doc:ParameterRanges#Static-Radial-Gradient> for value ranges and units.
/// Initializers keep the first `maxColorCount` colors and ignore extras.
public struct StaticRadialGradientParams: Equatable, Sendable, Codable {
  /// Maximum number of colors stored by this params type.
  public static let maxColorCount = 10
  public var colorBack: ShaderColor
  /// Shader colors after applying `maxColorCount` truncation.
  public var colors: [ShaderColor]
  public var radius: Float
  public var focalDistance: Float
  public var focalAngle: Float
  public var falloff: Float
  public var mixing: Float
  public var distortion: Float
  public var distortionShift: Float
  public var distortionFreq: Float
  public var grainMixer: Float
  public var grainOverlay: Float

  /// Creates static radial gradient shader parameters.
  ///
  /// See <doc:ParameterRanges#Static-Radial-Gradient> for each parameter's value range and unit.
  public init(
    colorBack: ShaderColor = ShaderColor(red: 0, green: 0, blue: 0, alpha: 1),
    colors: [ShaderColor],
    radius: Float = 0.8,
    focalDistance: Float = 0.99,
    focalAngle: Float = 0.0,
    falloff: Float = 0.24,
    mixing: Float = 0.5,
    distortion: Float = 0.0,
    distortionShift: Float = 0.0,
    distortionFreq: Float = 12.0,
    grainMixer: Float = 0,
    grainOverlay: Float = 0
  ) {
    self.colorBack = colorBack
    self.colors = clampedShaderColors(
      colors, maxColorCount: Self.maxColorCount, paramsType: Self.self)
    self.radius = radius
    self.focalDistance = focalDistance
    self.focalAngle = focalAngle
    self.falloff = falloff
    self.mixing = mixing
    self.distortion = distortion
    self.distortionShift = distortionShift
    self.distortionFreq = distortionFreq
    self.grainMixer = grainMixer
    self.grainOverlay = grainOverlay
  }
}

// MARK: - Swirl

/// Parameters for the swirl shader.
///
/// See <doc:ParameterRanges#Swirl> for value ranges and units.
/// Initializers keep the first `maxColorCount` colors and ignore extras.
public struct SwirlParams: Equatable, Sendable, Codable {
  /// Maximum number of colors stored by this params type.
  public static let maxColorCount = 10
  public var colorBack: ShaderColor
  /// Shader colors after applying `maxColorCount` truncation.
  public var colors: [ShaderColor]
  public var bandCount: Float
  public var twist: Float
  public var center: Float
  public var proportion: Float
  public var softness: Float
  public var noise: Float
  public var noiseFrequency: Float

  /// Creates swirl shader parameters.
  ///
  /// See <doc:ParameterRanges#Swirl> for each parameter's value range and unit.
  public init(
    colorBack: ShaderColor = ShaderColor(red: 0.2, green: 0, blue: 0, alpha: 1),
    colors: [ShaderColor],
    bandCount: Float = 4.0,
    twist: Float = 0.1,
    center: Float = 0.2,
    proportion: Float = 0.5,
    softness: Float = 0,
    noise: Float = 0.2,
    noiseFrequency: Float = 0.4
  ) {
    self.colorBack = colorBack
    self.colors = clampedShaderColors(
      colors, maxColorCount: Self.maxColorCount, paramsType: Self.self)
    self.bandCount = bandCount
    self.twist = twist
    self.center = center
    self.proportion = proportion
    self.softness = softness
    self.noise = noise
    self.noiseFrequency = noiseFrequency
  }
}

// MARK: - Spiral

/// Parameters for the spiral shader.
///
/// See <doc:ParameterRanges#Spiral> for value ranges and units.
public struct SpiralParams: Equatable, Sendable, Codable {
  public var colorBack: ShaderColor
  public var colorFront: ShaderColor
  public var density: Float
  public var distortion: Float
  public var strokeWidth: Float
  public var strokeTaper: Float
  public var strokeCap: Float
  public var noise: Float
  public var noiseFrequency: Float
  public var softness: Float

  /// Creates spiral shader parameters.
  ///
  /// See <doc:ParameterRanges#Spiral> for each parameter's value range and unit.
  public init(
    colorBack: ShaderColor = ShaderColor(red: 0, green: 0.078431375, blue: 0.16078432, alpha: 1),
    colorFront: ShaderColor,
    density: Float = 1.0,
    distortion: Float = 0,
    strokeWidth: Float = 0.5,
    strokeTaper: Float = 0,
    strokeCap: Float = 0,
    noise: Float = 0,
    noiseFrequency: Float = 0,
    softness: Float = 0
  ) {
    self.colorBack = colorBack
    self.colorFront = colorFront
    self.density = density
    self.distortion = distortion
    self.strokeWidth = strokeWidth
    self.strokeTaper = strokeTaper
    self.strokeCap = strokeCap
    self.noise = noise
    self.noiseFrequency = noiseFrequency
    self.softness = softness
  }
}

// MARK: - Dot Grid

/// Parameters for the dot grid shader.
///
/// See <doc:ParameterRanges#Dot-Grid> for value ranges and units.
public struct DotGridParams: Equatable, Sendable, Codable {
  public var colorBack: ShaderColor
  public var colorFill: ShaderColor
  public var colorStroke: ShaderColor
  public var dotSize: Float
  public var gapX: Float
  public var gapY: Float
  public var strokeWidth: Float
  public var sizeRange: Float
  public var opacityRange: Float
  public var shape: DotGridShape

  /// Creates dot grid shader parameters.
  ///
  /// See <doc:ParameterRanges#Dot-Grid> for each parameter's value range and unit.
  public init(
    colorBack: ShaderColor = ShaderColor(red: 0, green: 0, blue: 0, alpha: 1),
    colorFill: ShaderColor,
    colorStroke: ShaderColor,
    dotSize: Float = 2,
    gapX: Float = 32,
    gapY: Float = 32,
    strokeWidth: Float = 0,
    sizeRange: Float = 0,
    opacityRange: Float = 0,
    shape: DotGridShape = .circle
  ) {
    self.colorBack = colorBack
    self.colorFill = colorFill
    self.colorStroke = colorStroke
    self.dotSize = dotSize
    self.gapX = gapX
    self.gapY = gapY
    self.strokeWidth = strokeWidth
    self.sizeRange = sizeRange
    self.opacityRange = opacityRange
    self.shape = shape
  }
}

// MARK: - Simplex Noise

/// Parameters for the simplex noise shader.
///
/// See <doc:ParameterRanges#Simplex-Noise> for value ranges and units.
/// Initializers keep the first `maxColorCount` colors and ignore extras.
public struct SimplexNoiseParams: Equatable, Sendable, Codable {
  /// Maximum number of colors stored by this params type.
  public static let maxColorCount = 10
  /// Shader colors after applying `maxColorCount` truncation.
  public var colors: [ShaderColor]
  public var stepsPerColor: Float
  public var softness: Float

  /// Creates simplex noise shader parameters.
  ///
  /// See <doc:ParameterRanges#Simplex-Noise> for each parameter's value range and unit.
  public init(
    colors: [ShaderColor],
    stepsPerColor: Float = 2.0,
    softness: Float = 0
  ) {
    self.colors = clampedShaderColors(
      colors, maxColorCount: Self.maxColorCount, paramsType: Self.self)
    self.stepsPerColor = stepsPerColor
    self.softness = softness
  }
}

// MARK: - Perlin Noise

/// Parameters for the Perlin noise shader.
///
/// See <doc:ParameterRanges#Perlin-Noise> for value ranges and units.
public struct PerlinNoiseParams: Equatable, Sendable, Codable {
  public var colorFront: ShaderColor
  public var colorBack: ShaderColor
  public var proportion: Float
  public var softness: Float
  public var octaveCount: Float
  public var persistence: Float
  public var lacunarity: Float

  /// Creates Perlin noise shader parameters.
  ///
  /// See <doc:ParameterRanges#Perlin-Noise> for each parameter's value range and unit.
  public init(
    colorFront: ShaderColor,
    colorBack: ShaderColor = ShaderColor(
      red: 0.3882353, green: 0.16470589, blue: 0.8352941, alpha: 1),
    proportion: Float = 0.35,
    softness: Float = 0.1,
    octaveCount: Float = 1.0,
    persistence: Float = 1.0,
    lacunarity: Float = 1.5
  ) {
    self.colorFront = colorFront
    self.colorBack = colorBack
    self.proportion = proportion
    self.softness = softness
    self.octaveCount = octaveCount
    self.persistence = persistence
    self.lacunarity = lacunarity
  }
}

// MARK: - Neuro Noise

/// Parameters for the neuro noise shader.
///
/// See <doc:ParameterRanges#Neuro-Noise> for value ranges and units.
public struct NeuroNoiseParams: Equatable, Sendable, Codable {
  public var colorFront: ShaderColor
  public var colorMid: ShaderColor
  public var colorBack: ShaderColor
  public var brightness: Float
  public var contrast: Float

  /// Creates neuro noise shader parameters.
  ///
  /// See <doc:ParameterRanges#Neuro-Noise> for each parameter's value range and unit.
  public init(
    colorFront: ShaderColor,
    colorMid: ShaderColor,
    colorBack: ShaderColor = ShaderColor(red: 0, green: 0, blue: 0, alpha: 1),
    brightness: Float = 0.05,
    contrast: Float = 0.3
  ) {
    self.colorFront = colorFront
    self.colorMid = colorMid
    self.colorBack = colorBack
    self.brightness = brightness
    self.contrast = contrast
  }
}

// MARK: - Waves

/// Parameters for the waves shader.
///
/// See <doc:ParameterRanges#Waves> for value ranges and units.
public struct WavesParams: Equatable, Sendable, Codable {
  public var colorFront: ShaderColor
  public var colorBack: ShaderColor
  public var shape: Float
  public var frequency: Float
  public var amplitude: Float
  public var spacing: Float
  public var proportion: Float
  public var softness: Float

  /// Creates waves shader parameters.
  ///
  /// See <doc:ParameterRanges#Waves> for each parameter's value range and unit.
  public init(
    colorFront: ShaderColor,
    colorBack: ShaderColor = ShaderColor(red: 0, green: 0, blue: 0, alpha: 1),
    shape: Float = 0,
    frequency: Float = 0.5,
    amplitude: Float = 0.5,
    spacing: Float = 1.2,
    proportion: Float = 0.1,
    softness: Float = 0
  ) {
    self.colorFront = colorFront
    self.colorBack = colorBack
    self.shape = shape
    self.frequency = frequency
    self.amplitude = amplitude
    self.spacing = spacing
    self.proportion = proportion
    self.softness = softness
  }
}

// MARK: - Dithering

/// Parameters for the procedural dithering shader.
///
/// See <doc:ParameterRanges#Dithering> for value ranges and units.
public struct DitheringParams: Equatable, Sendable, Codable {
  public var colorBack: ShaderColor
  public var colorFront: ShaderColor
  public var shape: DitheringShape
  public var type: DitheringType
  public var size: Float

  /// Creates dithering shader parameters.
  ///
  /// See <doc:ParameterRanges#Dithering> for each parameter's value range and unit.
  public init(
    colorBack: ShaderColor = ShaderColor(red: 0, green: 0, blue: 0, alpha: 1),
    colorFront: ShaderColor,
    shape: DitheringShape = .sphere,
    type: DitheringType = .fourByFour,
    size: Float = 2.0
  ) {
    self.colorBack = colorBack
    self.colorFront = colorFront
    self.shape = shape
    self.type = type
    self.size = size
  }
}

// MARK: - Color Panels

/// Parameters for the color panels shader.
///
/// See <doc:ParameterRanges#Color-Panels> for value ranges and units.
/// Initializers keep the first `maxColorCount` colors and ignore extras.
public struct ColorPanelsParams: Equatable, Sendable, Codable {
  /// Maximum number of colors stored by this params type.
  public static let maxColorCount = 7
  /// Shader colors after applying `maxColorCount` truncation.
  public var colors: [ShaderColor]
  public var colorBack: ShaderColor
  public var density: Float
  public var angle1: Float
  public var angle2: Float
  public var length: Float
  public var edges: Float
  public var blur: Float
  public var fadeIn: Float
  public var fadeOut: Float
  public var gradient: Float

  /// Creates color panels shader parameters.
  ///
  /// See <doc:ParameterRanges#Color-Panels> for each parameter's value range and unit.
  public init(
    colors: [ShaderColor],
    colorBack: ShaderColor = ShaderColor(red: 0, green: 0, blue: 0, alpha: 1),
    density: Float = 3.0,
    angle1: Float = 0,
    angle2: Float = 0,
    length: Float = 1.1,
    edges: Float = 0,
    blur: Float = 0,
    fadeIn: Float = 1,
    fadeOut: Float = 0.3,
    gradient: Float = 0
  ) {
    self.colors = clampedShaderColors(
      colors, maxColorCount: Self.maxColorCount, paramsType: Self.self)
    self.colorBack = colorBack
    self.density = density
    self.angle1 = angle1
    self.angle2 = angle2
    self.length = length
    self.edges = edges
    self.blur = blur
    self.fadeIn = fadeIn
    self.fadeOut = fadeOut
    self.gradient = gradient
  }
}

// MARK: - Dot Orbit

/// Parameters for the dot orbit shader.
///
/// See <doc:ParameterRanges#Dot-Orbit> for value ranges and units.
/// Initializers keep the first `maxColorCount` colors and ignore extras.
public struct DotOrbitParams: Equatable, Sendable, Codable {
  /// Maximum number of colors stored by this params type.
  public static let maxColorCount = 10
  public var colorBack: ShaderColor
  /// Shader colors after applying `maxColorCount` truncation.
  public var colors: [ShaderColor]
  public var stepsPerColor: Float
  public var size: Float
  public var sizeRange: Float
  public var spreading: Float

  /// Creates dot orbit shader parameters.
  ///
  /// See <doc:ParameterRanges#Dot-Orbit> for each parameter's value range and unit.
  public init(
    colorBack: ShaderColor = ShaderColor(red: 0, green: 0, blue: 0, alpha: 1),
    colors: [ShaderColor],
    stepsPerColor: Float = 4.0,
    size: Float = 1.0,
    sizeRange: Float = 0,
    spreading: Float = 1.0
  ) {
    self.colorBack = colorBack
    self.colors = clampedShaderColors(
      colors, maxColorCount: Self.maxColorCount, paramsType: Self.self)
    self.stepsPerColor = stepsPerColor
    self.size = size
    self.sizeRange = sizeRange
    self.spreading = spreading
  }
}

// MARK: - God Rays

/// Parameters for the god rays shader.
///
/// See <doc:ParameterRanges#God-Rays> for value ranges and units.
/// Initializers keep the first `maxColorCount` colors and ignore extras.
public struct GodRaysParams: Equatable, Sendable, Codable {
  /// Maximum number of colors stored by this params type.
  public static let maxColorCount = 5
  public var colorBack: ShaderColor
  public var colorBloom: ShaderColor
  /// Shader colors after applying `maxColorCount` truncation.
  public var colors: [ShaderColor]
  public var density: Float
  public var spotty: Float
  public var midSize: Float
  public var midIntensity: Float
  public var intensity: Float
  public var bloom: Float

  /// Creates god rays shader parameters.
  ///
  /// See <doc:ParameterRanges#God-Rays> for each parameter's value range and unit.
  public init(
    colorBack: ShaderColor = ShaderColor(red: 0, green: 0, blue: 0, alpha: 1),
    colorBloom: ShaderColor = ShaderColor(red: 0, green: 0, blue: 1, alpha: 1),
    colors: [ShaderColor],
    density: Float = 0.3,
    spotty: Float = 0.3,
    midSize: Float = 0.2,
    midIntensity: Float = 0.4,
    intensity: Float = 0.8,
    bloom: Float = 0.4
  ) {
    self.colorBack = colorBack
    self.colorBloom = colorBloom
    self.colors = clampedShaderColors(
      colors, maxColorCount: Self.maxColorCount, paramsType: Self.self)
    self.density = density
    self.spotty = spotty
    self.midSize = midSize
    self.midIntensity = midIntensity
    self.intensity = intensity
    self.bloom = bloom
  }
}

// MARK: - Grain Gradient

/// Parameters for the grain gradient shader.
///
/// See <doc:ParameterRanges#Grain-Gradient> for value ranges and units.
/// Initializers keep the first `maxColorCount` colors and ignore extras.
public struct GrainGradientParams: Equatable, Sendable, Codable {
  /// Maximum number of colors stored by this params type.
  public static let maxColorCount = 7
  public var colorBack: ShaderColor
  /// Shader colors after applying `maxColorCount` truncation.
  public var colors: [ShaderColor]
  public var softness: Float
  public var intensity: Float
  public var noise: Float
  public var shape: GrainGradientShape

  /// Creates grain gradient shader parameters.
  ///
  /// See <doc:ParameterRanges#Grain-Gradient> for each parameter's value range and unit.
  public init(
    colorBack: ShaderColor = ShaderColor(red: 0, green: 0, blue: 0, alpha: 1),
    colors: [ShaderColor],
    softness: Float = 0.5,
    intensity: Float = 0.5,
    noise: Float = 0.25,
    shape: GrainGradientShape = .corners
  ) {
    self.colorBack = colorBack
    self.colors = clampedShaderColors(
      colors, maxColorCount: Self.maxColorCount, paramsType: Self.self)
    self.softness = softness
    self.intensity = intensity
    self.noise = noise
    self.shape = shape
  }
}

// MARK: - Metaballs

/// Parameters for the metaballs shader.
///
/// See <doc:ParameterRanges#Metaballs> for value ranges and units.
/// Initializers keep the first `maxColorCount` colors and ignore extras.
public struct MetaballsParams: Equatable, Sendable, Codable {
  /// Maximum number of colors stored by this params type.
  public static let maxColorCount = 8
  public var colorBack: ShaderColor
  /// Shader colors after applying `maxColorCount` truncation.
  public var colors: [ShaderColor]
  public var count: Float
  public var size: Float
  public var sizeRange: Float

  /// Creates metaballs shader parameters.
  ///
  /// See <doc:ParameterRanges#Metaballs> for each parameter's value range and unit.
  public init(
    colorBack: ShaderColor = ShaderColor(red: 0, green: 0, blue: 0, alpha: 1),
    colors: [ShaderColor],
    count: Float = 10,
    size: Float = 0.83,
    sizeRange: Float = 0.2
  ) {
    self.colorBack = colorBack
    self.colors = clampedShaderColors(
      colors, maxColorCount: Self.maxColorCount, paramsType: Self.self)
    self.count = count
    self.size = size
    self.sizeRange = sizeRange
  }
}

// MARK: - Warp

/// Parameters for the warp shader.
///
/// See <doc:ParameterRanges#Warp> for value ranges and units.
/// Initializers keep the first `maxColorCount` colors and ignore extras.
public struct WarpParams: Equatable, Sendable, Codable {
  /// Maximum number of colors stored by this params type.
  public static let maxColorCount = 10
  /// Shader colors after applying `maxColorCount` truncation.
  public var colors: [ShaderColor]
  public var proportion: Float
  public var softness: Float
  public var shape: WarpPattern
  public var shapeScale: Float
  public var distortion: Float
  public var swirl: Float
  public var swirlIterations: Float

  /// Creates warp shader parameters.
  ///
  /// See <doc:ParameterRanges#Warp> for each parameter's value range and unit.
  public init(
    colors: [ShaderColor],
    proportion: Float = 0.45,
    softness: Float = 1.0,
    shape: WarpPattern = .checks,
    shapeScale: Float = 0.1,
    distortion: Float = 0.25,
    swirl: Float = 0.8,
    swirlIterations: Float = 10.0
  ) {
    self.colors = clampedShaderColors(
      colors, maxColorCount: Self.maxColorCount, paramsType: Self.self)
    self.proportion = proportion
    self.softness = softness
    self.shape = shape
    self.shapeScale = shapeScale
    self.distortion = distortion
    self.swirl = swirl
    self.swirlIterations = swirlIterations
  }
}

// MARK: - Voronoi

/// Parameters for the Voronoi shader.
///
/// See <doc:ParameterRanges#Voronoi> for value ranges and units.
/// Initializers keep the first `maxColorCount` colors and ignore extras.
public struct VoronoiParams: Equatable, Sendable, Codable {
  /// Maximum number of colors stored by this params type.
  public static let maxColorCount = 5
  /// Shader colors after applying `maxColorCount` truncation.
  public var colors: [ShaderColor]
  public var stepsPerColor: Float
  public var colorGap: ShaderColor
  public var colorGlow: ShaderColor
  public var distortion: Float
  public var gap: Float
  public var glow: Float

  /// Creates Voronoi shader parameters.
  ///
  /// See <doc:ParameterRanges#Voronoi> for each parameter's value range and unit.
  public init(
    colors: [ShaderColor],
    stepsPerColor: Float = 3.0,
    colorGap: ShaderColor = ShaderColor(red: 0.18039216, green: 0, blue: 0, alpha: 1),
    colorGlow: ShaderColor = ShaderColor(red: 1, green: 1, blue: 1, alpha: 1),
    distortion: Float = 0.4,
    gap: Float = 0.04,
    glow: Float = 0
  ) {
    self.colors = clampedShaderColors(
      colors, maxColorCount: Self.maxColorCount, paramsType: Self.self)
    self.stepsPerColor = stepsPerColor
    self.colorGap = colorGap
    self.colorGlow = colorGlow
    self.distortion = distortion
    self.gap = gap
    self.glow = glow
  }
}

// MARK: - Pulsing Border

/// Parameters for the pulsing border shader.
///
/// See <doc:ParameterRanges#Pulsing-Border> for value ranges and units.
/// Initializers keep the first `maxColorCount` colors and ignore extras.
public struct PulsingBorderParams: Equatable, Sendable, Codable {
  /// Maximum number of colors stored by this params type.
  public static let maxColorCount = 5
  public var colorBack: ShaderColor
  /// Shader colors after applying `maxColorCount` truncation.
  public var colors: [ShaderColor]
  public var roundness: Float
  public var thickness: Float
  public var marginLeft: Float
  public var marginRight: Float
  public var marginTop: Float
  public var marginBottom: Float
  public var aspectRatio: PulsingBorderAspectRatio
  public var softness: Float
  public var intensity: Float
  public var bloom: Float
  public var spots: Float
  public var spotSize: Float
  public var pulse: Float
  public var smoke: Float
  public var smokeSize: Float

  /// Creates pulsing border shader parameters.
  ///
  /// See <doc:ParameterRanges#Pulsing-Border> for each parameter's value range and unit.
  public init(
    colorBack: ShaderColor = ShaderColor(red: 0, green: 0, blue: 0, alpha: 1),
    colors: [ShaderColor],
    roundness: Float = 0.25,
    thickness: Float = 0.1,
    marginLeft: Float = 0,
    marginRight: Float = 0,
    marginTop: Float = 0,
    marginBottom: Float = 0,
    aspectRatio: PulsingBorderAspectRatio = .auto,
    softness: Float = 0.75,
    intensity: Float = 0.2,
    bloom: Float = 0.25,
    spots: Float = 5.0,
    spotSize: Float = 0.5,
    pulse: Float = 0.25,
    smoke: Float = 0.3,
    smokeSize: Float = 0.6
  ) {
    self.colorBack = colorBack
    self.colors = clampedShaderColors(
      colors, maxColorCount: Self.maxColorCount, paramsType: Self.self)
    self.roundness = roundness
    self.thickness = thickness
    self.marginLeft = marginLeft
    self.marginRight = marginRight
    self.marginTop = marginTop
    self.marginBottom = marginBottom
    self.aspectRatio = aspectRatio
    self.softness = softness
    self.intensity = intensity
    self.bloom = bloom
    self.spots = spots
    self.spotSize = spotSize
    self.pulse = pulse
    self.smoke = smoke
    self.smokeSize = smokeSize
  }
}

// MARK: - Smoke Ring

/// Parameters for the smoke ring shader.
///
/// See <doc:ParameterRanges#Smoke-Ring> for value ranges and units.
/// Initializers keep the first `maxColorCount` colors and ignore extras.
public struct SmokeRingParams: Equatable, Sendable, Codable {
  /// Maximum number of colors stored by this params type.
  public static let maxColorCount = 10
  public var colorBack: ShaderColor
  /// Shader colors after applying `maxColorCount` truncation.
  public var colors: [ShaderColor]
  public var noiseScale: Float
  public var thickness: Float
  public var radius: Float
  public var innerShape: Float
  public var noiseIterations: Float

  /// Creates smoke ring shader parameters.
  ///
  /// See <doc:ParameterRanges#Smoke-Ring> for each parameter's value range and unit.
  public init(
    colorBack: ShaderColor = ShaderColor(red: 0, green: 0, blue: 0, alpha: 1),
    colors: [ShaderColor],
    noiseScale: Float = 3.0,
    thickness: Float = 0.65,
    radius: Float = 0.25,
    innerShape: Float = 0.7,
    noiseIterations: Float = 8.0
  ) {
    self.colorBack = colorBack
    self.colors = clampedShaderColors(
      colors, maxColorCount: Self.maxColorCount, paramsType: Self.self)
    self.noiseScale = noiseScale
    self.thickness = thickness
    self.radius = radius
    self.innerShape = innerShape
    self.noiseIterations = noiseIterations
  }
}

// MARK: - Image Dithering

/// Parameters for the image dithering shader.
///
/// See <doc:ParameterRanges#Image-Dithering> for value ranges and units.
public struct ImageDitheringParams: Equatable, Sendable, Codable {
  public var colorFront: ShaderColor
  public var colorBack: ShaderColor
  public var colorHighlight: ShaderColor
  public var type: DitheringType
  public var size: Float
  public var colorSteps: Float
  public var originalColors: Float
  public var inverted: Float

  /// Creates image dithering shader parameters.
  ///
  /// See <doc:ParameterRanges#Image-Dithering> for each parameter's value range and unit.
  public init(
    colorFront: ShaderColor,
    colorBack: ShaderColor = ShaderColor(red: 0, green: 0.047058824, blue: 0.21960784, alpha: 1),
    colorHighlight: ShaderColor = ShaderColor(red: 0.91764706, green: 1, blue: 0.5803922, alpha: 1),
    type: DitheringType = .eightByEight,
    size: Float = 2.0,
    colorSteps: Float = 2.0,
    originalColors: Float = 0.0,
    inverted: Float = 0.0
  ) {
    self.colorFront = colorFront
    self.colorBack = colorBack
    self.colorHighlight = colorHighlight
    self.type = type
    self.size = size
    self.colorSteps = colorSteps
    self.originalColors = originalColors
    self.inverted = inverted
  }
}

// MARK: - Halftone Dots

/// Parameters for the halftone dots shader.
///
/// See <doc:ParameterRanges#Halftone-Dots> for value ranges and units.
public struct HalftoneDotsParams: Equatable, Sendable, Codable {
  public var colorFront: ShaderColor
  public var colorBack: ShaderColor
  public var size: Float
  public var grid: HalftoneDotsGrid
  public var radius: Float
  public var contrast: Float
  public var originalColors: Float
  public var inverted: Float
  public var grainMixer: Float
  public var grainOverlay: Float
  public var grainSize: Float
  public var type: HalftoneDotsType

  /// Creates halftone dots shader parameters.
  ///
  /// See <doc:ParameterRanges#Halftone-Dots> for each parameter's value range and unit.
  public init(
    colorFront: ShaderColor,
    colorBack: ShaderColor = ShaderColor(
      red: 0.9490196, green: 0.94509804, blue: 0.9098039, alpha: 1),
    size: Float = 0.5,
    grid: HalftoneDotsGrid = .hex,
    radius: Float = 1.25,
    contrast: Float = 0.4,
    originalColors: Float = 0.0,
    inverted: Float = 0.0,
    grainMixer: Float = 0.2,
    grainOverlay: Float = 0.2,
    grainSize: Float = 0.5,
    type: HalftoneDotsType = .gooey
  ) {
    self.colorFront = colorFront
    self.colorBack = colorBack
    self.size = size
    self.grid = grid
    self.radius = radius
    self.contrast = contrast
    self.originalColors = originalColors
    self.inverted = inverted
    self.grainMixer = grainMixer
    self.grainOverlay = grainOverlay
    self.grainSize = grainSize
    self.type = type
  }
}

// MARK: - Halftone CMYK

/// Parameters for the halftone CMYK shader.
///
/// See <doc:ParameterRanges#Halftone-CMYK> for value ranges and units.
public struct HalftoneCmykParams: Equatable, Sendable, Codable {
  public var colorBack: ShaderColor
  public var colorC: ShaderColor
  public var colorM: ShaderColor
  public var colorY: ShaderColor
  public var colorK: ShaderColor
  public var size: Float
  public var contrast: Float
  public var softness: Float
  public var grainSize: Float
  public var grainMixer: Float
  public var grainOverlay: Float
  public var gridNoise: Float
  public var floodC: Float
  public var floodM: Float
  public var floodY: Float
  public var floodK: Float
  public var gainC: Float
  public var gainM: Float
  public var gainY: Float
  public var gainK: Float
  public var type: HalftoneCmykType

  /// Creates halftone CMYK shader parameters.
  ///
  /// See <doc:ParameterRanges#Halftone-CMYK> for each parameter's value range and unit.
  public init(
    colorBack: ShaderColor = ShaderColor(
      red: 0.9843137, green: 0.98039216, blue: 0.9607843, alpha: 1),
    colorC: ShaderColor = ShaderColor(red: 0, green: 0.7058824, blue: 1, alpha: 1),
    colorM: ShaderColor = ShaderColor(
      red: 0.9882353, green: 0.31764707, blue: 0.62352943, alpha: 1),
    colorY: ShaderColor = ShaderColor(red: 1, green: 0.84705883, blue: 0, alpha: 1),
    colorK: ShaderColor = ShaderColor(
      red: 0.13725491, green: 0.12156863, blue: 0.1254902, alpha: 1),
    size: Float = 0.2,
    contrast: Float = 1.0,
    softness: Float = 1.0,
    grainSize: Float = 0.5,
    grainMixer: Float = 0,
    grainOverlay: Float = 0,
    gridNoise: Float = 0.2,
    floodC: Float = 0.15,
    floodM: Float = 0.0,
    floodY: Float = 0.0,
    floodK: Float = 0.0,
    gainC: Float = 0.3,
    gainM: Float = 0.0,
    gainY: Float = 0.2,
    gainK: Float = 0.0,
    type: HalftoneCmykType = .ink
  ) {
    self.colorBack = colorBack
    self.colorC = colorC
    self.colorM = colorM
    self.colorY = colorY
    self.colorK = colorK
    self.size = size
    self.contrast = contrast
    self.softness = softness
    self.grainSize = grainSize
    self.grainMixer = grainMixer
    self.grainOverlay = grainOverlay
    self.gridNoise = gridNoise
    self.floodC = floodC
    self.floodM = floodM
    self.floodY = floodY
    self.floodK = floodK
    self.gainC = gainC
    self.gainM = gainM
    self.gainY = gainY
    self.gainK = gainK
    self.type = type
  }
}

// MARK: - Heatmap

/// Parameters for the heatmap shader.
///
/// See <doc:ParameterRanges#Heatmap> for value ranges and units.
/// Initializers keep the first `maxColorCount` colors and ignore extras.
public struct HeatmapParams: Equatable, Sendable, Codable {
  /// Maximum number of colors stored by this params type.
  public static let maxColorCount = 10
  public var colorBack: ShaderColor
  /// Shader colors after applying `maxColorCount` truncation.
  public var colors: [ShaderColor]
  public var contour: Float
  public var angle: Float
  public var noise: Float
  public var innerGlow: Float
  public var outerGlow: Float

  /// Creates heatmap shader parameters.
  ///
  /// See <doc:ParameterRanges#Heatmap> for each parameter's value range and unit.
  public init(
    colorBack: ShaderColor = ShaderColor(red: 0, green: 0, blue: 0, alpha: 1),
    colors: [ShaderColor],
    contour: Float = 0.5,
    angle: Float = 0.0,
    noise: Float = 0,
    innerGlow: Float = 0.5,
    outerGlow: Float = 0.5
  ) {
    self.colorBack = colorBack
    self.colors = clampedShaderColors(
      colors, maxColorCount: Self.maxColorCount, paramsType: Self.self)
    self.contour = contour
    self.angle = angle
    self.noise = noise
    self.innerGlow = innerGlow
    self.outerGlow = outerGlow
  }
}

// MARK: - Liquid Metal

/// Parameters for the liquid metal shader.
///
/// See <doc:ParameterRanges#Liquid-Metal> for value ranges and units.
public struct LiquidMetalParams: Equatable, Sendable, Codable {
  public var colorBack: ShaderColor
  public var colorTint: ShaderColor
  public var repetition: Float
  public var softness: Float
  public var shiftRed: Float
  public var shiftBlue: Float
  public var distortion: Float
  public var contour: Float
  public var angle: Float
  public var shape: LiquidMetalShape

  /// Creates liquid metal shader parameters.
  ///
  /// See <doc:ParameterRanges#Liquid-Metal> for each parameter's value range and unit.
  public init(
    colorBack: ShaderColor = ShaderColor(
      red: 0.6666667, green: 0.6666667, blue: 0.6745098, alpha: 1),
    colorTint: ShaderColor = ShaderColor(red: 1, green: 1, blue: 1, alpha: 1),
    repetition: Float = 2.0,
    softness: Float = 0.1,
    shiftRed: Float = 0.3,
    shiftBlue: Float = 0.3,
    distortion: Float = 0.07,
    contour: Float = 0.4,
    angle: Float = 70.0,
    shape: LiquidMetalShape = .diamond
  ) {
    self.colorBack = colorBack
    self.colorTint = colorTint
    self.repetition = repetition
    self.softness = softness
    self.shiftRed = shiftRed
    self.shiftBlue = shiftBlue
    self.distortion = distortion
    self.contour = contour
    self.angle = angle
    self.shape = shape
  }
}

// MARK: - Paper Texture

/// Parameters for the paper texture shader.
///
/// See <doc:ParameterRanges#Paper-Texture> for value ranges and units.
public struct PaperTextureParams: Equatable, Sendable, Codable {
  public var colorFront: ShaderColor
  public var colorBack: ShaderColor
  public var contrast: Float
  public var roughness: Float
  public var fiber: Float
  public var fiberSize: Float
  public var crumples: Float
  public var foldCount: Float
  public var folds: Float
  public var fade: Float
  public var crumpleSize: Float
  public var drops: Float
  public var seed: Float

  /// Creates paper texture shader parameters.
  ///
  /// See <doc:ParameterRanges#Paper-Texture> for each parameter's value range and unit.
  public init(
    colorFront: ShaderColor = ShaderColor(
      red: 0.62352943, green: 0.6784314, blue: 0.7372549, alpha: 1),
    colorBack: ShaderColor = ShaderColor(red: 1, green: 1, blue: 1, alpha: 1),
    contrast: Float = 0.3,
    roughness: Float = 0.4,
    fiber: Float = 0.3,
    fiberSize: Float = 0.2,
    crumples: Float = 0.3,
    foldCount: Float = 5.0,
    folds: Float = 0.65,
    fade: Float = 0,
    crumpleSize: Float = 0.35,
    drops: Float = 0.2,
    seed: Float = 5.8
  ) {
    self.colorFront = colorFront
    self.colorBack = colorBack
    self.contrast = contrast
    self.roughness = roughness
    self.fiber = fiber
    self.fiberSize = fiberSize
    self.crumples = crumples
    self.foldCount = foldCount
    self.folds = folds
    self.fade = fade
    self.crumpleSize = crumpleSize
    self.drops = drops
    self.seed = seed
  }
}

// MARK: - Water

/// Parameters for the water shader.
///
/// See <doc:ParameterRanges#Water> for value ranges and units.
public struct WaterParams: Equatable, Sendable, Codable {
  public var colorBack: ShaderColor
  public var colorHighlight: ShaderColor
  public var highlights: Float
  public var layering: Float
  public var edges: Float
  public var caustic: Float
  public var waves: Float
  public var size: Float

  /// Creates water shader parameters.
  ///
  /// See <doc:ParameterRanges#Water> for each parameter's value range and unit.
  public init(
    colorBack: ShaderColor = ShaderColor(
      red: 0.5647059, green: 0.5647059, blue: 0.5647059, alpha: 1),
    colorHighlight: ShaderColor = ShaderColor(red: 1, green: 1, blue: 1, alpha: 1),
    highlights: Float = 0.07,
    layering: Float = 0.5,
    edges: Float = 0.8,
    caustic: Float = 0.1,
    waves: Float = 0.3,
    size: Float = 1.0
  ) {
    self.colorBack = colorBack
    self.colorHighlight = colorHighlight
    self.highlights = highlights
    self.layering = layering
    self.edges = edges
    self.caustic = caustic
    self.waves = waves
    self.size = size
  }
}

// MARK: - Fluted Glass

/// Parameters for the fluted glass shader.
///
/// See <doc:ParameterRanges#Fluted-Glass> for value ranges and units.
public struct FlutedGlassParams: Equatable, Sendable, Codable {
  public var colorBack: ShaderColor
  public var colorShadow: ShaderColor
  public var colorHighlight: ShaderColor
  public var shadows: Float
  public var size: Float
  public var angle: Float
  public var distortion: Float
  public var shift: Float
  public var blur: Float
  public var edges: Float
  public var marginLeft: Float
  public var marginRight: Float
  public var marginTop: Float
  public var marginBottom: Float
  public var stretch: Float
  public var distortionShape: GlassDistortionShape
  public var highlights: Float
  public var shape: GlassGridShape
  public var grainMixer: Float
  public var grainOverlay: Float

  /// Creates fluted glass shader parameters.
  ///
  /// See <doc:ParameterRanges#Fluted-Glass> for each parameter's value range and unit.
  public init(
    colorBack: ShaderColor = ShaderColor(red: 0, green: 0, blue: 0, alpha: 0),
    colorShadow: ShaderColor = ShaderColor(red: 0, green: 0, blue: 0, alpha: 1),
    colorHighlight: ShaderColor = ShaderColor(red: 1, green: 1, blue: 1, alpha: 1),
    shadows: Float = 0.25,
    size: Float = 0.5,
    angle: Float = 0.0,
    distortion: Float = 0.5,
    shift: Float = 0.0,
    blur: Float = 0,
    edges: Float = 0.25,
    marginLeft: Float = 0.0,
    marginRight: Float = 0.0,
    marginTop: Float = 0.0,
    marginBottom: Float = 0.0,
    stretch: Float = 0,
    distortionShape: GlassDistortionShape = .prism,
    highlights: Float = 0.1,
    shape: GlassGridShape = .lines,
    grainMixer: Float = 0,
    grainOverlay: Float = 0
  ) {
    self.colorBack = colorBack
    self.colorShadow = colorShadow
    self.colorHighlight = colorHighlight
    self.shadows = shadows
    self.size = size
    self.angle = angle
    self.distortion = distortion
    self.shift = shift
    self.blur = blur
    self.edges = edges
    self.marginLeft = marginLeft
    self.marginRight = marginRight
    self.marginTop = marginTop
    self.marginBottom = marginBottom
    self.stretch = stretch
    self.distortionShape = distortionShape
    self.highlights = highlights
    self.shape = shape
    self.grainMixer = grainMixer
    self.grainOverlay = grainOverlay
  }
}

// MARK: - Gem Smoke

/// Parameters for the gem smoke shader.
///
/// See <doc:ParameterRanges#Gem-Smoke> for value ranges and units.
/// Initializers keep the first `maxColorCount` colors and ignore extras.
public struct GemSmokeParams: Equatable, Sendable, Codable {
  /// Maximum number of colors stored by this params type.
  public static let maxColorCount = 6
  /// Shader colors after applying `maxColorCount` truncation.
  public var colors: [ShaderColor]
  public var colorBack: ShaderColor
  public var colorInner: ShaderColor
  public var innerDistortion: Float
  public var outerDistortion: Float
  public var outerGlow: Float
  public var innerGlow: Float
  public var offset: Float
  public var angle: Float
  public var size: Float
  public var shape: GemSmokeShape

  /// Creates gem smoke shader parameters.
  ///
  /// See <doc:ParameterRanges#Gem-Smoke> for each parameter's value range and unit.
  public init(
    colors: [ShaderColor],
    colorBack: ShaderColor = ShaderColor(
      red: 0.9411765, green: 0.9372549, blue: 0.91764706, alpha: 1),
    colorInner: ShaderColor = ShaderColor(
      red: 0.98039216, green: 0.98039216, blue: 0.9607843, alpha: 1),
    innerDistortion: Float = 0.8,
    outerDistortion: Float = 0.6,
    outerGlow: Float = 0.55,
    innerGlow: Float = 1,
    offset: Float = 0,
    angle: Float = 0,
    size: Float = 0.8,
    shape: GemSmokeShape = .diamond
  ) {
    self.colors = clampedShaderColors(
      colors, maxColorCount: Self.maxColorCount, paramsType: Self.self)
    self.colorBack = colorBack
    self.colorInner = colorInner
    self.innerDistortion = innerDistortion
    self.outerDistortion = outerDistortion
    self.outerGlow = outerGlow
    self.innerGlow = innerGlow
    self.offset = offset
    self.angle = angle
    self.size = size
    self.shape = shape
  }
}
// MARK: - Metal Uniforms

// These raw uniforms mirror the .metal buffer layout. Keep them internal:
// field order is a renderer-owned shader contract, not public API.

struct VertexUniforms {
  var u_resolution: SIMD2<Float>
  var u_pixelRatio: Float
  var u_imageAspectRatio: Float
  var u_originX: Float
  var u_originY: Float
  var u_worldWidth: Float
  var u_worldHeight: Float
  var u_fit: Float
  var u_scale: Float
  var u_rotation: Float
  var u_offsetX: Float
  var u_offsetY: Float

  init(
    u_resolution: SIMD2<Float>,
    u_pixelRatio: Float,
    u_imageAspectRatio: Float,
    u_originX: Float,
    u_originY: Float,
    u_worldWidth: Float,
    u_worldHeight: Float,
    u_fit: Float,
    u_scale: Float,
    u_rotation: Float,
    u_offsetX: Float,
    u_offsetY: Float
  ) {
    self.u_resolution = u_resolution
    self.u_pixelRatio = u_pixelRatio
    self.u_imageAspectRatio = u_imageAspectRatio
    self.u_originX = u_originX
    self.u_originY = u_originY
    self.u_worldWidth = u_worldWidth
    self.u_worldHeight = u_worldHeight
    self.u_fit = u_fit
    self.u_scale = u_scale
    self.u_rotation = u_rotation
    self.u_offsetX = u_offsetX
    self.u_offsetY = u_offsetY
  }
}

struct MeshGradientUniformsRaw {
  var u_time: Float
  var u_colors0: SIMD4<Float>
  var u_colors1: SIMD4<Float>
  var u_colors2: SIMD4<Float>
  var u_colors3: SIMD4<Float>
  var u_colors4: SIMD4<Float>
  var u_colors5: SIMD4<Float>
  var u_colors6: SIMD4<Float>
  var u_colors7: SIMD4<Float>
  var u_colors8: SIMD4<Float>
  var u_colors9: SIMD4<Float>
  var u_colorsCount: Float
  var u_distortion: Float
  var u_swirl: Float
  var u_grainMixer: Float
  var u_grainOverlay: Float

  init(time: Float, params: MeshGradientParams) {
    let padded =
      params.colors.map(\.rgba)
      + Array(
        repeating: SIMD4<Float>(0, 0, 0, 0),
        count: max(0, MeshGradientParams.maxColorCount - params.colors.count))
    self.u_time = time
    self.u_colors0 = padded[0]
    self.u_colors1 = padded[1]
    self.u_colors2 = padded[2]
    self.u_colors3 = padded[3]
    self.u_colors4 = padded[4]
    self.u_colors5 = padded[5]
    self.u_colors6 = padded[6]
    self.u_colors7 = padded[7]
    self.u_colors8 = padded[8]
    self.u_colors9 = padded[9]
    self.u_colorsCount = Float(params.colors.count)
    self.u_distortion = params.distortion
    self.u_swirl = params.swirl
    self.u_grainMixer = params.grainMixer
    self.u_grainOverlay = params.grainOverlay
  }
}

struct StaticMeshGradientUniformsRaw {
  var u_colors0: SIMD4<Float>
  var u_colors1: SIMD4<Float>
  var u_colors2: SIMD4<Float>
  var u_colors3: SIMD4<Float>
  var u_colors4: SIMD4<Float>
  var u_colors5: SIMD4<Float>
  var u_colors6: SIMD4<Float>
  var u_colors7: SIMD4<Float>
  var u_colors8: SIMD4<Float>
  var u_colors9: SIMD4<Float>
  var u_colorsCount: Float
  var u_positions: Float
  var u_waveX: Float
  var u_waveXShift: Float
  var u_waveY: Float
  var u_waveYShift: Float
  var u_mixing: Float
  var u_grainMixer: Float
  var u_grainOverlay: Float

  init(params: StaticMeshGradientParams) {
    let padded =
      params.colors.map(\.rgba)
      + Array(
        repeating: SIMD4<Float>(0, 0, 0, 0),
        count: max(0, StaticMeshGradientParams.maxColorCount - params.colors.count))
    self.u_colors0 = padded[0]
    self.u_colors1 = padded[1]
    self.u_colors2 = padded[2]
    self.u_colors3 = padded[3]
    self.u_colors4 = padded[4]
    self.u_colors5 = padded[5]
    self.u_colors6 = padded[6]
    self.u_colors7 = padded[7]
    self.u_colors8 = padded[8]
    self.u_colors9 = padded[9]
    self.u_colorsCount = Float(params.colors.count)
    self.u_positions = params.positions
    self.u_waveX = params.waveX
    self.u_waveXShift = params.waveXShift
    self.u_waveY = params.waveY
    self.u_waveYShift = params.waveYShift
    self.u_mixing = params.mixing
    self.u_grainMixer = params.grainMixer
    self.u_grainOverlay = params.grainOverlay
  }
}

struct StaticRadialGradientUniformsRaw {
  var u_colorBack: SIMD4<Float>
  var u_colors0: SIMD4<Float>
  var u_colors1: SIMD4<Float>
  var u_colors2: SIMD4<Float>
  var u_colors3: SIMD4<Float>
  var u_colors4: SIMD4<Float>
  var u_colors5: SIMD4<Float>
  var u_colors6: SIMD4<Float>
  var u_colors7: SIMD4<Float>
  var u_colors8: SIMD4<Float>
  var u_colors9: SIMD4<Float>
  var u_colorsCount: Float
  var u_radius: Float
  var u_focalDistance: Float
  var u_focalAngle: Float
  var u_falloff: Float
  var u_mixing: Float
  var u_distortion: Float
  var u_distortionShift: Float
  var u_distortionFreq: Float
  var u_grainMixer: Float
  var u_grainOverlay: Float

  init(params: StaticRadialGradientParams) {
    let padded =
      params.colors.map(\.rgba)
      + Array(
        repeating: SIMD4<Float>(0, 0, 0, 0),
        count: max(0, StaticRadialGradientParams.maxColorCount - params.colors.count))
    self.u_colorBack = params.colorBack.rgba
    self.u_colors0 = padded[0]
    self.u_colors1 = padded[1]
    self.u_colors2 = padded[2]
    self.u_colors3 = padded[3]
    self.u_colors4 = padded[4]
    self.u_colors5 = padded[5]
    self.u_colors6 = padded[6]
    self.u_colors7 = padded[7]
    self.u_colors8 = padded[8]
    self.u_colors9 = padded[9]
    self.u_colorsCount = Float(params.colors.count)
    self.u_radius = params.radius
    self.u_focalDistance = params.focalDistance
    self.u_focalAngle = params.focalAngle
    self.u_falloff = params.falloff
    self.u_mixing = params.mixing
    self.u_distortion = params.distortion
    self.u_distortionShift = params.distortionShift
    self.u_distortionFreq = params.distortionFreq
    self.u_grainMixer = params.grainMixer
    self.u_grainOverlay = params.grainOverlay
  }
}

struct SwirlUniformsRaw {
  var u_time: Float
  var u_colorBack: SIMD4<Float>
  var u_colors0: SIMD4<Float>
  var u_colors1: SIMD4<Float>
  var u_colors2: SIMD4<Float>
  var u_colors3: SIMD4<Float>
  var u_colors4: SIMD4<Float>
  var u_colors5: SIMD4<Float>
  var u_colors6: SIMD4<Float>
  var u_colors7: SIMD4<Float>
  var u_colors8: SIMD4<Float>
  var u_colors9: SIMD4<Float>
  var u_colorsCount: Float
  var u_bandCount: Float
  var u_twist: Float
  var u_center: Float
  var u_proportion: Float
  var u_softness: Float
  var u_noise: Float
  var u_noiseFrequency: Float

  init(time: Float, params: SwirlParams) {
    let padded =
      params.colors.map(\.rgba)
      + Array(
        repeating: SIMD4<Float>(0, 0, 0, 0),
        count: max(0, SwirlParams.maxColorCount - params.colors.count))
    self.u_time = time
    self.u_colorBack = params.colorBack.rgba
    self.u_colors0 = padded[0]
    self.u_colors1 = padded[1]
    self.u_colors2 = padded[2]
    self.u_colors3 = padded[3]
    self.u_colors4 = padded[4]
    self.u_colors5 = padded[5]
    self.u_colors6 = padded[6]
    self.u_colors7 = padded[7]
    self.u_colors8 = padded[8]
    self.u_colors9 = padded[9]
    self.u_colorsCount = Float(params.colors.count)
    self.u_bandCount = params.bandCount
    self.u_twist = params.twist
    self.u_center = params.center
    self.u_proportion = params.proportion
    self.u_softness = params.softness
    self.u_noise = params.noise
    self.u_noiseFrequency = params.noiseFrequency
  }
}

struct SpiralUniformsRaw {
  var u_time: Float
  var u_colorBack: SIMD4<Float>
  var u_colorFront: SIMD4<Float>
  var u_density: Float
  var u_distortion: Float
  var u_strokeWidth: Float
  var u_strokeCap: Float
  var u_strokeTaper: Float
  var u_noise: Float
  var u_noiseFrequency: Float
  var u_softness: Float

  init(time: Float, params: SpiralParams) {
    self.u_time = time
    self.u_colorBack = params.colorBack.rgba
    self.u_colorFront = params.colorFront.rgba
    self.u_density = params.density
    self.u_distortion = params.distortion
    self.u_strokeWidth = params.strokeWidth
    self.u_strokeCap = params.strokeCap
    self.u_strokeTaper = params.strokeTaper
    self.u_noise = params.noise
    self.u_noiseFrequency = params.noiseFrequency
    self.u_softness = params.softness
  }
}

struct DotGridUniformsRaw {
  var u_colorBack: SIMD4<Float>
  var u_colorFill: SIMD4<Float>
  var u_colorStroke: SIMD4<Float>
  var u_dotSize: Float
  var u_gapX: Float
  var u_gapY: Float
  var u_strokeWidth: Float
  var u_sizeRange: Float
  var u_opacityRange: Float
  var u_shape: Float

  init(params: DotGridParams) {
    self.u_colorBack = params.colorBack.rgba
    self.u_colorFill = params.colorFill.rgba
    self.u_colorStroke = params.colorStroke.rgba
    self.u_dotSize = params.dotSize
    self.u_gapX = params.gapX
    self.u_gapY = params.gapY
    self.u_strokeWidth = params.strokeWidth
    self.u_sizeRange = params.sizeRange
    self.u_opacityRange = params.opacityRange
    self.u_shape = params.shape.rawValue
  }
}

struct SimplexNoiseUniformsRaw {
  var u_time: Float
  var u_colors0: SIMD4<Float>
  var u_colors1: SIMD4<Float>
  var u_colors2: SIMD4<Float>
  var u_colors3: SIMD4<Float>
  var u_colors4: SIMD4<Float>
  var u_colors5: SIMD4<Float>
  var u_colors6: SIMD4<Float>
  var u_colors7: SIMD4<Float>
  var u_colors8: SIMD4<Float>
  var u_colors9: SIMD4<Float>
  var u_colorsCount: Float
  var u_stepsPerColor: Float
  var u_softness: Float

  init(time: Float, params: SimplexNoiseParams) {
    let padded =
      params.colors.map(\.rgba)
      + Array(
        repeating: SIMD4<Float>(0, 0, 0, 0),
        count: max(0, SimplexNoiseParams.maxColorCount - params.colors.count))
    self.u_time = time
    self.u_colors0 = padded[0]
    self.u_colors1 = padded[1]
    self.u_colors2 = padded[2]
    self.u_colors3 = padded[3]
    self.u_colors4 = padded[4]
    self.u_colors5 = padded[5]
    self.u_colors6 = padded[6]
    self.u_colors7 = padded[7]
    self.u_colors8 = padded[8]
    self.u_colors9 = padded[9]
    self.u_colorsCount = Float(params.colors.count)
    self.u_stepsPerColor = params.stepsPerColor
    self.u_softness = params.softness
  }
}

struct PerlinNoiseUniformsRaw {
  var u_time: Float
  var u_colorFront: SIMD4<Float>
  var u_colorBack: SIMD4<Float>
  var u_proportion: Float
  var u_softness: Float
  var u_octaveCount: Float
  var u_persistence: Float
  var u_lacunarity: Float

  init(time: Float, params: PerlinNoiseParams) {
    self.u_time = time
    self.u_colorFront = params.colorFront.rgba
    self.u_colorBack = params.colorBack.rgba
    self.u_proportion = params.proportion
    self.u_softness = params.softness
    self.u_octaveCount = params.octaveCount
    self.u_persistence = params.persistence
    self.u_lacunarity = params.lacunarity
  }
}

struct NeuroNoiseUniformsRaw {
  var u_time: Float
  var u_colorFront: SIMD4<Float>
  var u_colorMid: SIMD4<Float>
  var u_colorBack: SIMD4<Float>
  var u_brightness: Float
  var u_contrast: Float

  init(time: Float, params: NeuroNoiseParams) {
    self.u_time = time
    self.u_colorFront = params.colorFront.rgba
    self.u_colorMid = params.colorMid.rgba
    self.u_colorBack = params.colorBack.rgba
    self.u_brightness = params.brightness
    self.u_contrast = params.contrast
  }
}

struct WavesUniformsRaw {
  var u_colorFront: SIMD4<Float>
  var u_colorBack: SIMD4<Float>
  var u_shape: Float
  var u_frequency: Float
  var u_amplitude: Float
  var u_spacing: Float
  var u_proportion: Float
  var u_softness: Float

  init(params: WavesParams) {
    self.u_colorFront = params.colorFront.rgba
    self.u_colorBack = params.colorBack.rgba
    self.u_shape = params.shape
    self.u_frequency = params.frequency
    self.u_amplitude = params.amplitude
    self.u_spacing = params.spacing
    self.u_proportion = params.proportion
    self.u_softness = params.softness
  }
}

struct DitheringUniformsRaw {
  var u_time: Float
  var u_pxSize: Float
  var u_colorBack: SIMD4<Float>
  var u_colorFront: SIMD4<Float>
  var u_shape: Float
  var u_type: Float

  init(time: Float, params: DitheringParams) {
    self.u_time = time
    self.u_pxSize = params.size
    self.u_colorBack = params.colorBack.rgba
    self.u_colorFront = params.colorFront.rgba
    self.u_shape = params.shape.rawValue
    self.u_type = params.type.rawValue
  }
}

struct ColorPanelsUniformsRaw {
  var u_time: Float
  var u_scale: Float
  var u_colors0: SIMD4<Float>
  var u_colors1: SIMD4<Float>
  var u_colors2: SIMD4<Float>
  var u_colors3: SIMD4<Float>
  var u_colors4: SIMD4<Float>
  var u_colors5: SIMD4<Float>
  var u_colors6: SIMD4<Float>
  var u_colorsCount: Float
  var u_colorBack: SIMD4<Float>
  var u_density: Float
  var u_angle1: Float
  var u_angle2: Float
  var u_length: Float
  var u_edges: Float
  var u_blur: Float
  var u_fadeIn: Float
  var u_fadeOut: Float
  var u_gradient: Float

  init(time: Float, scale: Float, params: ColorPanelsParams) {
    let padded =
      params.colors.map(\.rgba)
      + Array(
        repeating: SIMD4<Float>(0, 0, 0, 0),
        count: max(0, ColorPanelsParams.maxColorCount - params.colors.count))
    self.u_time = time
    self.u_scale = scale
    self.u_colors0 = padded[0]
    self.u_colors1 = padded[1]
    self.u_colors2 = padded[2]
    self.u_colors3 = padded[3]
    self.u_colors4 = padded[4]
    self.u_colors5 = padded[5]
    self.u_colors6 = padded[6]
    self.u_colorsCount = Float(params.colors.count)
    self.u_colorBack = params.colorBack.rgba
    self.u_density = params.density
    self.u_angle1 = params.angle1
    self.u_angle2 = params.angle2
    self.u_length = params.length
    self.u_edges = params.edges
    self.u_blur = params.blur
    self.u_fadeIn = params.fadeIn
    self.u_fadeOut = params.fadeOut
    self.u_gradient = params.gradient
  }
}

struct DotOrbitUniformsRaw {
  var u_time: Float
  var u_colorBack: SIMD4<Float>
  var u_colors0: SIMD4<Float>
  var u_colors1: SIMD4<Float>
  var u_colors2: SIMD4<Float>
  var u_colors3: SIMD4<Float>
  var u_colors4: SIMD4<Float>
  var u_colors5: SIMD4<Float>
  var u_colors6: SIMD4<Float>
  var u_colors7: SIMD4<Float>
  var u_colors8: SIMD4<Float>
  var u_colors9: SIMD4<Float>
  var u_colorsCount: Float
  var u_stepsPerColor: Float
  var u_size: Float
  var u_sizeRange: Float
  var u_spreading: Float

  init(time: Float, params: DotOrbitParams) {
    let padded =
      params.colors.map(\.rgba)
      + Array(
        repeating: SIMD4<Float>(0, 0, 0, 0),
        count: max(0, DotOrbitParams.maxColorCount - params.colors.count))
    self.u_time = time
    self.u_colorBack = params.colorBack.rgba
    self.u_colors0 = padded[0]
    self.u_colors1 = padded[1]
    self.u_colors2 = padded[2]
    self.u_colors3 = padded[3]
    self.u_colors4 = padded[4]
    self.u_colors5 = padded[5]
    self.u_colors6 = padded[6]
    self.u_colors7 = padded[7]
    self.u_colors8 = padded[8]
    self.u_colors9 = padded[9]
    self.u_colorsCount = Float(params.colors.count)
    self.u_stepsPerColor = params.stepsPerColor
    self.u_size = params.size
    self.u_sizeRange = params.sizeRange
    self.u_spreading = params.spreading
  }
}

struct GodRaysUniformsRaw {
  var u_time: Float
  var u_colorBack: SIMD4<Float>
  var u_colorBloom: SIMD4<Float>
  var u_colors0: SIMD4<Float>
  var u_colors1: SIMD4<Float>
  var u_colors2: SIMD4<Float>
  var u_colors3: SIMD4<Float>
  var u_colors4: SIMD4<Float>
  var u_colorsCount: Float
  var u_density: Float
  var u_spotty: Float
  var u_midSize: Float
  var u_midIntensity: Float
  var u_intensity: Float
  var u_bloom: Float

  init(time: Float, params: GodRaysParams) {
    let padded =
      params.colors.map(\.rgba)
      + Array(
        repeating: SIMD4<Float>(0, 0, 0, 0),
        count: max(0, GodRaysParams.maxColorCount - params.colors.count))
    self.u_time = time
    self.u_colorBack = params.colorBack.rgba
    self.u_colorBloom = params.colorBloom.rgba
    self.u_colors0 = padded[0]
    self.u_colors1 = padded[1]
    self.u_colors2 = padded[2]
    self.u_colors3 = padded[3]
    self.u_colors4 = padded[4]
    self.u_colorsCount = Float(params.colors.count)
    self.u_density = params.density
    self.u_spotty = params.spotty
    self.u_midSize = params.midSize
    self.u_midIntensity = params.midIntensity
    self.u_intensity = params.intensity
    self.u_bloom = params.bloom
  }
}

struct GrainGradientUniformsRaw {
  var u_time: Float
  var u_colorBack: SIMD4<Float>
  var u_colors0: SIMD4<Float>
  var u_colors1: SIMD4<Float>
  var u_colors2: SIMD4<Float>
  var u_colors3: SIMD4<Float>
  var u_colors4: SIMD4<Float>
  var u_colors5: SIMD4<Float>
  var u_colors6: SIMD4<Float>
  var u_colorsCount: Float
  var u_softness: Float
  var u_intensity: Float
  var u_noise: Float
  var u_shape: Float

  init(time: Float, params: GrainGradientParams) {
    let padded =
      params.colors.map(\.rgba)
      + Array(
        repeating: SIMD4<Float>(0, 0, 0, 0),
        count: max(0, GrainGradientParams.maxColorCount - params.colors.count))
    self.u_time = time
    self.u_colorBack = params.colorBack.rgba
    self.u_colors0 = padded[0]
    self.u_colors1 = padded[1]
    self.u_colors2 = padded[2]
    self.u_colors3 = padded[3]
    self.u_colors4 = padded[4]
    self.u_colors5 = padded[5]
    self.u_colors6 = padded[6]
    self.u_colorsCount = Float(params.colors.count)
    self.u_softness = params.softness
    self.u_intensity = params.intensity
    self.u_noise = params.noise
    self.u_shape = params.shape.rawValue
  }
}

struct MetaballsUniformsRaw {
  var u_time: Float
  var u_colorBack: SIMD4<Float>
  var u_colors0: SIMD4<Float>
  var u_colors1: SIMD4<Float>
  var u_colors2: SIMD4<Float>
  var u_colors3: SIMD4<Float>
  var u_colors4: SIMD4<Float>
  var u_colors5: SIMD4<Float>
  var u_colors6: SIMD4<Float>
  var u_colors7: SIMD4<Float>
  var u_colorsCount: Float
  var u_size: Float
  var u_sizeRange: Float
  var u_count: Float

  init(time: Float, params: MetaballsParams) {
    let padded =
      params.colors.map(\.rgba)
      + Array(
        repeating: SIMD4<Float>(0, 0, 0, 0),
        count: max(0, MetaballsParams.maxColorCount - params.colors.count))
    self.u_time = time
    self.u_colorBack = params.colorBack.rgba
    self.u_colors0 = padded[0]
    self.u_colors1 = padded[1]
    self.u_colors2 = padded[2]
    self.u_colors3 = padded[3]
    self.u_colors4 = padded[4]
    self.u_colors5 = padded[5]
    self.u_colors6 = padded[6]
    self.u_colors7 = padded[7]
    self.u_colorsCount = Float(params.colors.count)
    self.u_size = params.size
    self.u_sizeRange = params.sizeRange
    self.u_count = params.count
  }
}

struct WarpUniformsRaw {
  var u_time: Float
  var u_scale: Float
  var u_colors0: SIMD4<Float>
  var u_colors1: SIMD4<Float>
  var u_colors2: SIMD4<Float>
  var u_colors3: SIMD4<Float>
  var u_colors4: SIMD4<Float>
  var u_colors5: SIMD4<Float>
  var u_colors6: SIMD4<Float>
  var u_colors7: SIMD4<Float>
  var u_colors8: SIMD4<Float>
  var u_colors9: SIMD4<Float>
  var u_colorsCount: Float
  var u_proportion: Float
  var u_softness: Float
  var u_shape: Float
  var u_shapeScale: Float
  var u_distortion: Float
  var u_swirl: Float
  var u_swirlIterations: Float

  init(time: Float, scale: Float, params: WarpParams) {
    let padded =
      params.colors.map(\.rgba)
      + Array(
        repeating: SIMD4<Float>(0, 0, 0, 0),
        count: max(0, WarpParams.maxColorCount - params.colors.count))
    self.u_time = time
    self.u_scale = scale
    self.u_colors0 = padded[0]
    self.u_colors1 = padded[1]
    self.u_colors2 = padded[2]
    self.u_colors3 = padded[3]
    self.u_colors4 = padded[4]
    self.u_colors5 = padded[5]
    self.u_colors6 = padded[6]
    self.u_colors7 = padded[7]
    self.u_colors8 = padded[8]
    self.u_colors9 = padded[9]
    self.u_colorsCount = Float(params.colors.count)
    self.u_proportion = params.proportion
    self.u_softness = params.softness
    self.u_shape = params.shape.rawValue
    self.u_shapeScale = params.shapeScale
    self.u_distortion = params.distortion
    self.u_swirl = params.swirl
    self.u_swirlIterations = params.swirlIterations
  }
}

struct VoronoiUniformsRaw {
  var u_time: Float
  var u_scale: Float
  var u_colors0: SIMD4<Float>
  var u_colors1: SIMD4<Float>
  var u_colors2: SIMD4<Float>
  var u_colors3: SIMD4<Float>
  var u_colors4: SIMD4<Float>
  var u_colorsCount: Float
  var u_stepsPerColor: Float
  var u_colorGlow: SIMD4<Float>
  var u_colorGap: SIMD4<Float>
  var u_distortion: Float
  var u_gap: Float
  var u_glow: Float

  init(time: Float, scale: Float, params: VoronoiParams) {
    let padded =
      params.colors.map(\.rgba)
      + Array(
        repeating: SIMD4<Float>(0, 0, 0, 0),
        count: max(0, VoronoiParams.maxColorCount - params.colors.count))
    self.u_time = time
    self.u_scale = scale
    self.u_colors0 = padded[0]
    self.u_colors1 = padded[1]
    self.u_colors2 = padded[2]
    self.u_colors3 = padded[3]
    self.u_colors4 = padded[4]
    self.u_colorsCount = Float(params.colors.count)
    self.u_stepsPerColor = params.stepsPerColor
    self.u_colorGlow = params.colorGlow.rgba
    self.u_colorGap = params.colorGap.rgba
    self.u_distortion = params.distortion
    self.u_gap = params.gap
    self.u_glow = params.glow
  }
}

struct PulsingBorderUniformsRaw {
  var u_time: Float
  var u_colorBack: SIMD4<Float>
  var u_colors0: SIMD4<Float>
  var u_colors1: SIMD4<Float>
  var u_colors2: SIMD4<Float>
  var u_colors3: SIMD4<Float>
  var u_colors4: SIMD4<Float>
  var u_colorsCount: Float
  var u_roundness: Float
  var u_thickness: Float
  var u_marginLeft: Float
  var u_marginRight: Float
  var u_marginTop: Float
  var u_marginBottom: Float
  var u_aspectRatio: Float
  var u_softness: Float
  var u_intensity: Float
  var u_bloom: Float
  var u_spots: Float
  var u_spotSize: Float
  var u_pulse: Float
  var u_smoke: Float
  var u_smokeSize: Float

  init(time: Float, params: PulsingBorderParams) {
    let padded =
      params.colors.map(\.rgba)
      + Array(
        repeating: SIMD4<Float>(0, 0, 0, 0),
        count: max(0, PulsingBorderParams.maxColorCount - params.colors.count))
    self.u_time = time
    self.u_colorBack = params.colorBack.rgba
    self.u_colors0 = padded[0]
    self.u_colors1 = padded[1]
    self.u_colors2 = padded[2]
    self.u_colors3 = padded[3]
    self.u_colors4 = padded[4]
    self.u_colorsCount = Float(params.colors.count)
    self.u_roundness = params.roundness
    self.u_thickness = params.thickness
    self.u_marginLeft = params.marginLeft
    self.u_marginRight = params.marginRight
    self.u_marginTop = params.marginTop
    self.u_marginBottom = params.marginBottom
    self.u_aspectRatio = params.aspectRatio.rawValue
    self.u_softness = params.softness
    self.u_intensity = params.intensity
    self.u_bloom = params.bloom
    self.u_spots = params.spots
    self.u_spotSize = params.spotSize
    self.u_pulse = params.pulse
    self.u_smoke = params.smoke
    self.u_smokeSize = params.smokeSize
  }
}

struct SmokeRingUniformsRaw {
  var u_time: Float
  var u_colorBack: SIMD4<Float>
  var u_colors0: SIMD4<Float>
  var u_colors1: SIMD4<Float>
  var u_colors2: SIMD4<Float>
  var u_colors3: SIMD4<Float>
  var u_colors4: SIMD4<Float>
  var u_colors5: SIMD4<Float>
  var u_colors6: SIMD4<Float>
  var u_colors7: SIMD4<Float>
  var u_colors8: SIMD4<Float>
  var u_colors9: SIMD4<Float>
  var u_colorsCount: Float
  var u_thickness: Float
  var u_radius: Float
  var u_innerShape: Float
  var u_noiseScale: Float
  var u_noiseIterations: Float

  init(time: Float, params: SmokeRingParams) {
    let padded =
      params.colors.map(\.rgba)
      + Array(
        repeating: SIMD4<Float>(0, 0, 0, 0),
        count: max(0, SmokeRingParams.maxColorCount - params.colors.count))
    self.u_time = time
    self.u_colorBack = params.colorBack.rgba
    self.u_colors0 = padded[0]
    self.u_colors1 = padded[1]
    self.u_colors2 = padded[2]
    self.u_colors3 = padded[3]
    self.u_colors4 = padded[4]
    self.u_colors5 = padded[5]
    self.u_colors6 = padded[6]
    self.u_colors7 = padded[7]
    self.u_colors8 = padded[8]
    self.u_colors9 = padded[9]
    self.u_colorsCount = Float(params.colors.count)
    self.u_thickness = params.thickness
    self.u_radius = params.radius
    self.u_innerShape = params.innerShape
    self.u_noiseScale = params.noiseScale
    self.u_noiseIterations = params.noiseIterations
  }
}

struct ImageDitheringUniformsRaw {
  var u_colorFront: SIMD4<Float>
  var u_colorBack: SIMD4<Float>
  var u_colorHighlight: SIMD4<Float>
  var u_type: Float
  var u_pxSize: Float
  var u_originalColors: Float
  var u_inverted: Float
  var u_colorSteps: Float

  init(params: ImageDitheringParams) {
    self.u_colorFront = params.colorFront.rgba
    self.u_colorBack = params.colorBack.rgba
    self.u_colorHighlight = params.colorHighlight.rgba
    self.u_type = params.type.rawValue
    self.u_pxSize = params.size
    self.u_originalColors = params.originalColors
    self.u_inverted = params.inverted
    self.u_colorSteps = params.colorSteps
  }
}

struct HalftoneDotsUniformsRaw {
  var u_time: Float
  var u_colorFront: SIMD4<Float>
  var u_colorBack: SIMD4<Float>
  var u_radius: Float
  var u_contrast: Float
  var u_size: Float
  var u_grainMixer: Float
  var u_grainOverlay: Float
  var u_grainSize: Float
  var u_grid: Float
  var u_originalColors: Float
  var u_inverted: Float
  var u_type: Float

  init(time: Float, params: HalftoneDotsParams) {
    self.u_time = time
    self.u_colorFront = params.colorFront.rgba
    self.u_colorBack = params.colorBack.rgba
    self.u_radius = params.radius
    self.u_contrast = params.contrast
    self.u_size = params.size
    self.u_grainMixer = params.grainMixer
    self.u_grainOverlay = params.grainOverlay
    self.u_grainSize = params.grainSize
    self.u_grid = params.grid.rawValue
    self.u_originalColors = params.originalColors
    self.u_inverted = params.inverted
    self.u_type = params.type.rawValue
  }
}

struct HalftoneCmykUniformsRaw {
  var u_colorBack: SIMD4<Float>
  var u_colorC: SIMD4<Float>
  var u_colorM: SIMD4<Float>
  var u_colorY: SIMD4<Float>
  var u_colorK: SIMD4<Float>
  var u_size: Float
  var u_minDot: Float
  var u_contrast: Float
  var u_grainSize: Float
  var u_grainMixer: Float
  var u_grainOverlay: Float
  var u_gridNoise: Float
  var u_softness: Float
  var u_floodC: Float
  var u_floodM: Float
  var u_floodY: Float
  var u_floodK: Float
  var u_gainC: Float
  var u_gainM: Float
  var u_gainY: Float
  var u_gainK: Float
  var u_type: Float

  init(params: HalftoneCmykParams) {
    self.u_colorBack = params.colorBack.rgba
    self.u_colorC = params.colorC.rgba
    self.u_colorM = params.colorM.rgba
    self.u_colorY = params.colorY.rgba
    self.u_colorK = params.colorK.rgba
    self.u_size = params.size
    self.u_minDot = 0.0
    self.u_contrast = params.contrast
    self.u_grainSize = params.grainSize
    self.u_grainMixer = params.grainMixer
    self.u_grainOverlay = params.grainOverlay
    self.u_gridNoise = params.gridNoise
    self.u_softness = params.softness
    self.u_floodC = params.floodC
    self.u_floodM = params.floodM
    self.u_floodY = params.floodY
    self.u_floodK = params.floodK
    self.u_gainC = params.gainC
    self.u_gainM = params.gainM
    self.u_gainY = params.gainY
    self.u_gainK = params.gainK
    self.u_type = params.type.rawValue
  }
}

struct HeatmapUniformsRaw {
  var u_time: Float
  var u_colorBack: SIMD4<Float>
  var u_colors0: SIMD4<Float>
  var u_colors1: SIMD4<Float>
  var u_colors2: SIMD4<Float>
  var u_colors3: SIMD4<Float>
  var u_colors4: SIMD4<Float>
  var u_colors5: SIMD4<Float>
  var u_colors6: SIMD4<Float>
  var u_colors7: SIMD4<Float>
  var u_colors8: SIMD4<Float>
  var u_colors9: SIMD4<Float>
  var u_colorsCount: Float
  var u_contour: Float
  var u_angle: Float
  var u_noise: Float
  var u_innerGlow: Float
  var u_outerGlow: Float

  init(time: Float, params: HeatmapParams) {
    let padded =
      params.colors.map(\.rgba)
      + Array(
        repeating: SIMD4<Float>(0, 0, 0, 0),
        count: max(0, HeatmapParams.maxColorCount - params.colors.count))
    self.u_time = time
    self.u_colorBack = params.colorBack.rgba
    self.u_colors0 = padded[0]
    self.u_colors1 = padded[1]
    self.u_colors2 = padded[2]
    self.u_colors3 = padded[3]
    self.u_colors4 = padded[4]
    self.u_colors5 = padded[5]
    self.u_colors6 = padded[6]
    self.u_colors7 = padded[7]
    self.u_colors8 = padded[8]
    self.u_colors9 = padded[9]
    self.u_colorsCount = Float(params.colors.count)
    self.u_contour = params.contour
    self.u_angle = params.angle
    self.u_noise = params.noise
    self.u_innerGlow = params.innerGlow
    self.u_outerGlow = params.outerGlow
  }
}

struct LiquidMetalUniformsRaw {
  var u_time: Float
  var u_colorBack: SIMD4<Float>
  var u_colorTint: SIMD4<Float>
  var u_repetition: Float
  var u_softness: Float
  var u_shiftRed: Float
  var u_shiftBlue: Float
  var u_distortion: Float
  var u_contour: Float
  var u_angle: Float
  var u_shape: Float
  var u_isImage: Float

  init(time: Float, params: LiquidMetalParams) {
    self.u_time = time
    self.u_colorBack = params.colorBack.rgba
    self.u_colorTint = params.colorTint.rgba
    self.u_repetition = params.repetition
    self.u_softness = params.softness
    self.u_shiftRed = params.shiftRed
    self.u_shiftBlue = params.shiftBlue
    self.u_distortion = params.distortion
    self.u_contour = params.contour
    self.u_angle = params.angle
    self.u_shape = params.shape.rawValue
    // Set by the renderer from whether an image texture is bound.
    self.u_isImage = 0
  }
}

struct PaperTextureUniformsRaw {
  var u_colorFront: SIMD4<Float>
  var u_colorBack: SIMD4<Float>
  var u_contrast: Float
  var u_roughness: Float
  var u_fiber: Float
  var u_fiberSize: Float
  var u_crumples: Float
  var u_crumpleSize: Float
  var u_folds: Float
  var u_foldCount: Float
  var u_drops: Float
  var u_seed: Float
  var u_fade: Float

  init(params: PaperTextureParams) {
    self.u_colorFront = params.colorFront.rgba
    self.u_colorBack = params.colorBack.rgba
    self.u_contrast = params.contrast
    self.u_roughness = params.roughness
    self.u_fiber = params.fiber
    self.u_fiberSize = params.fiberSize
    self.u_crumples = params.crumples
    self.u_crumpleSize = params.crumpleSize
    self.u_folds = params.folds
    self.u_foldCount = params.foldCount
    self.u_drops = params.drops
    self.u_seed = params.seed
    self.u_fade = params.fade
  }
}

struct WaterUniformsRaw {
  var u_time: Float
  var u_colorBack: SIMD4<Float>
  var u_colorHighlight: SIMD4<Float>
  var u_highlights: Float
  var u_layering: Float
  var u_edges: Float
  var u_caustic: Float
  var u_waves: Float
  var u_size: Float

  init(time: Float, params: WaterParams) {
    self.u_time = time
    self.u_colorBack = params.colorBack.rgba
    self.u_colorHighlight = params.colorHighlight.rgba
    self.u_highlights = params.highlights
    self.u_layering = params.layering
    self.u_edges = params.edges
    self.u_caustic = params.caustic
    self.u_waves = params.waves
    self.u_size = params.size
  }
}

struct FlutedGlassUniformsRaw {
  var u_resolution: SIMD2<Float>
  var u_pixelRatio: Float
  var u_rotation: Float
  var u_colorBack: SIMD4<Float>
  var u_colorShadow: SIMD4<Float>
  var u_colorHighlight: SIMD4<Float>
  var u_shadows: Float
  var u_size: Float
  var u_angle: Float
  var u_stretch: Float
  var u_shape: Float
  var u_distortion: Float
  var u_highlights: Float
  var u_distortionShape: Float
  var u_shift: Float
  var u_blur: Float
  var u_edges: Float
  var u_marginLeft: Float
  var u_marginRight: Float
  var u_marginTop: Float
  var u_marginBottom: Float
  var u_grainMixer: Float
  var u_grainOverlay: Float

  init(
    resolution: SIMD2<Float>, pixelRatio: Float, rotation: Float, params: FlutedGlassParams
  ) {
    self.u_resolution = resolution
    self.u_pixelRatio = pixelRatio
    self.u_rotation = rotation
    self.u_colorBack = params.colorBack.rgba
    self.u_colorShadow = params.colorShadow.rgba
    self.u_colorHighlight = params.colorHighlight.rgba
    self.u_shadows = params.shadows
    self.u_size = params.size
    self.u_angle = params.angle
    self.u_stretch = params.stretch
    self.u_shape = params.shape.rawValue
    self.u_distortion = params.distortion
    self.u_highlights = params.highlights
    self.u_distortionShape = params.distortionShape.rawValue
    self.u_shift = params.shift
    self.u_blur = params.blur
    self.u_edges = params.edges
    self.u_marginLeft = params.marginLeft
    self.u_marginRight = params.marginRight
    self.u_marginTop = params.marginTop
    self.u_marginBottom = params.marginBottom
    self.u_grainMixer = params.grainMixer
    self.u_grainOverlay = params.grainOverlay
  }
}

struct GemSmokeUniformsRaw {
  var u_time: Float
  var u_colors0: SIMD4<Float>
  var u_colors1: SIMD4<Float>
  var u_colors2: SIMD4<Float>
  var u_colors3: SIMD4<Float>
  var u_colors4: SIMD4<Float>
  var u_colors5: SIMD4<Float>
  var u_colorsCount: Float
  var u_colorBack: SIMD4<Float>
  var u_colorInner: SIMD4<Float>
  var u_innerDistortion: Float
  var u_outerDistortion: Float
  var u_outerGlow: Float
  var u_innerGlow: Float
  var u_offset: Float
  var u_angle: Float
  var u_size: Float
  var u_shape: Float
  var u_isImage: Float

  init(time: Float, params: GemSmokeParams) {
    let padded =
      params.colors.map(\.rgba)
      + Array(
        repeating: SIMD4<Float>(0, 0, 0, 0),
        count: max(0, GemSmokeParams.maxColorCount - params.colors.count))
    self.u_time = time
    self.u_colors0 = padded[0]
    self.u_colors1 = padded[1]
    self.u_colors2 = padded[2]
    self.u_colors3 = padded[3]
    self.u_colors4 = padded[4]
    self.u_colors5 = padded[5]
    self.u_colorsCount = Float(params.colors.count)
    self.u_colorBack = params.colorBack.rgba
    self.u_colorInner = params.colorInner.rgba
    self.u_innerDistortion = params.innerDistortion
    self.u_outerDistortion = params.outerDistortion
    self.u_outerGlow = params.outerGlow
    self.u_innerGlow = params.innerGlow
    self.u_offset = params.offset
    self.u_angle = params.angle
    self.u_size = params.size
    self.u_shape = params.shape.rawValue
    // Set by the renderer from whether an image texture is bound.
    self.u_isImage = 0
  }
}
