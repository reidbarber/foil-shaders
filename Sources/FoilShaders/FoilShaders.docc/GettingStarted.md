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

This matches the README example and uses the flat initializer for ``AnimatedMeshGradient``:

```swift
import SwiftUI
import FoilShaders

struct ContentView: View {
  var body: some View {
    AnimatedMeshGradient(
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

You can bridge `CGColor`, SwiftUI `Color`, and platform colors (`UIColor` on
iOS, `NSColor` on macOS) into ``ShaderColor``. On iOS 17, macOS 14, or newer,
resolve dynamic SwiftUI colors against the current environment so asset-catalog
light and dark variants update with the view:

```swift
struct BrandedDithering: View {
  @Environment(\.self) private var environment

  var body: some View {
    let accent = ShaderColor(Color("ShaderAccent"), in: environment)

    FoilShaders.Dithering(
      colorBack: .black,
      colorFront: accent,
      shape: .sphere,
      type: .fourByFour,
      speed: 0.2
    )
  }
}
```

## Motion And Energy

Animated SwiftUI components respect the system Reduce Motion setting by default
and pause rendering while inactive or offscreen. Use
``foilShadersRespectsReduceMotion(_:)`` and
``foilShadersPausesWhenInactiveOrOffscreen(_:)`` as separate opt-outs for a
subtree.

## Ranges

See <doc:ParameterRanges> for shader-specific ranges, units, and enum cases.
