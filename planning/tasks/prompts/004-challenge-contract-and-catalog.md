# Task 004 — Define the challenge contract and catalog

## Objective

Create the smallest pure-Dart contract shared by every challenge module.

## Scope

- Define metadata, round plan, player action, outcome/metrics, lifecycle, validator/evaluator interface, and explicit catalog.
- Ensure plans record module/config/seed/version information and evaluation resolves once.
- Add one fake test module; do not add a session controller or production module UI.

## Relevant documentation

- `/planning/architecture/overview.md`
- `/planning/architecture/folder-structure.md`
- `/planning/gameplay/challenge-engine.md`
- `/planning/gameplay/gameplay-loop.md`

## Relevant files

`lib/features/gameplay/challenge.dart`, `challenge_catalog.dart`, `round_lifecycle.dart`, test fixture, and unit tests.

## Architecture constraints

- Pure Dart only: no Flutter, Riverpod, navigation, persistence, or analytics dependency.
- Do not create generic plugin/discovery machinery; catalog registration is explicit.

## Acceptance Criteria

- Invalid plans are rejected and duplicate resolution cannot alter outcome.
- Test module registers without changing catalog internals.
- Deterministic unit tests cover lifecycle and catalog behavior.

## Verification

Format changed Dart, run `flutter analyze`, then targeted challenge-contract tests.

## Files that must not be modified

`Docs/**`, `planning/**`, app router, local save, platform/dependency files.
