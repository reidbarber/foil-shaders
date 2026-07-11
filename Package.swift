// swift-tools-version: 6.0

import Foundation
import PackageDescription

let enableDocCPlugin = ProcessInfo.processInfo.environment["FOILSHADERS_ENABLE_DOCC_PLUGIN"] == "1"

var packageDependencies: [Package.Dependency] = []

if enableDocCPlugin {
  packageDependencies.append(
    .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.5.0")
  )
}

let package = Package(
  name: "FoilShaders",
  platforms: [
    .iOS(.v15),
    .macOS(.v13),
  ],
  products: [
    .library(
      name: "FoilShaders",
      targets: ["FoilShaders"]
    ),
    .executable(
      name: "FoilShadersStudio",
      targets: ["FoilShadersStudio"]
    ),
    .executable(
      name: "FoilShadersExport",
      targets: ["FoilShadersExport"]
    ),
  ],
  dependencies: packageDependencies,
  targets: [
    .target(
      name: "FoilShaders",
      resources: [
        // Shaders are compiled at build time, never at runtime:
        // - Xcode builds (apps depending on this package) compile the
        //   `.process`ed `.metal` files into `default.metallib` for the
        //   platform being built (iOS, macOS, Catalyst, simulator).
        // - Plain `swift build`/`swift test` do not compile Metal, so the
        //   FoilShadersMetalCompilerPlugin build tool plugin produces
        //   `FoilShaders.metallib` (macOS) for those CLI builds.
        // ShaderLibraryLoader prefers `default.metallib` and falls back to
        // the plugin-built library.
        .process("Resources/Shaders"),
        .process("Resources/noise-texture.png"),
      ],
      plugins: ["FoilShadersMetalCompilerPlugin"]
    ),
    .plugin(
      name: "FoilShadersMetalCompilerPlugin",
      capability: .buildTool()
    ),
    .executableTarget(
      name: "FoilShadersStudio",
      dependencies: ["FoilShaders"]
    ),
    .executableTarget(
      name: "FoilShadersExport",
      dependencies: ["FoilShaders"]
    ),
    .testTarget(
      name: "FoilShadersTests",
      dependencies: ["FoilShaders"],
      resources: [
        .copy("Fixtures")
      ]
    ),
    .testTarget(
      name: "FoilShadersParityTests",
      dependencies: ["FoilShaders"],
      resources: [
        .copy("Goldens"),
        .copy("Fixtures"),
      ]
    ),
  ]
)
