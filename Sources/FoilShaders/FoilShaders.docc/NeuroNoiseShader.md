# Neuro Noise

Animated organic noise field with front, mid, and background color blending.

![Neuro Noise default preset preview](preview-neuro-noise.png)

Use ``NeuroNoise`` as a SwiftUI view, ``NeuroNoiseParams`` for typed parameters, and ``NeuroNoisePreset`` for Paper-derived presets. This implementation tracks the Paper Shaders behavior and preset metadata where the Metal port has a matching shader.

[Paper Shaders reference](https://github.com/paper-design/shaders)

## Example

```swift
import SwiftUI
import FoilShaders

NeuroNoise(.default)
  .frame(width: 240, height: 240)
```

## Parameters

| Parameter | Preset-tested range / unit | Notes |
| --- | --- | --- |
| `colorFront` | `0...1` RGBA | Foreground ``ShaderColor``; RGBA components use `0...1`. |
| `colorMid` | `0...1` RGBA | Middle ``ShaderColor``; RGBA components use `0...1`. |
| `colorBack` | `0...1` RGBA | Background ``ShaderColor``; RGBA components use `0...1`. |
| `brightness` | `0...0.24` | Brightness offset. |
| `contrast` | `0.12...1` | Contrast multiplier or amount. |

See <doc:ParameterRanges#Neuro-Noise> for the full shared context around sizing, motion, and render options.

## Related Symbols

- ``NeuroNoise``
- ``NeuroNoiseParams``
- ``NeuroNoisePreset``
