import CoreGraphics
import FoilShaders
import MetalKit
import SwiftUI
import XCTest

#if canImport(UIKit)
  import UIKit
#elseif canImport(AppKit)
  import AppKit
#endif

final class PublicAPITests: XCTestCase {
  func testShaderColorStringLiteralFallsBackToBlackForInvalidInput() {
    let input = "definitely-not-a-color"
    let color: ShaderColor = "definitely-not-a-color"

    XCTAssertEqual(color, .black)
    XCTAssertNil(ShaderColor(input))
  }

  func testShaderColorInitializesFromCGColor() throws {
    let colorSpace = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
    let cgColor = try XCTUnwrap(
      CGColor(colorSpace: colorSpace, components: [0.25, 0.5, 0.75, 0.4]))

    let color = try XCTUnwrap(ShaderColor(cgColor))

    XCTAssertEqual(color.red, 0.25, accuracy: 0.0001)
    XCTAssertEqual(color.green, 0.5, accuracy: 0.0001)
    XCTAssertEqual(color.blue, 0.75, accuracy: 0.0001)
    XCTAssertEqual(color.alpha, 0.4, accuracy: 0.0001)
  }

  func testShaderColorInitializesFromGrayCGColor() throws {
    let cgColor = CGColor(gray: 0.35, alpha: 0.6)

    let color = try XCTUnwrap(ShaderColor(cgColor))

    XCTAssertEqual(color.red, color.green, accuracy: 0.0001)
    XCTAssertEqual(color.green, color.blue, accuracy: 0.0001)
    XCTAssertEqual(color.alpha, 0.6, accuracy: 0.0001)
  }

  @MainActor
  func testShaderColorInitializesFromSwiftUIColorBridge() throws {
    let color = try XCTUnwrap(
      ShaderColor(Color(.sRGB, red: 0.2, green: 0.4, blue: 0.6, opacity: 0.8)))

    XCTAssertEqual(color.red, 0.2, accuracy: 0.0001)
    XCTAssertEqual(color.green, 0.4, accuracy: 0.0001)
    XCTAssertEqual(color.blue, 0.6, accuracy: 0.0001)
    XCTAssertEqual(color.alpha, 0.8, accuracy: 0.0001)
  }

  @MainActor
  func testShaderColorInitializesFromSwiftUIColorEnvironment() throws {
    guard #available(iOS 17.0, macOS 14.0, *) else { return }

    let color = ShaderColor(
      Color(.sRGB, red: 0.15, green: 0.25, blue: 0.35, opacity: 0.45),
      in: EnvironmentValues()
    )

    XCTAssertEqual(color.red, 0.15, accuracy: 0.0001)
    XCTAssertEqual(color.green, 0.25, accuracy: 0.0001)
    XCTAssertEqual(color.blue, 0.35, accuracy: 0.0001)
    XCTAssertEqual(color.alpha, 0.45, accuracy: 0.0001)
  }

  @MainActor
  func testShaderColorInitializesFromPlatformColor() throws {
    #if canImport(UIKit)
      let platformColor = UIColor(red: 0.1, green: 0.3, blue: 0.5, alpha: 0.7)
    #elseif canImport(AppKit)
      let platformColor = NSColor(srgbRed: 0.1, green: 0.3, blue: 0.5, alpha: 0.7)
    #endif

    let color = try XCTUnwrap(ShaderColor(platformColor))

    XCTAssertEqual(color.red, 0.1, accuracy: 0.0001)
    XCTAssertEqual(color.green, 0.3, accuracy: 0.0001)
    XCTAssertEqual(color.blue, 0.5, accuracy: 0.0001)
    XCTAssertEqual(color.alpha, 0.7, accuracy: 0.0001)
  }

  @MainActor
  func testShaderPresetsCanDriveSwiftUIForEachWithoutExplicitID() {
    XCTAssertEqual(AnimatedMeshGradientPreset.default.id, AnimatedMeshGradientPreset.default.name)

    let view = ForEach(AnimatedMeshGradient.presets) { preset in
      Text(preset.name)
    }

    _ = view
  }

  func testColorArrayParamsKeepOnlyMaxColorCountColors() {
    let colors = (0..<(AnimatedMeshGradientParams.maxColorCount + 2)).map {
      ShaderColor(red: Float($0) / 20, green: 0, blue: 0)
    }
    let params = AnimatedMeshGradientParams(colors: colors)

    XCTAssertEqual(params.colors, Array(colors.prefix(AnimatedMeshGradientParams.maxColorCount)))
  }

  func testColorArrayParamsKeepOnlyMaxColorCountColorsAfterMutation() {
    assertColorMutationClamps(maxColorCount: AnimatedMeshGradientParams.maxColorCount) {
      initial, overflow in
      var params = AnimatedMeshGradientParams(colors: initial)
      params.colors.append(contentsOf: overflow)
      return params.colors
    }
    assertColorMutationClamps(maxColorCount: StaticMeshGradientParams.maxColorCount) {
      initial, overflow in
      var params = StaticMeshGradientParams(colors: initial)
      params.colors.append(contentsOf: overflow)
      return params.colors
    }
    assertColorMutationClamps(maxColorCount: StaticRadialGradientParams.maxColorCount) {
      initial, overflow in
      var params = StaticRadialGradientParams(colors: initial)
      params.colors.append(contentsOf: overflow)
      return params.colors
    }
    assertColorMutationClamps(maxColorCount: SwirlParams.maxColorCount) { initial, overflow in
      var params = SwirlParams(colors: initial)
      params.colors.append(contentsOf: overflow)
      return params.colors
    }
    assertColorMutationClamps(maxColorCount: SimplexNoiseParams.maxColorCount) {
      initial, overflow in
      var params = SimplexNoiseParams(colors: initial)
      params.colors.append(contentsOf: overflow)
      return params.colors
    }
    assertColorMutationClamps(maxColorCount: ColorPanelsParams.maxColorCount) {
      initial, overflow in
      var params = ColorPanelsParams(colors: initial)
      params.colors.append(contentsOf: overflow)
      return params.colors
    }
    assertColorMutationClamps(maxColorCount: DotOrbitParams.maxColorCount) { initial, overflow in
      var params = DotOrbitParams(colors: initial)
      params.colors.append(contentsOf: overflow)
      return params.colors
    }
    assertColorMutationClamps(maxColorCount: GodRaysParams.maxColorCount) { initial, overflow in
      var params = GodRaysParams(colors: initial)
      params.colors.append(contentsOf: overflow)
      return params.colors
    }
    assertColorMutationClamps(maxColorCount: GrainGradientParams.maxColorCount) {
      initial, overflow in
      var params = GrainGradientParams(colors: initial)
      params.colors.append(contentsOf: overflow)
      return params.colors
    }
    assertColorMutationClamps(maxColorCount: MetaballsParams.maxColorCount) {
      initial, overflow in
      var params = MetaballsParams(colors: initial)
      params.colors.append(contentsOf: overflow)
      return params.colors
    }
    assertColorMutationClamps(maxColorCount: WarpParams.maxColorCount) { initial, overflow in
      var params = WarpParams(colors: initial)
      params.colors.append(contentsOf: overflow)
      return params.colors
    }
    assertColorMutationClamps(maxColorCount: VoronoiParams.maxColorCount) { initial, overflow in
      var params = VoronoiParams(colors: initial)
      params.colors.append(contentsOf: overflow)
      return params.colors
    }
    assertColorMutationClamps(maxColorCount: PulsingBorderParams.maxColorCount) {
      initial, overflow in
      var params = PulsingBorderParams(colors: initial)
      params.colors.append(contentsOf: overflow)
      return params.colors
    }
    assertColorMutationClamps(maxColorCount: SmokeRingParams.maxColorCount) {
      initial, overflow in
      var params = SmokeRingParams(colors: initial)
      params.colors.append(contentsOf: overflow)
      return params.colors
    }
    assertColorMutationClamps(maxColorCount: HeatmapParams.maxColorCount) { initial, overflow in
      var params = HeatmapParams(colors: initial)
      params.colors.append(contentsOf: overflow)
      return params.colors
    }
    assertColorMutationClamps(maxColorCount: GemSmokeParams.maxColorCount) { initial, overflow in
      var params = GemSmokeParams(colors: initial)
      params.colors.append(contentsOf: overflow)
      return params.colors
    }
  }

  func testFoilShadersErrorIsPublicAndLocalized() {
    let error: any Error = FoilShadersError.shaderError("missing_fragment")

    XCTAssertTrue(error is FoilShadersError)
    XCTAssertEqual(
      error.localizedDescription,
      "FoilShaders could not find the required Metal shader function 'missing_fragment'.")
  }

  @MainActor
  func testRendererSetImageAcceptsBareNilLiteral() {
    let clearImage: (FoilShadersRenderer) -> Void = { renderer in
      renderer.setImage(nil)
    }

    _ = clearImage
  }

  @MainActor
  func testRendererPublicRenderAndThrowingCaptureAPIsCompile() {
    let renderConfiguration: (FoilShadersRenderer, ShaderConfiguration) throws -> Void = {
      renderer,
      configuration in
      try renderer.render(configuration)
    }
    let renderInView: (FoilShadersRenderer, ShaderConfiguration, MTKView) throws -> Void = {
      renderer,
      configuration,
      view in
      try renderer.render(configuration, in: view)
    }
    let captureImage: (FoilShadersRenderer) throws -> CGImage = { renderer in
      try renderer.captureImage(width: 1, height: 1)
    }

    _ = renderConfiguration
    _ = renderInView
    _ = captureImage
  }

  @MainActor
  func testShaderViewAcceptsPublicRendererErrorReportingHooks() {
    let configuration = AnimatedMeshGradient().configuration
    var reportedError: FoilShadersError?
    let rendererError = Binding<FoilShadersError?>(
      get: { reportedError },
      set: { reportedError = $0 }
    )

    let view = FoilShaderView(
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

    let view = FoilShaderView(
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

  @MainActor
  func testShaderComponentsAcceptRendererErrorEnvironmentHandler() {
    var reportedError: FoilShadersError?

    let view = Swirl(.candy)
      .foilShadersRendererError { error in
        reportedError = error
      }

    XCTAssertFalse(String(describing: type(of: view)).isEmpty)
    XCTAssertNil(reportedError)
  }

  private func assertColorMutationClamps(
    maxColorCount: Int,
    mutate: ([ShaderColor], [ShaderColor]) -> [ShaderColor],
    file: StaticString = #filePath,
    line: UInt = #line
  ) {
    let initial = [ShaderColor(red: 0.95, green: 0, blue: 0)]
    let overflow = (0..<(maxColorCount + 2)).map {
      ShaderColor(red: Float($0) / 20, green: 0.2, blue: 0.4)
    }
    let attemptedColors = initial + overflow

    XCTAssertEqual(
      mutate(initial, overflow),
      Array(attemptedColors.prefix(maxColorCount)),
      file: file,
      line: line
    )
  }
}
