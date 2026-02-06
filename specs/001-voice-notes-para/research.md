# Research: Voice-First Notes with PARA Categorization

**Date**: 2026-02-04
**Feature**: 001-voice-notes-para

## 1. Apple On-Device LLM (Foundation Models)

### Decision
Use Apple's **Foundation Models framework** (`import FoundationModels`) for on-device PARA categorization with structured output via `@Generable`.

### Rationale
- **Privacy**: Fully on-device, no data leaves the device
- **Offline**: Works without internet connection
- **Cost**: Free (no API charges)
- **Performance**: ~0.6ms time-to-first-token, ~30 tokens/sec on iPhone 15 Pro
- **Structured Output**: `@Generable` macro provides type-safe Swift objects directly

### Alternatives Considered
| Alternative | Rejected Because |
|-------------|------------------|
| Always cloud (Claude) | Requires internet, privacy concerns, API costs |
| Core ML custom model | Requires training data, complex setup, less flexible |
| OpenAI API | Same issues as cloud-only, plus no Apple integration |

### Requirements
- **iOS 26+** (or later) for Foundation Models framework
- Apple Intelligence-enabled devices only (iPhone 15 Pro+, M1+ Macs/iPads)
- ~7GB storage for the model
- User must enable Apple Intelligence in Settings

### Implementation Pattern

```swift
import FoundationModels

@Generable
enum PARACategory: String, CaseIterable {
    case project, area, resource, archive
}

@Generable
struct CategorizationResult {
    @Guide(description: "The PARA category that best fits this note")
    let category: PARACategory

    @Guide(description: "Brief explanation for the categorization")
    let reasoning: String

    @Guide(description: "Confidence from 0.0 to 1.0", .range(0.0...1.0))
    let confidence: Double
}

func categorize(_ noteContent: String) async throws -> CategorizationResult {
    let session = LanguageModelSession {
        """
        You are a PARA classification expert. Classify notes into:
        - project: Has a deadline, requires multiple tasks
        - area: Ongoing responsibility (health, finances, career)
        - resource: Reference material for future use
        - archive: Completed or inactive items
        """
    }

    let response = try await session.respond(
        to: "Classify: \(noteContent)",
        generating: CategorizationResult.self
    )
    return response.content
}
```

### Fallback Strategy
When `confidence < 0.8`, fall back to Claude API and store the example for future on-device improvement.

---

## 2. Claude API Fallback

### Decision
Use **Anthropic's Claude API** via official Swift SDK as fallback when on-device confidence is below 80%.

### Rationale
- **Accuracy**: Claude provides higher accuracy for ambiguous notes
- **Official SDK**: Anthropic provides maintained Swift package
- **Training Data**: Failed on-device attempts can be stored to improve prompts

### Implementation Pattern

```swift
import Anthropic

class ClaudeCategorizationService {
    private let client: Anthropic

    init(apiKey: String) {
        self.client = Anthropic(apiKey: apiKey)
    }

    func categorize(_ content: String) async throws -> CategorizationResult {
        let message = try await client.messages.create(
            model: "claude-sonnet-4-20250514",
            maxTokens: 256,
            messages: [
                .user("Classify this note into PARA (project/area/resource/archive): \(content)")
            ]
        )
        // Parse response into CategorizationResult
    }
}
```

### API Key Management
- Store in Keychain (not UserDefaults or code)
- User provides key in Settings
- Placeholder for now: `""`

---

## 3. SwiftUI Micro-Animations

### Decision
Use **native SwiftUI animation APIs** exclusively. No third-party animation libraries needed.

### Rationale
- SwiftUI's built-in system is robust for micro-transitions
- iOS 17+ provides `PhaseAnimator`, `KeyframeAnimator` for complex sequences
- Third-party libraries add unnecessary complexity
- Apple's spring presets (`.smooth`, `.snappy`, `.bouncy`) cover most needs

### Alternatives Considered
| Alternative | Rejected Because |
|-------------|------------------|
| Lottie | Only needed for After Effects animations; adds complexity |
| Hero library | UIKit-based; SwiftUI has `matchedGeometryEffect` |
| Spring library | Lightweight but unnecessary with native APIs |

### Animation Patterns to Use

**Button Taps**:
```swift
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
```

**Floating Cards**:
```swift
struct FloatingCard: View {
    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.background)
                    .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
            )
    }
}
```

**Screen Transitions**:
```swift
// iOS 18+ hero animations
.navigationTransition(.zoom(sourceID: note.id, in: heroNamespace))

// Fallback for iOS 17
.matchedGeometryEffect(id: note.id, in: namespace)
```

**Accessibility**:
```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

.animation(reduceMotion ? nil : .spring(), value: isExpanded)
```

---

## 4. SwiftData with iCloud Sync

### Decision
Use **SwiftData** for local persistence with **optional CloudKit sync** (user opt-in).

### Rationale
- Modern Apple persistence framework (iOS 17+)
- Native SwiftUI integration with `@Query`
- Built-in CloudKit support for sync
- Local-first architecture (offline capable)

### Alternatives Considered
| Alternative | Rejected Because |
|-------------|------------------|
| Core Data | More complex, SwiftData is the modern replacement |
| Realm | Third-party dependency, no iCloud integration |
| UserDefaults | Not suitable for complex data |
| File-based | Loses query capabilities |

### Requirements
- iOS 17.0+ for SwiftData
- CloudKit capability in Xcode
- Paid Apple Developer Account for CloudKit

### Model Requirements for CloudKit Compatibility
1. No `@Attribute(.unique)` on synced properties
2. All properties must have default values OR be optional
3. All relationships must be optional with explicit inverses

### Sync Toggle Pattern

```swift
@main
struct LunoApp: App {
    @AppStorage("iCloudSyncEnabled") private var syncEnabled = false

    var modelContainer: ModelContainer {
        let config = ModelConfiguration(
            cloudKitDatabase: syncEnabled ?
                .private("iCloud.com.luno.notes") : .none
        )
        return try! ModelContainer(for: Note.self, configurations: config)
    }
}
```

### Privacy Considerations
- Use `.allowsCloudEncryption` for sensitive content
- Default sync to OFF (user opt-in)
- Inform users about data storage in Settings

---

## 5. Speech Recognition

### Decision
Use **Apple Speech framework** for voice-to-text transcription.

### Rationale
- Works offline (on-device recognition)
- No third-party dependency
- Privacy-preserving
- High accuracy for clear speech

### Implementation Pattern

```swift
import Speech

class SpeechService: SpeechServiceProtocol {
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionTask: SFSpeechRecognitionTask?

    func startTranscription(audioEngine: AVAudioEngine) -> AsyncStream<String> {
        AsyncStream { continuation in
            let request = SFSpeechAudioBufferRecognitionRequest()
            request.shouldReportPartialResults = true
            request.requiresOnDeviceRecognition = true // Offline mode

            recognitionTask = recognizer?.recognitionTask(with: request) { result, error in
                if let result = result {
                    continuation.yield(result.bestTranscription.formattedString)
                }
            }
        }
    }
}
```

---

## 6. iOS Version Strategy

### Decision
- **Minimum deployment**: iOS 17.0 (SwiftData, modern animations)
- **Full AI features**: iOS 26+ (Foundation Models)

### Graceful Degradation

| Feature | iOS 17-25 | iOS 26+ |
|---------|-----------|---------|
| Voice capture | ✅ | ✅ |
| Text input | ✅ | ✅ |
| Local storage | ✅ SwiftData | ✅ SwiftData |
| iCloud sync | ✅ | ✅ |
| On-device AI | ❌ Cloud-only | ✅ Foundation Models |
| Animations | ✅ | ✅ |

```swift
func categorize(_ content: String) async throws -> CategorizationResult {
    if #available(iOS 26, *) {
        // Try on-device first
        let result = try await onDeviceService.categorize(content)
        if result.confidence >= 0.8 {
            return result
        }
    }
    // Fallback to Claude
    return try await claudeService.categorize(content)
}
```

---

## Sources

### Foundation Models
- [Meet the Foundation Models framework - WWDC25](https://developer.apple.com/videos/play/wwdc2025/286/)
- [Foundation Models Documentation](https://developer.apple.com/documentation/FoundationModels)
- [The Ultimate Guide To Foundation Models Framework](https://azamsharp.com/2025/06/18/the-ultimate-guide-to-the-foundation-models-framework.html)

### SwiftUI Animations
- [Apple SwiftUI Animation Tutorials](https://developer.apple.com/tutorials/swiftui/animating-views-and-transitions)
- [Hacking with Swift - matchedGeometryEffect](https://www.hackingwithswift.com/quick-start/swiftui/how-to-synchronize-animations-from-one-view-to-another-with-matchedgeometryeffect)
- [PhaseAnimator Documentation](https://developer.apple.com/documentation/swiftui/phaseanimator)

### SwiftData + CloudKit
- [Syncing model data across devices](https://developer.apple.com/documentation/swiftdata/syncing-model-data-across-a-persons-devices)
- [How to sync SwiftData with iCloud](https://www.hackingwithswift.com/quick-start/swiftdata/how-to-sync-swiftdata-with-icloud)
- [Key Considerations Before Using SwiftData](https://fatbobman.com/en/posts/key-considerations-before-using-swiftdata/)

### Speech Framework
- [Speech Framework Documentation](https://developer.apple.com/documentation/speech)
- [Recognizing Speech in Live Audio](https://developer.apple.com/documentation/speech/recognizing-speech-in-live-audio)
