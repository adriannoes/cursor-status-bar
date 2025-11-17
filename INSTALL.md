# Installation Guide - Cursor Menu Bar Stats

## Prerequisites

Before installing, make sure you have:

1. **macOS 13.0 (Ventura) or higher**
   - Check in: Apple Menu > About This Mac

2. **Xcode 15.0 or higher** (for building from source)
   - Download from Mac App Store or [developer.apple.com](https://developer.apple.com/xcode/)

3. **Cursor installed and logged in**
   - The application must be installed and you must be logged into your account

## Step-by-Step Installation

### Option 1: Using Xcode (Recommended for Development)

1. **Clone or download the repository**
   ```bash
   git clone https://github.com/adriannoes/cursor-status-bar.git
   cd cursor-status-bar
   ```

2. **Open the project in Xcode**
   ```bash
   cd CursorMenuBarApp
   open Package.swift
   ```
   Or drag the `CursorMenuBarApp` folder to Xcode

3. **Select the scheme**
   - At the top of Xcode, select `CursorMenuBarApp` from the scheme dropdown
   - Make sure "My Mac" is selected as the destination

4. **Build and run**
   - Press `Cmd+R` or click the Play button
   - On first run, you may need to allow access to Cursor's database

5. **Allow database access** (if prompted)
   - macOS may request permission to access files
   - Go to System Settings > Privacy & Security > Files and Folders
   - Allow access for the application

### Option 2: Command Line Build

1. **Navigate to the directory**
   ```bash
   git clone https://github.com/adriannoes/cursor-status-bar.git
   cd cursor-status-bar/CursorMenuBarApp
   ```

2. **Resolve dependencies**
   ```bash
   swift package resolve
   ```

3. **Build in release mode**
   ```bash
   swift build -c release
   ```

4. **Run the application**
   ```bash
   .build/release/CursorMenuBarApp
   ```

## First Run

1. **Verify Cursor is running**
   - The application needs to read the token from Cursor's database
   - Make sure Cursor is installed and you are logged in

2. **Database location**
   - The application automatically searches at:
     ```
     ~/Library/Application Support/Cursor/User/globalStorage/state.vscdb
     ```

3. **If token is not found**
   - Open Cursor and log in again
   - Close and reopen the Menu Bar application

## Verification

After installation, you should see:

1. **Icon in the menu bar**
   - A chart icon (📊) in the macOS menu bar
   - Shows the number of requests used/limit (e.g., "150/500")

2. **Menu when clicking**
   - Click the icon to see:
     - Current premium requests and limit
     - Visual progress bar
     - Subscription plan information
     - Distribution by AI model
     - Update options

## Advanced Configuration

### Custom Database Path

If Cursor is in a non-standard location, you can configure programmatically:

```swift
// In code, before using the token provider
CursorTokenProvider.shared.setCustomDatabasePath("/custom/path/state.vscdb")
```

### Refresh Interval

The application allows configuring the refresh interval:
- 30 seconds
- 1 minute (default)
- 5 minutes
- 10 minutes

Configure directly in the application menu.

## Troubleshooting

### "Cursor token not found"

**Solution:**
1. Make sure you are logged into Cursor
2. Verify the file exists:
   ```bash
   ls ~/Library/Application\ Support/Cursor/User/globalStorage/state.vscdb
   ```
3. If it doesn't exist, open Cursor and log in again

### Build error

**Solution:**
1. Make sure you have Xcode updated
2. Clean the build:
   ```bash
   cd CursorMenuBarApp
   swift package clean
   ```
3. Resolve dependencies again:
   ```bash
   swift package resolve
   ```

### Application doesn't appear in menu bar

**Solution:**
1. Check if the application is running:
   ```bash
   ps aux | grep CursorMenuBarApp
   ```
2. Check macOS permissions
3. Try running again

### Error 401 (Unauthorized)

**Solution:**
- The token may have expired
- Log out and log back into Cursor
- Restart the Menu Bar application

## Uninstallation

To remove the application:

1. **Stop the application**
   - Right-click the icon in the menu bar
   - Select "Quit" or use Activity Monitor

2. **Remove files** (if manually installed)
   ```bash
   rm -rf ~/Applications/CursorMenuBarApp.app
   ```

3. **Remove settings** (optional)
   ```bash
   defaults delete com.adriannoes.cursormenubar
   ```

## Support

If you encounter issues:

1. Check system logs:
   ```bash
   log show --predicate 'process == "CursorMenuBarApp"' --last 1h
   ```

2. Open an issue on GitHub with:
   - macOS version
   - Xcode version
   - Complete error messages
   - Steps to reproduce the problem
