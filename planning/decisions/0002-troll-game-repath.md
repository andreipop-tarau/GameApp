# ADR 0002: Repath to Troll Gauntlet and Flow Run modes

- **Status:** Accepted for planning and incremental implementation.
- **Date:** 2026-07-15.

## Context

Tasks 001-014 delivered a small deterministic Flutter brain-training loop with five quiz-like modules, AI Director, Brain Profile, local persistence, XP, and navigation. Task 015 lifecycle implementation landed but its final automated/manual verification is uncertain. The product is now required to become a fast, funny direct-manipulation game centered on troll microgames, with separate Calm and Rush runners and a premium restrained shell.

The current architecture is valuable, but the single-terminal-action contract, fixed legacy module enum/config, per-round result cadence, and generic card/button UI conflict with the target.

## Decision

1. Use **incremental migration** as the primary repath strategy.
2. Introduce a pure Dart microgame v2 contract/runtime beside the legacy challenge path; migrate the first vertical slice, then the full catalog, then remove the old main path.
3. Make Troll Gauntlet primary with three lives, a 24-round cap, rapid 5-15 second games, one major modifier per normal round, recovery rules, and one rare late boss.
4. Validate the first slice with Stop the Machine (tap, migrated from Timing Stop) and Hold It (hold, new) because together they maximize reuse and prove discrete plus continuous input.
5. Adapt the deterministic AI Director for microgame/gesture/modifier metadata and keep its target success band explicitly hypothetical.
6. Keep Brain Profile/XP/save data. Add per-game mastery, personal bests, and settings with active consumers through a tested additive v2 migration only after the primary-loop gate; add cosmetic state with the later cosmetic feature.
7. Build one portrait-first Flow Run foundation later for Calm Run and Rush Run; do not treat it as a fourth player-facing mode.
8. Define and validate the semantic visual/tell system on Home and the first two microgames before expanding it.
9. Defer backend, daily competition, real-money purchases, and LiveOps until the local three-mode product proves retention and fairness.

## Repath delta

| Area | Current | Target | Action |
|---|---|---|---|
| Architecture/state/navigation | Flutter, Riverpod, GoRouter, feature-first | same boundaries | **Keep** |
| Determinism/config | injected clock/random, strict v1 config | namespaced seeds, v2 microgame/modifier config | **Adapt** |
| Five challenge modules | working deterministic quiz-like rounds | ten direct microgames plus rare boss | **Migrate/Adapt/Defer** per catalog audit |
| Session | endless round/result/retry | three-life finite Gauntlet and concise run result | **Replace** run policy; **Keep** idempotent ownership seams |
| AI Director | legacy enum/category selection | gesture/intro/modifier/recovery/boss policy | **Adapt** |
| Brain Profile/XP | implemented and persisted | preserved secondary data plus mastery/PBs | **Migrate** |
| Local save | strict schema v1 | additive schema v2 with v1 migration | **Migrate** |
| Lifecycle | landed, verification uncertain | mode-specific pause/abandon with full tests | **Adapt/Reverify** |
| UI | generic Material, card/button/grid heavy | original restrained shell and expressive scenes | **Replace/Restyle** |
| Cloud/competition/economy roadmap | planned immediately after M0 | gated by local product evidence | **Defer** |
| Legacy main session | active | v2-only Troll Gauntlet | **Remove** in Task 061 after Task 056 validation |

## Transition and rollback

The legacy catalog remains buildable and its tests stay intact through Task 056. New microgames do not depend on legacy widgets. Task 061 removes the unreachable legacy main-session path after cutover but retains pure legacy identifiers/rules needed for compatibility. Before save schema v2, new work uses in-memory state or existing fields only. A failed vertical-slice playtest can disable the new route and return to the legacy route without data migration. After Task 057 writes v2, rollback must retain a readable backup/compatibility strategy and may not silently downgrade or reset user data.

## Risks and controls

- **Dual architecture lingers:** Task 056 owns main-path cutover and Task 061 removes unreachable legacy session/UI; pure legacy IDs remain only for compatibility until Task 057 and an explicit secondary-content decision.
- **Continuous gestures expose timing/lifecycle defects:** Task 047 establishes ordered monotonic events; Hold It and Gate G1 prove cancellation.
- **Visual redesign expands before validation:** Milestone R1 limits code application to Home plus two microgames.
- **Old saves become unreadable:** Task 057 owns frozen v1 fixtures and additive migration; no earlier schema edits.
- **Trolls feel unfair:** central tell language, plan validators, one-modifier cap, stable failure reasons, and manual recognition testing are release gates.
- **Runner scope dilutes the primary mode:** Flow Run begins only after the complete normal Gauntlet catalog and vertical-slice system are validated.

## Conditions requiring strategy review

Switch from incremental migration only if the v2 contract cannot coexist without changing legacy behavior, or profiling shows Flutter's normal rendering/touch stack cannot meet the documented budgets. Either finding requires a new ADR; it does not authorize an ad hoc rewrite or game-engine dependency.
