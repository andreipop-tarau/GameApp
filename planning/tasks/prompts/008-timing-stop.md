# Task 008 — Implement Timing Stop module

## Objective

Implement a frame-rate-independent timing challenge.

## Scope

- Add seeded generation/validation, elapsed-time position calculation, evaluation, and module widget.
- Register the module and add fake-clock/unit/widget tests.

## Relevant documentation

- `/planning/gameplay/challenge-engine.md`
- `/planning/ui/design-system.md`

## Relevant files

`lib/features/gameplay/challenges/timing_stop/**`, `lib/features/gameplay/challenge_catalog.dart`, timing-stop tests.

## Architecture constraints

- Derive position from injected monotonic elapsed time, never frame count.
- Do not add lifecycle/session handling yet; that is Task 015.
- No persistence, navigation, profile, or progression code.

## Acceptance Criteria

- Zone boundaries and tap outcome are deterministic.
- Speed, zone, and direction validate against config.
- Feedback is not color-only and resolution occurs once.

## Verification

Format changed Dart, run `flutter analyze`, then fake-clock unit and widget tests.

## Files that must not be modified

`Docs/**`, `planning/**`, session controller, router, local save, profile/progression files.
