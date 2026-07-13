# Task 003 — Add deterministic primitives and bundled challenge config

## Objective

Provide seeded randomness, injectable time, and one validated local MVP config.

## Scope

- Add a small clock abstraction and seeded-random wrapper.
- Add `assets/config/mvp_challenges.json` with an explicit schema/version and bounded module parameters.
- Parse/validate it into a typed config snapshot used by later gameplay.
- Cover same-seed behavior and missing/malformed/unsupported config.

## Relevant documentation

- `/planning/architecture/overview.md`
- `/planning/architecture/folder-structure.md`
- `/planning/gameplay/challenge-engine.md`

## Relevant files

`lib/core/clock.dart`, `lib/core/seeded_random.dart`, `lib/core/mvp_config.dart`, `assets/config/mvp_challenges.json`, `pubspec.yaml`, and core tests.

## Architecture constraints

- Use only Dart/Flutter standard libraries; no persistence or remote config.
- Core must contain no module-specific evaluation rules or Flutter widgets.
- Keep the schema small and tailored to the five MVP modules.

## Acceptance Criteria

- Same seed creates the same random sequence.
- Bundled config loads; invalid/unsupported config has a typed safe failure.
- Parameter bounds are explicit and test-covered.

## Verification

Format changed Dart, run `flutter analyze`, then targeted core unit tests.

## Files that must not be modified

`Docs/**`, `planning/**`, router/UI files, dependency list except the required asset declaration.
