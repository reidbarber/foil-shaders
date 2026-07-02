import Foundation

enum FailureArtifacts {
  static let directory: URL = {
    let base: URL
    if let override = ProcessInfo.processInfo.environment["PARITY_ARTIFACTS_DIR"] {
      base = URL(fileURLWithPath: override)
    } else {
      base = URL(fileURLWithPath: NSTemporaryDirectory())
        .appendingPathComponent("aluminum-foil-parity")
    }
    try? FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
    return base
  }()

  /// Writes expected/actual/diff PNGs for a failed case and returns the paths.
  static func write(
    caseID: String, expected: [UInt8], actual: [UInt8], width: Int, height: Int
  ) -> URL? {
    let slug = caseID.replacingOccurrences(
      of: "[^A-Za-z0-9]+", with: "-", options: .regularExpression)

    // Per-channel |delta| × 8 (clamped), opaque alpha, so faint diffs are visible.
    var diff = [UInt8](repeating: 0, count: expected.count)
    for pixel in 0..<(width * height) {
      let base = pixel * 4
      for channel in 0..<3 {
        let delta = abs(Int(expected[base + channel]) - Int(actual[base + channel]))
        diff[base + channel] = UInt8(min(255, delta * 8))
      }
      let alphaDelta = abs(Int(expected[base + 3]) - Int(actual[base + 3]))
      // Fold alpha differences into all three channels so they aren't invisible.
      if alphaDelta > 0 {
        for channel in 0..<3 {
          diff[base + channel] = UInt8(min(255, Int(diff[base + channel]) + alphaDelta * 8))
        }
      }
      diff[base + 3] = 255
    }

    do {
      let expectedURL = directory.appendingPathComponent("\(slug)-expected.png")
      let actualURL = directory.appendingPathComponent("\(slug)-actual.png")
      let diffURL = directory.appendingPathComponent("\(slug)-diff.png")
      try GoldenPNG.write(rgba: expected, width: width, height: height, to: expectedURL)
      try GoldenPNG.write(rgba: actual, width: width, height: height, to: actualURL)
      try GoldenPNG.write(rgba: diff, width: width, height: height, to: diffURL)
      return directory
    } catch {
      return nil
    }
  }
}
