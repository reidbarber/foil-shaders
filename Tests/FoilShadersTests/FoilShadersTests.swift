import CoreGraphics
import Foundation
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
    counts.append(HalftoneCMYK.presets.count)
    counts.append(GemSmoke.presets.count)
    XCTAssertEqual(
      counts,
      [
        4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
        6, 4, 4, 4, 6, 6, 4, 4, 4, 4,
        4, 4, 4, 4, 2, 4, 4, 4, 4,
      ])
  }

  func testShaderEnumRawValuesRemainStablePersistedValues() {
    XCTAssertEqual(DotGridShape.allCases.map(\.rawValue), [0, 1, 2, 3])
    XCTAssertEqual(DitheringShape.allCases.map(\.rawValue), [1, 2, 3, 4, 5, 6, 7])
    XCTAssertEqual(DitheringType.allCases.map(\.rawValue), [1, 2, 3, 4])
    XCTAssertEqual(WarpPattern.allCases.map(\.rawValue), [0, 1, 2])
    XCTAssertEqual(GrainGradientShape.allCases.map(\.rawValue), [1, 2, 3, 4, 5, 6, 7])
    XCTAssertEqual(PulsingBorderAspectRatio.allCases.map(\.rawValue), [0, 1])
    XCTAssertEqual(HalftoneDotsType.allCases.map(\.rawValue), [0, 1, 2, 3])
    XCTAssertEqual(HalftoneDotsGrid.allCases.map(\.rawValue), [0, 1])
    XCTAssertEqual(HalftoneCMYKType.allCases.map(\.rawValue), [0, 1, 2])
    XCTAssertEqual(LiquidMetalShape.allCases.map(\.rawValue), [0, 1, 2, 3, 4])
    XCTAssertEqual(GlassGridShape.allCases.map(\.rawValue), [1, 2, 3, 4, 5])
    XCTAssertEqual(GlassDistortionShape.allCases.map(\.rawValue), [1, 2, 3, 4, 5])
    XCTAssertEqual(GemSmokeShape.allCases.map(\.rawValue), [0, 1, 2, 3, 4])
  }

  func testConfigurationGraphConformancesCompile() {
    assertHashableSendableCodable(ShaderColor.self)
    assertHashableSendableCodable(ShaderImage.self)
    assertHashableSendableCodable(ShaderRenderOptions.self)
    assertHashableSendableCodable(ShaderSizingParams.self)
    assertHashableSendableCodable(ShaderMotionParams.self)
    assertHashableSendableCodable(ShaderParameters.self)
    assertHashableSendableCodable(ShaderConfiguration.self)
    assertHashableSendableCodable(ShaderPreset<AnimatedMeshGradientParams>.self)

    assertHashableSendableCodable(AnimatedMeshGradientParams.self)
    assertHashableSendableCodable(StaticMeshGradientParams.self)
    assertHashableSendableCodable(StaticRadialGradientParams.self)
    assertHashableSendableCodable(SwirlParams.self)
    assertHashableSendableCodable(SpiralParams.self)
    assertHashableSendableCodable(DotGridParams.self)
    assertHashableSendableCodable(SimplexNoiseParams.self)
    assertHashableSendableCodable(PerlinNoiseParams.self)
    assertHashableSendableCodable(NeuroNoiseParams.self)
    assertHashableSendableCodable(WavesParams.self)
    assertHashableSendableCodable(DitheringParams.self)
    assertHashableSendableCodable(ColorPanelsParams.self)
    assertHashableSendableCodable(DotOrbitParams.self)
    assertHashableSendableCodable(GodRaysParams.self)
    assertHashableSendableCodable(GrainGradientParams.self)
    assertHashableSendableCodable(MetaballsParams.self)
    assertHashableSendableCodable(WarpParams.self)
    assertHashableSendableCodable(VoronoiParams.self)
    assertHashableSendableCodable(PulsingBorderParams.self)
    assertHashableSendableCodable(SmokeRingParams.self)
    assertHashableSendableCodable(ImageDitheringParams.self)
    assertHashableSendableCodable(HalftoneDotsParams.self)
    assertHashableSendableCodable(HalftoneCMYKParams.self)
    assertHashableSendableCodable(HeatmapParams.self)
    assertHashableSendableCodable(LiquidMetalParams.self)
    assertHashableSendableCodable(PaperTextureParams.self)
    assertHashableSendableCodable(WaterParams.self)
    assertHashableSendableCodable(FlutedGlassParams.self)
    assertHashableSendableCodable(GemSmokeParams.self)
  }

  func testShaderSizingExplicitDefaultNames() {
    XCTAssertEqual(ShaderSizingParams.defaultObjectSizing.fit, .contain)
    XCTAssertEqual(ShaderSizingParams.defaultPatternSizing.fit, .none)
  }

  func testShaderConfigurationCodableRoundTrip() throws {
    let configuration = ShaderConfiguration(
      parameters: .animatedMeshGradient(AnimatedMeshGradientPreset.default.params),
      sizing: AnimatedMeshGradientPreset.default.sizing,
      motion: ShaderMotionParams(speed: 0.25, frame: 12),
      renderOptions: ShaderRenderOptions(minPixelRatio: 1.5, maxPixelCount: 320 * 180),
      image: .url(URL(fileURLWithPath: "/tmp/source.png"))
    )

    let data = try JSONEncoder().encode(configuration)
    let decoded = try JSONDecoder().decode(ShaderConfiguration.self, from: data)

    XCTAssertEqual(decoded, configuration)
  }

  func testUniformColorCountClampsDecodedOverflowingColorArrays() throws {
    let colorJSON = (0..<(AnimatedMeshGradientParams.maxColorCount + 2)).map { index in
      "{\"alpha\":1,\"blue\":0,\"green\":0,\"red\":\(Float(index) / 20)}"
    }.joined(separator: ",")
    let paramsJSON = """
      {
        "colors": [\(colorJSON)],
        "distortion": 0.8,
        "grainMixer": 0,
        "grainOverlay": 0,
        "swirl": 0.1
      }
      """

    let params = try JSONDecoder().decode(
      AnimatedMeshGradientParams.self, from: Data(paramsJSON.utf8))
    let uniforms = MeshGradientUniformsRaw(time: 0, params: params)

    XCTAssertGreaterThan(params.colors.count, AnimatedMeshGradientParams.maxColorCount)
    XCTAssertEqual(uniforms.u_colorsCount, Float(AnimatedMeshGradientParams.maxColorCount))
  }

  func testShaderParametersCodableFixture() throws {
    let fixtureData = try Self.loadFixture(named: "shader-parameters-dot-grid")
    let expected = Self.fixtureShaderParameters

    let decoded = try JSONDecoder().decode(ShaderParameters.self, from: fixtureData)
    let encoded = try Self.fixtureJSONEncoder.encode(expected)

    XCTAssertEqual(decoded, expected)
    XCTAssertEqual(try Self.canonicalJSONString(encoded), try Self.canonicalJSONString(fixtureData))
    XCTAssertFalse(String(decoding: encoded, as: UTF8.self).contains(#""_0""#))
  }

  func testShaderConfigurationCodableFixture() throws {
    let fixtureData = try Self.loadFixture(named: "shader-configuration-dot-grid")
    let expected = Self.fixtureShaderConfiguration

    let decoded = try JSONDecoder().decode(ShaderConfiguration.self, from: fixtureData)
    let encoded = try Self.fixtureJSONEncoder.encode(expected)

    XCTAssertEqual(decoded, expected)
    XCTAssertEqual(try Self.canonicalJSONString(encoded), try Self.canonicalJSONString(fixtureData))
    XCTAssertFalse(String(decoding: encoded, as: UTF8.self).contains(#""_0""#))
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

  func testShaderImageCGImageHashingUsesPixelFingerprint() throws {
    let imageA = try Self.makeTopDarkBottomLightImage(width: 8, height: 8)
    let imageB = try Self.makeTopDarkBottomLightImage(width: 8, height: 8)

    let images: Set<ShaderImage> = [ShaderImage.cgImage(imageA), .cgImage(imageB)]

    XCTAssertEqual(images.count, 1)
  }

  func testShaderImageCGImageFactoryCachesFingerprintForSameInstance() throws {
    let image = try Self.makeTopDarkBottomLightImage(width: 8, height: 8)

    ShaderImage._resetCGImageFingerprintCacheForTesting()

    _ = ShaderImage.cgImage(image)
    let afterFirstConstruction = ShaderImage._cgImageFingerprintCacheStatsForTesting
    XCTAssertEqual(afterFirstConstruction.misses, 1)
    XCTAssertEqual(afterFirstConstruction.hits, 0)

    _ = ShaderImage.cgImage(image)
    let afterSecondConstruction = ShaderImage._cgImageFingerprintCacheStatsForTesting
    XCTAssertEqual(afterSecondConstruction.misses, 1)
    XCTAssertEqual(afterSecondConstruction.hits, 1)
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

  func testShaderImageBundledResourceHashingMatchesEquality() {
    let bundle = Bundle(for: FoilShadersTests.self)
    let imageA = ShaderImage.bundledResource(name: "fixture", extension: "png", bundle: bundle)
    let imageB = ShaderImage.bundledResource(name: "fixture", extension: "png", bundle: bundle)

    let images: Set<ShaderImage> = [imageA, imageB]

    XCTAssertEqual(imageA, imageB)
    XCTAssertEqual(images.count, 1)
  }

  func testShaderImageBundledResourceDecodeUsesBundleURLWhenIdentifierCannotResolve() throws {
    let bundle = Bundle(for: FoilShadersTests.self)
    let data = try JSONSerialization.data(
      withJSONObject: [
        "type": "bundleResource",
        "name": "fixture",
        "fileExtension": "png",
        "bundleIdentifier": "com.example.definitely-missing",
        "bundleURL": bundle.bundleURL.absoluteString,
      ])

    let decoded = try JSONDecoder().decode(ShaderImage.self, from: data)

    XCTAssertEqual(
      decoded,
      .bundledResource(name: "fixture", extension: "png", bundle: bundle)
    )
  }

  func testShaderImageBundledResourceDecodeThrowsWhenBundleCannotResolve() throws {
    let missingBundleURL = FileManager.default.temporaryDirectory
      .appendingPathComponent("foil-shaders-missing-\(UUID().uuidString)")
      .appendingPathExtension("bundle")
    let data = try JSONSerialization.data(
      withJSONObject: [
        "type": "bundleResource",
        "name": "fixture",
        "fileExtension": "png",
        "bundleIdentifier": "com.example.definitely-missing",
        "bundleURL": missingBundleURL.absoluteString,
      ])

    XCTAssertThrowsError(try JSONDecoder().decode(ShaderImage.self, from: data)) { error in
      guard case DecodingError.dataCorrupted(let context) = error else {
        return XCTFail("Expected DecodingError.dataCorrupted, got \(error)")
      }

      XCTAssertTrue(
        context.debugDescription.contains("Unable to resolve ShaderImage bundled resource bundle")
      )
      XCTAssertTrue(context.debugDescription.contains("com.example.definitely-missing"))
      XCTAssertTrue(context.debugDescription.contains(missingBundleURL.absoluteString))
    }
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
    XCTAssertEqual(AnimatedMeshGradientPreset.default.name, "Default")
    XCTAssertEqual(AnimatedMeshGradientPreset.default.params.colors.count, 4)
    XCTAssertEqual(AnimatedMeshGradientPreset.default.params.distortion, 0.8, accuracy: 0.0001)
    XCTAssertEqual(AnimatedMeshGradientPreset.default.params.swirl, 0.1, accuracy: 0.0001)
    XCTAssertEqual(AnimatedMeshGradientPreset.default.motion.speed, 1, accuracy: 0.0001)
    XCTAssertEqual(AnimatedMeshGradientPreset.default.sizing.fit, .contain)

    XCTAssertEqual(DotGridPreset.default.params.dotSize, 2, accuracy: 0.0001)
    XCTAssertEqual(DotGridPreset.default.params.shape, .circle)
    XCTAssertEqual(DotGridPreset.default.renderOptions.maxPixelCount, 6016 * 3384)

    XCTAssertEqual(ImageDitheringPreset.default.params.type, .eightByEight)
    XCTAssertFalse(ImageDitheringPreset.default.params.inverted)
    XCTAssertEqual(LiquidMetalPreset.default.params.shape, .diamond)
    XCTAssertEqual(GemSmokePreset.default.params.shape, .diamond)
  }

  func testImageBooleanParamsEncodeAsBooleans() throws {
    let color = ShaderColor(red: 1, green: 1, blue: 1)
    let imageParams = ImageDitheringParams(
      colorFront: color, originalColors: true, inverted: false)
    let halftoneParams = HalftoneDotsParams(
      colorFront: color, originalColors: false, inverted: true)

    let imageJSON = String(decoding: try JSONEncoder().encode(imageParams), as: UTF8.self)
    let halftoneJSON = String(decoding: try JSONEncoder().encode(halftoneParams), as: UTF8.self)

    XCTAssertTrue(imageJSON.contains(#""originalColors":true"#))
    XCTAssertTrue(imageJSON.contains(#""inverted":false"#))
    XCTAssertTrue(halftoneJSON.contains(#""originalColors":false"#))
    XCTAssertTrue(halftoneJSON.contains(#""inverted":true"#))
  }

  func testImageBooleanParamsConvertToFloatUniforms() {
    let color = ShaderColor(red: 1, green: 1, blue: 1)

    let imageUniforms = ImageDitheringUniformsRaw(
      params: ImageDitheringParams(colorFront: color, originalColors: true, inverted: false))
    XCTAssertEqual(imageUniforms.u_originalColors, 1)
    XCTAssertEqual(imageUniforms.u_inverted, 0)

    let halftoneUniforms = HalftoneDotsUniformsRaw(
      time: 0,
      params: HalftoneDotsParams(colorFront: color, originalColors: false, inverted: true)
    )
    XCTAssertEqual(halftoneUniforms.u_originalColors, 0)
    XCTAssertEqual(halftoneUniforms.u_inverted, 1)
  }

  @MainActor
  func testParamsInitializersDefaultToComponentPresetConfiguration() {
    let meshColors: [ShaderColor] = ["#5100ff", "#00ff80", "#ffcc00", "#ea00ff"]
    XCTAssertEqual(
      AnimatedMeshGradient(params: AnimatedMeshGradientParams(colors: meshColors)).configuration,
      AnimatedMeshGradient(colors: meshColors).configuration
    )

    let configurations: [(String, ShaderConfiguration, ShaderConfiguration)] = [
      (
        "AnimatedMeshGradient",
        AnimatedMeshGradient(params: AnimatedMeshGradientPreset.default.params).configuration,
        AnimatedMeshGradient(AnimatedMeshGradientPreset.default).configuration
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
        "HalftoneCMYK",
        HalftoneCMYK(params: HalftoneCMYKPreset.default.params).configuration,
        HalftoneCMYK(HalftoneCMYKPreset.default).configuration
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
      HalftoneCMYK(
        colorBack: "#fbfaf5", colorC: "#00b4ff", colorM: "#fc519f", colorY: "#ffd800",
        colorK: "#231f20", type: .ink
      ).configuration,
      GemSmoke(colors: ["#333333", "#e7e6df"], colorBack: "#f0efea", colorInner: "#fafaf5")
        .configuration,
    ]

    XCTAssertEqual(configurations.count, 29)
  }

  func testCodeGeneratorUsesFlatInitializerArguments() {
    let code = FoilShadersCodeGenerator.swiftUICode(
      componentName: "AnimatedMeshGradient",
      presetReference: "AnimatedMeshGradientPreset.default",
      sizing: .defaultPatternSizing,
      motion: ShaderMotionParams(speed: 0.2, frame: 0),
      renderOptions: ShaderRenderOptions(),
      layoutSize: CGSize(width: 1280, height: 720)
    )
    XCTAssertEqual(
      code,
      """
      import FoilShaders

      AnimatedMeshGradient(fit: .none, speed: 0.2)
        .frame(width: 1280, height: 720)
      """
    )
    XCTAssertFalse(code.contains("params:"))
    XCTAssertFalse(code.contains("ShaderSizingParams"))
    XCTAssertFalse(code.contains("ShaderMotionParams"))
    XCTAssertFalse(code.contains("ShaderRenderOptions"))
  }

  func testCodeGeneratorEmitsTerseSmokeRingExport() {
    let code = FoilShadersCodeGenerator.swiftUICode(
      componentName: "SmokeRing",
      presetReference: "SmokeRingPreset.default",
      sizing: ShaderSizingParams(fit: .contain, scale: 0.8),
      motion: ShaderMotionParams(speed: 0.25, frame: 0),
      renderOptions: ShaderRenderOptions(),
      layoutSize: CGSize(width: 1280, height: 720)
    )
    XCTAssertEqual(
      code,
      """
      import FoilShaders

      SmokeRing(scale: 0.8, speed: 0.25)
        .frame(width: 1280, height: 720)
      """
    )
    XCTAssertEqual(code.components(separatedBy: ".frame(width:").count - 1, 1)
    XCTAssertFalse(code.contains("params:"))
    XCTAssertFalse(code.contains("renderOptions:"))
  }

  func testCodeGeneratorUsesCompactStructuredInitializerForNonDefaultPreset() {
    let code = FoilShadersCodeGenerator.swiftUICode(
      componentName: "SmokeRing",
      presetReference: "SmokeRingPreset.cloud",
      sizing: ShaderSizingParams(fit: .contain, scale: 2.5),
      motion: ShaderMotionParams(speed: 0.5, frame: 0),
      renderOptions: ShaderRenderOptions()
    )
    XCTAssertEqual(
      code,
      """
      import FoilShaders

      SmokeRing(
        params: SmokeRingPreset.cloud.params,
        sizing: ShaderSizingParams(scale: 2.5),
        motion: ShaderMotionParams(speed: 0.5),
        renderOptions: ShaderRenderOptions()
      )
      """
    )
    XCTAssertFalse(code.contains("originX:"))
    XCTAssertFalse(code.contains("frame:"))
  }

  func testCodeGeneratorLeavesPulsingBorderUnqualified() {
    let code = FoilShadersCodeGenerator.swiftUICode(
      componentName: "PulsingBorder",
      presetReference: "PulsingBorderPreset.default",
      sizing: .defaultPatternSizing,
      motion: ShaderMotionParams(speed: 0.2, frame: 0),
      renderOptions: ShaderRenderOptions()
    )
    XCTAssertTrue(code.contains("\nPulsingBorder("))
    XCTAssertFalse(code.contains("FoilShaders.PulsingBorder"))
    XCTAssertFalse(code.contains("params: PulsingBorderPreset.default.params"))
    XCTAssertFalse(code.contains(".frame(width:"))
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
  func testRendererRenderConvenienceConfiguresForCapture() throws {
    guard let device = MTLCreateSystemDefaultDevice() else {
      throw XCTSkip("Metal is not available")
    }

    let renderer = try FoilShadersRenderer(device: device)
    try renderer.render(AnimatedMeshGradient().configuration)
    let image = try renderer.captureImage(width: 8, height: 8, pixelRatio: 1)

    XCTAssertEqual(image.width, 8)
    XCTAssertEqual(image.height, 8)
  }

  @MainActor
  func testCaptureImageThrowsSpecificPublicError() throws {
    guard let device = MTLCreateSystemDefaultDevice() else {
      throw XCTSkip("Metal is not available")
    }

    let renderer = try FoilShadersRenderer(device: device)

    XCTAssertThrowsError(try renderer.captureImage(width: 0, height: 8, pixelRatio: 1)) { error in
      guard case FoilShadersError.captureInvalidSize(let width, let height, let pixelRatio) = error
      else {
        return XCTFail("Expected captureInvalidSize, got \(error)")
      }
      XCTAssertEqual(width, 0)
      XCTAssertEqual(height, 8)
      XCTAssertEqual(pixelRatio, 1)
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
  func testHeatmapImageRenderingMatchesReferenceSampleOrientation() throws {
    guard let device = MTLCreateSystemDefaultDevice() else {
      throw XCTSkip("Metal is not available")
    }

    let image = try Self.makeTopDarkBottomLightImage(width: 32, height: 32)
    let renderer = try FoilShadersRenderer(device: device)
    try renderer.render(
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
        motion: ShaderMotionParams(speed: 0, frame: 5000),
        image: .cgImage(image)
      )
    )
    let capture = try renderer.capturePixels(width: 96, height: 96, pixelRatio: 1)

    let sampleX = (capture.width / 3)..<(2 * capture.width / 3)
    let topSampleY = (capture.height / 4)..<(capture.height / 2)
    let bottomSampleY = (capture.height / 2)..<(3 * capture.height / 4)
    let topLuminance = Self.averageLuminance(
      capture.rgba, width: capture.width, xRange: sampleX, yRange: topSampleY)
    let bottomLuminance = Self.averageLuminance(
      capture.rgba, width: capture.width, xRange: sampleX, yRange: bottomSampleY)

    XCTAssertGreaterThan(
      bottomLuminance,
      topLuminance,
      "The heatmap sample orientation should match the Paper reference output.")
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

  private func assertHashableSendableCodable<T: Hashable & Sendable & Codable>(
    _: T.Type,
    file: StaticString = #filePath,
    line: UInt = #line
  ) {}

  private static var fixtureShaderParameters: ShaderParameters {
    .dotGrid(fixtureDotGridParams)
  }

  private static var fixtureDotGridParams: DotGridParams {
    DotGridParams(
      colorBack: .black,
      colorFill: .white,
      colorStroke: ShaderColor(red: 1, green: 0.5, blue: 0, alpha: 1),
      dotSize: 2,
      gapX: 4,
      gapY: 5,
      strokeWidth: 0.5,
      sizeRange: 0.7,
      opacityRange: 0.4,
      shape: .diamond
    )
  }

  private static var fixtureShaderConfiguration: ShaderConfiguration {
    ShaderConfiguration(
      parameters: fixtureShaderParameters,
      sizing: ShaderSizingParams(
        fit: .contain,
        scale: 1.25,
        rotation: 15,
        originX: 0.4,
        originY: 0.6,
        offsetX: 0.1,
        offsetY: -0.2,
        worldWidth: 640,
        worldHeight: 360
      ),
      motion: ShaderMotionParams(speed: 0.25, frame: 12),
      renderOptions: ShaderRenderOptions(minPixelRatio: 1.5, maxPixelCount: 57_600),
      image: .url(URL(fileURLWithPath: "/tmp/source.png"))
    )
  }

  private static var fixtureJSONEncoder: JSONEncoder {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
    return encoder
  }

  private static func loadFixture(named name: String) throws -> Data {
    let url = try XCTUnwrap(
      Bundle.module.url(forResource: name, withExtension: "json", subdirectory: "Fixtures")
    )
    return try Data(contentsOf: url)
  }

  private static func canonicalJSONString(_ data: Data) throws -> String {
    let object = try JSONSerialization.jsonObject(with: data)
    let canonicalData = try JSONSerialization.data(
      withJSONObject: object,
      options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
    )
    return String(decoding: canonicalData, as: UTF8.self)
  }

  private enum TestImageError: Error {
    case providerCreationFailed
    case imageCreationFailed
  }
}
