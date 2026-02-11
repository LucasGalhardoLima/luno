# Data Model: Lunar Design System

**Feature**: 002-lunar-design
**Date**: 2026-02-10

This feature is primarily a visual/design update — no new persistent data models are introduced. The data model focuses on the **design token entities** shared between the landing page and the iOS app.

## 1. Lunar Color Palette (Design Token Entity)

The unified color system used across landing page (CSS variables) and iOS app (LunoColors.swift).

### Token Categories

| Token Category | Tokens | Description |
|----------------|--------|-------------|
| **Backgrounds** | `bg-0`, `bg-1`, `bg-2` | Three-tier gradient background (darkest → lightest depth) |
| **Surfaces** | `surface-1`, `surface-2` | Translucent card/panel fills with alpha for glass effect |
| **Brand** | `brand-600`, `brand-500`, `moon-400` | Primary action blue, secondary blue, lavender accent |
| **Text** | `text-0`, `text-1`, `text-2` | Primary, secondary, accent text hierarchy |
| **Lines** | `line-soft` | Subtle border/stroke color |
| **Glow** | `glow-soft`, `glow-strong` | Diffused glow effects for depth |
| **PARA** | `para-project`, `para-area`, `para-resource`, `para-archive`, `para-uncategorized` | Category-specific accent colors |
| **State** | `state-success`, `state-warning`, `state-error` | Semantic feedback colors |
| **Gradients** | `gradient-app`, `gradient-hero`, `gradient-lunar`, `gradient-voice-button` | Named gradient definitions |

### Mapping: CSS ↔ Swift

Each token maps 1:1 between the landing page and app:

| CSS Variable | LunoColors Property | Light Value | Dark Value |
|---|---|---|---|
| `--bg-0` | `bg0` | `#EEF3FF` | `#020617` |
| `--bg-1` | `bg1` | `#E4ECFF` | `#0F172A` |
| `--bg-2` | `bg2` | `#D5E3FF` | `#172554` |
| `--surface-1` | `surface1` | `rgba(255,255,255,0.78)` | `rgba(15,23,42,0.72)` |
| `--surface-2` | `surface2` | `rgba(255,255,255,0.92)` | `rgba(15,23,42,0.92)` |
| `--brand-600` | `brand600` | `#2563EB` | `#3B82F6` |
| `--brand-500` | `brand500` | `#3B82F6` | `#60A5FA` |
| `--moon-400` | `moon400` | `#4F46E5` | `#A5B4FC` |
| `--text-0` | `text0` | `#0F172A` | `#EFF6FF` |
| `--text-1` | `text1` | `#334155` | `#9FB4D4` |
| `--text-2` | `text2` | `#1E293B` | `#DBEAFE` |

*Note: Surface opacity values may be adjusted during implementation to optimize Liquid Glass refraction on iOS 26.*

## 2. Bento Card (Content Entity)

Represents a feature card on the landing page bento grid.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | yes | Unique identifier (e.g., `voice-first`) |
| `title` | string | yes | Card heading (e.g., "Voice-First Capture") |
| `description` | string | yes | Brief description (1-2 sentences) |
| `icon` | string | yes | Icon identifier or SVG reference |
| `size` | enum | yes | `large` (2x2), `wide` (2x1), `tall` (1x2), `standard` (1x1) |
| `accentColor` | string | no | Optional accent from the palette (defaults to brand-500) |

### Planned Bento Cards

| Card | Size | Content |
|------|------|---------|
| Hero/Voice-First | large (2x2) | "Speak your mind. Luno captures it." — Voice-first note capture |
| AI Categorization | wide (2x1) | "AI that organizes for you" — Automatic PARA categorization |
| Privacy | standard (1x1) | "100% Private" — On-device processing, no data leaves phone |
| Offline | standard (1x1) | "Works Anywhere" — Full offline capability |
| PARA Native | wide (2x1) | Teaser linking to the PARA section below |

## 3. PARA Category Visual Identity (Design Entity)

| Category | Icon (SF Symbol) | Accent Color (dark) | Description |
|----------|-----------------|---------------------|-------------|
| Project | `target` | `#7DD3FC` (sky) | Active tasks with deadlines |
| Area | `circles.hexagongrid` | `#A5B4FC` (indigo) | Ongoing responsibilities |
| Resource | `bookmark.fill` | `#C4B5FD` (violet) | Reference material |
| Archive | `archivebox.fill` | `#93C5FD` (blue) | Completed/inactive items |
| Uncategorized | `questionmark.circle` | `#F59E0B` (amber) | Needs classification |

*These map to both the landing page PARA section cards and the iOS app's folder/badge system.*

## 4. Landing Page Section Structure

| Section | Order | Content |
|---------|-------|---------|
| **Hero** | 1 | Lunar orb visual, app name, tagline, CTA button |
| **Features Bento** | 2 | 5-6 bento cards showcasing key features |
| **PARA Method** | 3 | Educational section: what PARA is, why Luno chose it, 4 category cards |
| **Social Proof** | 4 | Trust badges (on-device AI, privacy-first, open source) |
| **CTA / Waitlist** | 5 | Formspree contact/waitlist form |
| **Footer** | 6 | Links: privacy, social media, App Store badge |

No database tables, API models, or persistent state is introduced by this feature.
