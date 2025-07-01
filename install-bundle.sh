#!/bin/bash

set -e

if [ $# -ne 1 ]; then
    echo "Usage: $0 <bundle.zip>"
    exit 1
fi

BUNDLE_FILE="$1"
TEMP_DIR=$(mktemp -d)
DEVICE_PATH="/data/local/tmp"

cleanup() {
    rm -rf "$TEMP_DIR"
}

trap cleanup EXIT

if [ ! -f "$BUNDLE_FILE" ]; then
    echo "Error: Bundle file '$BUNDLE_FILE' not found"
    exit 1
fi

if ! command -v adb &> /dev/null; then
    echo "Error: ADB not found in PATH"
    exit 1
fi

if ! adb get-state &> /dev/null; then
    echo "Error: No device connected or ADB daemon not running"
    exit 1
fi

echo "Extracting bundle..."
unzip -q "$BUNDLE_FILE" -d "$TEMP_DIR"

APK_FILES=($(find "$TEMP_DIR" -name "*.apk" -type f))

if [ ${#APK_FILES[@]} -eq 0 ]; then
    echo "Error: No APK files found in bundle"
    exit 1
fi

echo "Found ${#APK_FILES[@]} APK file(s)"

TOTAL_SIZE=0
for apk in "${APK_FILES[@]}"; do
    SIZE=$(stat -f%z "$apk" 2>/dev/null || stat -c%s "$apk" 2>/dev/null)
    TOTAL_SIZE=$((TOTAL_SIZE + SIZE))
done

echo "Total size: $TOTAL_SIZE bytes"

echo "Pushing APK files to device..."
for apk in "${APK_FILES[@]}"; do
    FILENAME=$(basename "$apk")
    adb push "$apk" "$DEVICE_PATH/$FILENAME" > /dev/null
done

echo "Creating installation session..."
SESSION_OUTPUT=$(adb shell pm install-create -S $TOTAL_SIZE)
SESSION_ID=$(echo "$SESSION_OUTPUT" | grep -o '[0-9]\+' | head -1)

if [ -z "$SESSION_ID" ]; then
    echo "Error: Failed to create installation session"
    exit 1
fi

echo "Session ID: $SESSION_ID"

echo "Staging APK files..."
INDEX=0
for apk in "${APK_FILES[@]}"; do
    FILENAME=$(basename "$apk")
    SIZE=$(stat -f%z "$apk" 2>/dev/null || stat -c%s "$apk" 2>/dev/null)
    
    adb shell pm install-write -S $SIZE $SESSION_ID $INDEX "$DEVICE_PATH/$FILENAME"
    INDEX=$((INDEX + 1))
done

echo "Committing installation..."
adb shell pm install-commit $SESSION_ID

echo "Cleaning up device files..."
for apk in "${APK_FILES[@]}"; do
    FILENAME=$(basename "$apk")
    adb shell rm "$DEVICE_PATH/$FILENAME" 2>/dev/null || true
done

echo "Installation completed successfully"
