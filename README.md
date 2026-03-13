# Cursor Menu Bar Stats 📊

A native macOS application that displays Cursor usage statistics directly in the system menu bar.

## Features

- 📊 **Real-time monitoring** of Cursor premium requests
- 📈 **Model distribution** showing which AI models are most used
- 💳 **Subscription plan information** including included and remaining requests
- 🔄 **Configurable auto-refresh** (30s, 1min, 5min, 10min)
- 🎨 **Native interface** using SwiftUI and MenuBarExtra

## Requirements

- macOS 13.0 (Ventura) or higher
- Cursor installed and logged in
- Xcode 15.0+ (for building from source)

## 📥 Quick Installation

### Download via GitHub Releases

1. Download the latest version from [Releases](https://github.com/adriannoes/cursor-status-bar/releases)
2. Extract the zip and run:
   ```bash
   unzip CursorMenuBarApp-X.X.X.zip
   open CursorMenuBarApp.app
   ```
3. On first run, allow file access in System Settings > Privacy & Security > Files and Folders

## 🔨 Build from Source

### Using Xcode (Recommended)

```bash
git clone https://github.com/adriannoes/cursor-status-bar.git
cd cursor-status-bar/CursorMenuBarApp
open Package.swift
```

Then in Xcode: Select `CursorMenuBarApp` scheme → Press `Cmd+R` to build and run.

### Using Command Line

```bash
git clone https://github.com/adriannoes/cursor-status-bar.git
cd cursor-status-bar/CursorMenuBarApp
swift package resolve
swift build -c release
.build/release/CursorMenuBarApp
```

**Note:** If you encounter SDK/compiler version errors, use Xcode instead or run:
```bash
xcodebuild -resolvePackageDependencies
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

## How It Works

1. **Reads authentication token** from Cursor's SQLite database:
   ```
   ~/Library/Application Support/Cursor/User/globalStorage/state.vscdb
   ```

2. **Fetches usage data** from Cursor's API:
   - Premium requests (current/limit)
   - Model distribution (GPT-4, GPT-4-32k, GPT-3.5-turbo)
   - Billing cycle information

3. **Displays metrics** in the macOS menu bar

## Project Structure

```
cursor-stats/
├── CursorShared/              # Swift Package (models, API, MetricsRepository)
├── CursorMenuBarApp/          # macOS menu bar app
│   ├── Sources/CursorMenuBarApp/
│   │   ├── Services/          # CursorTokenProvider (SQLite)
│   │   └── Views/             # MenuBarView (SwiftUI)
│   └── Package.swift
├── CursorStats/               # iOS app (Xcode project)
│   ├── CursorStats/           # App, Features, Core, Resources
│   └── CursorStats.xcodeproj
├── docs/                      # ROADMAP, workflow docs
└── Scripts/                   # Build and distribution scripts
```

**Key Components:**
- `CursorShared`: Models, CursorAPI, MetricsRepository, TokenProviding protocol
- `CursorTokenProvider` (macOS): Reads token from SQLite database
- `MenuBarView`: SwiftUI interface (macOS)

## Configuration

### Custom Database Path

If Cursor is in a non-standard location:
```swift
CursorTokenProvider.shared.setCustomDatabasePath("/custom/path/state.vscdb")
```

### Refresh Interval

Configure directly in the app menu (30s, 1min, 5min, 10min).

## Testing

Run tests with:
```bash
cd CursorMenuBarApp
swift test
```

Or in Xcode: Press `Cmd+U`

**What to verify:**
- ✅ Menu bar icon appears
- ✅ Menu opens and displays data
- ✅ Token is read from database
- ✅ API calls succeed
- ✅ Auto-refresh works

## Development

### Adding New Metrics

1. Add fields to `Models/CursorMetrics.swift`
2. Update `Services/MetricsRepository.swift` to fetch data
3. Update `Views/MenuBarView.swift` to display information

### Dependencies

- **GRDB.swift** (6.0.0+): SQLite database access

## 📝 License

This project is provided as-is, without warranties.

## 🙏 Acknowledgments

Inspired by:
- [cursor-stats](https://github.com/Dwtexe/cursor-stats) by Dwtexe
- [cursor-stats-lite](https://github.com/darzhang/cursor-stats-lite) by darzhang
- [CodexBar](https://github.com/steipete/CodexBar) by steipete
