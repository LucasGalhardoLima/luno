# Feature Specification: Lunar Design System — Landing Page & App UI Revamp

**Feature Branch**: `002-lunar-design`
**Created**: 2026-02-10
**Status**: Draft
**Input**: User description: "Create a beautiful, modern, minimalistic landing page for Luno with lunar/moon theme, bento-style layout, micro-transitions, and PARA method section. Then revamp the iOS app UI with the same color palette, modern premium mobile trends, cozy feel, and Apple's Liquid Glass."

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Visitor Discovers Luno via Landing Page (Priority: P1)

A potential user visits the Luno landing page for the first time. They immediately perceive a premium, polished product through the lunar-themed visual identity — deep space blues, soft moonlight glows, and smooth micro-transitions. The bento grid layout lets them scan key features at a glance without scrolling fatigue. They find a dedicated PARA method section that explains what PARA is and why it matters for organizing notes, building confidence in the product's approach. The page feels modern, calming, and trustworthy.

**Why this priority**: The landing page is the first touchpoint for new users. Without a compelling first impression, no one downloads the app. This story covers the complete end-to-end experience of a visitor evaluating Luno.

**Independent Test**: Can be fully tested by loading the landing page URL and verifying all sections render correctly, animations play smoothly, and the PARA section is informative and accessible.

**Acceptance Scenarios**:

1. **Given** a visitor loads the landing page on a desktop browser, **When** the page finishes loading, **Then** the hero section displays with a lunar-themed visual, the app name, tagline, and a call-to-action button — all within 2 seconds of page load.
2. **Given** a visitor scrolls down the page, **When** bento grid sections enter the viewport, **Then** each card animates in with a subtle entrance transition (fade + slide or scale) that feels smooth and intentional.
3. **Given** a visitor reaches the PARA section, **When** they read it, **Then** they find a clear explanation of the PARA method (Projects, Areas, Resources, Archive), who created it, and why Luno uses it for note organization.
4. **Given** a visitor views the page on a mobile device (320px–428px width), **When** they browse the full page, **Then** the bento grid gracefully reflows to a single-column stack and all content remains readable and accessible.
5. **Given** a visitor has "prefers-reduced-motion" enabled, **When** they browse the page, **Then** all entrance animations and micro-transitions are disabled or replaced with simple fades.

---

### User Story 2 — Visitor Evaluates Luno's Design Language (Priority: P2)

A design-conscious visitor explores the landing page to evaluate the product's visual quality and coherence. They notice a unified lunar color palette across hero, bento cards, typography, and interactive elements. The page follows current design trends (bento grids, generous whitespace, subtle glassmorphism accents) without feeling generic. The overall impression is "premium, cozy, and modern."

**Why this priority**: Design quality directly impacts perceived product quality. A cohesive design system across the landing page establishes the visual identity that will carry into the app. This must feel intentional and polished.

**Independent Test**: Can be fully tested by auditing the landing page against the defined color palette, verifying visual consistency across all sections, and checking that the design feels distinct from generic templates.

**Acceptance Scenarios**:

1. **Given** the landing page is loaded, **When** inspecting any section, **Then** all colors used belong to the defined Lunar color palette (deep navy backgrounds, moonlight accent tones, soft silver text, warm amber highlights).
2. **Given** a visitor views the page in dark mode (default) and light mode, **When** switching between modes, **Then** the color palette adapts gracefully with appropriate contrast ratios (WCAG AA minimum).
3. **Given** a visitor interacts with buttons or interactive elements, **When** they hover or tap, **Then** micro-transitions provide feedback (scale, glow, or color shift) within 150ms.

---

### User Story 3 — Existing User Experiences the Revamped App UI (Priority: P1)

An existing Luno user opens the app after the UI revamp. They immediately notice the transformation: the previously default-looking iOS app now feels premium and intentional. The lunar color palette from the landing page carries through the app's backgrounds, cards, and accents. The interface uses Apple's Liquid Glass effect for surfaces while maintaining a cozy, non-overwhelming aesthetic. Micro-transitions make navigation and interactions feel alive. The three-tab navigation (Capture, Notes, Folders) retains its familiar structure but looks significantly more polished.

**Why this priority**: The app is the core product. While the landing page attracts users, the app retains them. A premium, modern UI that feels warm and inviting directly impacts daily usage satisfaction and retention.

**Independent Test**: Can be fully tested by navigating all three tabs, opening note details, creating a note, and verifying the visual polish, color consistency, and animation quality throughout.

**Acceptance Scenarios**:

1. **Given** a user opens the app, **When** the main view loads, **Then** the background features the lunar gradient theme with subtle ambient glow elements, and surfaces use Liquid Glass material effects.
2. **Given** a user navigates between the Capture, Notes, and Folders tabs, **When** switching tabs, **Then** the transition is smooth with a micro-animation and the selected tab indicator updates with a fluid motion.
3. **Given** a user views the Notes list, **When** note cards appear, **Then** they use the updated design with the lunar color palette, refined typography, subtle shadows, and staggered entrance animations.
4. **Given** a user opens a note detail view, **When** the view appears, **Then** the detail layout uses Liquid Glass surfaces, proper spacing, and the lunar palette — feeling cohesive with the rest of the app.
5. **Given** a user with "Reduce Motion" enabled opens the app, **When** navigating anywhere, **Then** all micro-transitions are disabled or replaced with simple opacity changes, maintaining usability.

---

### User Story 4 — App User Interacts with Capture Flow (Priority: P2)

A user opens the Capture tab to record a voice note or type a quick note. The revamped capture experience feels more immersive — the record button has a refined lunar glow, the voice waveform visualization uses the new palette, and the categorization sheet that appears after saving looks polished with glassmorphic surfaces and smooth reveal animations.

**Why this priority**: Capture is the primary user action in Luno. The recording and categorization flow must feel premium and reassuring — users need confidence that their notes are being captured properly.

**Independent Test**: Can be fully tested by recording a voice note, reviewing the transcription, saving it, and interacting with the categorization sheet.

**Acceptance Scenarios**:

1. **Given** a user is on the Capture tab in voice mode, **When** they view the record button, **Then** it displays with a refined design featuring the lunar gradient and a subtle ambient glow effect.
2. **Given** a user taps the record button, **When** recording begins, **Then** the button transitions to the recording state with a smooth animation and the UI provides clear visual feedback (pulsing glow, status text).
3. **Given** a user saves a note, **When** the categorization sheet appears, **Then** it slides in with a smooth transition, displays AI suggestion and category options with glassmorphic styling, and all interactions feel responsive.

---

### User Story 5 — Visitor Explores the Landing Page's PARA Education Section (Priority: P2)

A visitor who is unfamiliar with the PARA method discovers the dedicated section on the landing page. The section visually explains the four categories (Projects, Areas, Resources, Archive) with distinct visual treatments for each. The explanation is concise, uses everyday language, and makes clear why this organizational system helps with note-taking. The visitor understands PARA's value without needing to read external resources.

**Why this priority**: The PARA method is Luno's core differentiator. If visitors don't understand it, they won't see why Luno is different from any other note-taking app. This section must educate and persuade.

**Independent Test**: Can be fully tested by having a user unfamiliar with PARA read only this section and then describe what PARA is and why Luno uses it.

**Acceptance Scenarios**:

1. **Given** a visitor scrolls to the PARA section, **When** it enters the viewport, **Then** the four PARA categories are displayed with unique visual identifiers (icons, colors) and concise descriptions.
2. **Given** a visitor reads the PARA section, **When** they finish reading, **Then** they understand that PARA stands for Projects, Areas, Resources, Archive; that it was created by Tiago Forte; and that Luno uses AI to automatically categorize notes into these categories.
3. **Given** a visitor views the PARA section on any screen size, **When** the layout adapts, **Then** each category card remains distinct, readable, and visually engaging.

---

### User Story 6 — Folders View Showcases PARA Categories (Priority: P3)

A user navigates to the Folders tab in the revamped app. The folder cards for each PARA category now feature refined visuals that match the lunar palette — each category has a distinct accent color, the cards use Liquid Glass surfaces, and the count indicators are prominent. The overall Folders view feels like a polished dashboard rather than a plain list.

**Why this priority**: The Folders view is where the PARA system becomes tangible in the app. It needs to look impressive and reinforce the organizational value.

**Independent Test**: Can be fully tested by navigating to Folders, verifying each PARA category card renders with the correct accent color, layout, and visual polish.

**Acceptance Scenarios**:

1. **Given** a user opens the Folders tab, **When** the folder cards appear, **Then** each PARA category displays with its designated accent color, a recognizable icon, note count, and a brief description — all in the updated lunar design.
2. **Given** a user taps a folder card, **When** the folder opens, **Then** the transition uses a smooth animation and the filtered notes view maintains the same design language.

---

### Edge Cases

- What happens when the landing page loads on a very slow connection (3G)? Content should be visible within 5 seconds with progressive loading; critical text appears first, images and animations load lazily.
- How does the landing page handle browsers with JavaScript disabled? Core content (text, images) must be visible. Animations degrade gracefully to static layouts.
- What happens when the app's Liquid Glass effect is not supported on older devices? The app falls back to the current glassmorphism approach (semi-transparent surfaces with blur) without visual breakage.
- How does the bento grid handle extremely long text in a card? Text truncates with ellipsis; no layout breakage.
- What happens when the app is used in high-contrast accessibility mode? All UI elements maintain sufficient contrast ratios and remain fully usable.

## Requirements *(mandatory)*

### Functional Requirements

**Landing Page**

- **FR-001**: The landing page MUST display a hero section with the Luno brand name, tagline, and a primary call-to-action (App Store link or waitlist)
- **FR-002**: The landing page MUST include a bento grid section showcasing key app features with visually distinct cards
- **FR-003**: The landing page MUST include a dedicated PARA method section explaining all four categories (Projects, Areas, Resources, Archive), crediting Tiago Forte, and explaining why Luno chose this system
- **FR-004**: The landing page MUST use micro-transitions for element entrances (scroll-triggered) and interactive hover/tap states
- **FR-005**: The landing page MUST be fully responsive across mobile (320px), tablet (768px), and desktop (1440px+) breakpoints
- **FR-006**: The landing page MUST support both dark mode (default) and light mode, respecting the user's system preference
- **FR-007**: The landing page MUST respect "prefers-reduced-motion" to disable or reduce animations
- **FR-008**: The landing page MUST define and apply a Lunar color palette that includes deep navy backgrounds, moonlight blue accents, soft silver tones, warm amber highlights, and category-specific PARA colors
- **FR-009**: The landing page MUST include a footer section with relevant links (privacy policy, social media, app store badge)
- **FR-010**: The landing page MUST achieve a Lighthouse performance score of 90+ on desktop and 85+ on mobile
- **FR-011**: The landing page MUST meet WCAG 2.1 AA accessibility standards for color contrast, keyboard navigation, and screen reader compatibility

**App UI Revamp**

- **FR-012**: The app MUST adopt the same Lunar color palette defined for the landing page, adapted for iOS light and dark appearances
- **FR-013**: All app surfaces (cards, sheets, navigation bars, tab bars) MUST use Apple's Liquid Glass material effect where supported, with a graceful fallback to the existing glassmorphism style
- **FR-014**: The app MUST feature refined micro-transitions for tab switching, card reveals, button interactions, sheet presentations, and navigation transitions
- **FR-015**: All existing app screens (Capture, Notes, Folders, Note Detail, Settings, Categorization Sheet, Category Picker) MUST be updated with the new design language
- **FR-016**: The app's record button MUST feature a refined design with lunar gradient and ambient glow effect consistent with the new palette
- **FR-017**: Note cards in the Notes view MUST be updated with the new visual style — refined shadows, lunar-palette backgrounds, and polished typography
- **FR-018**: Folder cards in the Folders view MUST feature updated category accent colors from the Lunar palette and Liquid Glass surfaces
- **FR-019**: The app MUST maintain all existing accessibility features (VoiceOver, Dynamic Type, Reduce Motion, minimum touch targets of 44x44pt)
- **FR-020**: The app's theme system (LunoTheme, LunoColors, LunoChrome) MUST be updated to reflect the new palette while maintaining the existing architecture of adaptive colors and modifiers
- **FR-021**: All existing snapshot tests MUST be updated to reflect the new visual design

### Key Entities

- **Lunar Color Palette**: The unified set of colors used across both the landing page and the app — including background tiers, surface colors, brand accents, text hierarchy, PARA category colors, state colors, and gradients
- **Bento Card**: A visual container on the landing page that presents a feature or concept within the bento grid layout — each card has a title, description, optional icon/illustration, and a distinct visual treatment
- **PARA Category Visual Identity**: The color, icon, and descriptive text associated with each PARA category (Project, Area, Resource, Archive) — consistent between the landing page educational section and the app's folder/badge system

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: First-time visitors spend an average of 45+ seconds on the landing page (indicating engagement, not bounce)
- **SC-002**: The landing page achieves a Lighthouse performance score of 90+ (desktop) and 85+ (mobile)
- **SC-003**: All landing page content is accessible — passing automated WCAG 2.1 AA audit with zero critical violations
- **SC-004**: The app's revamped UI maintains the existing launch time performance (cold start to interactive under 400ms)
- **SC-005**: All app interactions respond within 100ms and animations maintain 60fps — no performance regression from the UI revamp
- **SC-006**: 100% of existing snapshot tests are updated and passing with the new visual design
- **SC-007**: All app screens pass accessibility audit (VoiceOver navigable, Dynamic Type supported, contrast ratios meet WCAG AA)
- **SC-008**: The Lunar color palette is used consistently — zero instances of hardcoded colors outside the theme system in both the landing page and the app

## Assumptions

- The landing page will be built as a standalone web project (separate from the iOS app codebase) using modern web technologies
- The landing page's default appearance is dark mode, matching the lunar theme, with light mode as an alternative
- Apple's Liquid Glass effect is available on iOS 26+ (introduced with the new design language); older versions will use the existing custom glassmorphism fallback
- The existing app architecture (MVVM, theme system, component structure) will be preserved — this is a visual refresh, not an architectural rewrite
- The PARA category colors may be adjusted from the current palette to better align with the Lunar theme, while maintaining sufficient distinction between categories
- The Syne font (currently used for display text) will be retained or replaced with a font that better fits the lunar aesthetic — the decision will be made during planning
- No new app features are being added — this is purely a visual and interaction design update to the existing screens and components
- The bento grid on the landing page will contain 4–6 feature cards; exact content will be determined during planning
