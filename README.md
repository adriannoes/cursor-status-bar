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

## 📥 Quick Installation (Recommended)

### Download via GitHub Releases

1. **Download the latest version:**
   - Visit [Releases](https://github.com/adriannoes/cursor-status-bar/releases)
   - Download the `CursorMenuBarApp-X.X.X.zip` file

2. **Install:**
   ```bash
   # Extract the zip
   unzip CursorMenuBarApp-X.X.X.zip
   
   # Move to Applications (optional)
   mv CursorMenuBarApp.app /Applications/
   
   # Run
   open CursorMenuBarApp.app
   ```

3. **First run:**
   - macOS may request permission to access files
   - Go to System Settings > Privacy & Security > Files and Folders
   - Allow access for the application

## 🔨 Build from Source Code

### Build Prerequisites

- Xcode 15.0 or higher
- Swift 5.9 or higher

### Option 1: Using Xcode

1. Clone the repository:
```bash
git clone https://github.com/adriannoes/cursor-status-bar.git
cd cursor-status-bar
```

2. Open the project in Xcode:
```bash
cd CursorMenuBarApp
open Package.swift
```

3. Build and run:
- Select the `CursorMenuBarApp` scheme in Xcode
- Press `Cmd+R` to build and run

### Option 2: Command Line Build

```bash
# Clone the repository
git clone https://github.com/adriannoes/cursor-status-bar.git
cd cursor-status-bar/CursorMenuBarApp

# Resolve dependencies
swift package resolve

# Build
swift build -c release

# Run
.build/release/CursorMenuBarApp
```

### Option 3: Create App Bundle for Distribution

```bash
# Create the app bundle (run from project root)
./Scripts/package_app.sh 0.1.0 release

# The app will be created at: CursorMenuBarApp/CursorMenuBarApp.app
# To create a zip:
zip -r CursorMenuBarApp-0.1.0.zip CursorMenuBarApp/CursorMenuBarApp.app
```

## How It Works

The application:

1. **Reads the authentication token** from Cursor's SQLite database located at:
   ```
   ~/Library/Application Support/Cursor/User/globalStorage/state.vscdb
   ```

2. **Makes requests to Cursor's API** to get:
   - Current premium requests and limit
   - Usage distribution by model (GPT-4, GPT-4-32k, GPT-3.5-turbo)
   - Billing cycle information

3. **Displays the information** in a menu in the macOS menu bar

## Configuration

### Custom Database Path

If Cursor is installed in a non-standard location, you can configure a custom path programmatically:

```swift
CursorTokenProvider.shared.setCustomDatabasePath("/custom/path/state.vscdb")
```

## Project Structure

```
CursorMenuBarApp/
├── Sources/
│   └── CursorMenuBarApp/
│       ├── Models/
│       │   ├── PremiumUsage.swift
│       │   ├── ModelUsage.swift
│       │   └── CursorMetrics.swift
│       ├── Services/
│       │   ├── CursorTokenProvider.swift
│       │   ├── CursorAPI.swift
│       │   └── MetricsRepository.swift
│       ├── Views/
│       │   └── MenuBarView.swift
│       └── CursorStatsApp.swift
├── Tests/
│   └── CursorMenuBarAppTests/
│       ├── CursorTokenProviderTests.swift
│       └── MetricsRepositoryTests.swift
└── Package.swift
```

## Tests

Run tests with:

```bash
cd CursorMenuBarApp
swift test
```

Or in Xcode:
- Press `Cmd+U` to run all tests

## Development

### Adding New Metrics

To add new metrics:

1. Add fields to the `CursorMetrics` model in `Models/CursorMetrics.swift`
2. Update `MetricsRepository` to fetch the new data
3. Update `MenuBarView` to display the new information

### Debugging

To see debug logs, add `print()` statements in the services. The application prints:
- Database read errors
- HTTP request errors
- Loading status

## Troubleshooting

### Token Not Found

If you receive the error "Cursor token not found":
1. Make sure you are logged into Cursor
2. Verify that the `state.vscdb` file exists in the default path
3. Try configuring a custom path if necessary

### Error 401 (Unauthorized)

If you receive error 401:
- The token may have expired
- Log out and log back into Cursor
- The application will try to fetch a new token automatically

### Error 403 (Forbidden)

403 errors can occur due to:
- CORS issues (the application simulates browser headers to avoid this)
- Network/firewall restrictions

## 🚀 For Developers

### Creating a Release

1. Update the version in:
   - `Scripts/package_app.sh`
   - `Scripts/sign_and_notarize.sh`
   - `CHANGELOG.md` (in root)

2. Run tests:
   ```bash
   cd CursorMenuBarApp
   swift test
   swiftlint
   ```

3. Create the app bundle:
   ```bash
   ./Scripts/package_app.sh 0.1.0 release
   ```

4. (Optional) Sign and notarize:
   ```bash
   export APP_STORE_CONNECT_API_KEY_P8="..."
   export APP_STORE_CONNECT_KEY_ID="..."
   export APP_STORE_CONNECT_ISSUER_ID="..."
   ./Scripts/sign_and_notarize.sh 0.1.0
   ```

5. Create a GitHub Release:
   - Upload the `.zip` file
   - Add release notes from `CHANGELOG.md`

## 📝 License

This project is provided as-is, without warranties.

## 🤝 Contributing

Contributions are welcome! Please:
1. Fork the project
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 🙏 Acknowledgments

Inspired by projects:
- [cursor-stats](https://github.com/Dwtexe/cursor-stats) by Dwtexe
- [cursor-stats-lite](https://github.com/darzhang/cursor-stats-lite) by darzhang
- [CodexBar](https://github.com/steipete/CodexBar) by steipete

## 👤 Author

**Adrianno Esnarriaga**

- GitHub: [@adriannoes](https://github.com/adriannoes)
- Repository: [cursor-status-bar](https://github.com/adriannoes/cursor-status-bar)
