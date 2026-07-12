import AppKit
@_spi(Studio) import FoilShaders
import ImageIO
import Metal
import SwiftUI
import UniformTypeIdentifiers

struct StudioExportView: View {
  let exporter: StudioPreviewExporter
  let previewSize: CGSize

  var body: some View {
    Button("Copy Image", systemImage: "doc.on.clipboard") {
      exporter.copyImage(size: previewSize)
    }
    Button("Save Image...", systemImage: "square.and.arrow.down") {
      exporter.saveImage(size: previewSize)
    }
  }
}

@MainActor
struct StudioPreviewExporter {
  let configuration: ShaderConfiguration

  func copyImage(size: CGSize) {
    do {
      let image = try captureImage(size: size)
      let nsImage = NSImage(
        cgImage: image,
        size: NSSize(width: image.width, height: image.height)
      )
      guard let pngData = pngData(for: image), let tiffData = nsImage.tiffRepresentation else {
        throw PreviewImageError.pngEncodingFailed
      }

      let pasteboard = NSPasteboard.general
      pasteboard.declareTypes([.png, .tiff], owner: nil)
      pasteboard.setData(pngData, forType: .png)
      pasteboard.setData(tiffData, forType: .tiff)
    } catch {
      present(error)
    }
  }

  func saveImage(size: CGSize) {
    do {
      let image = try captureImage(size: size)
      let panel = NSSavePanel()
      panel.allowedContentTypes = [.png]
      panel.canCreateDirectories = true
      panel.nameFieldStringValue = "foil-shader-preview.png"

      guard panel.runModal() == .OK, let url = panel.url else { return }
      try writePNG(image, to: url)
    } catch {
      present(error)
    }
  }

  private func captureImage(size: CGSize) throws -> CGImage {
    guard let device = MTLCreateSystemDefaultDevice() else {
      throw PreviewImageError.metalUnavailable
    }

    var captureConfiguration = configuration
    captureConfiguration.motion.speed = 0
    let captureSize = previewCaptureSize(
      for: size,
      renderOptions: captureConfiguration.renderOptions
    )
    let renderer = try FoilShadersRenderer(device: device)
    try renderer.render(captureConfiguration)
    return try renderer.captureImage(
      width: captureSize.width,
      height: captureSize.height,
      pixelRatio: captureSize.pixelRatio
    )
  }

  private func previewCaptureSize(
    for pointSize: CGSize,
    renderOptions: ShaderRenderOptions
  ) -> (width: Int, height: Int, pixelRatio: Float) {
    let pointWidth = max(1.0, Double(pointSize.width))
    let pointHeight = max(1.0, Double(pointSize.height))
    let backingScale = Double(
      NSApp.keyWindow?.screen?.backingScaleFactor
        ?? NSScreen.main?.backingScaleFactor
        ?? 1.0
    )
    let targetScale = max(backingScale, Double(renderOptions.minPixelRatio))
    var pixelWidth = pointWidth * targetScale
    var pixelHeight = pointHeight * targetScale

    let maxPixels = Double(renderOptions.maxPixelCount)
    let targetPixels = pixelWidth * pixelHeight
    if maxPixels > 0, targetPixels > maxPixels {
      let downscale = (maxPixels / targetPixels).squareRoot()
      pixelWidth *= downscale
      pixelHeight *= downscale
    }

    let width = max(1, Int(pixelWidth.rounded()))
    let height = max(1, Int(pixelHeight.rounded()))
    return (width, height, Float(Double(width) / pointWidth))
  }

  private func pngData(for image: CGImage) -> Data? {
    let data = NSMutableData()
    guard
      let destination = CGImageDestinationCreateWithData(
        data, UTType.png.identifier as CFString, 1, nil)
    else {
      return nil
    }
    CGImageDestinationAddImage(destination, image, nil)
    guard CGImageDestinationFinalize(destination) else { return nil }
    return data as Data
  }

  private func writePNG(_ image: CGImage, to url: URL) throws {
    guard
      let destination = CGImageDestinationCreateWithURL(
        url as CFURL, UTType.png.identifier as CFString, 1, nil)
    else {
      throw PreviewImageError.cannotCreatePNGDestination(url)
    }
    CGImageDestinationAddImage(destination, image, nil)
    guard CGImageDestinationFinalize(destination) else {
      throw PreviewImageError.cannotWritePNG(url)
    }
  }

  private func present(_ error: Error) {
    NSAlert(error: error).runModal()
  }
}

private enum PreviewImageError: LocalizedError {
  case metalUnavailable
  case pngEncodingFailed
  case cannotCreatePNGDestination(URL)
  case cannotWritePNG(URL)

  var errorDescription: String? {
    switch self {
    case .metalUnavailable:
      "Metal is not available on this Mac."
    case .pngEncodingFailed:
      "Could not encode the preview image."
    case .cannotCreatePNGDestination(let url):
      "Could not create a PNG at \(url.path)."
    case .cannotWritePNG(let url):
      "Could not write the PNG at \(url.path)."
    }
  }
}
