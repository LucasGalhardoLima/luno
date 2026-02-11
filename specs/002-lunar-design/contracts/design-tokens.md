# Design Token Contract: Lunar Color Palette

**Feature**: 002-lunar-design
**Date**: 2026-02-10

This contract defines the shared design tokens between the landing page (CSS) and the iOS app (Swift). Both implementations MUST use identical color values to ensure visual consistency.

## Token Contract

### Background Tiers

```
Token: bg-0
  CSS: --color-bg-0
  Swift: LunoColors.bg0
  Light: #EEF3FF
  Dark:  #020617

Token: bg-1
  CSS: --color-bg-1
  Swift: LunoColors.bg1
  Light: #E4ECFF
  Dark:  #0F172A

Token: bg-2
  CSS: --color-bg-2
  Swift: LunoColors.bg2
  Light: #D5E3FF
  Dark:  #172554
```

### Surfaces

```
Token: surface-1
  CSS: --color-surface-1
  Swift: LunoColors.surface1
  Light: rgba(255, 255, 255, 0.78)
  Dark:  rgba(15, 23, 42, 0.72)

Token: surface-2
  CSS: --color-surface-2
  Swift: LunoColors.surface2
  Light: rgba(255, 255, 255, 0.92)
  Dark:  rgba(15, 23, 42, 0.92)
```

### Brand

```
Token: brand-600
  CSS: --color-brand-600
  Swift: LunoColors.brand600
  Light: #2563EB
  Dark:  #3B82F6

Token: brand-500
  CSS: --color-brand-500
  Swift: LunoColors.brand500
  Light: #3B82F6
  Dark:  #60A5FA

Token: moon-400
  CSS: --color-moon-400
  Swift: LunoColors.moon400
  Light: #4F46E5
  Dark:  #A5B4FC
```

### Text

```
Token: text-0
  CSS: --color-text-0
  Swift: LunoColors.text0
  Light: #0F172A
  Dark:  #EFF6FF

Token: text-1
  CSS: --color-text-1
  Swift: LunoColors.text1
  Light: #334155
  Dark:  #9FB4D4

Token: text-2
  CSS: --color-text-2
  Swift: LunoColors.text2
  Light: #1E293B
  Dark:  #DBEAFE
```

### PARA Category Colors

```
Token: para-project
  CSS: --color-para-project
  Swift: LunoColors.PARA.project
  Light: #0284C7
  Dark:  #7DD3FC

Token: para-area
  CSS: --color-para-area
  Swift: LunoColors.PARA.area
  Light: #4338CA
  Dark:  #A5B4FC

Token: para-resource
  CSS: --color-para-resource
  Swift: LunoColors.PARA.resource
  Light: #7C3AED
  Dark:  #C4B5FD

Token: para-archive
  CSS: --color-para-archive
  Swift: LunoColors.PARA.archive
  Light: #1D4ED8
  Dark:  #93C5FD

Token: para-uncategorized
  CSS: --color-para-uncategorized
  Swift: LunoColors.PARA.uncategorized
  Light: #EA580C
  Dark:  #F59E0B
```

## Validation Rule

Any change to a color value MUST be applied to both the CSS variable and the Swift property simultaneously. A CI check or manual review should verify parity between `landing/src/styles/tokens.css` and `Luno/Shared/Theme/LunoColors.swift`.

## Accessibility Requirements

All text-on-background combinations MUST meet WCAG 2.1 AA contrast ratio (4.5:1 for normal text, 3:1 for large text):

| Combination | Min Ratio |
|-------------|-----------|
| text-0 on bg-0 | 4.5:1 |
| text-1 on surface-1 | 4.5:1 |
| text-0 on surface-2 | 4.5:1 |
| brand-600 on bg-0 | 3:1 (large text) |
| PARA colors on surface-1 | 3:1 (used as badges, treated as large text) |
