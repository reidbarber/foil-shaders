# Fluted Glass

Image-based fluted glass distortion with grids, blur, margins, highlights, and grain.

![Fluted Glass default preset preview](preview-fluted-glass.png)

Use ``FlutedGlass`` as a SwiftUI view, ``FlutedGlassParams`` for typed parameters, and ``FlutedGlassPreset`` for Paper-derived presets. This implementation tracks the Paper Shaders behavior and preset metadata where the Metal port has a matching shader.

[Paper Shaders reference](https://github.com/paper-design/shaders)

## Example

```swift
import SwiftUI
import FoilShaders

FlutedGlass(.default)
  .frame(width: 240, height: 240)
```

## Parameters

| Parameter | Preset-tested range / unit | Notes |
| --- | --- | --- |
| `colorBack` | `0...1` RGBA | Background ``ShaderColor``; RGBA components use `0...1`. |
| `colorShadow` | `0...1` RGBA | Shadow ``ShaderColor``; RGBA components use `0...1`. |
| `colorHighlight` | `0...1` RGBA | Highlight ``ShaderColor``; RGBA components use `0...1`. |
| `shadows` | `0...0.4` | Normalized shadow strength. |
| `size` | `0.4...0.9` | Shader-specific size control; see the range for practical values. |
| `angle` | `0...30` | Angle in degrees. |
| `distortion` | `0.5...1` | Unitless distortion amount. |
| `shift` | `0` | Normalized pattern phase shift. |
| `blur` | `0...1` | Normalized blur amount. |
| `edges` | `0.25...0.5` | Normalized edge fade or edge distortion amount. |
| `marginLeft` | `0...0.1` | Normalized left inset. |
| `marginRight` | `0...0.1` | Normalized right inset. |
| `marginTop` | `0...0.1` | Normalized top inset. |
| `marginBottom` | `0...0.1` | Normalized bottom inset. |
| `stretch` | `0...1` | Normalized stretch amount. |
| `distortionShape` | ``GlassDistortionShape``: `.prism`, `.lens`, `.contour`, `.cascade`, `.flat`. | Glass distortion shape selector. |
| `highlights` | `0...0.1` | Normalized highlight amount. |
| `shape` | ``GlassGridShape``: `.lines`, `.linesIrregular`, `.wave`, `.zigzag`, `.pattern`. | Shape selector. |
| `grainMixer` | `0...0.1` | Normalized grain mix amount. |
| `grainOverlay` | `0...0.1` | Normalized grain overlay opacity. |

See <doc:ParameterRanges#Fluted-Glass> for the full shared context around sizing, motion, and render options.

## Related Symbols

- ``FlutedGlass``
- ``FlutedGlassParams``
- ``FlutedGlassPreset``
