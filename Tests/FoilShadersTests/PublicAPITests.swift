import FoilShaders
import SwiftUI
import XCTest

final class PublicAPITests: XCTestCase {
  func testShaderColorStringLiteralFallsBackToBlackForInvalidInput() {
    let input = "definitely-not-a-color"
    let color: ShaderColor = "definitely-not-a-color"

    XCTAssertEqual(color, .black)
    XCTAssertNil(ShaderColor(input))
  }

  func testColorArrayParamsKeepOnlyMaxColorCountColors() {
    let colors = (0..<(MeshGradientParams.maxColorCount + 2)).map {
      ShaderColor(red: Float($0) / 20, green: 0, blue: 0)
    }
    let params = MeshGradientParams(colors: colors)

    XCTAssertEqual(params.colors, Array(colors.prefix(MeshGradientParams.maxColorCount)))
  }

  func testFoilShadersErrorIsPublicAndLocalized() {
    let error: any Error = FoilShadersError.shaderError("missing_fragment")

    XCTAssertTrue(error is FoilShadersError)
    XCTAssertEqual(
      error.localizedDescription,
      "FoilShaders could not find the required Metal shader function 'missing_fragment'.")
  }

  @MainActor
  func testShaderViewAcceptsPublicRendererErrorReportingHooks() {
    let configuration = AnimatedMeshGradient().configuration
    var reportedError: FoilShadersError?
    let rendererError = Binding<FoilShadersError?>(
      get: { reportedError },
      set: { reportedError = $0 }
    )

    let view = FoilShadersShaderView(
      configuration: configuration,
      rendererError: rendererError,
      failureFallbackColor: .white
    ) { error in
      reportedError = error
    }

    XCTAssertEqual(view.configuration, configuration)
    XCTAssertEqual(view.failureFallbackColor, .white)
    XCTAssertTrue(view.respectsReduceMotion)
    XCTAssertTrue(view.pausesWhenInactiveOrOffscreen)
    XCTAssertNil(reportedError)
  }

  @MainActor
  func testShaderViewAcceptsEnergyAndAccessibilityOptOuts() {
    let configuration = AnimatedMeshGradient().configuration

    let view = FoilShadersShaderView(
      configuration: configuration,
      respectsReduceMotion: false,
      pausesWhenInactiveOrOffscreen: false
    )

    XCTAssertEqual(view.configuration, configuration)
    XCTAssertFalse(view.respectsReduceMotion)
    XCTAssertFalse(view.pausesWhenInactiveOrOffscreen)
  }

  @MainActor
  func testShaderComponentsAcceptEnergyAndAccessibilityEnvironmentOptOuts() {
    let view = AnimatedMeshGradient()
      .foilShadersRespectsReduceMotion(false)
      .foilShadersPausesWhenInactiveOrOffscreen(false)

    XCTAssertFalse(String(describing: type(of: view)).isEmpty)
  }
}
