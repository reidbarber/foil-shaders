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

const typealiases = specs.map((spec) => spec.componentName);

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
