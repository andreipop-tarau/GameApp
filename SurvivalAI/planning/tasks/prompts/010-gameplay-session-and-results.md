# Task 010 — Add offline gameplay session and result flow

## Objective

Make all five catalog modules playable through Home → round → result → retry.

## Scope

- Add one Riverpod session controller and Gameplay screen.
- Select modules through a simple seeded rotation, render active module, accept input only while active, and show a compact result panel.
- Retry starts the next valid round without route replacement; exit returns Home.
- Keep all state in memory.

## Relevant documentation

- `/planning/architecture/overview.md`
- `/planning/gameplay/gameplay-loop.md`
- `/planning/gameplay/challenge-engine.md`
- `/planning/ui/navigation.md`

## Relevant files

`lib/features/gameplay/game_session_controller.dart`, `gameplay_screen.dart`, `result_panel.dart`, `lib/app/router.dart`, and focused session/widget tests.

## Architecture constraints

- One controller owns session state; modules remain isolated.
- No local persistence, Brain Profile, XP, adaptive director, lifecycle policy, or dependency change.
- Generation failure retries once, then presents safe recoverable UI rather than crashing.

## Acceptance Criteria

- Home Play starts a round and all five modules are reachable.
- Resolution is frozen/idempotent; Again is local and route-stable; Home exits safely.
- No network call is required.

## Verification

Format changed Dart, run `flutter analyze`, targeted session/widget tests, and manually play/retry every module.

## Files that must not be modified

`Docs/**`, `planning/**`, persistence/profile/progression features, dependency list, platform files.
