# Dithering

Procedural dither pattern over generated shapes.

![Dithering default preset preview](preview-dithering.png)

Use ``Dithering`` as a SwiftUI view, ``DitheringParams`` for typed parameters, and ``DitheringPreset`` for Paper-derived presets. This implementation tracks the Paper Shaders behavior and preset metadata where the Metal port has a matching shader.

[Paper Shaders reference](https://github.com/paper-design/shaders)

## Example

```swift
import SwiftUI
import FoilShaders

Dithering(.default)
  .frame(width: 240, height: 240)
```

## Parameters

| Parameter | Preset-tested range / unit | Notes |
| --- | --- | --- |
| `colorBack` | `0...1` RGBA | Background ``ShaderColor``; RGBA components use `0...1`. |
| `colorFront` | `0...1` RGBA | Foreground ``ShaderColor``; RGBA components use `0...1`. |
| `shape` | ``DitheringShape``: `.simplex`, `.warp`, `.dots`, `.wave`, `.ripple`, `.swirl`, `.sphere`. | Shape selector. |
| `type` | ``DitheringType``: `.random`, `.twoByTwo`, `.fourByFour`, `.eightByEight`. | Style or matrix selector. |
| `size` | `2...11` | Shader-specific size control; see the range for practical values. |

See <doc:ParameterRanges#Dithering> for the full shared context around sizing, motion, and render options.

## Related Symbols

- ``Dithering``
- ``DitheringParams``
- ``DitheringPreset``
