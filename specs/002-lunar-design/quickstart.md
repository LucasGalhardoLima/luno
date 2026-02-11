# Quickstart: Lunar Design System

**Feature**: 002-lunar-design
**Branch**: `002-lunar-design`

## Prerequisites

### Landing Page
- Node.js 18+ (for Astro build)
- npm or pnpm
- Modern browser for local development

### iOS App
- Xcode 16+ (for iOS 17 minimum deployment target)
- Xcode 26+ (for Liquid Glass APIs — optional, for iOS 26 features)
- iOS 17+ simulator or device
- swift-snapshot-testing package (already in project)

## Project Structure

```text
luno/
├── landing/                    # Astro landing page (NEW)
│   ├── astro.config.mjs
│   ├── tailwind.config.ts
│   ├── package.json
│   ├── public/
│   │   ├── images/            # OG images, app screenshots
│   │   └── fonts/             # Syne variable font (self-hosted)
│   ├── src/
│   │   ├── layouts/
│   │   │   └── BaseLayout.astro
│   │   ├── components/
│   │   │   ├── Hero.astro
│   │   │   ├── BentoGrid.astro
│   │   │   ├── BentoCard.astro
│   │   │   ├── ParaSection.astro
│   │   │   ├── ParaCategoryCard.astro
│   │   │   ├── WaitlistForm.astro
│   │   │   ├── Footer.astro
│   │   │   └── ThemeToggle.astro
│   │   ├── pages/
│   │   │   ├── index.astro
│   │   │   └── privacy.astro
│   │   ├── styles/
│   │   │   ├── global.css       # Tailwind imports + CSS variables (design tokens)
│   │   │   └── animations.css   # Micro-transition keyframes
│   │   └── scripts/
│   │       ├── scroll-reveal.ts  # Intersection Observer logic
│   │       └── form-handler.ts   # Formspree AJAX enhancement
│   └── tests/
│       └── tokens.test.ts       # Verify CSS tokens match contract
│
├── Luno/                        # iOS app (EXISTING — files modified)
│   ├── Shared/
│   │   ├── Theme/
│   │   │   ├── LunoColors.swift    # Palette adjustments
│   │   │   ├── LunoTheme.swift     # Spacing/typography refinements
│   │   │   └── LunoChrome.swift    # Liquid Glass dual-path modifier
│   │   ├── Components/
│   │   │   ├── FloatingCard.swift   # Updated glass surface
│   │   │   ├── CategoryBadge.swift  # Updated PARA colors
│   │   │   └── RecordButton.swift   # PhaseAnimator pulse, refined design
│   │   ├── Animations/
│   │   │   └── MicroTransitions.swift  # Named spring aliases
│   │   └── Extensions/
│   │       └── View+Animations.swift   # matchedGeometryEffect helpers
│   ├── Features/
│   │   ├── Capture/
│   │   │   ├── CaptureView.swift
│   │   │   └── CategorizationSheet.swift
│   │   ├── Notes/
│   │   │   └── NotesView.swift
│   │   ├── Folders/
│   │   │   ├── FoldersView.swift
│   │   │   └── FolderCardView.swift
│   │   ├── NoteDetail/
│   │   │   ├── NoteDetailView.swift
│   │   │   └── CategoryPickerView.swift
│   │   └── Settings/
│   │       └── SettingsView.swift
│   └── App/
│       └── ContentView.swift    # Tab chrome update
│
├── LunoTests/
│   └── Snapshots/               # All snapshot reference images regenerated
│
└── specs/002-lunar-design/      # This feature's documentation
```

## Getting Started

### Landing Page

```bash
# Navigate to landing directory
cd landing

# Install dependencies
npm install

# Start development server
npm run dev
# → http://localhost:4321

# Build for production
npm run build

# Preview production build
npm run preview
```

### iOS App

```bash
# Open Xcode project
open Luno.xcodeproj

# Build and run on simulator (⌘R)
# Target: iPhone 16 Pro simulator (iOS 17+)

# Run unit tests (⌘U)
# Run snapshot tests with regeneration:
# Set SNAPSHOT_TESTING_RECORD=all in scheme env variables, then ⌘U
```

## Key Development Workflows

### 1. Color Token Sync
When changing a color in `LunoColors.swift`, update the corresponding CSS variable in `landing/src/styles/global.css`. Refer to `specs/002-lunar-design/contracts/design-tokens.md` for the mapping.

### 2. Liquid Glass Dual-Path Testing
Test the app on both iOS 17 simulator (fallback glassmorphism) and iOS 26 simulator (native Liquid Glass). Both paths live in `LunoChrome.swift`'s `lunoGlassSurface()` modifier.

### 3. Snapshot Regeneration
After completing all visual changes:
1. Add `SNAPSHOT_TESTING_RECORD=all` to the test scheme's environment variables
2. Run all tests (⌘U)
3. Remove the environment variable
4. Run tests again to verify they pass
5. Commit the new reference images

### 4. Formspree Form Testing
The Formspree URL is configured via environment variable. For local development, use a test form ID or mock the endpoint.

## Validation Checklist

- [ ] Landing page Lighthouse score: 90+ desktop, 85+ mobile
- [ ] Landing page WCAG 2.1 AA: zero critical violations
- [ ] iOS app launch time: under 400ms cold start
- [ ] iOS animations: 60fps, no frame drops
- [ ] All snapshot tests passing with new reference images
- [ ] Color tokens match between CSS and Swift (per contract)
- [ ] prefers-reduced-motion respected on landing page
- [ ] Reduce Motion setting respected in iOS app
