import AppKit
@_spi(Studio) import FoilShaders
import SwiftUI

struct StudioPreviewView: View {
  @ObservedObject var model: StudioEditorModel

  @State private var zoom: StudioPreviewZoom = .fit

  private var canvasSize: CGSize {
    model.canvasSize
  }

  var body: some View {
    GeometryReader { proxy in
      let footerHeight = model.canvasPreset == .custom ? 84.0 : 48.0
      let viewport = CGSize(
        width: max(1, proxy.size.width - 32),
        height: max(1, proxy.size.height - footerHeight - 32)
      )
      let displaySize = previewDisplaySize(in: viewport)
      let exporter = StudioPreviewExporter(configuration: model.currentConfiguration)

      VStack(spacing: 0) {
        ScrollView([.horizontal, .vertical]) {
          StudioPreviewCanvas(
            configuration: model.currentConfiguration,
            size: displaySize
          )
          .contextMenu {
            StudioExportView(exporter: exporter, previewSize: displaySize)
          }
          .frame(
            minWidth: proxy.size.width - 32,
            minHeight: proxy.size.height - footerHeight - 32
          )
          .padding(16)
        }

        Divider()

        StudioPreviewFooter(
          canvasSize: canvasSize,
          canvasPreset: $model.canvasPreset,
          customWidth: $model.customCanvasWidth,
          customHeight: $model.customCanvasHeight,
          zoom: $zoom,
          toggleFullScreen: toggleFullScreen,
          copy: { exporter.copyImage(size: displaySize) },
          export: { exporter.saveImage(size: displaySize) }
        )
      }
    }
    .frame(minWidth: 300, minHeight: 240)
  }

  private func previewDisplaySize(in viewport: CGSize) -> CGSize {
    switch zoom {
    case .fit:
      fittedSize(canvasSize, in: viewport)
    default:
      CGSize(
        width: canvasSize.width * zoom.scale,
        height: canvasSize.height * zoom.scale
      )
    }
  }

  private func fittedSize(_ size: CGSize, in availableSize: CGSize) -> CGSize {
    let scale = min(
      availableSize.width / max(1, size.width),
      availableSize.height / max(1, size.height)
    )
    return CGSize(width: size.width * scale, height: size.height * scale)
  }

  private func toggleFullScreen() {
    NSApp.keyWindow?.toggleFullScreen(nil)
  }
}

private struct StudioPreviewCanvas: View {
  let configuration: ShaderConfiguration
  let size: CGSize

  var body: some View {
    FoilShaderView(configuration: configuration)
      .frame(width: size.width, height: size.height)
      .background(.black.opacity(0.08))
      .clipShape(RoundedRectangle(cornerRadius: 8))
      .overlay {
        RoundedRectangle(cornerRadius: 8)
          .stroke(.black.opacity(0.15), lineWidth: 1)
      }
      .shadow(color: .black.opacity(0.16), radius: 12, y: 4)
  }
}

private struct StudioPreviewFooter: View {
  let canvasSize: CGSize
  @Binding var canvasPreset: StudioCanvasPreset
  @Binding var customWidth: Double
  @Binding var customHeight: Double
  @Binding var zoom: StudioPreviewZoom
  let toggleFullScreen: () -> Void
  let copy: () -> Void
  let export: () -> Void

  var body: some View {
    VStack(spacing: 6) {
      HStack(spacing: 10) {
        Text("\(Int(canvasSize.width)) × \(Int(canvasSize.height))")
          .font(.caption)
          .foregroundStyle(.secondary)

        Picker("Canvas", selection: $canvasPreset) {
          ForEach(StudioCanvasPreset.allCases) { preset in
            Text(preset.title).tag(preset)
          }
        }
        .labelsHidden()
        .frame(width: 105)

        Picker("Zoom", selection: $zoom) {
          ForEach(StudioPreviewZoom.allCases) { zoom in
            Text(zoom.title).tag(zoom)
          }
        }
        .labelsHidden()
        .frame(width: 76)

        Button("Full Screen", systemImage: "arrow.up.left.and.arrow.down.right") {
          toggleFullScreen()
        }
        .labelStyle(.iconOnly)

        Spacer(minLength: 0)

        Button("Copy", systemImage: "doc.on.clipboard", action: copy)
        Button("Export", systemImage: "square.and.arrow.up", action: export)
          .buttonStyle(.borderedProminent)
      }

      if canvasPreset == .custom {
        HStack {
          Text("Custom Canvas")
            .foregroundStyle(.secondary)
          TextField("Width", value: $customWidth, format: .number.precision(.fractionLength(0)))
          Text("×")
          TextField("Height", value: $customHeight, format: .number.precision(.fractionLength(0)))
          Spacer()
        }
        .textFieldStyle(.roundedBorder)
      }
    }
    .controlSize(.small)
    .padding(.horizontal, 12)
    .padding(.vertical, 7)
    .background(.regularMaterial)
  }
}

private enum StudioPreviewZoom: String, CaseIterable, Identifiable {
  case fit
  case quarter
  case half
  case actual
  case double

  var id: String { rawValue }

  var title: String {
    switch self {
    case .fit: "Fit"
    case .quarter: "25%"
    case .half: "50%"
    case .actual: "100%"
    case .double: "200%"
    }
  }

  var scale: CGFloat {
    switch self {
    case .fit: 1
    case .quarter: 0.25
    case .half: 0.5
    case .actual: 1
    case .double: 2
    }
  }
}
