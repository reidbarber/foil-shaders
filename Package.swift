// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "AluminumFoil",
  platforms: [
    .iOS(.v15),
    .macOS(.v13),
  ],
  products: [
    .library(
      name: "AluminumFoil",
      targets: ["AluminumFoil"]
    ),
    .executable(
      name: "AluminumFoilStudio",
      targets: ["AluminumFoilStudio"]
    ),
    .executable(
      name: "AluminumFoilExport",
      targets: ["AluminumFoilExport"]
    ),
  ],
  targets: [
    .target(
      name: "AluminumFoil",
      resources: [
        .process("Resources")
      ]
    ),
    .executableTarget(
      name: "AluminumFoilStudio",
      dependencies: ["AluminumFoil"]
    ),
    .executableTarget(
      name: "AluminumFoilExport",
      dependencies: ["AluminumFoil"]
    ),
    .testTarget(
      name: "AluminumFoilTests",
      dependencies: ["AluminumFoil"]
    ),
  ]
)
