# Gem Smoke

Animated gem smoke shape with inner and outer distortion, glow, offset, and color bands.

![Gem Smoke default preset preview](preview-gem-smoke.png)

Use ``GemSmoke`` as a SwiftUI view, ``GemSmokeParams`` for typed parameters, and ``GemSmokePreset`` for Paper-derived presets. This implementation tracks the Paper Shaders behavior and preset metadata where the Metal port has a matching shader.

[Paper Shaders reference](https://github.com/paper-design/shaders)

## Example

```swift
import SwiftUI
import FoilShaders

GemSmoke(.default)
  .frame(width: 240, height: 240)
```

## Parameters

| Parameter | Preset-tested range / unit | Notes |
| --- | --- | --- |
| `colors` | `2...5` colors | Array of ``ShaderColor`` values; this shader keeps at most 6 colors. |
| `colorBack` | `0...1` RGBA | Background ``ShaderColor``; RGBA components use `0...1`. |
| `colorInner` | `0...1` RGBA | Inner ``ShaderColor``; RGBA components use `0...1`. |
| `innerDistortion` | `0.6...1` | Normalized inner distortion amount. |
| `outerDistortion` | `0.6...1` | Normalized outer distortion amount. |
| `outerGlow` | `0...1` | Normalized outer glow amount. |
| `innerGlow` | `0.65...1` | Normalized inner glow amount. |
| `offset` | `0...0.2` | Normalized vertical smoke offset. |
| `angle` | `0` | Angle in degrees. |
| `size` | `0.8...1` | Shader-specific size control; see the range for practical values. |
| `shape` | ``GemSmokeShape``: `.none`, `.circle`, `.daisy`, `.diamond`, `.metaballs`. | Shape selector. |

See <doc:ParameterRanges#Gem-Smoke> for the full shared context around sizing, motion, and render options.

## Related Symbols

- ``GemSmoke``
- ``GemSmokeParams``
- ``GemSmokePreset``
