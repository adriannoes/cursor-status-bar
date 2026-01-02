# Testing Guide

## Quick Test Steps

### Option 1: Using Xcode (Recommended)

1. **Open the project:**
   ```bash
   cd CursorMenuBarApp
   open Package.swift
   ```

2. **In Xcode:**
   - Select the `CursorMenuBarApp` scheme
   - Select "My Mac" as the destination
   - Press `Cmd+R` to build and run

3. **First run:**
   - macOS may ask for file access permissions
   - Go to System Settings > Privacy & Security > Files and Folders
   - Allow access for the application

### Option 2: Using Command Line (if Xcode is not available)

If you encounter SDK/compiler version issues, try:

1. **Use Xcode's toolchain:**
   ```bash
   cd CursorMenuBarApp
   xcodebuild -resolvePackageDependencies
   swift build -c release
   ```

2. **Or use the full Xcode path:**
   ```bash
   /Applications/Xcode.app/Contents/Developer/usr/bin/swift build -c release
   ```

## What to Check

### ✅ Successful Test Indicators

1. **Menu bar icon appears:**
   - Look for a chart icon (📊) in the macOS menu bar
   - Should show usage like "150/500"

2. **Menu opens when clicked:**
   - Click the icon to see:
     - Premium requests (current/limit)
     - Progress bar
     - Subscription information
     - Model distribution

3. **Data loads:**
   - If you see actual numbers (not errors), the app is working
   - Data should refresh automatically

### ❌ Common Issues

**"Cursor token not found"**
- Solution: Open Cursor and log in, then restart the app

**"Invalid or expired token" (401)**
- Solution: Log out and log back into Cursor

**"HTTP error: 403"**
- This might be a CORS issue or network restriction
- Check your internet connection

**App doesn't appear in menu bar**
- Check if it's running: `ps aux | grep CursorMenuBarApp`
- Check macOS permissions in System Settings

## Troubleshooting Build Issues

If you see SDK/compiler version errors:

1. **Update Xcode:**
   ```bash
   xcode-select --install
   ```

2. **Use Xcode's toolchain:**
   ```bash
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   ```

3. **Clean and rebuild:**
   ```bash
   cd CursorMenuBarApp
   swift package clean
   swift package resolve
   swift build -c release
   ```

## Testing Checklist

- [ ] Project compiles without errors
- [ ] App launches successfully
- [ ] Menu bar icon appears
- [ ] Menu opens when clicked
- [ ] Token is read from Cursor database
- [ ] API calls succeed
- [ ] Usage data is displayed correctly
- [ ] Refresh works (manual and automatic)
- [ ] Error messages are clear

## Next Steps After Testing

If everything works:
1. Create a release using `./Scripts/package_app.sh`
2. Test the packaged `.app` bundle
3. Upload to GitHub Releases
