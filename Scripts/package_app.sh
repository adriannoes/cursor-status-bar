#!/bin/bash
set -e

# Package script for Cursor Menu Bar Stats
# Creates a .app bundle ready for distribution
# Run from repository root

VERSION="${1:-0.1.0}"
BUILD_TYPE="${2:-debug}"

APP_NAME="CursorMenuBarApp"
PACKAGE_DIR="CursorMenuBarApp"
APP_DIR="${PACKAGE_DIR}/${APP_NAME}.app"
CONTENTS_DIR="${APP_DIR}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"

echo "📦 Packaging ${APP_NAME} v${VERSION} (${BUILD_TYPE})..."

# Ensure we're in the repository root
if [ ! -d "${PACKAGE_DIR}" ] || [ ! -f "${PACKAGE_DIR}/Package.swift" ]; then
    echo "❌ Error: ${PACKAGE_DIR}/Package.swift not found. Run this script from repository root."
    exit 1
fi

cd "${PACKAGE_DIR}"

# Clean previous builds
rm -rf "${APP_NAME}.app"
rm -rf .build

# Build the app
echo "🔨 Building..."
swift build -c "${BUILD_TYPE}"

# Create app bundle structure
echo "📁 Creating app bundle..."
mkdir -p "${APP_NAME}.app/Contents/MacOS"
mkdir -p "${APP_NAME}.app/Contents/Resources"

# Copy executable
cp ".build/${BUILD_TYPE}/${APP_NAME}" "${APP_NAME}.app/Contents/MacOS/${APP_NAME}"
chmod +x "${APP_NAME}.app/Contents/MacOS/${APP_NAME}"

# Create Info.plist
cat > "${APP_NAME}.app/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>com.adriannoes.cursormenubar</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>Cursor Menu Bar Stats</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>${VERSION}</string>
    <key>CFBundleVersion</key>
    <string>${VERSION}</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>LSUIElement</key>
    <true/>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2024 Adrianno Esnarriaga. All rights reserved.</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
</dict>
</plist>
EOF

# Create PkgInfo
echo "APPL????" > "${APP_NAME}.app/Contents/PkgInfo"

cd ..

echo "✅ App bundle created: ${APP_DIR}"
echo "📦 To create a distributable zip:"
echo "   zip -r ${APP_NAME}-${VERSION}.zip ${APP_DIR}"
