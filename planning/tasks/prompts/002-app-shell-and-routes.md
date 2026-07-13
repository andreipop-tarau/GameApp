# Task 002 — Add minimal app shell and routes

## Objective

Create stable Home, Play-placeholder, and Profile-placeholder routes with minimal reusable visual tokens.

## Scope

- Add `MaterialApp.router` and named GoRouter routes for `/`, `/play`, and `/profile`.
- Add a Home screen with prominent Play and Profile actions.
- Add only the color, text, and spacing tokens those screens need.
- Use semantic labels and test predictable navigation/back behavior.

## Relevant documentation

- `/planning/architecture/overview.md`
- `/planning/architecture/folder-structure.md`
- `/planning/ui/navigation.md`
- `/planning/ui/design-system.md`

## Relevant files

`lib/main.dart`, `lib/app/app.dart`, `lib/app/router.dart`, `lib/app/app_theme.dart`, `lib/features/home/home_screen.dart`, and focused widget tests.

## Architecture constraints

- Keep route ownership in `app/router.dart`.
- No onboarding, settings, persistence, challenge rules, new dependencies, or empty shared-widget layer.
- Use direct file reads/`rg`; Serena is unnecessary.

## Acceptance Criteria

- Home works offline and routes to Play/Profile placeholders.
- Back navigation is predictable.
- Home uses tokens, supports text scaling, and exposes labels.

## Verification

Format changed Dart, run `flutter analyze`, then targeted router/Home widget tests.

## Files that must not be modified

`Docs/**`, `planning/**`, `pubspec.*`, platform folders, backend files.
