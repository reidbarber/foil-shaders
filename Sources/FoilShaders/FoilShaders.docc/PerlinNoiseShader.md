# Perlin Noise

Animated Perlin-noise threshold pattern with octave controls.

![Perlin Noise default preset preview](preview-perlin-noise.png)

Use ``PerlinNoise`` as a SwiftUI view, ``PerlinNoiseParams`` for typed parameters, and ``PerlinNoisePreset`` for Paper-derived presets. This implementation tracks the Paper Shaders behavior and preset metadata where the Metal port has a matching shader.

[Paper Shaders reference](https://github.com/paper-design/shaders)

## Example

```swift
import SwiftUI
import FoilShaders

PerlinNoise(.default)
  .frame(width: 240, height: 240)
```

## Parameters

| Parameter | Preset-tested range / unit | Notes |
| --- | --- | --- |
| `colorFront` | `0...1` RGBA | Foreground ``ShaderColor``; RGBA components use `0...1`. |
| `colorBack` | `0...1` RGBA | Background ``ShaderColor``; RGBA components use `0...1`. |
| `proportion` | `0.35...0.65` | Normalized threshold or color proportion. |
| `softness` | `0...0.35` | Soft-edge amount; most shaders use `0` as hard and `1` as soft. |
| `octaveCount` | `1...6` | Noise octave count; the shader clamps to `1...8`. |
| `persistence` | `0.55...1` | Perlin octave persistence multiplier; values are clamped below `1` in the shader. |
| `lacunarity` | `1.5...2.55` | Perlin octave frequency multiplier. |

See <doc:ParameterRanges#Perlin-Noise> for the full shared context around sizing, motion, and render options.

## Related Symbols

- ``PerlinNoise``
- ``PerlinNoiseParams``
- ``PerlinNoisePreset``
