# Cursor Menu Bar Stats 📊

A native macOS application that displays Cursor usage statistics directly in the system menu bar.

**Author:** [Adrianno Esnarriaga](https://github.com/adriannoes)  
**Repository:** [cursor-status-bar](https://github.com/adriannoes/cursor-status-bar)

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
cursor-status-bar/
├── CursorMenuBarApp/          # Swift Package
│   ├── Sources/
│   │   └── CursorMenuBarApp/
│   │       ├── Models/        # Data models (PremiumUsage, ModelUsage, CursorMetrics)
│   │       ├── Services/      # TokenProvider, API client, MetricsRepository
│   │       ├── Views/         # MenuBarView (SwiftUI)
│   │       └── CursorStatsApp.swift
│   ├── Tests/                 # Unit tests
│   └── Package.swift
└── Scripts/                   # Build and distribution scripts
```

**Key Components:**
- `CursorTokenProvider`: Reads token from SQLite database
- `CursorAPI`: HTTP client for Cursor API endpoints
- `MetricsRepository`: Aggregates and manages metrics
- `MenuBarView`: SwiftUI interface

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

## Troubleshooting

### "Cursor token not found"
- Ensure you're logged into Cursor
- Verify database exists: `ls ~/Library/Application\ Support/Cursor/User/globalStorage/state.vscdb`
- Restart the app after logging into Cursor

### Error 401 (Unauthorized)
- Token expired: Log out and back into Cursor, then restart the app

### Error 403 (Forbidden)
- Check internet connection
- May be a network/firewall restriction

### Build Errors
- Update Xcode: `xcode-select --install`
- Clean build: `swift package clean && swift package resolve`

### App doesn't appear in menu bar
- Check if running: `ps aux | grep CursorMenuBarApp`
- Verify macOS permissions in System Settings

## 🚀 Creating a Release

1. **Update version** in `Scripts/package_app.sh` and `CHANGELOG.md`

2. **Run tests:**
   ```bash
   cd CursorMenuBarApp
   swift test
   ```

3. **Create app bundle:**
   ```bash
   ./Scripts/package_app.sh 0.1.0 release
   zip -r CursorMenuBarApp-0.1.0.zip CursorMenuBarApp/CursorMenuBarApp.app
   ```

4. **(Optional) Sign and notarize:**
   ```bash
   export APP_STORE_CONNECT_API_KEY_P8="..."
   export APP_STORE_CONNECT_KEY_ID="..."
   export APP_STORE_CONNECT_ISSUER_ID="..."
   ./Scripts/sign_and_notarize.sh 0.1.0
   ```

5. **Upload to GitHub Releases**

## Development

### Adding New Metrics

1. Add fields to `Models/CursorMetrics.swift`
2. Update `Services/MetricsRepository.swift` to fetch data
3. Update `Views/MenuBarView.swift` to display information

### Dependencies

- **GRDB.swift** (6.0.0+): SQLite database access

## 📝 License

This project is provided as-is, without warranties.

## 🤝 Contributing

1. Fork the project
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 🙏 Acknowledgments

Inspired by:
- [cursor-stats](https://github.com/Dwtexe/cursor-stats) by Dwtexe
- [cursor-stats-lite](https://github.com/darzhang/cursor-stats-lite) by darzhang
- [CodexBar](https://github.com/steipete/CodexBar) by steipete

## 👤 Author

**Adrianno Esnarriaga**

- GitHub: [@adriannoes](https://github.com/adriannoes)
- Repository: [cursor-status-bar](https://github.com/adriannoes/cursor-status-bar)
