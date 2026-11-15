#!/bin/bash
# Local dev build (ad-hoc signed). For a distributable DMG use ./release.sh
set -euo pipefail
cd "$(dirname "$0")"
swift build -c release
APP=build/KeyboardCleaner.app
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$(swift build -c release --show-bin-path)/KeyboardCleaner" "$APP/Contents/MacOS/"
cp Resources/Info.plist "$APP/Contents/Info.plist"
cp Resources/AppIcon.icns "$APP/Contents/Resources/"
codesign --sign - --force "$APP"
echo "Built $APP"
if [[ "${1:-}" == "--install" ]]; then
  mkdir -p ~/Applications && rm -rf ~/Applications/KeyboardCleaner.app
  cp -R "$APP" ~/Applications/ && echo "Installed to ~/Applications"
fi
