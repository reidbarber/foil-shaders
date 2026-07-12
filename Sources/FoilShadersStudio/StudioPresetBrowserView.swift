@_spi(Studio) import FoilShaders
import SwiftUI

struct StudioPresetBrowserView: View {
  @ObservedObject var model: StudioEditorModel

  private let columns = [
    GridItem(.flexible(), spacing: 10),
    GridItem(.flexible(), spacing: 10),
  ]

  var body: some View {
    GroupBox {
      LazyVGrid(columns: columns, spacing: 10) {
        ForEach(0..<model.selectedShader.presetCount, id: \.self) { index in
          StudioPresetCard(
            name: presetLabel(at: index),
            configuration: model.presetPreviewConfiguration(at: index),
            isSelected: index == model.selectedPresetIndex,
            select: { model.selectPreset(index) }
          )
        }
      }
      .padding(.vertical, 4)
    } label: {
      HStack {
        Text("Presets")
        Spacer()
        Button(
          "Reset to Preset",
          systemImage: "arrow.counterclockwise",
          action: model.resetToPreset
        )
        .labelStyle(.iconOnly)
        .buttonStyle(.borderless)
        .disabled(!model.isCurrentConfigurationEdited)
        .help("Reset all edits to the selected preset")
      }
    }
  }

  private func presetLabel(at index: Int) -> String {
    let name = model.selectedShader.presetName(at: index)
    if index == model.selectedPresetIndex, model.isCurrentConfigurationEdited {
      return "\(name) • Edited"
    }
    return name
  }
}

private struct StudioPresetCard: View {
  let name: String
  let configuration: ShaderConfiguration
  let isSelected: Bool
  let select: () -> Void

  var body: some View {
    Button(action: select) {
      VStack(alignment: .leading, spacing: 6) {
        FoilShaderView(configuration: configuration)
          .allowsHitTesting(false)
          .aspectRatio(16 / 9, contentMode: .fit)
          .background(.black.opacity(0.08))
          .clipShape(RoundedRectangle(cornerRadius: 6))

        Text(name)
          .font(.caption)
          .lineLimit(1)
      }
      .padding(6)
      .background(
        RoundedRectangle(cornerRadius: 8)
          .fill(isSelected ? Color.accentColor.opacity(0.16) : Color.clear)
      )
      .overlay {
        RoundedRectangle(cornerRadius: 8)
          .stroke(isSelected ? Color.accentColor : Color.secondary.opacity(0.2), lineWidth: 1)
      }
    }
    .buttonStyle(.plain)
  }
}
