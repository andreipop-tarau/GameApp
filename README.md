# MindTrap AI

MindTrap AI is a one-handed iOS/Android challenge game built around 5–30 second deterministic rounds, adaptive difficulty, instant retry, unlimited free play, and cosmetics-only monetization.

## Stack

Flutter/Dart, Riverpod, GoRouter, Supabase/PostgreSQL/Edge Functions, RevenueCat pending its decision checkpoint, Firebase Analytics, and Firebase Crashlytics. The offline MVP is implemented before backend and monetization work.

## Repository

```text
Docs/             Original specifications; read-only
planning/         Permanent product, architecture, and task plans
lib/              Flutter source after Task 001
test/              Unit and widget tests
integration_test/  Critical-flow tests when introduced
android/ ios/      Platform projects after Task 001
supabase/           Migrations/functions/tests when introduced
```

Start agent work with `AGENTS.md` and `planning/tasks/current-task.md`. Do not reload `Docs/`; the relevant implementation requirements are under `planning/`.

The requested lowercase `docs/` cannot coexist with source `Docs/` on this Windows case-insensitive workspace. `planning/` is the deliberate equivalent; the source directory was not renamed or moved.

## Run

The Flutter project is created by Task 001. After that task:

```powershell
flutter pub get
flutter run
```

Select an Android emulator/device on Windows. iOS builds require macOS/Xcode.

## Test

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Run `flutter test integration_test` only after integration tests and a target device exist. Backend verification commands will be documented when Supabase is introduced.

## Build

```powershell
flutter build appbundle
flutter build ios --release
```

The iOS command requires macOS/Xcode and valid signing. Release environment files, Firebase projects, Supabase projects, and store signing/products are added in later milestones; never commit secrets.

## Contribute

Implement one numbered task per focused branch/session. Keep changes small, add tests for acceptance criteria, run the task’s stated verification, and leave the app buildable. Record durable architectural changes as a decision document; do not expand scope or begin the next task automatically.

See `planning/product/mvp.md`, `planning/development/roadmap.md`, and `planning/architecture/overview.md` for the current boundaries.
