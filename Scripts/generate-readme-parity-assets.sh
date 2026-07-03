#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
OUT_DIR="${REPO_ROOT}/Docs/Media/parity"
README_DIR="${REPO_ROOT}/Docs/Media/readme"
FIXTURE_PATH="${REPO_ROOT}/Docs/Media/parity/wave-image.jpeg"
GOLDENS_DIR="${REPO_ROOT}/Tests/FoilShadersParityTests/Goldens"
BUILD_ROOT="${REPO_ROOT}/.build"
PAPER_REPO="${PAPER_SHADERS_REPO:-${REPO_ROOT}/../shaders}"

mkdir -p "$OUT_DIR" "$README_DIR" "${BUILD_ROOT}/ModuleCache" "${BUILD_ROOT}/SwiftPMModuleCache"

export CLANG_MODULE_CACHE_PATH="${BUILD_ROOT}/ModuleCache"
export SWIFTPM_MODULECACHE_OVERRIDE="${BUILD_ROOT}/SwiftPMModuleCache"

cd "$REPO_ROOT"

CASES=(
  "mesh-gradient|Default|5000|mesh-gradient/Default-f5000.png|mesh-gradient-default"
  "swirl|Candy|5000|swirl/Candy-f5000.png|swirl-candy"
  "dithering|Ripple|5000|dithering/Ripple-f5000.png|dithering-ripple"
  "voronoi|Default|5000|voronoi/Default-f5000.png|voronoi-default"
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

if [[ ! -d "${PAPER_REPO}/packages/shaders/src" ]]; then
  echo "error: Paper Shaders repo not found at ${PAPER_REPO}" >&2
  echo "Set PAPER_SHADERS_REPO to regenerate the Cardboard Paper-side README asset." >&2
  exit 1
fi

PAPER_TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$PAPER_TMP_DIR"' EXIT

node Scripts/parity-harness/generate-goldens.mjs \
  --repo "$PAPER_REPO" \
  --shader paper-texture \
  --fixture "$FIXTURE_PATH" \
  --out "$PAPER_TMP_DIR"

cp "${PAPER_TMP_DIR}/paper-texture/Cardboard-f0.png" "${OUT_DIR}/paper-paper-texture-cardboard.png"

swift run FoilShadersExport \
  --shader paper-texture \
  --preset Cardboard \
  --frame 0 \
  --width 320 \
  --height 240 \
  --image "$FIXTURE_PATH" \
  --output "${OUT_DIR}/foil-paper-texture-cardboard.png"

swift run FoilShadersExport \
  --shader mesh-gradient \
  --preset Default \
  --frame 5000 \
  --width 1660 \
  --height 1140 \
  --output "${README_DIR}/mesh-gradient-hero.png"

echo "Generated README parity assets in ${OUT_DIR}"
echo "Generated README hero image at ${README_DIR}/mesh-gradient-hero.png"
