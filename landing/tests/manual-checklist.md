# Manual QA Checklist

## Story + rendering

- [ ] All folds render in order: hook, reveal, para-map, proof-flow, finale.
- [ ] No scene looks visually empty at 1440px, 1024px, 768px, and 390px widths.
- [ ] Hero CTA, PARA bridge CTA, and final submit CTA are visible and route correctly.
- [ ] First visit defaults to dark, then follows persisted `luno-theme` choice.
- [ ] Theme toggle changes between dark/light and persists after reload.

## Locale behavior (auto only)

- [ ] Browser locale `pt-*` renders PT-BR copy.
- [ ] Browser locale `en-*` renders EN copy.
- [ ] Unsupported locale falls back to PT-BR.
- [ ] No visible language switcher in header or footer.

## Conversion

- [ ] Hero and trust CTAs trigger `hero_cta_click` event.
- [ ] Valid email submit shows inline success state.
- [ ] Invalid email shows accessible error (`aria-live`).
- [ ] Honeypot filled prevents submission.

## Scene analytics

- [ ] `landing_view` fires on load.
- [ ] `story_scene_view` fires once per fold with scene id in: `hook`, `reveal`, `para-map`, `proof-flow`, `finale`.
- [ ] `theme_toggle` fires with `from` and `to`.
- [ ] `waitlist_submit_start/success/error` fire in expected paths.

## UTM preservation

- [ ] Open with `?utm_source=x&utm_campaign=y`.
- [ ] Hidden form fields include those values.
- [ ] Internal links with `data-preserve-utm` retain params.

## Motion and fallbacks

- [ ] Desktop: micro-transitions, reveal stagger, and tilt/parallax-lite are active.
- [ ] Mobile (`<=900px`): heavy effects are disabled, content remains polished.
- [ ] `prefers-reduced-motion: reduce`: no heavy animated loops/parallax.

## Accessibility and performance

- [ ] Keyboard focus is visible on links, inputs, and buttons.
- [ ] Text contrast passes AA.
- [ ] Lighthouse mobile >= 95; LCP < 2.5s; CLS < 0.1.
