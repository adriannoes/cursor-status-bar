# Changelog

All notable changes to Cursor Menu Bar Stats will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2024-12-XX

### Added
- Initial release
- Real-time monitoring of Cursor premium requests
- Model distribution visualization (GPT-4, GPT-4-32k, GPT-3.5-turbo)
- Subscription plan information display
- Configurable auto-refresh intervals (30s, 1min, 5min, 10min)
- Native SwiftUI menu bar interface
- Automatic token reading from Cursor's SQLite database
- Error handling and user-friendly error messages
- Manual refresh capability

### Technical
- Swift Package Manager setup
- GRDB for SQLite access
- URLSession for API calls
- MenuBarExtra for native macOS integration

[Unreleased]: https://github.com/adriannoes/cursor-status-bar/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/adriannoes/cursor-status-bar/releases/tag/v0.1.0

