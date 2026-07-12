import AppKit
@_spi(Studio) import FoilShaders
import SwiftUI
import UniformTypeIdentifiers

@MainActor
final class StudioEditorModel: ObservableObject {
  @Published var selectedShader: StudioShader = .animatedMeshGradient
  @Published private(set) var presetIndexByShader: [StudioShader: Int]
  @Published private(set) var configurationByShader: [StudioShader: ShaderConfiguration]
  @Published var canvasPreset: StudioCanvasPreset = .widescreen
  @Published var customCanvasWidth = 1280.0
  @Published var customCanvasHeight = 720.0
  @Published var codeOutputMode: StudioCodeOutputMode = .presetBased
  @Published var didCopyCode = false

  weak var undoManager: UndoManager?

  private var copyFeedbackID = UUID()

  init() {
    presetIndexByShader = Dictionary(
      uniqueKeysWithValues: StudioShader.allCases.map { ($0, 0) }
    )
    configurationByShader = Dictionary(
      uniqueKeysWithValues: StudioShader.allCases.map { ($0, $0.configuration(at: 0)) }
    )
  }

  var selectedPresetIndex: Int {
    presetIndexByShader[selectedShader, default: 0]
  }

  var currentConfiguration: ShaderConfiguration {
    configurationByShader[selectedShader] ?? selectedShader.configuration(at: selectedPresetIndex)
  }

  var isCurrentConfigurationEdited: Bool {
    currentConfiguration != selectedShader.configuration(at: selectedPresetIndex)
  }

  var canvasSize: CGSize {
    canvasPreset.size(
      customWidth: max(1, customCanvasWidth),
      customHeight: max(1, customCanvasHeight)
    )
  }

  var canGeneratePresetBasedCode: Bool {
    let preset = selectedShader.configuration(at: selectedPresetIndex)
    return currentConfiguration.parameters == preset.parameters
      && currentConfiguration.image == preset.image
  }

  var currentCode: String {
    if codeOutputMode == .presetBased, canGeneratePresetBasedCode {
      return FoilShadersCodeGenerator.presetSwiftUIViewCode(
        componentName: selectedShader.componentName,
        presetReference: selectedShader.presetReference(at: selectedPresetIndex),
        sizing: currentConfiguration.sizing,
        motion: currentConfiguration.motion,
        renderOptions: currentConfiguration.renderOptions,
        layoutSize: canvasSize
      )
    }
    return FoilShadersCodeGenerator.standaloneSwiftUICode(
      configuration: currentConfiguration,
      layoutSize: canvasSize
    )
  }

  var parameterDescriptors: [StudioParameterDescriptor] {
    StudioParameterCodec.descriptors(
      for: currentConfiguration.parameters,
      shader: selectedShader
    )
  }

  func selectShader(_ shader: StudioShader) {
    selectedShader = shader
    codeOutputMode = canGeneratePresetBasedCode ? .presetBased : .standalone
  }

  func configurationForThumbnail(_ shader: StudioShader) -> ShaderConfiguration {
    configuration(for: shader)
  }

  func presetPreviewConfiguration(at index: Int) -> ShaderConfiguration {
    if index == selectedPresetIndex {
      return currentConfiguration
    }
    return selectedShader.configuration(at: index)
  }

  func configurationBinding<Value: Equatable>(
    _ keyPath: WritableKeyPath<ShaderConfiguration, Value>,
    actionName: String
  ) -> Binding<Value> {
    let shader = selectedShader
    return Binding(
      get: { self.configuration(for: shader)[keyPath: keyPath] },
      set: { newValue in
        var configuration = self.configuration(for: shader)
        guard configuration[keyPath: keyPath] != newValue else { return }
        configuration[keyPath: keyPath] = newValue
        self.setConfiguration(configuration, for: shader, actionName: actionName)
      }
    )
  }

  func selectPreset(_ index: Int) {
    let shader = selectedShader
    let boundedIndex = min(index, max(0, shader.presetCount - 1))
    let oldIndex = presetIndexByShader[shader, default: 0]
    let oldConfiguration = configuration(for: shader)
    let newConfiguration = shader.configuration(at: boundedIndex)
    guard oldIndex != boundedIndex || oldConfiguration != newConfiguration else { return }

    registerUndo(
      shader: shader,
      presetIndex: oldIndex,
      configuration: oldConfiguration,
      actionName: "Select Preset"
    )
    presetIndexByShader[shader] = boundedIndex
    configurationByShader[shader] = newConfiguration
    codeOutputMode = .presetBased
  }

  func resetToPreset() {
    let shader = selectedShader
    setConfiguration(
      shader.configuration(at: selectedPresetIndex),
      for: shader,
      actionName: "Reset to Preset"
    )
  }

  func setParameter(_ descriptor: StudioParameterDescriptor, value: StudioParameterValue) {
    guard
      let parameters = StudioParameterCodec.setting(
        descriptor.name,
        to: value,
        in: currentConfiguration.parameters
      )
    else { return }
    var configuration = currentConfiguration
    configuration.parameters = parameters
    setConfiguration(
      configuration,
      for: selectedShader,
      actionName: "Change \(descriptor.title)"
    )
  }

  func resetParameter(_ descriptor: StudioParameterDescriptor) {
    let preset = selectedShader.configuration(at: selectedPresetIndex)
    guard
      let value = StudioParameterCodec.value(
        named: descriptor.name,
        in: preset.parameters,
        shader: selectedShader
      )
    else { return }
    setParameter(descriptor, value: value)
  }

  func resetParametersToPreset() {
    let shader = selectedShader
    var configuration = currentConfiguration
    configuration.parameters = shader.configuration(at: selectedPresetIndex).parameters
    setConfiguration(configuration, for: shader, actionName: "Reset Parameters")
  }

  func chooseImage() {
    let panel = NSOpenPanel()
    panel.allowedContentTypes = [.image]
    panel.allowsMultipleSelection = false
    panel.canChooseDirectories = false
    if panel.runModal() == .OK, let url = panel.url {
      var configuration = currentConfiguration
      configuration.image = .url(url)
      setConfiguration(configuration, for: selectedShader, actionName: "Choose Image")
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

  private func configuration(for shader: StudioShader) -> ShaderConfiguration {
    configurationByShader[shader]
      ?? shader.configuration(at: presetIndexByShader[shader, default: 0])
  }

  private func setConfiguration(
    _ configuration: ShaderConfiguration,
    for shader: StudioShader,
    actionName: String
  ) {
    let oldConfiguration = self.configuration(for: shader)
    guard oldConfiguration != configuration else { return }
    registerUndo(
      shader: shader,
      presetIndex: presetIndexByShader[shader, default: 0],
      configuration: oldConfiguration,
      actionName: actionName
    )
    configurationByShader[shader] = configuration
    if shader == selectedShader, !canGeneratePresetBasedCode {
      codeOutputMode = .standalone
    }
  }

  private func registerUndo(
    shader: StudioShader,
    presetIndex: Int,
    configuration: ShaderConfiguration,
    actionName: String
  ) {
    undoManager?.registerUndo(withTarget: self) { model in
      let redoIndex = model.presetIndexByShader[shader, default: 0]
      let redoConfiguration = model.configuration(for: shader)
      model.registerUndo(
        shader: shader,
        presetIndex: redoIndex,
        configuration: redoConfiguration,
        actionName: actionName
      )
      model.presetIndexByShader[shader] = presetIndex
      model.configurationByShader[shader] = configuration
      if shader == model.selectedShader, !model.canGeneratePresetBasedCode {
        model.codeOutputMode = .standalone
      }
    }
    undoManager?.setActionName(actionName)
  }

}
