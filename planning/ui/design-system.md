# Design system

## Experience direction

Portrait-first, one-handed, high-contrast, quick, and calm under pressure. Gameplay information takes priority over decoration. Cosmetic themes may change surfaces/effects but never hitboxes, timing visibility, semantic meaning, or readable contrast.

## Foundations

- Use semantic color tokens (`surface`, `onSurface`, `primary`, `success`, `danger`, `warning`, `focus`) rather than raw colors in features.
- Use a compact type scale with system text scaling supported to at least 200% outside timing-critical canvases. Critical instructions remain readable and may reflow.
- Base spacing grid: 4; common values 8, 12, 16, 24, 32.
- Minimum interactive target: 44×44 logical pixels; primary bottom actions should be thumb reachable.
- Rounded corners, elevation, motion, haptics, and audio use centralized tokens/services.
- Portrait is required for launch. Tablet layouts center a bounded play area rather than stretching mechanics.

## Reusable components

Primary/secondary/text buttons, icon button, app scaffold, status banner, loading placeholder, empty state, retry panel, stat card, progress bar, currency badge, offer card, leaderboard row, setting tile, modal confirmation, and accessible countdown.

Create a component only after two real uses or when consistency/accessibility requires central ownership.

## Motion and feedback

Normal transitions are 150–250 ms; result feedback stays under one second. Input feedback is immediate. Respect reduced motion by removing scaling/shake/parallax and using opacity/static state. Haptics and audio follow settings and platform capabilities. Never use shake alone to explain failure.

## Accessibility acceptance

- WCAG AA contrast for text and meaningful controls.
- Screen-reader labels, roles, values, and logical focus order.
- Color-independent game cues and captions/text alternatives for audio cues.
- Dynamic text and bold-text settings do not hide actions.
- Reduced motion and disabled haptics/audio are honored.
- Challenge modules document any remaining limitation before merge.

## Assets

Prefer vector/simple programmatic UI for stable interface elements and optimized raster assets for cosmetics. Asset names are lowercase descriptive paths. Every shipped asset has ownership/license recorded when applicable and an intended resolution/density strategy.
