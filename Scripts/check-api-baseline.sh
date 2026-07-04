#!/usr/bin/env bash
set -euo pipefail

readonly TARGET_NAME="FoilShaders"
readonly DEFAULT_BASELINE_DIR="API"
readonly DEFAULT_CONFIGURATION="release"
readonly DEFAULT_PLATFORMS="macos ios"

usage() {
  cat <<'USAGE'
Usage:
  Scripts/check-api-baseline.sh [--check]
  Scripts/check-api-baseline.sh --update

Checks the FoilShaders public API against the committed swift-api-digester
baseline. Use --update only when an API break is intentional and the baseline
should move with the change.

Environment overrides:
  FOIL_SHADERS_API_BASELINE_DIR   Directory containing baseline JSON files.
  FOIL_SHADERS_API_PLATFORMS      Space-separated platforms: macos ios.
  FOIL_SHADERS_API_MACOS_TARGET   macOS target triple.
  FOIL_SHADERS_API_IOS_TARGET     iOS target triple.
  FOIL_SHADERS_API_CONFIGURATION  SwiftPM configuration.
  FOIL_SHADERS_API_MODULE_CACHE   swift-api-digester module cache path.
USAGE
}

mode="check"
case "${1:---check}" in
  --check | check)
    mode="check"
    ;;
  --update | update | dump)
    mode="update"
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

baseline_dir="${FOIL_SHADERS_API_BASELINE_DIR:-$DEFAULT_BASELINE_DIR}"
platforms="${FOIL_SHADERS_API_PLATFORMS:-$DEFAULT_PLATFORMS}"
configuration="${FOIL_SHADERS_API_CONFIGURATION:-$DEFAULT_CONFIGURATION}"
module_cache_path="${FOIL_SHADERS_API_MODULE_CACHE:-${TMPDIR:-/tmp}/foil-shaders-api-digester-module-cache}"

xcrun --find swift-api-digester >/dev/null
mkdir -p "$baseline_dir" "$module_cache_path"

platform_config() {
  case "$1" in
    macos)
      echo "macosx ${FOIL_SHADERS_API_MACOS_TARGET:-arm64-apple-macosx13.0} $baseline_dir/FoilShaders-macos.json"
      ;;
    ios)
      echo "iphoneos ${FOIL_SHADERS_API_IOS_TARGET:-arm64-apple-ios15.0} $baseline_dir/FoilShaders-ios.json"
      ;;
    *)
      echo "error: unsupported API baseline platform '$1'" >&2
      exit 2
      ;;
  esac
}

module_dir_for_target() {
  local target_triple="$1"
  local build_triple_dir
  build_triple_dir="$(printf '%s' "$target_triple" | sed -E 's/[0-9.]+$//')"
  printf '.build/%s/%s/Modules' "$build_triple_dir" "$configuration"
}

fallback_module_dir() {
  find .build -path "*/$configuration/Modules/$TARGET_NAME.swiftmodule" -print -quit |
    xargs -I {} dirname "{}"
}

check_platform() {
  local platform="$1"
  local sdk_name target_triple baseline_path sdk_path module_dir module_path diagnostics_path

  read -r sdk_name target_triple baseline_path <<<"$(platform_config "$platform")"
  sdk_path="$(xcrun --sdk "$sdk_name" --show-sdk-path)"

  echo "Building $TARGET_NAME for $platform ($target_triple)..."
  swift build -c "$configuration" --target "$TARGET_NAME" --triple "$target_triple" --sdk "$sdk_path"

  module_dir="$(module_dir_for_target "$target_triple")"
  module_path="$module_dir/$TARGET_NAME.swiftmodule"
  if [[ ! -f "$module_path" ]]; then
    module_dir="$(fallback_module_dir)"
    module_path="$module_dir/$TARGET_NAME.swiftmodule"
  fi
  if [[ ! -f "$module_path" ]]; then
    echo "error: expected compiled module at $module_path" >&2
    exit 1
  fi

  local digester_args=(
    swift-api-digester
    -module "$TARGET_NAME"
    -I "$module_dir"
    -sdk "$sdk_path"
    -target "$target_triple"
    -swift-version 6
    -module-cache-path "$module_cache_path"
    -avoid-location
    -avoid-tool-args
    -swift-only
    -enable-remove-deprecated-check
  )

  if [[ "$mode" == "update" ]]; then
    echo "Updating $baseline_path..."
    xcrun "${digester_args[@]}" -dump-sdk -o "$baseline_path"
    echo "Updated public API baseline at $baseline_path."
    return
  fi

  if [[ ! -f "$baseline_path" ]]; then
    echo "error: missing public API baseline at $baseline_path" >&2
    echo "Run Scripts/check-api-baseline.sh --update to create it intentionally." >&2
    exit 1
  fi

  diagnostics_path="$(mktemp "${TMPDIR:-/tmp}/foil-shaders-api-diagnostics.XXXXXX")"

  set +e
  xcrun "${digester_args[@]}" -diagnose-sdk -baseline-path "$baseline_path" >"$diagnostics_path" 2>&1
  digester_status=$?
  set -e

  cat "$diagnostics_path"

  if [[ "$digester_status" -ne 0 ]]; then
    rm -f "$diagnostics_path"
    echo "error: public API baseline check failed for $platform." >&2
    echo "If this API break is intentional, run Scripts/check-api-baseline.sh --update and commit the baseline." >&2
    exit "$digester_status"
  fi

  if awk 'NF && $0 !~ /^\/\*/ { found = 1 } END { exit found ? 0 : 1 }' "$diagnostics_path"; then
    rm -f "$diagnostics_path"
    echo "error: public API differs from the committed $platform baseline." >&2
    echo "If this API break is intentional, run Scripts/check-api-baseline.sh --update and commit the baseline." >&2
    exit 1
  fi

  rm -f "$diagnostics_path"
  echo "Public API matches $baseline_path."
}

for platform in $platforms; do
  check_platform "$platform"
done
