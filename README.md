# Foil Shaders

Foil Shaders is a Swift and SwiftUI Metal port of Paper Shaders. It exposes
SwiftUI components named after the React components from
`@paper-design/shaders-react`, backed by a lower-level Metal renderer.

```swift
import FoilShaders

FoilShaders.MeshGradient(
    colors: ["#5100ff", "#00ff80", "#ffcc00", "#ea00ff"],
    distortion: 1,
    swirl: 0.8,
    speed: 0.2
)
.frame(width: 200, height: 200)
```

Run the companion app with:

```sh
swift run FoilShadersStudio
```

Package the companion app as a macOS app bundle with:

```sh
Scripts/package-macos-app.sh

# Also create dist/FoilShadersStudio.dmg:
Scripts/package-macos-app.sh --dmg
```

Regenerate Paper-derived preset metadata with:

```sh
node Scripts/extract-paper-presets.mjs <path-to-paper-shaders> > paper-presets.json
node Scripts/generate-swift-presets.mjs paper-presets.json > Sources/FoilShaders/Presets.swift
```

## Visual parity suite

`Tests/FoilShadersParityTests` renders every shader × preset × frame with the
Metal renderer and compares the raw pixels against golden images generated
from the original Paper Shaders WebGL implementation (committed under
`Tests/FoilShadersParityTests/Goldens`). Run it with:

```sh
swift test --filter FoilShadersParityTests

# Iterate on one shader / preset:
PARITY_FILTER=swirl swift test --filter FoilShadersParityTests
PARITY_FILTER="swirl/Candy" swift test --filter FoilShadersParityTests
```

Comparison uses a tight per-pixel tolerance (channel delta ≤ 2/255 with a cap
on the fraction of out-of-tolerance pixels; per-shader overrides in
`ParityTolerances`). On failure, expected/actual/diff PNGs are written to a
temp directory (override with `PARITY_ARTIFACTS_DIR`) and the path is printed.

Shaders that currently diverge structurally from the reference are tracked in
`GoldenParityTests.knownParityGaps`; they don't fail the suite, but the list is
strict — once a shader is fixed, the test demands its entry be removed.

Goldens were generated on one machine under SwiftShader (environment recorded
in `Goldens/manifest.json`). To regenerate them — required whenever
`Presets.swift` is regenerated or the paper repo is updated — see
[Scripts/parity-harness/README.md](Scripts/parity-harness/README.md).
