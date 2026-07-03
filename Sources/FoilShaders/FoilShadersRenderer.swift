import CoreGraphics
import Foundation
import Metal
import MetalKit

// MARK: - FoilShadersRenderer

// `@unchecked Sendable`: all mutable state is touched on the main thread (via
// the MTKView delegate callbacks and SwiftUI update path). The one background
// hop — remote image decoding in `loadRemoteImage` — marshals its result back
// to the main thread before mutating any state.
public class FoilShadersRenderer: NSObject, MTKViewDelegate, @unchecked Sendable {
  public enum ShaderKind: CaseIterable, Sendable {
    case meshGradient
    case staticMeshGradient
    case staticRadialGradient
    case swirl
    case spiral
    case dotGrid
    case simplexNoise
    case perlinNoise
    case neuroNoise
    case waves
    case dithering
    case colorPanels
    case dotOrbit
    case godRays
    case grainGradient
    case metaballs
    case warp
    case voronoi
    case pulsingBorder
    case smokeRing
    case imageDithering
    case halftoneDots
    case halftoneCmyk
    case heatmap
    case liquidMetal
    case paperTexture
    case water
    case flutedGlass
    case gemSmoke
  }
  private let device: MTLDevice
  private let commandQueue: MTLCommandQueue
  private let textureLoader: MTKTextureLoader
  private var pipelineState: MTLRenderPipelineState?
  private var vertexBuffer: MTLBuffer?
  private var noiseTexture: MTLTexture?
  private var imageTexture: MTLTexture?
  private var heatmapImageTexture: MTLTexture?
  private var fallbackImageTexture: MTLTexture?
  private var fallbackNoiseTexture: MTLTexture?
  private var imageAspectRatio: Float = 1.0
  private var heatmapImageAspectRatio: Float = 1.0

  // Time management (mirrors WebGL implementation)
  private var currentFrame: Float = 0.0
  private var lastRenderTime: CFTimeInterval = 0.0
  private var speed: Float = 0.0

  // Uniforms
  private var time: Float = 0.0
  private var resolution: SIMD2<Float> = SIMD2<Float>(0, 0)
  private var pixelRatio: Float = 1.0

  // Sizing params
  public var sizingParams: ShaderSizingParams = meshGradientPresets[0].sizing
  public var motionParams: ShaderMotionParams = meshGradientPresets[0].motion

  // Backing-store resolution controls (mirrors the web `minPixelRatio` /
  // `maxPixelCount`): raise the render scale to at least `minPixelRatio` for
  // sharper output, and cap total drawable pixels at `maxPixelCount`.
  public var renderOptions: ShaderRenderOptions = .default

  // Shader params
  public var meshGradientParams: MeshGradientParams = meshGradientPresets[0].params
  public var staticMeshGradientParams: StaticMeshGradientParams = staticMeshGradientPresets[0]
    .params
  public var staticRadialGradientParams: StaticRadialGradientParams = staticRadialGradientPresets[0]
    .params
  public var swirlParams: SwirlParams = swirlPresets[0].params
  public var spiralParams: SpiralParams = spiralPresets[0].params
  public var dotGridParams: DotGridParams = dotGridPresets[0].params
  public var simplexNoiseParams: SimplexNoiseParams = simplexNoisePresets[0].params
  public var perlinNoiseParams: PerlinNoiseParams = perlinNoisePresets[0].params
  public var neuroNoiseParams: NeuroNoiseParams = neuroNoisePresets[0].params
  public var wavesParams: WavesParams = wavesPresets[0].params
  public var ditheringParams: DitheringParams = ditheringPresets[0].params
  public var colorPanelsParams: ColorPanelsParams = colorPanelsPresets[0].params
  public var dotOrbitParams: DotOrbitParams = dotOrbitPresets[0].params
  public var godRaysParams: GodRaysParams = godRaysPresets[0].params
  public var grainGradientParams: GrainGradientParams = grainGradientPresets[0].params
  public var metaballsParams: MetaballsParams = metaballsPresets[0].params
  public var warpParams: WarpParams = warpPresets[0].params
  public var voronoiParams: VoronoiParams = voronoiPresets[0].params
  public var pulsingBorderParams: PulsingBorderParams = pulsingBorderPresets[0].params
  public var smokeRingParams: SmokeRingParams = smokeRingPresets[0].params
  public var imageDitheringParams: ImageDitheringParams = imageDitheringPresets[0].params
  public var halftoneDotsParams: HalftoneDotsParams = halftoneDotsPresets[0].params
  public var halftoneCmykParams: HalftoneCmykParams = halftoneCmykPresets[0].params
  public var heatmapParams: HeatmapParams = heatmapPresets[0].params
  public var liquidMetalParams: LiquidMetalParams = liquidMetalPresets[0].params
  public var paperTextureParams: PaperTextureParams = paperTexturePresets[0].params
  public var waterParams: WaterParams = waterPresets[0].params
  public var flutedGlassParams: FlutedGlassParams = flutedGlassPresets[0].params
  public var gemSmokeParams: GemSmokeParams = gemSmokePresets[0].params
  public var activeShader: ShaderKind = .meshGradient

  private var library: MTLLibrary?
  private var libraryShaderName: String?

  // Last-applied configuration values, used to diff on `apply(_:)` so that
  // repeated SwiftUI updates don't reset the animation, reload the image, or
  // re-trigger network fetches. `nil` means "not yet applied".
  private var appliedImage: ShaderImage?
  private var appliedImageIsSet = false
  private var appliedFrame: Float?
  private var appliedSpeed: Float?

  // Incremented on every image request so an in-flight async (remote) load can
  // tell whether its result is still the most recent one before installing it.
  private var imageRequestID: UInt64 = 0

  // Guards against re-entrancy: `MTKView.setDrawableSize` invokes the delegate's
  // `drawableSizeWillChange` synchronously (before committing the new value), so
  // without this flag `updateDrawableSizing` would recurse forever.
  private var isUpdatingDrawableSize = false

  // Weak reference to the view to control animation
  private weak var mtkView: MTKView?

  public init(device: MTLDevice) throws {
    self.device = device
    guard let commandQueue = device.makeCommandQueue() else {
      throw RendererError.deviceError
    }
    self.commandQueue = commandQueue
    self.textureLoader = MTKTextureLoader(device: device)
    super.init()

    setupVertexBuffer()
    loadNoiseTexture()
    setupFallbackTextures()
  }

  private func loadNoiseTexture() {
    for bundle in FoilShadersResourceBundles.candidates {
      if let url = bundle.url(forResource: "noise-texture", withExtension: "png") {
        // The bundled noise texture is a palette (indexed-color) PNG.
        // MTKTextureLoader cannot decode those (neither from a URL nor from
        // the indexed-colorspace CGImage ImageIO returns), so expand it to
        // RGBA8 through a device-RGB bitmap context (device space = no color
        // matching, keeping the exact palette byte values the WebGL reference
        // sees) and upload the raw bytes.
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
          let image = CGImageSourceCreateImageAtIndex(source, 0, nil)
        else { break }
        noiseTexture = makeTexture(expandingPalette: image)
        break
      }
    }
  }

  private func makeTexture(expandingPalette image: CGImage) -> MTLTexture? {
    let width = image.width
    let height = image.height
    var rgba = [UInt8](repeating: 0, count: width * height * 4)
    guard
      let context = CGContext(
        data: &rgba,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: width * 4,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
      )
    else { return nil }
    context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))

    let descriptor = MTLTextureDescriptor.texture2DDescriptor(
      pixelFormat: .rgba8Unorm,
      width: width,
      height: height,
      mipmapped: false
    )
    descriptor.usage = [.shaderRead, .renderTarget]
    guard let texture = device.makeTexture(descriptor: descriptor) else { return nil }
    rgba.withUnsafeBytes { buffer in
      texture.replace(
        region: MTLRegionMake2D(0, 0, width, height),
        mipmapLevel: 0,
        withBytes: buffer.baseAddress!,
        bytesPerRow: width * 4
      )
    }
    return texture
  }

  private func setupFallbackTextures() {
    if fallbackImageTexture == nil {
      fallbackImageTexture = makeSolidTexture(color: SIMD4<UInt8>(255, 255, 255, 255))
    }
    if fallbackNoiseTexture == nil {
      fallbackNoiseTexture = makeSolidTexture(color: SIMD4<UInt8>(127, 127, 127, 255))
    }
  }

  private func makeSolidTexture(color: SIMD4<UInt8>) -> MTLTexture? {
    let descriptor = MTLTextureDescriptor.texture2DDescriptor(
      pixelFormat: .rgba8Unorm,
      width: 1,
      height: 1,
      mipmapped: false
    )
    descriptor.usage = [.shaderRead]
    guard let texture = device.makeTexture(descriptor: descriptor) else {
      return nil
    }
    var pixel = [color.x, color.y, color.z, color.w]
    texture.replace(
      region: MTLRegionMake2D(0, 0, 1, 1), mipmapLevel: 0, withBytes: &pixel, bytesPerRow: 4)
    return texture
  }

  private func makeTexture(rgba: [UInt8], width: Int, height: Int, mipmapped: Bool = false)
    -> MTLTexture?
  {
    let descriptor = MTLTextureDescriptor.texture2DDescriptor(
      pixelFormat: .rgba8Unorm,
      width: width,
      height: height,
      mipmapped: mipmapped
    )
    descriptor.usage = [.shaderRead]
    guard let texture = device.makeTexture(descriptor: descriptor) else {
      return nil
    }
    rgba.withUnsafeBytes { buffer in
      texture.replace(
        region: MTLRegionMake2D(0, 0, width, height),
        mipmapLevel: 0,
        withBytes: buffer.baseAddress!,
        bytesPerRow: width * 4
      )
    }
    if mipmapped,
      let commandBuffer = commandQueue.makeCommandBuffer(),
      let blitEncoder = commandBuffer.makeBlitCommandEncoder()
    {
      blitEncoder.generateMipmaps(for: texture)
      blitEncoder.endEncoding()
      commandBuffer.commit()
      commandBuffer.waitUntilCompleted()
    }
    return texture
  }

  private func makeHeatmapImageTexture(from image: CGImage) -> (
    texture: MTLTexture, aspectRatio: Float
  )? {
    let canvasSize = 1000
    let maxBlur = Int(floor(Double(canvasSize) * 0.15))
    let padding = Int(ceil(Double(maxBlur) * 2.5))
    let ratio = Double(image.width) / max(1.0, Double(image.height))
    var imageWidth = canvasSize
    var imageHeight = canvasSize
    if ratio > 1.0 {
      imageHeight = Int(floor(Double(canvasSize) / ratio))
    } else {
      imageWidth = Int(floor(Double(canvasSize) * ratio))
    }

    let width = imageWidth + 2 * padding
    let height = imageHeight + 2 * padding
    var rgba = [UInt8](repeating: 255, count: width * height * 4)
    guard
      let context = CGContext(
        data: &rgba,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: width * 4,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
          .union(.byteOrder32Big).rawValue
      )
    else {
      return nil
    }

    context.interpolationQuality = .default
    context.translateBy(x: 0, y: CGFloat(height))
    context.scaleBy(x: 1, y: -1)
    context.draw(
      image,
      in: CGRect(x: padding, y: padding, width: imageWidth, height: imageHeight))

    let pixelCount = width * height
    var gray = [UInt8](repeating: 0, count: pixelCount)
    for i in 0..<pixelCount {
      let base = i * 4
      let r = Double(rgba[base])
      let g = Double(rgba[base + 1])
      let b = Double(rgba[base + 2])
      gray[i] = UInt8(max(0, min(255, Int(0.299 * r + 0.587 * g + 0.114 * b))))
    }

    let bigBlur = multiPassBlurGray(gray, width: width, height: height, radius: maxBlur, passes: 3)
    let innerBlur = multiPassBlurGray(
      gray, width: width, height: height, radius: max(1, Int((0.12 * Double(maxBlur)).rounded())),
      passes: 3)
    let contour = multiPassBlurGray(gray, width: width, height: height, radius: 5, passes: 1)

    var processed = [UInt8](repeating: 255, count: pixelCount * 4)
    for i in 0..<pixelCount {
      let base = i * 4
      processed[base] = contour[i]
      processed[base + 1] = bigBlur[i]
      processed[base + 2] = innerBlur[i]
      processed[base + 3] = 255
    }

    guard let texture = makeTexture(rgba: processed, width: width, height: height, mipmapped: true)
    else {
      return nil
    }
    return (texture, Float(width) / Float(height))
  }

  private func multiPassBlurGray(
    _ gray: [UInt8], width: Int, height: Int, radius: Int, passes: Int
  ) -> [UInt8] {
    if radius <= 0 || passes <= 1 {
      return blurGray(gray, width: width, height: height, radius: radius)
    }

    var input = gray
    var output = gray
    for _ in 0..<passes {
      output = blurGray(input, width: width, height: height, radius: radius)
      input = output
    }
    return output
  }

  private func blurGray(_ gray: [UInt8], width: Int, height: Int, radius: Int) -> [UInt8] {
    if radius <= 0 {
      return gray
    }

    var output = [UInt8](repeating: 0, count: width * height)
    var integral = [UInt32](repeating: 0, count: width * height)
    for y in 0..<height {
      var rowSum: UInt32 = 0
      for x in 0..<width {
        let index = y * width + x
        rowSum += UInt32(gray[index])
        integral[index] = rowSum + (y > 0 ? integral[index - width] : 0)
      }
    }

    for y in 0..<height {
      let y1 = max(0, y - radius)
      let y2 = min(height - 1, y + radius)
      for x in 0..<width {
        let x1 = max(0, x - radius)
        let x2 = min(width - 1, x + radius)
        let a = integral[y2 * width + x2]
        let b = x1 > 0 ? integral[y2 * width + x1 - 1] : 0
        let c = y1 > 0 ? integral[(y1 - 1) * width + x2] : 0
        let d = x1 > 0 && y1 > 0 ? integral[(y1 - 1) * width + x1 - 1] : 0
        let sum = Int(a) - Int(b) - Int(c) + Int(d)
        let area = (x2 - x1 + 1) * (y2 - y1 + 1)
        output[y * width + x] = UInt8(max(0, min(255, Int((Double(sum) / Double(area)).rounded()))))
      }
    }
    return output
  }

  private var activeImageAspectRatio: Float {
    if activeShader == .heatmap, heatmapImageTexture != nil {
      return heatmapImageAspectRatio
    }
    return imageAspectRatio
  }

  private var activeImageTexture: MTLTexture? {
    if activeShader == .heatmap {
      return heatmapImageTexture ?? imageTexture ?? fallbackImageTexture
    }
    return imageTexture ?? fallbackImageTexture
  }

  public func setImage(_ image: CGImage?) {
    guard let image else {
      imageTexture = nil
      heatmapImageTexture = nil
      imageAspectRatio = 1.0
      heatmapImageAspectRatio = 1.0
      return
    }
    imageTexture = try? textureLoader.newTexture(
      cgImage: image,
      options: [
        MTKTextureLoader.Option.SRGB: false,
        MTKTextureLoader.Option.generateMipmaps: true,
      ]
    )
    imageAspectRatio = Float(image.width) / max(1.0, Float(image.height))
    if let heatmapImage = makeHeatmapImageTexture(from: image) {
      heatmapImageTexture = heatmapImage.texture
      heatmapImageAspectRatio = heatmapImage.aspectRatio
    } else {
      heatmapImageTexture = nil
      heatmapImageAspectRatio = imageAspectRatio
    }
  }

  public func setImage(_ shaderImage: ShaderImage?) {
    // Any new image request supersedes an in-flight remote load.
    imageRequestID &+= 1
    guard let shaderImage else {
      setImage(nil as CGImage?)
      return
    }
    switch shaderImage {
    case .cgImage(let image):
      setImage(image)
    case .url(let url):
      setImage(FoilShadersDefaultImageLoader.loadCGImage(from: url))
    case .bundleResource(let name, let fileExtension, let bundle):
      let url = bundle.url(forResource: name, withExtension: fileExtension)
      setImage(url.flatMap(FoilShadersDefaultImageLoader.loadCGImage(from:)))
    case .remoteURL(let url):
      loadRemoteImage(from: url, requestID: imageRequestID)
    }
  }

  /// Loads a remote image off the main thread and installs it once ready. If a
  /// newer image has been requested in the meantime, the stale result is dropped.
  private func loadRemoteImage(from url: URL, requestID: UInt64) {
    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
      let image = FoilShadersDefaultImageLoader.loadCGImage(from: url)
      DispatchQueue.main.async {
        guard let self, self.imageRequestID == requestID else { return }
        self.setImage(image)
        // A static shader won't redraw on its own, so nudge it.
        if self.speed == 0.0 {
          self.mtkView?.setNeedsDisplay(self.mtkView?.bounds ?? .zero)
        }
      }
    }
  }

  /// Applies a new image only when it differs from the last one applied,
  /// so repeated SwiftUI updates don't re-decode or re-fetch the same image.
  private func updateImage(_ image: ShaderImage?) {
    if appliedImageIsSet && appliedImage == image { return }
    appliedImage = image
    appliedImageIsSet = true
    setImage(image)
  }

  private func setupVertexBuffer() {
    // Full-screen quad (two triangles) to match WebGL UV mapping
    let vertices: [Float] = [
      -1.0, -1.0,
      1.0, -1.0,
      -1.0, 1.0,
      -1.0, 1.0,
      1.0, -1.0,
      1.0, 1.0,
    ]
    vertexBuffer = device.makeBuffer(
      bytes: vertices, length: vertices.count * MemoryLayout<Float>.stride, options: [])
  }

  public func setupPipeline(fragmentFunctionName: String, library: MTLLibrary) throws {
    guard let vertexFunction = library.makeFunction(name: "vertex_main"),
      let fragmentFunction = library.makeFunction(name: fragmentFunctionName)
    else {
      throw RendererError.shaderError
    }

    let pipelineDescriptor = MTLRenderPipelineDescriptor()
    pipelineDescriptor.vertexFunction = vertexFunction
    pipelineDescriptor.fragmentFunction = fragmentFunction
    pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

    let vertexDescriptor = MTLVertexDescriptor()
    vertexDescriptor.attributes[0].format = .float2
    vertexDescriptor.attributes[0].offset = 0
    vertexDescriptor.attributes[0].bufferIndex = 0
    vertexDescriptor.layouts[0].stride = MemoryLayout<Float>.stride * 2
    pipelineDescriptor.vertexDescriptor = vertexDescriptor

    do {
      pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    } catch {
      throw RendererError.pipelineError(error)
    }
  }

  public func attach(to view: MTKView) {
    MainActor.assumeIsolated {
      self.mtkView = view
      view.delegate = self
      view.device = device
      view.colorPixelFormat = .bgra8Unorm
      view.enableSetNeedsDisplay = false
      view.isPaused = false
      view.framebufferOnly = true
      view.preferredFramesPerSecond = 60
      // Transparency: match the web version, where the canvas composites its
      // (premultiplied-alpha) output over the page. The shaders emit meaningful
      // alpha (e.g. FlutedGlass's transparent colorBack, mesh-gradient fractional
      // opacity), so clear to transparent and make the layer non-opaque; otherwise
      // those regions composite onto opaque black. CAMetalLayer composites using
      // premultiplied alpha, which is exactly what the shaders output.
      view.clearColor = MTLClearColorMake(0, 0, 0, 0)
      #if os(iOS)
        view.isOpaque = false
      #endif
      (view.layer as? CAMetalLayer)?.isOpaque = false
    }
  }

  public func configureMeshGradient() throws {
    try ensureLibrary(shaderName: "MeshGradient")
    if let library {
      try setupPipeline(fragmentFunctionName: "mesh_gradient_fragment", library: library)
      activeShader = .meshGradient
    } else {
      throw RendererError.libraryError
    }
  }

  public func configureStaticMeshGradient() throws {
    try ensureLibrary(shaderName: "StaticMeshGradient")
    if let library {
      try setupPipeline(fragmentFunctionName: "static_mesh_gradient_fragment", library: library)
      activeShader = .staticMeshGradient
    } else {
      throw RendererError.libraryError
    }
  }

  public func configureStaticRadialGradient() throws {
    try ensureLibrary(shaderName: "StaticRadialGradient")
    if let library {
      try setupPipeline(fragmentFunctionName: "static_radial_gradient_fragment", library: library)
      activeShader = .staticRadialGradient
    } else {
      throw RendererError.libraryError
    }
  }

  public func configureSwirl() throws {
    try ensureLibrary(shaderName: "Swirl")
    if let library {
      try setupPipeline(fragmentFunctionName: "swirl_fragment", library: library)
      activeShader = .swirl
    } else {
      throw RendererError.libraryError
    }
  }

  public func configureSpiral() throws {
    try ensureLibrary(shaderName: "Spiral")
    if let library {
      try setupPipeline(fragmentFunctionName: "spiral_fragment", library: library)
      activeShader = .spiral
    } else {
      throw RendererError.libraryError
    }
  }

  public func configureDotGrid() throws {
    try ensureLibrary(shaderName: "DotGrid")
    if let library {
      try setupPipeline(fragmentFunctionName: "dot_grid_fragment", library: library)
      activeShader = .dotGrid
    } else {
      throw RendererError.libraryError
    }
  }

  public func configureSimplexNoise() throws {
    try ensureLibrary(shaderName: "SimplexNoise")
    if let library {
      try setupPipeline(fragmentFunctionName: "simplex_noise_fragment", library: library)
      activeShader = .simplexNoise
    } else {
      throw RendererError.libraryError
    }
  }

  public func configurePerlinNoise() throws {
    try ensureLibrary(shaderName: "PerlinNoise")
    if let library {
      try setupPipeline(fragmentFunctionName: "perlin_noise_fragment", library: library)
      activeShader = .perlinNoise
    } else {
      throw RendererError.libraryError
    }
  }

  public func configureNeuroNoise() throws {
    try ensureLibrary(shaderName: "NeuroNoise")
    if let library {
      try setupPipeline(fragmentFunctionName: "neuro_noise_fragment", library: library)
      activeShader = .neuroNoise
    } else {
      throw RendererError.libraryError
    }
  }

  public func configureWaves() throws {
    try ensureLibrary(shaderName: "Waves")
    if let library {
      try setupPipeline(fragmentFunctionName: "waves_fragment", library: library)
      activeShader = .waves
    } else {
      throw RendererError.libraryError
    }
  }

  public func configureDithering() throws {
    try ensureLibrary(shaderName: "Dithering")
    if let library {
      try setupPipeline(fragmentFunctionName: "dithering_fragment", library: library)
      activeShader = .dithering
    } else {
      throw RendererError.libraryError
    }
  }

  public func configureColorPanels() throws {
    try ensureLibrary(shaderName: "ColorPanels")
    if let library {
      try setupPipeline(fragmentFunctionName: "color_panels_fragment", library: library)
      activeShader = .colorPanels
    } else {
      throw RendererError.libraryError
    }
  }

  public func configureDotOrbit() throws {
    try ensureLibrary(shaderName: "DotOrbit")
    if let library {
      try setupPipeline(fragmentFunctionName: "dot_orbit_fragment", library: library)
      activeShader = .dotOrbit
    } else {
      throw RendererError.libraryError
    }
  }

  public func configureGodRays() throws {
    try ensureLibrary(shaderName: "GodRays")
    if let library {
      try setupPipeline(fragmentFunctionName: "god_rays_fragment", library: library)
      activeShader = .godRays
    } else {
      throw RendererError.libraryError
    }
  }

  public func configureGrainGradient() throws {
    try ensureLibrary(shaderName: "GrainGradient")
    if let library {
      try setupPipeline(fragmentFunctionName: "grain_gradient_fragment", library: library)
      activeShader = .grainGradient
    } else {
      throw RendererError.libraryError
    }
  }

  public func configureMetaballs() throws {
    try ensureLibrary(shaderName: "Metaballs")
    if let library {
      try setupPipeline(fragmentFunctionName: "metaballs_fragment", library: library)
      activeShader = .metaballs
    } else {
      throw RendererError.libraryError
    }
  }

  public func configureWarp() throws {
    try ensureLibrary(shaderName: "Warp")
    if let library {
      try setupPipeline(fragmentFunctionName: "warp_fragment", library: library)
      activeShader = .warp
    } else {
      throw RendererError.libraryError
    }
  }

  public func configureVoronoi() throws {
    try ensureLibrary(shaderName: "Voronoi")
    if let library {
      try setupPipeline(fragmentFunctionName: "voronoi_fragment", library: library)
      activeShader = .voronoi
    } else {
      throw RendererError.libraryError
    }
  }

  public func configurePulsingBorder() throws {
    try ensureLibrary(shaderName: "PulsingBorder")
    if let library {
      try setupPipeline(fragmentFunctionName: "pulsing_border_fragment", library: library)
      activeShader = .pulsingBorder
    } else {
      throw RendererError.libraryError
    }
  }

  public func configureSmokeRing() throws {
    try ensureLibrary(shaderName: "SmokeRing")
    if let library {
      try setupPipeline(fragmentFunctionName: "smoke_ring_fragment", library: library)
      activeShader = .smokeRing
    } else {
      throw RendererError.libraryError
    }
  }

  public func configureImageDithering() throws {
    try ensureLibrary(shaderName: "ImageDithering")
    if let library {
      try setupPipeline(fragmentFunctionName: "image_dithering_fragment", library: library)
      activeShader = .imageDithering
    } else {
      throw RendererError.libraryError
    }
  }

  public func configureHalftoneDots() throws {
    try ensureLibrary(shaderName: "HalftoneDots")
    if let library {
      try setupPipeline(fragmentFunctionName: "halftone_dots_fragment", library: library)
      activeShader = .halftoneDots
    } else {
      throw RendererError.libraryError
    }
  }

  public func configureHalftoneCmyk() throws {
    try ensureLibrary(shaderName: "HalftoneCmyk")
    if let library {
      try setupPipeline(fragmentFunctionName: "halftone_cmyk_fragment", library: library)
      activeShader = .halftoneCmyk
    } else {
      throw RendererError.libraryError
    }
  }

  public func configureHeatmap() throws {
    try ensureLibrary(shaderName: "Heatmap")
    if let library {
      try setupPipeline(fragmentFunctionName: "heatmap_fragment", library: library)
      activeShader = .heatmap
    } else {
      throw RendererError.libraryError
    }
  }

  public func configureLiquidMetal() throws {
    try ensureLibrary(shaderName: "LiquidMetal")
    if let library {
      try setupPipeline(fragmentFunctionName: "liquid_metal_fragment", library: library)
      activeShader = .liquidMetal
    } else {
      throw RendererError.libraryError
    }
  }

  public func configurePaperTexture() throws {
    try ensureLibrary(shaderName: "PaperTexture")
    if let library {
      try setupPipeline(fragmentFunctionName: "paper_texture_fragment", library: library)
      activeShader = .paperTexture
    } else {
      throw RendererError.libraryError
    }
  }

  public func configureWater() throws {
    try ensureLibrary(shaderName: "Water")
    if let library {
      try setupPipeline(fragmentFunctionName: "water_fragment", library: library)
      activeShader = .water
    } else {
      throw RendererError.libraryError
    }
  }

  public func configureFlutedGlass() throws {
    try ensureLibrary(shaderName: "FlutedGlass")
    if let library {
      try setupPipeline(fragmentFunctionName: "fluted_glass_fragment", library: library)
      activeShader = .flutedGlass
    } else {
      throw RendererError.libraryError
    }
  }

  public func configureGemSmoke() throws {
    try ensureLibrary(shaderName: "GemSmoke")
    if let library {
      try setupPipeline(fragmentFunctionName: "gem_smoke_fragment", library: library)
      activeShader = .gemSmoke
    } else {
      throw RendererError.libraryError
    }
  }

  public func configure(_ shaderKind: ShaderKind) throws {
    switch shaderKind {
    case .meshGradient: try configureMeshGradient()
    case .staticMeshGradient: try configureStaticMeshGradient()
    case .staticRadialGradient: try configureStaticRadialGradient()
    case .swirl: try configureSwirl()
    case .spiral: try configureSpiral()
    case .dotGrid: try configureDotGrid()
    case .simplexNoise: try configureSimplexNoise()
    case .perlinNoise: try configurePerlinNoise()
    case .neuroNoise: try configureNeuroNoise()
    case .waves: try configureWaves()
    case .dithering: try configureDithering()
    case .colorPanels: try configureColorPanels()
    case .dotOrbit: try configureDotOrbit()
    case .godRays: try configureGodRays()
    case .grainGradient: try configureGrainGradient()
    case .metaballs: try configureMetaballs()
    case .warp: try configureWarp()
    case .voronoi: try configureVoronoi()
    case .pulsingBorder: try configurePulsingBorder()
    case .smokeRing: try configureSmokeRing()
    case .imageDithering: try configureImageDithering()
    case .halftoneDots: try configureHalftoneDots()
    case .halftoneCmyk: try configureHalftoneCmyk()
    case .heatmap: try configureHeatmap()
    case .liquidMetal: try configureLiquidMetal()
    case .paperTexture: try configurePaperTexture()
    case .water: try configureWater()
    case .flutedGlass: try configureFlutedGlass()
    case .gemSmoke: try configureGemSmoke()
    }
  }

  public func apply(_ configuration: ShaderConfiguration) {
    sizingParams = configuration.sizing
    motionParams = configuration.motion
    switch configuration.parameters {
    case .meshGradient(let params): meshGradientParams = params
    case .staticMeshGradient(let params): staticMeshGradientParams = params
    case .staticRadialGradient(let params): staticRadialGradientParams = params
    case .swirl(let params): swirlParams = params
    case .spiral(let params): spiralParams = params
    case .dotGrid(let params): dotGridParams = params
    case .simplexNoise(let params): simplexNoiseParams = params
    case .perlinNoise(let params): perlinNoiseParams = params
    case .neuroNoise(let params): neuroNoiseParams = params
    case .waves(let params): wavesParams = params
    case .dithering(let params): ditheringParams = params
    case .colorPanels(let params): colorPanelsParams = params
    case .dotOrbit(let params): dotOrbitParams = params
    case .godRays(let params): godRaysParams = params
    case .grainGradient(let params): grainGradientParams = params
    case .metaballs(let params): metaballsParams = params
    case .warp(let params): warpParams = params
    case .voronoi(let params): voronoiParams = params
    case .pulsingBorder(let params): pulsingBorderParams = params
    case .smokeRing(let params): smokeRingParams = params
    case .imageDithering(let params): imageDitheringParams = params
    case .halftoneDots(let params): halftoneDotsParams = params
    case .halftoneCmyk(let params): halftoneCmykParams = params
    case .heatmap(let params): heatmapParams = params
    case .liquidMetal(let params): liquidMetalParams = params
    case .paperTexture(let params): paperTextureParams = params
    case .water(let params): waterParams = params
    case .flutedGlass(let params): flutedGlassParams = params
    case .gemSmoke(let params): gemSmokeParams = params
    }
    updateImage(configuration.image)
    // Only reset the frame / speed when the values actually change, otherwise a
    // routine SwiftUI update (e.g. an unrelated parent state change) would
    // restart the animation. Mirrors the React wrapper, which calls setFrame
    // only when the `frame` prop changes.
    if appliedFrame != configuration.motion.frame {
      appliedFrame = configuration.motion.frame
      setFrame(configuration.motion.frame)
    }
    if appliedSpeed != configuration.motion.speed {
      appliedSpeed = configuration.motion.speed
      setSpeed(configuration.motion.speed)
    }
    // Re-clamp the drawable if the resolution controls changed (e.g. a new
    // maxPixelCount), matching the reference which re-runs its resize handler.
    if renderOptions != configuration.renderOptions {
      renderOptions = configuration.renderOptions
      if let mtkView {
        updateDrawableSizing(for: mtkView)
      }
    }
  }

  private func ensureLibrary(shaderName: String) throws {
    if library == nil || libraryShaderName != shaderName {
      library = try ShaderLibraryLoader.makeLibrary(device: device, shaderNames: [shaderName])
      libraryShaderName = shaderName
    }
  }

  public func setSpeed(_ speed: Float) {
    let wasStatic = self.speed == 0.0
    self.speed = speed
    let isStatic = speed == 0.0
    if let mtkView {
      MainActor.assumeIsolated {
        mtkView.enableSetNeedsDisplay = isStatic
        mtkView.isPaused = isStatic
      }
    }
    if wasStatic && !isStatic {
      lastRenderTime = CACurrentMediaTime()
    }
    if isStatic, let mtkView {
      MainActor.assumeIsolated {
        mtkView.setNeedsDisplay(mtkView.bounds)
      }
    }
  }

  public func setFrame(_ frame: Float) {
    self.currentFrame = frame
    self.lastRenderTime = CACurrentMediaTime()
  }

  public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    updateDrawableSizing(for: view)
  }

  /// Sizes the view's drawable to honor `minPixelRatio` / `maxPixelCount`, then
  /// records the resulting resolution and render scale. Mirrors the reference's
  /// resize handler. `autoResizeDrawable` stays enabled, so this re-runs whenever
  /// the view's bounds or backing scale change and overrides MTKView's default
  /// native-scale drawable.
  private func updateDrawableSizing(for view: MTKView) {
    MainActor.assumeIsolated {
      // Ignore the delegate callback triggered by our own `drawableSize` write.
      if isUpdatingDrawableSize { return }

      let pointSize = view.bounds.size
      guard pointSize.width > 0, pointSize.height > 0 else {
        // Bounds not laid out yet; fall back to whatever MTKView computed.
        let fallback = view.drawableSize
        resolution = SIMD2<Float>(Float(fallback.width), Float(fallback.height))
        pixelRatio = Float(view.layer?.contentsScale ?? 1.0)
        return
      }
      let nativeScale = view.layer?.contentsScale ?? 1.0
      let (clamped, renderScale) = clampedDrawableSize(
        pointSize: pointSize, nativeScale: nativeScale)
      if view.drawableSize != clamped {
        isUpdatingDrawableSize = true
        view.drawableSize = clamped
        isUpdatingDrawableSize = false
      }
      resolution = SIMD2<Float>(Float(clamped.width), Float(clamped.height))
      pixelRatio = renderScale
      if speed == 0.0 {
        view.setNeedsDisplay(view.bounds)
      }
    }
  }

  /// Computes the clamped drawable pixel size and the corresponding render scale
  /// (the `u_pixelRatio` uniform = drawable pixels per point).
  private func clampedDrawableSize(pointSize: CGSize, nativeScale: CGFloat) -> (
    size: CGSize, renderScale: Float
  ) {
    let pointWidth = max(1.0, Double(pointSize.width))
    let pointHeight = max(1.0, Double(pointSize.height))
    // Never downscale below the native backing scale, but reach at least minPixelRatio.
    let targetScale = max(Double(nativeScale), Double(renderOptions.minPixelRatio))
    var targetWidth = pointWidth * targetScale
    var targetHeight = pointHeight * targetScale
    // Cap the total pixel count.
    let maxPixels = Double(renderOptions.maxPixelCount)
    let targetPixels = targetWidth * targetHeight
    if maxPixels > 0, targetPixels > maxPixels {
      let downscale = (maxPixels / targetPixels).squareRoot()
      targetWidth *= downscale
      targetHeight *= downscale
    }
    let width = max(1.0, targetWidth.rounded())
    let height = max(1.0, targetHeight.rounded())
    return (CGSize(width: width, height: height), Float(width / pointWidth))
  }

  public func setRenderSize(width: Int, height: Int, pixelRatio: Float = 1) {
    resolution = SIMD2<Float>(Float(width), Float(height))
    self.pixelRatio = pixelRatio
  }

  public func draw(in view: MTKView) {
    guard let drawable = view.currentDrawable,
      let renderPassDescriptor = view.currentRenderPassDescriptor,
      let pipelineState = pipelineState,
      let vertexBuffer = vertexBuffer
    else {
      return
    }

    // Update time
    let currentTime = CACurrentMediaTime()
    if lastRenderTime > 0 {
      let dt = Float(currentTime - lastRenderTime) * 1000.0  // Convert to milliseconds
      if speed != 0.0 {
        currentFrame += dt * speed
      }
    } else {
      lastRenderTime = currentTime
    }
    lastRenderTime = currentTime
    time = currentFrame * 0.001  // Convert to seconds (matches WebGL implementation)

    guard let commandBuffer = commandQueue.makeCommandBuffer(),
      let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
    else {
      return
    }

    renderEncoder.setRenderPipelineState(pipelineState)
    renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)

    var vertexUniforms = VertexUniforms(
      u_resolution: resolution,
      u_pixelRatio: pixelRatio,
      u_imageAspectRatio: activeImageAspectRatio,
      u_originX: sizingParams.originX,
      u_originY: sizingParams.originY,
      u_worldWidth: sizingParams.worldWidth,
      u_worldHeight: sizingParams.worldHeight,
      u_fit: sizingParams.fit.rawValue,
      u_scale: sizingParams.scale,
      u_rotation: sizingParams.rotation,
      u_offsetX: sizingParams.offsetX,
      u_offsetY: sizingParams.offsetY
    )
    renderEncoder.setVertexBytes(
      &vertexUniforms,
      length: MemoryLayout<VertexUniforms>.stride,
      index: 1)
    renderEncoder.setFragmentBytes(
      &vertexUniforms,
      length: MemoryLayout<VertexUniforms>.stride,
      index: 1)
    renderEncoder.setFragmentTexture(activeImageTexture, index: 0)
    renderEncoder.setFragmentTexture(noiseTexture ?? fallbackNoiseTexture, index: 1)

    switch activeShader {
    case .meshGradient:
      var meshUniforms = MeshGradientUniformsRaw(time: time, params: meshGradientParams)
      renderEncoder.setFragmentBytes(
        &meshUniforms,
        length: MemoryLayout<MeshGradientUniformsRaw>.stride,
        index: 0)
    case .staticMeshGradient:
      var staticMeshUniforms = StaticMeshGradientUniformsRaw(params: staticMeshGradientParams)
      renderEncoder.setFragmentBytes(
        &staticMeshUniforms,
        length: MemoryLayout<StaticMeshGradientUniformsRaw>.stride,
        index: 0)
    case .staticRadialGradient:
      var staticRadialUniforms = StaticRadialGradientUniformsRaw(params: staticRadialGradientParams)
      renderEncoder.setFragmentBytes(
        &staticRadialUniforms,
        length: MemoryLayout<StaticRadialGradientUniformsRaw>.stride,
        index: 0)
    case .swirl:
      var swirlUniforms = SwirlUniformsRaw(time: time, params: swirlParams)
      renderEncoder.setFragmentBytes(
        &swirlUniforms,
        length: MemoryLayout<SwirlUniformsRaw>.stride,
        index: 0)
    case .spiral:
      var spiralUniforms = SpiralUniformsRaw(time: time, params: spiralParams)
      renderEncoder.setFragmentBytes(
        &spiralUniforms,
        length: MemoryLayout<SpiralUniformsRaw>.stride,
        index: 0)
    case .dotGrid:
      var dotGridUniforms = DotGridUniformsRaw(params: dotGridParams)
      renderEncoder.setFragmentBytes(
        &dotGridUniforms,
        length: MemoryLayout<DotGridUniformsRaw>.stride,
        index: 0)
    case .simplexNoise:
      var simplexUniforms = SimplexNoiseUniformsRaw(time: time, params: simplexNoiseParams)
      renderEncoder.setFragmentBytes(
        &simplexUniforms,
        length: MemoryLayout<SimplexNoiseUniformsRaw>.stride,
        index: 0)
    case .perlinNoise:
      var perlinUniforms = PerlinNoiseUniformsRaw(time: time, params: perlinNoiseParams)
      renderEncoder.setFragmentBytes(
        &perlinUniforms,
        length: MemoryLayout<PerlinNoiseUniformsRaw>.stride,
        index: 0)
    case .neuroNoise:
      var neuroUniforms = NeuroNoiseUniformsRaw(time: time, params: neuroNoiseParams)
      renderEncoder.setFragmentBytes(
        &neuroUniforms,
        length: MemoryLayout<NeuroNoiseUniformsRaw>.stride,
        index: 0)
    case .waves:
      var wavesUniforms = WavesUniformsRaw(params: wavesParams)
      renderEncoder.setFragmentBytes(
        &wavesUniforms,
        length: MemoryLayout<WavesUniformsRaw>.stride,
        index: 0)
    case .dithering:
      var ditheringUniforms = DitheringUniformsRaw(time: time, params: ditheringParams)
      renderEncoder.setFragmentBytes(
        &ditheringUniforms,
        length: MemoryLayout<DitheringUniformsRaw>.stride,
        index: 0)
    case .colorPanels:
      var colorPanelsUniforms = ColorPanelsUniformsRaw(
        time: time, scale: sizingParams.scale, params: colorPanelsParams)
      renderEncoder.setFragmentBytes(
        &colorPanelsUniforms,
        length: MemoryLayout<ColorPanelsUniformsRaw>.stride,
        index: 0)
    case .dotOrbit:
      var dotOrbitUniforms = DotOrbitUniformsRaw(time: time, params: dotOrbitParams)
      renderEncoder.setFragmentBytes(
        &dotOrbitUniforms,
        length: MemoryLayout<DotOrbitUniformsRaw>.stride,
        index: 0)
    case .godRays:
      var godRaysUniforms = GodRaysUniformsRaw(time: time, params: godRaysParams)
      renderEncoder.setFragmentBytes(
        &godRaysUniforms,
        length: MemoryLayout<GodRaysUniformsRaw>.stride,
        index: 0)
    case .grainGradient:
      var grainGradientUniforms = GrainGradientUniformsRaw(time: time, params: grainGradientParams)
      renderEncoder.setFragmentBytes(
        &grainGradientUniforms,
        length: MemoryLayout<GrainGradientUniformsRaw>.stride,
        index: 0)
    case .metaballs:
      var metaballsUniforms = MetaballsUniformsRaw(time: time, params: metaballsParams)
      renderEncoder.setFragmentBytes(
        &metaballsUniforms,
        length: MemoryLayout<MetaballsUniformsRaw>.stride,
        index: 0)
    case .warp:
      var warpUniforms = WarpUniformsRaw(time: time, scale: sizingParams.scale, params: warpParams)
      renderEncoder.setFragmentBytes(
        &warpUniforms,
        length: MemoryLayout<WarpUniformsRaw>.stride,
        index: 0)
    case .voronoi:
      var voronoiUniforms = VoronoiUniformsRaw(
        time: time, scale: sizingParams.scale, params: voronoiParams)
      renderEncoder.setFragmentBytes(
        &voronoiUniforms,
        length: MemoryLayout<VoronoiUniformsRaw>.stride,
        index: 0)
    case .pulsingBorder:
      var pulsingBorderUniforms = PulsingBorderUniformsRaw(time: time, params: pulsingBorderParams)
      renderEncoder.setFragmentBytes(
        &pulsingBorderUniforms,
        length: MemoryLayout<PulsingBorderUniformsRaw>.stride,
        index: 0)
    case .smokeRing:
      var smokeRingUniforms = SmokeRingUniformsRaw(time: time, params: smokeRingParams)
      renderEncoder.setFragmentBytes(
        &smokeRingUniforms,
        length: MemoryLayout<SmokeRingUniformsRaw>.stride,
        index: 0)
    case .imageDithering:
      var imageDitheringUniforms = ImageDitheringUniformsRaw(params: imageDitheringParams)
      renderEncoder.setFragmentBytes(
        &imageDitheringUniforms,
        length: MemoryLayout<ImageDitheringUniformsRaw>.stride,
        index: 0)
    case .halftoneDots:
      var halftoneDotsUniforms = HalftoneDotsUniformsRaw(time: time, params: halftoneDotsParams)
      renderEncoder.setFragmentBytes(
        &halftoneDotsUniforms,
        length: MemoryLayout<HalftoneDotsUniformsRaw>.stride,
        index: 0)
    case .halftoneCmyk:
      var halftoneCmykUniforms = HalftoneCmykUniformsRaw(params: halftoneCmykParams)
      renderEncoder.setFragmentBytes(
        &halftoneCmykUniforms,
        length: MemoryLayout<HalftoneCmykUniformsRaw>.stride,
        index: 0)
    case .heatmap:
      var heatmapUniforms = HeatmapUniformsRaw(time: time, params: heatmapParams)
      renderEncoder.setFragmentBytes(
        &heatmapUniforms,
        length: MemoryLayout<HeatmapUniformsRaw>.stride,
        index: 0)
    case .liquidMetal:
      var liquidMetalUniforms = LiquidMetalUniformsRaw(time: time, params: liquidMetalParams)
      liquidMetalUniforms.u_isImage = imageTexture == nil ? 0 : 1
      renderEncoder.setFragmentBytes(
        &liquidMetalUniforms,
        length: MemoryLayout<LiquidMetalUniformsRaw>.stride,
        index: 0)
    case .paperTexture:
      var paperTextureUniforms = PaperTextureUniformsRaw(params: paperTextureParams)
      renderEncoder.setFragmentBytes(
        &paperTextureUniforms,
        length: MemoryLayout<PaperTextureUniformsRaw>.stride,
        index: 0)
    case .water:
      var waterUniforms = WaterUniformsRaw(time: time, params: waterParams)
      renderEncoder.setFragmentBytes(
        &waterUniforms,
        length: MemoryLayout<WaterUniformsRaw>.stride,
        index: 0)
    case .flutedGlass:
      var flutedGlassUniforms = FlutedGlassUniformsRaw(
        resolution: resolution,
        pixelRatio: pixelRatio,
        rotation: sizingParams.rotation,
        params: flutedGlassParams)
      renderEncoder.setFragmentBytes(
        &flutedGlassUniforms,
        length: MemoryLayout<FlutedGlassUniformsRaw>.stride,
        index: 0)
    case .gemSmoke:
      var gemSmokeUniforms = GemSmokeUniformsRaw(time: time, params: gemSmokeParams)
      gemSmokeUniforms.u_isImage = imageTexture == nil ? 0 : 1
      renderEncoder.setFragmentBytes(
        &gemSmokeUniforms,
        length: MemoryLayout<GemSmokeUniformsRaw>.stride,
        index: 0)
    }

    renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
    renderEncoder.endEncoding()

    commandBuffer.present(drawable)
    commandBuffer.commit()
  }

  public func captureCurrentImage() -> CGImage? {
    guard let capture = captureCurrentPixels() else { return nil }
    let bytesPerRow = capture.width * 4
    guard let provider = CGDataProvider(data: Data(capture.rgba) as CFData) else { return nil }
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    // The shaders output premultiplied alpha (each composites `color.rgb *= a`),
    // so the rendered texture holds premultiplied data — hence `premultipliedLast`.
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
      .union(.byteOrder32Big)
    return CGImage(
      width: capture.width,
      height: capture.height,
      bitsPerComponent: 8,
      bitsPerPixel: 32,
      bytesPerRow: bytesPerRow,
      space: colorSpace,
      bitmapInfo: bitmapInfo,
      provider: provider,
      decode: nil,
      shouldInterpolate: false,
      intent: .defaultIntent
    )
  }

  /// Renders the current shader offscreen and returns the raw RGBA8 bytes
  /// (premultiplied alpha, top-down row order), exactly as produced by the
  /// fragment shader with no color management applied.
  func captureCurrentPixels() -> (rgba: [UInt8], width: Int, height: Int)? {
    guard let pipelineState = pipelineState,
      let vertexBuffer = vertexBuffer
    else {
      return nil
    }
    let width = Int(resolution.x)
    let height = Int(resolution.y)
    if width <= 0 || height <= 0 { return nil }

    // The export path never runs `draw(in:)`, so compute the shader time from
    // the current frame here; otherwise captures always encode `time == 0`.
    time = currentFrame * 0.001  // seconds (matches WebGL implementation)

    let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
      pixelFormat: .bgra8Unorm,
      width: width,
      height: height,
      mipmapped: false
    )
    textureDescriptor.usage = [.renderTarget, .shaderRead]
    guard let texture = device.makeTexture(descriptor: textureDescriptor) else {
      return nil
    }

    let passDescriptor = MTLRenderPassDescriptor()
    passDescriptor.colorAttachments[0].texture = texture
    passDescriptor.colorAttachments[0].loadAction = .clear
    passDescriptor.colorAttachments[0].storeAction = .store
    passDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 0)

    guard let commandBuffer = commandQueue.makeCommandBuffer(),
      let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor)
    else {
      return nil
    }

    var vertexUniforms = VertexUniforms(
      u_resolution: resolution,
      u_pixelRatio: pixelRatio,
      u_imageAspectRatio: activeImageAspectRatio,
      u_originX: sizingParams.originX,
      u_originY: sizingParams.originY,
      u_worldWidth: sizingParams.worldWidth,
      u_worldHeight: sizingParams.worldHeight,
      u_fit: sizingParams.fit.rawValue,
      u_scale: sizingParams.scale,
      u_rotation: sizingParams.rotation,
      u_offsetX: sizingParams.offsetX,
      u_offsetY: sizingParams.offsetY
    )
    encoder.setRenderPipelineState(pipelineState)
    encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
    encoder.setVertexBytes(&vertexUniforms, length: MemoryLayout<VertexUniforms>.stride, index: 1)
    encoder.setFragmentBytes(&vertexUniforms, length: MemoryLayout<VertexUniforms>.stride, index: 1)
    encoder.setFragmentTexture(activeImageTexture, index: 0)
    encoder.setFragmentTexture(noiseTexture ?? fallbackNoiseTexture, index: 1)
    switch activeShader {
    case .meshGradient:
      var meshUniforms = MeshGradientUniformsRaw(time: time, params: meshGradientParams)
      encoder.setFragmentBytes(
        &meshUniforms, length: MemoryLayout<MeshGradientUniformsRaw>.stride, index: 0)
    case .staticMeshGradient:
      var staticMeshUniforms = StaticMeshGradientUniformsRaw(params: staticMeshGradientParams)
      encoder.setFragmentBytes(
        &staticMeshUniforms, length: MemoryLayout<StaticMeshGradientUniformsRaw>.stride, index: 0)
    case .staticRadialGradient:
      var staticRadialUniforms = StaticRadialGradientUniformsRaw(params: staticRadialGradientParams)
      encoder.setFragmentBytes(
        &staticRadialUniforms, length: MemoryLayout<StaticRadialGradientUniformsRaw>.stride,
        index: 0)
    case .swirl:
      var swirlUniforms = SwirlUniformsRaw(time: time, params: swirlParams)
      encoder.setFragmentBytes(
        &swirlUniforms, length: MemoryLayout<SwirlUniformsRaw>.stride, index: 0)
    case .spiral:
      var spiralUniforms = SpiralUniformsRaw(time: time, params: spiralParams)
      encoder.setFragmentBytes(
        &spiralUniforms, length: MemoryLayout<SpiralUniformsRaw>.stride, index: 0)
    case .dotGrid:
      var dotGridUniforms = DotGridUniformsRaw(params: dotGridParams)
      encoder.setFragmentBytes(
        &dotGridUniforms, length: MemoryLayout<DotGridUniformsRaw>.stride, index: 0)
    case .simplexNoise:
      var simplexUniforms = SimplexNoiseUniformsRaw(time: time, params: simplexNoiseParams)
      encoder.setFragmentBytes(
        &simplexUniforms, length: MemoryLayout<SimplexNoiseUniformsRaw>.stride, index: 0)
    case .perlinNoise:
      var perlinUniforms = PerlinNoiseUniformsRaw(time: time, params: perlinNoiseParams)
      encoder.setFragmentBytes(
        &perlinUniforms, length: MemoryLayout<PerlinNoiseUniformsRaw>.stride, index: 0)
    case .neuroNoise:
      var neuroUniforms = NeuroNoiseUniformsRaw(time: time, params: neuroNoiseParams)
      encoder.setFragmentBytes(
        &neuroUniforms, length: MemoryLayout<NeuroNoiseUniformsRaw>.stride, index: 0)
    case .waves:
      var wavesUniforms = WavesUniformsRaw(params: wavesParams)
      encoder.setFragmentBytes(
        &wavesUniforms, length: MemoryLayout<WavesUniformsRaw>.stride, index: 0)
    case .dithering:
      var ditheringUniforms = DitheringUniformsRaw(time: time, params: ditheringParams)
      encoder.setFragmentBytes(
        &ditheringUniforms, length: MemoryLayout<DitheringUniformsRaw>.stride, index: 0)
    case .colorPanels:
      var colorPanelsUniforms = ColorPanelsUniformsRaw(
        time: time, scale: sizingParams.scale, params: colorPanelsParams)
      encoder.setFragmentBytes(
        &colorPanelsUniforms, length: MemoryLayout<ColorPanelsUniformsRaw>.stride, index: 0)
    case .dotOrbit:
      var dotOrbitUniforms = DotOrbitUniformsRaw(time: time, params: dotOrbitParams)
      encoder.setFragmentBytes(
        &dotOrbitUniforms, length: MemoryLayout<DotOrbitUniformsRaw>.stride, index: 0)
    case .godRays:
      var godRaysUniforms = GodRaysUniformsRaw(time: time, params: godRaysParams)
      encoder.setFragmentBytes(
        &godRaysUniforms, length: MemoryLayout<GodRaysUniformsRaw>.stride, index: 0)
    case .grainGradient:
      var grainGradientUniforms = GrainGradientUniformsRaw(time: time, params: grainGradientParams)
      encoder.setFragmentBytes(
        &grainGradientUniforms, length: MemoryLayout<GrainGradientUniformsRaw>.stride, index: 0)
    case .metaballs:
      var metaballsUniforms = MetaballsUniformsRaw(time: time, params: metaballsParams)
      encoder.setFragmentBytes(
        &metaballsUniforms, length: MemoryLayout<MetaballsUniformsRaw>.stride, index: 0)
    case .warp:
      var warpUniforms = WarpUniformsRaw(time: time, scale: sizingParams.scale, params: warpParams)
      encoder.setFragmentBytes(
        &warpUniforms, length: MemoryLayout<WarpUniformsRaw>.stride, index: 0)
    case .voronoi:
      var voronoiUniforms = VoronoiUniformsRaw(
        time: time, scale: sizingParams.scale, params: voronoiParams)
      encoder.setFragmentBytes(
        &voronoiUniforms, length: MemoryLayout<VoronoiUniformsRaw>.stride, index: 0)
    case .pulsingBorder:
      var pulsingBorderUniforms = PulsingBorderUniformsRaw(time: time, params: pulsingBorderParams)
      encoder.setFragmentBytes(
        &pulsingBorderUniforms, length: MemoryLayout<PulsingBorderUniformsRaw>.stride, index: 0)
    case .smokeRing:
      var smokeRingUniforms = SmokeRingUniformsRaw(time: time, params: smokeRingParams)
      encoder.setFragmentBytes(
        &smokeRingUniforms, length: MemoryLayout<SmokeRingUniformsRaw>.stride, index: 0)
    case .imageDithering:
      var imageDitheringUniforms = ImageDitheringUniformsRaw(params: imageDitheringParams)
      encoder.setFragmentBytes(
        &imageDitheringUniforms, length: MemoryLayout<ImageDitheringUniformsRaw>.stride, index: 0)
    case .halftoneDots:
      var halftoneDotsUniforms = HalftoneDotsUniformsRaw(time: time, params: halftoneDotsParams)
      encoder.setFragmentBytes(
        &halftoneDotsUniforms, length: MemoryLayout<HalftoneDotsUniformsRaw>.stride, index: 0)
    case .halftoneCmyk:
      var halftoneCmykUniforms = HalftoneCmykUniformsRaw(params: halftoneCmykParams)
      encoder.setFragmentBytes(
        &halftoneCmykUniforms, length: MemoryLayout<HalftoneCmykUniformsRaw>.stride, index: 0)
    case .heatmap:
      var heatmapUniforms = HeatmapUniformsRaw(time: time, params: heatmapParams)
      encoder.setFragmentBytes(
        &heatmapUniforms, length: MemoryLayout<HeatmapUniformsRaw>.stride, index: 0)
    case .liquidMetal:
      var liquidMetalUniforms = LiquidMetalUniformsRaw(time: time, params: liquidMetalParams)
      liquidMetalUniforms.u_isImage = imageTexture == nil ? 0 : 1
      encoder.setFragmentBytes(
        &liquidMetalUniforms, length: MemoryLayout<LiquidMetalUniformsRaw>.stride, index: 0)
    case .paperTexture:
      var paperTextureUniforms = PaperTextureUniformsRaw(params: paperTextureParams)
      encoder.setFragmentBytes(
        &paperTextureUniforms, length: MemoryLayout<PaperTextureUniformsRaw>.stride, index: 0)
    case .water:
      var waterUniforms = WaterUniformsRaw(time: time, params: waterParams)
      encoder.setFragmentBytes(
        &waterUniforms, length: MemoryLayout<WaterUniformsRaw>.stride, index: 0)
    case .flutedGlass:
      var flutedGlassUniforms = FlutedGlassUniformsRaw(
        resolution: resolution,
        pixelRatio: pixelRatio,
        rotation: sizingParams.rotation,
        params: flutedGlassParams)
      encoder.setFragmentBytes(
        &flutedGlassUniforms, length: MemoryLayout<FlutedGlassUniformsRaw>.stride, index: 0)
    case .gemSmoke:
      var gemSmokeUniforms = GemSmokeUniformsRaw(time: time, params: gemSmokeParams)
      gemSmokeUniforms.u_isImage = imageTexture == nil ? 0 : 1
      encoder.setFragmentBytes(
        &gemSmokeUniforms, length: MemoryLayout<GemSmokeUniformsRaw>.stride, index: 0)
    }
    encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
    encoder.endEncoding()

    commandBuffer.commit()
    commandBuffer.waitUntilCompleted()

    var raw = [UInt8](repeating: 0, count: width * height * 4)
    let bytesPerRow = width * 4
    texture.getBytes(
      &raw, bytesPerRow: bytesPerRow, from: MTLRegionMake2D(0, 0, width, height), mipmapLevel: 0)
    for i in stride(from: 0, to: raw.count, by: 4) {
      let b = raw[i]
      let g = raw[i + 1]
      let r = raw[i + 2]
      let a = raw[i + 3]
      raw[i] = r
      raw[i + 1] = g
      raw[i + 2] = b
      raw[i + 3] = a
    }

    return (rgba: raw, width: width, height: height)
  }
}

enum RendererError: Error {
  case deviceError
  case shaderError
  case pipelineError(Error)
  case libraryError
  case libraryCompileError(String)
}
