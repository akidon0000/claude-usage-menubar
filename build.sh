#!/bin/bash
set -euo pipefail

APP_NAME="Claude Usage"
BUNDLE_NAME="ClaudeUsageMenubar"
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$PROJECT_DIR/.build/release"
APP_DIR="/Applications/${APP_NAME}.app"

echo "Building $APP_NAME..."
cd "$PROJECT_DIR"
swift build -c release 2>&1

echo "Packaging .app bundle..."
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS"

cp "$BUILD_DIR/$BUNDLE_NAME" "$APP_DIR/Contents/MacOS/$BUNDLE_NAME"
cp "$PROJECT_DIR/Info.plist" "$APP_DIR/Contents/Info.plist"

codesign --force --sign - "$APP_DIR" 2>/dev/null || true

echo "Installed to $APP_DIR"
echo ""

if pgrep -f "$BUNDLE_NAME" > /dev/null 2>&1; then
  echo "Restarting..."
  pkill -f "$BUNDLE_NAME" 2>/dev/null || true
  sleep 1
fi

echo "Launching..."
open "$APP_DIR"
echo "Done."
