# Visual and interaction design system

## Direction

MindTrap AI uses premium mobile clarity, restraint, fluidity, and precise direct manipulation without copying Apple or any game. The shell is calm, spacious, and typographically disciplined. Active microgames use bold silhouettes, physical reactions, and controlled bursts of absurdity. Humor comes from Traplings, objects, motion, sound, and failure explanations—not from cluttering every screen.

Avoid clinical brain-training presentation, generic Material defaults, card dashboards, cheap hyper-casual/neon styling, children's educational styling, excessive gradients/glow/borders/badges, and a different visual gimmick on every screen.

### Active-slice implementation boundary

R1 implements only semantic light/dark colors, the minimum type/spacing/radius tokens, primary/secondary actions, gameplay safe area, genuine/fake instruction frame and symbol, pressed/held feedback, and reduced-motion substitutions consumed by Home, Stop the Machine, Hold It, and the slice result. The rest of this document remains the authoritative future design direction, not permission to build unused components, audio/haptic services, asset systems, particles, complete screen families, cosmetic themes, or a broad animation framework before Gate G2.

## Brand and shape language

Traplings are rounded geometric creatures with simple silhouettes, two or three expressive facial features, and transformations into absurd everyday objects. Use circles, soft rectangles, broken-circle marks, and one controlled angular accent for hazards. Expressions and motion may be exaggerated in gameplay; shell icons and controls remain restrained.

The signature symbol is a **broken circle with a centered notch**. In the complete genuine-tell pattern it appears with a stable instruction frame and a short inward-settle motion. Never use a system icon or imitate operating-system UI as the tell.

## Semantic color tokens

Define complete light and dark values for:

`background`, `surface`, `surfaceElevated`, `textPrimary`, `textSecondary`, `actionPrimary`, `success`, `warning`, `failure`, `instructionGenuine`, `instructionDeceptive`, `disabled`, `focus`, `calmMode`, and `rushMode`.

Neutral backgrounds and surfaces dominate shell screens. Saturated color is reserved for the primary action, game events, and mode identity. Genuine and deceptive instructions differ through shape/icon/placement as well as color. Every meaningful pairing meets WCAG AA contrast. Gradients are limited to environments, progression emphasis, or a single hero region—never every surface.

## Typography

Use the platform/system sans-serif initially; adopt a shipped font only after licensing, memory, and legibility validation.

| Token | Use |
|---|---|
| `displayTitle` | launch/home identity, rare |
| `screenTitle` | shell hierarchy |
| `gameInstruction` | one-to-four-word objective, usually large and bold |
| `resultScore` | score/personal best |
| `sectionHeading` | grouped secondary content |
| `body` | normal explanations |
| `supporting` | secondary/context text |
| `compactLabel` | small but non-critical labels |
| `numericTimer` | tabular, stable-width time/score |

All styles have accessibility-expanded variants. Avoid decorative fonts, dense paragraphs, and all caps except short gameplay commands such as `HOLD` or `STAY INSIDE`. At large text, shell content scrolls/reflows; gameplay instruction remains visible without covering the play region.

## Spacing, sizing, and layout

- Base spacing: 4; core tokens: 4, 8, 12, 16, 24, 32, 48.
- Portrait screen margins: 20 logical pixels compact, 24 regular; safe areas always applied.
- Touch targets: minimum 44x44, preferred 48x48; primary actions are thumb reachable.
- Corner radii: 8 for compact controls, 14 for buttons/sheets, 20 for hero surfaces; pills only for true tags/toggles.
- Tablet layouts center a bounded portrait play canvas; they do not stretch mechanics.
- Avoid nested containers. Use cards only for meaningful grouping or depth, not every section.

## Surfaces and depth

Use tonal separation and one or two soft elevation levels. Dragged objects may gain a focused shadow and slight scale/deformation. Blur/translucency is reserved for an occasional modal overlay when readable and performant; never blur every surface or the active playfield.

## Icons and symbols

Use a small original/system-compatible icon vocabulary with visible text where meaning is not universal. Do not copy proprietary icon sets. Required gameplay symbols include genuine tell, fake/distraction, pause, sound, haptic, reduced motion, success, failure, combo, boss, Calm, and Rush. Gameplay meaning always has a text/shape or semantic equivalent.

## Interaction states

Every shared interactive object defines `idle`, `proximity` where supported, `pressed`, `held`, `dragged`, `released`, `accepted`, `rejected`, and `disabled`. Feedback begins under the finger by the next rendered frame through a restrained combination of scale/deformation, position, depth, optional sound, and optional haptic. Do not bounce every button.

Controls react continuously during holds/drags/traces. Momentum and snapping must be predictable and deterministic when gameplay-relevant. Avoid submit buttons, normal-play confirmations, delayed input feedback, small unexplained icon actions, nested menus, and artificial loading.

## Shared gameplay presentation

The framework owns safe area, instruction frame, input-open signal, pressure/timer placement, pause/abandon, feedback overlay, failure explanation, transition, reduced-motion substitutions, sound/haptic hooks, semantic announcements, and large-text behavior. A microgame owns its scene, objects, deterministic movement, and typed input translation.

Within about one second the player must know which object matters, what action is expected, whether input is open, whether input was accepted, and why a terminal result occurred.

## Genuine and deceptive instruction language

A genuine instruction change always combines at least four stable signals:

1. broken-circle-with-notch icon;
2. asymmetric notched instruction frame;
3. fixed top-center placement outside the play region;
4. short inward-settle motion or reduced-motion state change;
5. optional two-note sound and light double haptic.

A fake instruction may imitate only one of these signals and must never reproduce the complete pattern. Screen readers announce `Real instruction changed:` before genuine text and `Distraction:` for accessible fake content. Tells never depend only on color, sound, text size, subtle motion, or a tiny symbol.

## Motion and transitions

Motion is brief, causal, interruptible where appropriate, deterministic when gameplay-relevant, and replaceable under reduced motion.

- Screen hierarchy: 180-240 ms spatial slide/fade.
- Modal/sheet: 150-220 ms scale/fade.
- Input opening/genuine change: 120-180 ms settle/state change.
- Pickup/drop/snap: direct tracking plus 80-160 ms settle.
- Success/failure/troll reveal: 180-450 ms; never blocks retry beyond the pacing budget.
- Between microgames: quick scene replacement under 350 ms.
- Results: controlled content expansion; runner segments use smooth environmental continuity.

Use a shared-object transition only when it clarifies the relationship between home/mode and play. Avoid long entrances, constant floating elements, uncontrolled springs, decorative movement, and transitions that move important controls unpredictably.

Reduced motion replaces camera movement, large translation, shake, parallax, and particles with fades, border/state changes, shorter translation, and static cause/effect indicators. It does not remove useful feedback.

## Haptic vocabulary

Optional patterns: light confirmation, pickup, snap, genuine instruction change, round success, round failure, runner collision, boss event, and personal best. Strong vibration is rare and never used for every tap. Haptics can be disabled independently.

## Sound vocabulary

Define short object/contact sounds, success and failure motifs, troll reveal, genuine-change signal, combo steps, boss introduction, Calm ambience, and Rush rhythm layers. Music, effects, and haptics have separate controls. Gameplay remains understandable when muted. Original motifs/assets require license and memory records.

## Reusable components

Create only after two real uses or central consistency need: app shell, primary/secondary/text action, icon action with label/tooltip, mode hero, instruction frame, genuine-tell badge, gameplay safe area, pressure indicator, feedback layer, compact failure explanation, score/ personal-best block, progression meter, cosmetic preview, setting row, bottom sheet, pause/exit sheet, loading/error/empty state, and accessible countdown.

## Light and dark themes

Both themes use the same hierarchy, semantic roles, tell shapes, touch sizes, and interaction behavior. Dark mode avoids pure-black/pure-white glare and preserves obstacle/tell separation. Cosmetics are validated against both themes; unsupported cosmetic contrast falls back to the default outline.

## Performance budgets

Initial measurable budgets, revised only from profile evidence:

- 60 FPS target; representative low-end Android p95 build/raster frame stays within the 16.7 ms budget.
- Visible input response appears by the next frame and manual observed latency remains under 50 ms.
- No real-time blur in active gameplay; at most one blurred shell/modal layer.
- Normal rounds show at most 8 independently animated gameplay actors; bosses at most 12 after profiling.
- Transient particles are capped at 24 and disabled/replaced in reduced motion.
- Raster assets are decoded near displayed size, large atlases are avoided, and representative asset memory/battery use is profiled before catalog expansion.
- Prewarm only proven shaders/transitions; first-use jank is a validation failure.

## Validation gates

Validate the tokens and interaction language on Home plus Stop the Machine and Hold It before restyling the full app or implementing the remaining catalog. Manual checks cover premium visual quality, one-second objective comprehension, one-handed reach, hit accuracy, next-frame feedback, genuine-tell recognition, reduced motion, color/sound independence, 200% text, light/dark themes, low-end Android performance, rapid transitions, first-session teaching, and consistency across modes.
