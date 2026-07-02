# Aluminum Foil

Aluminum Foil is a Swift and SwiftUI Metal port of Paper Shaders. It exposes
SwiftUI components named after the React components from
`@paper-design/shaders-react`, backed by a lower-level Metal renderer.

```swift
import AluminumFoil

AluminumFoil.MeshGradient(
    colors: ["#5100ff", "#00ff80", "#ffcc00", "#ea00ff"],
    distortion: 1,
    swirl: 0.8,
    speed: 0.2
)
.frame(width: 200, height: 200)
```

Run the companion app with:

```sh
swift run AluminumFoilStudio
```

Regenerate Paper-derived preset metadata with:

```sh
node Scripts/extract-paper-presets.mjs <path-to-paper-shaders> > paper-presets.json
node Scripts/generate-swift-presets.mjs paper-presets.json > Sources/AluminumFoil/Presets.swift
```
