# Task 006 — Implement Sequence Memory module

## Objective

Implement an accessible sequence-memory challenge through the existing contract.

## Scope

- Add seeded sequence generation, validation, presentation/input phases, evaluation, and module widget.
- Register the module and add focused unit/widget tests.

## Relevant documentation

- `/planning/gameplay/challenge-engine.md`
- `/planning/ui/design-system.md`

## Relevant files

`lib/features/gameplay/challenges/sequence_memory/**`, `lib/features/gameplay/challenge_catalog.dart`, sequence-memory tests.

## Architecture constraints

- Input is disabled during presentation.
- Symbols need non-color identity; no navigation, persistence, profile, or progression logic.
- Do not introduce a generic animation framework.

## Acceptance Criteria

- Correct, wrong, and timeout paths resolve once.
- Length, symbol count, and pace validate against config.
- Same seed reproduces the same sequence.

## Verification

Format changed Dart, run `flutter analyze`, then sequence-memory unit and widget tests.

## Files that must not be modified

`Docs/**`, `planning/**`, session controller, router, local save, profile/progression files.
