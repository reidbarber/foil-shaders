# Dot Grid

Static procedural dot grid with variable shape, spacing, stroke, size, and opacity.

![Dot Grid default preset preview](preview-dot-grid.png)

Use ``DotGrid`` as a SwiftUI view, ``DotGridParams`` for typed parameters, and ``DotGridPreset`` for Paper-derived presets. This implementation tracks the Paper Shaders behavior and preset metadata where the Metal port has a matching shader.

[Paper Shaders reference](https://github.com/paper-design/shaders)

## Example

```swift
import SwiftUI
import FoilShaders

DotGrid(.default)
  .frame(width: 240, height: 240)
```

## Parameters

| Parameter | Preset-tested range / unit | Notes |
| --- | --- | --- |
| `colorBack` | `0...1` RGBA | Background ``ShaderColor``; RGBA components use `0...1`. |
| `colorFill` | `0...1` RGBA | Fill ``ShaderColor``; RGBA components use `0...1`. |
| `colorStroke` | `0...1` RGBA | Stroke ``ShaderColor``; RGBA components use `0...1`. |
| `dotSize` | `2...9` | Dot radius in rendered pixels. |
| `gapX` | `20...32` | Horizontal dot spacing in rendered pixels. |
| `gapY` | `32...90` | Vertical dot spacing in rendered pixels. |
| `strokeWidth` | `0...1` | Stroke width. Dot Grid uses pixels; Spiral uses a normalized width. |
| `sizeRange` | `0...1` | Normalized random size variation. |
| `opacityRange` | `0...0.6` | Normalized random opacity variation. |
| `shape` | ``DotGridShape``: `.circle`, `.diamond`, `.square`, `.triangle`. | Shape selector. |

See <doc:ParameterRanges#Dot-Grid> for the full shared context around sizing, motion, and render options.

## Related Symbols

- ``DotGrid``
- ``DotGridParams``
- ``DotGridPreset``
