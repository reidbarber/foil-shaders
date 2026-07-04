# Color Panels

Layered color panels with density, taper, fade, blur, and gradient controls.

![Color Panels default preset preview](preview-color-panels.png)

Use ``ColorPanels`` as a SwiftUI view, ``ColorPanelsParams`` for typed parameters, and ``ColorPanelsPreset`` for Paper-derived presets. This implementation tracks the Paper Shaders behavior and preset metadata where the Metal port has a matching shader.

[Paper Shaders reference](https://github.com/paper-design/shaders)

## Example

```swift
import SwiftUI
import FoilShaders

ColorPanels(.default)
  .frame(width: 240, height: 240)
```

## Parameters

| Parameter | Preset-tested range / unit | Notes |
| --- | --- | --- |
| `colors` | `1...7` colors | Array of ``ShaderColor`` values; this shader keeps at most 7 colors. |
| `colorBack` | `0...1` RGBA | Background ``ShaderColor``; RGBA components use `0...1`. |
| `density` | `1.6...3` | Unitless density amount. |
| `angle1` | `-1...0.4` | Panel taper amount for one side; unitless, not degrees. |
| `angle2` | `-1...0.4` | Panel taper amount for the opposite side; unitless, not degrees. |
| `length` | `0.52...3` | Panel length multiplier. |
| `edges` | `0...1` | Normalized edge fade or edge distortion amount. |
| `blur` | `0...0.5` | Normalized blur amount. |
| `fadeIn` | `0...1` | Normalized fade-in amount. |
| `fadeOut` | `0.3...1` | Normalized fade-out amount. |
| `gradient` | `0...0.78` | Normalized gradient blend amount. |

See <doc:ParameterRanges#Color-Panels> for the full shared context around sizing, motion, and render options.

## Related Symbols

- ``ColorPanels``
- ``ColorPanelsParams``
- ``ColorPanelsPreset``
