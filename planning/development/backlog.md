# Optimized implementation backlog

This is the only active implementation task index. Product rules live in `planning/product/vision.md`, architecture/contracts in `planning/architecture/` and `planning/gameplay/`, visual rules in `planning/ui/design-system.md`, and measurable gates in `milestones.md`. Tasks reference those decisions instead of restating them.

Use one task at a time. Reuse a coding chat only where the task explicitly recommends it and only after the current-task pointer is advanced externally. Stop at each task boundary.

## Foundation history

Tasks 001-014 are implemented and preserved. Task 015 lifecycle work landed but is verification-uncertain. Historical prompts remain under `planning/tasks/prompts/` and are inactive unless `current-task.md` points to them.

## Superseded repath task map

The original unimplemented repath Tasks 016-046 are superseded, not completed.

| Original task(s) | Revised disposition |
|---|---|
| 016 contract + 017 runtime | Merged into 047 |
| 018 visual foundation | Narrowed into 048 |
| 019 mode routes + 024 slice integration | Merged/narrowed into 052; Calm/Rush routes deferred |
| 020 Stop the Machine | Retained as 049 |
| 021 Hold It | Retained as 050 |
| 022 Director + 023 run model | Merged into 051 |
| 025 Don't Press It | Retained as 053 |
| 026 Escape Button | Deferred to R4 after Gate G2 |
| 027 Protect the Egg | Retained as 054 |
| 028 Feed the Idiot | Deferred to R4 after Gate G2 |
| 029 Wrong Way | Retained as 055 |
| 030 Keep Inside, 031 Parking Disaster, 032 Clean the Screen, 033 boss | Deferred to R4 after Gate G2 |
| 034 full catalog cutover + 035 legacy cleanup | Representative integration in 056; cleanup in 061; full catalog deferred |
| 036 save migration | Retained as 057 |
| 037 mastery/PBs | Retained and presentation-coupled in 058 |
| 038 onboarding | Retained as 060 |
| 039 settings/feedback | Narrowed into 059; production feedback deferred |
| 040 shell/results/profile/cosmetics | Slice shell in 052; results/profile in 058; cosmetics deferred |
| 041-044 Flow Run/Calm/Rush/integration | Deferred to R4 after Gate G2 and stable R3 boundaries |
| 045 production assets | Deferred to R4 |
| 046 beta gate | Replaced by Gate G1, Gate G2, and R3 exit criteria |

## R1 — Two-game Troll Gauntlet vertical slice

### Task 047 — Add the minimal microgame v2 foundation

- **Objective:** Add the pure contract, modifier data contract, and smallest runtime needed by Stop the Machine and Hold It in one pass.
- **Dependencies:** Tasks 003-004 and ADR 0002.
- **Scope:** `microgame.dart`, `troll_modifier.dart`, `microgame_runtime.dart`, one fake fixture, and focused tests. Define stable metadata/plan identity, gesture/event types, normalized required regions, resolution/reason data, one-major-modifier validation, phases, monotonic event ordering, timeout/inactivity hooks, abandon, and idempotent resolution.
- **Constraints:** Pure Dart. Keep the legacy challenge/session path unchanged. Do not add catalog UI, Riverpod, persistence, generic physics/path solvers, executable modifier pipelines, seed-random consumption, or abstractions without an immediate test consumer.
- **Acceptance:** Fake-clock tests cover phase legality, tap and hold event order, cancel/abandon, timeout/inactivity, invalid regions/modifiers, and duplicate terminal events; existing legacy behavior is untouched.
- **Minimum context:** ADR 0002, `challenge-engine.md`, architecture state/lifecycle sections, `challenge.dart`, `round_lifecycle.dart`, `clock.dart`, and their focused tests. Expand only for a concrete type collision.
- **Reasoning/chat:** High. New chat.
- **Stop:** Pure foundation and focused tests only; no real microgame or UI.

### Task 048 — Implement slice-only visual and troll-tell primitives

- **Objective:** Implement only the visual/interaction pieces consumed by Home, Stop the Machine, Hold It, and the slice result.
- **Dependencies:** 047 contracts for instruction state names.
- **Scope:** Semantic light/dark colors, minimal type/spacing/radius tokens, primary/secondary actions, gameplay safe area, genuine/fake instruction frame and broken-circle symbol, immediate pressed/held feedback, and reduced-motion substitutions; add focused widget/semantics tests.
- **Constraints:** No general component library, audio/haptic service, asset pipeline, particles, full screen family, cosmetic theming, broad motion framework, or third-party package.
- **Acceptance:** Tell uses shape/icon/placement plus semantics; fake state cannot request the full genuine pattern; 44x44 targets, 200% shell text, light/dark contrast, and reduced-motion meaning are verified.
- **Minimum context:** `planning/ui/design-system.md`, current `app_theme.dart`, and the current Home/Gameplay widgets only to confirm immediate consumers.
- **Reasoning/chat:** Medium. New chat; 049 may reuse it after pointer advancement if context remains clear.
- **Stop:** Shared slice primitives only; do not restyle unrelated screens.

### Task 049 — Migrate Stop the Machine to v2

- **Objective:** Deliver the first real v2 tap microgame by adapting Timing Stop's proven elapsed-time generator/evaluator.
- **Dependencies:** 047-048.
- **Scope:** One v2 module/scene, registration fixture, deterministic and widget tests. Preserve or extract Timing Stop logic without altering the legacy module.
- **Acceptance:** Same seed/time reproduces motion and zone; boundary tap and terminal paths resolve once; target/control regions are visible and accessible; input-open, failure explanation, reduced motion, and 200% instruction behavior use Task 048 primitives.
- **Minimum context:** v2 public types, slice primitives, `timing_stop.dart`, and its unit/widget tests.
- **Reasoning/chat:** Medium. Reuse the 048 chat if still focused; otherwise new chat.
- **Stop:** Independently testable module/scene only; no session integration.

### Task 050 — Implement Hold It v2

- **Objective:** Prove continuous down/hold/up/cancel and lifecycle-safe abandonment with the second slice gesture.
- **Dependencies:** 047-048.
- **Scope:** One v2 module/scene, deterministic/widget tests, and only the minimal harmless visual distraction needed to exercise held feedback; no major modifier.
- **Acceptance:** Fake-clock tests cover required duration, early release, pointer cancel, background-equivalent abandon, duplicate events, target bounds, semantic hold alternative, failure explanation, and reduced motion.
- **Minimum context:** v2 runtime tests, Task 048 primitives, Reaction Tap timing concepts, and current lifecycle tests.
- **Reasoning/chat:** High because input cancellation/lifecycle are correctness boundaries. Prefer the 049 chat if its runtime/module context remains compact.
- **Stop:** Independently testable Hold It only; no session integration.

### Task 051 — Adapt the Director and add the pure Gauntlet run model

- **Objective:** Make one deterministic pure policy select v2 metadata and advance the approved three-life/24-round run without building UI or persistence.
- **Dependencies:** 049-050 metadata.
- **Scope:** Adapt Director request/history/selection and difficulty policy; add pure Gauntlet run state for lives, the provisional documented score/combo formula, within-run unmodified introduction tracking, recovery, round cap, abandonment, and duplicate-result protection; focused policy/run tests.
- **Constraints:** Retain the legacy Director API only while the old route needs it. The slice ends at the round cap; boss scheduling is implemented in R4 with the real boss rather than through an unused hook. No profile/save/UI mutation.
- **Acceptance:** Deterministic replay, no immediate game repeat, gesture limit, unmodified introduction, two-failure recovery, bounded difficulty/modifier cost, exact provisional lives/combo/score behavior, abandon, and 24-round completion pass.
- **Minimum context:** `ai-director.md`, `gameplay-loop.md`, v2 metadata, current Director/policy/tests, and progression operation-ID behavior only.
- **Reasoning/chat:** High. New chat because it joins two tightly coupled pure policies.
- **Stop:** Pure selection/run model and tests only.

### Task 052 — Integrate Home-to-Gauntlet vertical slice and record Gate G1

- **Objective:** Deliver the two-game playable path and verify the architecture/design on a real device.
- **Dependencies:** 048-051.
- **Scope:** Gauntlet controller/screen/result state, Home primary action and one Gauntlet route, two-module scene factory, minimal existing progression adapter, integration/widget tests, and Gate G1 record. Keep the edit within 5-8 hand-authored files; split only a measured defect, not planned scope.
- **Constraints:** No Calm/Rush placeholders, save schema change, onboarding, settings, cosmetics, profile redesign, production assets, or missing-content/boss stubs.
- **Acceptance:** Automated checks cover two gestures, lives, round/replay, one-result/progress, generation failure, active/result back, background/foreground/cancel, large text, reduced motion, and themes. Every Gate G1 item in `milestones.md` is recorded pass/fail on a real Android device.
- **Minimum context:** Public APIs from 048-051, current Home/router/Gameplay/controller/result/lifecycle tests, `navigation.md`, and Gate G1 only.
- **Reasoning/chat:** High. New integration chat.
- **Stop:** Report Gate G1 and narrow blockers; do not start R2 automatically.

## R2 — Representative catalog proof

### Task 053 — Implement Don't Press It with genuine/fake instruction behavior

- **Objective:** Add intentional inactivity/deception and the first real troll modifier using the validated tell language.
- **Dependencies:** Gate G1 passes.
- **Scope:** One v2 module/scene and focused tests; adapt Reaction Tap timing concepts. The base round is forgiving and unmodified; the modified variant may imitate only one genuine-tell signal.
- **Acceptance:** Early touch, genuine change, valid post-change tap, timeout/inactivity, fake/genuine pattern, color/sound-independent recognition, seed replay, and stable explanations pass.
- **Minimum context:** v2 runtime, tell primitives/tests, Reaction Tap timing code/tests, and modifier contract.
- **Reasoning/chat:** High because timing and deception fairness interact. New chat or reuse the compact R1 microgame chat.
- **Stop:** Module only; no run-wide policy changes.

### Task 054 — Implement Protect the Egg

- **Objective:** Validate direct drag tracking and visible collision fairness with the smallest representative drag game.
- **Dependencies:** Gate G1 passes.
- **Scope:** One module/scene with seeded hazards, shield drag, visible collision shapes, one deterministic beatability/clearance validator, and focused tests. No decoy-hazard modifier yet.
- **Acceptance:** Multi-seed clearance, deterministic collision, drag offset, cancel/abandon, one-handed reach, semantic alternative, and reduced motion pass.
- **Minimum context:** v2 drag events/regions, fairness invariants, and the slice scene pattern. Do not inspect unrelated modules.
- **Reasoning/chat:** High because geometry is gameplay correctness. New chat.
- **Stop:** Base module only; no general physics engine.

### Task 055 — Implement Wrong Way

- **Objective:** Add the representative swipe mechanic with an explicit same/opposite rule.
- **Dependencies:** Gate G1 passes.
- **Scope:** One module/scene and focused tests for cardinal direction, distance/tolerance, same/opposite rule, cancel, and semantic alternatives. Use the genuine tell only for a real rule change; no mid-swipe inversion.
- **Acceptance:** Threshold boundaries, deterministic rule selection, pre-open input, success/failure explanation, large text, reduced motion, and color/sound independence pass.
- **Minimum context:** v2 swipe event, tell primitives, and one existing v2 module pattern.
- **Reasoning/chat:** Medium. May reuse the 054 catalog chat after pointer advancement.
- **Stop:** Module only.

### Task 056 — Integrate the five-game catalog and record Gate G2

- **Objective:** Test the actual replay/session proposition before funding the rest of the catalog or Flow Run.
- **Dependencies:** 053-055.
- **Scope:** Register five games, add the minimal typed Gauntlet snapshot for run-policy values and module enable/version references, update Director eligibility/history for proven metadata only, integrate scenes, run focused catalog/session tests, record Gate G2, and make v2 the primary Gauntlet route. Do not delete legacy code yet.
- **Acceptance:** Multi-seed selection proves game/gesture repetition, introduction/modifier/recovery, accessibility fallback, deterministic run replay, and safe no-candidate behavior. Every Gate G2 item is recorded pass/fail.
- **Minimum context:** Five module metadata, Director/run public APIs, catalog/config seam, Gauntlet scene factory, and Gate G2 only.
- **Reasoning/chat:** High. New integration chat.
- **Stop:** If G2 fails, create one focused correction task; do not expand catalog or begin R3/Flow Run.

## R3 — Local product compatibility

### Task 057 — Migrate local save v1 to additive v2

- **Objective:** Preserve every valid existing Brain Profile/progression/outcome while adding typed defaults only for Gauntlet run history, mastery, personal bests, and settings that have active consumers.
- **Dependencies:** Gate G2 passes and v2 IDs/outcomes are frozen.
- **Scope:** Save/data models, frozen v1 fixture, v2 migration/round-trip/failure tests; no UI or progression policy.
- **Acceptance:** Valid v1 data is retained exactly; v2 defaults and round trip work; corrupt/unsupported/failed-write/dedup/cap cases remain non-destructive; no reset is required.
- **Minimum context:** Architecture persistence section, current save/tests, Brain Profile/progression serialization, and final v2 outcome identifiers.
- **Reasoning/chat:** High. New migration chat.
- **Stop:** Storage/data boundary only.

### Task 058 — Add mastery/PBs and concise results/profile presentation

- **Objective:** Apply valid v2 outcomes idempotently and show the minimum useful run result/profile evidence.
- **Dependencies:** 057.
- **Scope:** Mastery/PB policy, Gauntlet result integration, concise result and profile updates, focused persistence/widget tests. Preserve historical Brain Profile as secondary data.
- **Constraints:** No cosmetic inventory/store, broad dashboard, currency, or reinterpretation of old values.
- **Acceptance:** Bounded/idempotent updates, deterministic PB ties, sparse state, restart persistence, dominant `Play Again`, one meaningful insight, 200% text, semantics, and light/dark pass.
- **Minimum context:** `progression.md`, v2 save API, current progression/profile/result models and tests.
- **Reasoning/chat:** Medium. Prefer reuse of the 057 chat if migration context remains manageable.
- **Stop:** Progress/result/profile only.

### Task 059 — Implement minimal persistent accessibility/settings controls

- **Objective:** Expose only settings consumed by validated gameplay: theme/system choice, reduced motion, and accessible local defaults.
- **Dependencies:** 057 and Task 048 primitives.
- **Scope:** Settings model/provider/screen, app application, save integration, focused tests.
- **Acceptance:** Changes apply immediately, survive restart, remain usable at 200% text with logical focus/44x44 targets, and preserve gameplay meaning under reduced motion.
- **Minimum context:** Design-system accessibility sections, app theme/bootstrap, v2 settings fields, and current router.
- **Reasoning/chat:** Medium. New UI/settings chat; 060 may reuse it.
- **Stop:** Settings only; no haptic/music/sound toggles before those systems exist, audio assets/services, analytics, permissions, or broad preferences.

### Task 060 — Implement interaction-led first-session onboarding

- **Objective:** Teach Stop the Machine and the genuine tell through play without pages or account/permission gates.
- **Dependencies:** 052, 053, 057, 059.
- **Scope:** Minimal onboarding state/screen, router/bootstrap hook, persistence, focused widget/manual checks.
- **Acceptance:** First launch enters a forgiving practice interaction; returning launch skips it; complete/skip/failure recovery work offline; genuine/fake tell remains clear with sound off, reduced motion, screen reader, and 200% text.
- **Minimum context:** `screens.md` onboarding section, Stop the Machine scene API, tell primitives, router/bootstrap, and onboarding save field.
- **Reasoning/chat:** Medium. Reuse the 059 chat if still focused.
- **Stop:** First-session path only.

### Task 061 — Retire the legacy primary-session path and close R3

- **Objective:** Remove runtime/session duplication proven unreachable after v2 cutover while retaining pure legacy rules/IDs required by v1 compatibility or later secondary-content decisions.
- **Dependencies:** 056-060.
- **Scope:** Remove/isolate old Gameplay/session/result route adapters and update focused reference/navigation/lifecycle tests; record R3 exit evidence.
- **Constraints:** No deletion by filename, broad cleanup, legacy save-ID removal, remaining catalog work, Flow Run, cosmetics, or production assets. Stop if an old controller still owns behavior not migrated.
- **Acceptance:** Reference search shows one primary Gauntlet session owner; v2 route/profile/progression/lifecycle and frozen v1 migration remain valid; R3 exit criteria are recorded.
- **Minimum context:** Task 056 reachability report, old/new route/session/result symbols, tests importing removal candidates, and v1 decoder references.
- **Reasoning/chat:** High for ownership/lifecycle cleanup. New focused cleanup chat.
- **Stop:** Report removed/retained legacy pieces and any blocker; do not detail or implement R4.

## R4 — Conditional approved queue, no active task IDs

After Gate G2 and stable R3 boundaries, create one focused prompt at a time in this order:

1. Escape Button.
2. Feed the Idiot.
3. Keep Inside.
4. Parking Disaster.
5. Clean the Screen.
6. Boss: The App Is Broken and full-catalog boss/balance validation.
7. Flow Run deterministic segment/physics foundation.
8. Calm Run.
9. Rush Run and runner persistence integration.
10. Local cosmetic presentation, original production assets/audio, then release-quality cross-mode validation.

These outcomes are retained, not canceled. Their exact file/task boundaries depend on the validated five-game runtime and should not be guessed now.

## Deferred infrastructure

Cloud accounts/sync, daily competition, leaderboards, server currency/inventory, purchases, remote LiveOps, social, notifications, landscape runner support, and online AI remain outside this backlog until separately approved.
