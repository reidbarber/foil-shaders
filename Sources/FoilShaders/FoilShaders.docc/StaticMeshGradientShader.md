# Static Mesh Gradient

Static mesh gradient variant with wave and grain controls.

![Static Mesh Gradient default preset preview](preview-static-mesh-gradient.png)

Use ``StaticMeshGradient`` as a SwiftUI view, ``StaticMeshGradientParams`` for typed parameters, and ``StaticMeshGradientPreset`` for Paper-derived presets. This implementation tracks the Paper Shaders behavior and preset metadata where the Metal port has a matching shader.

[Paper Shaders reference](https://github.com/paper-design/shaders)

## Example

```swift
import SwiftUI
import FoilShaders

StaticMeshGradient(.default)
  .frame(width: 240, height: 240)
```

## Parameters

| Parameter | Preset-tested range / unit | Notes |
| --- | --- | --- |
| `colors` | `4` colors | Array of ``ShaderColor`` values; this shader keeps at most 10 colors. |
| `positions` | `0...42` | Unitless mesh point distribution amount. |
| `waveX` | `0.45...1` | Horizontal wave amplitude multiplier. |
| `waveXShift` | `0...0.7` | Horizontal wave phase shift as a fraction of a cycle. |
| `waveY` | `0.7...1` | Vertical wave amplitude multiplier. |
| `waveYShift` | `0...0.7` | Vertical wave phase shift as a fraction of a cycle. |
| `mixing` | `0...0.93` | Normalized color mixing curve amount. |
| `grainMixer` | `0...0.37` | Normalized grain mix amount. |
| `grainOverlay` | `0...0.78` | Normalized grain overlay opacity. |

See <doc:ParameterRanges#Static-Mesh-Gradient> for the full shared context around sizing, motion, and render options.

## Related Symbols

- ``StaticMeshGradient``
- ``StaticMeshGradientParams``
- ``StaticMeshGradientPreset``
