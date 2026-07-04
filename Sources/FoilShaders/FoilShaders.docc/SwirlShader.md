# Swirl

Animated radial swirl bands with twist, center, softness, and noise controls.

![Swirl default preset preview](preview-swirl.png)

Use ``Swirl`` as a SwiftUI view, ``SwirlParams`` for typed parameters, and ``SwirlPreset`` for Paper-derived presets. This implementation tracks the Paper Shaders behavior and preset metadata where the Metal port has a matching shader.

[Paper Shaders reference](https://github.com/paper-design/shaders)

## Example

```swift
import SwiftUI
import FoilShaders

Swirl(.default)
  .frame(width: 240, height: 240)
```

## Parameters

| Parameter | Preset-tested range / unit | Notes |
| --- | --- | --- |
| `colorBack` | `0...1` RGBA | Background ``ShaderColor``; RGBA components use `0...1`. |
| `colors` | `1...3` colors | Array of ``ShaderColor`` values; this shader keeps at most 10 colors. |
| `bandCount` | `2...5` | Band count; fractional values are accepted but the shader rounds visible bands. |
| `twist` | `0.1...0.3` | Unitless twist amount. |
| `center` | `0...0.2` | Normalized center offset. |
| `proportion` | `0...0.5` | Normalized threshold or color proportion. |
| `softness` | `0...1` | Soft-edge amount; most shaders use `0` as hard and `1` as soft. |
| `noise` | `0...0.2` | Normalized noise amount. |
| `noiseFrequency` | `0...0.5` | Noise frequency multiplier. |

See <doc:ParameterRanges#Swirl> for the full shared context around sizing, motion, and render options.

## Related Symbols

- ``Swirl``
- ``SwirlParams``
- ``SwirlPreset``
