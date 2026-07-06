# Contributing

Foil Shaders is a Swift package with a SwiftUI/Metal library, a macOS studio
app, an export helper, generated Paper Shaders preset metadata, and a visual
parity suite.

## Local Setup

Requirements:

- macOS with Xcode installed
- Swift 6 toolchain
- Metal-capable Mac for renderer tests and app previews
- Node.js for preset extraction and parity golden regeneration

Build the package:

```sh
swift build
```

Run the lightweight unit test target:

```sh
swift test --filter FoilShadersTests
```

## Documentation

DocC content lives in `Sources/FoilShaders/FoilShaders.docc`. The
`swift-docc-plugin` dependency is opt-in so package consumers do not resolve it
during normal builds. Enable it only for documentation commands:

```sh
FOILSHADERS_ENABLE_DOCC_PLUGIN=1 swift package generate-documentation --target FoilShaders
```

Do not commit a `Package.resolved` generated only by this documentation command.

## Public API Baseline

CI checks the `FoilShaders` public API with `swift-api-digester` against the
committed macOS and iOS baselines in `API/`.

New cases in public case-bearing enums are compatible minor-version additions
under the package API evolution policy. The baseline check allows digester's
`EnumElement ... has been added as a new enum case` diagnostics, while still
failing removals, renames, raw-value changes, associated-value changes, and
other public API differences. Regenerate the baseline when adding enum cases so
the committed snapshots continue to describe the current API.

Run the check locally:

```sh
Scripts/check-api-baseline.sh
```

When a breaking API change is intentional, regenerate the baseline and commit it
with the API change:

```sh
Scripts/check-api-baseline.sh --update
```

## Studio App

Run the companion app locally:

```sh
swift run FoilShadersStudio
```

The studio app previews shaders, exposes preset and sizing controls, and copies
SwiftUI code for the current configuration.

## Packaging The Studio App

Build a macOS app bundle:

```sh
Scripts/package-macos-app.sh
```

Build a DMG:

```sh
Scripts/package-macos-app.sh --dmg
```

The script writes release artifacts under `dist/`, which is intentionally
ignored by Git. Public downloads should be uploaded to GitHub Releases instead
of being committed to the repository.

## Preset Generation

Preset metadata is derived from Paper Shaders. Regenerate the Swift presets
after updating the Paper Shaders checkout or changing `Scripts/preset-specs.mjs`:

```sh
node Scripts/extract-paper-presets.mjs <path-to-paper-shaders> > paper-presets.json
node Scripts/generate-swift-presets.mjs paper-presets.json > Sources/FoilShaders/Presets.swift
```

`paper-presets.json` is a scratch artifact and should not be committed.

## Visual Parity Suite

`Tests/FoilShadersParityTests` renders every shader, preset, and frame with the
Metal renderer and compares the raw pixels against golden images generated from
the original Paper Shaders WebGL implementation. The goldens are committed
under `Tests/FoilShadersParityTests/Goldens`.

Run the full parity suite:

```sh
swift test --filter FoilShadersParityTests
```

Iterate on one shader or preset:

```sh
PARITY_FILTER=swirl swift test --filter FoilShadersParityTests
PARITY_FILTER="swirl/Candy" swift test --filter FoilShadersParityTests
```

Comparison uses a tight per-pixel tolerance, with per-shader overrides in
`ParityTolerances`. On failure, expected, actual, and diff PNGs are written to
a temporary directory. Set `PARITY_ARTIFACTS_DIR` to choose the output path.

Shaders that currently diverge structurally from the reference are tracked in
`GoldenParityTests.knownParityGaps`. Those cases do not fail the suite, but the
list is strict: once a shader is fixed, the test requires its entry to be
removed.

Goldens were generated under SwiftShader, with the environment recorded in
`Tests/FoilShadersParityTests/Goldens/manifest.json`. Regenerate them whenever:

- `Sources/FoilShaders/Presets.swift` is regenerated.
- The Paper Shaders checkout is updated.
- The canvas size in `Scripts/preset-specs.mjs` changes.

See [Scripts/parity-harness/README.md](Scripts/parity-harness/README.md) for
golden regeneration instructions.

Regenerate the README visual parity table and hero image assets:

```sh
Scripts/generate-readme-parity-assets.sh
```

The script copies or regenerates the selected Paper Shaders outputs, renders
the matching Foil Shaders outputs into `Docs/Media/parity/`, and writes the
large README Mesh Gradient image to `Docs/Media/readme/`.

## Package Products

Apps should depend on the `FoilShaders` library product.

The package also includes executable products for project tooling:

- `FoilShadersStudio`: the macOS preview companion app.
- `FoilShadersExport`: a helper for rendering PNG output from Swift.

Keeping the studio executable in the package makes the contributor workflow and
release packaging straightforward. If Xcode package selection feels too noisy
for app users, `FoilShadersExport` is the first product to consider moving out
of the public product list.

## Release Checklist

Before tagging a release:

1. Confirm `swift build` passes.
2. Confirm `swift test --filter FoilShadersTests` passes.
3. Run the parity suite or review the latest parity workflow result.
4. Build the studio DMG with `Scripts/package-macos-app.sh --dmg`.
5. Upload the DMG to GitHub Releases.
6. Verify Xcode can add `https://github.com/reidbarber/foil-shaders.git`.
7. Verify a sample app can import `FoilShaders` and render a shader.
