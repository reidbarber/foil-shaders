import fs from "node:fs";

const snapshotPath = process.argv[2] ?? "paper-presets.json";
if (!fs.existsSync(snapshotPath)) {
  console.error("Usage: node Scripts/generate-swift-presets.mjs <paper-presets-json>");
  console.error("       Defaults to ./paper-presets.json when no path is provided.");
  process.exit(1);
}
const snapshot = JSON.parse(fs.readFileSync(snapshotPath, "utf8"));

const sizingKeys = [
  "fit",
  "scale",
  "rotation",
  "originX",
  "originY",
  "offsetX",
  "offsetY",
  "worldWidth",
  "worldHeight",
];

const defaultSizing = {
  fit: "contain",
  scale: 1,
  rotation: 0,
  originX: 0.5,
  originY: 0.5,
  offsetX: 0,
  offsetY: 0,
  worldWidth: 0,
  worldHeight: 0,
};

const enumMaps = snapshot.enums;

const specs = [
  {
    key: "mesh-gradient",
    arrayName: "meshGradientPresets",
    presetType: "MeshGradientPreset",
    paramsType: "MeshGradientParams",
    fields: ["colors", "distortion", "swirl", "grainMixer", "grainOverlay"],
  },
  {
    key: "smoke-ring",
    arrayName: "smokeRingPresets",
    presetType: "SmokeRingPreset",
    paramsType: "SmokeRingParams",
    fields: ["colorBack", "colors", "noiseScale", "thickness", "radius", "innerShape", "noiseIterations"],
  },
  {
    key: "neuro-noise",
    arrayName: "neuroNoisePresets",
    presetType: "NeuroNoisePreset",
    paramsType: "NeuroNoiseParams",
    fields: ["colorFront", "colorMid", "colorBack", "brightness", "contrast"],
  },
  {
    key: "dot-orbit",
    arrayName: "dotOrbitPresets",
    presetType: "DotOrbitPreset",
    paramsType: "DotOrbitParams",
    fields: ["colorBack", "colors", "stepsPerColor", "size", "sizeRange", "spreading"],
  },
  {
    key: "dot-grid",
    arrayName: "dotGridPresets",
    presetType: "DotGridPreset",
    paramsType: "DotGridParams",
    renderOptions: "ShaderRenderOptions(maxPixelCount: 6016 * 3384)",
    fields: [
      "colorBack",
      "colorFill",
      "colorStroke",
      { swift: "dotSize", paper: "size" },
      "gapX",
      "gapY",
      "strokeWidth",
      "sizeRange",
      "opacityRange",
      { swift: "shape", enum: "DotGridShapes" },
    ],
  },
  {
    key: "simplex-noise",
    arrayName: "simplexNoisePresets",
    presetType: "SimplexNoisePreset",
    paramsType: "SimplexNoiseParams",
    fields: ["colors", "stepsPerColor", "softness"],
  },
  {
    key: "metaballs",
    arrayName: "metaballsPresets",
    presetType: "MetaballsPreset",
    paramsType: "MetaballsParams",
    fields: ["colorBack", "colors", "count", "size", { swift: "sizeRange", defaultValue: 0.2 }],
  },
  {
    key: "waves",
    arrayName: "wavesPresets",
    presetType: "WavesPreset",
    paramsType: "WavesParams",
    renderOptions: "ShaderRenderOptions(maxPixelCount: 6016 * 3384)",
    fields: ["colorFront", "colorBack", "shape", "frequency", "amplitude", "spacing", "proportion", "softness"],
  },
  {
    key: "perlin-noise",
    arrayName: "perlinNoisePresets",
    presetType: "PerlinNoisePreset",
    paramsType: "PerlinNoiseParams",
    fields: ["colorFront", "colorBack", "proportion", "softness", "octaveCount", "persistence", "lacunarity"],
  },
  {
    key: "voronoi",
    arrayName: "voronoiPresets",
    presetType: "VoronoiPreset",
    paramsType: "VoronoiParams",
    fields: ["colors", "stepsPerColor", "colorGap", "colorGlow", "distortion", "gap", "glow"],
  },
  {
    key: "warp",
    arrayName: "warpPresets",
    presetType: "WarpPreset",
    paramsType: "WarpParams",
    fields: [
      "colors",
      "proportion",
      "softness",
      { swift: "shape", enum: "WarpPatterns" },
      "shapeScale",
      "distortion",
      "swirl",
      "swirlIterations",
    ],
  },
  {
    key: "god-rays",
    arrayName: "godRaysPresets",
    presetType: "GodRaysPreset",
    paramsType: "GodRaysParams",
    fields: [
      "colorBack",
      "colorBloom",
      "colors",
      "density",
      "spotty",
      "midSize",
      "midIntensity",
      "intensity",
      "bloom",
    ],
  },
  {
    key: "spiral",
    arrayName: "spiralPresets",
    presetType: "SpiralPreset",
    paramsType: "SpiralParams",
    fields: [
      "colorBack",
      "colorFront",
      "density",
      "distortion",
      "strokeWidth",
      "strokeTaper",
      "strokeCap",
      "noise",
      "noiseFrequency",
      "softness",
    ],
  },
  {
    key: "swirl",
    arrayName: "swirlPresets",
    presetType: "SwirlPreset",
    paramsType: "SwirlParams",
    fields: ["colorBack", "colors", "bandCount", "twist", "center", "proportion", "softness", "noise", "noiseFrequency"],
  },
  {
    key: "dithering",
    arrayName: "ditheringPresets",
    presetType: "DitheringPreset",
    paramsType: "DitheringParams",
    fields: ["colorBack", "colorFront", { swift: "shape", enum: "DitheringShapes" }, { swift: "type", enum: "DitheringTypes" }, "size"],
  },
  {
    key: "grain-gradient",
    arrayName: "grainGradientPresets",
    presetType: "GrainGradientPreset",
    paramsType: "GrainGradientParams",
    fields: ["colorBack", "colors", "softness", "intensity", "noise", { swift: "shape", enum: "GrainGradientShapes" }],
  },
  {
    key: "pulsing-border",
    arrayName: "pulsingBorderPresets",
    presetType: "PulsingBorderPreset",
    paramsType: "PulsingBorderParams",
    fields: [
      "colorBack",
      "colors",
      "roundness",
      "thickness",
      "marginLeft",
      "marginRight",
      "marginTop",
      "marginBottom",
      { swift: "aspectRatio", enum: "PulsingBorderAspectRatios" },
      "softness",
      "intensity",
      "bloom",
      "spots",
      "spotSize",
      "pulse",
      "smoke",
      "smokeSize",
    ],
  },
  {
    key: "color-panels",
    arrayName: "colorPanelsPresets",
    presetType: "ColorPanelsPreset",
    paramsType: "ColorPanelsParams",
    fields: ["colors", "colorBack", "density", "angle1", "angle2", "length", "edges", "blur", "fadeIn", "fadeOut", "gradient"],
  },
  {
    key: "static-mesh-gradient",
    arrayName: "staticMeshGradientPresets",
    presetType: "StaticMeshGradientPreset",
    paramsType: "StaticMeshGradientParams",
    fields: ["colors", "positions", "waveX", "waveXShift", "waveY", "waveYShift", "mixing", "grainMixer", "grainOverlay"],
  },
  {
    key: "static-radial-gradient",
    arrayName: "staticRadialGradientPresets",
    presetType: "StaticRadialGradientPreset",
    paramsType: "StaticRadialGradientParams",
    fields: [
      "colorBack",
      "colors",
      "radius",
      "focalDistance",
      "focalAngle",
      "falloff",
      "mixing",
      "distortion",
      "distortionShift",
      "distortionFreq",
      "grainMixer",
      "grainOverlay",
    ],
  },
  {
    key: "paper-texture",
    arrayName: "paperTexturePresets",
    presetType: "PaperTexturePreset",
    paramsType: "PaperTextureParams",
    fields: [
      "colorFront",
      "colorBack",
      "contrast",
      "roughness",
      "fiber",
      "fiberSize",
      "crumples",
      "foldCount",
      "folds",
      "fade",
      "crumpleSize",
      "drops",
      "seed",
    ],
  },
  {
    key: "fluted-glass",
    arrayName: "flutedGlassPresets",
    presetType: "FlutedGlassPreset",
    paramsType: "FlutedGlassParams",
    fields: [
      "colorBack",
      "colorShadow",
      "colorHighlight",
      "shadows",
      "size",
      "angle",
      "distortion",
      "shift",
      "blur",
      "edges",
      "marginLeft",
      "marginRight",
      "marginTop",
      "marginBottom",
      "stretch",
      { swift: "distortionShape", enum: "GlassDistortionShapes" },
      "highlights",
      { swift: "shape", enum: "GlassGridShapes" },
      "grainMixer",
      "grainOverlay",
    ],
  },
  {
    key: "water",
    arrayName: "waterPresets",
    presetType: "WaterPreset",
    paramsType: "WaterParams",
    fields: ["colorBack", "colorHighlight", "highlights", "layering", "edges", "caustic", "waves", "size"],
  },
  {
    key: "image-dithering",
    arrayName: "imageDitheringPresets",
    presetType: "ImageDitheringPreset",
    paramsType: "ImageDitheringParams",
    fields: [
      "colorFront",
      "colorBack",
      "colorHighlight",
      { swift: "type", enum: "DitheringTypes" },
      "size",
      "colorSteps",
      "originalColors",
      "inverted",
    ],
  },
  {
    key: "heatmap",
    arrayName: "heatmapPresets",
    presetType: "HeatmapPreset",
    paramsType: "HeatmapParams",
    fields: ["colorBack", "colors", "contour", "angle", "noise", "innerGlow", "outerGlow"],
  },
  {
    key: "liquid-metal",
    arrayName: "liquidMetalPresets",
    presetType: "LiquidMetalPreset",
    paramsType: "LiquidMetalParams",
    fields: [
      "colorBack",
      "colorTint",
      "repetition",
      "softness",
      "shiftRed",
      "shiftBlue",
      "distortion",
      "contour",
      "angle",
      { swift: "shape", enum: "LiquidMetalShapes" },
      { swift: "isImage", defaultValue: false },
    ],
  },
  {
    key: "halftone-dots",
    arrayName: "halftoneDotsPresets",
    presetType: "HalftoneDotsPreset",
    paramsType: "HalftoneDotsParams",
    fields: [
      "colorFront",
      "colorBack",
      "size",
      { swift: "grid", enum: "HalftoneDotsGrids" },
      "radius",
      "contrast",
      "originalColors",
      "inverted",
      "grainMixer",
      "grainOverlay",
      "grainSize",
      { swift: "type", enum: "HalftoneDotsTypes" },
    ],
  },
  {
    key: "halftone-cmyk",
    arrayName: "halftoneCmykPresets",
    presetType: "HalftoneCmykPreset",
    paramsType: "HalftoneCmykParams",
    fields: [
      "colorBack",
      "colorC",
      "colorM",
      "colorY",
      "colorK",
      "size",
      "contrast",
      "softness",
      "grainSize",
      "grainMixer",
      "grainOverlay",
      "gridNoise",
      "floodC",
      "floodM",
      "floodY",
      "floodK",
      "gainC",
      "gainM",
      "gainY",
      "gainK",
      { swift: "type", enum: "HalftoneCmykTypes" },
    ],
  },
  {
    key: "gem-smoke",
    arrayName: "gemSmokePresets",
    presetType: "GemSmokePreset",
    paramsType: "GemSmokeParams",
    fields: [
      "colors",
      "colorBack",
      "colorInner",
      "innerDistortion",
      "outerDistortion",
      "outerGlow",
      "innerGlow",
      "offset",
      "angle",
      "size",
      { swift: "shape", enum: "GemSmokeShapes" },
      { swift: "isImage", defaultValue: false },
    ],
  },
];

const typealiases = [
  "MeshGradient",
  "SmokeRing",
  "NeuroNoise",
  "DotOrbit",
  "DotGrid",
  "SimplexNoise",
  "Metaballs",
  "Waves",
  "PerlinNoise",
  "Voronoi",
  "Warp",
  "GodRays",
  "Spiral",
  "Swirl",
  "Dithering",
  "GrainGradient",
  "PulsingBorder",
  "ColorPanels",
  "StaticMeshGradient",
  "StaticRadialGradient",
  "PaperTexture",
  "FlutedGlass",
  "Water",
  "ImageDithering",
  "Heatmap",
  "LiquidMetal",
  "HalftoneDots",
  "HalftoneCmyk",
  "GemSmoke",
];

function arrayFor(spec) {
  const values = snapshot.presets[spec.key];
  if (!values) throw new Error(`Missing preset namespace ${spec.key}`);
  const match = Object.entries(values).find(([name, value]) => name === spec.arrayName && Array.isArray(value));
  if (!match) throw new Error(`Missing preset array ${spec.arrayName}`);
  return match[1];
}

function swiftString(value) {
  return JSON.stringify(value).replace(/\//g, "\\/");
}

function number(value) {
  if (!Number.isFinite(value)) throw new Error(`Invalid number ${value}`);
  return Number.isInteger(value) ? String(value) : String(value);
}

function shaderFit(value) {
  if (!["none", "contain", "cover"].includes(value)) {
    throw new Error(`Unknown fit value ${value}`);
  }
  return `.${value}`;
}

function valueCode(value, field) {
  if (field?.enum) {
    const mapped = enumMaps[field.enum]?.[value];
    if (mapped === undefined) throw new Error(`Unknown ${field.enum} value ${value}`);
    return number(mapped);
  }
  if (typeof value === "string") {
    if (value.startsWith("#") || value.startsWith("rgb") || value.startsWith("hsl")) {
      return `color(${swiftString(value)})`;
    }
    throw new Error(`Unexpected string value for ${field?.swift ?? field}: ${value}`);
  }
  if (typeof value === "number") return number(value);
  if (typeof value === "boolean") return value ? "1" : "0";
  if (Array.isArray(value)) {
    return `[${value.map((item) => valueCode(item, field)).join(", ")}]`;
  }
  throw new Error(`Unsupported value ${JSON.stringify(value)}`);
}

function fieldSpec(field) {
  return typeof field === "string" ? { swift: field, paper: field } : { paper: field.swift, ...field };
}

function paramsCode(spec, params) {
  const args = [];
  for (const rawField of spec.fields) {
    const field = fieldSpec(rawField);
    const paperKey = field.paper ?? field.swift;
    let value = params[paperKey];
    if (value === undefined) {
      if ("defaultValue" in field) {
        value = field.defaultValue;
      } else {
        throw new Error(`${spec.arrayName}.${field.swift} missing source key ${paperKey}`);
      }
    }
    args.push(`${field.swift}: ${valueCode(value, field)}`);
  }

  const lines = [`${spec.paramsType}(`];
  args.forEach((arg, index) => {
    const comma = index === args.length - 1 ? "" : ",";
    lines.push(`      ${arg}${comma}`);
  });
  lines.push("    )");
  return lines.join("\n");
}

function sizingCode(params) {
  const merged = { ...defaultSizing, ...Object.fromEntries(sizingKeys.map((key) => [key, params[key]]).filter(([, value]) => value !== undefined)) };
  return `ShaderSizingParams(\n      fit: ${shaderFit(merged.fit)}, scale: ${number(merged.scale)}, rotation: ${number(merged.rotation)}, originX: ${number(merged.originX)}, originY: ${number(merged.originY)}, offsetX: ${number(merged.offsetX)}, offsetY: ${number(merged.offsetY)},\n      worldWidth: ${number(merged.worldWidth)}, worldHeight: ${number(merged.worldHeight)})`;
}

function motionCode(params) {
  return `ShaderMotionParams(speed: ${number(params.speed ?? 0)}, frame: ${number(params.frame ?? 0)})`;
}

function presetCode(spec, preset) {
  const args = [
    `name: ${swiftString(preset.name)}`,
    `params: ${paramsCode(spec, preset.params)}`,
    `sizing: ${sizingCode(preset.params)}`,
    `motion: ${motionCode(preset.params)}`,
  ];
  if (spec.renderOptions) {
    args.push(`renderOptions: ${spec.renderOptions}`);
  }

  const lines = ["  ShaderPreset("];
  args.forEach((arg, index) => {
    const comma = index === args.length - 1 ? "" : ",";
    const rendered = arg
      .split("\n")
      .map((line, lineIndex) => (lineIndex === 0 ? `    ${line}` : line))
      .join("\n");
    lines.push(`${rendered}${comma}`);
  });
  lines.push("  )");
  return lines.join("\n");
}

function presetArrayCode(spec) {
  const presets = arrayFor(spec);
  return [
    `public let ${spec.arrayName}: [${spec.presetType}] = [`,
    presets.map((preset) => `${presetCode(spec, preset)},`).join("\n"),
    "]",
  ].join("\n");
}

const out = [];
out.push("import Foundation");
out.push("import simd");
out.push("");
out.push("// Generated from Paper Shaders preset metadata with Scripts/extract-paper-presets.mjs.");
out.push("private func color(_ value: String) -> SIMD4<Float> {");
out.push("  (ShaderColor(value) ?? .black).rgba");
out.push("}");
out.push("");

for (const name of typealiases) {
  out.push(`public typealias ${name}Preset = ShaderPreset<${name}Params>`);
}

out.push("");
out.push(specs.map(presetArrayCode).join("\n\n"));
out.push("");

console.log(out.join("\n"));
