// Generates golden PNGs + manifest.json for the visual parity suite by
// rendering the original Paper Shaders (WebGL2) in headless Chromium under
// SwiftShader (CPU rasterizer, reproducible across machines).
//
// Usage:
//   node generate-goldens.mjs --repo ~/dev/shaders [--shader swirl]... [--out <dir>]
//   PAPER_SHADERS_REPO=~/dev/shaders node generate-goldens.mjs
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { execFileSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import esbuild from "esbuild";
import { chromium } from "playwright";
import { PNG } from "pngjs";
import {
  specs,
  sizingKeys,
  defaultSizing,
  goldenCanvas,
  framesFor,
} from "../preset-specs.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(here, "../..");

const args = process.argv.slice(2);
function argValue(flag) {
  const index = args.indexOf(flag);
  return index >= 0 ? args[index + 1] : undefined;
}
function argValues(flag) {
  const values = [];
  args.forEach((arg, index) => {
    if (arg === flag) values.push(args[index + 1]);
  });
  return values;
}

const paperRepo = argValue("--repo") ?? process.env.PAPER_SHADERS_REPO;
if (!paperRepo || !fs.existsSync(path.join(paperRepo, "packages/shaders/src"))) {
  console.error("Pass the Paper Shaders repo with --repo <path> or PAPER_SHADERS_REPO=<path>.");
  process.exit(1);
}
const outDir = path.resolve(argValue("--out") ?? path.join(repoRoot, "Tests/AluminumFoilParityTests/Goldens"));
const shaderFilter = argValues("--shader");
const fixturePath = argValue("--fixture") ?? path.join(repoRoot, "Tests/AluminumFoilParityTests/Fixtures/fixture.png");

// 1. Preset snapshot straight from the paper repo (single source of truth).
const snapshot = JSON.parse(
  execFileSync("node", [path.join(repoRoot, "Scripts/extract-paper-presets.mjs"), paperRepo], {
    encoding: "utf8",
    maxBuffer: 64 * 1024 * 1024,
  })
);

// 2. Bundle the browser harness against the paper repo's TypeScript source.
const buildDir = path.join(here, ".build");
fs.mkdirSync(buildDir, { recursive: true });
const bundlePath = path.join(buildDir, "harness.js");
await esbuild.build({
  entryPoints: [path.join(here, "harness-entry.jsx")],
  bundle: true,
  outfile: bundlePath,
  format: "iife",
  platform: "browser",
  target: "es2022",
  jsx: "automatic",
  define: { "process.env.NODE_ENV": '"production"' },
  alias: {
    "@paper-design/shaders-react": path.join(paperRepo, "packages/shaders-react/src/index.ts"),
    "@paper-design/shaders": path.join(paperRepo, "packages/shaders/src/index.ts"),
  },
  // Resolve react/react-dom from the harness for files inside the paper repo.
  nodePaths: [path.join(here, "node_modules")],
  logLevel: "warning",
});

// 3. Build the case list (identical matrix to the Swift side).
const activeSpecs = specs.filter((spec) => shaderFilter.length === 0 || shaderFilter.includes(spec.key));
if (activeSpecs.length === 0) {
  console.error(`No shaders match filter: ${shaderFilter.join(", ")}`);
  process.exit(1);
}
function presetArray(spec) {
  const namespace = snapshot.presets[spec.key];
  if (!namespace) throw new Error(`Missing preset namespace ${spec.key}`);
  const presets = namespace[spec.arrayName];
  if (!Array.isArray(presets)) throw new Error(`Missing preset array ${spec.arrayName}`);
  return presets;
}

let fixtureDataUrl;
const needsFixture = activeSpecs.some((spec) => spec.usesImage);
if (needsFixture) {
  if (!fs.existsSync(fixturePath)) {
    console.error(`Image shaders requested but fixture is missing: ${fixturePath}`);
    console.error("Generate it first with: node make-fixture.mjs");
    process.exit(1);
  }
  fixtureDataUrl = `data:image/png;base64,${fs.readFileSync(fixturePath).toString("base64")}`;
}

// 4. Launch headless Chromium under SwiftShader.
const browser = await chromium.launch({
  args: ["--use-angle=swiftshader", "--force-color-profile=srgb"],
});
const bundleSource = fs.readFileSync(bundlePath, "utf8");
const context = await browser.newContext({
  viewport: { width: goldenCanvas.width + 160, height: goldenCanvas.height + 120 },
  deviceScaleFactor: 1,
});

async function newHarnessPage() {
  const page = await context.newPage();
  page.on("console", (message) => {
    if (message.type() === "error" || message.type() === "warning") {
      console.error(`  [browser ${message.type()}] ${message.text()}`);
    }
  });
  await page.setContent("<!DOCTYPE html><html><body></body></html>");
  await page.addScriptTag({ content: bundleSource });
  await page.waitForFunction("window.__harnessReady === true");
  return page;
}

let page = await newHarnessPage();
const glRenderer = await page.evaluate("window.glInfo()");
console.log(`GL renderer: ${glRenderer}`);
if (!/swiftshader/i.test(glRenderer)) {
  console.warn("WARNING: not running under SwiftShader; goldens may not be reproducible across machines.");
}

// Color/enum resolution uses the actual library implementations via the page.
const colorCache = new Map();
async function resolveColor(value) {
  if (!colorCache.has(value)) {
    colorCache.set(value, await page.evaluate((v) => window.resolveColor(v), value));
  }
  return colorCache.get(value);
}

const enumMaps = snapshot.enums;
function fieldSpec(field) {
  return typeof field === "string" ? { swift: field, paper: field } : { paper: field.swift, ...field };
}

async function swiftParamsFor(spec, params) {
  const out = {};
  for (const rawField of spec.fields) {
    const field = fieldSpec(rawField);
    const paperKey = field.paper ?? field.swift;
    let value = params[paperKey];
    if (value === undefined) {
      if ("defaultValue" in field) {
        value = field.defaultValue;
      } else {
        throw new Error(`${spec.key}: preset missing param ${paperKey}`);
      }
    }
    if (field.enum) {
      const mapped = enumMaps[field.enum]?.[value];
      if (mapped === undefined) throw new Error(`Unknown ${field.enum} value ${value}`);
      out[field.swift] = mapped;
    } else if (typeof value === "string") {
      out[field.swift] = await resolveColor(value);
    } else if (typeof value === "boolean") {
      out[field.swift] = value ? 1 : 0;
    } else if (Array.isArray(value)) {
      out[field.swift] = await Promise.all(
        value.map((item) => (typeof item === "string" ? resolveColor(item) : Promise.resolve(item)))
      );
    } else {
      out[field.swift] = value;
    }
  }
  return out;
}

async function sizingFor(params) {
  const merged = { ...defaultSizing };
  for (const key of sizingKeys) {
    if (params[key] !== undefined) merged[key] = params[key];
  }
  return { ...merged, fit: await page.evaluate((f) => window.shaderFitValue(f), merged.fit) };
}

function sanitizeName(name) {
  return name.replace(/[^A-Za-z0-9]+/g, "-").replace(/^-+|-+$/g, "");
}

// 5. Render all cases.
const cases = [];
let rendered = 0;
const casesPerPage = 24; // WebGL context churn: recycle the page periodically.

for (const spec of activeSpecs) {
  const presets = presetArray(spec);
  const shaderDir = path.join(outDir, spec.key);
  fs.mkdirSync(shaderDir, { recursive: true });
  for (const [presetIndex, preset] of presets.entries()) {
    for (const frame of framesFor(spec)) {
      if (rendered > 0 && rendered % casesPerPage === 0) {
        await page.close();
        page = await newHarnessPage();
      }
      const id = `${spec.key}/${preset.name}@${frame}`;
      const result = await page.evaluate((c) => window.renderCase(c), {
        component: spec.componentName,
        params: preset.params,
        frame,
        width: goldenCanvas.width,
        height: goldenCanvas.height,
        imageDataUrl: spec.usesImage ? fixtureDataUrl : undefined,
      });

      const png = new PNG({ width: result.width, height: result.height });
      png.data = Buffer.from(result.base64, "base64");
      const goldenPath = `${spec.key}/${sanitizeName(preset.name)}-f${frame}.png`;
      fs.writeFileSync(path.join(outDir, goldenPath), PNG.sync.write(png));

      cases.push({
        id,
        shader: spec.key,
        component: spec.componentName,
        presetName: preset.name,
        presetIndex,
        frame,
        usesImage: Boolean(spec.usesImage),
        goldenPath,
        swiftParams: await swiftParamsFor(spec, preset.params),
        sizing: await sizingFor(preset.params),
      });
      rendered += 1;
      console.log(`  ${id} -> ${goldenPath}`);
    }
  }
}

// 6. Self-test image proving the Swift PNG decode path is byte-exact
// (non-premultiplied RGBA with partial alpha; formula mirrored in the Swift test).
{
  const png = new PNG({ width: goldenCanvas.width, height: goldenCanvas.height });
  for (let y = 0; y < png.height; y++) {
    for (let x = 0; x < png.width; x++) {
      const i = (y * png.width + x) * 4;
      png.data[i + 0] = x % 256;
      png.data[i + 1] = y % 256;
      png.data[i + 2] = (x * 3 + y * 7) % 256;
      png.data[i + 3] = (x + y) % 256;
    }
  }
  fs.writeFileSync(path.join(outDir, "_selftest.png"), PNG.sync.write(png));
}

// 7. Manifest.
const environment = {
  paperShadersCommit: execFileSync("git", ["-C", paperRepo, "rev-parse", "HEAD"], { encoding: "utf8" }).trim(),
  playwrightVersion: JSON.parse(fs.readFileSync(path.join(here, "node_modules/playwright/package.json"), "utf8")).version,
  chromiumVersion: browser.version(),
  glRenderer,
  platform: `${os.platform()} ${os.release()}`,
  generatedAt: new Date().toISOString(),
};

const manifestPath = path.join(outDir, "manifest.json");
let manifest = { version: 1, canvas: goldenCanvas, environment, cases };
if (shaderFilter.length > 0 && fs.existsSync(manifestPath)) {
  // Partial regeneration: merge into the existing manifest.
  const existing = JSON.parse(fs.readFileSync(manifestPath, "utf8"));
  const kept = existing.cases.filter((c) => !shaderFilter.includes(c.shader));
  const byKey = new Map(specs.map((spec, index) => [spec.key, index]));
  manifest.cases = [...kept, ...cases].sort(
    (a, b) => byKey.get(a.shader) - byKey.get(b.shader) || a.presetIndex - b.presetIndex || a.frame - b.frame
  );
}
fs.writeFileSync(manifestPath, `${JSON.stringify(manifest, null, 2)}\n`);

await page.close();
await context.close();
await browser.close();
console.log(`\nWrote ${rendered} goldens and manifest with ${manifest.cases.length} cases to ${outDir}`);
