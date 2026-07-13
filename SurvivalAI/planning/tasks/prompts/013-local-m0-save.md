# Task 013 — Persist the local M0 game state

## Objective

Keep recent round history and Brain Profile across restart through one small versioned save.

## Scope

- Add `shared_preferences`.
- Add one versioned JSON local-save model containing bounded recent outcomes and Brain Profile.
- Load it at startup, save eligible completed rounds once, and provide typed corrupt/unsupported-data recovery/reset behavior.

## Relevant documentation

- `/planning/architecture/overview.md`
- `/planning/architecture/technology-stack.md`
- `/planning/gameplay/gameplay-loop.md`

## Relevant files

`pubspec.yaml`, `lib/core/local_game_save.dart`, `lib/app/app.dart`, `lib/features/gameplay/game_session_controller.dart`, `lib/features/brain_profile/brain_profile.dart`, persistence tests.

## Architecture constraints

- Use one explicit save document; no repository abstraction, database, cloud sync, or settings feature.
- Keep startup wiring small; do not change routes/UI except a recoverable startup message if strictly required.
- Bound history size and make save schema/version explicit.

## Acceptance Criteria

- Empty save starts cleanly; valid save round-trips; corrupt/unsupported save safely resets.
- One completed outcome persists once and history cap is enforced.
- No duplicate-profile mutation occurs while saving/loading.

## Verification

Run `flutter pub get`, format changed Dart, `flutter analyze`, and targeted persistence/session tests.

## Files that must not be modified

`Docs/**`, `planning/**`, router/UI beyond startup wiring, backend files, platform files.
