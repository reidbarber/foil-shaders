import AppKit
@_spi(Studio) import FoilShaders
import SwiftUI
import UniformTypeIdentifiers

@MainActor
final class StudioEditorModel: ObservableObject {
  @Published var selectedShader: StudioShader = .animatedMeshGradient
  @Published var presetIndexByShader: [StudioShader: Int] = [:]
  @Published var speed: Float = 0.25
  @Published var frame: Float = 0
  @Published var scale: Float = 1
  @Published var rotation: Float = 0
  @Published var offsetX: Float = 0
  @Published var offsetY: Float = 0
  @Published var selectedImage: ShaderImage?
  @Published var didCopyCode = false

  private var copyFeedbackID = UUID()

  var selectedPresetIndex: Int {
    get { presetIndexByShader[selectedShader, default: 0] }
    set {
      presetIndexByShader[selectedShader] = min(newValue, max(0, selectedShader.presetCount - 1))
    }
  }

  var currentConfiguration: ShaderConfiguration {
    var configuration = selectedShader.configuration(at: selectedPresetIndex)
    configuration.sizing.scale *= scale
    configuration.sizing.rotation = rotation
    configuration.sizing.offsetX = offsetX
    configuration.sizing.offsetY = offsetY
    configuration.motion.speed = speed
    configuration.motion.frame = frame
    if selectedShader.usesImage, let selectedImage {
      configuration.image = selectedImage
    }
    return configuration
  }

  var currentCode: String {
    FoilShadersCodeGenerator.swiftUICode(
      componentName: selectedShader.componentName,
      presetReference: selectedShader.presetReference(at: selectedPresetIndex),
      sizing: currentConfiguration.sizing,
      motion: currentConfiguration.motion,
      renderOptions: currentConfiguration.renderOptions,
      layoutSize: CGSize(width: 1280, height: 720)
    )
  }

  func chooseImage() {
    let panel = NSOpenPanel()
    panel.allowedContentTypes = [.image]
    panel.allowsMultipleSelection = false
    panel.canChooseDirectories = false
    if panel.runModal() == .OK, let url = panel.url {
      selectedImage = .url(url)
    }
  }

  func copyCurrentCode() {
    NSPasteboard.general.clearContents()
    NSPasteboard.general.setString(currentCode, forType: .string)

    let feedbackID = UUID()
    copyFeedbackID = feedbackID
    withAnimation(.easeOut(duration: 0.16)) {
      didCopyCode = true
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) { [weak self] in
      guard let self, self.copyFeedbackID == feedbackID else { return }
      withAnimation(.easeOut(duration: 0.16)) {
        self.didCopyCode = false
      }
    }
  }
}
