# Grain Gradient

Grainy static gradient pattern with selectable shape masks.

![Grain Gradient default preset preview](preview-grain-gradient.png)

Use ``GrainGradient`` as a SwiftUI view, ``GrainGradientParams`` for typed parameters, and ``GrainGradientPreset`` for Paper-derived presets. This implementation tracks the Paper Shaders behavior and preset metadata where the Metal port has a matching shader.

[Paper Shaders reference](https://github.com/paper-design/shaders)

## Example

```swift
import SwiftUI
import FoilShaders

GrainGradient(.default)
  .frame(width: 240, height: 240)
```

## Parameters

| Parameter | Preset-tested range / unit | Notes |
| --- | --- | --- |
| `colorBack` | `0...1` RGBA | Background ``ShaderColor``; RGBA components use `0...1`. |
| `colors` | `3...4` colors | Array of ``ShaderColor`` values; this shader keeps at most 7 colors. |
| `softness` | `0...1` | Soft-edge amount; most shaders use `0` as hard and `1` as soft. |
| `intensity` | `0.15...1` | Intensity multiplier. |
| `noise` | `0.25...1` | Normalized noise amount. |
| `shape` | ``GrainGradientShape``: `.wave`, `.dots`, `.truchet`, `.corners`, `.ripple`, `.blob`, `.sphere`. | Shape selector. |

See <doc:ParameterRanges#Grain-Gradient> for the full shared context around sizing, motion, and render options.

## Related Symbols

- ``GrainGradient``
- ``GrainGradientParams``
- ``GrainGradientPreset``
