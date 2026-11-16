<p align="center"><img src="Resources/AppIcon-1024.png" width="128" alt="Keyboard Cleaner"></p>
<h1 align="center">Keyboard Cleaner</h1>
<p align="center">One button locks every key so you can wipe your keyboard without typing a thing.</p>

## Install

Open **Terminal** (⌘ Space, type "Terminal"), paste this, and press Return:

```sh
curl -fsSL https://raw.githubusercontent.com/jeffreylin1216/KeyboardCleaner/main/install.sh | bash
```

The app installs and opens. Allow **Accessibility** when asked. It's how macOS lets an app block keys.

Requires macOS 13+. Works on Apple Silicon and Intel.

## Use

Open the app and it starts cleaning right away: every key is locked. Press **Done** to unlock early. It also unlocks by itself when the timer ends or the app quits. Mouse and trackpad keep working. Change the auto-unlock time (1, 2, 5 or 10 min) between sessions.

## Build

```sh
./release.sh   # builds build/KeyboardCleaner-<version>.dmg
```
