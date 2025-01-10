#!/bin/bash
SCRIPT_DIR="$(pwd)/Scripts"
BUILD_OUTPUT_DIR="$(pwd)/build-output"

# Build & Archive the app
xcodebuild archive \
    -project OVault.xcodeproj \
    -scheme ovault \
    -destination "generic/platform=macOS" \
    -archivePath "$BUILD_OUTPUT_DIR/OVault" \
    -configuration Release 

# Export the Archive
xcodebuild -exportArchive \
    -archivePath "$BUILD_OUTPUT_DIR/OVault.xcarchive" \
    -exportPath "$BUILD_OUTPUT_DIR/OVault.app" \
    -exportOptionsPlist "$SCRIPT_DIR/exportOptions.plist"

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




# xcodebuild archive -project OVault.xcodeproj -scheme ovault -destination "generic/platform=macOS" -archivePath "/Users/aman/ovault/build-output/ovault.xcarchive" -configuration Release
