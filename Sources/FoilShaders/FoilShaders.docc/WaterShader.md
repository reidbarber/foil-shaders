# Water

Image-based water caustic distortion with highlights, waves, edges, and layering.

![Water default preset preview](preview-water.png)

Use ``Water`` as a SwiftUI view, ``WaterParams`` for typed parameters, and ``WaterPreset`` for Paper-derived presets. This implementation tracks the Paper Shaders behavior and preset metadata where the Metal port has a matching shader.

[Paper Shaders reference](https://github.com/paper-design/shaders)

## Example

```swift
import SwiftUI
import FoilShaders

Water(.default)
  .frame(width: 240, height: 240)
```

## Parameters

| Parameter | Preset-tested range / unit | Notes |
| --- | --- | --- |
| `colorBack` | `0...1` RGBA | Background ``ShaderColor``; RGBA components use `0...1`. |
| `colorHighlight` | `0...1` RGBA | Highlight ``ShaderColor``; RGBA components use `0...1`. |
| `highlights` | `0...0.4` | Normalized highlight amount. |
| `layering` | `0...0.5` | Normalized caustic layer amount. |
| `edges` | `0...1` | Normalized edge fade or edge distortion amount. |
| `caustic` | `0...0.4` | Normalized caustic distortion amount. |
| `waves` | `0...1` | Normalized wave distortion amount. |
| `size` | `0.15...1` | Shader-specific size control; see the range for practical values. |

See <doc:ParameterRanges#Water> for the full shared context around sizing, motion, and render options.

## Related Symbols

- ``Water``
- ``WaterParams``
- ``WaterPreset``
