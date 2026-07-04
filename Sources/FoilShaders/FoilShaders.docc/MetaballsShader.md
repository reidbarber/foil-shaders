# Metaballs

Animated metaball blobs with color gradients.

![Metaballs default preset preview](preview-metaballs.png)

Use ``Metaballs`` as a SwiftUI view, ``MetaballsParams`` for typed parameters, and ``MetaballsPreset`` for Paper-derived presets. This implementation tracks the Paper Shaders behavior and preset metadata where the Metal port has a matching shader.

[Paper Shaders reference](https://github.com/paper-design/shaders)

## Example

```swift
import SwiftUI
import FoilShaders

Metaballs(.default)
  .frame(width: 240, height: 240)
```

## Parameters

| Parameter | Preset-tested range / unit | Notes |
| --- | --- | --- |
| `colorBack` | `0...1` RGBA | Background ``ShaderColor``; RGBA components use `0...1`. |
| `colors` | `1...5` colors | Array of ``ShaderColor`` values; this shader keeps at most 8 colors. |
| `count` | `7...18` | Number of animated metaballs. |
| `size` | `0.1...0.83` | Shader-specific size control; see the range for practical values. |
| `sizeRange` | `0.2` | Normalized random size variation. |

See <doc:ParameterRanges#Metaballs> for the full shared context around sizing, motion, and render options.

## Related Symbols

- ``Metaballs``
- ``MetaballsParams``
- ``MetaballsPreset``
