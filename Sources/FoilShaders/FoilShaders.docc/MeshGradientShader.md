# Mesh Gradient

Animated mesh gradient with flowing color fields and optional grain.

![Mesh Gradient default preset preview](preview-mesh-gradient.png)

Use ``MeshGradient`` as a SwiftUI view, ``MeshGradientParams`` for typed parameters, and ``MeshGradientPreset`` for Paper-derived presets. This implementation tracks the Paper Shaders behavior and preset metadata where the Metal port has a matching shader.

[Paper Shaders reference](https://github.com/paper-design/shaders)

## Example

```swift
import SwiftUI
import FoilShaders

MeshGradient(.default)
  .frame(width: 240, height: 240)
```

## Parameters

| Parameter | Preset-tested range / unit | Notes |
| --- | --- | --- |
| `colors` | `2...4` colors | Array of ``ShaderColor`` values; this shader keeps at most 10 colors. |
| `distortion` | `0.8...1` | Unitless distortion amount. |
| `swirl` | `0.1...1` | Unitless swirl amount. |
| `grainMixer` | `0` | Normalized grain mix amount. |
| `grainOverlay` | `0` | Normalized grain overlay opacity. |

See <doc:ParameterRanges#Mesh-Gradient> for the full shared context around sizing, motion, and render options.

## Related Symbols

- ``MeshGradient``
- ``MeshGradientParams``
- ``MeshGradientPreset``
