# Voronoi

Animated Voronoi cells with gap, glow, and distortion controls.

![Voronoi default preset preview](preview-voronoi.png)

Use ``Voronoi`` as a SwiftUI view, ``VoronoiParams`` for typed parameters, and ``VoronoiPreset`` for Paper-derived presets. This implementation tracks the Paper Shaders behavior and preset metadata where the Metal port has a matching shader.

[Paper Shaders reference](https://github.com/paper-design/shaders)

## Example

```swift
import SwiftUI
import FoilShaders

Voronoi(.default)
  .frame(width: 240, height: 240)
```

## Parameters

| Parameter | Preset-tested range / unit | Notes |
| --- | --- | --- |
| `colors` | `1...3` colors | Array of ``ShaderColor`` values; this shader keeps at most 5 colors. |
| `stepsPerColor` | `1...3` | Number of quantization steps per color stop. |
| `colorGap` | `0...1` RGBA | Gap ``ShaderColor``; RGBA components use `0...1`. |
| `colorGlow` | `0...1` RGBA | Glow ``ShaderColor``; RGBA components use `0...1`. |
| `distortion` | `0.38...0.5` | Unitless distortion amount. |
| `gap` | `0...0.04` | Normalized cell gap width. |
| `glow` | `0...1` | Normalized glow amount. |

See <doc:ParameterRanges#Voronoi> for the full shared context around sizing, motion, and render options.

## Related Symbols

- ``Voronoi``
- ``VoronoiParams``
- ``VoronoiPreset``
