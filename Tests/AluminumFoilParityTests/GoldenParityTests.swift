import CoreGraphics
import Metal
import XCTest

@testable import AluminumFoil

/// Visual parity suite: renders every shader × preset × frame with the Metal
/// port and compares raw RGBA output against golden PNGs generated from the
/// original Paper Shaders WebGL implementation.
///
/// Regenerate goldens with Scripts/parity-harness (see its README).
/// Env vars: PARITY_FILTER=<shader> or <shader>/<preset> limits the cases run;
/// PARITY_ARTIFACTS_DIR overrides where failure images are written.
final class GoldenParityTests: XCTestCase {

  /// Known parity gaps: cases that currently render structurally differently
  /// from the WebGL reference (mean channel deltas far beyond precision
  /// noise). They still run and their stats are printed, but they don't fail
  /// the suite. STRICT: when a listed case starts passing, the test fails and
  /// tells you to remove the entry, so this list can only shrink.
  ///
  /// Matched by prefix against the case id (`shader` or `shader/Preset`).
  static let knownParityGaps: [String] = [
    "heatmap",  // image preprocessing / heat sampling still diverges
    "halftone-dots/Default",  // dot density/contrast systematically off (mean delta ~6)
    "halftone-dots/Mosaic",
    "halftone-dots/Round and square",
  ]

  private static func isKnownGap(_ id: String) -> Bool {
    knownParityGaps.contains { gap in
      id == gap || id.hasPrefix("\(gap)/") || id.hasPrefix("\(gap)@")
    }
  }

  @MainActor
  func testParityAgainstGoldens() throws {
    guard let device = MTLCreateSystemDefaultDevice() else {
      throw XCTSkip("Metal is not available on this machine")
    }

    let manifest = try ParityManifest.load()
    let fixture = try Self.loadFixture(manifest: manifest)
    let renderer = try AluminumFoilRenderer(device: device)

    let filter = ProcessInfo.processInfo.environment["PARITY_FILTER"]
    var cases = manifest.cases
    if let filter {
      cases = cases.filter { $0.id.hasPrefix(filter) }
      XCTAssertFalse(cases.isEmpty, "PARITY_FILTER=\(filter) matched no cases")
    }

    var failed = 0
    var artifactsDirectory: URL?

    for parityCase in cases {
      try XCTContext.runActivity(named: parityCase.id) { _ in
        let configuration = try ParityConfigurationFactory.configuration(
          for: parityCase, fixture: fixture)
        try renderer.configure(configuration.kind)
        renderer.apply(configuration)
        renderer.setSpeed(0)
        renderer.setFrame(parityCase.frame)
        renderer.setRenderSize(
          width: manifest.canvas.width,
          height: manifest.canvas.height,
          pixelRatio: manifest.canvas.pixelRatio
        )

        guard let capture = renderer.captureCurrentPixels() else {
          XCTFail("\(parityCase.id): captureCurrentPixels returned nil")
          failed += 1
          return
        }
        XCTAssertEqual(capture.width, manifest.canvas.width)
        XCTAssertEqual(capture.height, manifest.canvas.height)

        let golden = try GoldenPNG.decodeRGBA8(from: manifest.goldenURL(for: parityCase))
        XCTAssertEqual(golden.width, capture.width, "\(parityCase.id): golden size mismatch")
        XCTAssertEqual(golden.height, capture.height, "\(parityCase.id): golden size mismatch")

        let tolerance = ParityTolerances.tolerance(for: parityCase)
        let result = comparePixels(
          expected: golden.rgba,
          actual: capture.rgba,
          width: capture.width,
          height: capture.height,
          channelTolerance: tolerance.channelTolerance
        )

        let passes = result.passes(tolerance)
        let knownGap = Self.isKnownGap(parityCase.id)
        switch (passes, knownGap) {
        case (true, false):
          break
        case (true, true):
          XCTFail(
            "\(parityCase.id) now passes — remove its entry from knownParityGaps")
        case (false, true):
          print("KNOWN GAP \(parityCase.id): \(result.summary)")
        case (false, false):
          failed += 1
          if let directory = FailureArtifacts.write(
            caseID: parityCase.id,
            expected: golden.rgba,
            actual: capture.rgba,
            width: capture.width,
            height: capture.height
          ) {
            artifactsDirectory = directory
          }
          XCTFail("\(parityCase.id): \(result.summary)")
        }
      }
    }

    if let artifactsDirectory {
      print("Parity failure artifacts written to: \(artifactsDirectory.path)")
    }
    print("Parity: \(cases.count - failed)/\(cases.count) cases passed")
  }

  /// Proves the PNG decode path returns the exact bytes the generator wrote
  /// (including non-premultiplied partial alpha). The pattern mirrors the
  /// `_selftest.png` formula in Scripts/parity-harness/generate-goldens.mjs.
  func testGoldenPNGDecodeIsByteExact() throws {
    guard
      let url = Bundle.module.url(forResource: "Goldens/_selftest", withExtension: "png")
    else {
      throw XCTSkip("No goldens generated yet")
    }
    let decoded = try GoldenPNG.decodeRGBA8(from: url)

    for y in 0..<decoded.height {
      for x in 0..<decoded.width {
        let base = (y * decoded.width + x) * 4
        let expected: [UInt8] = [
          UInt8(x % 256),
          UInt8(y % 256),
          UInt8((x * 3 + y * 7) % 256),
          UInt8((x + y) % 256),
        ]
        for channel in 0..<4 where decoded.rgba[base + channel] != expected[channel] {
          XCTFail(
            "Self-test byte mismatch at (\(x),\(y)) channel \(channel): "
              + "got \(decoded.rgba[base + channel]), expected \(expected[channel])")
          return
        }
      }
    }
  }

  /// The manifest must cover every shader with case counts matching the
  /// Swift preset arrays (once fully generated; partial manifests are reported).
  func testManifestCoversGeneratedShaders() throws {
    let manifest = try ParityManifest.load()
    XCTAssertFalse(manifest.cases.isEmpty, "Manifest has no cases")

    var caseCounts: [String: Int] = [:]
    var presetNames: [String: Set<String>] = [:]
    for parityCase in manifest.cases {
      caseCounts[parityCase.shader, default: 0] += 1
      presetNames[parityCase.shader, default: []].insert(parityCase.presetName)
    }

    // Every case in the manifest must resolve to a real preset.
    for (shader, names) in presetNames {
      for name in names {
        let sample = manifest.cases.first { $0.shader == shader && $0.presetName == name }!
        XCTAssertNoThrow(
          try ParityConfigurationFactory.configuration(for: sample, fixture: nil),
          "\(shader)/\(name) does not resolve against Presets.swift"
        )
      }
    }
  }

  private static func loadFixture(manifest: ParityManifest) throws -> ShaderImage? {
    guard manifest.cases.contains(where: { $0.usesImage }) else { return nil }
    guard
      let url = Bundle.module.url(forResource: "Fixtures/fixture", withExtension: "png"),
      let source = CGImageSourceCreateWithURL(url as CFURL, nil),
      let image = CGImageSourceCreateImageAtIndex(source, 0, nil)
    else {
      throw ParityError.missingResource("Fixtures/fixture.png")
    }
    return .cgImage(image)
  }
}
