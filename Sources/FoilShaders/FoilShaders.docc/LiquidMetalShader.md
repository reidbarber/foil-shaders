# Liquid Metal

Animated liquid metal pattern with tint, contour, chromatic shifts, and shape masks.

![Liquid Metal default preset preview](preview-liquid-metal.png)

Use ``LiquidMetal`` as a SwiftUI view, ``LiquidMetalParams`` for typed parameters, and ``LiquidMetalPreset`` for Paper-derived presets. This implementation tracks the Paper Shaders behavior and preset metadata where the Metal port has a matching shader.

[Paper Shaders reference](https://github.com/paper-design/shaders)

## Example

```swift
import SwiftUI
import FoilShaders

LiquidMetal(.default)
  .frame(width: 240, height: 240)
```

## Parameters

| Parameter | Preset-tested range / unit | Notes |
| --- | --- | --- |
| `colorBack` | `0...1` RGBA | Background ``ShaderColor``; RGBA components use `0...1`. |
| `colorTint` | `0...1` RGBA | Tint ``ShaderColor``; RGBA components use `0...1`. |
| `repetition` | `1.5...6` | Pattern repetition count. |
| `softness` | `0.05...0.8` | Soft-edge amount; most shaders use `0` as hard and `1` as soft. |
| `shiftRed` | `0...1` | Red channel shift amount. |
| `shiftBlue` | `-1...0.3` | Blue channel shift amount; negative values shift the opposite direction. |
| `distortion` | `0...0.4` | Unitless distortion amount. |
| `contour` | `0...0.4` | Normalized contour threshold. |
| `angle` | `0...90` | Angle in degrees. |
| `shape` | ``LiquidMetalShape``: `.none`, `.circle`, `.daisy`, `.diamond`, `.metaballs`. | Shape selector. |

See <doc:ParameterRanges#Liquid-Metal> for the full shared context around sizing, motion, and render options.

## Related Symbols

- ``LiquidMetal``
- ``LiquidMetalParams``
- ``LiquidMetalPreset``
