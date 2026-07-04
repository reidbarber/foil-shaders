# God Rays

Animated radial light rays with bloom and spot controls.

![God Rays default preset preview](preview-god-rays.png)

Use ``GodRays`` as a SwiftUI view, ``GodRaysParams`` for typed parameters, and ``GodRaysPreset`` for Paper-derived presets. This implementation tracks the Paper Shaders behavior and preset metadata where the Metal port has a matching shader.

[Paper Shaders reference](https://github.com/paper-design/shaders)

## Example

```swift
import SwiftUI
import FoilShaders

GodRays(.default)
  .frame(width: 240, height: 240)
```

## Parameters

| Parameter | Preset-tested range / unit | Notes |
| --- | --- | --- |
| `colorBack` | `0...1` RGBA | Background ``ShaderColor``; RGBA components use `0...1`. |
| `colorBloom` | `0...1` RGBA | Bloom ``ShaderColor``; RGBA components use `0...1`. |
| `colors` | `3...4` colors | Array of ``ShaderColor`` values; this shader keeps at most 5 colors. |
| `density` | `0.03...0.45` | Unitless density amount. |
| `spotty` | `0.15...0.77` | Normalized ray spot variation. |
| `midSize` | `0.1...0.33` | Normalized middle glow size. |
| `midIntensity` | `0.4...0.75` | Normalized middle glow intensity. |
| `intensity` | `0.6...0.8` | Intensity multiplier. |
| `bloom` | `0.4...1` | Bloom amount. |

See <doc:ParameterRanges#God-Rays> for the full shared context around sizing, motion, and render options.

## Related Symbols

- ``GodRays``
- ``GodRaysParams``
- ``GodRaysPreset``
