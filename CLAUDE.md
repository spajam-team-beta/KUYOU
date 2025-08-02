# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

KUYOU is an iOS application built with SwiftUI and Xcode. This is a new project created for SPAJAM 2025 (a hackathon event), currently in its initial state with minimal implementation.

## Development Environment

- **Platform**: iOS (SwiftUI)
- **IDE**: Xcode (version 26.0 based on project file)
- **Language**: Swift
- **Minimum iOS Version**: Check project settings in Xcode

## Building and Running

### Build the project
```bash
xcodebuild -project KUYOU.xcodeproj -scheme KUYOU -configuration Debug build
```

### Run on simulator
```bash
open -a Simulator
xcodebuild -project KUYOU.xcodeproj -scheme KUYOU -destination 'platform=iOS Simulator,name=iPhone 15' run
```

### Clean build
```bash
xcodebuild -project KUYOU.xcodeproj -scheme KUYOU clean
```

## Project Structure

The project follows standard iOS/SwiftUI conventions:

- `KUYOU/` - Main source directory
  - `KUYOUApp.swift` - App entry point with @main attribute
  - `ContentView.swift` - Main view containing the initial UI
  - `Assets.xcassets/` - Asset catalog for images, colors, and app icons

## Architecture Notes

Currently, the app is in its initial state with:
- Single view architecture using SwiftUI
- No external dependencies or packages
- Standard SwiftUI app lifecycle management

When extending this project:
- Follow SwiftUI best practices for view composition
- Consider MVVM pattern for more complex features
- Add unit tests in a dedicated test target when needed

## Testing

No test targets are currently configured. To add tests:
1. Add a new test target in Xcode
2. Use XCTest framework for unit tests
3. Use XCUITest for UI tests

## Common Tasks

### Adding new views
Create new SwiftUI View files in the KUYOU directory and compose them within ContentView or create navigation structure as needed.

### Managing dependencies
If Swift Package Manager dependencies are needed, add them through Xcode's File → Add Package Dependencies menu.