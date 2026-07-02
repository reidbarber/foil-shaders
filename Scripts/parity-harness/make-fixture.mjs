// Deterministically generates the shared image fixture used by image-based
// shader parity cases (Tests/AluminumFoilParityTests/Fixtures/fixture.png).
// Untagged PNG (no ICC/sRGB chunk) so the browser and ImageIO decode it to
// identical bytes. Synthetic but photo-like: smooth multi-hue gradients,
// circles, and a luminance ramp so dithering/halftone/heatmap shaders have
// meaningful structure to work with.
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { PNG } from "pngjs";
import { goldenCanvas } from "../preset-specs.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));
const outPath = path.resolve(
  here,
  "../../Tests/AluminumFoilParityTests/Fixtures/fixture.png"
);

const { width, height } = goldenCanvas;
const png = new PNG({ width, height });

const clamp = (v) => Math.max(0, Math.min(255, Math.round(v)));

for (let y = 0; y < height; y++) {
  for (let x = 0; x < width; x++) {
    const nx = x / (width - 1);
    const ny = y / (height - 1);

    // Base: smooth two-axis hue gradient.
    let r = 210 * nx + 30;
    let g = 190 * ny + 25;
    let b = 200 * (1 - nx) * (1 - ny) + 20;

    // Circles of varying brightness for edges and curvature.
    const circles = [
      { cx: 0.3, cy: 0.35, radius: 0.18, boost: 90 },
      { cx: 0.72, cy: 0.62, radius: 0.22, boost: -70 },
      { cx: 0.62, cy: 0.22, radius: 0.1, boost: 120 },
    ];
    for (const { cx, cy, radius, boost } of circles) {
      const dx = nx - cx;
      const dy = (ny - cy) * (height / width);
      const distance = Math.sqrt(dx * dx + dy * dy);
      if (distance < radius) {
        const falloff = 1 - distance / radius;
        r += boost * falloff;
        g += boost * falloff;
        b += boost * falloff;
      }
    }

    // Bottom strip: pure luminance ramp for dither/halftone response.
    if (ny > 0.85) {
      const ramp = 255 * nx;
      r = ramp;
      g = ramp;
      b = ramp;
    }

    const i = (y * width + x) * 4;
    png.data[i + 0] = clamp(r);
    png.data[i + 1] = clamp(g);
    png.data[i + 2] = clamp(b);
    png.data[i + 3] = 255;
  }
}

fs.mkdirSync(path.dirname(outPath), { recursive: true });
fs.writeFileSync(outPath, PNG.sync.write(png));
console.log(`Wrote ${width}x${height} fixture to ${outPath}`);
