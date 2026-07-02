import fs from "node:fs";
import path from "node:path";
import vm from "node:vm";

const repo = process.argv[2] ?? process.env.PAPER_SHADERS_REPO;
if (!repo) {
  console.error("Usage: node Scripts/extract-paper-presets.mjs <paper-shaders-repo>");
  console.error("       PAPER_SHADERS_REPO=<paper-shaders-repo> node Scripts/extract-paper-presets.mjs");
  process.exit(1);
}

const reactDir = path.join(repo, "packages/shaders-react/src/shaders");
const coreDir = path.join(repo, "packages/shaders/src/shaders");

const defaultObjectSizing = {
  fit: "contain",
  scale: 1,
  rotation: 0,
  offsetX: 0,
  offsetY: 0,
  originX: 0.5,
  originY: 0.5,
  worldWidth: 0,
  worldHeight: 0,
};

const defaultPatternSizing = {
  fit: "none",
  scale: 1,
  rotation: 0,
  offsetX: 0,
  offsetY: 0,
  originX: 0.5,
  originY: 0.5,
  worldWidth: 0,
  worldHeight: 0,
};

const enumConstNames = new Set([
  "DotGridShapes",
  "DitheringShapes",
  "DitheringTypes",
  "WarpPatterns",
  "GrainGradientShapes",
  "PulsingBorderAspectRatios",
  "HalftoneDotsTypes",
  "HalftoneDotsGrids",
  "HalftoneCmykTypes",
  "LiquidMetalShapes",
  "GlassGridShapes",
  "GlassDistortionShapes",
  "GemSmokeShapes",
]);

function expressionEnd(text, start) {
  let quote = null;
  let templateDepth = 0;
  let escaped = false;
  let lineComment = false;
  let blockComment = false;
  let parens = 0;
  let braces = 0;
  let brackets = 0;
  for (let i = start; i < text.length; i++) {
    const c = text[i];
    const next = text[i + 1];
    if (lineComment) {
      if (c === "\n") lineComment = false;
      continue;
    }
    if (blockComment) {
      if (c === "*" && next === "/") {
        blockComment = false;
        i++;
      }
      continue;
    }
    if (quote) {
      if (escaped) {
        escaped = false;
      } else if (c === "\\") {
        escaped = true;
      } else if (quote === "`" && c === "$" && next === "{") {
        templateDepth++;
        braces++;
        i++;
      } else if (c === quote && templateDepth === 0) {
        quote = null;
      } else if (quote === "`" && c === "}" && templateDepth > 0) {
        braces--;
        templateDepth--;
      }
      continue;
    }
    if (c === "/" && next === "/") {
      lineComment = true;
      i++;
      continue;
    }
    if (c === "/" && next === "*") {
      blockComment = true;
      i++;
      continue;
    }
    if (c === "\"" || c === "'" || c === "`") {
      quote = c;
      continue;
    }
    if (c === "(") parens++;
    else if (c === ")") parens--;
    else if (c === "{") braces++;
    else if (c === "}") braces--;
    else if (c === "[") brackets++;
    else if (c === "]") brackets--;
    else if (c === ";" && parens === 0 && braces === 0 && brackets === 0) {
      return i;
    }
  }
  return -1;
}

function exportedConsts(text) {
  const matches = [];
  const re = /(?:export\s+)?const\s+([A-Za-z0-9_]+)(?:\s*:\s*[^=]+)?\s*=\s*/g;
  let m;
  while ((m = re.exec(text))) {
    const start = re.lastIndex;
    const end = expressionEnd(text, start);
    if (end > start) {
      matches.push({ name: m[1], expr: text.slice(start, end).trim() });
      re.lastIndex = end + 1;
    }
  }
  return matches;
}

function evaluate(expr, context) {
  const normalized = expr
    .replace(/\s+as\s+const(?:\s+satisfies\s+[\w.<>,\[\]\s]+)?\s*$/g, "")
    .replace(/\s+satisfies\s+[\w.<>,\[\]\s]+\s*$/g, "");
  return vm.runInNewContext(`(${normalized})`, context, { timeout: 1000 });
}

function readEnums() {
  const context = { defaultObjectSizing, defaultPatternSizing };
  const enums = {};
  for (const file of fs.readdirSync(coreDir).filter((name) => name.endsWith(".ts"))) {
    const text = fs.readFileSync(path.join(coreDir, file), "utf8");
    for (const item of exportedConsts(text)) {
      if (!enumConstNames.has(item.name)) continue;
      const value = evaluate(item.expr, context);
      context[item.name] = value;
      enums[item.name] = value;
    }
  }
  return enums;
}

function readPresets() {
  const all = {};
  for (const file of fs.readdirSync(reactDir).filter((name) => name.endsWith(".tsx")).sort()) {
    const key = file.replace(/\.tsx$/, "");
    const context = {
      defaultObjectSizing,
      defaultPatternSizing,
    };
    const text = fs.readFileSync(path.join(reactDir, file), "utf8");
    const values = {};
    for (const item of exportedConsts(text)) {
      if (
        item.name.endsWith("Preset") ||
        item.name.startsWith("preset") ||
        item.name === "newspaper" ||
        item.name.endsWith("Presets")
      ) {
        const value = evaluate(item.expr, context);
        context[item.name] = value;
        values[item.name] = value;
      }
    }
    all[key] = values;
  }
  return all;
}

console.log(JSON.stringify({ enums: readEnums(), presets: readPresets() }, null, 2));
