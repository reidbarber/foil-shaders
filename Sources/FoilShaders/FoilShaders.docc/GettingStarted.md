# Getting Started

Create a SwiftUI shader view with a preset or explicit parameters.

## Installation

Add the package URL to your app in Xcode or your package manifest:

```swift
dependencies: [
  .package(url: "https://github.com/reidbarber/foil-shaders.git", from: "0.3.0")
]
```

## Basic Usage

This matches the README example and uses the flat initializer for ``MeshGradient``:

```swift
import SwiftUI
import FoilShaders

struct ContentView: View {
  var body: some View {
    FoilShaders.MeshGradient(
      colors: ["#5100ff", "#00ff80", "#ffcc00", "#ea00ff"],
      distortion: 1,
      swirl: 0.8,
      speed: 0.2
    )
    .frame(width: 240, height: 240)
  }
}
```

## Presets

Most components expose Paper-derived presets:

```swift
FoilShaders.Swirl(.candy)
  .frame(width: 240, height: 240)
```

## Colors

Color parameters accept ``ShaderColor`` values. String literals are parsed as hex, `rgb()`, `rgba()`, `hsl()`, or `hsla()` and normalized to RGBA components in `0...1`.

```swift
FoilShaders.Dithering(
  colorBack: "#000000",
  colorFront: "hsl(195 100% 50%)",
  shape: .sphere,
  type: .fourByFour,
  speed: 0.2
)
```

## Ranges

See <doc:ParameterRanges> for shader-specific ranges, units, and enum cases.
