# Task 015 — Add interruption-safe round lifecycle

## Objective

Prevent active timed rounds from being corrupted or exploited by app lifecycle changes.

## Scope

- Wire lifecycle transitions into the existing session controller.
- Pause/abandon or safely resolve active rounds according to the existing lifecycle model.
- Prevent duplicate resolution after foregrounding.
- Add active-round exit confirmation only; result/inactive states exit normally.

## Relevant documentation

- `/planning/gameplay/gameplay-loop.md`
- `/planning/architecture/overview.md`
- `/planning/ui/navigation.md`

## Relevant files

`lib/features/gameplay/game_session_controller.dart`, `gameplay_screen.dart`, `lib/app/app.dart`, lifecycle/session widget tests.

## Architecture constraints

- Do not change save schema, AI Director policy, dependencies, or module evaluators.
- Keep behavior deterministic and offline. Do not add a pause menu/settings system.

## Acceptance Criteria

- Backgrounding never improves a score or produces a phantom/duplicate result.
- Foregrounding behavior is deterministic.
- Active back confirms exit; resolved/result states do not unnecessarily confirm.

## Verification

Format changed Dart, run `flutter analyze`, targeted lifecycle/session widget tests, then manually background/foreground and use system back during an active round.

## Files that must not be modified

`Docs/**`, `planning/**`, local-save schema, AI Director files, dependency files.
