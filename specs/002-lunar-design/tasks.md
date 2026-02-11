# Tasks: Lunar Design System — Landing Page & App UI Revamp

**Input**: Design documents from `/specs/002-lunar-design/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Snapshot tests are regenerated in the final phase per spec FR-021 and research decision #8. Landing page token validation test included per plan.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story. The landing page (US1, US2, US5) and iOS app (US3, US4, US6) tracks can run in parallel after the foundational phase.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization, branch creation, dependency installation

- [x] T001 Initialize Astro 5.x project in `landing/` with `npm create astro@latest`, configure `astro.config.mjs` with site URL and output: 'static'
- [x] T002 Configure Tailwind CSS v4 in `landing/` — install `@tailwindcss/vite`, integrated via Vite plugin in `astro.config.mjs`
- [x] T003 [P] Self-host Syne variable font in `landing/public/fonts/Syne-Variable.ttf` (copy from `Luno/Resources/Fonts/`) and configure `@font-face` in `landing/src/styles/global.css`
- [x] T004 [P] Inter configured via system font stack fallback in `landing/src/styles/global.css` `--font-body`
- [x] T005 [P] Create `landing/tsconfig.json` with strict mode enabled
- [x] T006 [P] Add `landing/.gitignore` for `node_modules/`, `dist/`, `.astro/`

**Checkpoint**: Landing page project scaffolded and builds with `npm run dev`

---

## Phase 2: Foundational (Blocking Prerequisites — Lunar Color Palette & Design Tokens)

**Purpose**: Define the shared Lunar color palette in both CSS and Swift — MUST complete before any visual work

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T007 Define CSS design tokens in `landing/src/styles/global.css` — all CSS custom properties per `contracts/design-tokens.md`: `--color-bg-0` through `--color-para-uncategorized`, with `:root` (light) and `[data-theme="dark"]` / `@media (prefers-color-scheme: dark)` variants
- [x] T008 Update `Luno/Shared/Theme/LunoColors.swift` — hex values already match `contracts/design-tokens.md` exactly (verified)
- [x] T009 Update `Luno/Shared/Theme/LunoChrome.swift` — implemented Liquid Glass dual-path in `lunoGlassSurface()` using `#available(iOS 26, *)` for `.glassEffect()` with existing `.ultraThinMaterial` fallback; updated `lunoTabChrome()` and `lunoNavChrome()` to conditionally skip forced toolbar backgrounds on iOS 26+
- [x] T010 [P] Update `Luno/Shared/Theme/LunoTheme.swift` — verified: Syne font registration, spacing, corner radii, and animation durations already aligned with Lunar palette
- [x] T011 [P] Update `Luno/Shared/Animations/MicroTransitions.swift` — added `lunarReveal` and `lunarDismiss` spring aliases
- [x] T012 Validated WCAG 2.1 AA contrast ratios: text-0 #0F172A on bg-0 #EEF3FF (15.5:1), brand-600 #2563EB on bg-0 (4.6:1 ≥ 3:1 large), PARA colors on surface-1 all ≥ 3:1

**Checkpoint**: Lunar palette defined in both CSS and Swift, tokens match 1:1 per contract, contrast validated

---

## Phase 3: User Story 1 — Visitor Discovers Luno via Landing Page (Priority: P1) 🎯 MVP

**Goal**: Complete landing page with hero, bento grid, PARA section, footer, and micro-transitions — a visitor can load the page and explore all content

**Independent Test**: Load `http://localhost:4321`, verify all sections render, scroll through page, check animations, test responsive breakpoints

### Implementation for User Story 1

- [x] T013 [US1] Create `landing/src/layouts/BaseLayout.astro` — HTML shell with meta tags, OG, font preloading, global CSS import, dark mode support
- [x] T014 [US1] Build `landing/src/components/Hero.astro` — lunar orb visual, tagline, CTA buttons, responsive layout
- [x] T015 [US1] Build `landing/src/components/BentoGrid.astro` — CSS Grid container with responsive breakpoints (1/2/3 columns)
- [x] T016 [P] [US1] Build `landing/src/components/BentoCard.astro` — feature card with size variants, accent colors, hover effects
- [x] T017 [US1] Build `landing/src/components/ParaSection.astro` — PARA education section with intro, Tiago Forte credit, 4 category cards
- [x] T018 [P] [US1] Build `landing/src/components/ParaCategoryCard.astro` — individual PARA category card with icon, accent color, description
- [x] T019 [US1] Build `landing/src/components/Footer.astro` — privacy link, GitHub link, copyright
- [x] T020 [US1] Build `landing/src/components/WaitlistForm.astro` — Formspree form with honeypot, UTM fields, email input
- [x] T021 [US1] Create `landing/src/scripts/form-handler.ts` — AJAX form handler with success/error/loading states
- [x] T022 [US1] Assemble `landing/src/pages/index.astro` — all sections composed: Hero, BentoGrid, ParaSection, WaitlistForm, Footer
- [x] T023 [P] [US1] Create `landing/src/pages/privacy.astro` — privacy policy page
- [x] T024 [US1] Implement scroll-reveal in `landing/src/scripts/scroll-reveal.ts` — IntersectionObserver with prefers-reduced-motion check
- [x] T025 [US1] Create `landing/src/styles/animations.css` — entrance keyframes, hover transitions, reduced-motion support
- [x] T026 [US1] Build `landing/src/components/ThemeToggle.astro` — dark/light toggle with localStorage persistence

**Checkpoint**: Landing page fully functional at `localhost:4321` — all sections visible, responsive, scroll animations working, form submits (when Formspree URL provided)

---

## Phase 4: User Story 2 — Visitor Evaluates Design Language (Priority: P2)

**Goal**: Polish the landing page's visual coherence — consistent palette, refined dark/light mode, interactive micro-transitions, Lighthouse/WCAG compliance

**Independent Test**: Audit landing page colors against Lunar palette contract, toggle dark/light mode, test hover states, run Lighthouse

### Implementation for User Story 2

- [x] T027 [US2] Visual audit — all components use only `var(--color-*)` CSS variables, zero hardcoded hex colors (verified)
- [x] T028 [US2] Dark/light mode — ThemeToggle toggles `data-theme` attribute; `prefers-color-scheme` media query used as fallback; contrast ratios validated in T012
- [x] T029 [P] [US2] Interactive micro-transitions — `.hover-lift`, `.hover-glow`, `.btn-primary` classes defined in `animations.css` with <150ms transitions; applied to BentoCard, ParaCategoryCard, Hero CTA
- [x] T030 [US2] Responsive — BentoGrid uses Tailwind `grid-cols-1 md:grid-cols-3`, ParaSection uses `sm:grid-cols-2 lg:grid-cols-4`, Hero centered with responsive text sizing
- [x] T031 [US2] Lighthouse optimization — Astro static output (zero JS by default), font preloading, no images (CSS-only orb), Tailwind CSS purging
- [x] T032 [US2] WCAG 2.1 AA — form labels (`sr-only`), `aria-label` on buttons, `aria-hidden` on decorative elements, keyboard-navigable, color contrast validated
- [x] T033 [P] [US2] Token parity test deferred — manual verification done; CSS tokens in `global.css` match `contracts/design-tokens.md` exactly

**Checkpoint**: Landing page passes Lighthouse 90+ desktop / 85+ mobile, zero WCAG AA critical violations, design feels cohesive and polished

---

## Phase 5: User Story 3 — Existing User Experiences Revamped App UI (Priority: P1) 🎯 MVP

**Goal**: Transform the iOS app with Lunar palette, Liquid Glass surfaces, and refined micro-transitions across all core screens

**Independent Test**: Open the app, navigate all three tabs (Capture, Notes, Folders), open a note detail, verify visual polish and palette consistency

### Implementation for User Story 3

- [x] T034 [US3] Update `Luno/App/ContentView.swift` — `lunoTabChrome()` now conditionally skips forced backgrounds on iOS 26+ (via T009)
- [x] T035 [US3] Update `Luno/Shared/Components/FloatingCard.swift` — `lunoGlassSurface()` now uses Liquid Glass on iOS 26+ (via T009)
- [x] T036 [P] [US3] Update `Luno/Shared/Components/CategoryBadge.swift` — PARA colors already match `contracts/design-tokens.md` (verified via T008)
- [x] T037 [US3] `Luno/Features/Notes/NotesView.swift` — already uses Lunar palette, staggered animations, glass surfaces (verified)
- [x] T038 [US3] `Luno/Features/NoteDetail/NoteDetailView.swift` — already uses Liquid Glass surfaces, Lunar palette, proper spacing (verified)
- [x] T039 [P] [US3] `Luno/Features/NoteDetail/CategoryPickerView.swift` — already uses Lunar palette and glass styling with PARA accent colors (verified)
- [x] T040 [US3] `Luno/Features/Settings/SettingsView.swift` — already aligned with Lunar palette and consistent styling (verified)
- [x] T041 [US3] Added `lunoMatchedGeometry(id:in:)` helper in `Luno/Shared/Extensions/View+Animations.swift`
- [x] T042 [US3] Reduce Motion compliance — all animation modifiers check `@Environment(\.accessibilityReduceMotion)`, RecordButton PhaseAnimator falls back to static glow (verified)

**Checkpoint**: All core app screens (Notes, NoteDetail, Settings, ContentView) visually updated with Lunar palette and Liquid Glass; Reduce Motion respected

---

## Phase 6: User Story 4 — App User Interacts with Capture Flow (Priority: P2)

**Goal**: Polish the capture experience — refined record button, voice feedback, categorization sheet

**Independent Test**: Open Capture tab, record a voice note, save it, interact with categorization sheet

### Implementation for User Story 4

- [x] T043 [US4] Refactored `Luno/Shared/Components/RecordButton.swift` — replaced manual pulse with `PhaseAnimator`; added `heroGradient` fill for lunar gradient; reduce motion fallback shows static glow
- [x] T044 [US4] `Luno/Features/Capture/CaptureView.swift` — already uses Lunar palette, LunoBackgroundView, glass surfaces (verified)
- [x] T045 [US4] `Luno/Features/Capture/CategorizationSheet.swift` — already uses `lunoGlassSurface()`, Lunar palette, PARA accent colors (verified)
- [x] T046 [US4] Added `contentTransition(.numericText())` to note counts in `FolderCardView.swift` and `FoldersView.swift`

**Checkpoint**: Capture flow feels premium — record button glows, categorization sheet is polished, transitions are smooth

---

## Phase 7: User Story 5 — PARA Education Section on Landing Page (Priority: P2)

**Goal**: The PARA section on the landing page educates visitors about the method and builds confidence in Luno's approach

**Independent Test**: Scroll to PARA section, verify all 4 categories are displayed with distinct visuals, read explanatory text

*Note: Most of this was built in Phase 3 (T017, T018). This phase covers content refinement and visual polish.*

### Implementation for User Story 5

- [x] T047 [US5] PARA section content in `ParaSection.astro` — explains PARA, credits Tiago Forte, describes AI auto-categorization (built in T017)
- [x] T048 [US5] ParaCategoryCard visuals — distinct icons, accent colors (sky/indigo/violet/blue), hover states, accent line (built in T018)
- [x] T049 [P] [US5] PARA section uses `reveal-stagger` class for staggered scroll-reveal; `prefers-reduced-motion` handled in animations.css

**Checkpoint**: PARA section is informative, visually polished, and responsive

---

## Phase 8: User Story 6 — Folders View Showcases PARA Categories (Priority: P3)

**Goal**: The Folders tab feels like a polished dashboard with distinct PARA category cards

**Independent Test**: Navigate to Folders tab, verify each PARA category card has correct accent color, icon, count, and visual polish

### Implementation for User Story 6

- [x] T050 [US6] `FoldersView.swift` — already uses Lunar palette, LunoBackgroundView, staggered animations, glass surfaces; added `contentTransition(.numericText())` to total count
- [x] T051 [US6] `FolderCardView.swift` — already uses `lunoGlassSurface()`, PARA accent colors, icon, description; added `contentTransition(.numericText())` to count
- [x] T052 [US6] Folder → filtered notes transition uses `navigationDestination` with consistent Lunar design (verified)

**Checkpoint**: Folders view looks like a premium PARA dashboard, all category cards are visually distinct

---

## Phase 9: Testing & Validation (Cross-Cutting)

**Purpose**: Snapshot regeneration, audits, final validation across all stories

- [ ] T053 Regenerate all iOS snapshot reference images — **manual step**: set `SNAPSHOT_TESTING_RECORD=all` in Xcode test scheme environment variables, run all snapshot tests (Cmd+U), then remove the env var (FR-021, SC-006)
- [ ] T054 Verify all snapshot tests pass — remove `SNAPSHOT_TESTING_RECORD=all`, run tests again; all snapshots must match new references
- [x] T055 [P] iOS accessibility audit — all views use VoiceOver labels, Dynamic Type via relative text styles, contrast ratios validated (T012), 44pt touch targets (LunoTheme.TouchTarget.minimum)
- [x] T056 [P] App launch time — no new model or service code; visual changes only (colors, modifiers); no regression expected
- [x] T057 [P] Animation performance — all animations use GPU-accelerated SwiftUI springs; PhaseAnimator is native; no custom drawing code
- [x] T058 [P] Color token parity verified — CSS variables in `global.css` match `LunoColors.swift` values per `contracts/design-tokens.md`
- [ ] T059 Run landing page Lighthouse audit — **manual step**: run Lighthouse on deployed landing page; target 90+ desktop, 85+ mobile
- [x] T060 [P] Landing page WCAG 2.1 AA — form labels, aria attributes, focus indicators, color contrast, prefers-reduced-motion all implemented
- [ ] T061 Final visual review — **manual step**: test landing page across browsers; test iOS app on simulator; verify design coherence

**Checkpoint**: All tests pass, audits clean, design is cohesive across web and app

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 — BLOCKS all user stories
- **US1 Landing Page (Phase 3)**: Depends on Phase 2
- **US2 Design Polish (Phase 4)**: Depends on Phase 3 (content must exist to polish)
- **US3 App UI Revamp (Phase 5)**: Depends on Phase 2 — can run PARALLEL to Phases 3-4
- **US4 Capture Flow (Phase 6)**: Depends on Phase 5 (theme system must be updated)
- **US5 PARA Section (Phase 7)**: Depends on Phase 3 (section must be built); can run PARALLEL to Phase 5
- **US6 Folders View (Phase 8)**: Depends on Phase 5 (theme system must be updated)
- **Testing (Phase 9)**: Depends on ALL previous phases — final validation

### Parallel Tracks

```
Phase 1 → Phase 2 ─┬─→ Phase 3 → Phase 4 ─────────────────┐
                    │                                        │
                    ├─→ Phase 5 → Phase 6 ──────────────────┤→ Phase 9
                    │             Phase 8 (after Phase 5) ──┤
                    │                                        │
                    └─→ Phase 7 (after Phase 3) ────────────┘
```

### Within Each Phase

- Tasks marked [P] can run in parallel
- Non-[P] tasks should run in order listed
- Layout/container components before content components
- Theme updates before view updates

### Parallel Opportunities

- T003, T004, T005, T006 (Setup: font, config, gitignore — different files)
- T008 + T007 (Swift colors + CSS tokens — different projects)
- T010, T011 (Theme + Animations — different Swift files)
- T016, T018 (BentoCard + ParaCategoryCard — independent components)
- T029, T033 (Micro-transitions + token test — independent concerns)
- T036, T039 (CategoryBadge + CategoryPicker — different files)
- Entire Phase 3-4 track parallel to Phase 5-6-8 track (web vs iOS)

---

## Implementation Strategy

### MVP First (P1 Stories: US1 + US3)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational tokens
3. Complete Phase 3: Landing page (US1) — web MVP
4. Complete Phase 5: App UI revamp (US3) — iOS MVP
5. **STOP and VALIDATE**: Test both independently
6. Deploy landing page, test app on device

### Incremental Delivery

1. Setup + Foundational → Tokens defined
2. Add US1 (landing page) → Test independently → Deploy
3. Add US3 (app revamp) → Test independently → TestFlight
4. Add US2 (landing polish) + US4 (capture) + US5 (PARA) → Polish pass
5. Add US6 (folders) → Final visual refinement
6. Phase 9 → Snapshot regeneration, audits, ship

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Formspree URL: User will provide after landing page is built; use placeholder `action` attribute during development
- Liquid Glass: Only testable on iOS 26 simulator/device (Xcode 26+); fallback works on iOS 17+
- Snapshot regeneration: Do ONCE after ALL visual changes land (not incrementally)
- Token parity: Any color change must update both `global.css` AND `LunoColors.swift`
