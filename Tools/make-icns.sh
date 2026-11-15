#!/bin/bash
# Regenerates Resources/AppIcon.icns from Tools/make-icon.swift
set -euo pipefail
cd "$(dirname "$0")/.."
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
swift Tools/make-icon.swift "$T/1024.png"
I="$T/AppIcon.iconset"; mkdir "$I"
for s in 16 32 128 256 512; do
  sips -z $s $s "$T/1024.png" --out "$I/icon_${s}x${s}.png" >/dev/null
  sips -z $((s*2)) $((s*2)) "$T/1024.png" --out "$I/icon_${s}x${s}@2x.png" >/dev/null
done
iconutil -c icns "$I" -o Resources/AppIcon.icns
cp "$T/1024.png" Resources/AppIcon-1024.png
echo "Wrote Resources/AppIcon.icns"
