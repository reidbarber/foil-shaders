import Foundation
import simd

// MARK: - Shader Sizing

public enum ShaderFit: Float, Sendable {
  case none = 0.0
  case contain = 1.0
  case cover = 2.0
}

public struct ShaderSizingParams: Sendable {
  public var fit: ShaderFit
  public var scale: Float
  public var rotation: Float
  public var originX: Float
  public var originY: Float
  public var offsetX: Float
  public var offsetY: Float
  public var worldWidth: Float
  public var worldHeight: Float

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

public struct ShaderMotionParams: Sendable {
  public var speed: Float
  public var frame: Float

  public init(speed: Float = 0.0, frame: Float = 0.0) {
    self.speed = speed
    self.frame = frame
  }
}

// MARK: - Mesh Gradient

public struct MeshGradientParams {
  public static let maxColorCount = 10
  public var colors: [SIMD4<Float>]
  public var distortion: Float
  public var swirl: Float
  public var grainMixer: Float
  public var grainOverlay: Float

  public init(
    colors: [SIMD4<Float>],
    distortion: Float = 0.8,
    swirl: Float = 0.1,
    grainMixer: Float = 0,
    grainOverlay: Float = 0
  ) {
    self.colors = Array(colors.prefix(Self.maxColorCount))
    self.distortion = distortion
    self.swirl = swirl
    self.grainMixer = grainMixer
    self.grainOverlay = grainOverlay
  }
}

// MARK: - Static Mesh Gradient

public struct StaticMeshGradientParams {
  public static let maxColorCount = 10
  public var colors: [SIMD4<Float>]
  public var positions: Float
  public var waveX: Float
  public var waveXShift: Float
  public var waveY: Float
  public var waveYShift: Float
  public var mixing: Float
  public var grainMixer: Float
  public var grainOverlay: Float

  public init(
    colors: [SIMD4<Float>],
    positions: Float = 2.0,
    waveX: Float = 1.0,
    waveXShift: Float = 0.6,
    waveY: Float = 1.0,
    waveYShift: Float = 0.21,
    mixing: Float = 0.93,
    grainMixer: Float = 0,
    grainOverlay: Float = 0
  ) {
    self.colors = Array(colors.prefix(Self.maxColorCount))
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

public struct StaticRadialGradientParams {
  public static let maxColorCount = 10
  public var colorBack: SIMD4<Float>
  public var colors: [SIMD4<Float>]
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

  public init(
    colorBack: SIMD4<Float> = SIMD4<Float>(0, 0, 0, 1),
    colors: [SIMD4<Float>],
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
    self.colors = Array(colors.prefix(Self.maxColorCount))
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

public struct SwirlParams {
  public static let maxColorCount = 10
  public var colorBack: SIMD4<Float>
  public var colors: [SIMD4<Float>]
  public var bandCount: Float
  public var twist: Float
  public var center: Float
  public var proportion: Float
  public var softness: Float
  public var noise: Float
  public var noiseFrequency: Float

  public init(
    colorBack: SIMD4<Float> = SIMD4<Float>(0.2, 0, 0, 1),
    colors: [SIMD4<Float>],
    bandCount: Float = 4.0,
    twist: Float = 0.1,
    center: Float = 0.2,
    proportion: Float = 0.5,
    softness: Float = 0,
    noise: Float = 0.2,
    noiseFrequency: Float = 0.4
  ) {
    self.colorBack = colorBack
    self.colors = Array(colors.prefix(Self.maxColorCount))
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

public struct SpiralParams {
  public var colorBack: SIMD4<Float>
  public var colorFront: SIMD4<Float>
  public var density: Float
  public var distortion: Float
  public var strokeWidth: Float
  public var strokeTaper: Float
  public var strokeCap: Float
  public var noise: Float
  public var noiseFrequency: Float
  public var softness: Float

  public init(
    colorBack: SIMD4<Float> = SIMD4<Float>(0, 0.078431375, 0.16078432, 1),
    colorFront: SIMD4<Float>,
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

public struct DotGridParams {
  public var colorBack: SIMD4<Float>
  public var colorFill: SIMD4<Float>
  public var colorStroke: SIMD4<Float>
  public var dotSize: Float
  public var gapX: Float
  public var gapY: Float
  public var strokeWidth: Float
  public var sizeRange: Float
  public var opacityRange: Float
  public var shape: Float

  public init(
    colorBack: SIMD4<Float> = SIMD4<Float>(0, 0, 0, 1),
    colorFill: SIMD4<Float>,
    colorStroke: SIMD4<Float>,
    dotSize: Float = 2,
    gapX: Float = 32,
    gapY: Float = 32,
    strokeWidth: Float = 0,
    sizeRange: Float = 0,
    opacityRange: Float = 0,
    shape: Float = 0
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

public struct SimplexNoiseParams {
  public static let maxColorCount = 10
  public var colors: [SIMD4<Float>]
  public var stepsPerColor: Float
  public var softness: Float

  public init(
    colors: [SIMD4<Float>],
    stepsPerColor: Float = 2.0,
    softness: Float = 0
  ) {
    self.colors = Array(colors.prefix(Self.maxColorCount))
    self.stepsPerColor = stepsPerColor
    self.softness = softness
  }
}

// MARK: - Perlin Noise

public struct PerlinNoiseParams {
  public var colorFront: SIMD4<Float>
  public var colorBack: SIMD4<Float>
  public var proportion: Float
  public var softness: Float
  public var octaveCount: Float
  public var persistence: Float
  public var lacunarity: Float

  public init(
    colorFront: SIMD4<Float>,
    colorBack: SIMD4<Float> = SIMD4<Float>(0.3882353, 0.16470589, 0.8352941, 1),
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

public struct NeuroNoiseParams {
  public var colorFront: SIMD4<Float>
  public var colorMid: SIMD4<Float>
  public var colorBack: SIMD4<Float>
  public var brightness: Float
  public var contrast: Float

  public init(
    colorFront: SIMD4<Float>,
    colorMid: SIMD4<Float>,
    colorBack: SIMD4<Float> = SIMD4<Float>(0, 0, 0, 1),
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

public struct WavesParams {
  public var colorFront: SIMD4<Float>
  public var colorBack: SIMD4<Float>
  public var shape: Float
  public var frequency: Float
  public var amplitude: Float
  public var spacing: Float
  public var proportion: Float
  public var softness: Float

  public init(
    colorFront: SIMD4<Float>,
    colorBack: SIMD4<Float> = SIMD4<Float>(0, 0, 0, 1),
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

public struct DitheringParams {
  public var colorBack: SIMD4<Float>
  public var colorFront: SIMD4<Float>
  public var shape: Float
  public var type: Float
  public var size: Float

  public init(
    colorBack: SIMD4<Float> = SIMD4<Float>(0, 0, 0, 1),
    colorFront: SIMD4<Float>,
    shape: Float = 7.0,
    type: Float = 3.0,
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

public struct ColorPanelsParams {
  public static let maxColorCount = 7
  public var colors: [SIMD4<Float>]
  public var colorBack: SIMD4<Float>
  public var density: Float
  public var angle1: Float
  public var angle2: Float
  public var length: Float
  public var edges: Float
  public var blur: Float
  public var fadeIn: Float
  public var fadeOut: Float
  public var gradient: Float

  public init(
    colors: [SIMD4<Float>],
    colorBack: SIMD4<Float> = SIMD4<Float>(0, 0, 0, 1),
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
    self.colors = Array(colors.prefix(Self.maxColorCount))
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

public struct DotOrbitParams {
  public static let maxColorCount = 10
  public var colorBack: SIMD4<Float>
  public var colors: [SIMD4<Float>]
  public var stepsPerColor: Float
  public var size: Float
  public var sizeRange: Float
  public var spreading: Float

  public init(
    colorBack: SIMD4<Float> = SIMD4<Float>(0, 0, 0, 1),
    colors: [SIMD4<Float>],
    stepsPerColor: Float = 4.0,
    size: Float = 1.0,
    sizeRange: Float = 0,
    spreading: Float = 1.0
  ) {
    self.colorBack = colorBack
    self.colors = Array(colors.prefix(Self.maxColorCount))
    self.stepsPerColor = stepsPerColor
    self.size = size
    self.sizeRange = sizeRange
    self.spreading = spreading
  }
}

// MARK: - God Rays

public struct GodRaysParams {
  public static let maxColorCount = 5
  public var colorBack: SIMD4<Float>
  public var colorBloom: SIMD4<Float>
  public var colors: [SIMD4<Float>]
  public var density: Float
  public var spotty: Float
  public var midSize: Float
  public var midIntensity: Float
  public var intensity: Float
  public var bloom: Float

  public init(
    colorBack: SIMD4<Float> = SIMD4<Float>(0, 0, 0, 1),
    colorBloom: SIMD4<Float> = SIMD4<Float>(0, 0, 1, 1),
    colors: [SIMD4<Float>],
    density: Float = 0.3,
    spotty: Float = 0.3,
    midSize: Float = 0.2,
    midIntensity: Float = 0.4,
    intensity: Float = 0.8,
    bloom: Float = 0.4
  ) {
    self.colorBack = colorBack
    self.colorBloom = colorBloom
    self.colors = Array(colors.prefix(Self.maxColorCount))
    self.density = density
    self.spotty = spotty
    self.midSize = midSize
    self.midIntensity = midIntensity
    self.intensity = intensity
    self.bloom = bloom
  }
}

// MARK: - Grain Gradient

public struct GrainGradientParams {
  public static let maxColorCount = 7
  public var colorBack: SIMD4<Float>
  public var colors: [SIMD4<Float>]
  public var softness: Float
  public var intensity: Float
  public var noise: Float
  public var shape: Float

  public init(
    colorBack: SIMD4<Float> = SIMD4<Float>(0, 0, 0, 1),
    colors: [SIMD4<Float>],
    softness: Float = 0.5,
    intensity: Float = 0.5,
    noise: Float = 0.25,
    shape: Float = 4.0
  ) {
    self.colorBack = colorBack
    self.colors = Array(colors.prefix(Self.maxColorCount))
    self.softness = softness
    self.intensity = intensity
    self.noise = noise
    self.shape = shape
  }
}

// MARK: - Metaballs

public struct MetaballsParams {
  public static let maxColorCount = 8
  public var colorBack: SIMD4<Float>
  public var colors: [SIMD4<Float>]
  public var count: Float
  public var size: Float
  public var sizeRange: Float

  public init(
    colorBack: SIMD4<Float> = SIMD4<Float>(0, 0, 0, 1),
    colors: [SIMD4<Float>],
    count: Float = 10,
    size: Float = 0.83,
    sizeRange: Float = 0.2
  ) {
    self.colorBack = colorBack
    self.colors = Array(colors.prefix(Self.maxColorCount))
    self.count = count
    self.size = size
    self.sizeRange = sizeRange
  }
}

// MARK: - Warp

public struct WarpParams {
  public static let maxColorCount = 10
  public var colors: [SIMD4<Float>]
  public var proportion: Float
  public var softness: Float
  public var shape: Float
  public var shapeScale: Float
  public var distortion: Float
  public var swirl: Float
  public var swirlIterations: Float

  public init(
    colors: [SIMD4<Float>],
    proportion: Float = 0.45,
    softness: Float = 1.0,
    shape: Float = 0.0,
    shapeScale: Float = 0.1,
    distortion: Float = 0.25,
    swirl: Float = 0.8,
    swirlIterations: Float = 10.0
  ) {
    self.colors = Array(colors.prefix(Self.maxColorCount))
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

public struct VoronoiParams {
  public static let maxColorCount = 5
  public var colors: [SIMD4<Float>]
  public var stepsPerColor: Float
  public var colorGap: SIMD4<Float>
  public var colorGlow: SIMD4<Float>
  public var distortion: Float
  public var gap: Float
  public var glow: Float

  public init(
    colors: [SIMD4<Float>],
    stepsPerColor: Float = 3.0,
    colorGap: SIMD4<Float> = SIMD4<Float>(0.18039216, 0, 0, 1),
    colorGlow: SIMD4<Float> = SIMD4<Float>(1, 1, 1, 1),
    distortion: Float = 0.4,
    gap: Float = 0.04,
    glow: Float = 0
  ) {
    self.colors = Array(colors.prefix(Self.maxColorCount))
    self.stepsPerColor = stepsPerColor
    self.colorGap = colorGap
    self.colorGlow = colorGlow
    self.distortion = distortion
    self.gap = gap
    self.glow = glow
  }
}

// MARK: - Pulsing Border

public struct PulsingBorderParams {
  public static let maxColorCount = 5
  public var colorBack: SIMD4<Float>
  public var colors: [SIMD4<Float>]
  public var roundness: Float
  public var thickness: Float
  public var marginLeft: Float
  public var marginRight: Float
  public var marginTop: Float
  public var marginBottom: Float
  public var aspectRatio: Float
  public var softness: Float
  public var intensity: Float
  public var bloom: Float
  public var spots: Float
  public var spotSize: Float
  public var pulse: Float
  public var smoke: Float
  public var smokeSize: Float

  public init(
    colorBack: SIMD4<Float> = SIMD4<Float>(0, 0, 0, 1),
    colors: [SIMD4<Float>],
    roundness: Float = 0.25,
    thickness: Float = 0.1,
    marginLeft: Float = 0,
    marginRight: Float = 0,
    marginTop: Float = 0,
    marginBottom: Float = 0,
    aspectRatio: Float = 0.0,
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
    self.colors = Array(colors.prefix(Self.maxColorCount))
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

public struct SmokeRingParams {
  public static let maxColorCount = 10
  public var colorBack: SIMD4<Float>
  public var colors: [SIMD4<Float>]
  public var noiseScale: Float
  public var thickness: Float
  public var radius: Float
  public var innerShape: Float
  public var noiseIterations: Float

  public init(
    colorBack: SIMD4<Float> = SIMD4<Float>(0, 0, 0, 1),
    colors: [SIMD4<Float>],
    noiseScale: Float = 3.0,
    thickness: Float = 0.65,
    radius: Float = 0.25,
    innerShape: Float = 0.7,
    noiseIterations: Float = 8.0
  ) {
    self.colorBack = colorBack
    self.colors = Array(colors.prefix(Self.maxColorCount))
    self.noiseScale = noiseScale
    self.thickness = thickness
    self.radius = radius
    self.innerShape = innerShape
    self.noiseIterations = noiseIterations
  }
}

// MARK: - Image Dithering

public struct ImageDitheringParams {
  public var colorFront: SIMD4<Float>
  public var colorBack: SIMD4<Float>
  public var colorHighlight: SIMD4<Float>
  public var type: Float
  public var size: Float
  public var colorSteps: Float
  public var originalColors: Float
  public var inverted: Float

  public init(
    colorFront: SIMD4<Float>,
    colorBack: SIMD4<Float> = SIMD4<Float>(0, 0.047058824, 0.21960784, 1),
    colorHighlight: SIMD4<Float> = SIMD4<Float>(0.91764706, 1, 0.5803922, 1),
    type: Float = 4.0,
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

public struct HalftoneDotsParams {
  public var colorFront: SIMD4<Float>
  public var colorBack: SIMD4<Float>
  public var size: Float
  public var grid: Float
  public var radius: Float
  public var contrast: Float
  public var originalColors: Float
  public var inverted: Float
  public var grainMixer: Float
  public var grainOverlay: Float
  public var grainSize: Float
  public var type: Float

  public init(
    colorFront: SIMD4<Float>,
    colorBack: SIMD4<Float> = SIMD4<Float>(0.9490196, 0.94509804, 0.9098039, 1),
    size: Float = 0.5,
    grid: Float = 1.0,
    radius: Float = 1.25,
    contrast: Float = 0.4,
    originalColors: Float = 0.0,
    inverted: Float = 0.0,
    grainMixer: Float = 0.2,
    grainOverlay: Float = 0.2,
    grainSize: Float = 0.5,
    type: Float = 1.0
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

public struct HalftoneCmykParams {
  public var colorBack: SIMD4<Float>
  public var colorC: SIMD4<Float>
  public var colorM: SIMD4<Float>
  public var colorY: SIMD4<Float>
  public var colorK: SIMD4<Float>
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
  public var type: Float

  public init(
    colorBack: SIMD4<Float> = SIMD4<Float>(0.9843137, 0.98039216, 0.9607843, 1),
    colorC: SIMD4<Float> = SIMD4<Float>(0, 0.7058824, 1, 1),
    colorM: SIMD4<Float> = SIMD4<Float>(0.9882353, 0.31764707, 0.62352943, 1),
    colorY: SIMD4<Float> = SIMD4<Float>(1, 0.84705883, 0, 1),
    colorK: SIMD4<Float> = SIMD4<Float>(0.13725491, 0.12156863, 0.1254902, 1),
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
    type: Float = 1.0
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

public struct HeatmapParams {
  public static let maxColorCount = 10
  public var colorBack: SIMD4<Float>
  public var colors: [SIMD4<Float>]
  public var contour: Float
  public var angle: Float
  public var noise: Float
  public var innerGlow: Float
  public var outerGlow: Float

  public init(
    colorBack: SIMD4<Float> = SIMD4<Float>(0, 0, 0, 1),
    colors: [SIMD4<Float>],
    contour: Float = 0.5,
    angle: Float = 0.0,
    noise: Float = 0,
    innerGlow: Float = 0.5,
    outerGlow: Float = 0.5
  ) {
    self.colorBack = colorBack
    self.colors = Array(colors.prefix(Self.maxColorCount))
    self.contour = contour
    self.angle = angle
    self.noise = noise
    self.innerGlow = innerGlow
    self.outerGlow = outerGlow
  }
}

// MARK: - Liquid Metal

public struct LiquidMetalParams {
  public var colorBack: SIMD4<Float>
  public var colorTint: SIMD4<Float>
  public var repetition: Float
  public var softness: Float
  public var shiftRed: Float
  public var shiftBlue: Float
  public var distortion: Float
  public var contour: Float
  public var angle: Float
  public var shape: Float
  public var isImage: Float

  public init(
    colorBack: SIMD4<Float> = SIMD4<Float>(0.6666667, 0.6666667, 0.6745098, 1),
    colorTint: SIMD4<Float> = SIMD4<Float>(1, 1, 1, 1),
    repetition: Float = 2.0,
    softness: Float = 0.1,
    shiftRed: Float = 0.3,
    shiftBlue: Float = 0.3,
    distortion: Float = 0.07,
    contour: Float = 0.4,
    angle: Float = 70.0,
    shape: Float = 3.0,
    isImage: Float = 0
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
    self.isImage = isImage
  }
}

// MARK: - Paper Texture

public struct PaperTextureParams {
  public var colorFront: SIMD4<Float>
  public var colorBack: SIMD4<Float>
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

  public init(
    colorFront: SIMD4<Float> = SIMD4<Float>(0.62352943, 0.6784314, 0.7372549, 1),
    colorBack: SIMD4<Float> = SIMD4<Float>(1, 1, 1, 1),
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

public struct WaterParams {
  public var colorBack: SIMD4<Float>
  public var colorHighlight: SIMD4<Float>
  public var highlights: Float
  public var layering: Float
  public var edges: Float
  public var caustic: Float
  public var waves: Float
  public var size: Float

  public init(
    colorBack: SIMD4<Float> = SIMD4<Float>(0.5647059, 0.5647059, 0.5647059, 1),
    colorHighlight: SIMD4<Float> = SIMD4<Float>(1, 1, 1, 1),
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

public struct FlutedGlassParams {
  public var colorBack: SIMD4<Float>
  public var colorShadow: SIMD4<Float>
  public var colorHighlight: SIMD4<Float>
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
  public var distortionShape: Float
  public var highlights: Float
  public var shape: Float
  public var grainMixer: Float
  public var grainOverlay: Float

  public init(
    colorBack: SIMD4<Float> = SIMD4<Float>(0, 0, 0, 0),
    colorShadow: SIMD4<Float> = SIMD4<Float>(0, 0, 0, 1),
    colorHighlight: SIMD4<Float> = SIMD4<Float>(1, 1, 1, 1),
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
    distortionShape: Float = 1.0,
    highlights: Float = 0.1,
    shape: Float = 1.0,
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

public struct GemSmokeParams {
  public static let maxColorCount = 6
  public var colors: [SIMD4<Float>]
  public var colorBack: SIMD4<Float>
  public var colorInner: SIMD4<Float>
  public var innerDistortion: Float
  public var outerDistortion: Float
  public var outerGlow: Float
  public var innerGlow: Float
  public var offset: Float
  public var angle: Float
  public var size: Float
  public var shape: Float
  public var isImage: Float

  public init(
    colors: [SIMD4<Float>],
    colorBack: SIMD4<Float> = SIMD4<Float>(0.9411765, 0.9372549, 0.91764706, 1),
    colorInner: SIMD4<Float> = SIMD4<Float>(0.98039216, 0.98039216, 0.9607843, 1),
    innerDistortion: Float = 0.8,
    outerDistortion: Float = 0.6,
    outerGlow: Float = 0.55,
    innerGlow: Float = 1,
    offset: Float = 0,
    angle: Float = 0,
    size: Float = 0.8,
    shape: Float = 3,
    isImage: Float = 0
  ) {
    self.colors = Array(colors.prefix(Self.maxColorCount))
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
    self.isImage = isImage
  }
}
// MARK: - Metal Uniforms

public struct VertexUniforms {
  public var u_resolution: SIMD2<Float>
  public var u_pixelRatio: Float
  public var u_imageAspectRatio: Float
  public var u_originX: Float
  public var u_originY: Float
  public var u_worldWidth: Float
  public var u_worldHeight: Float
  public var u_fit: Float
  public var u_scale: Float
  public var u_rotation: Float
  public var u_offsetX: Float
  public var u_offsetY: Float

  public init(
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

public struct MeshGradientUniformsRaw {
  public var u_time: Float
  public var u_colors0: SIMD4<Float>
  public var u_colors1: SIMD4<Float>
  public var u_colors2: SIMD4<Float>
  public var u_colors3: SIMD4<Float>
  public var u_colors4: SIMD4<Float>
  public var u_colors5: SIMD4<Float>
  public var u_colors6: SIMD4<Float>
  public var u_colors7: SIMD4<Float>
  public var u_colors8: SIMD4<Float>
  public var u_colors9: SIMD4<Float>
  public var u_colorsCount: Float
  public var u_distortion: Float
  public var u_swirl: Float
  public var u_grainMixer: Float
  public var u_grainOverlay: Float

  public init(time: Float, params: MeshGradientParams) {
    let padded =
      params.colors
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

public struct StaticMeshGradientUniformsRaw {
  public var u_colors0: SIMD4<Float>
  public var u_colors1: SIMD4<Float>
  public var u_colors2: SIMD4<Float>
  public var u_colors3: SIMD4<Float>
  public var u_colors4: SIMD4<Float>
  public var u_colors5: SIMD4<Float>
  public var u_colors6: SIMD4<Float>
  public var u_colors7: SIMD4<Float>
  public var u_colors8: SIMD4<Float>
  public var u_colors9: SIMD4<Float>
  public var u_colorsCount: Float
  public var u_positions: Float
  public var u_waveX: Float
  public var u_waveXShift: Float
  public var u_waveY: Float
  public var u_waveYShift: Float
  public var u_mixing: Float
  public var u_grainMixer: Float
  public var u_grainOverlay: Float

  public init(params: StaticMeshGradientParams) {
    let padded =
      params.colors
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

public struct StaticRadialGradientUniformsRaw {
  public var u_colorBack: SIMD4<Float>
  public var u_colors0: SIMD4<Float>
  public var u_colors1: SIMD4<Float>
  public var u_colors2: SIMD4<Float>
  public var u_colors3: SIMD4<Float>
  public var u_colors4: SIMD4<Float>
  public var u_colors5: SIMD4<Float>
  public var u_colors6: SIMD4<Float>
  public var u_colors7: SIMD4<Float>
  public var u_colors8: SIMD4<Float>
  public var u_colors9: SIMD4<Float>
  public var u_colorsCount: Float
  public var u_radius: Float
  public var u_focalDistance: Float
  public var u_focalAngle: Float
  public var u_falloff: Float
  public var u_mixing: Float
  public var u_distortion: Float
  public var u_distortionShift: Float
  public var u_distortionFreq: Float
  public var u_grainMixer: Float
  public var u_grainOverlay: Float

  public init(params: StaticRadialGradientParams) {
    let padded =
      params.colors
      + Array(
        repeating: SIMD4<Float>(0, 0, 0, 0),
        count: max(0, StaticRadialGradientParams.maxColorCount - params.colors.count))
    self.u_colorBack = params.colorBack
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

public struct SwirlUniformsRaw {
  public var u_time: Float
  public var u_colorBack: SIMD4<Float>
  public var u_colors0: SIMD4<Float>
  public var u_colors1: SIMD4<Float>
  public var u_colors2: SIMD4<Float>
  public var u_colors3: SIMD4<Float>
  public var u_colors4: SIMD4<Float>
  public var u_colors5: SIMD4<Float>
  public var u_colors6: SIMD4<Float>
  public var u_colors7: SIMD4<Float>
  public var u_colors8: SIMD4<Float>
  public var u_colors9: SIMD4<Float>
  public var u_colorsCount: Float
  public var u_bandCount: Float
  public var u_twist: Float
  public var u_center: Float
  public var u_proportion: Float
  public var u_softness: Float
  public var u_noise: Float
  public var u_noiseFrequency: Float

  public init(time: Float, params: SwirlParams) {
    let padded =
      params.colors
      + Array(
        repeating: SIMD4<Float>(0, 0, 0, 0),
        count: max(0, SwirlParams.maxColorCount - params.colors.count))
    self.u_time = time
    self.u_colorBack = params.colorBack
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

public struct SpiralUniformsRaw {
  public var u_time: Float
  public var u_colorBack: SIMD4<Float>
  public var u_colorFront: SIMD4<Float>
  public var u_density: Float
  public var u_distortion: Float
  public var u_strokeWidth: Float
  public var u_strokeCap: Float
  public var u_strokeTaper: Float
  public var u_noise: Float
  public var u_noiseFrequency: Float
  public var u_softness: Float

  public init(time: Float, params: SpiralParams) {
    self.u_time = time
    self.u_colorBack = params.colorBack
    self.u_colorFront = params.colorFront
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

public struct DotGridUniformsRaw {
  public var u_colorBack: SIMD4<Float>
  public var u_colorFill: SIMD4<Float>
  public var u_colorStroke: SIMD4<Float>
  public var u_dotSize: Float
  public var u_gapX: Float
  public var u_gapY: Float
  public var u_strokeWidth: Float
  public var u_sizeRange: Float
  public var u_opacityRange: Float
  public var u_shape: Float

  public init(params: DotGridParams) {
    self.u_colorBack = params.colorBack
    self.u_colorFill = params.colorFill
    self.u_colorStroke = params.colorStroke
    self.u_dotSize = params.dotSize
    self.u_gapX = params.gapX
    self.u_gapY = params.gapY
    self.u_strokeWidth = params.strokeWidth
    self.u_sizeRange = params.sizeRange
    self.u_opacityRange = params.opacityRange
    self.u_shape = params.shape
  }
}

public struct SimplexNoiseUniformsRaw {
  public var u_time: Float
  public var u_colors0: SIMD4<Float>
  public var u_colors1: SIMD4<Float>
  public var u_colors2: SIMD4<Float>
  public var u_colors3: SIMD4<Float>
  public var u_colors4: SIMD4<Float>
  public var u_colors5: SIMD4<Float>
  public var u_colors6: SIMD4<Float>
  public var u_colors7: SIMD4<Float>
  public var u_colors8: SIMD4<Float>
  public var u_colors9: SIMD4<Float>
  public var u_colorsCount: Float
  public var u_stepsPerColor: Float
  public var u_softness: Float

  public init(time: Float, params: SimplexNoiseParams) {
    let padded =
      params.colors
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

public struct PerlinNoiseUniformsRaw {
  public var u_time: Float
  public var u_colorFront: SIMD4<Float>
  public var u_colorBack: SIMD4<Float>
  public var u_proportion: Float
  public var u_softness: Float
  public var u_octaveCount: Float
  public var u_persistence: Float
  public var u_lacunarity: Float

  public init(time: Float, params: PerlinNoiseParams) {
    self.u_time = time
    self.u_colorFront = params.colorFront
    self.u_colorBack = params.colorBack
    self.u_proportion = params.proportion
    self.u_softness = params.softness
    self.u_octaveCount = params.octaveCount
    self.u_persistence = params.persistence
    self.u_lacunarity = params.lacunarity
  }
}

public struct NeuroNoiseUniformsRaw {
  public var u_time: Float
  public var u_colorFront: SIMD4<Float>
  public var u_colorMid: SIMD4<Float>
  public var u_colorBack: SIMD4<Float>
  public var u_brightness: Float
  public var u_contrast: Float

  public init(time: Float, params: NeuroNoiseParams) {
    self.u_time = time
    self.u_colorFront = params.colorFront
    self.u_colorMid = params.colorMid
    self.u_colorBack = params.colorBack
    self.u_brightness = params.brightness
    self.u_contrast = params.contrast
  }
}

public struct WavesUniformsRaw {
  public var u_colorFront: SIMD4<Float>
  public var u_colorBack: SIMD4<Float>
  public var u_shape: Float
  public var u_frequency: Float
  public var u_amplitude: Float
  public var u_spacing: Float
  public var u_proportion: Float
  public var u_softness: Float

  public init(params: WavesParams) {
    self.u_colorFront = params.colorFront
    self.u_colorBack = params.colorBack
    self.u_shape = params.shape
    self.u_frequency = params.frequency
    self.u_amplitude = params.amplitude
    self.u_spacing = params.spacing
    self.u_proportion = params.proportion
    self.u_softness = params.softness
  }
}

public struct DitheringUniformsRaw {
  public var u_time: Float
  public var u_pxSize: Float
  public var u_colorBack: SIMD4<Float>
  public var u_colorFront: SIMD4<Float>
  public var u_shape: Float
  public var u_type: Float

  public init(time: Float, params: DitheringParams) {
    self.u_time = time
    self.u_pxSize = params.size
    self.u_colorBack = params.colorBack
    self.u_colorFront = params.colorFront
    self.u_shape = params.shape
    self.u_type = params.type
  }
}

public struct ColorPanelsUniformsRaw {
  public var u_time: Float
  public var u_scale: Float
  public var u_colors0: SIMD4<Float>
  public var u_colors1: SIMD4<Float>
  public var u_colors2: SIMD4<Float>
  public var u_colors3: SIMD4<Float>
  public var u_colors4: SIMD4<Float>
  public var u_colors5: SIMD4<Float>
  public var u_colors6: SIMD4<Float>
  public var u_colorsCount: Float
  public var u_colorBack: SIMD4<Float>
  public var u_density: Float
  public var u_angle1: Float
  public var u_angle2: Float
  public var u_length: Float
  public var u_edges: Float
  public var u_blur: Float
  public var u_fadeIn: Float
  public var u_fadeOut: Float
  public var u_gradient: Float

  public init(time: Float, scale: Float, params: ColorPanelsParams) {
    let padded =
      params.colors
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
    self.u_colorBack = params.colorBack
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

public struct DotOrbitUniformsRaw {
  public var u_time: Float
  public var u_colorBack: SIMD4<Float>
  public var u_colors0: SIMD4<Float>
  public var u_colors1: SIMD4<Float>
  public var u_colors2: SIMD4<Float>
  public var u_colors3: SIMD4<Float>
  public var u_colors4: SIMD4<Float>
  public var u_colors5: SIMD4<Float>
  public var u_colors6: SIMD4<Float>
  public var u_colors7: SIMD4<Float>
  public var u_colors8: SIMD4<Float>
  public var u_colors9: SIMD4<Float>
  public var u_colorsCount: Float
  public var u_stepsPerColor: Float
  public var u_size: Float
  public var u_sizeRange: Float
  public var u_spreading: Float

  public init(time: Float, params: DotOrbitParams) {
    let padded =
      params.colors
      + Array(
        repeating: SIMD4<Float>(0, 0, 0, 0),
        count: max(0, DotOrbitParams.maxColorCount - params.colors.count))
    self.u_time = time
    self.u_colorBack = params.colorBack
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

public struct GodRaysUniformsRaw {
  public var u_time: Float
  public var u_colorBack: SIMD4<Float>
  public var u_colorBloom: SIMD4<Float>
  public var u_colors0: SIMD4<Float>
  public var u_colors1: SIMD4<Float>
  public var u_colors2: SIMD4<Float>
  public var u_colors3: SIMD4<Float>
  public var u_colors4: SIMD4<Float>
  public var u_colorsCount: Float
  public var u_density: Float
  public var u_spotty: Float
  public var u_midSize: Float
  public var u_midIntensity: Float
  public var u_intensity: Float
  public var u_bloom: Float

  public init(time: Float, params: GodRaysParams) {
    let padded =
      params.colors
      + Array(
        repeating: SIMD4<Float>(0, 0, 0, 0),
        count: max(0, GodRaysParams.maxColorCount - params.colors.count))
    self.u_time = time
    self.u_colorBack = params.colorBack
    self.u_colorBloom = params.colorBloom
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

public struct GrainGradientUniformsRaw {
  public var u_time: Float
  public var u_colorBack: SIMD4<Float>
  public var u_colors0: SIMD4<Float>
  public var u_colors1: SIMD4<Float>
  public var u_colors2: SIMD4<Float>
  public var u_colors3: SIMD4<Float>
  public var u_colors4: SIMD4<Float>
  public var u_colors5: SIMD4<Float>
  public var u_colors6: SIMD4<Float>
  public var u_colorsCount: Float
  public var u_softness: Float
  public var u_intensity: Float
  public var u_noise: Float
  public var u_shape: Float

  public init(time: Float, params: GrainGradientParams) {
    let padded =
      params.colors
      + Array(
        repeating: SIMD4<Float>(0, 0, 0, 0),
        count: max(0, GrainGradientParams.maxColorCount - params.colors.count))
    self.u_time = time
    self.u_colorBack = params.colorBack
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
    self.u_shape = params.shape
  }
}

public struct MetaballsUniformsRaw {
  public var u_time: Float
  public var u_colorBack: SIMD4<Float>
  public var u_colors0: SIMD4<Float>
  public var u_colors1: SIMD4<Float>
  public var u_colors2: SIMD4<Float>
  public var u_colors3: SIMD4<Float>
  public var u_colors4: SIMD4<Float>
  public var u_colors5: SIMD4<Float>
  public var u_colors6: SIMD4<Float>
  public var u_colors7: SIMD4<Float>
  public var u_colorsCount: Float
  public var u_size: Float
  public var u_sizeRange: Float
  public var u_count: Float

  public init(time: Float, params: MetaballsParams) {
    let padded =
      params.colors
      + Array(
        repeating: SIMD4<Float>(0, 0, 0, 0),
        count: max(0, MetaballsParams.maxColorCount - params.colors.count))
    self.u_time = time
    self.u_colorBack = params.colorBack
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

public struct WarpUniformsRaw {
  public var u_time: Float
  public var u_scale: Float
  public var u_colors0: SIMD4<Float>
  public var u_colors1: SIMD4<Float>
  public var u_colors2: SIMD4<Float>
  public var u_colors3: SIMD4<Float>
  public var u_colors4: SIMD4<Float>
  public var u_colors5: SIMD4<Float>
  public var u_colors6: SIMD4<Float>
  public var u_colors7: SIMD4<Float>
  public var u_colors8: SIMD4<Float>
  public var u_colors9: SIMD4<Float>
  public var u_colorsCount: Float
  public var u_proportion: Float
  public var u_softness: Float
  public var u_shape: Float
  public var u_shapeScale: Float
  public var u_distortion: Float
  public var u_swirl: Float
  public var u_swirlIterations: Float

  public init(time: Float, scale: Float, params: WarpParams) {
    let padded =
      params.colors
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
    self.u_shape = params.shape
    self.u_shapeScale = params.shapeScale
    self.u_distortion = params.distortion
    self.u_swirl = params.swirl
    self.u_swirlIterations = params.swirlIterations
  }
}

public struct VoronoiUniformsRaw {
  public var u_time: Float
  public var u_scale: Float
  public var u_colors0: SIMD4<Float>
  public var u_colors1: SIMD4<Float>
  public var u_colors2: SIMD4<Float>
  public var u_colors3: SIMD4<Float>
  public var u_colors4: SIMD4<Float>
  public var u_colorsCount: Float
  public var u_stepsPerColor: Float
  public var u_colorGlow: SIMD4<Float>
  public var u_colorGap: SIMD4<Float>
  public var u_distortion: Float
  public var u_gap: Float
  public var u_glow: Float

  public init(time: Float, scale: Float, params: VoronoiParams) {
    let padded =
      params.colors
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
    self.u_colorGlow = params.colorGlow
    self.u_colorGap = params.colorGap
    self.u_distortion = params.distortion
    self.u_gap = params.gap
    self.u_glow = params.glow
  }
}

public struct PulsingBorderUniformsRaw {
  public var u_time: Float
  public var u_colorBack: SIMD4<Float>
  public var u_colors0: SIMD4<Float>
  public var u_colors1: SIMD4<Float>
  public var u_colors2: SIMD4<Float>
  public var u_colors3: SIMD4<Float>
  public var u_colors4: SIMD4<Float>
  public var u_colorsCount: Float
  public var u_roundness: Float
  public var u_thickness: Float
  public var u_marginLeft: Float
  public var u_marginRight: Float
  public var u_marginTop: Float
  public var u_marginBottom: Float
  public var u_aspectRatio: Float
  public var u_softness: Float
  public var u_intensity: Float
  public var u_bloom: Float
  public var u_spots: Float
  public var u_spotSize: Float
  public var u_pulse: Float
  public var u_smoke: Float
  public var u_smokeSize: Float

  public init(time: Float, params: PulsingBorderParams) {
    let padded =
      params.colors
      + Array(
        repeating: SIMD4<Float>(0, 0, 0, 0),
        count: max(0, PulsingBorderParams.maxColorCount - params.colors.count))
    self.u_time = time
    self.u_colorBack = params.colorBack
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
    self.u_aspectRatio = params.aspectRatio
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

public struct SmokeRingUniformsRaw {
  public var u_time: Float
  public var u_colorBack: SIMD4<Float>
  public var u_colors0: SIMD4<Float>
  public var u_colors1: SIMD4<Float>
  public var u_colors2: SIMD4<Float>
  public var u_colors3: SIMD4<Float>
  public var u_colors4: SIMD4<Float>
  public var u_colors5: SIMD4<Float>
  public var u_colors6: SIMD4<Float>
  public var u_colors7: SIMD4<Float>
  public var u_colors8: SIMD4<Float>
  public var u_colors9: SIMD4<Float>
  public var u_colorsCount: Float
  public var u_thickness: Float
  public var u_radius: Float
  public var u_innerShape: Float
  public var u_noiseScale: Float
  public var u_noiseIterations: Float

  public init(time: Float, params: SmokeRingParams) {
    let padded =
      params.colors
      + Array(
        repeating: SIMD4<Float>(0, 0, 0, 0),
        count: max(0, SmokeRingParams.maxColorCount - params.colors.count))
    self.u_time = time
    self.u_colorBack = params.colorBack
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

public struct ImageDitheringUniformsRaw {
  public var u_colorFront: SIMD4<Float>
  public var u_colorBack: SIMD4<Float>
  public var u_colorHighlight: SIMD4<Float>
  public var u_type: Float
  public var u_pxSize: Float
  public var u_originalColors: Float
  public var u_inverted: Float
  public var u_colorSteps: Float

  public init(params: ImageDitheringParams) {
    self.u_colorFront = params.colorFront
    self.u_colorBack = params.colorBack
    self.u_colorHighlight = params.colorHighlight
    self.u_type = params.type
    self.u_pxSize = params.size
    self.u_originalColors = params.originalColors
    self.u_inverted = params.inverted
    self.u_colorSteps = params.colorSteps
  }
}

public struct HalftoneDotsUniformsRaw {
  public var u_time: Float
  public var u_colorFront: SIMD4<Float>
  public var u_colorBack: SIMD4<Float>
  public var u_radius: Float
  public var u_contrast: Float
  public var u_size: Float
  public var u_grainMixer: Float
  public var u_grainOverlay: Float
  public var u_grainSize: Float
  public var u_grid: Float
  public var u_originalColors: Float
  public var u_inverted: Float
  public var u_type: Float

  public init(time: Float, params: HalftoneDotsParams) {
    self.u_time = time
    self.u_colorFront = params.colorFront
    self.u_colorBack = params.colorBack
    self.u_radius = params.radius
    self.u_contrast = params.contrast
    self.u_size = params.size
    self.u_grainMixer = params.grainMixer
    self.u_grainOverlay = params.grainOverlay
    self.u_grainSize = params.grainSize
    self.u_grid = params.grid
    self.u_originalColors = params.originalColors
    self.u_inverted = params.inverted
    self.u_type = params.type
  }
}

public struct HalftoneCmykUniformsRaw {
  public var u_colorBack: SIMD4<Float>
  public var u_colorC: SIMD4<Float>
  public var u_colorM: SIMD4<Float>
  public var u_colorY: SIMD4<Float>
  public var u_colorK: SIMD4<Float>
  public var u_size: Float
  public var u_minDot: Float
  public var u_contrast: Float
  public var u_grainSize: Float
  public var u_grainMixer: Float
  public var u_grainOverlay: Float
  public var u_gridNoise: Float
  public var u_softness: Float
  public var u_floodC: Float
  public var u_floodM: Float
  public var u_floodY: Float
  public var u_floodK: Float
  public var u_gainC: Float
  public var u_gainM: Float
  public var u_gainY: Float
  public var u_gainK: Float
  public var u_type: Float

  public init(params: HalftoneCmykParams) {
    self.u_colorBack = params.colorBack
    self.u_colorC = params.colorC
    self.u_colorM = params.colorM
    self.u_colorY = params.colorY
    self.u_colorK = params.colorK
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
    self.u_type = params.type
  }
}

public struct HeatmapUniformsRaw {
  public var u_time: Float
  public var u_colorBack: SIMD4<Float>
  public var u_colors0: SIMD4<Float>
  public var u_colors1: SIMD4<Float>
  public var u_colors2: SIMD4<Float>
  public var u_colors3: SIMD4<Float>
  public var u_colors4: SIMD4<Float>
  public var u_colors5: SIMD4<Float>
  public var u_colors6: SIMD4<Float>
  public var u_colors7: SIMD4<Float>
  public var u_colors8: SIMD4<Float>
  public var u_colors9: SIMD4<Float>
  public var u_colorsCount: Float
  public var u_contour: Float
  public var u_angle: Float
  public var u_noise: Float
  public var u_innerGlow: Float
  public var u_outerGlow: Float

  public init(time: Float, params: HeatmapParams) {
    let padded =
      params.colors
      + Array(
        repeating: SIMD4<Float>(0, 0, 0, 0),
        count: max(0, HeatmapParams.maxColorCount - params.colors.count))
    self.u_time = time
    self.u_colorBack = params.colorBack
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

public struct LiquidMetalUniformsRaw {
  public var u_time: Float
  public var u_colorBack: SIMD4<Float>
  public var u_colorTint: SIMD4<Float>
  public var u_repetition: Float
  public var u_softness: Float
  public var u_shiftRed: Float
  public var u_shiftBlue: Float
  public var u_distortion: Float
  public var u_contour: Float
  public var u_angle: Float
  public var u_shape: Float
  public var u_isImage: Float

  public init(time: Float, params: LiquidMetalParams) {
    self.u_time = time
    self.u_colorBack = params.colorBack
    self.u_colorTint = params.colorTint
    self.u_repetition = params.repetition
    self.u_softness = params.softness
    self.u_shiftRed = params.shiftRed
    self.u_shiftBlue = params.shiftBlue
    self.u_distortion = params.distortion
    self.u_contour = params.contour
    self.u_angle = params.angle
    self.u_shape = params.shape
    self.u_isImage = params.isImage
  }
}

public struct PaperTextureUniformsRaw {
  public var u_colorFront: SIMD4<Float>
  public var u_colorBack: SIMD4<Float>
  public var u_contrast: Float
  public var u_roughness: Float
  public var u_fiber: Float
  public var u_fiberSize: Float
  public var u_crumples: Float
  public var u_crumpleSize: Float
  public var u_folds: Float
  public var u_foldCount: Float
  public var u_drops: Float
  public var u_seed: Float
  public var u_fade: Float

  public init(params: PaperTextureParams) {
    self.u_colorFront = params.colorFront
    self.u_colorBack = params.colorBack
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

public struct WaterUniformsRaw {
  public var u_time: Float
  public var u_colorBack: SIMD4<Float>
  public var u_colorHighlight: SIMD4<Float>
  public var u_highlights: Float
  public var u_layering: Float
  public var u_edges: Float
  public var u_caustic: Float
  public var u_waves: Float
  public var u_size: Float

  public init(time: Float, params: WaterParams) {
    self.u_time = time
    self.u_colorBack = params.colorBack
    self.u_colorHighlight = params.colorHighlight
    self.u_highlights = params.highlights
    self.u_layering = params.layering
    self.u_edges = params.edges
    self.u_caustic = params.caustic
    self.u_waves = params.waves
    self.u_size = params.size
  }
}

public struct FlutedGlassUniformsRaw {
  public var u_resolution: SIMD2<Float>
  public var u_pixelRatio: Float
  public var u_rotation: Float
  public var u_colorBack: SIMD4<Float>
  public var u_colorShadow: SIMD4<Float>
  public var u_colorHighlight: SIMD4<Float>
  public var u_shadows: Float
  public var u_size: Float
  public var u_angle: Float
  public var u_stretch: Float
  public var u_shape: Float
  public var u_distortion: Float
  public var u_highlights: Float
  public var u_distortionShape: Float
  public var u_shift: Float
  public var u_blur: Float
  public var u_edges: Float
  public var u_marginLeft: Float
  public var u_marginRight: Float
  public var u_marginTop: Float
  public var u_marginBottom: Float
  public var u_grainMixer: Float
  public var u_grainOverlay: Float

  public init(
    resolution: SIMD2<Float>, pixelRatio: Float, rotation: Float, params: FlutedGlassParams
  ) {
    self.u_resolution = resolution
    self.u_pixelRatio = pixelRatio
    self.u_rotation = rotation
    self.u_colorBack = params.colorBack
    self.u_colorShadow = params.colorShadow
    self.u_colorHighlight = params.colorHighlight
    self.u_shadows = params.shadows
    self.u_size = params.size
    self.u_angle = params.angle
    self.u_stretch = params.stretch
    self.u_shape = params.shape
    self.u_distortion = params.distortion
    self.u_highlights = params.highlights
    self.u_distortionShape = params.distortionShape
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

public struct GemSmokeUniformsRaw {
  public var u_time: Float
  public var u_colors0: SIMD4<Float>
  public var u_colors1: SIMD4<Float>
  public var u_colors2: SIMD4<Float>
  public var u_colors3: SIMD4<Float>
  public var u_colors4: SIMD4<Float>
  public var u_colors5: SIMD4<Float>
  public var u_colorsCount: Float
  public var u_colorBack: SIMD4<Float>
  public var u_colorInner: SIMD4<Float>
  public var u_innerDistortion: Float
  public var u_outerDistortion: Float
  public var u_outerGlow: Float
  public var u_innerGlow: Float
  public var u_offset: Float
  public var u_angle: Float
  public var u_size: Float
  public var u_shape: Float
  public var u_isImage: Float

  public init(time: Float, params: GemSmokeParams) {
    let padded =
      params.colors
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
    self.u_colorBack = params.colorBack
    self.u_colorInner = params.colorInner
    self.u_innerDistortion = params.innerDistortion
    self.u_outerDistortion = params.outerDistortion
    self.u_outerGlow = params.outerGlow
    self.u_innerGlow = params.innerGlow
    self.u_offset = params.offset
    self.u_angle = params.angle
    self.u_size = params.size
    self.u_shape = params.shape
    self.u_isImage = params.isImage
  }
}
