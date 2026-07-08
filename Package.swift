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
        // The `.metal` files are loaded and compiled at runtime from source
        // (see ShaderLibraryLoader), so they must be copied verbatim. Using
        // `.process` makes Xcode's build system treat them as standalone Metal
        // sources and compile them into a default.metallib, which fails because
        // each shader depends on shared types from Common.metal/Vertex.metal
        // (e.g. `unknown type name 'VertexOutput'`). `.copy` preserves the
        // `Shaders/` subdirectory that the loader looks in.
        .copy("Resources/Shaders"),
        .process("Resources/noise-texture.png"),
      ]
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
