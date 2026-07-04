# Image Dithering

Image-based dithering with color quantization, ordered dither type, and optional original colors.

![Image Dithering default preset preview](preview-image-dithering.png)

Use ``ImageDithering`` as a SwiftUI view, ``ImageDitheringParams`` for typed parameters, and ``ImageDitheringPreset`` for Paper-derived presets. This implementation tracks the Paper Shaders behavior and preset metadata where the Metal port has a matching shader.

[Paper Shaders reference](https://github.com/paper-design/shaders)

## Example

```swift
import SwiftUI
import FoilShaders

ImageDithering(.default)
  .frame(width: 240, height: 240)
```

## Parameters

| Parameter | Preset-tested range / unit | Notes |
| --- | --- | --- |
| `colorFront` | `0...1` RGBA | Foreground ``ShaderColor``; RGBA components use `0...1`. |
| `colorBack` | `0...1` RGBA | Background ``ShaderColor``; RGBA components use `0...1`. |
| `colorHighlight` | `0...1` RGBA | Highlight ``ShaderColor``; RGBA components use `0...1`. |
| `type` | ``DitheringType``: `.random`, `.twoByTwo`, `.fourByFour`, `.eightByEight`. | Style or matrix selector. |
| `size` | `1...3` | Shader-specific size control; see the range for practical values. |
| `colorSteps` | `1...5` | Number of quantized color steps. |
| `originalColors` | `0...1` | Boolean-like `0` or `1`; `1` keeps source image colors. |
| `inverted` | `0` | Boolean-like `0` or `1`; `1` inverts the source image luminance. |

See <doc:ParameterRanges#Image-Dithering> for the full shared context around sizing, motion, and render options.

## Related Symbols

- ``ImageDithering``
- ``ImageDitheringParams``
- ``ImageDitheringPreset``
