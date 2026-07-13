# Task 011 — Add Brain Profile and basic Profile screen

## Objective

Derive a gradual five-skill profile from eligible in-memory round outcomes and render it on the existing Profile route.

## Scope

- Add pure profile model and update policy for reaction, memory, attention, logic, and timing.
- Include bounded smoothing, confidence/sample count, category mapping, and duplicate/invalid outcome protection.
- Update profile once after an eligible session result and replace the Profile placeholder with the five skills, confidence, and a sparse-data state. Do not persist or add XP.

## Relevant documentation

- `/planning/architecture/overview.md`
- `/planning/gameplay/ai-director.md`
- `/planning/gameplay/gameplay-loop.md`

## Relevant files

`lib/features/brain_profile/brain_profile.dart`, `brain_profile_updater.dart`, `lib/features/profile/profile_screen.dart`, `lib/features/gameplay/game_session_controller.dart`, profile tests, session test update.

## Architecture constraints

- Keep update policy pure Dart and deterministic.
- Profile is private descriptive data, never a power system or diagnosis.
- Do not add local save, XP, router changes, or a new package.

## Acceptance Criteria

- One outcome has a capped influence; invalid/abandoned/duplicate outcomes do not update.
- Repeated identical inputs converge predictably and sparse data exposes confidence.
- Session integration applies exactly one eligible update and the Profile screen renders the resulting in-memory state accessibly.

## Verification

Format changed Dart, run `flutter analyze`, then targeted Brain Profile, session, and Profile widget tests.

## Files that must not be modified

`Docs/**`, `planning/**`, local save, progression, router, dependency files.
