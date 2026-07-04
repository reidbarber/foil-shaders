# API Evolution

Understand how Foil Shaders evolves its public Swift API.

## Overview

Foil Shaders is distributed as Swift source through SwiftPM. Public enums in a
source package are visible to exhaustive `switch` statements in client code, so
the package documents enum case additions as part of its compatibility policy
instead of relying on binary framework library-evolution annotations.

## Enum Cases

Public case-bearing enums are not frozen. New cases in enums such as
`FoilShadersRenderer/ShaderKind`, `ShaderParameters`, `ShaderFit`, and the
shader shape/type enums may ship in minor releases after 1.0.

This policy covers shader-selection and parameter enums, including
`DotGridShape`, `DitheringShape`, `DitheringType`, `WarpPattern`,
`GrainGradientShape`, `PulsingBorderAspectRatio`, `HalftoneDotsType`,
`HalftoneDotsGrid`, `HalftoneCMYKType`, `LiquidMetalShape`,
`GlassGridShape`, `GlassDistortionShape`, and `GemSmokeShape`.

Client code that switches over these enums should include a `default:` branch.
Removing or renaming cases, changing raw values, and changing associated values
remain breaking changes.

## Codable Format

`ShaderConfiguration` and the configuration graph are user-persistable
`Codable` values. Their encoded form is part of the compatibility surface.

`ShaderParameters` uses an explicit discriminator and payload shape:

```json
{
  "type": "dotGrid",
  "params": {
    "shape": 1
  }
}
```

Shape, type, fit, and aspect-ratio enums encode their `Float` raw values. Those
raw values are stable persisted values as well as shader uniform values; do not
renumber existing cases without treating it as a breaking persistence change.
