import AppKit
@_spi(Studio) import FoilShaders
import SwiftUI

struct StudioParametersView: View {
  @ObservedObject var model: StudioEditorModel

  var body: some View {
    GroupBox {
      VStack(alignment: .leading, spacing: 12) {
        ForEach(model.parameterDescriptors) { descriptor in
          StudioParameterRow(
            descriptor: descriptor,
            setValue: { model.setParameter(descriptor, value: $0) },
            reset: { model.resetParameter(descriptor) }
          )
          if descriptor.id != model.parameterDescriptors.last?.id {
            Divider()
          }
        }
      }
      .padding(.vertical, 4)
    } label: {
      HStack {
        Text("Parameters")
        Spacer()
        Button(
          "Reset Parameters",
          systemImage: "arrow.counterclockwise",
          action: model.resetParametersToPreset
        )
        .labelStyle(.iconOnly)
        .buttonStyle(.borderless)
        .help("Reset all shader parameters to the selected preset")
      }
    }
  }
}

private struct StudioParameterRow: View {
  let descriptor: StudioParameterDescriptor
  let setValue: (StudioParameterValue) -> Void
  let reset: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      HStack {
        Text(descriptor.title)
        Spacer()
        Button("Reset \(descriptor.title)", systemImage: "arrow.counterclockwise", action: reset)
          .labelStyle(.iconOnly)
          .buttonStyle(.borderless)
          .help("Reset \(descriptor.title) to the selected preset")
      }
      control
    }
  }

  @ViewBuilder
  private var control: some View {
    switch descriptor.value {
    case .number(let value):
      StudioParameterSlider(
        value: value,
        range: descriptor.range ?? 0...1,
        setValue: { setValue(.number($0)) }
      )
    case .boolean(let value):
      Toggle(
        descriptor.title,
        isOn: Binding(
          get: { value },
          set: { setValue(.boolean($0)) }
        )
      )
      .labelsHidden()
    case .option(let value, let options):
      Picker(
        descriptor.title,
        selection: Binding(
          get: { value },
          set: { setValue(.option($0, options: options)) }
        )
      ) {
        ForEach(options, id: \.self) { option in
          Text(option.unCamelCased.capitalized).tag(option)
        }
      }
      .labelsHidden()
      .pickerStyle(.menu)
    case .color(let color):
      ColorPicker(
        descriptor.title,
        selection: colorBinding(color),
        supportsOpacity: true
      )
      .labelsHidden()
    case .palette(let colors):
      StudioPaletteEditor(colors: colors) {
        setValue(.palette($0))
      }
    }
  }

  private func colorBinding(_ color: ShaderColor) -> Binding<Color> {
    Binding(
      get: { Color(shaderColor: color) },
      set: { newColor in
        guard let shaderColor = ShaderColor(NSColor(newColor).cgColor) else { return }
        setValue(.color(shaderColor))
      }
    )
  }
}

private struct StudioParameterSlider: View {
  let value: Float
  let range: ClosedRange<Float>
  let setValue: (Float) -> Void

  var body: some View {
    HStack {
      Slider(
        value: Binding(get: { value }, set: { newValue in setValue(newValue) }),
        in: range
      )
      Text(value.formatted(.number.precision(.fractionLength(2))))
        .monospacedDigit()
        .foregroundStyle(.secondary)
        .frame(width: 48, alignment: .trailing)
    }
  }
}

private struct StudioPaletteEditor: View {
  let colors: [ShaderColor]
  let setColors: ([ShaderColor]) -> Void

  var body: some View {
    VStack(spacing: 6) {
      ForEach(Array(colors.enumerated()), id: \.offset) { index, color in
        HStack(spacing: 6) {
          ColorPicker(
            "Color \(index + 1)",
            selection: paletteColorBinding(at: index, color: color),
            supportsOpacity: true
          )
          .labelsHidden()
          Text("Color \(index + 1)")
            .foregroundStyle(.secondary)
          Spacer()
          Button("Move Up", systemImage: "chevron.up") { move(index, by: -1) }
            .disabled(index == colors.startIndex)
          Button("Move Down", systemImage: "chevron.down") { move(index, by: 1) }
            .disabled(index == colors.index(before: colors.endIndex))
          Button("Remove", systemImage: "minus") { remove(index) }
            .disabled(colors.count <= 1)
        }
        .labelStyle(.iconOnly)
        .buttonStyle(.borderless)
      }

      Button("Add Color", systemImage: "plus") {
        setColors(colors + [colors.last ?? .white])
      }
      .disabled(colors.count >= 10)
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }

  private func paletteColorBinding(at index: Int, color: ShaderColor) -> Binding<Color> {
    Binding(
      get: { Color(shaderColor: color) },
      set: { newColor in
        guard let shaderColor = ShaderColor(NSColor(newColor).cgColor) else { return }
        var updated = colors
        updated[index] = shaderColor
        setColors(updated)
      }
    )
  }

  private func move(_ index: Int, by offset: Int) {
    var updated = colors
    updated.swapAt(index, index + offset)
    setColors(updated)
  }

  private func remove(_ index: Int) {
    var updated = colors
    updated.remove(at: index)
    setColors(updated)
  }
}

extension Color {
  fileprivate init(shaderColor: ShaderColor) {
    self.init(
      .sRGB,
      red: Double(shaderColor.red),
      green: Double(shaderColor.green),
      blue: Double(shaderColor.blue),
      opacity: Double(shaderColor.alpha)
    )
  }
}

extension String {
  fileprivate var unCamelCased: String {
    unicodeScalars.reduce(into: "") { result, scalar in
      if CharacterSet.uppercaseLetters.contains(scalar), !result.isEmpty {
        result.append(" ")
      }
      result.append(Character(scalar))
    }
  }
}
