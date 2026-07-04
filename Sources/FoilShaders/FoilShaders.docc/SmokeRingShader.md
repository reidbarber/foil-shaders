# Smoke Ring

Animated smoke ring with layered noise and radial color bands.

![Smoke Ring default preset preview](preview-smoke-ring.png)

Use ``SmokeRing`` as a SwiftUI view, ``SmokeRingParams`` for typed parameters, and ``SmokeRingPreset`` for Paper-derived presets. This implementation tracks the Paper Shaders behavior and preset metadata where the Metal port has a matching shader.

[Paper Shaders reference](https://github.com/paper-design/shaders)

## Example

```swift
import SwiftUI
import FoilShaders

SmokeRing(.default)
  .frame(width: 240, height: 240)
```

## Parameters

| Parameter | Preset-tested range / unit | Notes |
| --- | --- | --- |
| `colorBack` | `0...1` RGBA | Background ``ShaderColor``; RGBA components use `0...1`. |
| `colors` | `1...4` colors | Array of ``ShaderColor`` values; this shader keeps at most 10 colors. |
| `noiseScale` | `1.1...3` | Noise scale multiplier. |
| `thickness` | `0.01...0.8` | Normalized ring or border thickness. |
| `radius` | `0.25...0.5` | Normalized radius. |
| `innerShape` | `0.7...4` | Inner ring shape exponent amount. |
| `noiseIterations` | `2...10` | Noise iteration count. |

See <doc:ParameterRanges#Smoke-Ring> for the full shared context around sizing, motion, and render options.

## Related Symbols

- ``SmokeRing``
- ``SmokeRingParams``
- ``SmokeRingPreset``
