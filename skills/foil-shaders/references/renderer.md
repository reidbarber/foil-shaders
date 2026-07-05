# Rendering Without SwiftUI

Most apps should use the SwiftUI views (see SKILL.md). Reach for the imperative
`FoilShadersRenderer` only when you need something the views don't give you: an
offscreen still image (thumbnail, share sheet, export, server-side render), or a
shader driven inside a Metal view you already own.

`FoilShadersRenderer` is `@MainActor`. Create it once and reuse it — building the
Metal pipeline is the expensive part, and the renderer caches the compiled
pipeline per shader kind.

## Rendering a still image (`captureImage`)

The cleanest way to get a `ShaderConfiguration` is to build the SwiftUI view you
would otherwise render and read its public `configuration` property. That reuses
the exact preset/flat-init logic, so the offscreen image matches the on-screen
view.

```swift
import FoilShaders
import Metal

@MainActor
func meshGradientThumbnail() throws -> CGImage {
  guard let device = MTLCreateSystemDefaultDevice() else {
    throw NSError(domain: "app", code: 0)  // Metal unavailable (e.g. some CI)
  }
  let renderer = try FoilShadersRenderer(device: device)

  // Grab the configuration from any Foil Shaders view.
  var config = AnimatedMeshGradient(.beach).configuration

  // Animated shaders need a fixed timeline for a deterministic frame:
  // freeze time and pick a moment (milliseconds).
  config.motion.speed = 0
  config.motion.frame = 5000

  try renderer.render(config)                                  // configure + apply
  return try renderer.captureImage(width: 1280, height: 720)   // pixels, not points
}
```

Notes:

- `captureImage(width:height:pixelRatio:)` sizes the drawable in pixels. Pass a
  `pixelRatio` above `1` for a Retina-scale capture.
- For a still frame of an animated shader, always set `motion.speed = 0` and a
  fixed `motion.frame`; otherwise the captured frame depends on wall-clock time.
- Image-based shaders (Paper Texture, Water, Fluted Glass, Image Dithering,
  Heatmap, Halftone Dots, Halftone CMYK) need an input image. Set
  `config.image = .cgImage(myCGImage)` before rendering, or they use a fallback
  texture.

## Driving your own Metal view

To render continuously into an `MTKView` you manage:

```swift
let renderer = try FoilShadersRenderer(device: mtkView.device!)
try renderer.render(config, in: mtkView)   // attaches, configures, applies
```

Update parameters over time by mutating a `ShaderConfiguration` and calling
`renderer.apply(_:)` (cheap) or `renderer.render(_:)` (re-configures only if the
shader kind changed). Pause and resume with `renderer.setRenderingPaused(_:)`.

## Building a configuration by hand

If you don't want to instantiate a view, construct the configuration directly.
`ShaderParameters` is an enum with one case per shader; wrap the matching
`*Params` value:

```swift
let config = ShaderConfiguration(
  parameters: .swirl(SwirlParams(/* ... */)),
  sizing: .defaultPatternSizing,   // or .defaultObjectSizing (fit: .contain)
  motion: ShaderMotionParams(speed: 0.5, frame: 0),
  renderOptions: .default,
  image: nil
)
```

Every view type also exposes its presets as `TypeName.presets` (an array of
`ShaderPreset`), each carrying `.params`, `.sizing`, `.motion`, `.renderOptions`,
and `.name` — handy for building a picker.

## Errors

Renderer setup and rendering throw `FoilShadersError` (shader library missing,
pipeline compilation failure, invalid capture size, image-creation failure).
`MTLCreateSystemDefaultDevice()` returns `nil` where Metal is unavailable — guard
it and fail gracefully. In SwiftUI, observe the same failures without try/catch
via `.foilShadersRendererError { error in ... }` on any subtree.
