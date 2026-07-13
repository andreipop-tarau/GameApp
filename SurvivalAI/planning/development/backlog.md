# M0 implementation backlog

Each task is one logical commit and one focused Codex session. A task may touch no more than 5–8 hand-authored files and should stay below roughly 400–600 implementation lines. Task 001 is the sole exception: `flutter create` produces an atomic generated platform baseline, not a hand-authored cross-cutting change.

## Task 001 — Scaffold Flutter app

- **Objective:** Create a runnable iOS/Android Flutter baseline with no gameplay architecture.
- **Scope:** Generate the project; set app/package identifiers and display name; add Riverpod and GoRouter dependencies; replace the counter demo with a minimal `ProviderScope` app.
- **Dependencies:** None.
- **Files likely affected:** Generated Flutter root/platform files (atomic generator output), `pubspec.yaml`, `pubspec.lock`, `lib/main.dart`, `test/`.
- **Acceptance Criteria:** Package is `mindtrap_ai`; Android/iOS identifier is `com.mindtrapai.game`; display name is MindTrap AI; only iOS/Android targets exist; no counter demo remains; app opens under `ProviderScope`.
- **Definition of Done:** Generated baseline is clean, dependencies are limited to this task, and all stated checks pass.
- **Verification:** `flutter pub get`; format check for `lib`/`test`; `flutter analyze`; `flutter test`; inspect identifiers.
- **Estimated effort:** S.
- **Estimated Codex sessions:** 1.
- **Do Not Modify:** `Docs/**`, `planning/**`, `AGENTS.md`, `README.md`.
- **Implementation prompt:** `planning/tasks/prompts/001-scaffold-flutter-app.md`.

## Task 002 — Add minimal app shell and routes

- **Objective:** Establish a stable Home → Play/Profile route shell and small visual token set.
- **Scope:** Add `MaterialApp.router`, named GoRouter routes for Home, Play placeholder, and Profile placeholder; add only color/spacing/text tokens needed by those screens; make Home’s Play action prominent.
- **Dependencies:** 001.
- **Files likely affected:** `lib/main.dart`, `lib/app/app.dart`, `lib/app/router.dart`, `lib/app/app_theme.dart`, `lib/features/home/home_screen.dart`, route/widget tests.
- **Acceptance Criteria:** Back behavior is predictable; Home renders without network; Play/Profile routes work; UI uses tokens rather than scattered raw styling; text-scale and semantic labels work on Home.
- **Definition of Done:** Routes and widgets are tested; no onboarding, settings, persistence, or challenge logic is added.
- **Verification:** Format changed Dart; `flutter analyze`; targeted router/Home widget tests.
- **Estimated effort:** M.
- **Estimated Codex sessions:** 1.
- **Do Not Modify:** `Docs/**`, `planning/**`, backend/platform files, dependency list.
- **Implementation prompt:** `planning/tasks/prompts/002-app-shell-and-routes.md`.

## Task 003 — Add deterministic primitives and bundled challenge config

- **Objective:** Supply reproducible time/random inputs and one validated local challenge configuration.
- **Scope:** Add injected clock and seeded-random abstractions; add one MVP JSON config asset and parser/validator; expose a typed config snapshot to gameplay. Do not persist or remotely fetch configuration.
- **Dependencies:** 001.
- **Files likely affected:** `lib/core/clock.dart`, `lib/core/seeded_random.dart`, `lib/core/mvp_config.dart`, `assets/config/mvp_challenges.json`, `pubspec.yaml`, core tests.
- **Acceptance Criteria:** Same seed produces the same random sequence; malformed/unsupported config fails with a typed safe error; supported bundled config loads in tests; no module-specific game rules live in core.
- **Definition of Done:** Config schema/version is explicit; asset declaration and all boundary tests pass.
- **Verification:** Format changed Dart; `flutter analyze`; targeted core unit tests.
- **Estimated effort:** M.
- **Estimated Codex sessions:** 1.
- **Do Not Modify:** `Docs/**`, `planning/**`, router/UI, dependencies other than asset declaration.
- **Implementation prompt:** `planning/tasks/prompts/003-deterministic-primitives-and-config.md`.

## Task 004 — Define the challenge contract and catalog

- **Objective:** Create the minimal typed contract every challenge module uses.
- **Scope:** Define module metadata, round plan, player action, outcome/metrics, lifecycle, validator/evaluator interfaces, and an explicit catalog. Include one fake module used only by tests. Do not add session orchestration or module UI.
- **Dependencies:** 003.
- **Files likely affected:** `lib/features/gameplay/challenge.dart`, `lib/features/gameplay/challenge_catalog.dart`, `lib/features/gameplay/round_lifecycle.dart`, gameplay test fixture, unit tests.
- **Acceptance Criteria:** Plans carry module/config/seed/version data; evaluation resolves once; invalid plans are rejected; a test module registers without changing catalog internals.
- **Definition of Done:** Contract is pure Dart, narrowly typed, and covered by deterministic unit tests.
- **Verification:** Format changed Dart; `flutter analyze`; targeted challenge-contract tests.
- **Estimated effort:** M.
- **Estimated Codex sessions:** 1.
- **Do Not Modify:** `Docs/**`, `planning/**`, app router, persistence, Riverpod controllers.
- **Implementation prompt:** `planning/tasks/prompts/004-challenge-contract-and-catalog.md`.

## Task 005 — Implement Reaction Tap module

- **Objective:** Add the reaction-tap module to the shared challenge contract.
- **Scope:** Implement seeded plan generation, validation, evaluation, accessibility labels/cues, and module widget for cue, target, distractors, and timeout. Register only this module in the catalog.
- **Dependencies:** 004.
- **Files likely affected:** `lib/features/gameplay/challenges/reaction_tap/**`, `lib/features/gameplay/challenge_catalog.dart`, reaction-tap unit/widget tests.
- **Acceptance Criteria:** Early tap, correct tap, wrong tap, and timeout resolve once; difficulty parameters stay within config bounds; same seed gives the same plan; no cue depends only on color.
- **Definition of Done:** Module is independently testable and does not navigate, persist, or update profile/progression.
- **Verification:** Format changed Dart; `flutter analyze`; reaction-tap unit and widget tests.
- **Estimated effort:** M.
- **Estimated Codex sessions:** 1.
- **Do Not Modify:** `Docs/**`, `planning/**`, session controller, router, local save.
- **Implementation prompt:** `planning/tasks/prompts/005-reaction-tap.md`.

## Task 006 — Implement Sequence Memory module

- **Objective:** Add an accessible sequence-memory module.
- **Scope:** Implement seeded sequence generation, presentation/input phases, evaluation, and module widget. Register it in the existing catalog only.
- **Dependencies:** 004.
- **Files likely affected:** `lib/features/gameplay/challenges/sequence_memory/**`, `lib/features/gameplay/challenge_catalog.dart`, sequence-memory tests.
- **Acceptance Criteria:** Input is disabled during presentation; correct, wrong, and timeout paths resolve once; bounds for sequence length/symbols/pacing validate; symbols have non-color identity; seed replay is stable.
- **Definition of Done:** Module remains isolated from navigation, persistence, profile, and progression.
- **Verification:** Format changed Dart; `flutter analyze`; sequence-memory unit and widget tests.
- **Estimated effort:** M.
- **Estimated Codex sessions:** 1.
- **Do Not Modify:** `Docs/**`, `planning/**`, session controller, router, local save.
- **Implementation prompt:** `planning/tasks/prompts/006-sequence-memory.md`.

## Task 007 — Implement Selective Attention module

- **Objective:** Add a target-filtering module with guaranteed valid layouts.
- **Scope:** Implement seeded item/rule generation, plan validation, evaluation, and module widget. Register it in the existing catalog only.
- **Dependencies:** 004.
- **Files likely affected:** `lib/features/gameplay/challenges/selective_attention/**`, `lib/features/gameplay/challenge_catalog.dart`, selective-attention tests.
- **Acceptance Criteria:** Every plan has exactly one valid target; generated items are reachable and non-overlapping; correct/wrong/timeout resolve once; target rule is understandable without color alone.
- **Definition of Done:** A multi-seed generation test protects layout and target invariants; no session/profile/persistence code changes.
- **Verification:** Format changed Dart; `flutter analyze`; targeted unit/widget tests across multiple seeds.
- **Estimated effort:** M.
- **Estimated Codex sessions:** 1.
- **Do Not Modify:** `Docs/**`, `planning/**`, session controller, router, local save.
- **Implementation prompt:** `planning/tasks/prompts/007-selective-attention.md`.

## Task 008 — Implement Timing Stop module

- **Objective:** Add a timing module whose result is independent of frame rate.
- **Scope:** Implement plan generation/validation, elapsed-time position calculation, evaluation, and module widget. Register it in the existing catalog only.
- **Dependencies:** 003, 004.
- **Files likely affected:** `lib/features/gameplay/challenges/timing_stop/**`, `lib/features/gameplay/challenge_catalog.dart`, timing-stop tests.
- **Acceptance Criteria:** Position derives from injected monotonic elapsed time, not frames; zone boundaries are deterministic; speed/zone/direction validate; one tap resolves once; target is not color-only.
- **Definition of Done:** Fake-clock boundary tests cover timing behavior; no lifecycle/session/persistence handling is added yet.
- **Verification:** Format changed Dart; `flutter analyze`; timing-stop unit and widget tests.
- **Estimated effort:** M.
- **Estimated Codex sessions:** 1.
- **Do Not Modify:** `Docs/**`, `planning/**`, session controller, router, local save.
- **Implementation prompt:** `planning/tasks/prompts/008-timing-stop.md`.

## Task 009 — Implement Logic Choice module

- **Objective:** Add a deterministic, readable logic-choice module.
- **Scope:** Implement a small set of seeded rule templates, provable answer generation, validation, evaluation, and module widget. Register it in the existing catalog only.
- **Dependencies:** 004.
- **Files likely affected:** `lib/features/gameplay/challenges/logic_choice/**`, `lib/features/gameplay/challenge_catalog.dart`, logic-choice fixtures/tests.
- **Acceptance Criteria:** Each generated plan has one correct answer and distinct plausible distractors; answer order is seeded; text remains usable at 200% scale; correct/wrong/timeout resolve once.
- **Definition of Done:** Template/boundary tests prove answer uniqueness; no generic puzzle framework or content-management system is added.
- **Verification:** Format changed Dart; `flutter analyze`; targeted unit/widget tests.
- **Estimated effort:** M.
- **Estimated Codex sessions:** 1.
- **Do Not Modify:** `Docs/**`, `planning/**`, session controller, router, local save.
- **Implementation prompt:** `planning/tasks/prompts/009-logic-choice.md`.

## Task 010 — Add offline gameplay session and result flow

- **Objective:** Make the catalog playable through Home → round → result → retry.
- **Scope:** Add one Riverpod session controller, choose a valid catalog module using a simple seeded rotation, render the active module, freeze resolution, show compact result, retry without route replacement, and exit to Home. Keep state in memory only.
- **Dependencies:** 002, 004–009.
- **Files likely affected:** `lib/features/gameplay/game_session_controller.dart`, `lib/features/gameplay/gameplay_screen.dart`, `lib/features/gameplay/result_panel.dart`, `lib/app/router.dart`, session/widget tests.
- **Acceptance Criteria:** Home Play starts a round; only active rounds accept input; a result is emitted once; Again starts a new valid round without a network call or route replacement; Home ends safely; invalid generation retries once then shows a safe error.
- **Definition of Done:** All five modules are reachable in a deterministic rotation; no persistence, Brain Profile, XP, adaptive difficulty, or lifecycle policy is added.
- **Verification:** Format changed Dart; `flutter analyze`; targeted session/widget tests; manual play/retry smoke through all five modules.
- **Estimated effort:** M.
- **Estimated Codex sessions:** 1.
- **Do Not Modify:** `Docs/**`, `planning/**`, local persistence, profile/progression features, dependency list.
- **Implementation prompt:** `planning/tasks/prompts/010-gameplay-session-and-results.md`.

## Task 011 — Add Brain Profile and basic Profile screen

- **Objective:** Derive a gradual five-skill player profile and show its in-memory state on the existing Profile route.
- **Scope:** Add pure profile models and update policy for reaction, memory, attention, logic, and timing; integrate one post-resolution update in the session controller; replace the Profile placeholder with five skills, confidence, and an honest sparse-data state. Do not persist or add XP.
- **Dependencies:** 002, 010.
- **Files likely affected:** `lib/features/brain_profile/brain_profile.dart`, `lib/features/brain_profile/brain_profile_updater.dart`, `lib/features/profile/profile_screen.dart`, `lib/features/gameplay/game_session_controller.dart`, profile tests, session test update.
- **Acceptance Criteria:** Updates are bounded and deterministic; invalid/abandoned/duplicate outcomes do not update; category mapping is explicit; sparse data exposes confidence/sample count; Profile is accessible and makes no diagnostic claim.
- **Definition of Done:** Pure update policy has boundary, convergence, and duplicate-outcome tests; session integration updates exactly once per eligible result; Profile accurately renders current in-memory state.
- **Verification:** Format changed Dart; `flutter analyze`; targeted Brain Profile, session, and Profile widget tests.
- **Estimated effort:** M.
- **Estimated Codex sessions:** 1.
- **Do Not Modify:** `Docs/**`, `planning/**`, local save, XP/progression, router, dependency files.
- **Implementation prompt:** `planning/tasks/prompts/011-brain-profile.md`.

## Task 012 — Add initial AI Director

- **Objective:** Replace fixed rotation with a deterministic, varied difficulty-aware selection policy.
- **Scope:** Add pure candidate filtering/scoring and simple difficulty step selection; integrate it before next-round creation. Use existing profile and recent session history only.
- **Dependencies:** 003, 004–011.
- **Files likely affected:** `lib/features/ai_director/ai_director.dart`, `lib/features/ai_director/difficulty_policy.dart`, `lib/features/gameplay/game_session_controller.dart`, director tests, session test update.
- **Acceptance Criteria:** Same inputs/seed return same selection; recent duplicate is avoided when alternatives exist; cold start rotates categories; three failures produce an easier valid recovery round; director is synchronous and offline.
- **Definition of Done:** Decision reason/policy version are carried in the round record; simulation/table tests cover disabled, single-candidate, recovery, and bounds cases.
- **Verification:** Format changed Dart; `flutter analyze`; targeted AI Director and session tests.
- **Estimated effort:** M.
- **Estimated Codex sessions:** 1.
- **Do Not Modify:** `Docs/**`, `planning/**`, remote config, persistence, Profile UI, dependency list.
- **Implementation prompt:** `planning/tasks/prompts/012-ai-director.md`.

## Task 013 — Persist the local M0 game state

- **Objective:** Survive restart with a small versioned local save.
- **Scope:** Add `shared_preferences`; persist the current Brain Profile and a bounded recent round history through one versioned JSON document; load safely at app/session startup; expose reset-on-corruption recovery. Do not add settings, cloud sync, or a database.
- **Dependencies:** 010–012.
- **Files likely affected:** `pubspec.yaml`, `lib/core/local_game_save.dart`, `lib/app/app.dart`, `lib/features/gameplay/game_session_controller.dart`, `lib/features/brain_profile/brain_profile.dart`, persistence tests.
- **Acceptance Criteria:** Save/load round trip is deterministic; absent save starts cleanly; malformed/unsupported data fails safely with reset option; one completed round is persisted once; save size/history cap are explicit.
- **Definition of Done:** No repository abstraction or generic storage framework is introduced; unit tests cover version, corrupt data, cap, and duplicate save.
- **Verification:** `flutter pub get`; format changed Dart; `flutter analyze`; targeted persistence/session tests.
- **Estimated effort:** M.
- **Estimated Codex sessions:** 1.
- **Do Not Modify:** `Docs/**`, `planning/**`, router/UI except startup wiring, backend files.
- **Implementation prompt:** `planning/tasks/prompts/013-local-m0-save.md`.

## Task 014 — Add XP and levels

- **Objective:** Add non-power XP/level progression and result feedback.
- **Scope:** Add config-driven XP/level calculation, persist it in the existing save, show the latest XP delta on the result panel, and add level/XP to the existing Profile screen.
- **Dependencies:** 002, 003, 010–013.
- **Files likely affected:** `lib/features/progression/progression.dart`, `lib/core/local_game_save.dart`, `lib/features/profile/profile_screen.dart`, `lib/features/gameplay/result_panel.dart`, `lib/features/gameplay/game_session_controller.dart`, progression/persistence tests.
- **Acceptance Criteria:** XP is idempotent per outcome; level is monotonic; config owns numeric values; result and Profile clearly show the latest progression; no diagnostic claims, cosmetics, account, or network UI appears.
- **Definition of Done:** Progression survives restart and is covered by calculation, persistence, result-panel, and focused Profile widget tests.
- **Verification:** Format changed Dart; `flutter analyze`; targeted progression, persistence, result-panel, and Profile widget tests.
- **Estimated effort:** M.
- **Estimated Codex sessions:** 1.
- **Do Not Modify:** `Docs/**`, `planning/**`, router structure, backend files, shop/cosmetic/account features.
- **Implementation prompt:** `planning/tasks/prompts/014-xp-and-levels.md`.

## Task 015 — Add interruption-safe round lifecycle

- **Objective:** Ensure active timed rounds cannot be corrupted or exploited by app lifecycle changes.
- **Scope:** Pause/abandon or safely resolve active rounds on app lifecycle transitions according to the existing round lifecycle; prevent background/foreground double resolution; add a minimal exit confirmation only during active play.
- **Dependencies:** 010, 012, 013.
- **Files likely affected:** `lib/features/gameplay/game_session_controller.dart`, `lib/features/gameplay/gameplay_screen.dart`, `lib/app/app.dart`, lifecycle/session widget tests.
- **Acceptance Criteria:** Backgrounding never improves a score or creates a phantom result; returning is deterministic; active back action confirms exit; resolved/result states do not show an unnecessary confirmation; Classic remains offline.
- **Definition of Done:** Lifecycle transitions are tested with fake/injected lifecycle state and manual device smoke instructions are recorded in the task result.
- **Verification:** Format changed Dart; `flutter analyze`; targeted lifecycle/session widget tests; manual background/foreground and active-back smoke test.
- **Estimated effort:** S.
- **Estimated Codex sessions:** 1.
- **Do Not Modify:** `Docs/**`, `planning/**`, persistence schema, AI Director policy, dependencies.
- **Implementation prompt:** `planning/tasks/prompts/015-round-lifecycle.md`.

## M0 exit gate

This is a milestone check, not an implementation task. Run the full M0 verification only after Task 015: formatted Dart, `flutter analyze`, `flutter test`, one offline session across all five modules, restart persistence, active-round interruption, large-text check, and device smoke where available. Fixes found here become separate narrowly scoped tasks; do not reopen a generic hardening task.
