@_spi(Studio) import FoilShaders
import SwiftUI

struct StudioSidebarView: View {
  @ObservedObject var model: StudioEditorModel

  private var selection: Binding<StudioShader> {
    Binding(
      get: { model.selectedShader },
      set: { model.selectShader($0) }
    )
  }

  var body: some View {
    List(selection: selection) {
      ForEach(StudioShaderCategory.allCases) { category in
        Section(category.rawValue) {
          ForEach(StudioShader.allCases.filter { $0.category == category }) { shader in
            StudioShaderRow(
              shader: shader,
              configuration: model.configurationForThumbnail(shader)
            )
            .tag(shader)
          }
        }
      }
    }
    .navigationTitle("Shaders")
    .navigationSplitViewColumnWidth(min: 220, ideal: 280, max: 360)
  }
}

private struct StudioShaderRow: View {
  let shader: StudioShader
  let configuration: ShaderConfiguration

  var body: some View {
    HStack(spacing: 10) {
      FoilShaderView(configuration: configuration)
        .allowsHitTesting(false)
        .frame(width: 64, height: 40)
        .background(.black.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 5))

      Text(shader.displayName)
        .lineLimit(1)
    }
    .padding(.vertical, 2)
  }
}
