# Parity harness

Generates the golden images for the visual parity suite
(`Tests/AluminumFoilParityTests`) by rendering the **original** Paper Shaders
WebGL2 implementation headlessly and dumping raw framebuffer pixels.

## How it works

- `generate-goldens.mjs` bundles `harness-entry.jsx` with esbuild, aliasing
  `@paper-design/shaders[-react]` to the paper repo's TypeScript source (no
  paper-repo build needed), and loads it into headless Chromium via Playwright.
- Chromium runs under **SwiftShader** (`--use-angle=swiftshader`), a CPU
  rasterizer, so goldens are reproducible across machines and don't depend on
  the local GPU.
- The harness renders the real React components (`<Swirl {...presetParams}/>`)
  with `speed=0` and an explicit `frame`, disables GL dithering, calls
  `setFrame()` (which renders synchronously), and reads pixels back with
  `gl.readPixels` — no `toDataURL`, no canvas compositing, no color mangling.
  Rows are flipped to match Metal's top-down order.
- PNGs are written untagged (no ICC/sRGB chunk) with `pngjs` so ImageIO and the
  browser decode them to identical bytes.
- The shader × preset × frame matrix comes from `Scripts/preset-specs.mjs`,
  the same table `generate-swift-presets.mjs` uses — both sides always iterate
  the identical matrix. Animated shaders render at frames 0 and 5000 (ms);
  static shaders (no `u_time` uniform) render frame 0 only.
- `manifest.json` records every case (including resolved param values for the
  Swift-side cross-check) plus the generation environment (paper repo commit,
  Chromium version, GL renderer).

## Regenerating goldens

```sh
cd Scripts/parity-harness
npm ci
npx playwright install chromium

node make-fixture.mjs                       # only if the image fixture changed
node generate-goldens.mjs --repo ~/dev/shaders

cd ../..
swift test --filter AluminumFoilParityTests
```

`--repo` defaults to `$PAPER_SHADERS_REPO`. Use `--shader <key>` (repeatable)
to regenerate a subset; the manifest is merged in place.

Regeneration is deterministic to within a handful of pixels: across repeated
runs, ~206 of 208 goldens are byte-identical and the rest differ on <10
isolated pixels by ≤11/255 (SwiftShader threading) — well inside the suite's
tolerances, so a regeneration never flips test results by itself.

Regenerate goldens whenever:
- `Presets.swift` is regenerated (the manifest cross-check will fail loudly if
  the two drift), or
- the paper repo checkout is updated, or
- the canvas size in `Scripts/preset-specs.mjs` changes.

## Files

- `harness-entry.jsx` — browser-side renderer (`window.renderCase`)
- `generate-goldens.mjs` — Node driver, writes goldens + manifest + `_selftest.png`
- `make-fixture.mjs` — deterministic 320×240 fixture image for image-based shaders
