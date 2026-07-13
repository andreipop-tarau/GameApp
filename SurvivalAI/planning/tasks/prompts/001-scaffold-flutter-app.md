# Task 001 — Scaffold Flutter app

## Objective

Create the runnable Flutter baseline for MindTrap AI.

## Scope

- Run Flutter project generation in this repository for iOS and Android only.
- Set Dart package `mindtrap_ai`, app display name `MindTrap AI`, and Android/iOS identifier `com.mindtrapai.game`.
- Add direct dependencies `flutter_riverpod` and `go_router`, plus the standard lint dev dependency.
- Replace the counter demo with a minimal `MaterialApp` wrapped in `ProviderScope` that shows “MindTrap AI”.
- Keep this as generated baseline work; do not create app architecture, routes, theme tokens, or gameplay folders.

## Relevant documentation

- `/AGENTS.md`

## Relevant files

Create standard Flutter root/platform files. Edit only generated Flutter files, `pubspec.yaml`, `pubspec.lock`, `lib/main.dart`, and the generated test as needed.

## Architecture constraints

- No Supabase, Firebase, persistence, code-generation, mock, or extra UI package.
- Do not use GoRouter yet; Task 002 owns routing.
- Do not invent signing credentials.

## Acceptance Criteria

- App launches under `ProviderScope`; counter demo is gone.
- Only Android/iOS platforms exist and identifiers/display name match scope.
- Dependencies are limited to this task.

## Verification

```powershell
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Inspect Android and iOS identifiers. Report iOS build as not run on Windows; do not try to work around that.

## Files that must not be modified

`Docs/**`, `planning/**`, `AGENTS.md`, `README.md`.
