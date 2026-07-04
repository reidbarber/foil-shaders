// swift-tools-version: 6.0

import PackageDescription

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
  dependencies: [
    .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.5.0")
  ],
  targets: [
    .target(
      name: "FoilShaders",
      resources: [
        .process("Resources")
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
