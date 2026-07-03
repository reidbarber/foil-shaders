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
        renderer.attach(to: mtkView)
        try renderer.configure(configuration.kind)
        renderer.apply(configuration)
        context.coordinator.renderer = renderer
        context.coordinator.currentKind = configuration.kind
      } catch {
        assertionFailure("FoilShaders renderer setup failed: \(error)")
      }
      return mtkView
    }

    fileprivate func update(_ view: MTKView, context: Context) {
      guard let renderer = context.coordinator.renderer else { return }
      if context.coordinator.currentKind != configuration.kind {
        do {
          try renderer.configure(configuration.kind)
          context.coordinator.currentKind = configuration.kind
        } catch {
          assertionFailure("FoilShaders shader configure failed: \(error)")
        }
      }
      renderer.apply(configuration)
      view.setNeedsDisplay(view.bounds)
    }

    fileprivate final class Coordinator {
      var renderer: FoilShadersRenderer?
      var currentKind: FoilShadersRenderer.ShaderKind?
    }
  }
#endif
