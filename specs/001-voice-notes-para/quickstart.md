# Developer Quickstart: Luno

**Feature**: Voice-First Notes with PARA Categorization
**Branch**: `001-voice-notes-para`

## Prerequisites

### Required
- **Xcode 16.0+** (for iOS 17 SwiftData support)
- **Xcode 17.0+** (for iOS 26 Foundation Models support)
- **macOS Sequoia 15.0+** or **macOS Tahoe 16.0+**
- **Apple Developer Account** (paid, for CloudKit)
- **iOS 17.0+ device** (simulator works for most features)

### For Full AI Features
- **iOS 26+ device** with Apple Intelligence enabled
- iPhone 15 Pro/Pro Max or newer, OR M1+ iPad/Mac
- ~7GB free storage (for Foundation Models)

## Initial Setup

### 1. Clone and Open Project

```bash
git clone <repository-url>
cd luno
git checkout 001-voice-notes-para
open Luno.xcodeproj
```

### 2. Configure Signing & Capabilities

1. Select the **Luno** target in Xcode
2. Go to **Signing & Capabilities**
3. Select your Team
4. Add capabilities:
   - **iCloud** → Enable CloudKit → Add container: `iCloud.com.yourcompany.luno`
   - **Background Modes** → Enable Remote Notifications
   - **Speech Recognition**

### 3. Configure Info.plist

Ensure these keys are present:

```xml
<key>NSSpeechRecognitionUsageDescription</key>
<string>Luno uses speech recognition to transcribe your voice notes.</string>

<key>NSMicrophoneUsageDescription</key>
<string>Luno needs microphone access to record your voice notes.</string>
```

### 4. Install Dependencies

```bash
# Using Swift Package Manager (configured in Xcode)
# Dependencies resolve automatically on project open

# For testing from command line:
swift package resolve
```

## Project Structure

```
Luno/
├── App/                    # App entry, DI, navigation
├── Features/               # Feature modules
│   ├── Capture/           # Voice + text note capture
│   ├── Notes/             # Note browsing
│   ├── Folders/           # PARA folder browsing
│   ├── NoteDetail/        # Note detail + re-categorization
│   └── Settings/          # API key, sync, categorization config
├── Core/
│   ├── Models/            # SwiftData models
│   ├── Services/          # Business logic (Speech, Categorization, Logger)
│   └── Repository/        # Data access layer
├── Shared/                # Reusable components, theme, animations
└── Resources/             # Assets, Info.plist
```

## Running the App

### Simulator
```bash
# Build and run on iOS 17+ simulator
xcodebuild -scheme Luno -destination 'platform=iOS Simulator,name=iPhone 16 Pro'

# Or use Xcode: ⌘R
```

### Device
1. Connect iOS device
2. Select device in Xcode scheme
3. Build and run (⌘R)

**Note**: Foundation Models (on-device AI) only work on physical devices with iOS 26+.

## Configuration

### Claude API Key (Optional Fallback)

For AI categorization fallback when on-device confidence is low:

1. Get API key from [Anthropic Console](https://console.anthropic.com/)
2. Enter in app Settings (gear icon in Notes tab toolbar)
3. Or set environment variable for development:
   ```bash
   export CLAUDE_API_KEY="sk-ant-..."
   ```

### iCloud Sync

Sync is **disabled by default**. Users enable in Settings.

For development:
1. Sign into iCloud on device/simulator
2. Enable sync in app Settings
3. Use CloudKit Dashboard to monitor sync

## Running Tests

### Unit Tests
```bash
xcodebuild test \
  -scheme Luno \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -only-testing:LunoTests/Unit
```

### UI Tests
```bash
xcodebuild test \
  -scheme Luno \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -only-testing:LunoUITests
```

### Snapshot Tests
```bash
# First run generates reference images
# Set environment variable to record:
SNAPSHOT_TESTING_RECORD=true xcodebuild test ...

# Subsequent runs compare against references
xcodebuild test \
  -scheme Luno \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -only-testing:LunoTests/Snapshots
```

### All Tests
```bash
xcodebuild test \
  -scheme Luno \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

## Development Workflow

### TDD Cycle (Required by Constitution)

1. **Red**: Write failing test first
2. **Green**: Implement minimal code to pass
3. **Refactor**: Clean up while tests pass

Example:
```swift
// 1. Write test (LunoTests/Unit/Services/CategorizationServiceTests.swift)
func test_categorize_projectNote_returnsProjectCategory() async throws {
    let sut = makeSUT()
    let result = try await sut.categorize("Launch website by March 15")
    XCTAssertEqual(result.category, .project)
}

// 2. Run test - should fail
// 3. Implement CategorizationService.categorize()
// 4. Run test - should pass
// 5. Refactor if needed
```

### Feature Development

1. Check out feature branch
2. Read relevant spec in `specs/001-voice-notes-para/`
3. Review contracts in `specs/.../contracts/`
4. Write tests first (TDD)
5. Implement feature
6. Run all tests
7. Create PR

## Debugging

### Speech Recognition
```swift
// Uses LunoLogger (os.Logger) — check Console.app with:
// subsystem: com.luno.app, category: Speech
import os
let log = Logger(subsystem: "com.luno.app", category: "Speech")
```

### Foundation Models
```swift
// Check availability
if #available(iOS 26, *) {
    switch SystemLanguageModel.default.availability {
    case .available:
        print("✅ Foundation Models available")
    case .unavailable(let reason):
        print("❌ Unavailable: \(reason)")
    }
}
```

### SwiftData
```swift
// Debug queries
#if DEBUG
let container = try ModelContainer(
    for: Note.self,
    configurations: ModelConfiguration(isStoredInMemoryOnly: false)
)
print("📁 Store URL: \(container.configurations.first?.url?.path ?? "unknown")")
#endif
```

### CloudKit
- Use [CloudKit Dashboard](https://icloud.developer.apple.com/dashboard/)
- Check Development vs Production environment
- Monitor sync events in Console.app

## Common Issues

### "Speech recognition not available"
- Check device supports on-device recognition
- Ensure language is supported (start with en-US)
- Request authorization first

### "Foundation Models unavailable"
- Requires iOS 26+
- Requires Apple Intelligence-enabled device
- User must enable Apple Intelligence in Settings
- Model may still be downloading (~7GB)

### "CloudKit sync not working"
- Verify iCloud capability added
- Check container name matches
- Ensure user signed into iCloud
- Check CloudKit Dashboard for errors

### Tests fail with "No such module"
```bash
# Clean build folder
rm -rf ~/Library/Developer/Xcode/DerivedData/Luno-*
# Resolve packages
swift package resolve
# Rebuild
xcodebuild clean build -scheme Luno
```

## Code Style

### SwiftLint
```bash
# Install
brew install swiftlint

# Run
swiftlint

# Auto-fix
swiftlint --fix
```

### SwiftFormat
```bash
# Install
brew install swiftformat

# Run
swiftformat .
```

## Useful Commands

```bash
# Build for release
xcodebuild -scheme Luno -configuration Release

# Archive for distribution
xcodebuild archive -scheme Luno -archivePath ./build/Luno.xcarchive

# Export IPA
xcodebuild -exportArchive -archivePath ./build/Luno.xcarchive \
  -exportPath ./build -exportOptionsPlist ExportOptions.plist
```

## Resources

- [Spec Document](./spec.md)
- [Implementation Plan](./plan.md)
- [Research Notes](./research.md)
- [Data Model](./data-model.md)
- [Service Contracts](./contracts/)

### Apple Documentation
- [SwiftData](https://developer.apple.com/documentation/swiftdata)
- [Foundation Models](https://developer.apple.com/documentation/foundationmodels)
- [Speech Framework](https://developer.apple.com/documentation/speech)
- [CloudKit](https://developer.apple.com/documentation/cloudkit)

### WWDC Sessions
- [Meet Foundation Models - WWDC25](https://developer.apple.com/videos/play/wwdc2025/286/)
- [What's new in SwiftData - WWDC24](https://developer.apple.com/videos/play/wwdc2024/10137/)
