import Metal
import XCTest

@testable import FoilShaders

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

  func testMetalPipelinesCompile() throws {
    guard let device = MTLCreateSystemDefaultDevice() else {
      throw XCTSkip("Metal is not available")
    }
    let renderer = try FoilShadersRenderer(device: device)
    for shader in FoilShadersRenderer.ShaderKind.allCases {
      XCTAssertNoThrow(try renderer.configure(shader), "Failed to configure \(shader)")
    }
  }
}
