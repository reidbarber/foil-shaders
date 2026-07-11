# Parameter Ranges

Practical value ranges and units for all shader-specific parameters.

The ranges below are mined from the Paper-derived preset metadata used by the parity suite. They are not always hard validation limits: most numeric values are passed directly to Metal, and several shaders intentionally allow values outside the preset range for stronger effects. Color channels use normalized RGBA components in `0...1`. Angle parameters are degrees where noted.

## Shared Controls

| Parameter | Range / unit | Notes |
| --- | --- | --- |
| `fit` | ``ShaderFit``: `.none`, `.contain`, `.cover` | Coordinate fitting mode. |
| `scale` | Unitless multiplier; presets use `0.3...5` | Values above `1` zoom in; values below `1` zoom out. |
| `rotation` | Degrees; presets use `0...90` | Clockwise rotation. |
| `originX`, `originY` | Normalized fraction; presets use `0.5` | `0.5` is centered. |
| `offsetX`, `offsetY` | Normalized coordinate offset; presets use `-0.3...1` | Positive and negative values pan the shader content. |
| `worldWidth`, `worldHeight` | Rendered coordinate units; `0` means automatic | Use nonzero values to size the shader coordinate box explicitly. |
| `speed` | Animation multiplier; presets use `0.1...4` | `0` freezes automatic time progression. |
| `frame` | Milliseconds | Fixed timeline position. Parity previews use `0` and `5000`. |
| `minPixelRatio` | Scale multiplier; default `2` | Minimum backing-store scale. |
| `maxPixelCount` | Pixel count; default `1920 * 1080 * 4` | Caps drawable pixels before reducing scale. |
## Mesh Gradient

Animated mesh gradient with flowing color fields and optional grain.

| Parameter | Preset-tested range / unit | Notes |
| --- | --- | --- |
| `colors` | `2...4` colors | Array of ``ShaderColor`` values; this shader keeps at most 10 colors. |
| `distortion` | `0.8...1` | Unitless distortion amount. |
| `swirl` | `0.1...1` | Unitless swirl amount. |
| `grainMixer` | `0` | Normalized grain mix amount. |
| `grainOverlay` | `0` | Normalized grain overlay opacity. |

## Smoke Ring

Animated smoke ring with layered noise and radial color bands.

| Parameter | Preset-tested range / unit | Notes |
| --- | --- | --- |
| `colorBack` | `0...1` RGBA | Background ``ShaderColor``; RGBA components use `0...1`. |
| `colors` | `1...4` colors | Array of ``ShaderColor`` values; this shader keeps at most 10 colors. |
| `noiseScale` | `1.1...3` | Noise scale multiplier. |
| `thickness` | `0.01...0.8` | Normalized ring or border thickness. |
| `radius` | `0.25...0.5` | Normalized radius. |
| `innerShape` | `0.7...4` | Inner ring shape exponent amount. |
| `noiseIterations` | `2...10` | Noise iteration count. |

## Neuro Noise

Animated organic noise field with front, mid, and background color blending.

| Parameter | Preset-tested range / unit | Notes |
| --- | --- | --- |
| `colorFront` | `0...1` RGBA | Foreground ``ShaderColor``; RGBA components use `0...1`. |
| `colorMid` | `0...1` RGBA | Middle ``ShaderColor``; RGBA components use `0...1`. |
| `colorBack` | `0...1` RGBA | Background ``ShaderColor``; RGBA components use `0...1`. |
| `brightness` | `0...0.24` | Brightness offset. |
| `contrast` | `0.12...1` | Contrast multiplier or amount. |

## Dot Orbit

Animated orbital dot pattern driven by Voronoi-style cells.

| Parameter | Preset-tested range / unit | Notes |
| --- | --- | --- |
| `colorBack` | `0...1` RGBA | Background ``ShaderColor``; RGBA components use `0...1`. |
| `colors` | `1...5` colors | Array of ``ShaderColor`` values; this shader keeps at most 10 colors. |
| `stepsPerColor` | `2...4` | Number of quantization steps per color stop. |
| `size` | `0.3...1` | Shader-specific size control; see the range for practical values. |
| `sizeRange` | `0...0.7` | Normalized random size variation. |
| `spreading` | `0.3...1` | Normalized dot spread; the shader clamps this to `0...1`. |

## Dot Grid

Static procedural dot grid with variable shape, spacing, stroke, size, and opacity.

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

## Simplex Noise

Animated stepped simplex-noise color bands.

| Parameter | Preset-tested range / unit | Notes |
| --- | --- | --- |
| `colors` | `3...5` colors | Array of ``ShaderColor`` values; this shader keeps at most 10 colors. |
| `stepsPerColor` | `1...2` | Number of quantization steps per color stop. |
| `softness` | `0...1` | Soft-edge amount; most shaders use `0` as hard and `1` as soft. |

## Metaballs

Animated metaball blobs with color gradients.

| Parameter | Preset-tested range / unit | Notes |
| --- | --- | --- |
| `colorBack` | `0...1` RGBA | Background ``ShaderColor``; RGBA components use `0...1`. |
| `colors` | `1...5` colors | Array of ``ShaderColor`` values; this shader keeps at most 8 colors. |
| `count` | `7...18` | Number of animated metaballs. |
| `size` | `0.1...0.83` | Shader-specific size control; see the range for practical values. |
| `sizeRange` | `0.2` | Normalized random size variation. |

## Waves

Static wave-line pattern with shape, spacing, amplitude, and softness controls.

| Parameter | Preset-tested range / unit | Notes |
| --- | --- | --- |
| `colorFront` | `0...1` RGBA | Foreground ``ShaderColor``; RGBA components use `0...1`. |
| `colorBack` | `0...1` RGBA | Background ``ShaderColor``; RGBA components use `0...1`. |
| `shape` | `0...3` | Continuous shape selector; fractional values intentionally morph between wave shapes. |
| `frequency` | `0.2...0.5` | Wave frequency multiplier. |
| `amplitude` | `0.25...1` | Wave amplitude multiplier. |
| `spacing` | `1.05...1.25` | Wave spacing multiplier. |
| `proportion` | `0.1...1` | Normalized threshold or color proportion. |
| `softness` | `0` | Soft-edge amount; most shaders use `0` as hard and `1` as soft. |

## Perlin Noise

Animated Perlin-noise threshold pattern with octave controls.

| Parameter | Preset-tested range / unit | Notes |
| --- | --- | --- |
| `colorFront` | `0...1` RGBA | Foreground ``ShaderColor``; RGBA components use `0...1`. |
| `colorBack` | `0...1` RGBA | Background ``ShaderColor``; RGBA components use `0...1`. |
| `proportion` | `0.35...0.65` | Normalized threshold or color proportion. |
| `softness` | `0...0.35` | Soft-edge amount; most shaders use `0` as hard and `1` as soft. |
| `octaveCount` | `1...6` | Noise octave count; the shader clamps to `1...8`. |
| `persistence` | `0.55...1` | Perlin octave persistence multiplier; values are clamped below `1` in the shader. |
| `lacunarity` | `1.5...2.55` | Perlin octave frequency multiplier. |

## Voronoi

Animated Voronoi cells with gap, glow, and distortion controls.

| Parameter | Preset-tested range / unit | Notes |
| --- | --- | --- |
| `colors` | `1...3` colors | Array of ``ShaderColor`` values; this shader keeps at most 5 colors. |
| `stepsPerColor` | `1...3` | Number of quantization steps per color stop. |
| `colorGap` | `0...1` RGBA | Gap ``ShaderColor``; RGBA components use `0...1`. |
| `colorGlow` | `0...1` RGBA | Glow ``ShaderColor``; RGBA components use `0...1`. |
| `distortion` | `0.38...0.5` | Unitless distortion amount. |
| `gap` | `0...0.04` | Normalized cell gap width. |
| `glow` | `0...1` | Normalized glow amount. |

## Warp

Animated warped color bands based on checks, stripes, or edge patterns.

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

## God Rays

Animated radial light rays with bloom and spot controls.

| Parameter | Preset-tested range / unit | Notes |
| --- | --- | --- |
| `colorBack` | `0...1` RGBA | Background ``ShaderColor``; RGBA components use `0...1`. |
| `colorBloom` | `0...1` RGBA | Bloom ``ShaderColor``; RGBA components use `0...1`. |
| `colors` | `3...4` colors | Array of ``ShaderColor`` values; this shader keeps at most 5 colors. |
| `density` | `0.03...0.45` | Unitless density amount. |
| `spotty` | `0.15...0.77` | Normalized ray spot variation. |
| `midSize` | `0.1...0.33` | Normalized middle glow size. |
| `midIntensity` | `0.4...0.75` | Normalized middle glow intensity. |
| `intensity` | `0.6...0.8` | Intensity multiplier. |
| `bloom` | `0.4...1` | Bloom amount. |

## Spiral

Animated spiral stroke with density, cap, taper, noise, and softness controls.

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

## Swirl

Animated radial swirl bands with twist, center, softness, and noise controls.

| Parameter | Preset-tested range / unit | Notes |
| --- | --- | --- |
| `colorBack` | `0...1` RGBA | Background ``ShaderColor``; RGBA components use `0...1`. |
| `colors` | `1...3` colors | Array of ``ShaderColor`` values; this shader keeps at most 10 colors. |
| `bandCount` | `2...5` | Band count; fractional values are accepted but the shader rounds visible bands. |
| `twist` | `0.1...0.3` | Unitless twist amount. |
| `center` | `0...0.2` | Normalized center offset. |
| `proportion` | `0...0.5` | Normalized threshold or color proportion. |
| `softness` | `0...1` | Soft-edge amount; most shaders use `0` as hard and `1` as soft. |
| `noise` | `0...0.2` | Normalized noise amount. |
| `noiseFrequency` | `0...0.5` | Noise frequency multiplier. |

## Dithering

Procedural dither pattern over generated shapes.

| Parameter | Preset-tested range / unit | Notes |
| --- | --- | --- |
| `colorBack` | `0...1` RGBA | Background ``ShaderColor``; RGBA components use `0...1`. |
| `colorFront` | `0...1` RGBA | Foreground ``ShaderColor``; RGBA components use `0...1`. |
| `shape` | ``DitheringShape``: `.simplex`, `.warp`, `.dots`, `.wave`, `.ripple`, `.swirl`, `.sphere`. | Shape selector. |
| `type` | ``DitheringType``: `.random`, `.twoByTwo`, `.fourByFour`, `.eightByEight`. | Style or matrix selector. |
| `size` | `2...11` | Shader-specific size control; see the range for practical values. |

## Grain Gradient

Grainy static gradient pattern with selectable shape masks.

| Parameter | Preset-tested range / unit | Notes |
| --- | --- | --- |
| `colorBack` | `0...1` RGBA | Background ``ShaderColor``; RGBA components use `0...1`. |
| `colors` | `3...4` colors | Array of ``ShaderColor`` values; this shader keeps at most 7 colors. |
| `softness` | `0...1` | Soft-edge amount; most shaders use `0` as hard and `1` as soft. |
| `intensity` | `0.15...1` | Intensity multiplier. |
| `noise` | `0.25...1` | Normalized noise amount. |
| `shape` | ``GrainGradientShape``: `.wave`, `.dots`, `.truchet`, `.corners`, `.ripple`, `.blob`, `.sphere`. | Shape selector. |

## Pulsing Border

Animated glowing border with rounded corners, pulse, smoke, spots, and bloom.

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

## Color Panels

Layered color panels with density, taper, fade, blur, and gradient controls.

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

## Static Mesh Gradient

Static mesh gradient variant with wave and grain controls.

| Parameter | Preset-tested range / unit | Notes |
| --- | --- | --- |
| `colors` | `4` colors | Array of ``ShaderColor`` values; this shader keeps at most 10 colors. |
| `positions` | `0...42` | Unitless mesh point distribution amount. |
| `waveX` | `0.45...1` | Horizontal wave amplitude multiplier. |
| `waveXShift` | `0...0.7` | Horizontal wave phase shift as a fraction of a cycle. |
| `waveY` | `0.7...1` | Vertical wave amplitude multiplier. |
| `waveYShift` | `0...0.7` | Vertical wave phase shift as a fraction of a cycle. |
| `mixing` | `0...0.93` | Normalized color mixing curve amount. |
| `grainMixer` | `0...0.37` | Normalized grain mix amount. |
| `grainOverlay` | `0...0.78` | Normalized grain overlay opacity. |

## Static Radial Gradient

Static radial gradient with focal point, falloff, distortion, and grain controls.

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

## Paper Texture

Image-based paper texture effect with fiber, folds, crumples, drops, and contrast.

| Parameter | Preset-tested range / unit | Notes |
| --- | --- | --- |
| `colorFront` | `0...1` RGBA | Foreground ``ShaderColor``; RGBA components use `0...1`. |
| `colorBack` | `0...1` RGBA | Background ``ShaderColor``; RGBA components use `0...1`. |
| `contrast` | `0...0.85` | Contrast multiplier or amount. |
| `roughness` | `0...1` | Normalized paper roughness. |
| `fiber` | `0.1...0.35` | Normalized paper fiber amount. |
| `fiberSize` | `0.14...0.22` | Normalized paper fiber scale. |
| `crumples` | `0...1` | Normalized crumple amount. |
| `foldCount` | `1...15` | Number of fold bands. |
| `folds` | `0...1` | Normalized fold opacity. |
| `fade` | `0` | Normalized texture fade amount. |
| `crumpleSize` | `0.1...0.5` | Normalized crumple scale. |
| `drops` | `0...0.2` | Normalized drop/stain amount. |
| `seed` | `1.6...6` | Unitless deterministic random seed. |

## Fluted Glass

Image-based fluted glass distortion with grids, blur, margins, highlights, and grain.

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

## Water

Image-based water caustic distortion with highlights, waves, edges, and layering.

| Parameter | Preset-tested range / unit | Notes |
| --- | --- | --- |
| `colorBack` | `0...1` RGBA | Background ``ShaderColor``; RGBA components use `0...1`. |
| `colorHighlight` | `0...1` RGBA | Highlight ``ShaderColor``; RGBA components use `0...1`. |
| `highlights` | `0...0.4` | Normalized highlight amount. |
| `layering` | `0...0.5` | Normalized caustic layer amount. |
| `edges` | `0...1` | Normalized edge fade or edge distortion amount. |
| `caustic` | `0...0.4` | Normalized caustic distortion amount. |
| `waves` | `0...1` | Normalized wave distortion amount. |
| `size` | `0.15...1` | Shader-specific size control; see the range for practical values. |

## Image Dithering

Image-based dithering with color quantization, ordered dither type, and optional original colors.

| Parameter | Preset-tested range / unit | Notes |
| --- | --- | --- |
| `colorFront` | `0...1` RGBA | Foreground ``ShaderColor``; RGBA components use `0...1`. |
| `colorBack` | `0...1` RGBA | Background ``ShaderColor``; RGBA components use `0...1`. |
| `colorHighlight` | `0...1` RGBA | Highlight ``ShaderColor``; RGBA components use `0...1`. |
| `type` | ``DitheringType``: `.random`, `.twoByTwo`, `.fourByFour`, `.eightByEight`. | Style or matrix selector. |
| `size` | `1...3` | Shader-specific size control; see the range for practical values. |
| `colorSteps` | `1...5` | Number of quantized color steps. |
| `originalColors` | `Bool` | `true` keeps source image colors. |
| `inverted` | `Bool` | `true` inverts the source image luminance. |

## Heatmap

Image-based heatmap coloring with contour, angle, noise, and glow controls.

| Parameter | Preset-tested range / unit | Notes |
| --- | --- | --- |
| `colorBack` | `0...1` RGBA | Background ``ShaderColor``; RGBA components use `0...1`. |
| `colors` | `2...7` colors | Array of ``ShaderColor`` values; this shader keeps at most 10 colors. |
| `contour` | `0.5` | Normalized contour threshold. |
| `angle` | `0` | Angle in degrees. |
| `noise` | `0...0.75` | Normalized noise amount. |
| `innerGlow` | `0.5` | Normalized inner glow amount. |
| `outerGlow` | `0.5` | Normalized outer glow amount. |

## Liquid Metal

Animated liquid metal pattern with tint, contour, chromatic shifts, and shape masks.

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

## Halftone Dots

Image-based halftone dots with grid, radius, contrast, grain, and style controls.

| Parameter | Preset-tested range / unit | Notes |
| --- | --- | --- |
| `colorFront` | `0...1` RGBA | Foreground ``ShaderColor``; RGBA components use `0...1`. |
| `colorBack` | `0...1` RGBA | Background ``ShaderColor``; RGBA components use `0...1`. |
| `size` | `0.5...0.8` | Shader-specific size control; see the range for practical values. |
| `grid` | ``HalftoneDotsGrid``: `.square`, `.hex`. | Halftone dot grid selector. |
| `radius` | `1...2` | Normalized radius. |
| `contrast` | `0.01...1` | Contrast multiplier or amount. |
| `originalColors` | `Bool` | `true` keeps source image colors. |
| `inverted` | `Bool` | `true` inverts the source image luminance. |
| `grainMixer` | `0...0.2` | Normalized grain mix amount. |
| `grainOverlay` | `0...0.3` | Normalized grain overlay opacity. |
| `grainSize` | `0.5` | Normalized grain scale. |
| `type` | ``HalftoneDotsType``: `.classic`, `.gooey`, `.holes`, `.soft`. | Style or matrix selector. |

## Halftone CMYK

Image-based CMYK halftone separation with flood, gain, grain, and style controls.

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
| `type` | ``HalftoneCMYKType``: `.dots`, `.ink`, `.sharp`. | Style or matrix selector. |

## Gem Smoke

Animated gem smoke shape with inner and outer distortion, glow, offset, and color bands.

| Parameter | Preset-tested range / unit | Notes |
| --- | --- | --- |
| `colors` | `2...5` colors | Array of ``ShaderColor`` values; this shader keeps at most 6 colors. |
| `colorBack` | `0...1` RGBA | Background ``ShaderColor``; RGBA components use `0...1`. |
| `colorInner` | `0...1` RGBA | Inner ``ShaderColor``; RGBA components use `0...1`. |
| `innerDistortion` | `0.6...1` | Normalized inner distortion amount. |
| `outerDistortion` | `0.6...1` | Normalized outer distortion amount. |
| `outerGlow` | `0...1` | Normalized outer glow amount. |
| `innerGlow` | `0.65...1` | Normalized inner glow amount. |
| `offset` | `0...0.2` | Normalized vertical smoke offset. |
| `angle` | `0` | Angle in degrees. |
| `size` | `0.8...1` | Shader-specific size control; see the range for practical values. |
| `shape` | ``GemSmokeShape``: `.none`, `.circle`, `.daisy`, `.diamond`, `.metaballs`. | Shape selector. |
