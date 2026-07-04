# Paper Texture

Image-based paper texture effect with fiber, folds, crumples, drops, and contrast.

![Paper Texture default preset preview](preview-paper-texture.png)

Use ``PaperTexture`` as a SwiftUI view, ``PaperTextureParams`` for typed parameters, and ``PaperTexturePreset`` for Paper-derived presets. This implementation tracks the Paper Shaders behavior and preset metadata where the Metal port has a matching shader.

[Paper Shaders reference](https://github.com/paper-design/shaders)

## Example

```swift
import SwiftUI
import FoilShaders

PaperTexture(.default)
  .frame(width: 240, height: 240)
```

## Parameters

| Parameter | Preset-tested range / unit | Notes |
| --- | --- | --- |
| `colorFront` | `0...1` RGBA | Foreground ``ShaderColor``; RGBA components use `0...1`. |
| `colorBack` | `0...1` RGBA | Background ``ShaderColor``; RGBA components use `0...1`. |
| `contrast` | `0...0.85` | Contrast multiplier or amount. |
| `roughness` | `0...1` | Normalized paper roughness. |
| `fiber` | `0.1...0.35` | Normalized paper fiber amount. |
| `fiberSize` | `0.14...0.22` | Normalized paper fiber scale. |
| `crumples` | `0...1` | Normalized crumple amount. |
| `foldCount` | `1...15` | Number of fold bands. |
| `folds` | `0...1` | Normalized fold opacity. |
| `fade` | `0` | Normalized texture fade amount. |
| `crumpleSize` | `0.1...0.5` | Normalized crumple scale. |
| `drops` | `0...0.2` | Normalized drop/stain amount. |
| `seed` | `1.6...6` | Unitless deterministic random seed. |

See <doc:ParameterRanges#Paper-Texture> for the full shared context around sizing, motion, and render options.

## Related Symbols

- ``PaperTexture``
- ``PaperTextureParams``
- ``PaperTexturePreset``
