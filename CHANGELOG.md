# Changelog

All notable changes to Foil Shaders will be documented in this file.

## 0.6.0 - 2026-07-11

- Compile Metal shaders at build time instead of from source at runtime.
  Xcode builds produce `default.metallib`; `swift build`/`swift test` produce
  `FoilShaders.metallib` via a new `FoilShadersMetalCompilerPlugin` build tool
  plugin. Shader errors now fail the package build with compiler diagnostics,
  and first render no longer pays for runtime shader compilation.
- **Breaking:** Remove `FoilShadersError.librarySourceReadError` and
  `.libraryCompileError`; shaders are no longer read or compiled at runtime.
  A missing precompiled library now surfaces as `.libraryError`.
- Building the package now requires Xcode's Metal toolchain component
  (`xcodebuild -downloadComponent MetalToolchain` on Xcode 26 and later).
- Make the public shader configuration graph `Hashable`.
- Encode shader enum values as stable, human-readable strings while preserving
  their raw values for Metal uniforms.
- Derive `ShaderConfiguration` defaults from the matching shader kind's default
  preset.
- Type image-dithering and halftone-dots boolean parameters as `Bool` instead of
  `Float`.
- Close Heatmap and Halftone Dots rendering and preset parity gaps.
- Remove `swift-docc-plugin` from default package resolution; it remains
  available when `FOILSHADERS_ENABLE_DOCC_PLUGIN=1`.

## 0.5.0 - 2026-07-04

- **Breaking:** Split resolution from layout.
- **Breaking:** Drop the `CGImage` overload and standardize on `ShaderImage`.
- **Breaking:** Remove `ShaderSizingParams.default`; add single-call renderer APIs.
- **Breaking:** Make `ShaderParameters` encode as a stable type, plus `params` JSON.
- Every `params:` initializer now defaults sizing, motion, render options, and image from that component's own preset default.
- Add `ShaderColor` bridges.
- Clamp color-array params after mutation.
- Surface renderer errors from convenience shader components.
- `ShaderImage` bundle-resource decoding now throws `DecodingError.dataCorrupted` when neither the encoded bundle identifier nor bundle URL resolves.
- Fix `CodeGenerator` output.
- Avoid redrawing and hashing the full bitmap for image hash (perf).
- Document the enum-evolution policy for public case-bearing enums.

## 0.4.0 - 2026-07-04

- **Breaking:** Rename `MeshGradient` to `AnimatedMeshGradient` to avoid a naming conflict with SwiftUI's `MeshGradient`.
- **Breaking:** Unify shader parameters around `ShaderColor`.
- **Breaking:** Change `ShaderImage` from a public enum to a struct-backed descriptor.
- **Breaking:** Replace index-addressed presets with named static members.
- Shrink and slim down the public API surface, and derive `ShaderConfiguration`'s kind from its parameters.
- Add `Codable` conformance and checked `Sendable` config types.
- Add Reduce Motion support, with paused rendering when inactive or offscreen, and a `pausesWhenInactiveOrOffscreen` opt-out.
- Make renderer errors public and fix a silent failure in the SwiftUI path.
- Fix invalid literal fallback and max-color truncation.
- Share `MTLDevice`, command queue, decoded noise texture, shader libraries, and cached pipeline states for better performance.
- Add DocC documentation.

## 0.3.0 - 2026-07-04

- Refresh the Foil Shader Studio app icon across all app icon asset sizes.

## 0.2.0 - 2026-07-03

- Add a context menu to Foil Shader Studio with Copy Image and Save Image… actions.
- Fix image flipping in the renderer.
- Improve the layout of the generated code snippet.

## 0.1.0 - 2026-07-03

- Initial public alpha release.
- SwiftUI and Metal port of Paper Shaders for iOS 15+ and macOS 13+.
- Paper-derived presets and visual parity test coverage.
- macOS Foil Shader Studio companion app.
