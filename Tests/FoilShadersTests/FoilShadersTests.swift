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
    counts.append(meshGradientPresets.count)
    counts.append(smokeRingPresets.count)
    counts.append(neuroNoisePresets.count)
    counts.append(dotOrbitPresets.count)
    counts.append(dotGridPresets.count)
    counts.append(simplexNoisePresets.count)
    counts.append(metaballsPresets.count)
    counts.append(wavesPresets.count)
    counts.append(perlinNoisePresets.count)
    counts.append(voronoiPresets.count)
    counts.append(warpPresets.count)
    counts.append(godRaysPresets.count)
    counts.append(spiralPresets.count)
    counts.append(swirlPresets.count)
    counts.append(ditheringPresets.count)
    counts.append(grainGradientPresets.count)
    counts.append(pulsingBorderPresets.count)
    counts.append(colorPanelsPresets.count)
    counts.append(staticMeshGradientPresets.count)
    counts.append(staticRadialGradientPresets.count)
    counts.append(paperTexturePresets.count)
    counts.append(flutedGlassPresets.count)
    counts.append(waterPresets.count)
    counts.append(imageDitheringPresets.count)
    counts.append(heatmapPresets.count)
    counts.append(liquidMetalPresets.count)
    counts.append(halftoneDotsPresets.count)
    counts.append(halftoneCmykPresets.count)
    counts.append(gemSmokePresets.count)
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

  func testPaperDefaultPresetValues() {
    XCTAssertEqual(meshGradientPresets[0].name, "Default")
    XCTAssertEqual(meshGradientPresets[0].params.colors.count, 4)
    XCTAssertEqual(meshGradientPresets[0].params.distortion, 0.8, accuracy: 0.0001)
    XCTAssertEqual(meshGradientPresets[0].params.swirl, 0.1, accuracy: 0.0001)
    XCTAssertEqual(meshGradientPresets[0].motion.speed, 1, accuracy: 0.0001)
    XCTAssertEqual(meshGradientPresets[0].sizing.fit, .contain)

    XCTAssertEqual(dotGridPresets[0].params.dotSize, 2, accuracy: 0.0001)
    XCTAssertEqual(dotGridPresets[0].params.shape, DotGridShape.circle.rawValue, accuracy: 0.0001)
    XCTAssertEqual(dotGridPresets[0].renderOptions.maxPixelCount, 6016 * 3384)

    XCTAssertEqual(imageDitheringPresets[0].params.type, DitheringType.eightByEight.rawValue)
    XCTAssertEqual(imageDitheringPresets[0].params.inverted, 0)
    XCTAssertEqual(liquidMetalPresets[0].params.shape, LiquidMetalShape.diamond.rawValue)
    XCTAssertEqual(gemSmokePresets[0].params.shape, GemSmokeShape.diamond.rawValue)
  }

  func testCodeGeneratorQualifiesMeshGradient() {
    let code = FoilShadersCodeGenerator.swiftUICode(
      componentName: "MeshGradient",
      presetReference: "meshGradientPresets[0]",
      sizing: .defaultPatternSizing,
      motion: ShaderMotionParams(speed: 0.2, frame: 0),
      renderOptions: ShaderRenderOptions(width: 1280, height: 720)
    )
    XCTAssertTrue(code.contains("FoilShaders.MeshGradient"))
    XCTAssertTrue(code.contains("params: meshGradientPresets[0].params"))
  }

  func testCodeGeneratorLeavesPulsingBorderUnqualified() {
    let code = FoilShadersCodeGenerator.swiftUICode(
      componentName: "PulsingBorder",
      presetReference: "pulsingBorderPresets[0]",
      sizing: .defaultPatternSizing,
      motion: ShaderMotionParams(speed: 0.2, frame: 0),
      renderOptions: ShaderRenderOptions(width: 1280, height: 720)
    )
    XCTAssertTrue(code.contains("\nPulsingBorder(\n"))
    XCTAssertFalse(code.contains("FoilShaders.PulsingBorder"))
    XCTAssertTrue(code.contains("params: pulsingBorderPresets[0].params"))
  }

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
  func testHeatmapImageRenderingPreservesSourceOrientation() throws {
    guard let device = MTLCreateSystemDefaultDevice() else {
      throw XCTSkip("Metal is not available")
    }

    let image = try Self.makeTopDarkBottomLightImage(width: 32, height: 32)
    let renderer = try FoilShadersRenderer(device: device)
    try renderer.configure(.heatmap)
    renderer.apply(
      ShaderConfiguration(
        kind: .heatmap,
        parameters: .heatmap(
          HeatmapParams(
            colorBack: SIMD4<Float>(0, 0, 0, 1),
            colors: [SIMD4<Float>(1, 1, 1, 1)],
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
    renderer.setRenderSize(width: 96, height: 96, pixelRatio: 1)

    guard let capture = renderer.captureCurrentPixels() else {
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
    var rgba = [UInt8](repeating: 255, count: width * height * 4)
    for y in 0..<height {
      for x in 0..<width {
        let base = (y * width + x) * 4
        let value: UInt8 = y < height / 2 ? 0 : 255
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

  private enum TestImageError: Error {
    case providerCreationFailed
    case imageCreationFailed
  }
}
