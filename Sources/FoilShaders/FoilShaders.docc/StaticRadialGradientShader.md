# Static Radial Gradient

Static radial gradient with focal point, falloff, distortion, and grain controls.

![Static Radial Gradient default preset preview](preview-static-radial-gradient.png)

Use ``StaticRadialGradient`` as a SwiftUI view, ``StaticRadialGradientParams`` for typed parameters, and ``StaticRadialGradientPreset`` for Paper-derived presets. This implementation tracks the Paper Shaders behavior and preset metadata where the Metal port has a matching shader.

[Paper Shaders reference](https://github.com/paper-design/shaders)

## Example

```swift
import SwiftUI
import FoilShaders

StaticRadialGradient(.default)
  .frame(width: 240, height: 240)
```

## Parameters

| Parameter | Preset-tested range / unit | Notes |
| --- | --- | --- |
| `colorBack` | `0...1` RGBA | Background ``ShaderColor``; RGBA components use `0...1`. |
| `colors` | `3...4` colors | Array of ``ShaderColor`` values; this shader keeps at most 10 colors. |
| `radius` | `0.8...1` | Normalized radius. |
| `focalDistance` | `0...0.99` | Normalized distance from the center. |
| `focalAngle` | `0` | Angle in degrees. |
| `falloff` | `0...0.9` | Normalized falloff width. |
| `mixing` | `0...1` | Normalized color mixing curve amount. |
| `distortion` | `0...1` | Unitless distortion amount. |
| `distortionShift` | `0` | Normalized distortion phase shift. |
| `distortionFreq` | `12` | Distortion frequency multiplier. |
| `grainMixer` | `0...1` | Normalized grain mix amount. |
| `grainOverlay` | `0...0.5` | Normalized grain overlay opacity. |

See <doc:ParameterRanges#Static-Radial-Gradient> for the full shared context around sizing, motion, and render options.

## Related Symbols

- ``StaticRadialGradient``
- ``StaticRadialGradientParams``
- ``StaticRadialGradientPreset``
