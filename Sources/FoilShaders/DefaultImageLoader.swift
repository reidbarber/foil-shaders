import Foundation
import ImageIO
import UniformTypeIdentifiers

#if canImport(UIKit)
  import UIKit
#elseif canImport(AppKit)
  import AppKit
#endif

enum FoilShadersDefaultImageLoader {
  static func loadCGImage(from url: URL) -> CGImage? {
    if let data = try? Data(contentsOf: url),
      let image = loadCGImage(from: data)
    {
      return image
    }
    #if canImport(AppKit)
      if let nsImage = NSImage(contentsOf: url) {
        return nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil)
      }
    #elseif canImport(UIKit)
      if let uiImage = UIImage(contentsOfFile: url.path) {
        return uiImage.cgImage
      }
    #endif
    return nil
  }

  static func loadCGImage(from data: Data) -> CGImage? {
    let options: [CFString: Any] = [
      kCGImageSourceShouldCache: true,
      kCGImageSourceTypeIdentifierHint: UTType.svg.identifier,
    ]
    if let source = CGImageSourceCreateWithData(data as CFData, options as CFDictionary),
      let image = CGImageSourceCreateImageAtIndex(source, 0, options as CFDictionary)
    {
      return image
    }
    #if canImport(AppKit)
      if let nsImage = NSImage(data: data) {
        return nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil)
      }
    #elseif canImport(UIKit)
      if let uiImage = UIImage(data: data) {
        return uiImage.cgImage
      }
    #endif
    return nil
  }
}
