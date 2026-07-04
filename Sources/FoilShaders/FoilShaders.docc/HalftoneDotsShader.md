# Halftone Dots

Image-based halftone dots with grid, radius, contrast, grain, and style controls.

![Halftone Dots default preset preview](preview-halftone-dots.png)

Use ``HalftoneDots`` as a SwiftUI view, ``HalftoneDotsParams`` for typed parameters, and ``HalftoneDotsPreset`` for Paper-derived presets. This implementation tracks the Paper Shaders behavior and preset metadata where the Metal port has a matching shader.

[Paper Shaders reference](https://github.com/paper-design/shaders)

## Example

```swift
import SwiftUI
import FoilShaders

HalftoneDots(.default)
  .frame(width: 240, height: 240)
```

## Parameters

| Parameter | Preset-tested range / unit | Notes |
| --- | --- | --- |
| `colorFront` | `0...1` RGBA | Foreground ``ShaderColor``; RGBA components use `0...1`. |
| `colorBack` | `0...1` RGBA | Background ``ShaderColor``; RGBA components use `0...1`. |
| `size` | `0.5...0.8` | Shader-specific size control; see the range for practical values. |
| `grid` | ``HalftoneDotsGrid``: `.square`, `.hex`. | Halftone dot grid selector. |
| `radius` | `1...2` | Normalized radius. |
| `contrast` | `0.01...1` | Contrast multiplier or amount. |
| `originalColors` | `0...1` | Boolean-like `0` or `1`; `1` keeps source image colors. |
| `inverted` | `0...1` | Boolean-like `0` or `1`; `1` inverts the source image luminance. |
| `grainMixer` | `0...0.2` | Normalized grain mix amount. |
| `grainOverlay` | `0...0.3` | Normalized grain overlay opacity. |
| `grainSize` | `0.5` | Normalized grain scale. |
| `type` | ``HalftoneDotsType``: `.classic`, `.gooey`, `.holes`, `.soft`. | Style or matrix selector. |

See <doc:ParameterRanges#Halftone-Dots> for the full shared context around sizing, motion, and render options.

## Related Symbols

- ``HalftoneDots``
- ``HalftoneDotsParams``
- ``HalftoneDotsPreset``
