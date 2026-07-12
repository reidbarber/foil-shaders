@_spi(Studio) import FoilShaders
import SwiftUI

struct StudioPreviewView: View {
  let configuration: ShaderConfiguration
  let exporter: StudioPreviewExporter

  var body: some View {
    GeometryReader { proxy in
      let availableSize = CGSize(
        width: max(1, proxy.size.width - 32),
        height: max(1, proxy.size.height - 32)
      )
      let previewSize = fittedPreviewSize(in: availableSize)

      FoilShaderView(configuration: configuration)
        .frame(width: previewSize.width, height: previewSize.height)
        .background(.black.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .contextMenu {
          StudioExportView(exporter: exporter, previewSize: previewSize)
        }
        .frame(width: proxy.size.width, height: proxy.size.height)
    }
    .frame(minWidth: 300, minHeight: 240)
  }

  private func fittedPreviewSize(in availableSize: CGSize) -> CGSize {
    let aspectRatio = CGFloat(16.0 / 9.0)
    let availableWidth = max(1, availableSize.width)
    let availableHeight = max(1, availableSize.height)
    let widthForHeight = availableHeight * aspectRatio

    if widthForHeight <= availableWidth {
      return CGSize(width: widthForHeight, height: availableHeight)
    }
    return CGSize(width: availableWidth, height: availableWidth / aspectRatio)
  }
}
