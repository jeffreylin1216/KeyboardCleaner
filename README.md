<p align="center"><img src="Resources/AppIcon-1024.png" width="128" alt="Keyboard Cleaner"></p>
<h1 align="center">Keyboard Cleaner</h1>
<p align="center">One button locks every key so you can wipe your keyboard without typing a thing.</p>

<p align="center">
  <a href="https://github.com/jeffreylin1216/KeyboardCleaner/releases/latest/download/KeyboardCleaner.dmg"><img src="https://img.shields.io/badge/%E2%AC%87%20Download%20for%20Mac-6A5CF2?style=for-the-badge" alt="Download for Mac"></a>
</p>

## Install

1. Click **Download for Mac** above.
2. Open the file and drag the app to Applications.
3. macOS will say it "could not verify" the app. That's expected, since the app isn't notarized. Click **Done**, then open **System Settings → Privacy & Security**, scroll down and click **Open Anyway**. You only do this once.
4. Allow **Accessibility** when asked. It's how macOS lets an app block keys.

Requires macOS 13+. Works on Apple Silicon and Intel.

## Use

Pick an auto-unlock time, press **Start**, clean, then press **Done**. The keyboard also unlocks by itself when the timer ends or the app quits. Mouse and trackpad keep working.

## Build

```sh
./release.sh   # builds build/KeyboardCleaner-<version>.dmg
```
