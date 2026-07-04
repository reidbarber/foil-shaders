# Warp

Animated warped color bands based on checks, stripes, or edge patterns.

![Warp default preset preview](preview-warp.png)

Use ``Warp`` as a SwiftUI view, ``WarpParams`` for typed parameters, and ``WarpPreset`` for Paper-derived presets. This implementation tracks the Paper Shaders behavior and preset metadata where the Metal port has a matching shader.

[Paper Shaders reference](https://github.com/paper-design/shaders)

## Example

```swift
import SwiftUI
import FoilShaders

Warp(.default)
  .frame(width: 240, height: 240)
```

## Parameters

| Parameter | Preset-tested range / unit | Notes |
| --- | --- | --- |
| `colors` | `3...4` colors | Array of ``ShaderColor`` values; this shader keeps at most 10 colors. |
| `proportion` | `0.05...0.67` | Normalized threshold or color proportion. |
| `softness` | `0...1.5` | Soft-edge amount; most shaders use `0` as hard and `1` as soft. |
| `shape` | ``WarpPattern``: `.checks`, `.stripes`, `.edge`. | Shape selector. |
| `shapeScale` | `0.1...1` | Pattern scale multiplier. |
| `distortion` | `0...0.25` | Unitless distortion amount. |
| `swirl` | `0.2...0.9` | Unitless swirl amount. |
| `swirlIterations` | `3...10` | Number of swirl iterations. |

See <doc:ParameterRanges#Warp> for the full shared context around sizing, motion, and render options.

## Related Symbols

- ``Warp``
- ``WarpParams``
- ``WarpPreset``
