# Spiral

Animated spiral stroke with density, cap, taper, noise, and softness controls.

![Spiral default preset preview](preview-spiral.png)

Use ``Spiral`` as a SwiftUI view, ``SpiralParams`` for typed parameters, and ``SpiralPreset`` for Paper-derived presets. This implementation tracks the Paper Shaders behavior and preset metadata where the Metal port has a matching shader.

[Paper Shaders reference](https://github.com/paper-design/shaders)

## Example

```swift
import SwiftUI
import FoilShaders

Spiral(.default)
  .frame(width: 240, height: 240)
```

## Parameters

| Parameter | Preset-tested range / unit | Notes |
| --- | --- | --- |
| `colorBack` | `0...1` RGBA | Background ``ShaderColor``; RGBA components use `0...1`. |
| `colorFront` | `0...1` RGBA | Foreground ``ShaderColor``; RGBA components use `0...1`. |
| `density` | `0.2...1` | Unitless density amount. |
| `distortion` | `0` | Unitless distortion amount. |
| `strokeWidth` | `0.5...0.75` | Stroke width. Dot Grid uses pixels; Spiral uses a normalized width. |
| `strokeTaper` | `0...0.18` | Normalized stroke taper. |
| `strokeCap` | `0...1` | Normalized stroke cap amount; `0` is flat and `1` is rounded/tapered. |
| `noise` | `0...1` | Normalized noise amount. |
| `noiseFrequency` | `0...0.33` | Noise frequency multiplier. |
| `softness` | `0...0.5` | Soft-edge amount; most shaders use `0` as hard and `1` as soft. |

See <doc:ParameterRanges#Spiral> for the full shared context around sizing, motion, and render options.

## Related Symbols

- ``Spiral``
- ``SpiralParams``
- ``SpiralPreset``
