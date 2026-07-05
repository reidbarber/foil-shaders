---
name: foil-shaders
description: >-
  How to use the FoilShaders Swift package — Metal-backed SwiftUI shader views
  (mesh gradients, dithering, voronoi, warp, waves, liquid metal, halftone,
  and ~29 more) for iOS and macOS. Use this whenever a task involves adding an
  animated or generative background, gradient, or texture to a SwiftUI app and
  FoilShaders is (or could be) the tool — including phrases like "animated
  gradient background," "mesh gradient," "shader view," "moving background,"
  "dithered/halftone/voronoi effect," or when someone imports FoilShaders,
  references a *Shader/*Params/ShaderColor/ShaderImage type, or asks to render a
  shader to an image. Prefer this skill over hand-writing raw Metal or SwiftUI
  MeshGradient when FoilShaders is available.
---

# Foil Shaders

FoilShaders is a Swift package of ~29 Metal-backed SwiftUI views that render
animated and generative effects — mesh gradients, dithering, voronoi, warp,
waves, god rays, liquid metal, halftone, paper texture, and more. It is a Metal
port of [Paper Shaders](https://github.com/paper-design/shaders) for iOS 15+ and
macOS 13+. Each effect is a plain SwiftUI `View`; drop one in and size it with
`.frame`.

## Mental model

Three things to get right, in order:

1. **Pick a view.** Each effect is a `View` type (`AnimatedMeshGradient`,
   `Dithering`, `Voronoi`, …). See "Choosing a shader" below.
2. **Configure it** one of three ways: a **preset**, the **flat initializer**
   (labeled arguments), or a typed **`*Params`** value. They're
   interchangeable — presets read cleanest, flat initializers give per-argument
   control, `*Params` is for when you already hold a params value.
3. **Size and place it.** These views have no intrinsic size; always give them a
   `.frame` (or let them fill a container). They're happy as full-bleed
   backgrounds behind other content.

## Install

Swift Package Manager. In Xcode: File ▸ Add Package Dependencies ▸
`https://github.com/reidbarber/foil-shaders.git`, then add the **FoilShaders**
product to the app target. In a `Package.swift`:

```swift
dependencies: [
  .package(url: "https://github.com/reidbarber/foil-shaders.git", from: "0.5.0")
],
targets: [
  .target(name: "YourTarget", dependencies: [
    .product(name: "FoilShaders", package: "foil-shaders")
  ])
]
```

FoilShaders is alpha (pre-1.0); APIs may shift, so pinning an exact version is
reasonable. It renders on real Metal devices — simulators and previews work, but
headless CI without a GPU won't.

## Basic usage

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

### The three ways to configure a view

All three produce the same kind of view. Mix and match freely.

**Preset** — the fastest path to something that looks good. Every shader ships a
handful; pass one as the first argument:

```swift
Swirl(.candy)
Voronoi(.cells)
AnimatedMeshGradient(.beach)
```

**Flat initializer** — labeled arguments for exactly what you want. Every
parameter is optional and defaults to the shader's default preset, so you only
name what you change:

```swift
Dithering(
  colorBack: "#000000",
  colorFront: "hsl(195 100% 50%)",
  shape: .sphere,
  type: .fourByFour,
  speed: 0.2
)
```

**Typed params** — when you're holding a `*Params` value (from a model, a
picker, decoded JSON):

```swift
Dithering(params: myDitheringParams)
```

Both preset and flat forms also accept the shared sizing, motion, and render
options as arguments (see "Sizing" and "Motion"). The full argument list and
value ranges for each shader live in **`references/shaders.md`** — read that
before setting unfamiliar parameters so you use sane ranges and the right enum
cases.

### A note on names

The mesh-gradient view is `AnimatedMeshGradient`, not `MeshGradient` — SwiftUI
already has a `MeshGradient`, so this avoids the clash. If any other Foil Shaders
type name collides with something in scope, module-qualify it: `FoilShaders.Swirl`,
`FoilShaders.Dithering`. That's the only reason the README writes `FoilShaders.` —
the bare name works whenever it's unambiguous.

## Colors

Color parameters take `ShaderColor`, which conforms to `ExpressibleByStringLiteral`,
so string literals just work. Strings parse as hex, `rgb()`, `rgba()`, `hsl()`, or
`hsla()`:

```swift
colorFront: "#00ffcc"
colorBack: "hsl(195 100% 50%)"
colorFront: "rgba(255, 0, 128, 0.8)"
```

You can also bridge a SwiftUI `Color`, `CGColor`, `UIColor`, or `NSColor` into
`ShaderColor`. For asset-catalog colors that must track light/dark mode, resolve
against the environment (iOS 17 / macOS 14+):

```swift
struct Branded: View {
  @Environment(\.self) private var environment
  var body: some View {
    let accent = ShaderColor(Color("Accent"), in: environment)
    Dithering(colorBack: .black, colorFront: accent, shape: .sphere)
  }
}
```

Color channels are normalized RGBA in `0...1` throughout.

## Images

Some shaders sample an input image — Paper Texture, Water, Fluted Glass, Image
Dithering, Heatmap, Halftone Dots, and Halftone CMYK. They take a `ShaderImage`,
built from a bundled resource, a URL, or a runtime `CGImage`:

```swift
ImageDithering(image: .bundledResource(name: "portrait", extension: "jpg"), type: .fourByFour)
Water(image: .cgImage(myCGImage))
```

Build the `ShaderImage` once and store it in view state or a model — don't
construct `.cgImage(photo)` inline inside `body`, which re-does synchronous setup
on every render. Without an image these shaders fall back to a built-in texture,
so they still render.

## Motion, energy, and accessibility

Animated views handle the right defaults for you, and this is a real selling
point — respect it rather than disabling it casually:

- They **honor Reduce Motion** automatically (falling back to a still frame).
- They **pause when inactive or offscreen** to save power.

Opt a subtree out only when you have a concrete reason:

```swift
AnimatedMeshGradient()
  .foilShadersRespectsReduceMotion(false)          // ignore the system setting
  .foilShadersPausesWhenInactiveOrOffscreen(false) // keep rendering while hidden
```

Control animation with the `speed` argument (`0` freezes time; presets use roughly
`0.1...4`) and pin a specific still frame with `frame` (milliseconds). To surface
renderer setup/reconfiguration failures anywhere in a subtree:

```swift
SomeShaderStack()
  .foilShadersRendererError { error in /* log, show fallback UI */ }
```

## Sizing

Give every shader view an explicit size — `.frame(...)`, or let it fill a
container (e.g. as a `ZStack` background). Beyond the frame, the shared `fit`,
`scale`, `rotation`, `origin*`, and `offset*` arguments control how the shader's
internal coordinate space maps into that frame (`fit: .none` / `.contain` /
`.cover`). Defaults are sensible; reach for these only to zoom, rotate, or pan the
effect. Ranges are in `references/shaders.md` under "Shared Controls".

## Choosing a shader

Pick by the look you want. Animated unless noted; **image-based** shaders need an
input image (they blend/distort it).

- `AnimatedMeshGradient` — flowing multi-color mesh gradient (the classic "animated
  gradient background").
- `StaticMeshGradient` — non-animated mesh gradient variant. *(static)*
- `StaticRadialGradient` — radial gradient with focal point and grain. *(static)*
- `Swirl` — radial swirl bands with twist and noise.
- `Spiral` — animated spiral stroke.
- `Warp` — warped color bands (checks, stripes, or edges).
- `Voronoi` — animated voronoi cells with gap and glow.
- `Waves` — wave-line pattern. *(static)*
- `SimplexNoise` / `PerlinNoise` — stepped noise color fields.
- `NeuroNoise` — organic noise field, front/mid/back blend.
- `Metaballs` — blobby metaball gradients.
- `DotOrbit` — orbital dot pattern.
- `DotGrid` — procedural dot grid (shape, spacing, stroke). *(static)*
- `GodRays` — radial light rays with bloom.
- `Dithering` — dither pattern over generated shapes (sphere, ripple, swirl, …).
- `GrainGradient` — grainy gradient with shape masks. *(static)*
- `PulsingBorder` — glowing animated border (great around cards/buttons).
- `ColorPanels` — layered translucent color panels.
- `LiquidMetal` — chromatic liquid-metal pattern.
- `GemSmoke` — smoky gem shape with glow.
- `SmokeRing` — layered smoke ring.
- **Image-based:** `PaperTexture`, `Water`, `FlutedGlass`, `ImageDithering`,
  `Heatmap`, `HalftoneDots`, `HalftoneCMYK`.

For the full parameter list, value ranges, enum cases, and preset names of any
shader, read **`references/shaders.md`**.

## Rendering to an image or into your own Metal view

For a still image (thumbnail, export, share sheet) or to drive a shader inside an
`MTKView` you own, use the imperative `FoilShadersRenderer`. This is a smaller,
separate path — read **`references/renderer.md`** when a task needs it. For normal
in-app UI, the SwiftUI views above are the answer.

## Common pitfalls

- **No `.frame`** → the view collapses to nothing. Always size it.
- **`MeshGradient` vs `AnimatedMeshGradient`** → the Foil Shaders type is
  `AnimatedMeshGradient`; `MeshGradient` is SwiftUI's own unrelated type.
- **Rebuilding `ShaderImage` in `body`** → construct it once and store it.
- **Guessing parameter values** → open `references/shaders.md` for tested ranges;
  don't invent magnitudes.
- **Fighting Reduce Motion / pausing** → these defaults are a feature; keep them
  unless the design genuinely requires otherwise.
- **Expecting it in headless CI** → rendering needs a Metal device.
