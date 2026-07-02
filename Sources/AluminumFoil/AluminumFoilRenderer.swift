import CoreGraphics
import Foundation
import Metal
import MetalKit

// MARK: - AluminumFoilRenderer

public class AluminumFoilRenderer: NSObject, MTKViewDelegate {
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
  private var fallbackImageTexture: MTLTexture?
  private var fallbackNoiseTexture: MTLTexture?
  private var imageAspectRatio: Float = 1.0

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
    let bundles = [Bundle.module, Bundle.main]
    for bundle in bundles {
      if let url = bundle.url(forResource: "noise-texture", withExtension: "png") {
        noiseTexture = try? textureLoader.newTexture(
          URL: url,
          options: [
            MTKTextureLoader.Option.SRGB: false
          ]
        )
        break
      }
    }
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

  public func setImage(_ image: CGImage?) {
    guard let image else {
      imageTexture = nil
      imageAspectRatio = 1.0
      return
    }
    imageTexture = try? textureLoader.newTexture(
      cgImage: image,
      options: [
        MTKTextureLoader.Option.SRGB: false
      ]
    )
    imageAspectRatio = Float(image.width) / max(1.0, Float(image.height))
  }

  public func setImage(_ shaderImage: ShaderImage?) {
    guard let shaderImage else {
      setImage(nil as CGImage?)
      return
    }
    switch shaderImage {
    case .cgImage(let image):
      setImage(image)
    case .url(let url), .remoteURL(let url):
      setImage(AluminumFoilDefaultImageLoader.loadCGImage(from: url))
    case .bundleResource(let name, let fileExtension, let bundle):
      let url = bundle.url(forResource: name, withExtension: fileExtension)
      setImage(url.flatMap(AluminumFoilDefaultImageLoader.loadCGImage(from:)))
    }
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
    self.mtkView = view
    view.delegate = self
    view.device = device
    view.colorPixelFormat = .bgra8Unorm
    view.enableSetNeedsDisplay = false
    view.isPaused = false
    view.framebufferOnly = true
    view.preferredFramesPerSecond = 60
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
    setImage(configuration.image)
    setFrame(configuration.motion.frame)
    setSpeed(configuration.motion.speed)
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
    mtkView?.enableSetNeedsDisplay = isStatic
    mtkView?.isPaused = isStatic
    if wasStatic && !isStatic {
      lastRenderTime = CACurrentMediaTime()
    }
    if isStatic {
      mtkView?.setNeedsDisplay(mtkView?.bounds ?? .zero)
    }
  }

  public func setFrame(_ frame: Float) {
    self.currentFrame = frame
    self.lastRenderTime = CACurrentMediaTime()
  }

  public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    let scale = Float(view.layer?.contentsScale ?? 1.0)
    resolution = SIMD2<Float>(Float(size.width), Float(size.height))
    pixelRatio = scale
    if speed == 0.0 {
      view.setNeedsDisplay(view.bounds)
    }
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
      u_imageAspectRatio: imageAspectRatio,
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
    renderEncoder.setFragmentTexture(imageTexture ?? fallbackImageTexture, index: 0)
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
    guard let pipelineState = pipelineState,
      let vertexBuffer = vertexBuffer
    else {
      return nil
    }
    let width = Int(resolution.x)
    let height = Int(resolution.y)
    if width <= 0 || height <= 0 { return nil }

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
      u_imageAspectRatio: imageAspectRatio,
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
    encoder.setFragmentTexture(imageTexture ?? fallbackImageTexture, index: 0)
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

    guard let provider = CGDataProvider(data: Data(raw) as CFData) else { return nil }
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
      .union(.byteOrder32Big)
    return CGImage(
      width: width,
      height: height,
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
}

enum RendererError: Error {
  case deviceError
  case shaderError
  case pipelineError(Error)
  case libraryError
  case libraryCompileError(String)
}
