import FoilShaders
import SwiftUI
import XCTest

final class PublicAPITests: XCTestCase {
  func testFoilShadersErrorIsPublicAndLocalized() {
    let error: any Error = FoilShadersError.shaderError("missing_fragment")

    XCTAssertTrue(error is FoilShadersError)
    XCTAssertEqual(
      error.localizedDescription,
      "FoilShaders could not find the required Metal shader function 'missing_fragment'.")
  }

  @MainActor
  func testShaderViewAcceptsPublicRendererErrorReportingHooks() {
    let configuration = MeshGradient().configuration
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
    XCTAssertNil(reportedError)
  }
}
