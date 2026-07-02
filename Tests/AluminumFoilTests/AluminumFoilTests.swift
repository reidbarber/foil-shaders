import Metal
import XCTest

@testable import AluminumFoil

final class AluminumFoilTests: XCTestCase {
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
    XCTAssertEqual(counts.count, 29)
    XCTAssertTrue(counts.allSatisfy { $0 > 0 })
  }

  func testCodeGeneratorQualifiesMeshGradient() {
    let code = AluminumFoilCodeGenerator.swiftUICode(
      componentName: "MeshGradient",
      presetReference: "meshGradientPresets[0]",
      sizing: .defaultPatternSizing,
      motion: ShaderMotionParams(speed: 0.2, frame: 0),
      renderOptions: ShaderRenderOptions(width: 1280, height: 720)
    )
    XCTAssertTrue(code.contains("AluminumFoil.MeshGradient"))
    XCTAssertTrue(code.contains("params: meshGradientPresets[0].params"))
  }

  func testMetalPipelinesCompile() throws {
    guard let device = MTLCreateSystemDefaultDevice() else {
      throw XCTSkip("Metal is not available")
    }
    let renderer = try AluminumFoilRenderer(device: device)
    for shader in AluminumFoilRenderer.ShaderKind.allCases {
      XCTAssertNoThrow(try renderer.configure(shader), "Failed to configure \(shader)")
    }
  }
}
