# Heatmap

Image-based heatmap coloring with contour, angle, noise, and glow controls.

![Heatmap default preset preview](preview-heatmap.png)

Use ``Heatmap`` as a SwiftUI view, ``HeatmapParams`` for typed parameters, and ``HeatmapPreset`` for Paper-derived presets. This implementation tracks the Paper Shaders behavior and preset metadata where the Metal port has a matching shader.

[Paper Shaders reference](https://github.com/paper-design/shaders)

## Example

```swift
import SwiftUI
import FoilShaders

Heatmap(.default)
  .frame(width: 240, height: 240)
```

## Parameters

| Parameter | Preset-tested range / unit | Notes |
| --- | --- | --- |
| `colorBack` | `0...1` RGBA | Background ``ShaderColor``; RGBA components use `0...1`. |
| `colors` | `2...7` colors | Array of ``ShaderColor`` values; this shader keeps at most 10 colors. |
| `contour` | `0.5` | Normalized contour threshold. |
| `angle` | `0` | Angle in degrees. |
| `noise` | `0...0.75` | Normalized noise amount. |
| `innerGlow` | `0.5` | Normalized inner glow amount. |
| `outerGlow` | `0.5` | Normalized outer glow amount. |

See <doc:ParameterRanges#Heatmap> for the full shared context around sizing, motion, and render options.

## Related Symbols

- ``Heatmap``
- ``HeatmapParams``
- ``HeatmapPreset``
