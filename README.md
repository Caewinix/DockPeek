# Dock Peek

Dock Peek is a lightweight macOS utility that lets you preview and manage app windows directly from the Dock.

When you hover over a Dock item, Dock Peek shows thumbnail previews of that app's windows. From the preview panel, you can:

- Inspect open windows at a glance
- Click a thumbnail to focus that window
- Close a window from the preview
- Exit fullscreen for a fullscreen window
- Trigger the app's Dock menu with right click or long press

## Features

- Dock hover previews for app windows
- Support for standard windows and fullscreen windows
- Window focus, close, and fullscreen exit actions
- Native macOS UI built with AppKit
- Multi-window handling per application

## Requirements

- Accessibility permission
- Screen Recording permission

## Permissions

Dock Peek uses system accessibility APIs and screen capture access to detect Dock items and render window thumbnails.

On first launch, macOS may prompt for:

- Accessibility access
- Screen Recording access

If prompts do not appear automatically, you can enable them manually in:

`System Settings -> Privacy & Security`

## Build

1. Open `Dock Peek.xcodeproj` in Xcode.
2. Select the `Dock Peek` scheme.
3. Build and run the app.

You can also build from the command line:

```bash
xcodebuild -project Dock Peek.xcodeproj -scheme Dock Peek -configuration Debug build
```

## How It Works

Dock Peek watches mouse events globally, detects when the cursor is over a Dock item, and then gathers the target app's windows. It builds a thumbnail preview panel and wires actions back to the underlying app window.

The project includes a few private macOS APIs to improve window detection, space handling, and focusing behavior.

## Project Structure

- `Dock Peek/AppDelegate.swift` - app bootstrap and global event monitoring
- `Dock Peek/Dock PeekManager.swift` - main preview and interaction controller
- `Dock Peek/Functions/` - accessibility, Dock, and window helpers
- `Dock Peek/Designs/` and `Dock Peek/Widgets/` - preview UI and window views
- `Dock Peek/Models/` - data models for Dock items and windows
