import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

enum GoldenPNG {

  /// Decodes a golden PNG to raw RGBA8 bytes without any CGContext round-trip.
  /// CG bitmap contexts force premultiplied alpha and may color-match, which
  /// would corrupt exactly the semi-transparent pixels we need to compare, so
  /// we read the decoded buffer straight off the CGImage after asserting its
  /// layout. `testGoldenPNGDecodeIsByteExact` guards these assumptions.
  static func decodeRGBA8(from url: URL) throws -> (rgba: [UInt8], width: Int, height: Int) {
    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
      let image = CGImageSourceCreateImageAtIndex(source, 0, nil)
    else {
      throw ParityError.missingResource(url.lastPathComponent)
    }

    guard image.bitsPerComponent == 8, image.bitsPerPixel == 32 else {
      throw ParityError.unexpectedPNGLayout(
        "bitsPerComponent=\(image.bitsPerComponent) bitsPerPixel=\(image.bitsPerPixel)")
    }
    guard image.alphaInfo == .last else {
      throw ParityError.unexpectedPNGLayout("alphaInfo=\(image.alphaInfo.rawValue), expected .last")
    }
    let byteOrder = image.bitmapInfo.intersection(.byteOrderMask)
    guard byteOrder == .byteOrderDefault || byteOrder == .byteOrder32Big else {
      throw ParityError.unexpectedPNGLayout("byteOrder=\(byteOrder.rawValue)")
    }
    guard let data = image.dataProvider?.data as Data? else {
      throw ParityError.unexpectedPNGLayout("no data provider")
    }

    let width = image.width
    let height = image.height
    let bytesPerRow = image.bytesPerRow
    var rgba = [UInt8](repeating: 0, count: width * height * 4)
    data.withUnsafeBytes { (buffer: UnsafeRawBufferPointer) in
      for row in 0..<height {
        let sourceStart = row * bytesPerRow
        let destinationStart = row * width * 4
        for column in 0..<(width * 4) {
          rgba[destinationStart + column] = buffer[sourceStart + column]
        }
      }
    }
    return (rgba: rgba, width: width, height: height)
  }

  /// Writes raw RGBA8 bytes as a PNG (used for failure artifacts).
  static func write(rgba: [UInt8], width: Int, height: Int, to url: URL) throws {
    guard let provider = CGDataProvider(data: Data(rgba) as CFData),
      let image = CGImage(
        width: width,
        height: height,
        bitsPerComponent: 8,
        bitsPerPixel: 32,
        bytesPerRow: width * 4,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.last.rawValue).union(.byteOrder32Big),
        provider: provider,
        decode: nil,
        shouldInterpolate: false,
        intent: .defaultIntent
      ),
      let destination = CGImageDestinationCreateWithURL(
        url as CFURL, UTType.png.identifier as CFString, 1, nil)
    else {
      throw ParityError.unexpectedPNGLayout("could not create PNG at \(url.path)")
    }
    CGImageDestinationAddImage(destination, image, nil)
    guard CGImageDestinationFinalize(destination) else {
      throw ParityError.unexpectedPNGLayout("could not finalize PNG at \(url.path)")
    }
  }
}
