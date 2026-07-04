# Halftone CMYK

Image-based CMYK halftone separation with flood, gain, grain, and style controls.

![Halftone CMYK default preset preview](preview-halftone-cmyk.png)

Use ``HalftoneCmyk`` as a SwiftUI view, ``HalftoneCmykParams`` for typed parameters, and ``HalftoneCmykPreset`` for Paper-derived presets. This implementation tracks the Paper Shaders behavior and preset metadata where the Metal port has a matching shader.

[Paper Shaders reference](https://github.com/paper-design/shaders)

## Example

```swift
import SwiftUI
import FoilShaders

HalftoneCmyk(.default)
  .frame(width: 240, height: 240)
```

## Parameters

| Parameter | Preset-tested range / unit | Notes |
| --- | --- | --- |
| `colorBack` | `0...1` RGBA | Background ``ShaderColor``; RGBA components use `0...1`. |
| `colorC` | `0...1` RGBA | Cyan ink ``ShaderColor``; RGBA components use `0...1`. |
| `colorM` | `0...1` RGBA | Magenta ink ``ShaderColor``; RGBA components use `0...1`. |
| `colorY` | `0...1` RGBA | Yellow ink ``ShaderColor``; RGBA components use `0...1`. |
| `colorK` | `0...1` RGBA | Black ink ``ShaderColor``; RGBA components use `0...1`. |
| `size` | `0.01...0.88` | Shader-specific size control; see the range for practical values. |
| `contrast` | `1...2` | Contrast multiplier or amount. |
| `softness` | `0...1` | Soft-edge amount; most shaders use `0` as hard and `1` as soft. |
| `grainSize` | `0...0.5` | Normalized grain scale. |
| `grainMixer` | `0...0.15` | Normalized grain mix amount. |
| `grainOverlay` | `0...0.25` | Normalized grain overlay opacity. |
| `gridNoise` | `0.2...0.6` | Normalized random grid displacement. |
| `floodC` | `0...0.15` | Cyan channel flood amount. |
| `floodM` | `0` | Magenta channel flood amount. |
| `floodY` | `0` | Yellow channel flood amount. |
| `floodK` | `0...0.1` | Black channel flood amount. |
| `gainC` | `-0.17...1` | Cyan channel gain adjustment. |
| `gainM` | `-0.45...0.44` | Magenta channel gain adjustment. |
| `gainY` | `-1...0.2` | Yellow channel gain adjustment. |
| `gainK` | `0` | Black channel gain adjustment. |
| `type` | ``HalftoneCmykType``: `.dots`, `.ink`, `.sharp`. | Style or matrix selector. |

See <doc:ParameterRanges#Halftone-CMYK> for the full shared context around sizing, motion, and render options.

## Related Symbols

- ``HalftoneCmyk``
- ``HalftoneCmykParams``
- ``HalftoneCmykPreset``
