import AluminumFoil
import CoreGraphics
import Foundation
import ImageIO
import Metal
import UniformTypeIdentifiers

let arguments = CommandLine.arguments.dropFirst()
let outputURL: URL
if let first = arguments.first {
  outputURL = URL(fileURLWithPath: first)
} else {
  outputURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    .appendingPathComponent("aluminum-foil-export.png")
}

guard let device = MTLCreateSystemDefaultDevice() else {
  fputs("Metal is not available on this machine.\n", stderr)
  exit(1)
}

do {
  let renderer = try AluminumFoilRenderer(device: device)
  let configuration = MeshGradient(meshGradientPresets[0]).configuration
  try renderer.configure(configuration.kind)
  renderer.apply(configuration)
  renderer.setRenderSize(width: 1280, height: 720, pixelRatio: 1)

  guard let image = renderer.captureCurrentImage() else {
    fputs("Could not capture shader image.\n", stderr)
    exit(1)
  }

  guard
    let destination = CGImageDestinationCreateWithURL(
      outputURL as CFURL, UTType.png.identifier as CFString, 1, nil)
  else {
    fputs("Could not create PNG destination.\n", stderr)
    exit(1)
  }
  CGImageDestinationAddImage(destination, image, nil)
  guard CGImageDestinationFinalize(destination) else {
    fputs("Could not write PNG.\n", stderr)
    exit(1)
  }
  print(outputURL.path)
} catch {
  fputs("Export failed: \(error)\n", stderr)
  exit(1)
}
