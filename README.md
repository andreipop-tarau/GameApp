# MindTrap AI

MindTrap AI is a Flutter challenge game for Android and iOS. Classic play runs locally, uses seeded deterministic rounds, and remains usable offline.

## Current MVP

- Five short challenge types: Reaction Tap, Sequence Memory, Selective Attention, Timing Stop, and Logic Choice.
- Adaptive difficulty, progression, and brain-profile data stored locally.
- Home, play, and profile screens built with Flutter, Riverpod, and GoRouter.

## Requirements

- Flutter SDK compatible with Dart `^3.12.2`
- An Android emulator/device, or macOS with Xcode for iOS

## Run

```powershell
flutter pub get
flutter run
```

## Verify

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

## Build

```powershell
flutter build appbundle
flutter build ios --release
```

The iOS build requires macOS, Xcode, and valid signing.

## Repository rules

Read `AGENTS.md` and `planning/tasks/current-task.md` before implementation work. `Docs/` is historical and immutable; `planning/` is the implementation source of truth.
