# Task 016 — Add the pure microgame v2 and modifier contracts (superseded)

**Status:** Superseded before implementation by compressed Task 047, which combines the contract and minimal runtime foundation. Do not execute this prompt.

## Objective

Add the pure Dart type boundary required by Troll Gauntlet microgames and deterministic troll modifiers without changing the existing challenge path or application behavior.

This task creates architecture only. It does not add a runtime coordinator, a real microgame, UI, session integration, persistence, or config migration.

## Required context

Read only:

1. `/AGENTS.md`.
2. `/planning/tasks/current-task.md`.
3. This prompt.
4. `/planning/decisions/0002-troll-game-repath.md`.
5. `/planning/gameplay/challenge-engine.md`.
6. `/planning/architecture/overview.md`.
7. `/lib/features/gameplay/challenge.dart`.
8. `/lib/features/gameplay/round_lifecycle.dart`.
9. `/test/features/gameplay/challenge_contract_test.dart`.

Inspect `core/seeded_random.dart` only if the seed namespace type cannot be designed from the named planning contract. Do not load the backlog or other planning documents.

## Scope

Add narrowly named pure Dart types, expected under `lib/features/gameplay/`:

- stable microgame identifier/version metadata;
- primary gesture enum covering tap, hold, drag, swipe, trace, continuous tracking, and intentional inactivity;
- skill category and accessibility/presentation capability metadata;
- normalized visible interaction-region model with viewport-safe validation inputs;
- immutable deterministic microgame plan identity/parameters;
- typed ordered input events for tap, pointer down/move/up/cancel, swipe summary, trace sample, semantic equivalent, timeout, and inactivity tick using monotonic elapsed time;
- immutable state/resolution contracts with stable reason codes, metrics, and concise failure explanation;
- troll modifier definition with stable ID/version, compatible gestures/microgames, seed namespace, difficulty cost, fairness/accessibility constraints, and explanation contribution;
- contract validators that reject invalid gesture declarations, out-of-bounds/undersized required regions, incompatible modifiers, and more than one major normal-round modifier;
- one fake microgame/modifier fixture used only by focused tests.

Prefer `microgame.dart`, `troll_modifier.dart`, and mirrored tests. A small additional file is allowed only if one file would mix unrelated responsibilities.

## Architecture constraints

- Pure Dart rules: no Flutter, Riverpod, GoRouter, storage, or vendor imports.
- Do not modify `challenge.dart`, `round_lifecycle.dart`, legacy modules/catalog/session, UI, save schema, bundled config, dependencies, assets, or planning files.
- Do not create a generic physics engine, service locator, repository abstraction, runtime controller, or scene factory.
- New v2 types must coexist without changing the legacy public behavior.
- Seed identity must reserve stable independent namespaces for run/round/microgame/modifier; do not consume random values in this task.
- A modifier plan is data, not executable UI behavior.
- Stable reason codes are machine-readable; user-facing explanation is concise and localizable later.
- Required tap regions validate to at least 44x44 logical pixels after viewport projection. Continuous paths/regions expose bounds needed for later beatability validators; do not invent a universal solver.

## Acceptance criteria

- Every target gesture has a typed representation.
- Metadata carries identifier/version, primary gesture, skill category, base difficulty/cost, compatible modifiers, estimated duration, and accessibility flags.
- Plan identity contains seed/config/microgame/modifier versions and normalized visible regions.
- Normal plans cannot declare multiple major modifiers.
- Incompatible gesture/modifier pairs are rejected.
- Required tap regions outside the safe viewport or below 44x44 are rejected in tests.
- Resolution can represent success/failure, stable cause, explanation, metrics, and deterministic replay identifiers without importing legacy `RoundEvaluation`.
- Fake definition/fixture registers without an ID switch in the contract.
- Existing legacy tests and source behavior remain untouched.

## Verification

Do not run Flutter or Dart commands yourself. Ask the developer to run exactly:

```powershell
dart format --output=none --set-exit-if-changed lib/features/gameplay/microgame.dart lib/features/gameplay/troll_modifier.dart test/features/gameplay/microgame_contract_test.dart
flutter analyze
flutter test test/features/gameplay/microgame_contract_test.dart
```

Adjust paths only if the approved implementation uses one additional narrowly justified contract/test file. Do not request the full test suite in this task.

## Completion handoff

Report:

- changed files;
- public v2 types and invariants;
- verification results supplied by the developer;
- whether any legacy file changed (expected: no);
- any condition that Task 017 must know.

Recommended reasoning: **high**. Use a **new chat**. Expand investigation only if a named legacy type collision makes coexistence impossible; stop and report that conflict instead of redesigning the session.

## Stop point

Stop when the pure contracts and focused tests are complete. Do not start Task 017, a runtime, a microgame, UI, config, persistence, or planning updates.
