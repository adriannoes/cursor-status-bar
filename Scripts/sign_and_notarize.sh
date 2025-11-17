#!/bin/bash
set -e

# Sign and notarize script for Cursor Menu Bar Stats
# Requires: APP_STORE_CONNECT_API_KEY_P8, APP_STORE_CONNECT_KEY_ID, APP_STORE_CONNECT_ISSUER_ID
# Run from repository root

VERSION="${1:-0.1.0}"
APP_NAME="CursorMenuBarApp"
PACKAGE_DIR="CursorMenuBarApp"
APP_DIR="${PACKAGE_DIR}/${APP_NAME}.app"
ZIP_NAME="${APP_NAME}-${VERSION}.zip"

# Identity for signing (adjust if needed)
APP_IDENTITY="${APP_IDENTITY:-Developer ID Application: Adrianno Esnarriaga}"

echo "🔐 Signing and notarizing ${APP_NAME} v${VERSION}..."

# Ensure we're in the repository root
if [ ! -d "${PACKAGE_DIR}" ] || [ ! -f "${PACKAGE_DIR}/Package.swift" ]; then
    echo "❌ Error: ${PACKAGE_DIR}/Package.swift not found. Run this script from repository root."
    exit 1
fi

if [ ! -d "${APP_DIR}" ]; then
    echo "❌ Error: ${APP_DIR} not found. Run Scripts/package_app.sh first."
    exit 1
fi

# Sign the app
echo "✍️  Signing app..."
codesign --force --deep --sign "${APP_IDENTITY}" \
    --options runtime \
    --timestamp \
    "${APP_DIR}"

# Verify signature
echo "🔍 Verifying signature..."
codesign --verify --verbose "${APP_DIR}"
spctl -a -t exec -vv "${APP_DIR}"

# Create zip for notarization
echo "📦 Creating zip for notarization..."
rm -f "${ZIP_NAME}"
ditto -c -k --keepParent "${APP_DIR}" "${ZIP_NAME}"

# Notarize (if credentials are provided)
if [ -n "${APP_STORE_CONNECT_API_KEY_P8}" ] && [ -n "${APP_STORE_CONNECT_KEY_ID}" ] && [ -n "${APP_STORE_CONNECT_ISSUER_ID}" ]; then
    echo "📤 Submitting for notarization..."
    
    # Create keychain item
    xcrun notarytool store-credentials \
        --apple-id "${APP_STORE_CONNECT_ISSUER_ID}" \
        --team-id "${APP_STORE_CONNECT_KEY_ID}" \
        --password "${APP_STORE_CONNECT_API_KEY_P8}" \
        "notarytool-profile" || true
    
    # Submit
    xcrun notarytool submit "${ZIP_NAME}" \
        --keychain-profile "notarytool-profile" \
        --wait
    
    # Staple
    echo "📎 Stapling notarization ticket..."
    xcrun stapler staple "${APP_DIR}"
    xcrun stapler validate "${APP_DIR}"
    
    # Recreate zip with stapled app
    rm -f "${ZIP_NAME}"
    ditto -c -k --keepParent "${APP_DIR}" "${ZIP_NAME}"
else
    echo "⚠️  Skipping notarization (credentials not provided)"
    echo "   Set APP_STORE_CONNECT_API_KEY_P8, APP_STORE_CONNECT_KEY_ID, and APP_STORE_CONNECT_ISSUER_ID to enable"
fi

echo "✅ Signed and notarized: ${ZIP_NAME}"
echo "📦 Ready for distribution!"
echo "📤 Upload ${ZIP_NAME} to GitHub Releases"
