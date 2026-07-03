#!/usr/bin/env bash
set -euo pipefail

PRODUCT_NAME="AluminumFoilStudio"
APP_NAME="Aluminum Foil Studio"
BUNDLE_IDENTIFIER="com.reidbarber.AluminumFoilStudio"
BUNDLE_VERSION="1"
BUNDLE_SHORT_VERSION="0.1.0"
MINIMUM_SYSTEM_VERSION="13.0"
CONFIGURATION="release"
CREATE_DMG=0

usage() {
  cat <<EOF
Usage: Scripts/package-macos-app.sh [--dmg] [--configuration release|debug]

Builds dist/${APP_NAME}.app from the SwiftPM ${PRODUCT_NAME} executable.

Options:
  --dmg                         Also create dist/AluminumFoilStudio.dmg.
  --configuration <config>      SwiftPM configuration to build. Defaults to release.
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
      if [[ $# -lt 2 ]]; then
        echo "error: --configuration requires a value" >&2
        exit 1
      fi
      CONFIGURATION="$2"
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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
DIST_DIR="${REPO_ROOT}/dist"
APP_BUNDLE="${DIST_DIR}/${APP_NAME}.app"
CONTENTS_DIR="${APP_BUNDLE}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"
APP_ICONSET="${DIST_DIR}/AppIcon.iconset"
APP_ICON="${RESOURCES_DIR}/AppIcon.icns"
DMG_PATH="${DIST_DIR}/AluminumFoilStudio.dmg"
DMG_STAGING_DIR="${DIST_DIR}/dmg-staging"
ICON_SOURCE_DIR="${REPO_ROOT}/Icons/Assets.xcassets/AppIcon.appiconset"
BUILD_ROOT="${REPO_ROOT}/.build"
PLATFORM_DIR="$(uname -m)-apple-macosx"
BUILD_DIR="${BUILD_ROOT}/${PLATFORM_DIR}/${CONFIGURATION}"
EXECUTABLE_PATH="${BUILD_DIR}/${PRODUCT_NAME}"
RESOURCE_BUNDLE_NAME="AluminumFoil_AluminumFoil.bundle"
RESOURCE_BUNDLE_PATH="${BUILD_DIR}/${RESOURCE_BUNDLE_NAME}"

if [[ ! -d "$ICON_SOURCE_DIR" ]]; then
  echo "error: missing icon source directory: ${ICON_SOURCE_DIR}" >&2
  exit 1
fi

echo "Building ${PRODUCT_NAME} (${CONFIGURATION})..."
mkdir -p "${BUILD_ROOT}/ModuleCache" "${BUILD_ROOT}/SwiftPMModuleCache"
env \
  CLANG_MODULE_CACHE_PATH="${BUILD_ROOT}/ModuleCache" \
  SWIFTPM_MODULECACHE_OVERRIDE="${BUILD_ROOT}/SwiftPMModuleCache" \
  swift build -c "$CONFIGURATION" --product "$PRODUCT_NAME"

if [[ ! -x "$EXECUTABLE_PATH" ]]; then
  echo "error: missing built executable: ${EXECUTABLE_PATH}" >&2
  exit 1
fi

if [[ ! -d "$RESOURCE_BUNDLE_PATH" ]]; then
  echo "error: missing SwiftPM resource bundle: ${RESOURCE_BUNDLE_PATH}" >&2
  exit 1
fi

echo "Creating ${APP_BUNDLE}..."
rm -rf "$APP_BUNDLE" "$APP_ICONSET"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR" "$APP_ICONSET"

cp "$EXECUTABLE_PATH" "${MACOS_DIR}/${PRODUCT_NAME}"
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
codesign --force --deep --sign - "$APP_BUNDLE"

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
fi
