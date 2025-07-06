#!/bin/bash
set -eu 

# Set the project name
PROJECT_NAME="MouseDebouncer"

# Set the source and build directories
SOURCE_DIR="MacOS-mouse-debouncer"
BUILD_DIR="build"
APP_BUNDLE_PATH="$BUILD_DIR/$PROJECT_NAME.app"

# Create the build directory if it doesn't exist
mkdir -p "$BUILD_DIR"

# Compile the Swift files
swiftc -o "$BUILD_DIR/$PROJECT_NAME" "$SOURCE_DIR/main.swift" "$SOURCE_DIR/AppDelegate.swift" "$SOURCE_DIR/MouseDebouncer.swift"

# Create the .app bundle structure
mkdir -p "$APP_BUNDLE_PATH/Contents/MacOS"
mkdir -p "$APP_BUNDLE_PATH/Contents/Resources"

# Move the compiled binary to the .app bundle
mv "$BUILD_DIR/$PROJECT_NAME" "$APP_BUNDLE_PATH/Contents/MacOS/"

# Copy the Info.plist file to the .app bundle
cp "$SOURCE_DIR/Info.plist" "$APP_BUNDLE_PATH/Contents/"

echo "Build successful. The application bundle is at $APP_BUNDLE_PATH"
