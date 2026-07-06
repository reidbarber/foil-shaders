# Waves

Static wave-line pattern with shape, spacing, amplitude, and softness controls.

![Waves default preset preview](preview-waves.png)

Use ``Waves`` as a SwiftUI view, ``WavesParams`` for typed parameters, and ``WavesPreset`` for Paper-derived presets. This implementation tracks the Paper Shaders behavior and preset metadata where the Metal port has a matching shader.

[Paper Shaders reference](https://github.com/paper-design/shaders)

## Example

```swift
import SwiftUI
import FoilShaders

Waves(.default)
  .frame(width: 240, height: 240)
```

## Parameters

| Parameter | Preset-tested range / unit | Notes |
| --- | --- | --- |
| `colorFront` | `0...1` RGBA | Foreground ``ShaderColor``; RGBA components use `0...1`. |
| `colorBack` | `0...1` RGBA | Background ``ShaderColor``; RGBA components use `0...1`. |
| `shape` | `0...3` | Continuous shape selector; fractional values intentionally morph between wave shapes. |
| `frequency` | `0.2...0.5` | Wave frequency multiplier. |
| `amplitude` | `0.25...1` | Wave amplitude multiplier. |
| `spacing` | `1.05...1.25` | Wave spacing multiplier. |
| `proportion` | `0.1...1` | Normalized threshold or color proportion. |
| `softness` | `0` | Soft-edge amount; most shaders use `0` as hard and `1` as soft. |

See <doc:ParameterRanges#Waves> for the full shared context around sizing, motion, and render options.

## Related Symbols

- ``Waves``
- ``WavesParams``
- ``WavesPreset``
