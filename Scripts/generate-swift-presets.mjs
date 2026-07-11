import fs from "node:fs";
import { specs, sizingKeys, defaultSizing } from "./preset-specs.mjs";

const snapshotPath = process.argv[2] ?? "paper-presets.json";
if (!fs.existsSync(snapshotPath)) {
  console.error("Usage: node Scripts/generate-swift-presets.mjs <paper-presets-json>");
  console.error("       Defaults to ./paper-presets.json when no path is provided.");
  process.exit(1);
}
const snapshot = JSON.parse(fs.readFileSync(snapshotPath, "utf8"));

const enumMaps = snapshot.enums;

const typealiases = specs.map((spec) => [spec.presetType, spec.paramsType]);

const swiftEnumCases = {
  DotGridShapes: {
    0: ".circle",
    1: ".diamond",
    2: ".square",
    3: ".triangle",
  },
  DitheringShapes: {
    1: ".simplex",
    2: ".warp",
    3: ".dots",
    4: ".wave",
    5: ".ripple",
    6: ".swirl",
    7: ".sphere",
  },
  DitheringTypes: {
    1: ".random",
    2: ".twoByTwo",
    3: ".fourByFour",
    4: ".eightByEight",
  },
  WarpPatterns: {
    0: ".checks",
    1: ".stripes",
    2: ".edge",
  },
  GrainGradientShapes: {
    1: ".wave",
    2: ".dots",
    3: ".truchet",
    4: ".corners",
    5: ".ripple",
    6: ".blob",
    7: ".sphere",
  },
  PulsingBorderAspectRatios: {
    0: ".auto",
    1: ".square",
  },
  HalftoneDotsTypes: {
    0: ".classic",
    1: ".gooey",
    2: ".holes",
    3: ".soft",
  },
  HalftoneDotsGrids: {
    0: ".square",
    1: ".hex",
  },
  HalftoneCmykTypes: {
    0: ".dots",
    1: ".ink",
    2: ".sharp",
  },
  LiquidMetalShapes: {
    0: ".none",
    1: ".circle",
    2: ".daisy",
    3: ".diamond",
    4: ".metaballs",
  },
  GlassGridShapes: {
    1: ".lines",
    2: ".linesIrregular",
    3: ".wave",
    4: ".zigzag",
    5: ".pattern",
  },
  GlassDistortionShapes: {
    1: ".prism",
    2: ".lens",
    3: ".contour",
    4: ".cascade",
    5: ".flat",
  },
  GemSmokeShapes: {
    0: ".none",
    1: ".circle",
    2: ".daisy",
    3: ".diamond",
    4: ".metaballs",
  },
};

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

function presetIdentifier(name) {
  const words = name.match(/[A-Za-z0-9]+/g) ?? [];
  let identifier = words
    .map((word, index) => {
      const normalized = /^[A-Z0-9]+$/.test(word)
        ? word.toLowerCase()
        : word[0].toLowerCase() + word.slice(1);
      return index === 0 ? normalized : normalized[0].toUpperCase() + normalized.slice(1);
    })
    .join("");
  if (!identifier) identifier = "preset";
  if (/^[0-9]/.test(identifier)) {
    identifier = `preset${identifier[0].toUpperCase()}${identifier.slice(1)}`;
  }
  return identifier;
}

function swiftIdentifier(identifier) {
  return identifier === "default" ? "`default`" : identifier;
}

function memberAccess(identifier) {
  return identifier === "default" ? ".default" : `.${identifier}`;
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
  if (field?.swiftType === "Bool") {
    if (typeof value === "boolean") return value ? "true" : "false";
    if (value === 0 || value === 1) return value === 1 ? "true" : "false";
    throw new Error(`Expected boolean-compatible value for ${field.swift}: ${value}`);
  }
  if (field?.enum) {
    const mapped = enumMaps[field.enum]?.[value];
    if (mapped === undefined) throw new Error(`Unknown ${field.enum} value ${value}`);
    const caseName = swiftEnumCases[field.enum]?.[mapped];
    if (caseName === undefined) throw new Error(`Missing Swift enum case for ${field.enum}.${value} (${mapped})`);
    return caseName;
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

function presetMemberCode(spec, preset) {
  const identifier = presetIdentifier(preset.name);
  return [
    `  static let ${swiftIdentifier(identifier)}: ${spec.presetType} =`,
    presetCode(spec, preset)
      .split("\n")
      .map((line) => `  ${line}`)
      .join("\n"),
  ].join("\n");
}

function presetArrayCode(spec) {
  const presets = arrayFor(spec);
  const swiftArrayName = spec.swiftArrayName ?? spec.arrayName;
  const identifiers = presets.map((preset) => presetIdentifier(preset.name));
  const duplicates = identifiers.filter((identifier, index) => identifiers.indexOf(identifier) !== index);
  if (duplicates.length > 0) {
    throw new Error(`${spec.arrayName} has duplicate preset identifiers: ${duplicates.join(", ")}`);
  }
  return [
    `public extension ${spec.presetType} {`,
    presets.map((preset) => presetMemberCode(spec, preset)).join("\n\n"),
    "}",
    "",
    `let ${swiftArrayName}: [${spec.presetType}] = [`,
    `  ${identifiers.map(memberAccess).join(", ")}`,
    "]",
  ].join("\n");
}

const out = [];
out.push("import Foundation");
out.push("");
out.push("// Generated from Paper Shaders preset metadata with Scripts/extract-paper-presets.mjs.");
out.push("private func color(_ value: String) -> ShaderColor {");
out.push("  ShaderColor(value) ?? .black");
out.push("}");
out.push("");

for (const [presetType, paramsType] of typealiases) {
  out.push(`public typealias ${presetType} = ShaderPreset<${paramsType}>`);
}

out.push("");
out.push(specs.map(presetArrayCode).join("\n\n"));
out.push("");

console.log(out.join("\n"));
