import SwiftUI

struct StudioInspectorView: View {
  @ObservedObject var model: StudioEditorModel

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 18) {
        StudioPresetBrowserView(model: model)

        if model.selectedShader.usesImage {
          Button("Choose Image", systemImage: "photo", action: model.chooseImage)
        }

        StudioParametersView(model: model)

        GroupBox("Motion") {
          StudioSlider(
            "Speed",
            value: model.configurationBinding(\.motion.speed, actionName: "Change Speed"),
            range: -2...2
          )
          StudioSlider(
            "Frame",
            value: model.configurationBinding(\.motion.frame, actionName: "Change Frame"),
            range: 0...5000
          )
        }

        GroupBox("Sizing") {
          StudioSlider(
            "Scale",
            value: model.configurationBinding(\.sizing.scale, actionName: "Change Scale"),
            range: 0.1...4
          )
          StudioSlider(
            "Rotation",
            value: model.configurationBinding(\.sizing.rotation, actionName: "Change Rotation"),
            range: 0...360
          )
          StudioSlider(
            "Offset X",
            value: model.configurationBinding(\.sizing.offsetX, actionName: "Change Offset X"),
            range: -1...1
          )
          StudioSlider(
            "Offset Y",
            value: model.configurationBinding(\.sizing.offsetY, actionName: "Change Offset Y"),
            range: -1...1
          )
        }

        StudioCodeView(
          code: model.currentCode,
          didCopy: model.didCopyCode,
          copy: model.copyCurrentCode
        )
      }
      .padding(18)
    }
    .background(.regularMaterial)
  }

}

private struct StudioSlider: View {
  let title: String
  @Binding var value: Float
  let range: ClosedRange<Float>

  init(_ title: String, value: Binding<Float>, range: ClosedRange<Float>) {
    self.title = title
    _value = value
    self.range = range
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      HStack {
        Text(title)
        Spacer()
        Text(value.formatted(.number.precision(.fractionLength(2))))
          .monospacedDigit()
          .foregroundStyle(.secondary)
      }
      Slider(value: $value, in: range)
    }
    .padding(.vertical, 4)
  }
}
