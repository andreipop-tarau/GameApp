# Task 007 — Implement Selective Attention module

## Objective

Implement a target-filtering challenge with guaranteed valid layouts.

## Scope

- Add seeded item/rule generation, plan validation, evaluation, and module widget.
- Register the module and add multi-seed/unit/widget tests.

## Relevant documentation

- `/planning/gameplay/challenge-engine.md`
- `/planning/ui/design-system.md`

## Relevant files

`lib/features/gameplay/challenges/selective_attention/**`, `lib/features/gameplay/challenge_catalog.dart`, selective-attention tests.

## Architecture constraints

- Plans must have exactly one reachable, non-overlapping target.
- Do not add session, router, persistence, profile, or progression code.
- Target rules must be understandable without color alone.

## Acceptance Criteria

- Correct/wrong/timeout resolve once.
- Multi-seed tests protect target uniqueness and layout invariants.
- Difficulty remains within the bundled config bounds.

## Verification

Format changed Dart, run `flutter analyze`, then focused unit and widget tests across multiple seeds.

## Files that must not be modified

`Docs/**`, `planning/**`, session controller, router, local save, profile/progression files.
