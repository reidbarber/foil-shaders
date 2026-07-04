import CoreGraphics
import Metal
import XCTest

@_spi(Studio) @testable import FoilShaders

final class FoilShadersTests: XCTestCase {
  func testShaderColorParsesHexRGBAndHSL() {
    XCTAssertEqual(ShaderColor("#ff0000" as String)?.rgba, SIMD4<Float>(1, 0, 0, 1))
    XCTAssertEqual(ShaderColor("rgb(0, 255, 0)" as String)?.rgba, SIMD4<Float>(0, 1, 0, 1))
    let blue = ShaderColor("hsl(240 100% 50%)" as String)?.rgba
    XCTAssertEqual(blue?.x ?? -1, 0, accuracy: 0.001)
    XCTAssertEqual(blue?.y ?? -1, 0, accuracy: 0.001)
    XCTAssertEqual(blue?.z ?? -1, 1, accuracy: 0.001)
  }

  func testAllReactExportedShaderComponentsHavePresets() {
    var counts: [Int] = []
    counts.append(AnimatedMeshGradient.presets.count)
    counts.append(SmokeRing.presets.count)
    counts.append(NeuroNoise.presets.count)
    counts.append(DotOrbit.presets.count)
    counts.append(DotGrid.presets.count)
    counts.append(SimplexNoise.presets.count)
    counts.append(Metaballs.presets.count)
    counts.append(Waves.presets.count)
    counts.append(PerlinNoise.presets.count)
    counts.append(Voronoi.presets.count)
    counts.append(Warp.presets.count)
    counts.append(GodRays.presets.count)
    counts.append(Spiral.presets.count)
    counts.append(Swirl.presets.count)
    counts.append(Dithering.presets.count)
    counts.append(GrainGradient.presets.count)
    counts.append(PulsingBorder.presets.count)
    counts.append(ColorPanels.presets.count)
    counts.append(StaticMeshGradient.presets.count)
    counts.append(StaticRadialGradient.presets.count)
    counts.append(PaperTexture.presets.count)
    counts.append(FlutedGlass.presets.count)
    counts.append(Water.presets.count)
    counts.append(ImageDithering.presets.count)
    counts.append(Heatmap.presets.count)
    counts.append(LiquidMetal.presets.count)
    counts.append(HalftoneDots.presets.count)
    counts.append(HalftoneCmyk.presets.count)
    counts.append(GemSmoke.presets.count)
    XCTAssertEqual(
      counts,
      [
        4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
        6, 4, 4, 4, 6, 6, 4, 4, 4, 4,
        4, 4, 4, 4, 2, 4, 4, 4, 4,
      ])
  }

  func testPaperEnumRawValueParity() {
    XCTAssertEqual(DotGridShape.diamond.rawValue, 1)
    XCTAssertEqual(DitheringShape.sphere.rawValue, 7)
    XCTAssertEqual(DitheringType.eightByEight.rawValue, 4)
    XCTAssertEqual(GrainGradientShape.corners.rawValue, 4)
    XCTAssertEqual(HalftoneDotsGrid.hex.rawValue, 1)
    XCTAssertEqual(HalftoneCmykType.ink.rawValue, 1)
    XCTAssertEqual(GlassGridShape.lines.rawValue, 1)
    XCTAssertEqual(GlassDistortionShape.prism.rawValue, 1)
  }

  func testConfigurationGraphConformancesCompile() {
    assertEquatableSendableCodable(ShaderColor.self)
    assertEquatableSendableCodable(ShaderImage.self)
    assertEquatableSendableCodable(ShaderRenderOptions.self)
    assertEquatableSendableCodable(ShaderSizingParams.self)
    assertEquatableSendableCodable(ShaderMotionParams.self)
    assertEquatableSendableCodable(ShaderParameters.self)
    assertEquatableSendableCodable(ShaderConfiguration.self)
    assertEquatableSendableCodable(ShaderPreset<MeshGradientParams>.self)

    assertEquatableSendableCodable(MeshGradientParams.self)
    assertEquatableSendableCodable(StaticMeshGradientParams.self)
    assertEquatableSendableCodable(StaticRadialGradientParams.self)
    assertEquatableSendableCodable(SwirlParams.self)
    assertEquatableSendableCodable(SpiralParams.self)
    assertEquatableSendableCodable(DotGridParams.self)
    assertEquatableSendableCodable(SimplexNoiseParams.self)
    assertEquatableSendableCodable(PerlinNoiseParams.self)
    assertEquatableSendableCodable(NeuroNoiseParams.self)
    assertEquatableSendableCodable(WavesParams.self)
    assertEquatableSendableCodable(DitheringParams.self)
    assertEquatableSendableCodable(ColorPanelsParams.self)
    assertEquatableSendableCodable(DotOrbitParams.self)
    assertEquatableSendableCodable(GodRaysParams.self)
    assertEquatableSendableCodable(GrainGradientParams.self)
    assertEquatableSendableCodable(MetaballsParams.self)
    assertEquatableSendableCodable(WarpParams.self)
    assertEquatableSendableCodable(VoronoiParams.self)
    assertEquatableSendableCodable(PulsingBorderParams.self)
    assertEquatableSendableCodable(SmokeRingParams.self)
    assertEquatableSendableCodable(ImageDitheringParams.self)
    assertEquatableSendableCodable(HalftoneDotsParams.self)
    assertEquatableSendableCodable(HalftoneCmykParams.self)
    assertEquatableSendableCodable(HeatmapParams.self)
    assertEquatableSendableCodable(LiquidMetalParams.self)
    assertEquatableSendableCodable(PaperTextureParams.self)
    assertEquatableSendableCodable(WaterParams.self)
    assertEquatableSendableCodable(FlutedGlassParams.self)
    assertEquatableSendableCodable(GemSmokeParams.self)
  }

  func testShaderConfigurationCodableRoundTrip() throws {
    let configuration = ShaderConfiguration(
      parameters: .meshGradient(MeshGradientPreset.default.params),
      sizing: MeshGradientPreset.default.sizing,
      motion: ShaderMotionParams(speed: 0.25, frame: 12),
      renderOptions: ShaderRenderOptions(width: 320, height: 180),
      image: .url(URL(fileURLWithPath: "/tmp/source.png"))
    )

    let data = try JSONEncoder().encode(configuration)
    let decoded = try JSONDecoder().decode(ShaderConfiguration.self, from: data)

    XCTAssertEqual(decoded, configuration)
  }

  func testShaderConfigurationRejectsRawCGImageEncoding() throws {
    let image = try Self.makeTopDarkBottomLightImage(width: 8, height: 8)
    let configuration = ShaderConfiguration(
      parameters: .heatmap(
        HeatmapParams(colorBack: .black, colors: [.white], contour: 0, innerGlow: 1, outerGlow: 0)
      ),
      image: .cgImage(image)
    )

    XCTAssertThrowsError(try JSONEncoder().encode(configuration)) { error in
      guard case EncodingError.invalidValue = error else {
        return XCTFail("Expected EncodingError.invalidValue, got \(error)")
      }
    }
  }

  func testShaderImageCGImageEqualityUsesPixelFingerprint() throws {
    let imageA = try Self.makeTopDarkBottomLightImage(width: 8, height: 8)
    let imageB = try Self.makeTopDarkBottomLightImage(width: 8, height: 8)

    XCTAssertFalse(imageA === imageB)
    XCTAssertEqual(ShaderImage.cgImage(imageA), .cgImage(imageB))
  }

  func testShaderImageCGImageEqualityDetectsDifferentPixels() throws {
    let imageA = try Self.makeTopDarkBottomLightImage(width: 8, height: 8)
    let imageB = try Self.makeTwoToneImage(width: 8, height: 8, topValue: 255, bottomValue: 0)

    XCTAssertNotEqual(ShaderImage.cgImage(imageA), .cgImage(imageB))
  }

  func testShaderImageURLCodableRoundTrip() throws {
    let image = ShaderImage.url(URL(fileURLWithPath: "/tmp/source.png"))

    let data = try JSONEncoder().encode(image)
    let decoded = try JSONDecoder().decode(ShaderImage.self, from: data)

    XCTAssertEqual(decoded, image)
  }

  func testShaderImageBundledResourceCodableRoundTrip() throws {
    let image = ShaderImage.bundledResource(
      name: "fixture",
      extension: "png",
      bundle: Bundle(for: FoilShadersTests.self)
    )

    let data = try JSONEncoder().encode(image)
    let decoded = try JSONDecoder().decode(ShaderImage.self, from: data)

    XCTAssertEqual(decoded, image)
  }

  func testShaderImageDecodesLegacyRemoteURLAsURL() throws {
    let data = """
      {"type":"remoteURL","url":"https://example.com/source.png"}
      """.data(using: .utf8)!

    let decoded = try JSONDecoder().decode(ShaderImage.self, from: data)
    let reencoded = try JSONEncoder().encode(decoded)
    let payload = try JSONSerialization.jsonObject(with: reencoded) as? [String: Any]

    XCTAssertEqual(decoded, .url(URL(string: "https://example.com/source.png")!))
    XCTAssertEqual(payload?["type"] as? String, "url")
  }

  func testPaperDefaultPresetValues() {
    XCTAssertEqual(MeshGradientPreset.default.name, "Default")
    XCTAssertEqual(MeshGradientPreset.default.params.colors.count, 4)
    XCTAssertEqual(MeshGradientPreset.default.params.distortion, 0.8, accuracy: 0.0001)
    XCTAssertEqual(MeshGradientPreset.default.params.swirl, 0.1, accuracy: 0.0001)
    XCTAssertEqual(MeshGradientPreset.default.motion.speed, 1, accuracy: 0.0001)
    XCTAssertEqual(MeshGradientPreset.default.sizing.fit, .contain)

    XCTAssertEqual(DotGridPreset.default.params.dotSize, 2, accuracy: 0.0001)
    XCTAssertEqual(DotGridPreset.default.params.shape, .circle)
    XCTAssertEqual(DotGridPreset.default.renderOptions.maxPixelCount, 6016 * 3384)

    XCTAssertEqual(ImageDitheringPreset.default.params.type, .eightByEight)
    XCTAssertEqual(ImageDitheringPreset.default.params.inverted, 0)
    XCTAssertEqual(LiquidMetalPreset.default.params.shape, .diamond)
    XCTAssertEqual(GemSmokePreset.default.params.shape, .diamond)
  }

  @MainActor
  func testParamsInitializersDefaultToComponentPresetConfiguration() {
    let meshColors: [ShaderColor] = ["#5100ff", "#00ff80", "#ffcc00", "#ea00ff"]
    XCTAssertEqual(
      AnimatedMeshGradient(params: MeshGradientParams(colors: meshColors)).configuration,
      AnimatedMeshGradient(colors: meshColors).configuration
    )

    let configurations: [(String, ShaderConfiguration, ShaderConfiguration)] = [
      (
        "AnimatedMeshGradient",
        AnimatedMeshGradient(params: MeshGradientPreset.default.params).configuration,
        AnimatedMeshGradient(MeshGradientPreset.default).configuration
      ),
      (
        "SmokeRing",
        SmokeRing(params: SmokeRingPreset.default.params).configuration,
        SmokeRing(SmokeRingPreset.default).configuration
      ),
      (
        "NeuroNoise",
        NeuroNoise(params: NeuroNoisePreset.default.params).configuration,
        NeuroNoise(NeuroNoisePreset.default).configuration
      ),
      (
        "DotOrbit",
        DotOrbit(params: DotOrbitPreset.default.params).configuration,
        DotOrbit(DotOrbitPreset.default).configuration
      ),
      (
        "DotGrid",
        DotGrid(params: DotGridPreset.default.params).configuration,
        DotGrid(DotGridPreset.default).configuration
      ),
      (
        "SimplexNoise",
        SimplexNoise(params: SimplexNoisePreset.default.params).configuration,
        SimplexNoise(SimplexNoisePreset.default).configuration
      ),
      (
        "Metaballs",
        Metaballs(params: MetaballsPreset.default.params).configuration,
        Metaballs(MetaballsPreset.default).configuration
      ),
      (
        "Waves",
        Waves(params: WavesPreset.default.params).configuration,
        Waves(WavesPreset.default).configuration
      ),
      (
        "PerlinNoise",
        PerlinNoise(params: PerlinNoisePreset.default.params).configuration,
        PerlinNoise(PerlinNoisePreset.default).configuration
      ),
      (
        "Voronoi",
        Voronoi(params: VoronoiPreset.default.params).configuration,
        Voronoi(VoronoiPreset.default).configuration
      ),
      (
        "Warp",
        Warp(params: WarpPreset.default.params).configuration,
        Warp(WarpPreset.default).configuration
      ),
      (
        "GodRays",
        GodRays(params: GodRaysPreset.default.params).configuration,
        GodRays(GodRaysPreset.default).configuration
      ),
      (
        "Spiral",
        Spiral(params: SpiralPreset.default.params).configuration,
        Spiral(SpiralPreset.default).configuration
      ),
      (
        "Swirl",
        Swirl(params: SwirlPreset.default.params).configuration,
        Swirl(SwirlPreset.default).configuration
      ),
      (
        "Dithering",
        Dithering(params: DitheringPreset.default.params).configuration,
        Dithering(DitheringPreset.default).configuration
      ),
      (
        "GrainGradient",
        GrainGradient(params: GrainGradientPreset.default.params).configuration,
        GrainGradient(GrainGradientPreset.default).configuration
      ),
      (
        "PulsingBorder",
        PulsingBorder(params: PulsingBorderPreset.default.params).configuration,
        PulsingBorder(PulsingBorderPreset.default).configuration
      ),
      (
        "ColorPanels",
        ColorPanels(params: ColorPanelsPreset.default.params).configuration,
        ColorPanels(ColorPanelsPreset.default).configuration
      ),
      (
        "StaticMeshGradient",
        StaticMeshGradient(params: StaticMeshGradientPreset.default.params).configuration,
        StaticMeshGradient(StaticMeshGradientPreset.default).configuration
      ),
      (
        "StaticRadialGradient",
        StaticRadialGradient(params: StaticRadialGradientPreset.default.params).configuration,
        StaticRadialGradient(StaticRadialGradientPreset.default).configuration
      ),
      (
        "PaperTexture",
        PaperTexture(params: PaperTexturePreset.default.params).configuration,
        PaperTexture(PaperTexturePreset.default).configuration
      ),
      (
        "FlutedGlass",
        FlutedGlass(params: FlutedGlassPreset.default.params).configuration,
        FlutedGlass(FlutedGlassPreset.default).configuration
      ),
      (
        "Water",
        Water(params: WaterPreset.default.params).configuration,
        Water(WaterPreset.default).configuration
      ),
      (
        "ImageDithering",
        ImageDithering(params: ImageDitheringPreset.default.params).configuration,
        ImageDithering(ImageDitheringPreset.default).configuration
      ),
      (
        "Heatmap",
        Heatmap(params: HeatmapPreset.default.params).configuration,
        Heatmap(HeatmapPreset.default).configuration
      ),
      (
        "LiquidMetal",
        LiquidMetal(params: LiquidMetalPreset.default.params).configuration,
        LiquidMetal(LiquidMetalPreset.default).configuration
      ),
      (
        "HalftoneDots",
        HalftoneDots(params: HalftoneDotsPreset.default.params).configuration,
        HalftoneDots(HalftoneDotsPreset.default).configuration
      ),
      (
        "HalftoneCmyk",
        HalftoneCmyk(params: HalftoneCmykPreset.default.params).configuration,
        HalftoneCmyk(HalftoneCmykPreset.default).configuration
      ),
      (
        "GemSmoke",
        GemSmoke(params: GemSmokePreset.default.params).configuration,
        GemSmoke(GemSmokePreset.default).configuration
      ),
    ]

    XCTAssertEqual(configurations.count, 29)
    for (name, paramsConfiguration, presetConfiguration) in configurations {
      XCTAssertEqual(paramsConfiguration, presetConfiguration, name)
    }
  }

  func testNamedPresetMembersPreserveComponentPresetOrder() {
    XCTAssertEqual(SwirlPreset.candy.name, "Candy")
    XCTAssertEqual(SwirlPreset.preset007.name, "007")
    XCTAssertEqual(StaticMeshGradientPreset.preset1960s.name, "1960s")
    XCTAssertEqual(HalftoneDotsPreset.ledScreen.name, "LED screen")

    XCTAssertEqual(
      Swirl.presets,
      [SwirlPreset.default, SwirlPreset.preset007, SwirlPreset.opening, SwirlPreset.candy])
    XCTAssertEqual(
      StaticMeshGradient.presets,
      [
        StaticMeshGradientPreset.default, StaticMeshGradientPreset.preset1960s,
        StaticMeshGradientPreset.sunset, StaticMeshGradientPreset.sea,
      ])
    XCTAssertEqual(
      HalftoneDots.presets,
      [
        HalftoneDotsPreset.default, HalftoneDotsPreset.ledScreen, HalftoneDotsPreset.mosaic,
        HalftoneDotsPreset.roundAndSquare,
      ])
  }

  @MainActor
  func testFlatInitializersAcceptShaderColorLiterals() {
    let configurations: [ShaderConfiguration] = [
      AnimatedMeshGradient(colors: ["#5100ff", "#00ff80", "#ffcc00", "#ea00ff"]).configuration,
      SmokeRing(colorBack: "#000000", colors: ["#ffffff"]).configuration,
      NeuroNoise(colorFront: "#ffffff", colorMid: "#47a6ff", colorBack: "#000000").configuration,
      DotOrbit(colorBack: "#000000", colors: ["#ffffff"]).configuration,
      DotGrid(colorBack: "#000000", colorFill: "#ffffff", colorStroke: "#ffaa00", shape: .circle)
        .configuration,
      SimplexNoise(colors: ["#4449cf", "#ffd1e0", "#f94446"]).configuration,
      Metaballs(colorBack: "#000000", colors: ["#7300ff", "#eba8ff"]).configuration,
      Waves(colorFront: "#ffbb00", colorBack: "#000000").configuration,
      PerlinNoise(colorFront: "#79d1ff", colorBack: "#001429").configuration,
      Voronoi(colors: ["#ff8247", "#ffe53d"], colorGap: "#2e0000", colorGlow: "#ffffff")
        .configuration,
      Warp(colors: ["#121212", "#9470ff"], shape: .checks).configuration,
      GodRays(colorBack: "#000000", colorBloom: "#0000ff", colors: ["#ffffff"]).configuration,
      Spiral(colorBack: "#001429", colorFront: "#79d1ff").configuration,
      Swirl(colorBack: "#330000", colors: ["#ffd1d1", "#ff8a8a"]).configuration,
      Dithering(colorBack: "#000000", colorFront: "#00b2ff", shape: .sphere, type: .fourByFour)
        .configuration,
      GrainGradient(colorBack: "#000000", colors: ["#7300ff", "#eba8ff"], shape: .corners)
        .configuration,
      PulsingBorder(colorBack: "#000000", colors: ["#0dc1fd"], aspectRatio: .auto).configuration,
      ColorPanels(colors: ["#ff9d00", "#fd4f30"], colorBack: "#000000").configuration,
      StaticMeshGradient(colors: ["#ffad0a", "#6200ff"]).configuration,
      StaticRadialGradient(colorBack: "#000000", colors: ["#00bbff", "#00ffe1"]).configuration,
      PaperTexture(colorFront: "#9fadbc", colorBack: "#ffffff").configuration,
      FlutedGlass(
        colorBack: "#00000000", colorShadow: "#000000", colorHighlight: "#ffffff",
        distortionShape: .prism, shape: .lines
      ).configuration,
      Water(colorBack: "#909090", colorHighlight: "#ffffff").configuration,
      ImageDithering(
        colorFront: "#94ffaf", colorBack: "#000c38", colorHighlight: "#eaff94",
        type: .eightByEight
      ).configuration,
      Heatmap(colorBack: "#000000", colors: ["#11206a", "#1f3ba2"]).configuration,
      LiquidMetal(colorBack: "#aaaaac", colorTint: "#ffffff", shape: .diamond).configuration,
      HalftoneDots(colorFront: "#2b2b2b", colorBack: "#f2f1e8", grid: .hex, type: .gooey)
        .configuration,
      HalftoneCmyk(
        colorBack: "#fbfaf5", colorC: "#00b4ff", colorM: "#fc519f", colorY: "#ffd800",
        colorK: "#231f20", type: .ink
      ).configuration,
      GemSmoke(colors: ["#333333", "#e7e6df"], colorBack: "#f0efea", colorInner: "#fafaf5")
        .configuration,
    ]

    XCTAssertEqual(configurations.count, 29)
  }

  func testCodeGeneratorUsesAnimatedMeshGradient() {
    let code = FoilShadersCodeGenerator.swiftUICode(
      componentName: "MeshGradient",
      presetReference: "MeshGradientPreset.default",
      sizing: .defaultPatternSizing,
      motion: ShaderMotionParams(speed: 0.2, frame: 0),
      renderOptions: ShaderRenderOptions(width: 1280, height: 720)
    )
    XCTAssertTrue(code.contains("\nAnimatedMeshGradient(\n"))
    XCTAssertTrue(code.contains("params: MeshGradientPreset.default.params"))
  }

  func testCodeGeneratorLeavesPulsingBorderUnqualified() {
    let code = FoilShadersCodeGenerator.swiftUICode(
      componentName: "PulsingBorder",
      presetReference: "PulsingBorderPreset.default",
      sizing: .defaultPatternSizing,
      motion: ShaderMotionParams(speed: 0.2, frame: 0),
      renderOptions: ShaderRenderOptions(width: 1280, height: 720)
    )
    XCTAssertTrue(code.contains("\nPulsingBorder(\n"))
    XCTAssertFalse(code.contains("FoilShaders.PulsingBorder"))
    XCTAssertTrue(code.contains("params: PulsingBorderPreset.default.params"))
  }

  @MainActor
  func testMetalPipelinesCompile() throws {
    guard let device = MTLCreateSystemDefaultDevice() else {
      throw XCTSkip("Metal is not available")
    }
    let renderer = try FoilShadersRenderer(device: device)
    for shader in FoilShadersRenderer.ShaderKind.allCases {
      XCTAssertNoThrow(try renderer.configure(shader), "Failed to configure \(shader)")
    }
  }

  @MainActor
  func testDefaultMetalContextSharesReusableResources() throws {
    guard MTLCreateSystemDefaultDevice() != nil else {
      throw XCTSkip("Metal is not available")
    }

    let first = try FoilShadersMetalContext.sharedDefault()
    let second = try FoilShadersMetalContext.sharedDefault()
    XCTAssertTrue(first === second)
    XCTAssertEqual(
      ObjectIdentifier(first.device as AnyObject),
      ObjectIdentifier(second.device as AnyObject)
    )
    XCTAssertEqual(
      ObjectIdentifier(first.commandQueue as AnyObject),
      ObjectIdentifier(second.commandQueue as AnyObject)
    )
    let firstNoiseTexture = try XCTUnwrap(first.noiseTexture)
    let secondNoiseTexture = try XCTUnwrap(second.noiseTexture)
    XCTAssertEqual(
      ObjectIdentifier(firstNoiseTexture as AnyObject),
      ObjectIdentifier(secondNoiseTexture as AnyObject)
    )
  }

  @MainActor
  func testHeatmapImageRenderingPreservesSourceOrientation() throws {
    guard let device = MTLCreateSystemDefaultDevice() else {
      throw XCTSkip("Metal is not available")
    }

    let image = try Self.makeTopDarkBottomLightImage(width: 32, height: 32)
    let renderer = try FoilShadersRenderer(device: device)
    try renderer.configure(.heatmap)
    renderer.apply(
      ShaderConfiguration(
        parameters: .heatmap(
          HeatmapParams(
            colorBack: .black,
            colors: [.white],
            contour: 0,
            angle: 0,
            noise: 0,
            innerGlow: 1,
            outerGlow: 0
          )
        ),
        sizing: ShaderSizingParams(fit: .contain),
        motion: ShaderMotionParams(speed: 0, frame: 0),
        image: .cgImage(image)
      )
    )
    guard let capture = renderer.capturePixels(width: 96, height: 96, pixelRatio: 1) else {
      return XCTFail("Expected heatmap capture")
    }

    let sampleX = (capture.width / 3)..<(2 * capture.width / 3)
    let topSampleY = (capture.height / 4)..<(capture.height / 2)
    let bottomSampleY = (capture.height / 2)..<(3 * capture.height / 4)
    let topLuminance = Self.averageLuminance(
      capture.rgba, width: capture.width, xRange: sampleX, yRange: topSampleY)
    let bottomLuminance = Self.averageLuminance(
      capture.rgba, width: capture.width, xRange: sampleX, yRange: bottomSampleY)

    XCTAssertGreaterThan(
      topLuminance,
      bottomLuminance + 25,
      "The dark top half of the source image should render as the brighter heatmap region.")
  }

  private static func makeTopDarkBottomLightImage(width: Int, height: Int) throws -> CGImage {
    try makeTwoToneImage(width: width, height: height, topValue: 0, bottomValue: 255)
  }

  private static func makeTwoToneImage(
    width: Int, height: Int, topValue: UInt8, bottomValue: UInt8
  ) throws -> CGImage {
    var rgba = [UInt8](repeating: 255, count: width * height * 4)
    for y in 0..<height {
      for x in 0..<width {
        let base = (y * width + x) * 4
        let value = y < height / 2 ? topValue : bottomValue
        rgba[base] = value
        rgba[base + 1] = value
        rgba[base + 2] = value
        rgba[base + 3] = 255
      }
    }

    guard let provider = CGDataProvider(data: Data(rgba) as CFData) else {
      throw TestImageError.providerCreationFailed
    }
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
      .union(.byteOrder32Big)
    guard
      let image = CGImage(
        width: width,
        height: height,
        bitsPerComponent: 8,
        bitsPerPixel: 32,
        bytesPerRow: width * 4,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: bitmapInfo,
        provider: provider,
        decode: nil,
        shouldInterpolate: false,
        intent: .defaultIntent
      )
    else {
      throw TestImageError.imageCreationFailed
    }
    return image
  }

  private static func averageLuminance(
    _ rgba: [UInt8], width: Int, xRange: Range<Int>, yRange: Range<Int>
  ) -> Double {
    var total = 0.0
    var count = 0
    for y in yRange {
      for x in xRange {
        let base = (y * width + x) * 4
        total +=
          Double(rgba[base]) * 0.2126
          + Double(rgba[base + 1]) * 0.7152
          + Double(rgba[base + 2]) * 0.0722
        count += 1
      }
    }
    return total / Double(max(count, 1))
  }

  private func assertEquatableSendableCodable<T: Equatable & Sendable & Codable>(
    _: T.Type,
    file: StaticString = #filePath,
    line: UInt = #line
  ) {}

  private enum TestImageError: Error {
    case providerCreationFailed
    case imageCreationFailed
  }
}
