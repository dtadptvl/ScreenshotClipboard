# ScreenshotClipboard

Experimental iOS 27 app for the target workflow:

**one gesture → full-screen frame → clipboard → no Photos**

The app deliberately avoids the Shortcuts `Take Screenshot` action. It uses ScreenCaptureKit for full-display capture and keeps the capture session active using the iOS `screen-capture` background mode.

## Current prototype status

- Full-display `SCStream` capture implementation.
- Latest frame can be copied to `UIPasteboard` from the app.
- No Photo Library writes.
- Control Widget target intended for Action Button / Control Center latency testing.
- GitHub Actions builds an unsigned IPA on macOS/Xcode.

### Important limitation in v0.1

The Control Widget extension runs out-of-process and cannot directly access the app process's in-memory `SCStream` frame. The current `Copy Screen` Control is therefore a latency/availability prototype only. Do **not** expect the Control to copy a frame yet.

The next engineering step is to validate on a physical iOS 27 device whether a low-latency shared transport between the active screen-capture process and the Control/AppIntent is permitted and fast enough. If iOS suspends or isolates the required state, the exact one-gesture clipboard goal is not achievable through a third-party Control without opening/activating the capture app.

## Build

Push to `main` or run **Actions → Build unsigned IPA → Run workflow**. Download the `ScreenshotClipboard-unsigned` artifact and sign/sideload the IPA using your normal tool.

## First device test

1. Install and launch ScreenshotClipboard.
2. Tap **Start Full-Screen Capture** and approve the system capture UI/permission.
3. Leave the app and verify capture remains active.
4. Return to the app and tap **Copy Current Frame**; paste into Notes/Messages to verify the current screen frame is on the clipboard.
5. Add the `Copy Screen` Control to Control Center / Action Button and test invocation latency. In v0.1 the Control intentionally does not copy yet.

## Why this is experimental

Apple's iOS ScreenCaptureKit APIs make background full-display capture possible, but WidgetKit Controls/AppIntents execute separately from the capture app. This repository is intended to establish the real device constraints rather than claim the final workflow works before it has been measured on-device.
