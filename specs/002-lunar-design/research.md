# Research: Lunar Design System — Landing Page & App UI Revamp

**Date**: 2026-02-10
**Feature**: 002-lunar-design

## 1. Astro for Static Landing Page

### Decision
Use **Astro 5.x** for the landing page — a static-first web framework that ships zero JavaScript by default.

### Rationale
- **Performance**: Astro outputs pure HTML/CSS for static pages, meeting the Lighthouse 90+ target
- **Familiar**: The project previously had an Astro-based landing page (deleted in git history) with i18n, Formspree, and Tailwind
- **Islands architecture**: Only hydrate interactive components (theme toggle, contact form), keeping JS payload minimal
- **User explicitly requested Astro** for the landing page

### Alternatives Considered
| Alternative | Rejected Because |
|-------------|------------------|
| Next.js | SSR overhead unnecessary for a static landing page; heavier JS bundle |
| Plain HTML/CSS | No templating, component reuse, or build-time optimization |
| Nuxt | Vue ecosystem not present in project; overkill for static content |

---

## 2. CSS Approach: Tailwind CSS v4

### Decision
Use **Tailwind CSS v4** for landing page styling — utility-first CSS framework.

### Rationale
- **Rapid iteration**: Utility classes enable fast visual experimentation during design work
- **Dark mode**: Built-in `dark:` variant maps directly to the landing page's dark/light mode requirement
- **Responsive**: Built-in `sm:`, `md:`, `lg:` breakpoints for bento grid responsiveness
- **Previous landing page** already used Tailwind (postcss.config.cjs existed in git history)
- **Purging**: Tailwind v4 produces minimal CSS by scanning only used utilities

### Alternatives Considered
| Alternative | Rejected Because |
|-------------|------------------|
| Vanilla CSS | Slower iteration, no utility classes for responsive/dark mode |
| CSS Modules | Good for components but doesn't scale as well for a single-page marketing site |
| Styled Components | Requires React runtime; contradicts Astro's static-first approach |

---

## 3. Scroll-Triggered Micro-Transitions

### Decision
Use **Intersection Observer API** with minimal vanilla JS for scroll-triggered reveals. CSS-only for hover/interactive states.

### Rationale
- **No library dependency**: IntersectionObserver is native browser API, lightweight
- **Performance**: CSS `transform` and `opacity` animations are GPU-accelerated
- **Reduced Motion**: Easy to check `prefers-reduced-motion` in both CSS and JS
- **Astro compatible**: Works with static HTML output; no framework needed
- Pattern: Add a `.reveal` class to sections, observe with IntersectionObserver, toggle `.visible` class

### Alternatives Considered
| Alternative | Rejected Because |
|-------------|------------------|
| GSAP/ScrollTrigger | 65KB+ library for subtle entrance animations is overkill |
| Framer Motion | Requires React; Astro page is static |
| CSS scroll-timeline | Browser support still incomplete in 2026; Safari partial |
| AOS library | Adds dependency for something achievable in ~30 lines of JS |

---

## 4. Formspree for Contact/Waitlist Form

### Decision
Use **Formspree** for form handling — HTML form with `action` attribute pointing to user-provided Formspree URL.

### Rationale
- **Zero backend**: No server code needed; form submits directly to Formspree
- **Previous implementation**: The old landing page already used Formspree with `waitlistActionUrl` config
- **User explicitly chose Formspree** and will provide the URL
- **Progressive enhancement**: Works without JS (HTML form action); enhanced with fetch API for AJAX submission

### Implementation Pattern
- HTML `<form action="https://formspree.io/f/{id}" method="POST">` as base
- Optional JS enhancement: intercept submit, use `fetch()`, show inline success/error feedback
- Honeypot field for spam prevention (same pattern as previous landing page)
- Hidden UTM fields for marketing attribution

---

## 5. Landing Page Typography

### Decision
Use **Syne** (variable font) for display headings and **Inter** (variable font) for body text on the landing page.

### Rationale
- **Syne** is already the iOS app's display font (bundled at `Luno/Resources/Fonts/Syne-Variable.ttf`); using it on the landing page creates cross-platform brand consistency
- **Inter** is an excellent body typeface: highly legible, variable weight support, Google Fonts hosted for fast CDN loading
- Both are variable fonts — single file covers all weights, reducing HTTP requests
- The geometric, modern character of Syne pairs well with the lunar aesthetic

### Alternatives Considered
| Alternative | Rejected Because |
|-------------|------------------|
| Space Grotesk + Inter | Space Grotesk is similar to Syne but breaks brand consistency with the app |
| Clash Display + Satoshi | Strong pairing but not aligned with existing app typography |
| System fonts only | Would lose brand identity; Syne is part of Luno's visual DNA |

---

## 6. Apple Liquid Glass in SwiftUI (iOS 26+)

### Decision
Adopt a **dual-path approach** in `LunoChrome.swift`: use `.glassEffect()` on iOS 26+, fall back to existing `.ultraThinMaterial` + surface fill for iOS 17-25.

### Rationale
- **Single modifier, automatic upgrade**: The existing `lunoGlassSurface()` modifier is used consistently across all views. Updating it once upgrades the entire app
- **Liquid Glass APIs**: `.glassEffect(_:in:isEnabled:)` modifier, `GlassEffectContainer` for grouped elements
- **Tab/nav bars**: iOS 26 automatically applies Liquid Glass to system chrome; remove forced toolbar backgrounds via `#available(iOS 26, *)` in `lunoTabChrome()` and `lunoNavChrome()`
- **Refraction**: `LunoBackgroundView`'s gradient + ambient glow circles become the refraction source, creating depth naturally

### Alternatives Considered
| Alternative | Rejected Because |
|-------------|------------------|
| Requiring iOS 26 minimum | Too early; drops iOS 17-25 users |
| Separate code paths per view | `lunoGlassSurface()` already centralizes this |
| Keeping `.ultraThinMaterial` only | Misses the platform's design evolution on iOS 26 |

---

## 7. Color Palette Migration Strategy

### Decision
Keep colors **code-defined** in `LunoColors.swift`. Adjust hex values within existing `Color.adaptive(light:dark:)` calls. Increase surface transparency to let Liquid Glass refraction show through.

### Rationale
- Code-defined colors are easier to version control (diffs show hex changes)
- The `adaptive()` helper already provides light/dark switching equivalent to asset catalogs
- Central `LunoColors` enum means palette change is a single-file edit
- PARA colors may need increased hue spread (Archive and Project are both blue-family; under glass refraction they could blur together)

### Key Changes Planned
- **Surfaces**: Reduce opacity of `surface1`/`surface2` to let background gradient bleed through glass
- **PARA colors**: Evaluate shifting Archive toward cooler slate or Project toward teal for better distinction under glass
- **Gradients**: Harmonize `appGradient`, `heroGradient`, `lunarGradient` with the refined Lunar palette
- **Landing page CSS variables**: Mirror `LunoColors` hex values as CSS custom properties for web/app consistency

### Alternatives Considered
| Alternative | Rejected Because |
|-------------|------------------|
| Asset Catalog colors | Adds parallel system without benefit; harder to diff |
| Separate LiquidGlassColors variant | Over-complicates; adaptive() already handles mode switching |
| Complete palette redesign | Current lunar blues are already well-aligned; refinement, not replacement |

---

## 8. Snapshot Testing Strategy for UI Revamp

### Decision
**Batch regeneration** after all visual changes land. Use existing `SNAPSHOT_TESTING_RECORD=all` environment variable mechanism.

### Rationale
- Incremental snapshot updates during a visual overhaul create churn
- 29 snapshot images across 5 test files — batch update is fast
- Existing env-var pattern (`ProcessInfo.processInfo.environment["SNAPSHOT_TESTING_RECORD"] == "all"`) already supports this workflow

### Post-Regeneration Workflow
1. Complete all visual changes across LunoColors, LunoChrome, LunoTheme, and component views
2. Run all snapshot tests with `SNAPSHOT_TESTING_RECORD=all`
3. Visually inspect new reference images in PR diff
4. Remove env var, run tests again to verify pass
5. Commit new snapshots alongside code changes

---

## 9. Animation Refinements

### Decision
Refactor recording pulse to **PhaseAnimator** (iOS 17+). Add **matchedGeometryEffect** for NoteCard-to-NoteDetail transitions. Add **contentTransition(.numericText())** on folder counts.

### Rationale
- `PhaseAnimator` simplifies `RecordButton` pulse code (currently manual `withAnimation` + `repeatForever`)
- `matchedGeometryEffect` provides spatial continuity aligned with Liquid Glass design philosophy
- `contentTransition(.numericText())` adds polish to folder count changes
- All existing spring presets (`buttonPress`, `cardReveal`, etc.) are well-tuned and should be preserved

### Alternatives Considered
| Alternative | Rejected Because |
|-------------|------------------|
| TimelineView for recording | Overkill; PhaseAnimator is the right abstraction |
| Full KeyframeAnimator everywhere | Too complex for most use cases |
| Custom CADisplayLink animations | SwiftUI animations are sufficient and more maintainable |

---

## 10. Bento Grid Layout Pattern

### Decision
Use **CSS Grid with `grid-template-areas`** for the landing page bento layout, with responsive breakpoint adjustments.

### Rationale
- `grid-template-areas` provides named regions that make responsive reflow intuitive
- Asymmetric cell sizes (2x2, 1x2, 2x1, 1x1) are natural with named areas
- Mobile (320px): single column stack. Tablet (768px): 2-column. Desktop (1440px+): 3-4 column
- Tailwind's grid utilities (`grid-cols-*`, `col-span-*`, `row-span-*`) provide clean abstractions

### Pattern
```
Desktop (1440px+):     Tablet (768px):      Mobile (320px):
┌─────────┬─────┐      ┌─────┬─────┐       ┌─────────┐
│ 2x2     │ 1x1 │      │ 2x1       │       │ Card 1  │
│ Hero    │     │      ├─────┼─────┤       ├─────────┤
│         ├─────┤      │     │     │       │ Card 2  │
│         │ 1x1 │      │     │     │       ├─────────┤
├────┬────┼─────┤      ├─────┼─────┤       │ Card 3  │
│ 1x1│ 1x1│ 1x2 │      │ 2x1       │       └─────────┘
└────┴────┴─────┘      └───────────┘
```

---

## Sources

### Astro & Web
- [Astro Documentation](https://docs.astro.build)
- [Tailwind CSS v4 Docs](https://tailwindcss.com/docs)
- [Formspree Documentation](https://formspree.io/docs)
- [Intersection Observer API](https://developer.mozilla.org/en-US/docs/Web/API/Intersection_Observer_API)

### Apple & iOS
- [Meet the Foundation Models framework - WWDC25](https://developer.apple.com/videos/play/wwdc2025/286/)
- [Apple Human Interface Guidelines - Materials](https://developer.apple.com/design/human-interface-guidelines/materials)
- [SwiftUI Animation Documentation](https://developer.apple.com/documentation/swiftui/animation)
- [swift-snapshot-testing by Point-Free](https://github.com/pointfreeco/swift-snapshot-testing)

### Typography
- [Syne on Google Fonts](https://fonts.google.com/specimen/Syne)
- [Inter on Google Fonts](https://fonts.google.com/specimen/Inter)
