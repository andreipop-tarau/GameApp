# Task 009 — Implement Logic Choice module

## Objective

Implement a deterministic, readable logic-choice challenge.

## Scope

- Add a small set of seeded rule templates, answer/distractor generation, validation, evaluation, and module widget.
- Register the module and add template, boundary, and widget tests.

## Relevant documentation

- `/planning/gameplay/challenge-engine.md`
- `/planning/ui/design-system.md`

## Relevant files

`lib/features/gameplay/challenges/logic_choice/**`, `lib/features/gameplay/challenge_catalog.dart`, logic-choice fixtures/tests.

## Architecture constraints

- Every plan needs one provably correct answer and distinct plausible distractors.
- Do not add generic puzzle/content systems, navigation, persistence, profile, or progression logic.
- Text must remain usable at 200% scale.

## Acceptance Criteria

- Answer order is seeded; correct/wrong/timeout resolve once.
- Template tests prove answer uniqueness across parameter bounds.
- Widget uses accessible labels and non-ambiguous wording.

## Verification

Format changed Dart, run `flutter analyze`, then targeted unit and widget tests.

## Files that must not be modified

`Docs/**`, `planning/**`, session controller, router, local save, profile/progression files.
