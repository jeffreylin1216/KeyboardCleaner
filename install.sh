#!/bin/bash
# Installs Keyboard Cleaner. Downloading with curl means macOS shows no "unverified app" warning.
set -euo pipefail
URL="https://github.com/jeffreylin1216/KeyboardCleaner/releases/latest/download/KeyboardCleaner.dmg"
DEST="${INSTALL_DIR:-/Applications}"
TMP=$(mktemp -d); MNT="$TMP/mnt"
trap 'hdiutil detach "$MNT" -quiet 2>/dev/null || true; rm -rf "$TMP"' EXIT

echo "Downloading Keyboard Cleaner..."
curl -fsSL "$URL" -o "$TMP/kc.dmg"
mkdir "$MNT"
hdiutil attach "$TMP/kc.dmg" -mountpoint "$MNT" -nobrowse -quiet
rm -rf "$DEST/KeyboardCleaner.app"
cp -R "$MNT/KeyboardCleaner.app" "$DEST/"
xattr -dr com.apple.quarantine "$DEST/KeyboardCleaner.app" 2>/dev/null || true
echo "Installed to $DEST"
if [[ -z "${INSTALL_DIR:-}" ]]; then open "$DEST/KeyboardCleaner.app"; fi
