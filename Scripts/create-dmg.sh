#!/bin/bash
SCRIPT_DIR="$(pwd)/Scripts"
BUILD_OUTPUT_DIR="$(pwd)/build-output"

mkdir -p $BUILD_OUTPUT_DIR
rm -r $BUILD_OUTPUT_DIR/*

set -e

# Build, Archive, and Export (signed with Developer ID) the app
xcodebuild clean archive \
    -scheme "ovault" \
    -archivePath "$BUILD_OUTPUT_DIR/ovault" \
    -xcconfig "$SCRIPT_DIR/MacBuild.xcconfig"

xcodebuild -exportArchive \
    -archivePath "$BUILD_OUTPUT_DIR/ovault.xcarchive" \
    -exportOptionsPlist $SCRIPT_DIR/exportOptions.plist \
    -exportPath "$BUILD_OUTPUT_DIR"

# Create the dmg file
create-dmg \
    --volname "OVault" \
    --background "$SCRIPT_DIR/installer-background.png" \
    --window-pos 200 120 \
    --window-size 835 600 \
    --icon-size 128 \
    --icon "OVault.app" 230 295 \
    --hide-extension "OVault.app" \
    --app-drop-link 593 295 \
    "$BUILD_OUTPUT_DIR/OVault.dmg" \
    "$BUILD_OUTPUT_DIR/OVault.app"

# Notarize the dmg file
# notarytool requires you to auth to Apple with your Apple ID. 
# You need to create a app-specific password to support this. 
# Store the apple-id and app-specific password in Keychain with the following command:
# `xcrun notarytool store-credentials "notarytool-password" --apple-id "" --team-id "KED4M385SL" --password ""`

xcrun notarytool submit "$BUILD_OUTPUT_DIR/OVault.dmg" --keychain-profile "notarytool-password" --wait

xcrun stapler staple "$BUILD_OUTPUT_DIR/OVault.dmg"

# Fetch the current version to append to the dmg file name
SRCROOT="." # Required by the UpdateVersion script
. "$(pwd)/UpdateVersion.sh"
echo "Version: $VERSION"

mv "$BUILD_OUTPUT_DIR/OVault.dmg" "$BUILD_OUTPUT_DIR/OVault-$VERSION.dmg"

echo "DMG created at $BUILD_OUTPUT_DIR/OVault-$VERSION.dmg, ready to upload to GitHub Releases https://github.com/JustAman62/ovault/releases/latest"
