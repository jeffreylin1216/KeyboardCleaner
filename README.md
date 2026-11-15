<p align="center"><img src="Resources/AppIcon-1024.png" width="128" alt="Keyboard Cleaner"></p>
<h1 align="center">Keyboard Cleaner</h1>
<p align="center">One button locks every key so you can wipe your keyboard without typing a thing.</p>

## Install

1. Download the latest **KeyboardCleaner.dmg** from [Releases](../../releases/latest).
2. Open it and drag the app to Applications.
3. First launch: **right-click the app → Open → Open**. (macOS shows a warning because the app isn't notarized.)
4. Allow **Accessibility** when asked. It's how macOS lets an app block keys.

Requires macOS 13+. Works on Apple Silicon and Intel.

## Use

Pick an auto-unlock time, press **Start**, clean, then press **Done**. The keyboard also unlocks by itself when the timer ends or the app quits. Mouse and trackpad keep working.

## Build

```sh
./release.sh   # builds build/KeyboardCleaner-<version>.dmg
```
