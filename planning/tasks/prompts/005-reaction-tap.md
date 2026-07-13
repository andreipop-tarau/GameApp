# Task 005 — Implement Reaction Tap module

## Objective

Implement the reaction-tap challenge through the existing contract.

## Scope

- Add seeded plan generation, validation, evaluation, and a module widget.
- Support valid cue, target, distractors, timeout, early-tap loss, correct tap, and wrong tap.
- Register the module; add unit and widget tests.

## Relevant documentation

- `/planning/gameplay/challenge-engine.md`
- `/planning/ui/design-system.md`

## Relevant files

`lib/features/gameplay/challenges/reaction_tap/**`, `lib/features/gameplay/challenge_catalog.dart`, reaction-tap tests.

## Architecture constraints

- Module does not navigate, persist, update profile/progression, or own a session.
- Use config bounds and injected elapsed time/seed; do not hardcode an unbounded difficulty system.
- Cue and target semantics cannot depend on color alone.

## Acceptance Criteria

- Early/correct/wrong/timeout paths resolve once.
- Same seed produces the same plan and all parameters remain in configured bounds.
- Widget exposes usable labels and interaction targets.

## Verification

Format changed Dart, run `flutter analyze`, then reaction-tap unit and widget tests.

## Files that must not be modified

`Docs/**`, `planning/**`, session controller, router, local save, profile/progression files.
