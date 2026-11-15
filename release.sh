#!/bin/bash
# Builds a universal, signed (and, if configured, notarized) KeyboardCleaner.dmg
#
#   SIGN_IDENTITY="Developer ID Application: Your Name (TEAMID)"   # from: security find-identity -v -p codesigning
#   NOTARY_PROFILE="kc-notary"   # from: xcrun notarytool store-credentials kc-notary --apple-id ... --team-id ... --password <app-specific-password>
#
# Without those, the DMG is ad-hoc signed and macOS will show a Gatekeeper warning to downloaders.
set -euo pipefail
cd "$(dirname "$0")"
VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" Resources/Info.plist)
APP=build/KeyboardCleaner.app
DMG="build/KeyboardCleaner-$VERSION.dmg"

swift build -c release --arch arm64 --arch x86_64
BIN=$(swift build -c release --arch arm64 --arch x86_64 --show-bin-path)/KeyboardCleaner

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN" "$APP/Contents/MacOS/"
cp Resources/Info.plist "$APP/Contents/Info.plist"
cp Resources/AppIcon.icns "$APP/Contents/Resources/"

if [[ -n "${SIGN_IDENTITY:-}" ]]; then
  codesign --sign "$SIGN_IDENTITY" --force --options runtime --timestamp "$APP"
else
  echo "⚠️  SIGN_IDENTITY not set: ad-hoc signing (users will see a Gatekeeper warning)"
  codesign --sign - --force "$APP"
fi
codesign --verify --deep --strict "$APP"

# DMG with an Applications shortcut
STAGE=$(mktemp -d); trap 'rm -rf "$STAGE"' EXIT
cp -R "$APP" "$STAGE/"; ln -s /Applications "$STAGE/Applications"
rm -f "$DMG"
hdiutil create -volname "Keyboard Cleaner" -srcfolder "$STAGE" -ov -format UDZO "$DMG" >/dev/null

if [[ -n "${SIGN_IDENTITY:-}" ]]; then
  codesign --sign "$SIGN_IDENTITY" --timestamp "$DMG"
  if [[ -n "${NOTARY_PROFILE:-}" ]]; then
    xcrun notarytool submit "$DMG" --keychain-profile "$NOTARY_PROFILE" --wait
    xcrun stapler staple "$DMG"
    spctl --assess --type open --context context:primary-signature -v "$DMG"
  else
    echo "⚠️  NOTARY_PROFILE not set: signed but not notarized"
  fi
fi
echo "Done: $DMG"
