import Foundation

struct ParityTolerance {
  /// Max per-channel delta a pixel may have before it counts as "bad".
  var channelTolerance: UInt8 = 2
  /// Max fraction of pixels allowed to exceed `channelTolerance`.
  var maxBadPixelFraction: Double = 0.005
  /// Max mean per-channel delta across the whole image; catches global shifts
  /// (colorspace / premultiply mistakes) hiding under the fraction cap.
  var maxMeanChannelDelta: Double = 1.0
}

enum ParityTolerances {
  static let `default` = ParityTolerance()

  /// Shader-level overrides. Shaders with thin anti-aliased edges, hard color
  /// steps, or per-pixel hash noise flip pixels on 1-ulp float differences, so
  /// they're governed by the bad-pixel fraction (and the mean-delta cap, which
  /// still catches systematic shifts) instead of the per-channel tolerance.
  /// Fractions are tuned from observed stats on Apple Silicon vs the
  /// SwiftShader-generated goldens, with roughly 40–50% headroom.
  static let shaderOverrides: [String: ParityTolerance] = [
    // Thin anti-aliased band/line edges (observed worst-preset fractions in
    // parentheses).
    "swirl": ParityTolerance(maxBadPixelFraction: 0.06),  // (4.7%)
    "waves": ParityTolerance(maxBadPixelFraction: 0.15),  // (10.5%)
    "voronoi": ParityTolerance(maxBadPixelFraction: 0.15),  // (10.4%)
    "warp": ParityTolerance(maxBadPixelFraction: 0.12),  // (8.2%)
    "fluted-glass": ParityTolerance(maxBadPixelFraction: 0.15),  // (10.8%)
    "dot-grid": ParityTolerance(maxBadPixelFraction: 0.03),  // (2.1%)
    "metaballs": ParityTolerance(maxBadPixelFraction: 0.02),  // (1.1%)
    "smoke-ring": ParityTolerance(maxBadPixelFraction: 0.02),  // (1.1%)
    "pulsing-border": ParityTolerance(maxBadPixelFraction: 0.025),  // (1.8%)
    "color-panels": ParityTolerance(maxBadPixelFraction: 0.01),  // (0.6%)
    // Noise-texture-driven speckle decorrelates per pixel (observed 3.2%).
    "dot-orbit": ParityTolerance(maxBadPixelFraction: 0.05),
    // Iso-contour stepping over smooth noise flips large soft regions by a
    // few counts (observed 26.6% on Moss with mean delta 0.67).
    "perlin-noise": ParityTolerance(maxBadPixelFraction: 0.35),
    // Fiber speckle decorrelates on isolated pixels (observed 2.4%; the
    // Default preset is a known structural gap, tracked separately).
    "paper-texture": ParityTolerance(maxBadPixelFraction: 0.04),
  ]

  /// Per-preset overrides keyed by "<shader>/<preset name>"; these win over
  /// shader-level overrides.
  static let caseOverrides: [String: ParityTolerance] = [
    // Cross Section has hard color-step contours; the step boundary pixels
    // flip on precision noise (observed 0.71%).
    "static-radial-gradient/Cross Section": ParityTolerance(maxBadPixelFraction: 0.015),
    // Lo-Fi is dominated by hash-based grain, which decorrelates per-pixel
    // across float implementations (observed 36% flipped grain pixels, mean
    // delta ~1.0; a structural bug pushes the mean far above 2).
    "static-radial-gradient/Lo-Fi": ParityTolerance(
      maxBadPixelFraction: 0.45, maxMeanChannelDelta: 2.0),
  ]

  static func tolerance(for parityCase: ParityCase) -> ParityTolerance {
    caseOverrides["\(parityCase.shader)/\(parityCase.presetName)"]
      ?? shaderOverrides[parityCase.shader]
      ?? `default`
  }
}

struct PixelComparisonResult {
  var maxChannelDelta: Int = 0
  var meanChannelDelta: Double = 0
  var badPixelCount: Int = 0
  var badPixelFraction: Double = 0
  var worstPixel: (x: Int, y: Int, expected: SIMD4<UInt8>, actual: SIMD4<UInt8>)?

  func passes(_ tolerance: ParityTolerance) -> Bool {
    badPixelFraction <= tolerance.maxBadPixelFraction
      && meanChannelDelta <= tolerance.maxMeanChannelDelta
  }

  var summary: String {
    var text =
      "maxChannelDelta=\(maxChannelDelta) meanChannelDelta=\(String(format: "%.4f", meanChannelDelta)) "
      + "badPixels=\(badPixelCount) (\(String(format: "%.3f%%", badPixelFraction * 100)))"
    if let worst = worstPixel {
      text +=
        " worst@(\(worst.x),\(worst.y)) expected=\(worst.expected) actual=\(worst.actual)"
    }
    return text
  }
}

/// Per-pixel RGBA8 comparison across all four channels (alpha included —
/// several shaders emit transparent backgrounds).
func comparePixels(
  expected: [UInt8], actual: [UInt8], width: Int, height: Int, channelTolerance: UInt8
) -> PixelComparisonResult {
  precondition(expected.count == width * height * 4, "golden byte count mismatch")
  precondition(actual.count == expected.count, "render byte count mismatch")

  var result = PixelComparisonResult()
  var totalDelta = 0
  var worstDelta = -1

  for pixel in 0..<(width * height) {
    let base = pixel * 4
    var pixelMaxDelta = 0
    for channel in 0..<4 {
      let delta = abs(Int(expected[base + channel]) - Int(actual[base + channel]))
      totalDelta += delta
      if delta > pixelMaxDelta { pixelMaxDelta = delta }
    }
    if pixelMaxDelta > result.maxChannelDelta { result.maxChannelDelta = pixelMaxDelta }
    if pixelMaxDelta > Int(channelTolerance) {
      result.badPixelCount += 1
      if pixelMaxDelta > worstDelta {
        worstDelta = pixelMaxDelta
        result.worstPixel = (
          x: pixel % width,
          y: pixel / width,
          expected: SIMD4(
            expected[base], expected[base + 1], expected[base + 2], expected[base + 3]),
          actual: SIMD4(actual[base], actual[base + 1], actual[base + 2], actual[base + 3])
        )
      }
    }
  }

  result.meanChannelDelta = Double(totalDelta) / Double(width * height * 4)
  result.badPixelFraction = Double(result.badPixelCount) / Double(width * height)
  return result
}
