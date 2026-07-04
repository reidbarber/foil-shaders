# Simplex Noise

Animated stepped simplex-noise color bands.

![Simplex Noise default preset preview](preview-simplex-noise.png)

Use ``SimplexNoise`` as a SwiftUI view, ``SimplexNoiseParams`` for typed parameters, and ``SimplexNoisePreset`` for Paper-derived presets. This implementation tracks the Paper Shaders behavior and preset metadata where the Metal port has a matching shader.

[Paper Shaders reference](https://github.com/paper-design/shaders)

## Example

```swift
import SwiftUI
import FoilShaders

SimplexNoise(.default)
  .frame(width: 240, height: 240)
```

## Parameters

| Parameter | Preset-tested range / unit | Notes |
| --- | --- | --- |
| `colors` | `3...5` colors | Array of ``ShaderColor`` values; this shader keeps at most 10 colors. |
| `stepsPerColor` | `1...2` | Number of quantization steps per color stop. |
| `softness` | `0...1` | Soft-edge amount; most shaders use `0` as hard and `1` as soft. |

See <doc:ParameterRanges#Simplex-Noise> for the full shared context around sizing, motion, and render options.

## Related Symbols

- ``SimplexNoise``
- ``SimplexNoiseParams``
- ``SimplexNoisePreset``
