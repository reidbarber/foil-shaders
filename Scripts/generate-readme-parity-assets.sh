#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
OUT_DIR="${REPO_ROOT}/Docs/Media/parity"
FIXTURE_PATH="${REPO_ROOT}/Tests/FoilShadersParityTests/Fixtures/fixture.png"
GOLDENS_DIR="${REPO_ROOT}/Tests/FoilShadersParityTests/Goldens"
BUILD_ROOT="${REPO_ROOT}/.build"

mkdir -p "$OUT_DIR" "${BUILD_ROOT}/ModuleCache" "${BUILD_ROOT}/SwiftPMModuleCache"

export CLANG_MODULE_CACHE_PATH="${BUILD_ROOT}/ModuleCache"
export SWIFTPM_MODULECACHE_OVERRIDE="${BUILD_ROOT}/SwiftPMModuleCache"

cd "$REPO_ROOT"

CASES=(
  "mesh-gradient|Default|5000|mesh-gradient/Default-f5000.png|mesh-gradient-default"
  "swirl|Candy|5000|swirl/Candy-f5000.png|swirl-candy"
  "dithering|Ripple|5000|dithering/Ripple-f5000.png|dithering-ripple"
  "voronoi|Lights|5000|voronoi/Lights-f5000.png|voronoi-lights"
  "paper-texture|Cardboard|0|paper-texture/Cardboard-f0.png|paper-texture-cardboard"
  "liquid-metal|Stripes|5000|liquid-metal/Stripes-f5000.png|liquid-metal-stripes"
)

for entry in "${CASES[@]}"; do
  IFS='|' read -r shader preset frame golden_path slug <<<"$entry"

  cp "${GOLDENS_DIR}/${golden_path}" "${OUT_DIR}/paper-${slug}.png"

  swift run FoilShadersExport \
    --shader "$shader" \
    --preset "$preset" \
    --frame "$frame" \
    --width 320 \
    --height 240 \
    --image "$FIXTURE_PATH" \
    --output "${OUT_DIR}/foil-${slug}.png"
done

echo "Generated README parity assets in ${OUT_DIR}"
