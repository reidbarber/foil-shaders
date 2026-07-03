import CoreGraphics
import Foundation
import simd

public struct ShaderColor: Equatable, Sendable, ExpressibleByStringLiteral {
  public var red: Float
  public var green: Float
  public var blue: Float
  public var alpha: Float

  public init(red: Float, green: Float, blue: Float, alpha: Float = 1) {
    self.red = red
    self.green = green
    self.blue = blue
    self.alpha = alpha
  }

  public init(_ rgba: SIMD4<Float>) {
    self.init(red: rgba.x, green: rgba.y, blue: rgba.z, alpha: rgba.w)
  }

  public init(stringLiteral value: String) {
    self = ShaderColor(value) ?? .black
  }

  public init?(_ value: String) {
    let text = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    if let color = Self.parseHex(text) ?? Self.parseRGB(text) ?? Self.parseHSL(text) {
      self = color
    } else {
      return nil
    }
  }

  public var rgba: SIMD4<Float> {
    SIMD4(red, green, blue, alpha)
  }

  public var hexString: String {
    let r = Int((red.clamped01 * 255).rounded())
    let g = Int((green.clamped01 * 255).rounded())
    let b = Int((blue.clamped01 * 255).rounded())
    let a = Int((alpha.clamped01 * 255).rounded())
    if a == 255 {
      return String(format: "#%02x%02x%02x", r, g, b)
    }
    return String(format: "#%02x%02x%02x%02x", r, g, b, a)
  }

  public static let clear = ShaderColor(red: 0, green: 0, blue: 0, alpha: 0)
  public static let black = ShaderColor(red: 0, green: 0, blue: 0, alpha: 1)
  public static let white = ShaderColor(red: 1, green: 1, blue: 1, alpha: 1)

  private static func parseHex(_ text: String) -> ShaderColor? {
    guard text.hasPrefix("#") else { return nil }
    let hex = String(text.dropFirst())
    let expanded: String
    switch hex.count {
    case 3:
      expanded = hex.map { "\($0)\($0)" }.joined()
    case 4:
      expanded = hex.map { "\($0)\($0)" }.joined()
    case 6, 8:
      expanded = hex
    default:
      return nil
    }

    guard let value = UInt32(expanded, radix: 16) else { return nil }
    if expanded.count == 6 {
      return ShaderColor(
        red: Float((value >> 16) & 0xff) / 255,
        green: Float((value >> 8) & 0xff) / 255,
        blue: Float(value & 0xff) / 255
      )
    }
    return ShaderColor(
      red: Float((value >> 24) & 0xff) / 255,
      green: Float((value >> 16) & 0xff) / 255,
      blue: Float((value >> 8) & 0xff) / 255,
      alpha: Float(value & 0xff) / 255
    )
  }

  private static func parseRGB(_ text: String) -> ShaderColor? {
    guard text.hasPrefix("rgb(") || text.hasPrefix("rgba(") else { return nil }
    let values = cssFunctionValues(text)
    guard values.count >= 3 else { return nil }
    let r = component(values[0])
    let g = component(values[1])
    let b = component(values[2])
    let a = values.count >= 4 ? alphaComponent(values[3]) : 1
    return ShaderColor(red: r, green: g, blue: b, alpha: a)
  }

  private static func parseHSL(_ text: String) -> ShaderColor? {
    guard text.hasPrefix("hsl(") || text.hasPrefix("hsla(") else { return nil }
    let values = cssFunctionValues(text)
    guard values.count >= 3 else { return nil }
    let h = (Float(values[0].replacingOccurrences(of: "deg", with: "")) ?? 0) / 360
    let s = percent(values[1])
    let l = percent(values[2])
    let a = values.count >= 4 ? alphaComponent(values[3]) : 1

    if s == 0 {
      return ShaderColor(red: l, green: l, blue: l, alpha: a)
    }

    let q = l < 0.5 ? l * (1 + s) : l + s - l * s
    let p = 2 * l - q
    return ShaderColor(
      red: hueToRGB(p: p, q: q, t: h + 1 / 3),
      green: hueToRGB(p: p, q: q, t: h),
      blue: hueToRGB(p: p, q: q, t: h - 1 / 3),
      alpha: a
    )
  }

  private static func cssFunctionValues(_ text: String) -> [String] {
    guard let open = text.firstIndex(of: "("), let close = text.lastIndex(of: ")"), open < close
    else {
      return []
    }
    return text[text.index(after: open)..<close]
      .replacingOccurrences(of: "/", with: " ")
      .split { $0 == "," || $0 == " " || $0 == "\t" || $0 == "\n" }
      .map(String.init)
  }

  private static func component(_ value: String) -> Float {
    if value.hasSuffix("%") {
      return percent(value)
    }
    return ((Float(value) ?? 0) / 255).clamped01
  }

  private static func percent(_ value: String) -> Float {
    let stripped = value.replacingOccurrences(of: "%", with: "")
    return ((Float(stripped) ?? 0) / 100).clamped01
  }

  private static func alphaComponent(_ value: String) -> Float {
    value.hasSuffix("%") ? percent(value) : (Float(value) ?? 1).clamped01
  }

  private static func hueToRGB(p: Float, q: Float, t raw: Float) -> Float {
    var t = raw
    if t < 0 { t += 1 }
    if t > 1 { t -= 1 }
    if t < 1 / 6 { return p + (q - p) * 6 * t }
    if t < 1 / 2 { return q }
    if t < 2 / 3 { return p + (q - p) * (2 / 3 - t) * 6 }
    return p
  }
}

public enum ShaderImage: @unchecked Sendable {
  case cgImage(CGImage)
  case url(URL)
  case bundleResource(name: String, extension: String, bundle: Bundle)
  case remoteURL(URL)

  public static func bundledResource(
    name: String, extension fileExtension: String, bundle: Bundle = .main
  ) -> ShaderImage {
    .bundleResource(name: name, extension: fileExtension, bundle: bundle)
  }
}

extension ShaderImage: Equatable {
  public static func == (lhs: ShaderImage, rhs: ShaderImage) -> Bool {
    switch (lhs, rhs) {
    case (.cgImage(let a), .cgImage(let b)):
      return a === b
    case (.url(let a), .url(let b)):
      return a == b
    case (.remoteURL(let a), .remoteURL(let b)):
      return a == b
    case (.bundleResource(let n1, let e1, let b1), .bundleResource(let n2, let e2, let b2)):
      return n1 == n2 && e1 == e2 && b1 == b2
    default:
      return false
    }
  }
}

public struct ShaderRenderOptions: Equatable, Sendable {
  public static let defaultMaxPixelCount = 1920 * 1080 * 4

  public var minPixelRatio: Float
  public var maxPixelCount: Int
  public var width: CGFloat?
  public var height: CGFloat?

  public static let `default` = ShaderRenderOptions()

  public init(
    minPixelRatio: Float = 2,
    maxPixelCount: Int = ShaderRenderOptions.defaultMaxPixelCount,
    width: CGFloat? = nil,
    height: CGFloat? = nil
  ) {
    self.minPixelRatio = minPixelRatio
    self.maxPixelCount = maxPixelCount
    self.width = width
    self.height = height
  }
}

public struct ShaderPreset<Params>: @unchecked Sendable {
  public var name: String
  public var params: Params
  public var sizing: ShaderSizingParams
  public var motion: ShaderMotionParams
  public var renderOptions: ShaderRenderOptions
  public var image: ShaderImage?

  public init(
    name: String,
    params: Params,
    sizing: ShaderSizingParams = .defaultPatternSizing,
    motion: ShaderMotionParams = ShaderMotionParams(),
    renderOptions: ShaderRenderOptions = .default,
    image: ShaderImage? = nil
  ) {
    self.name = name
    self.params = params
    self.sizing = sizing
    self.motion = motion
    self.renderOptions = renderOptions
    self.image = image
  }
}

public enum DotGridShape: Float, CaseIterable, Sendable {
  case circle = 0
  case diamond = 1
  case square = 2
  case triangle = 3
}

public enum DitheringShape: Float, CaseIterable, Sendable {
  case simplex = 1
  case warp = 2
  case dots = 3
  case wave = 4
  case ripple = 5
  case swirl = 6
  case sphere = 7
}

public enum DitheringType: Float, CaseIterable, Sendable {
  case random = 1
  case twoByTwo = 2
  case fourByFour = 3
  case eightByEight = 4
}

public enum WarpPattern: Float, CaseIterable, Sendable {
  case checks = 0
  case stripes = 1
  case edge = 2
}

public enum GrainGradientShape: Float, CaseIterable, Sendable {
  case wave = 1
  case dots = 2
  case truchet = 3
  case corners = 4
  case ripple = 5
  case blob = 6
  case sphere = 7
}

public enum PulsingBorderAspectRatio: Float, CaseIterable, Sendable {
  case auto = 0
  case square = 1
}

public enum HalftoneDotsType: Float, CaseIterable, Sendable {
  case classic = 0
  case gooey = 1
  case holes = 2
  case soft = 3
}

public enum HalftoneDotsGrid: Float, CaseIterable, Sendable {
  case square = 0
  case hex = 1
}

public enum HalftoneCmykType: Float, CaseIterable, Sendable {
  case dots = 0
  case ink = 1
  case sharp = 2
}

public enum LiquidMetalShape: Float, CaseIterable, Sendable {
  case none = 0
  case circle = 1
  case daisy = 2
  case diamond = 3
  case metaballs = 4
}

public enum GlassGridShape: Float, CaseIterable, Sendable {
  case lines = 1
  case linesIrregular = 2
  case wave = 3
  case zigzag = 4
  case pattern = 5
}

public enum GlassDistortionShape: Float, CaseIterable, Sendable {
  case prism = 1
  case lens = 2
  case contour = 3
  case cascade = 4
  case flat = 5
}

public enum GemSmokeShape: Float, CaseIterable, Sendable {
  case none = 0
  case circle = 1
  case daisy = 2
  case diamond = 3
  case metaballs = 4
}

public enum ShaderParameters {
  case meshGradient(MeshGradientParams)
  case staticMeshGradient(StaticMeshGradientParams)
  case staticRadialGradient(StaticRadialGradientParams)
  case swirl(SwirlParams)
  case spiral(SpiralParams)
  case dotGrid(DotGridParams)
  case simplexNoise(SimplexNoiseParams)
  case perlinNoise(PerlinNoiseParams)
  case neuroNoise(NeuroNoiseParams)
  case waves(WavesParams)
  case dithering(DitheringParams)
  case colorPanels(ColorPanelsParams)
  case dotOrbit(DotOrbitParams)
  case godRays(GodRaysParams)
  case grainGradient(GrainGradientParams)
  case metaballs(MetaballsParams)
  case warp(WarpParams)
  case voronoi(VoronoiParams)
  case pulsingBorder(PulsingBorderParams)
  case smokeRing(SmokeRingParams)
  case imageDithering(ImageDitheringParams)
  case halftoneDots(HalftoneDotsParams)
  case halftoneCmyk(HalftoneCmykParams)
  case heatmap(HeatmapParams)
  case liquidMetal(LiquidMetalParams)
  case paperTexture(PaperTextureParams)
  case water(WaterParams)
  case flutedGlass(FlutedGlassParams)
  case gemSmoke(GemSmokeParams)
}

public struct ShaderConfiguration {
  public var kind: FoilShadersRenderer.ShaderKind
  public var parameters: ShaderParameters
  public var sizing: ShaderSizingParams
  public var motion: ShaderMotionParams
  public var renderOptions: ShaderRenderOptions
  public var image: ShaderImage?

  public init(
    kind: FoilShadersRenderer.ShaderKind,
    parameters: ShaderParameters,
    sizing: ShaderSizingParams = .defaultPatternSizing,
    motion: ShaderMotionParams = ShaderMotionParams(),
    renderOptions: ShaderRenderOptions = .default,
    image: ShaderImage? = nil
  ) {
    self.kind = kind
    self.parameters = parameters
    self.sizing = sizing
    self.motion = motion
    self.renderOptions = renderOptions
    self.image = image
  }
}

extension ShaderSizingParams {
  public static let defaultObjectSizing = ShaderSizingParams(fit: .contain)
  public static let defaultPatternSizing = ShaderSizingParams(fit: .none)
}

extension Float {
  fileprivate var clamped01: Float {
    min(1, max(0, self))
  }
}
