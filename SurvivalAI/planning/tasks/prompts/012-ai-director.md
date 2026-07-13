# Task 012 — Add initial AI Director

## Objective

Replace fixed module rotation with deterministic, varied, difficulty-aware selection.

## Scope

- Add pure candidate filtering/scoring and one-step difficulty selection.
- Use existing config, Brain Profile, recent session history, failures, and seed.
- Integrate selection before the next round and carry reason/policy version in its record.

## Relevant documentation

- `/planning/architecture/overview.md`
- `/planning/gameplay/ai-director.md`
- `/planning/gameplay/challenge-engine.md`

## Relevant files

`lib/features/ai_director/ai_director.dart`, `difficulty_policy.dart`, `lib/features/gameplay/game_session_controller.dart`, director tests, session test update.

## Architecture constraints

- Synchronous, local, deterministic rules only—no LLM, ML, network, remote config, or new dependency.
- Avoid recent duplicates when alternatives exist; do not modify module evaluators.

## Acceptance Criteria

- Same inputs/seed yield same choice.
- Cold start rotates categories; three failures select a valid easier recovery candidate.
- Tests cover disabled module, single candidate, repeat avoidance, recovery, and bounds.

## Verification

Format changed Dart, run `flutter analyze`, then targeted director and session tests.

## Files that must not be modified

`Docs/**`, `planning/**`, persistence, Profile UI, backend files, dependency list.
