# Task 014 — Add XP and levels

## Objective

Add non-power XP/levels and result feedback.

## Scope

- Add config-driven XP/level calculation and apply it once per eligible outcome.
- Persist progression in the existing local save.
- Show the latest XP delta in the existing result panel.
- Add level/XP to the existing Profile screen; do not redesign its Brain Profile section.

## Relevant documentation

- `/planning/gameplay/progression.md`

## Relevant files

`lib/features/progression/progression.dart`, `lib/core/local_game_save.dart`, `lib/features/profile/profile_screen.dart`, `lib/features/gameplay/result_panel.dart`, `lib/features/gameplay/game_session_controller.dart`, focused tests.

## Architecture constraints

- Numeric values come from bundled config, not scattered constants.
- No cosmetics, accounts, shop, analytics, diagnostic claims, or network UI.
- Do not redesign the Brain Profile UI or alter the router structure.

## Acceptance Criteria

- XP cannot duplicate per outcome and levels never decrease.
- Progress survives restart.
- Result feedback clearly states the latest XP delta.
- Profile shows level and XP consistently with the stored progression state.

## Verification

Format changed Dart, run `flutter analyze`, then targeted progression, persistence, result-panel, and Profile widget tests.

## Files that must not be modified

`Docs/**`, `planning/**`, router structure, backend files, shop/cosmetic/account features.
