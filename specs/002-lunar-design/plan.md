# Implementation Plan: Lunar Design System — Landing Page & App UI Revamp

**Branch**: `002-lunar-design` | **Date**: 2026-02-10 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/002-lunar-design/spec.md`

## Summary

Create a premium, lunar-themed landing page using Astro + Tailwind CSS with bento grid layout, micro-transitions, and a dedicated PARA method section. Then revamp the existing iOS app's UI to adopt the same Lunar color palette, Apple's Liquid Glass material (iOS 26+), and refined micro-interactions — transforming a default-looking app into a modern, cozy, polished experience.

## Technical Context

**Language/Version**: TypeScript 5.x (landing page), Swift 5.9+ (iOS app)
**Primary Dependencies**: Astro 5.x, Tailwind CSS v4 (landing); SwiftUI, swift-snapshot-testing (iOS)
**Storage**: N/A (visual update only; no new persistence)
**Testing**: Vitest (landing page tokens); XCTest + swift-snapshot-testing (iOS snapshots + unit tests)
**Target Platform**: Web (all modern browsers) + iOS 17.0+ (Liquid Glass on iOS 26+)
**Project Type**: Web + Mobile (landing page is a new sub-project; iOS app is existing)
**Performance Goals**: Lighthouse 90+ desktop / 85+ mobile (landing); 60fps animations, <400ms cold start (iOS)
**Constraints**: Zero JS by default on landing page (Astro static); Reduce Motion / prefers-reduced-motion respected; WCAG 2.1 AA contrast ratios; Formspree for form handling (URL to be provided by user)
**Scale/Scope**: 1 landing page (~6 sections), 7 iOS screens updated, 3 theme files refactored, 5 snapshot test suites regenerated

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| **I. Test-First Development** | PASS | Snapshot tests regenerated after visual changes; new landing page token validation tests; TDD for any new Swift components |
| **II. Native iOS Excellence** | PASS | SwiftUI remains primary framework; Liquid Glass via native `.glassEffect()` on iOS 26; existing `lunoGlassSurface()` fallback for iOS 17+; Reduce Motion, Dynamic Type, Dark Mode respected |
| **III. User Experience Quality** | PASS | Accessibility audit maintained (VoiceOver, contrast, 44pt touch targets); <400ms launch; 60fps animations; prefers-reduced-motion on web |
| **IV. Code Architecture** | PASS | MVVM preserved; theme changes centralized in LunoColors/LunoTheme/LunoChrome; no business logic touched; landing page follows component-based Astro architecture |
| **V. Simplicity & Pragmatism** | PASS | No new third-party dependencies for iOS; Astro + Tailwind are minimal for web; Formspree avoids backend; color system refactored in-place, not rebuilt |

**Quality Gates**:
- Compilation: Zero warnings in Release ✓ (visual changes only)
- Tests: All snapshot tests regenerated and passing ✓
- Coverage: N/A (visual changes; no new business logic)
- Linting: SwiftLint/SwiftFormat applied ✓
- Accessibility: Lighthouse + Accessibility Inspector audits ✓
- Performance: No regression in launch time or memory ✓

**Post-Design Re-evaluation**: The design phase introduces no new violations. The Liquid Glass dual-path approach in `LunoChrome.swift` adds a single `#available` check — this is the standard Apple pattern for conditional API usage, not an architectural violation.

## Project Structure

### Documentation (this feature)

```text
specs/002-lunar-design/
├── plan.md              # This file
├── spec.md              # Feature specification
├── research.md          # Phase 0 research findings
├── data-model.md        # Design token entities
├── quickstart.md        # Setup and development guide
├── contracts/
│   ├── design-tokens.md     # CSS ↔ Swift color token contract
│   └── formspree-integration.md  # Form submission contract
├── checklists/
│   └── requirements.md      # Spec quality checklist
└── tasks.md             # Phase 2 output (created by /speckit.tasks)
```

### Source Code (repository root)

```text
landing/                        # NEW: Astro landing page
├── astro.config.mjs
├── tailwind.config.ts
├── package.json
├── tsconfig.json
├── public/
│   ├── images/                # OG image, app screenshots
│   ├── fonts/                 # Syne variable font (self-hosted)
│   └── robots.txt
├── src/
│   ├── layouts/
│   │   └── BaseLayout.astro   # HTML shell, meta, font loading
│   ├── components/
│   │   ├── Hero.astro         # Lunar orb + tagline + CTA
│   │   ├── BentoGrid.astro    # CSS Grid container
│   │   ├── BentoCard.astro    # Individual feature card
│   │   ├── ParaSection.astro  # PARA method education section
│   │   ├── ParaCategoryCard.astro  # Individual PARA category card
│   │   ├── WaitlistForm.astro # Formspree form with AJAX
│   │   ├── Footer.astro       # Links, App Store badge
│   │   └── ThemeToggle.astro  # Dark/light mode switch
│   ├── pages/
│   │   ├── index.astro        # Main landing page
│   │   └── privacy.astro      # Privacy policy page
│   ├── styles/
│   │   ├── global.css         # Tailwind + CSS custom properties (design tokens)
│   │   └── animations.css     # Scroll reveal keyframes
│   └── scripts/
│       ├── scroll-reveal.ts   # Intersection Observer for entrance animations
│       └── form-handler.ts    # Formspree AJAX submission
└── tests/
    └── tokens.test.ts         # Token parity validation

Luno/                           # EXISTING: iOS app (files modified)
├── Shared/Theme/
│   ├── LunoColors.swift       # Palette refinements, surface opacity adjustments
│   ├── LunoTheme.swift        # Typography/spacing refinements
│   └── LunoChrome.swift       # Liquid Glass dual-path, chrome modifiers update
├── Shared/Components/
│   ├── FloatingCard.swift      # Visual polish
│   ├── CategoryBadge.swift     # Updated PARA palette
│   └── RecordButton.swift      # PhaseAnimator pulse, lunar glow
├── Shared/Animations/
│   └── MicroTransitions.swift  # Named spring aliases
├── Shared/Extensions/
│   └── View+Animations.swift   # matchedGeometryEffect helper
├── Features/
│   ├── Capture/CaptureView.swift
│   ├── Capture/CategorizationSheet.swift
│   ├── Notes/NotesView.swift
│   ├── Folders/FoldersView.swift
│   ├── Folders/FolderCardView.swift
│   ├── NoteDetail/NoteDetailView.swift
│   ├── NoteDetail/CategoryPickerView.swift
│   └── Settings/SettingsView.swift
└── App/ContentView.swift       # Tab/nav chrome conditional update

LunoTests/Snapshots/            # EXISTING: Reference images regenerated
├── __Snapshots__/              # All .png files regenerated
├── CaptureViewSnapshotTests.swift
├── CategoryPickerSnapshotTests.swift
├── FolderCardViewSnapshotTests.swift
├── NoteCardViewSnapshotTests.swift
└── RecordButtonSnapshotTests.swift
```

**Structure Decision**: This is a **Web + Mobile** project. The landing page lives in `landing/` at the repo root as a self-contained Astro project. The iOS app remains in `Luno/` with modifications to the existing theme system and feature views. No new iOS modules are created — changes are in-place updates to existing files.

## Complexity Tracking

No constitution violations. No complexity justifications needed.

| Aspect | Approach | Justification |
|--------|----------|---------------|
| Liquid Glass dual-path | `#available(iOS 26, *)` inside existing `lunoGlassSurface()` | Standard Apple conditional API pattern; zero call-site changes |
| Landing page as separate project | `landing/` directory with own `package.json` | Clean separation; Astro has its own toolchain |
| Color token contract | Manual parity between CSS and Swift | Automated sync would be over-engineering; 15 tokens is manageable |

## Implementation Phases

### Phase A: Lunar Color Palette & Design Tokens
*Foundation — must complete first*

1. Refine `LunoColors.swift` hex values (surface opacity, PARA hue spread)
2. Create `landing/src/styles/global.css` with CSS custom properties mirroring Swift tokens
3. Validate contrast ratios (WCAG AA) for all text/background combinations
4. Update `LunoChrome.swift` with Liquid Glass dual-path (`#available(iOS 26, *)`)
5. Update `lunoTabChrome()` / `lunoNavChrome()` for conditional toolbar backgrounds

### Phase B: Landing Page — Structure & Static Content
*Depends on Phase A (palette defined)*

1. Initialize Astro 5.x project in `landing/`
2. Configure Tailwind CSS v4 with Lunar palette
3. Create `BaseLayout.astro` with meta, font loading, dark mode
4. Build Hero section (lunar orb visual, tagline, CTA)
5. Build BentoGrid + BentoCard components
6. Build PARA method section with 4 category cards
7. Build Footer section
8. Build WaitlistForm with Formspree integration

### Phase C: Landing Page — Polish & Micro-Transitions
*Depends on Phase B (static content)*

1. Implement Intersection Observer scroll-reveal system
2. Add CSS micro-transitions (hover states, entrance animations)
3. Implement dark/light mode toggle
4. Responsive breakpoint testing and adjustments
5. Lighthouse audit and performance optimization
6. Accessibility audit (WCAG 2.1 AA)
7. Implement `prefers-reduced-motion` support

### Phase D: iOS App — Theme System Updates
*Depends on Phase A (palette defined), can run parallel to Phases B-C*

1. Update `LunoColors.swift` with refined palette values
2. Update `LunoTheme.swift` typography/spacing refinements
3. Update `LunoChrome.swift` glass surface modifier + chrome modifiers
4. Update `MicroTransitions.swift` with named spring aliases
5. Refactor `RecordButton.swift` pulse to `PhaseAnimator`
6. Update `CategoryBadge.swift` with refined PARA colors

### Phase E: iOS App — Screen-by-Screen UI Polish
*Depends on Phase D (theme system updated)*

1. Update `ContentView.swift` tab bar chrome
2. Update `CaptureView.swift` visual polish
3. Update `NotesView.swift` card layout and animations
4. Update `FoldersView.swift` + `FolderCardView.swift` visual polish
5. Update `NoteDetailView.swift` + `CategoryPickerView.swift`
6. Update `CategorizationSheet.swift` glass surfaces
7. Update `SettingsView.swift` visual alignment
8. Add `matchedGeometryEffect` for NoteCard → NoteDetail transition
9. Add `contentTransition(.numericText())` on folder counts

### Phase F: Testing & Validation
*Depends on Phases C + E (all visual changes complete)*

1. Regenerate all iOS snapshot reference images (batch `SNAPSHOT_TESTING_RECORD=all`)
2. Verify all snapshot tests pass with new references
3. Run iOS accessibility audit (VoiceOver, Dynamic Type, contrast)
4. Verify launch time performance (<400ms)
5. Verify animation performance (60fps)
6. Run landing page Lighthouse audit (90+ desktop, 85+ mobile)
7. Run landing page WCAG 2.1 AA audit
8. Verify color token parity between CSS and Swift
9. Final visual review on multiple devices/browsers
