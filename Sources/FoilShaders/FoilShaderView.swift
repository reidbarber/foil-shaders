import CoreGraphics
import Foundation
import Metal
import MetalKit
import SwiftUI

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#endif

private struct FoilShadersRespectsReduceMotionKey: EnvironmentKey {
  static let defaultValue = true
}

private struct FoilShadersPausesWhenInactiveOrOffscreenKey: EnvironmentKey {
  static let defaultValue = true
}

extension EnvironmentValues {
  /// Controls whether Foil Shaders SwiftUI components pause animation when Reduce Motion is enabled.
  public var foilShadersRespectsReduceMotion: Bool {
    get { self[FoilShadersRespectsReduceMotionKey.self] }
    set { self[FoilShadersRespectsReduceMotionKey.self] = newValue }
  }

  /// Controls whether Foil Shaders SwiftUI components pause rendering while inactive or offscreen.
  public var foilShadersPausesWhenInactiveOrOffscreen: Bool {
    get { self[FoilShadersPausesWhenInactiveOrOffscreenKey.self] }
    set { self[FoilShadersPausesWhenInactiveOrOffscreenKey.self] = newValue }
  }
}

extension SwiftUI.View {
  /// Sets whether Foil Shaders descendants pause animation when Reduce Motion is enabled.
  public func foilShadersRespectsReduceMotion(_ respectsReduceMotion: Bool) -> some SwiftUI.View {
    environment(\.foilShadersRespectsReduceMotion, respectsReduceMotion)
  }

  /// Sets whether Foil Shaders descendants pause rendering while inactive or offscreen.
  public func foilShadersPausesWhenInactiveOrOffscreen(
    _ pausesWhenInactiveOrOffscreen: Bool
  ) -> some SwiftUI.View {
    environment(\.foilShadersPausesWhenInactiveOrOffscreen, pausesWhenInactiveOrOffscreen)
  }
}

public struct FoilShaderView: SwiftUI.View {
  /// The color shown by the SwiftUI wrapper when renderer setup fails in release builds.
  public static let defaultFailureFallbackColor = ShaderColor(red: 1, green: 0, blue: 0.55)

  public var configuration: ShaderConfiguration
  public var failureFallbackColor: ShaderColor
  public var respectsReduceMotion: Bool
  public var pausesWhenInactiveOrOffscreen: Bool

  @Environment(\.accessibilityReduceMotion) private var accessibilityReduceMotion
  @Environment(\.foilShadersRespectsReduceMotion) private var environmentRespectsReduceMotion
  @Environment(\.foilShadersPausesWhenInactiveOrOffscreen)
  private var environmentPausesWhenInactiveOrOffscreen
  @Environment(\.scenePhase) private var scenePhase
  @Binding private var rendererError: FoilShadersError?
  private var onRendererError: ((FoilShadersError) -> Void)?

  /// Creates a SwiftUI shader view.
  ///
  /// - Parameters:
  ///   - configuration: The shader configuration to render.
  ///   - rendererError: Optional binding updated when renderer setup or reconfiguration fails.
  ///   - failureFallbackColor: Solid fallback color shown if the renderer cannot be configured.
  ///   - respectsReduceMotion: Whether animation pauses when the system Reduce Motion setting is enabled.
  ///   - pausesWhenInactiveOrOffscreen: Whether rendering pauses while inactive or offscreen.
  ///   - onRendererError: Optional callback invoked once for each distinct renderer failure.
  public init(
    configuration: ShaderConfiguration,
    rendererError: Binding<FoilShadersError?> = .constant(nil),
    failureFallbackColor: ShaderColor = FoilShaderView.defaultFailureFallbackColor,
    respectsReduceMotion: Bool = true,
    pausesWhenInactiveOrOffscreen: Bool = true,
    onRendererError: ((FoilShadersError) -> Void)? = nil
  ) {
    self.configuration = configuration
    self._rendererError = rendererError
    self.failureFallbackColor = failureFallbackColor
    self.respectsReduceMotion = respectsReduceMotion
    self.pausesWhenInactiveOrOffscreen = pausesWhenInactiveOrOffscreen
    self.onRendererError = onRendererError
  }

  public var body: some SwiftUI.View {
    let pausesForReduceMotion =
      respectsReduceMotion && environmentRespectsReduceMotion && accessibilityReduceMotion
    let pausesForLifecycle =
      pausesWhenInactiveOrOffscreen && environmentPausesWhenInactiveOrOffscreen
    PlatformShaderView(
      configuration: configuration,
      rendererError: $rendererError,
      failureFallbackColor: failureFallbackColor,
      pausesForReduceMotion: pausesForReduceMotion,
      pausesForLifecycle: pausesForLifecycle,
      isSceneActive: scenePhase == .active,
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
    var pausesForReduceMotion: Bool
    var pausesForLifecycle: Bool
    var isSceneActive: Bool
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
    var pausesForReduceMotion: Bool
    var pausesForLifecycle: Bool
    var isSceneActive: Bool
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
      let mtkView = VisibilityTrackingMTKView(frame: .zero, device: nil)
      context.coordinator.installVisibilityTracking(on: mtkView)
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
        context.coordinator.updateRenderingPolicy(
          on: mtkView,
          pausesForReduceMotion: pausesForReduceMotion,
          pausesForLifecycle: pausesForLifecycle,
          isSceneActive: isSceneActive
        )
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
      context.coordinator.updateRenderingPolicy(
        on: view,
        pausesForReduceMotion: pausesForReduceMotion,
        pausesForLifecycle: pausesForLifecycle,
        isSceneActive: isSceneActive
      )
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
      private var pausesForReduceMotion = false
      private var pausesForLifecycle = true
      private var isSceneActive = true
      private var isViewVisible = true
      private var lastReportedFailureDescription: String?

      @MainActor func installVisibilityTracking(on view: VisibilityTrackingMTKView) {
        view.onVisibilityChanged = { [weak self] view in
          self?.setViewVisible(view.isVisibleForRendering)
        }
        setViewVisible(view.isVisibleForRendering)
      }

      @MainActor func updateRenderingPolicy(
        on view: MTKView,
        pausesForReduceMotion: Bool,
        pausesForLifecycle: Bool,
        isSceneActive: Bool
      ) {
        self.pausesForReduceMotion = pausesForReduceMotion
        self.pausesForLifecycle = pausesForLifecycle
        self.isSceneActive = isSceneActive
        if let view = view as? VisibilityTrackingMTKView {
          isViewVisible = view.isVisibleForRendering
        }
        applyRenderingPause()
      }

      @MainActor private func setViewVisible(_ isVisible: Bool) {
        isViewVisible = isVisible
        applyRenderingPause()
      }

      @MainActor private func applyRenderingPause() {
        let pausesForVisibility = pausesForLifecycle && (!isSceneActive || !isViewVisible)
        renderer?.setRenderingPaused(pausesForReduceMotion || pausesForVisibility)
      }

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

#if os(macOS)
  @MainActor private final class VisibilityTrackingMTKView: MTKView {
    var onVisibilityChanged: ((VisibilityTrackingMTKView) -> Void)?

    private weak var observedWindow: NSWindow?
    private var windowObservers: [NSObjectProtocol] = []

    var isVisibleForRendering: Bool {
      guard let window,
        !isHiddenOrHasHiddenAncestor,
        bounds.width > 0,
        bounds.height > 0,
        !window.isMiniaturized,
        window.occlusionState.contains(.visible),
        !visibleRect.isEmpty
      else {
        return false
      }
      return true
    }

    override var isHidden: Bool {
      didSet { notifyVisibilityChanged() }
    }

    override func viewDidMoveToWindow() {
      super.viewDidMoveToWindow()
      updateWindowObservation()
      notifyVisibilityChanged()
    }

    override func viewDidMoveToSuperview() {
      super.viewDidMoveToSuperview()
      notifyVisibilityChanged()
    }

    override func setFrameSize(_ newSize: NSSize) {
      super.setFrameSize(newSize)
      notifyVisibilityChanged()
    }

    override func setBoundsSize(_ newSize: NSSize) {
      super.setBoundsSize(newSize)
      notifyVisibilityChanged()
    }

    deinit {
      MainActor.assumeIsolated {
        removeWindowObservers()
      }
    }

    private func updateWindowObservation() {
      guard observedWindow !== window else { return }
      removeWindowObservers()
      observedWindow = window
      guard let window else { return }
      observeWindow(NSWindow.didChangeOcclusionStateNotification, window: window)
      observeWindow(NSWindow.didMiniaturizeNotification, window: window)
      observeWindow(NSWindow.didDeminiaturizeNotification, window: window)
    }

    private func observeWindow(_ name: Notification.Name, window: NSWindow) {
      let observer = NotificationCenter.default.addObserver(
        forName: name,
        object: window,
        queue: .main
      ) { [weak self] _ in
        Task { @MainActor in
          self?.notifyVisibilityChanged()
        }
      }
      windowObservers.append(observer)
    }

    private func removeWindowObservers() {
      for observer in windowObservers {
        NotificationCenter.default.removeObserver(observer)
      }
      windowObservers.removeAll()
    }

    private func notifyVisibilityChanged() {
      onVisibilityChanged?(self)
    }
  }
#elseif os(iOS)
  @MainActor private final class VisibilityTrackingMTKView: MTKView {
    var onVisibilityChanged: ((VisibilityTrackingMTKView) -> Void)?

    var isVisibleForRendering: Bool {
      guard let window,
        !window.isHidden,
        window.alpha > 0.01,
        bounds.width > 0,
        bounds.height > 0
      else {
        return false
      }

      var visibleRect = convert(bounds, to: window)
      guard !visibleRect.isNull, !visibleRect.isEmpty else { return false }

      var currentView: UIView? = self
      while let view = currentView {
        guard !view.isHidden, view.alpha > 0.01 else { return false }
        if view.clipsToBounds {
          visibleRect = visibleRect.intersection(view.convert(view.bounds, to: window))
          guard !visibleRect.isNull, !visibleRect.isEmpty else { return false }
        }
        currentView = view.superview
      }

      return visibleRect.intersects(window.bounds)
    }

    override var isHidden: Bool {
      didSet { notifyVisibilityChanged() }
    }

    override var alpha: CGFloat {
      didSet { notifyVisibilityChanged() }
    }

    override func didMoveToWindow() {
      super.didMoveToWindow()
      notifyVisibilityChanged()
    }

    override func didMoveToSuperview() {
      super.didMoveToSuperview()
      notifyVisibilityChanged()
    }

    override func layoutSubviews() {
      super.layoutSubviews()
      notifyVisibilityChanged()
    }

    private func notifyVisibilityChanged() {
      onVisibilityChanged?(self)
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
