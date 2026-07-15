# Task 047 — Add the minimal microgame v2 foundation

## Objective

Add the pure Dart microgame contract, modifier data contract, and smallest deterministic runtime required by Stop the Machine and Hold It without changing current application behavior.

This replaces superseded Tasks 016 and 017. It deliberately combines contracts with their first test consumer so no temporary adapter-only task is created.

## Required context

Read only:

1. `/AGENTS.md`.
2. `/planning/tasks/current-task.md`.
3. This prompt.
4. The runtime contract, fairness invariants, primary gestures, first-slice selection, and compatibility sections of `/planning/gameplay/challenge-engine.md`.
5. The state/lifecycle and determinism sections of `/planning/architecture/overview.md`.
6. `/lib/features/gameplay/challenge.dart`.
7. `/lib/features/gameplay/round_lifecycle.dart`.
8. `/lib/core/clock.dart`.
9. `/test/features/gameplay/challenge_contract_test.dart` and `/test/core/clock_test.dart`.

Inspect `seeded_random.dart` only if a stable seed-namespace value type cannot be defined without it. Do not load the backlog, full planning system, UI, session controller, persistence, config, or legacy modules.

## Scope

Prefer three production files and one focused test file:

- `lib/features/gameplay/microgame.dart`;
- `lib/features/gameplay/troll_modifier.dart`;
- `lib/features/gameplay/microgame_runtime.dart`;
- `test/features/gameplay/microgame_foundation_test.dart`.

Define only:

- stable microgame/plan/config/modifier identity and version values;
- metadata required by the first slice: primary gesture, a v2-local five-value skill-category enum compatible through an explicit later adapter, base difficulty/cost, estimated duration, compatible modifier IDs, and accessibility flags;
- gesture/event types covering tap, pointer down/move/up/cancel, swipe summary, trace sample, semantic equivalent, timeout, and inactivity tick with monotonic elapsed time;
- normalized required interaction regions and viewport projection validation, including 44x44 minimum tap/hold targets;
- immutable plan/state/resolution data with stable outcome/reason/explanation/metrics fields;
- modifier data with stable ID/version, compatibility, difficulty cost, major/minor classification, and fairness/accessibility notes;
- validation for plan identity, region bounds/size, modifier compatibility, and at most one major modifier in a normal plan;
- runtime phases `created -> briefing -> inputOpen -> active -> resolved`, plus `abandoned`;
- ordered event dispatch, explicit timeout/inactivity hooks, abandon, input rejection outside legal phases, and idempotent terminal resolution;
- fake definition/plan/reducer fixtures inside the focused test file only.

## Architecture constraints

- Pure Dart: no Flutter, Riverpod, GoRouter, storage, assets, or vendor imports.
- Keep `challenge.dart`, `round_lifecycle.dart`, legacy catalog/modules/session, bundled config, persistence, UI, dependencies, and planning files unchanged.
- Do not implement a real microgame, catalog, scene factory, Riverpod controller, generic physics/path solver, executable modifier pipeline, or difficulty/Director policy.
- Do not consume random numbers. Represent stable seed namespaces/identity only; generation begins in later tasks.
- Do not create JSON/config parsing. Module-owned versioned typed parameter tables begin with real modules in Tasks 049-050; a minimal Gauntlet snapshot waits for Task 056.
- Runtime coordinates phases/events and invokes a supplied pure reducer seam; it does not know microgame IDs or rules.
- Support future gesture event types as data, but test runtime behavior only for tap, hold/cancel, timeout, and inactivity required by the first slice.
- If the combined work would require changing a legacy public type, stop and report the collision instead of creating a broad adapter layer.

## Acceptance criteria

- The fake definition registers without a microgame-ID switch.
- Same plan identity/event sequence produces the same fake state/resolution.
- Illegal phase input is rejected without mutation.
- Pointer down/hold/up and pointer cancel remain ordered at identical/adjacent elapsed values.
- Abandon, timeout, inactivity, and duplicate terminal events cannot produce more than one resolution.
- Invalid/out-of-safe-area/undersized required regions are rejected.
- An incompatible modifier or more than one major normal modifier is rejected.
- Resolution carries stable cause, concise explanation, metrics, and replay identity without importing legacy `RoundEvaluation`.
- Existing legacy source behavior remains untouched.

## Verification

Do not run Flutter or Dart commands yourself. Ask the developer to run exactly:

```powershell
dart format --output=none --set-exit-if-changed lib/features/gameplay/microgame.dart lib/features/gameplay/troll_modifier.dart lib/features/gameplay/microgame_runtime.dart test/features/gameplay/microgame_foundation_test.dart
flutter analyze
flutter test test/features/gameplay/microgame_foundation_test.dart
```

Do not request the full test suite. If one extra narrowly justified file is required, report it before changing the verification paths.

## Completion handoff

Report changed files, public v2 types, enforced invariants, developer-supplied verification results, confirmation that legacy files were unchanged, and the exact reducer/runtime seam Task 049 will consume.

Recommended reasoning: **high**. Use a **new chat**.

## Stop point

Stop after the pure foundation and focused tests. Do not begin Task 048, implement UI or a real microgame, change planning, or advance the task pointer.
