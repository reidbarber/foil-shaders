import CoreGraphics
import CryptoKit
import Foundation
import simd

/// A normalized RGBA color passed to Metal shader uniforms.
///
/// Component values use the `0...1` range. String literals and string parsing accept
/// CSS-style hex, `rgb()`/`rgba()`, and `hsl()`/`hsla()` values and normalize them to
/// the same component range.
public struct ShaderColor: Equatable, Sendable, Codable, ExpressibleByStringLiteral {
  /// Red channel in the `0...1` range.
  public var red: Float
  /// Green channel in the `0...1` range.
  public var green: Float
  /// Blue channel in the `0...1` range.
  public var blue: Float
  /// Alpha channel in the `0...1` range, where `0` is transparent and `1` is opaque.
  public var alpha: Float

  /// Creates a color from normalized RGBA components.
  ///
  /// - Parameters:
  ///   - red: Red channel in the `0...1` range.
  ///   - green: Green channel in the `0...1` range.
  ///   - blue: Blue channel in the `0...1` range.
  ///   - alpha: Alpha channel in the `0...1` range.
  public init(red: Float, green: Float, blue: Float, alpha: Float = 1) {
    self.red = red
    self.green = green
    self.blue = blue
    self.alpha = alpha
  }

  /// Creates a color from a normalized RGBA vector.
  ///
  /// - Parameter rgba: Components in red, green, blue, alpha order, each using `0...1`.
  public init(_ rgba: SIMD4<Float>) {
    self.init(red: rgba.x, green: rgba.y, blue: rgba.z, alpha: rgba.w)
  }

  /// Creates a color from a CSS-style color string literal.
  ///
  /// Invalid strings fall back to ``black``.
  public init(stringLiteral value: String) {
    self = ShaderColor(value) ?? .black
  }

  /// Creates a color from a CSS-style color string.
  ///
  /// Supported formats include `#rgb`, `#rgba`, `#rrggbb`, `#rrggbbaa`, `rgb()`,
  /// `rgba()`, `hsl()`, and `hsla()`.
  public init?(_ value: String) {
    let text = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    if let color = Self.parseHex(text) ?? Self.parseRGB(text) ?? Self.parseHSL(text) {
      self = color
    } else {
      return nil
    }
  }

  /// The normalized RGBA components as a SIMD vector.
  public var rgba: SIMD4<Float> {
    SIMD4(red, green, blue, alpha)
  }

  /// A lowercased hex string representation in `#rrggbb` or `#rrggbbaa` form.
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

  /// Fully transparent black.
  public static let clear = ShaderColor(red: 0, green: 0, blue: 0, alpha: 0)
  /// Opaque black.
  public static let black = ShaderColor(red: 0, green: 0, blue: 0, alpha: 1)
  /// Opaque white.
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

/// A source image descriptor for shaders that sample image input.
///
/// `CGImage` values compare by a deterministic pixel fingerprint when possible,
/// with a per-value fallback identity only if fingerprinting fails.
public struct ShaderImage: Equatable, @unchecked Sendable, Codable {
  enum Storage: Equatable {
    case cgImage(CGImage, ImageFingerprint)
    case url(URL)
    case bundledResource(BundleResource)

    static func == (lhs: Storage, rhs: Storage) -> Bool {
      switch (lhs, rhs) {
      case (.cgImage(_, let a), .cgImage(_, let b)):
        return a == b
      case (.url(let a), .url(let b)):
        return a == b
      case (.bundledResource(let a), .bundledResource(let b)):
        return a == b
      default:
        return false
      }
    }
  }

  struct BundleResource: Equatable {
    var name: String
    var fileExtension: String
    var bundle: Bundle

    static func == (lhs: BundleResource, rhs: BundleResource) -> Bool {
      lhs.name == rhs.name
        && lhs.fileExtension == rhs.fileExtension
        && lhs.bundle.bundleIdentifier == rhs.bundle.bundleIdentifier
        && lhs.bundle.bundleURL.standardizedFileURL == rhs.bundle.bundleURL.standardizedFileURL
    }
  }

  struct ImageFingerprint: Equatable {
    var width: Int
    var height: Int
    var digest: [UInt8]?
    var fallbackID: UUID?
  }

  let storage: Storage

  public static func cgImage(_ image: CGImage) -> ShaderImage {
    ShaderImage(
      storage: .cgImage(
        image,
        Self.makeFingerprint(for: image)
          ?? ImageFingerprint(
            width: image.width,
            height: image.height,
            digest: nil,
            fallbackID: UUID())
      )
    )
  }

  public static func url(_ url: URL) -> ShaderImage {
    ShaderImage(storage: .url(url))
  }

  public static func bundledResource(
    name: String, extension fileExtension: String, bundle: Bundle = .main
  ) -> ShaderImage {
    ShaderImage(
      storage: .bundledResource(
        BundleResource(name: name, fileExtension: fileExtension, bundle: bundle)))
  }

  private init(storage: Storage) {
    self.storage = storage
  }

  private static func makeFingerprint(for image: CGImage) -> ImageFingerprint? {
    let width = image.width
    let height = image.height
    guard width > 0, height > 0 else { return nil }

    let pixelProduct = width.multipliedReportingOverflow(by: height)
    guard !pixelProduct.overflow, pixelProduct.partialValue <= Int.max / 4 else { return nil }
    let pixelCount = pixelProduct.partialValue
    var rgba = [UInt8](repeating: 0, count: pixelCount * 4)
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
      .union(.byteOrder32Big)
    guard
      let context = CGContext(
        data: &rgba,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: width * 4,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: bitmapInfo.rawValue
      )
    else {
      return nil
    }

    context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))

    var hasher = SHA256()
    withUnsafeBytes(of: width.bigEndian) { hasher.update(bufferPointer: $0) }
    withUnsafeBytes(of: height.bigEndian) { hasher.update(bufferPointer: $0) }
    hasher.update(data: Data(rgba))
    return ImageFingerprint(
      width: width,
      height: height,
      digest: Array(hasher.finalize()),
      fallbackID: nil
    )
  }

  private enum CodingKeys: String, CodingKey {
    case type
    case url
    case name
    case fileExtension
    case bundleIdentifier
    case bundleURL
  }

  private enum ImageType: String, Codable {
    case url
    case bundleResource
    case remoteURL
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let type = try container.decode(ImageType.self, forKey: .type)
    switch type {
    case .url, .remoteURL:
      self = .url(try container.decode(URL.self, forKey: .url))
    case .bundleResource:
      let bundleIdentifier = try container.decodeIfPresent(String.self, forKey: .bundleIdentifier)
      let bundleURL = try container.decodeIfPresent(URL.self, forKey: .bundleURL)
      let bundle =
        bundleIdentifier.flatMap(Bundle.init(identifier:))
        ?? bundleURL.flatMap(Bundle.init(url:))
        ?? .main
      self = .bundledResource(
        name: try container.decode(String.self, forKey: .name),
        extension: try container.decode(String.self, forKey: .fileExtension),
        bundle: bundle
      )
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch storage {
    case .cgImage:
      throw EncodingError.invalidValue(
        self,
        EncodingError.Context(
          codingPath: encoder.codingPath,
          debugDescription:
            "ShaderImage.cgImage is a runtime image handle and cannot be encoded. Use a URL or bundled resource image descriptor for Codable configurations."
        )
      )
    case .url(let url):
      try container.encode(ImageType.url, forKey: .type)
      try container.encode(url, forKey: .url)
    case .bundledResource(let resource):
      try container.encode(ImageType.bundleResource, forKey: .type)
      try container.encode(resource.name, forKey: .name)
      try container.encode(resource.fileExtension, forKey: .fileExtension)
      try container.encodeIfPresent(resource.bundle.bundleIdentifier, forKey: .bundleIdentifier)
      try container.encode(resource.bundle.bundleURL, forKey: .bundleURL)
    }
  }
}

/// Resolution controls for the Metal backing texture used by a shader view.
///
/// These options mirror Paper Shaders' render-size controls. Use them to keep
/// output sharp while preventing extremely large drawable textures.
public struct ShaderRenderOptions: Equatable, Sendable, Codable {
  /// Default maximum rendered pixel count, equal to four 1080p frames.
  public static let defaultMaxPixelCount = 1920 * 1080 * 4

  /// Minimum backing-store scale relative to the view size. Typical values are `1...3`.
  public var minPixelRatio: Float
  /// Maximum rendered pixel count before the renderer lowers the effective pixel ratio.
  public var maxPixelCount: Int
  /// Optional fixed render width in points or pixels, depending on the caller's sizing context.
  public var width: CGFloat?
  /// Optional fixed render height in points or pixels, depending on the caller's sizing context.
  public var height: CGFloat?

  /// Default render options: `minPixelRatio` `2` and ``defaultMaxPixelCount``.
  public static let `default` = ShaderRenderOptions()

  /// Creates render resolution controls.
  ///
  /// - Parameters:
  ///   - minPixelRatio: Minimum backing-store scale relative to the view size.
  ///     Values in `1...3` are typical; the default is `2`.
  ///   - maxPixelCount: Maximum rendered pixel count before the renderer lowers
  ///     the effective pixel ratio.
  ///   - width: Optional fixed render width in points or pixels, depending on
  ///     the caller's sizing context.
  ///   - height: Optional fixed render height in points or pixels, depending on
  ///     the caller's sizing context.
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

public struct ShaderPreset<Params: Equatable & Sendable>: Equatable, Sendable {
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

extension ShaderPreset: Codable where Params: Codable {}

public enum DotGridShape: Float, CaseIterable, Equatable, Sendable, Codable {
  case circle = 0
  case diamond = 1
  case square = 2
  case triangle = 3
}

public enum DitheringShape: Float, CaseIterable, Equatable, Sendable, Codable {
  case simplex = 1
  case warp = 2
  case dots = 3
  case wave = 4
  case ripple = 5
  case swirl = 6
  case sphere = 7
}

public enum DitheringType: Float, CaseIterable, Equatable, Sendable, Codable {
  case random = 1
  case twoByTwo = 2
  case fourByFour = 3
  case eightByEight = 4
}

public enum WarpPattern: Float, CaseIterable, Equatable, Sendable, Codable {
  case checks = 0
  case stripes = 1
  case edge = 2
}

public enum GrainGradientShape: Float, CaseIterable, Equatable, Sendable, Codable {
  case wave = 1
  case dots = 2
  case truchet = 3
  case corners = 4
  case ripple = 5
  case blob = 6
  case sphere = 7
}

public enum PulsingBorderAspectRatio: Float, CaseIterable, Equatable, Sendable, Codable {
  case auto = 0
  case square = 1
}

public enum HalftoneDotsType: Float, CaseIterable, Equatable, Sendable, Codable {
  case classic = 0
  case gooey = 1
  case holes = 2
  case soft = 3
}

public enum HalftoneDotsGrid: Float, CaseIterable, Equatable, Sendable, Codable {
  case square = 0
  case hex = 1
}

public enum HalftoneCmykType: Float, CaseIterable, Equatable, Sendable, Codable {
  case dots = 0
  case ink = 1
  case sharp = 2
}

public enum LiquidMetalShape: Float, CaseIterable, Equatable, Sendable, Codable {
  case none = 0
  case circle = 1
  case daisy = 2
  case diamond = 3
  case metaballs = 4
}

public enum GlassGridShape: Float, CaseIterable, Equatable, Sendable, Codable {
  case lines = 1
  case linesIrregular = 2
  case wave = 3
  case zigzag = 4
  case pattern = 5
}

public enum GlassDistortionShape: Float, CaseIterable, Equatable, Sendable, Codable {
  case prism = 1
  case lens = 2
  case contour = 3
  case cascade = 4
  case flat = 5
}

public enum GemSmokeShape: Float, CaseIterable, Equatable, Sendable, Codable {
  case none = 0
  case circle = 1
  case daisy = 2
  case diamond = 3
  case metaballs = 4
}

public enum ShaderParameters: Equatable, Sendable, Codable {
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

  public var kind: FoilShadersRenderer.ShaderKind {
    switch self {
    case .meshGradient: .meshGradient
    case .staticMeshGradient: .staticMeshGradient
    case .staticRadialGradient: .staticRadialGradient
    case .swirl: .swirl
    case .spiral: .spiral
    case .dotGrid: .dotGrid
    case .simplexNoise: .simplexNoise
    case .perlinNoise: .perlinNoise
    case .neuroNoise: .neuroNoise
    case .waves: .waves
    case .dithering: .dithering
    case .colorPanels: .colorPanels
    case .dotOrbit: .dotOrbit
    case .godRays: .godRays
    case .grainGradient: .grainGradient
    case .metaballs: .metaballs
    case .warp: .warp
    case .voronoi: .voronoi
    case .pulsingBorder: .pulsingBorder
    case .smokeRing: .smokeRing
    case .imageDithering: .imageDithering
    case .halftoneDots: .halftoneDots
    case .halftoneCmyk: .halftoneCmyk
    case .heatmap: .heatmap
    case .liquidMetal: .liquidMetal
    case .paperTexture: .paperTexture
    case .water: .water
    case .flutedGlass: .flutedGlass
    case .gemSmoke: .gemSmoke
    }
  }
}

public struct ShaderConfiguration: Equatable, Sendable, Codable {
  public var parameters: ShaderParameters
  public var sizing: ShaderSizingParams
  public var motion: ShaderMotionParams
  public var renderOptions: ShaderRenderOptions
  public var image: ShaderImage?

  public var kind: FoilShadersRenderer.ShaderKind { parameters.kind }

  public init(
    parameters: ShaderParameters,
    sizing: ShaderSizingParams = .defaultPatternSizing,
    motion: ShaderMotionParams = ShaderMotionParams(),
    renderOptions: ShaderRenderOptions = .default,
    image: ShaderImage? = nil
  ) {
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
