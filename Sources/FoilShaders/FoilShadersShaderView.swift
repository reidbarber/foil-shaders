import CoreGraphics
import Metal
import MetalKit
import SwiftUI

public struct FoilShadersShaderView: SwiftUI.View {
  /// The color shown by the SwiftUI wrapper when renderer setup fails in release builds.
  public static let defaultFailureFallbackColor = ShaderColor(red: 1, green: 0, blue: 0.55)

  public var configuration: ShaderConfiguration
  public var failureFallbackColor: ShaderColor

  @Binding private var rendererError: FoilShadersError?
  private var onRendererError: ((FoilShadersError) -> Void)?

  /// Creates a SwiftUI shader view.
  ///
  /// - Parameters:
  ///   - configuration: The shader configuration to render.
  ///   - rendererError: Optional binding updated when renderer setup or reconfiguration fails.
  ///   - failureFallbackColor: Solid fallback color shown if the renderer cannot be configured.
  ///   - onRendererError: Optional callback invoked once for each distinct renderer failure.
  public init(
    configuration: ShaderConfiguration,
    rendererError: Binding<FoilShadersError?> = .constant(nil),
    failureFallbackColor: ShaderColor = FoilShadersShaderView.defaultFailureFallbackColor,
    onRendererError: ((FoilShadersError) -> Void)? = nil
  ) {
    self.configuration = configuration
    self._rendererError = rendererError
    self.failureFallbackColor = failureFallbackColor
    self.onRendererError = onRendererError
  }

  public var body: some SwiftUI.View {
    PlatformShaderView(
      configuration: configuration,
      rendererError: $rendererError,
      failureFallbackColor: failureFallbackColor,
      onRendererError: onRendererError
    )
    .frame(width: configuration.renderOptions.width, height: configuration.renderOptions.height)
  }
}

#if os(macOS)
  private struct PlatformShaderView: NSViewRepresentable {
    var configuration: ShaderConfiguration
    @Binding var rendererError: FoilShadersError?
    var failureFallbackColor: ShaderColor
    var onRendererError: ((FoilShadersError) -> Void)?

    func makeNSView(context: Context) -> MTKView {
      makeView(context: context)
    }

    func updateNSView(_ view: MTKView, context: Context) {
      update(view, context: context)
    }
  }
#elseif os(iOS)
  private struct PlatformShaderView: UIViewRepresentable {
    var configuration: ShaderConfiguration
    @Binding var rendererError: FoilShadersError?
    var failureFallbackColor: ShaderColor
    var onRendererError: ((FoilShadersError) -> Void)?

    func makeUIView(context: Context) -> MTKView {
      makeView(context: context)
    }

    func updateUIView(_ view: MTKView, context: Context) {
      update(view, context: context)
    }
  }
#endif

#if os(macOS) || os(iOS)
  extension PlatformShaderView {
    fileprivate func makeCoordinator() -> Coordinator {
      Coordinator()
    }

    @MainActor fileprivate func makeView(context: Context) -> MTKView {
      let mtkView = MTKView(frame: .zero, device: nil)
      do {
        let metalContext = try FoilShadersMetalContext.sharedDefault()
        mtkView.device = metalContext.device
        let renderer = FoilShadersRenderer(context: metalContext)
        let shaderKind = configuration.kind
        try renderer.configure(shaderKind)
        renderer.attach(to: mtkView)
        renderer.apply(configuration)
        context.coordinator.renderer = renderer
        context.coordinator.currentKind = shaderKind
        context.coordinator.currentConfiguration = configuration
      } catch {
        handleFailure(FoilShadersError.wrapping(error), in: mtkView, context: context)
      }
      return mtkView
    }

    @MainActor fileprivate func update(_ view: MTKView, context: Context) {
      guard let renderer = context.coordinator.renderer else { return }
      let shaderKind = configuration.kind
      let needsConfigure = context.coordinator.currentKind != shaderKind
      let needsApply = context.coordinator.currentConfiguration != configuration
      if needsConfigure {
        do {
          try renderer.configure(shaderKind)
          renderer.attach(to: view)
          context.coordinator.clearFailure(on: view, rendererError: $rendererError)
          context.coordinator.currentKind = shaderKind
        } catch {
          handleFailure(FoilShadersError.wrapping(error), in: view, context: context)
          return
        }
      }
      if needsConfigure || needsApply {
        renderer.apply(configuration)
        context.coordinator.currentConfiguration = configuration
      }
      view.setNeedsDisplay(view.bounds)
    }

    @MainActor fileprivate func handleFailure(
      _ error: FoilShadersError,
      in view: MTKView,
      context: Context
    ) {
      context.coordinator.showFailureFallback(on: view, color: failureFallbackColor)
      context.coordinator.reportFailure(
        error,
        rendererError: $rendererError,
        onRendererError: onRendererError
      )
    }

    fileprivate final class Coordinator {
      var renderer: FoilShadersRenderer?
      var currentKind: FoilShadersRenderer.ShaderKind?
      var currentConfiguration: ShaderConfiguration?
      private var lastReportedFailureDescription: String?

      @MainActor func showFailureFallback(on view: MTKView, color: ShaderColor) {
        view.delegate = nil
        view.isPaused = true
        view.enableSetNeedsDisplay = true
        view.clearColor = MTLClearColorMake(
          Double(color.red.clamped01),
          Double(color.green.clamped01),
          Double(color.blue.clamped01),
          Double(color.alpha.clamped01)
        )
        #if os(iOS)
          view.isOpaque = color.alpha.clamped01 >= 1
        #endif
        setLayerBackground(
          color.cgColor,
          isOpaque: color.alpha.clamped01 >= 1,
          on: view
        )
        view.setNeedsDisplay(view.bounds)
      }

      @MainActor func reportFailure(
        _ error: FoilShadersError,
        rendererError: Binding<FoilShadersError?>,
        onRendererError: ((FoilShadersError) -> Void)?
      ) {
        rendererError.wrappedValue = error
        let description = error.localizedDescription
        guard lastReportedFailureDescription != description else { return }
        lastReportedFailureDescription = description
        onRendererError?(error)
      }

      @MainActor func clearFailure(on view: MTKView, rendererError: Binding<FoilShadersError?>) {
        guard lastReportedFailureDescription != nil else { return }
        lastReportedFailureDescription = nil
        rendererError.wrappedValue = nil
        setLayerBackground(nil, isOpaque: false, on: view)
      }

      @MainActor private func setLayerBackground(
        _ color: CGColor?,
        isOpaque: Bool,
        on view: MTKView
      ) {
        #if os(macOS)
          view.layer?.backgroundColor = color
          (view.layer as? CAMetalLayer)?.isOpaque = isOpaque
        #elseif os(iOS)
          view.layer.backgroundColor = color
          (view.layer as? CAMetalLayer)?.isOpaque = isOpaque
        #endif
      }
    }
  }
#endif

extension ShaderColor {
  fileprivate var cgColor: CGColor {
    CGColor(
      srgbRed: CGFloat(red.clamped01),
      green: CGFloat(green.clamped01),
      blue: CGFloat(blue.clamped01),
      alpha: CGFloat(alpha.clamped01)
    )
  }
}

extension Float {
  fileprivate var clamped01: Float {
    min(1, max(0, self))
  }
}
