import CoreGraphics
import Metal
import MetalKit
import SwiftUI

public struct FoilShadersShaderView: SwiftUI.View {
  public var configuration: ShaderConfiguration

  public init(configuration: ShaderConfiguration) {
    self.configuration = configuration
  }

  public var body: some SwiftUI.View {
    PlatformShaderView(configuration: configuration)
      .frame(width: configuration.renderOptions.width, height: configuration.renderOptions.height)
  }
}

#if os(macOS)
  private struct PlatformShaderView: NSViewRepresentable {
    var configuration: ShaderConfiguration

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

    fileprivate func makeView(context: Context) -> MTKView {
      let mtkView = MTKView(frame: .zero, device: MTLCreateSystemDefaultDevice())
      guard let device = mtkView.device else { return mtkView }
      do {
        let renderer = try FoilShadersRenderer(device: device)
        let shaderKind = configuration.kind
        renderer.attach(to: mtkView)
        try renderer.configure(shaderKind)
        renderer.apply(configuration)
        context.coordinator.renderer = renderer
        context.coordinator.currentKind = shaderKind
        context.coordinator.currentConfiguration = configuration
      } catch {
        assertionFailure("FoilShaders renderer setup failed: \(error)")
      }
      return mtkView
    }

    fileprivate func update(_ view: MTKView, context: Context) {
      guard let renderer = context.coordinator.renderer else { return }
      let shaderKind = configuration.kind
      let needsConfigure = context.coordinator.currentKind != shaderKind
      let needsApply = context.coordinator.currentConfiguration != configuration
      if needsConfigure {
        do {
          try renderer.configure(shaderKind)
          context.coordinator.currentKind = shaderKind
        } catch {
          assertionFailure("FoilShaders shader configure failed: \(error)")
        }
      }
      if needsConfigure || needsApply {
        renderer.apply(configuration)
        context.coordinator.currentConfiguration = configuration
      }
      view.setNeedsDisplay(view.bounds)
    }

    fileprivate final class Coordinator {
      var renderer: FoilShadersRenderer?
      var currentKind: FoilShadersRenderer.ShaderKind?
      var currentConfiguration: ShaderConfiguration?
    }
  }
#endif
