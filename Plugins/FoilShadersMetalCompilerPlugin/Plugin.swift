import Foundation
import PackagePlugin

/// Compiles the package's Metal shaders into `FoilShaders.metallib` at build
/// time and embeds it in the target's resource bundle.
///
/// Xcode's build system already compiles `.process`ed `.metal` resources into
/// a `default.metallib` for whichever platform it is building, but plain
/// `swift build` / `swift test` do not compile Metal at all. This plugin
/// covers those SwiftPM CLI builds (which only ever run on macOS) so the
/// Studio/Export executables and the test suites load a precompiled library
/// instead of compiling shader source at runtime.
@main
struct FoilShadersMetalCompilerPlugin: BuildToolPlugin {
  func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
    guard let target = target as? SourceModuleTarget else { return [] }

    // Path-based PackagePlugin API keeps the manifest on swift-tools 6.0;
    // the URL-based equivalents require 6.1.
    let shadersDirectory = URL(fileURLWithPath: target.directory.string)
      .appendingPathComponent("Resources")
      .appendingPathComponent("Shaders")
    let shaderFiles = try FileManager.default
      .contentsOfDirectory(at: shadersDirectory, includingPropertiesForKeys: nil)
      .sorted { $0.lastPathComponent < $1.lastPathComponent }
    let metalSources = shaderFiles.filter { $0.pathExtension == "metal" }
    let headers = shaderFiles.filter { $0.pathExtension == "h" }
    guard !metalSources.isEmpty else { return [] }

    let outputLibrary = URL(
      fileURLWithPath: context.pluginWorkDirectory.string
    ).appendingPathComponent("FoilShaders.metallib")
    let moduleCacheDirectory = URL(
      fileURLWithPath: context.pluginWorkDirectory.string
    ).appendingPathComponent("ModuleCache")

    return [
      .buildCommand(
        displayName: "Compiling FoilShaders Metal library (\(metalSources.count) shaders)",
        executable: URL(fileURLWithPath: "/usr/bin/xcrun"),
        arguments: [
          "-sdk", "macosx", "metal",
          "-mmacos-version-min=13.0",
          "-fmodules-cache-path=\(moduleCacheDirectory.path)",
          "-o", outputLibrary.path,
        ] + metalSources.map(\.path),
        inputFiles: metalSources + headers,
        outputFiles: [outputLibrary]
      )
    ]
  }
}
