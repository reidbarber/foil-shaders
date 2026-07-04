# Dot Orbit

Animated orbital dot pattern driven by Voronoi-style cells.

![Dot Orbit default preset preview](preview-dot-orbit.png)

Use ``DotOrbit`` as a SwiftUI view, ``DotOrbitParams`` for typed parameters, and ``DotOrbitPreset`` for Paper-derived presets. This implementation tracks the Paper Shaders behavior and preset metadata where the Metal port has a matching shader.

[Paper Shaders reference](https://github.com/paper-design/shaders)

## Example

```swift
import SwiftUI
import FoilShaders

DotOrbit(.default)
  .frame(width: 240, height: 240)
```

## Parameters

| Parameter | Preset-tested range / unit | Notes |
| --- | --- | --- |
| `colorBack` | `0...1` RGBA | Background ``ShaderColor``; RGBA components use `0...1`. |
| `colors` | `1...5` colors | Array of ``ShaderColor`` values; this shader keeps at most 10 colors. |
| `stepsPerColor` | `2...4` | Number of quantization steps per color stop. |
| `size` | `0.3...1` | Shader-specific size control; see the range for practical values. |
| `sizeRange` | `0...0.7` | Normalized random size variation. |
| `spreading` | `0.3...1` | Normalized dot spread; the shader clamps this to `0...1`. |

See <doc:ParameterRanges#Dot-Orbit> for the full shared context around sizing, motion, and render options.

## Related Symbols

- ``DotOrbit``
- ``DotOrbitParams``
- ``DotOrbitPreset``
