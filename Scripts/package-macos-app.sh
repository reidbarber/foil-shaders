#!/usr/bin/env bash
set -euo pipefail

PRODUCT_NAME="FoilShadersStudio"
APP_NAME="Foil Shader Studio"
BUNDLE_IDENTIFIER="com.reidbarber.FoilShadersStudio"
BUNDLE_VERSION="1"
BUNDLE_SHORT_VERSION="0.1.0"
MINIMUM_SYSTEM_VERSION="13.0"
CONFIGURATION="release"
ARCH_MODE="universal"
CREATE_DMG=0
SIGN_IDENTITY="-"
NOTARIZE_PROFILE=""

usage() {
  cat <<EOF
Usage: Scripts/package-macos-app.sh [options]

Builds dist/${APP_NAME}.app from the SwiftPM ${PRODUCT_NAME} executable.

Options:
  --dmg                         Also create dist/FoilShadersStudio.dmg.
  --configuration <config>      SwiftPM configuration to build. Defaults to release.
  --arch <universal|host>       Build a universal (arm64 + x86_64) or host-only
                                binary. Defaults to universal. Universal builds
                                must run on an Apple Silicon host.
  --sign <identity>             codesign identity, e.g.
                                "Developer ID Application: RB Labs LLC (XXXXXXXXXX)".
                                Enables hardened runtime and a secure timestamp.
                                Defaults to ad-hoc signing ("-").
  --notarize <keychain-profile> Submit the DMG to Apple notarization and staple
                                the ticket. Implies --dmg and requires --sign
                                with a Developer ID identity. Set up the profile
                                once with: xcrun notarytool store-credentials.
  --version <x.y.z>             CFBundleShortVersionString. Defaults to ${BUNDLE_SHORT_VERSION}.
  -h, --help                    Show this help message.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dmg)
      CREATE_DMG=1
      shift
      ;;
    --configuration)
      [[ $# -ge 2 ]] || { echo "error: --configuration requires a value" >&2; exit 1; }
      CONFIGURATION="$2"
      shift 2
      ;;
    --arch)
      [[ $# -ge 2 ]] || { echo "error: --arch requires a value" >&2; exit 1; }
      ARCH_MODE="$2"
      shift 2
      ;;
    --sign)
      [[ $# -ge 2 ]] || { echo "error: --sign requires a value" >&2; exit 1; }
      SIGN_IDENTITY="$2"
      shift 2
      ;;
    --notarize)
      [[ $# -ge 2 ]] || { echo "error: --notarize requires a value" >&2; exit 1; }
      NOTARIZE_PROFILE="$2"
      CREATE_DMG=1
      shift 2
      ;;
    --version)
      [[ $# -ge 2 ]] || { echo "error: --version requires a value" >&2; exit 1; }
      BUNDLE_SHORT_VERSION="$2"
      shift 2
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "error: unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ "$CONFIGURATION" != "release" && "$CONFIGURATION" != "debug" ]]; then
  echo "error: --configuration must be release or debug" >&2
  exit 1
fi

if [[ "$ARCH_MODE" != "universal" && "$ARCH_MODE" != "host" ]]; then
  echo "error: --arch must be universal or host" >&2
  exit 1
fi

HOST_ARCH="$(uname -m)"

if [[ "$ARCH_MODE" == "universal" && "$HOST_ARCH" != "arm64" ]]; then
  echo "error: universal builds require an Apple Silicon (arm64) host." >&2
  echo "Use --arch host on this machine, or build the release on an arm64 Mac." >&2
  exit 1
fi

if [[ -n "$NOTARIZE_PROFILE" && "$SIGN_IDENTITY" == "-" ]]; then
  echo "error: --notarize requires --sign with a Developer ID identity." >&2
  echo "Ad-hoc signed apps cannot be notarized." >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
DIST_DIR="${REPO_ROOT}/dist"
APP_BUNDLE="${DIST_DIR}/${APP_NAME}.app"
CONTENTS_DIR="${APP_BUNDLE}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"
APP_ICONSET="${DIST_DIR}/AppIcon.iconset"
APP_ICON="${RESOURCES_DIR}/AppIcon.icns"
DMG_PATH="${DIST_DIR}/FoilShadersStudio.dmg"
DMG_STAGING_DIR="${DIST_DIR}/dmg-staging"
ICON_SOURCE_DIR="${REPO_ROOT}/Icons/Assets.xcassets/AppIcon.appiconset"
BUILD_ROOT="${REPO_ROOT}/.build"
MODULE_CACHE_DIR="${BUILD_ROOT}/ModuleCache"
SWIFTPM_MODULE_CACHE_DIR="${BUILD_ROOT}/SwiftPMModuleCache"
MODULE_CACHE_ROOT_MARKER="${BUILD_ROOT}/.package-macos-app-module-cache-root"
MODULE_CACHE_ROOT_MARKER_VALUE="v4:${REPO_ROOT}"
HOST_BUILD_DIR="${BUILD_ROOT}/${HOST_ARCH}-apple-macosx/${CONFIGURATION}"
RESOURCE_BUNDLE_NAME="FoilShaders_FoilShaders.bundle"
RESOURCE_BUNDLE_PATH="${HOST_BUILD_DIR}/${RESOURCE_BUNDLE_NAME}"

if [[ ! -d "$ICON_SOURCE_DIR" ]]; then
  echo "error: missing icon source directory: ${ICON_SOURCE_DIR}" >&2
  exit 1
fi

# The .metal shaders ship as raw source and are compiled at runtime, so every
# slice must be built with the default SwiftPM build system (which copies them
# verbatim). A `swift build --arch a --arch b` universal build routes through
# XCBuild, which instead compiles the shaders and drops the source the app
# needs. We therefore build each slice separately and lipo them together.
mkdir -p "$MODULE_CACHE_DIR" "$SWIFTPM_MODULE_CACHE_DIR"
if [[ ! -f "$MODULE_CACHE_ROOT_MARKER" ]] || [[ "$(cat "$MODULE_CACHE_ROOT_MARKER")" != "$MODULE_CACHE_ROOT_MARKER_VALUE" ]]; then
  echo "Refreshing Swift module caches for ${REPO_ROOT}..."
  rm -rf "$MODULE_CACHE_DIR" "$SWIFTPM_MODULE_CACHE_DIR"
  mkdir -p "$MODULE_CACHE_DIR" "$SWIFTPM_MODULE_CACHE_DIR"
fi
printf "%s\n" "$MODULE_CACHE_ROOT_MARKER_VALUE" > "$MODULE_CACHE_ROOT_MARKER"

build_slice() {
  # $1: optional arch wrapper (e.g. "arch -x86_64"); empty for native.
  local wrapper="$1"
  ${wrapper} env \
    CLANG_MODULE_CACHE_PATH="$MODULE_CACHE_DIR" \
    SWIFTPM_MODULECACHE_OVERRIDE="$SWIFTPM_MODULE_CACHE_DIR" \
    swift build -c "$CONFIGURATION" --product "$PRODUCT_NAME"
}

echo "Building ${PRODUCT_NAME} (${CONFIGURATION}, ${ARCH_MODE})..."
echo "  native (${HOST_ARCH}) slice..."
build_slice ""
NATIVE_EXECUTABLE="${HOST_BUILD_DIR}/${PRODUCT_NAME}"
if [[ ! -x "$NATIVE_EXECUTABLE" ]]; then
  echo "error: missing built executable: ${NATIVE_EXECUTABLE}" >&2
  exit 1
fi

LIPO_INPUTS=("$NATIVE_EXECUTABLE")
if [[ "$ARCH_MODE" == "universal" ]]; then
  echo "  x86_64 slice (via Rosetta)..."
  build_slice "arch -x86_64"
  X86_EXECUTABLE="${BUILD_ROOT}/x86_64-apple-macosx/${CONFIGURATION}/${PRODUCT_NAME}"
  if [[ ! -x "$X86_EXECUTABLE" ]]; then
    echo "error: missing built executable: ${X86_EXECUTABLE}" >&2
    exit 1
  fi
  LIPO_INPUTS+=("$X86_EXECUTABLE")
fi

if [[ ! -d "$RESOURCE_BUNDLE_PATH" ]]; then
  echo "error: missing SwiftPM resource bundle: ${RESOURCE_BUNDLE_PATH}" >&2
  exit 1
fi

echo "Creating ${APP_BUNDLE}..."
rm -rf "$APP_BUNDLE" "$APP_ICONSET"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR" "$APP_ICONSET"

lipo -create "${LIPO_INPUTS[@]}" -output "${MACOS_DIR}/${PRODUCT_NAME}"
lipo -info "${MACOS_DIR}/${PRODUCT_NAME}"
cp -R "$RESOURCE_BUNDLE_PATH" "${RESOURCES_DIR}/${RESOURCE_BUNDLE_NAME}"

cp "${ICON_SOURCE_DIR}/16.png" "${APP_ICONSET}/icon_16x16.png"
cp "${ICON_SOURCE_DIR}/32.png" "${APP_ICONSET}/icon_16x16@2x.png"
cp "${ICON_SOURCE_DIR}/32.png" "${APP_ICONSET}/icon_32x32.png"
cp "${ICON_SOURCE_DIR}/64.png" "${APP_ICONSET}/icon_32x32@2x.png"
cp "${ICON_SOURCE_DIR}/128.png" "${APP_ICONSET}/icon_128x128.png"
cp "${ICON_SOURCE_DIR}/256.png" "${APP_ICONSET}/icon_128x128@2x.png"
cp "${ICON_SOURCE_DIR}/256.png" "${APP_ICONSET}/icon_256x256.png"
cp "${ICON_SOURCE_DIR}/512.png" "${APP_ICONSET}/icon_256x256@2x.png"
cp "${ICON_SOURCE_DIR}/512.png" "${APP_ICONSET}/icon_512x512.png"
cp "${ICON_SOURCE_DIR}/1024.png" "${APP_ICONSET}/icon_512x512@2x.png"
iconutil -c icns "$APP_ICONSET" -o "$APP_ICON"
rm -rf "$APP_ICONSET"

cat > "${CONTENTS_DIR}/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleExecutable</key>
  <string>${PRODUCT_NAME}</string>
  <key>CFBundleIconFile</key>
  <string>AppIcon</string>
  <key>CFBundleIdentifier</key>
  <string>${BUNDLE_IDENTIFIER}</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleName</key>
  <string>${APP_NAME}</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>${BUNDLE_SHORT_VERSION}</string>
  <key>CFBundleVersion</key>
  <string>${BUNDLE_VERSION}</string>
  <key>LSMinimumSystemVersion</key>
  <string>${MINIMUM_SYSTEM_VERSION}</string>
  <key>NSHighResolutionCapable</key>
  <true/>
</dict>
</plist>
EOF

plutil -lint "${CONTENTS_DIR}/Info.plist"

if [[ "$SIGN_IDENTITY" == "-" ]]; then
  echo "Ad-hoc signing ${APP_BUNDLE} (not distributable to other Macs)..."
  codesign --force --sign - "$APP_BUNDLE"
else
  echo "Signing ${APP_BUNDLE} with: ${SIGN_IDENTITY}"
  codesign --force --options runtime --timestamp \
    --sign "$SIGN_IDENTITY" "$APP_BUNDLE"
  codesign --verify --strict --verbose=2 "$APP_BUNDLE"
fi

echo "Created ${APP_BUNDLE}"

if [[ "$CREATE_DMG" -eq 1 ]]; then
  echo "Creating ${DMG_PATH}..."
  rm -rf "$DMG_PATH" "$DMG_STAGING_DIR"
  mkdir -p "$DMG_STAGING_DIR"
  cp -R "$APP_BUNDLE" "$DMG_STAGING_DIR/"
  hdiutil create \
    -volname "$APP_NAME" \
    -srcfolder "$DMG_STAGING_DIR" \
    -ov \
    -format UDZO \
    "$DMG_PATH"
  rm -rf "$DMG_STAGING_DIR"
  echo "Created ${DMG_PATH}"

  if [[ -n "$NOTARIZE_PROFILE" ]]; then
    echo "Submitting ${DMG_PATH} for notarization (profile: ${NOTARIZE_PROFILE})..."
    xcrun notarytool submit "$DMG_PATH" \
      --keychain-profile "$NOTARIZE_PROFILE" \
      --wait
    echo "Stapling notarization ticket..."
    xcrun stapler staple "$DMG_PATH"
    xcrun stapler validate "$DMG_PATH"
    spctl --assess --type open --context context:primary-signature -v "$DMG_PATH" || true
  fi

  echo "SHA-256:"
  shasum -a 256 "$DMG_PATH"
fi
