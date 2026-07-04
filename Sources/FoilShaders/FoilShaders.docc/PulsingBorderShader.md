# Pulsing Border

Animated glowing border with rounded corners, pulse, smoke, spots, and bloom.

![Pulsing Border default preset preview](preview-pulsing-border.png)

Use ``PulsingBorder`` as a SwiftUI view, ``PulsingBorderParams`` for typed parameters, and ``PulsingBorderPreset`` for Paper-derived presets. This implementation tracks the Paper Shaders behavior and preset metadata where the Metal port has a matching shader.

[Paper Shaders reference](https://github.com/paper-design/shaders)

## Example

```swift
import SwiftUI
import FoilShaders

PulsingBorder(.default)
  .frame(width: 240, height: 240)
```

## Parameters

| Parameter | Preset-tested range / unit | Notes |
| --- | --- | --- |
| `colorBack` | `0...1` RGBA | Background ``ShaderColor``; RGBA components use `0...1`. |
| `colors` | `1...5` colors | Array of ``ShaderColor`` values; this shader keeps at most 5 colors. |
| `roundness` | `0...1` | Normalized corner radius. |
| `thickness` | `0...1` | Normalized ring or border thickness. |
| `marginLeft` | `0` | Normalized left inset. |
| `marginRight` | `0` | Normalized right inset. |
| `marginTop` | `0` | Normalized top inset. |
| `marginBottom` | `0` | Normalized bottom inset. |
| `aspectRatio` | ``PulsingBorderAspectRatio``: `.auto`, `.square`. | Unitless shader control. |
| `softness` | `0...1` | Soft-edge amount; most shaders use `0` as hard and `1` as soft. |
| `intensity` | `0...0.2` | Intensity multiplier. |
| `bloom` | `0.15...0.45` | Bloom amount. |
| `spots` | `3...5` | Number of animated border spots. |
| `spotSize` | `0.25...1` | Normalized spot radius. |
| `pulse` | `0...0.5` | Normalized pulse amount. |
| `smoke` | `0...1` | Normalized smoke amount. |
| `smokeSize` | `0...0.6` | Normalized smoke scale. |

See <doc:ParameterRanges#Pulsing-Border> for the full shared context around sizing, motion, and render options.

## Related Symbols

- ``PulsingBorder``
- ``PulsingBorderParams``
- ``PulsingBorderPreset``
