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
      dependencies: ["FoilShaders"]
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
