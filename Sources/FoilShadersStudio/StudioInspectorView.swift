import SwiftUI

struct StudioInspectorView: View {
  @ObservedObject var model: StudioEditorModel

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 18) {
        Picker("Preset", selection: $model.selectedPresetIndex) {
          ForEach(0..<model.selectedShader.presetCount, id: \.self) { index in
            Text(model.selectedShader.presetName(at: index)).tag(index)
          }
        }
        .pickerStyle(.menu)

        if model.selectedShader.usesImage {
          Button("Choose Image", systemImage: "photo", action: model.chooseImage)
        }

        GroupBox("Motion") {
          StudioSlider("Speed", value: $model.speed, range: -2...2)
          StudioSlider("Frame", value: $model.frame, range: 0...5000)
        }

        GroupBox("Sizing") {
          StudioSlider("Scale", value: $model.scale, range: 0.1...4)
          StudioSlider("Rotation", value: $model.rotation, range: 0...360)
          StudioSlider("Offset X", value: $model.offsetX, range: -1...1)
          StudioSlider("Offset Y", value: $model.offsetY, range: -1...1)
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
