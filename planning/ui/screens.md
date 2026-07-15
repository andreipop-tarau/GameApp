# Screen and interaction specifications

## Existing UI disposition

| Screen/component | Current state | Action |
|---|---|---|
| `MaterialApp.router`, GoRouter routes, Riverpod ownership | Small and functional | **Keep** boundaries; add mode routes incrementally |
| Home | Generic AppBar and two buttons | **Restructure** around Troll Gauntlet, Calm, Rush, recent best, progression |
| Gameplay screen/controller wiring | Owns ticker, lifecycle, result state | **Adapt** ownership to v2 runtime; replace AppBar/padded quiz layout |
| Result panel | Card with `Again`/`Home` | **Replace** presentation; keep state-local immediate replay concept |
| Profile | Accessible but card-heavy five-skill dashboard | **Restyle** and subordinate Brain Profile to mastery/progression |
| Challenge widgets | Button/grid/text quiz presentation | **Replace or migrate** per catalog audit; preserve rules/tests where named |
| Theme | Minimal indigo seed | **Replace** with semantic light/dark tokens |
| Settings/onboarding/cosmetics/runners | Not implemented | **Defer** until assigned milestones |

## Launch and bootstrap

Static brand mark/Trapling and bounded local progress only; no artificial delay. Load versioned config/save and route to first-session interaction or Home. Corrupt save recovery never silently resets data. Network is not required.

## First-session onboarding

Teach by play, not pages. Start with an unmodified forgiving Stop the Machine round, a visible tap demonstration, immediate feedback, and one short failure explanation. Introduce the full genuine-tell pattern only after basic success, then show one fake signal that cannot copy the whole pattern. No feature carousel, account gate, permission wall, or complete-system tour.

## Home and mode access

One prominent `Play Troll Gauntlet` action is reachable from launch. Calm Run and Rush Run are distinct secondary actions. Show recent personal best and one progression summary without a card dashboard. Profile, cosmetics, statistics, settings, and accessibility are accessible but secondary. Offline state never disables core modes.

An optional mode-selection sheet may explain duration/control once; returning players start the selected mode directly. Do not add an extra mandatory screen between Home and Troll Gauntlet.

## Troll Gauntlet

Full-screen portrait scene with minimal permanent UI: short instruction at top, small lives/round pressure indicator, central interaction, and pause/exit affordance outside active regions. No persistent panels or analytics. Input-open, active, accepted/rejected, success/failure, troll reveal, and transition use the shared framework.

### Microgame introduction

First exposure is unmodified and forgiving. Show one gesture demonstration in the play area; dismiss it on first valid input. It is clearly practice if failure will not cost a life.

### Active input and troll reveal

The object under touch responds immediately. Genuine changes use the full central tell. Fake content never reproduces it. Reveal names the trick only after resolution and disappears automatically or on immediate continuation.

### Success, failure, transition

Success is satisfying but under 450 ms. Failure freezes relevant state, states the cause, uses a short funny Trapling reaction, then continues/retries without a dialog. Transitions stay under 350 ms. Boss entry may use a distinct but short title beat; `The App Is Broken` remains inside the game scene and never imitates system UI.

## End-of-run results and retry

Prioritize score, personal-best comparison, furthest round, one insight, and the dominant `Play Again` action. Show one progression/cosmetic unlock only when meaningful. Home/share/details are secondary. Do not show a large analytics dashboard or a store offer after failure.

## Calm Run

Open composition, automatic movement, minimal text, soft density changes, predictable obstacles, and gradual visual cooldown. Collision uses a non-aggressive rewind/bounce/slowdown with no death screen. Pause, sound/music/haptic controls, and reduced motion remain reachable; score pressure is absent.

## Rush Run

Clear obstacle silhouettes, stronger speed/rhythm feedback, compact distance/combo, controlled camera response, and immediate restart after a terminal collision. Effects cannot hide collision boundaries. Results emphasize distance and personal-best delta.

## Progression and cosmetics

Progression shows one clear level/mastery path and focused unlocks. Cosmetic inventory uses large previews and direct Trapling manipulation/equip where practical. Avoid multiple currencies, overlapping bars, notification badges, fake urgency, or dominant store placement.

## Profile

Show identity/Trapling, level, key personal bests, per-game mastery/tell familiarity, then optional historical Brain Profile detail with honest confidence. Use whitespace and grouped rows/visuals rather than one card per metric. No diagnostic or intelligence claims.

## Settings and accessibility

Provide theme/system choice, reduced motion, haptics, separate music/effects, text/accessibility guidance, contrast-safe mode if needed, pause behavior, privacy/legal/version, and reset/recovery with confirmation. Changes apply immediately and persist. Controls have clear labels, focus order, and 44x44 minimum targets.

## Generic loading, empty, and error behavior

Core play uses bundled content and near-instant generation. Loading indicators appear only for real bounded work. Empty states explain the next useful action. Errors use safe stable wording, retry/escape, and preserve prior data. Invalid plans retry once with a known-safe eligible plan, then stop the run without granting or losing progress.
