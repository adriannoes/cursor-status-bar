# Project Structure

This document describes the code organization of Cursor Menu Bar Stats.

## Overview

```
cursor-status-bar/              # Repository root
├── README.md                    # Main documentation
├── CHANGELOG.md                 # Version history
├── INSTALL.md                   # Installation guide
├── PROJECT_STRUCTURE.md          # This file
├── .gitignore                   # Git ignored files
├── Scripts/                     # Build and distribution scripts
│   ├── package_app.sh
│   └── sign_and_notarize.sh
│
└── CursorMenuBarApp/            # Swift Package
    ├── Package.swift            # Swift Package configuration
    │
    ├── Sources/
    │   └── CursorMenuBarApp/    # Main source code
    │       ├── CursorStatsApp.swift   # Application entry point
    │       │
    │       ├── Models/          # Data models
    │       │   ├── PremiumUsage.swift      # Premium usage model
    │       │   ├── ModelUsage.swift        # Model usage by AI model
    │       │   └── CursorMetrics.swift     # Aggregation of all metrics
    │       │
    │       ├── Services/        # Services and business logic
    │       │   ├── CursorTokenProvider.swift  # SQLite token reading
    │       │   ├── CursorAPI.swift           # Cursor API communication
    │       │   └── MetricsRepository.swift   # Metrics repository
    │       │
    │       └── Views/           # User interface
    │           └── MenuBarView.swift  # Main menu bar view
    │
    └── Tests/
        └── CursorMenuBarAppTests/     # Unit tests
            ├── CursorTokenProviderTests.swift
            └── MetricsRepositoryTests.swift
```

## Component Description

### Models

#### `PremiumUsage.swift`
Represents Cursor premium request usage.
- `current`: Requests used
- `limit`: Request limit
- `startOfMonth`: Cycle start date
- `percentage`: Calculated percentage
- `remaining`: Remaining requests

#### `ModelUsage.swift`
Represents usage by specific AI model.
- `ModelUsage`: Structure for an individual model
- `ModelUsageResponse`: API response with all models
- `ModelUsageData`: Raw data for a model

#### `CursorMetrics.swift`
Aggregates all metrics into a single structure.
- `premiumUsage`: Premium usage
- `modelDistribution`: List of models sorted by usage
- `subscriptionIncludedRequests`: Requests included in plan
- `subscriptionRemainingRequests`: Remaining requests
- `billingCycleStart/End`: Billing cycle dates

### Services

#### `CursorTokenProvider.swift`
Responsible for reading the authentication token from Cursor's SQLite database.
- `getToken()`: Fetches token (with cache)
- `clearCache()`: Clears cache
- `setCustomDatabasePath()`: Configures custom path
- `getCustomDatabasePath()`: Returns configured path

**Default database location:**
```
~/Library/Application Support/Cursor/User/globalStorage/state.vscdb
```

#### `CursorAPI.swift`
Manages all HTTP calls to Cursor's API.
- `fetchUsage()`: Fetches usage data (`/api/usage`)
- `fetchUsageLimit()`: Fetches usage limit (`/api/dashboard/get-hard-limit`)
- `getBrowserHeaders()`: Generates headers that simulate browser

**Endpoints used:**
- `GET /api/usage?user={userId}`
- `POST /api/dashboard/get-hard-limit`

#### `MetricsRepository.swift`
Central repository that coordinates fetching and aggregating metrics.
- `refresh()`: Updates all metrics
- `@Published var metrics`: Current metrics (observable)
- `@Published var isLoading`: Loading state
- `@Published var errorMessage`: Error messages

### Views

#### `MenuBarView.swift`
Main application interface using SwiftUI.
- `contentView`: Menu content
- `premiumUsageSection`: Premium requests section
- `subscriptionSection`: Plan information
- `modelDistributionSection`: Model distribution
- `footerView`: Settings and information

**Features:**
- Configurable automatic updates
- Visual progress bar
- Colors based on usage percentage
- Manual refresh

### App Entry Point

#### `CursorStatsApp.swift`
Application entry point using `@main`.
- Defines `MenuBarExtra` with icon and content
- Configures window style

## Data Flow

```
1. App starts
   ↓
2. MenuBarView appears
   ↓
3. MetricsRepository.refresh() is called
   ↓
4. CursorTokenProvider.getToken() fetches token from SQLite
   ↓
5. CursorAPI.fetchUsage() makes HTTP request
   ↓
6. Data is parsed and aggregated into CursorMetrics
   ↓
7. MenuBarView updates UI with data
   ↓
8. Timer schedules next update
```

## External Dependencies

- **GRDB.swift**: Library for SQLite access
  - Used in `CursorTokenProvider` to read Cursor's database
  - Version: 6.0.0+

## Tests

Tests are organized in:
- `CursorTokenProviderTests`: Tests token reading and configuration
- `MetricsRepositoryTests`: Tests calculations and metrics initialization

Run with:
```bash
cd CursorMenuBarApp
swift test
```

## Extensibility

To add new features:

1. **New metrics**: Add fields to `CursorMetrics.swift`
2. **New endpoints**: Add methods to `CursorAPI.swift`
3. **New views**: Create files in `Views/`
4. **New models**: Add structures in `Models/`

## Code Conventions

- **SwiftUI**: Used for all interface
- **Async/Await**: For asynchronous operations
- **@Published**: For observable properties
- **Error Handling**: Try/catch with specific error types
- **Naming**: camelCase for variables, PascalCase for types
