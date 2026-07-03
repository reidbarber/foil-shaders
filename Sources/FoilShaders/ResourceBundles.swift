import Foundation

enum FoilShadersResourceBundles {
  private static let resourceBundleName = "FoilShaders_FoilShaders"

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

    func appendSwiftPMBuildBundles(near startURL: URL) {
      var directory = startURL.standardizedFileURL
      for _ in 0..<8 {
        let buildDirectory = directory.appendingPathComponent(".build")
        appendBundle(at: buildDirectory.appendingPathComponent("debug/\(resourceBundleFileName)"))
        appendBundle(at: buildDirectory.appendingPathComponent("release/\(resourceBundleFileName)"))

        if let platformDirectories = try? FileManager.default.contentsOfDirectory(
          at: buildDirectory,
          includingPropertiesForKeys: [.isDirectoryKey]
        ) {
          for platformDirectory in platformDirectories {
            guard
              (try? platformDirectory.resourceValues(forKeys: [.isDirectoryKey]).isDirectory)
                == true
            else { continue }
            appendBundle(
              at: platformDirectory.appendingPathComponent("debug/\(resourceBundleFileName)")
            )
            appendBundle(
              at: platformDirectory.appendingPathComponent("release/\(resourceBundleFileName)")
            )
          }
        }

        let parent = directory.deletingLastPathComponent()
        guard parent.path != directory.path else { break }
        directory = parent
      }
    }

    for bundle in Bundle.allBundles
    where bundle.bundleURL.lastPathComponent == resourceBundleFileName {
      append(bundle)
    }
    appendBundle(at: mainBundle.url(forResource: resourceBundleName, withExtension: "bundle"))
    appendBundle(at: mainBundle.resourceURL?.appendingPathComponent(resourceBundleFileName))
    appendBundle(at: mainBundle.bundleURL.appendingPathComponent(resourceBundleFileName))
    appendBundle(
      at: mainBundle.bundleURL.deletingLastPathComponent().appendingPathComponent(
        resourceBundleFileName)
    )
    appendBundle(
      at: mainBundle.bundleURL.appendingPathComponent(
        "Contents/Resources/\(resourceBundleFileName)")
    )
    appendBundle(
      at: mainBundle.executableURL?
        .deletingLastPathComponent()
        .appendingPathComponent(resourceBundleFileName)
    )

    if let executablePath = CommandLine.arguments.first {
      appendBundle(
        at: URL(fileURLWithPath: executablePath)
          .deletingLastPathComponent()
          .appendingPathComponent(resourceBundleFileName)
      )
    }

    appendSwiftPMBuildBundles(near: URL(fileURLWithPath: FileManager.default.currentDirectoryPath))

    append(mainBundle)
    return bundles
  }()
}
