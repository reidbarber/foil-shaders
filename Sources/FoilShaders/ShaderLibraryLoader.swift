import Foundation
import Metal

enum ShaderLibraryLoader {
  /// Loads the precompiled FoilShaders Metal library.
  ///
  /// Shaders are compiled at build time, never at runtime:
  /// - Xcode builds compile the package's `.metal` resources into
  ///   `default.metallib` for the platform being built.
  /// - SwiftPM CLI builds (`swift build` / `swift test`) get
  ///   `FoilShaders.metallib` from the FoilShadersMetalCompilerPlugin
  ///   build tool plugin.
  static func makeLibrary(device: MTLDevice) throws -> MTLLibrary {
    for bundle in FoilShadersResourceBundles.candidates {
      if let library = try? device.makeDefaultLibrary(bundle: bundle) {
        return library
      }
      if let url = bundle.url(forResource: "FoilShaders", withExtension: "metallib"),
        let library = try? device.makeLibrary(URL: url)
      {
        return library
      }
    }
    throw FoilShadersError.libraryError
  }
}
