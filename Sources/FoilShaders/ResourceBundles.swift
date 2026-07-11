import Foundation

/// Anchor for locating the bundle that contains this module's code
/// (an app binary, a framework, or an `.xctest` bundle).
private final class FoilShadersBundleFinder {}

enum FoilShadersResourceBundles {
  private static let resourceBundleName = "FoilShaders_FoilShaders"

  /// Bundles that may contain the package's resources (the precompiled
  /// shader library and the noise texture), in lookup order.
  ///
  /// This mirrors the locations SwiftPM's generated `Bundle.module` accessor
  /// probes, without its `fatalError` on a miss, so a packaging problem
  /// surfaces as a thrown `FoilShadersError` instead of a crash.
  static let candidates: [Bundle] = {
    var bundles: [Bundle] = []
    var seenPaths: Set<String> = []
    let mainBundle = Bundle.main
    let resourceBundleFileName = "\(resourceBundleName).bundle"

    func append(_ bundle: Bundle?) {
      guard let bundle else { return }
      let path = bundle.bundleURL.standardizedFileURL.path
      guard !seenPaths.contains(path) else { return }
      seenPaths.insert(path)
      bundles.append(bundle)
    }

    func appendBundle(at url: URL?) {
      guard let url else { return }
      let path = url.standardizedFileURL.path
      guard FileManager.default.fileExists(atPath: path) else { return }
      append(Bundle(url: URL(fileURLWithPath: path)))
    }

    for bundle in Bundle.allBundles
    where bundle.bundleURL.lastPathComponent == resourceBundleFileName {
      append(bundle)
    }

    // Apps built by Xcode embed the resource bundle in their resources
    // directory; CLI executables built by SwiftPM have it next to the binary.
    appendBundle(at: mainBundle.resourceURL?.appendingPathComponent(resourceBundleFileName))
    appendBundle(at: mainBundle.bundleURL.appendingPathComponent(resourceBundleFileName))
    appendBundle(
      at: mainBundle.executableURL?
        .deletingLastPathComponent()
        .appendingPathComponent(resourceBundleFileName)
    )

    // The bundle hosting this module's code: a framework's resources, or —
    // for `swift test` — the directory containing the `.xctest` bundle.
    let hostBundle = Bundle(for: FoilShadersBundleFinder.self)
    appendBundle(at: hostBundle.resourceURL?.appendingPathComponent(resourceBundleFileName))
    appendBundle(
      at: hostBundle.bundleURL
        .deletingLastPathComponent()
        .appendingPathComponent(resourceBundleFileName)
    )

    append(mainBundle)
    return bundles
  }()
}
