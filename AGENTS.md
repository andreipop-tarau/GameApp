# MindTrap AI agent rules

## Scope and source of truth

- `Docs/` is immutable historical source. Never read it for an implementation task and never modify, move, rename, or delete it.
- `planning/` is the implementation source of truth. Its name is intentional: Windows cannot host both `Docs/` and `docs/` in this workspace.
- Implement one assigned task only. Do not start the next task, refactor unrelated code, add speculative packages, or update planning files unless the task explicitly says so.

## Context and workflow

- Read `AGENTS.md`, `planning/tasks/current-task.md`, then only the task prompt and documents it names.
- Search target files narrowly with `rg`. Use Serena only to trace symbols/references or understand an in-scope cross-feature dependency.
- Preserve existing user changes. Never use destructive Git commands to discard work. Stop and report a conflict, missing authority, or unsafe requirement.

## Non-negotiable architecture

- Flutter, Riverpod, and GoRouter. Keep Classic play local, seeded, deterministic, and usable offline.
- Widgets render state and forward intent; game rules stay pure Dart. Do not put navigation in storage/services or vendor SDK models in UI/game rules.
- Add a boundary only when the current task needs one. No global mutable state, client secrets/service-role keys, silent catches, or unbounded retries.
- Competitive scores, currency, inventory, and purchases become server-authoritative only in their assigned milestones.

## Quality and handoff

- Keep edits focused, formatted, accessible, and testable. Do not rely on color, sound, or haptics alone for gameplay meaning.
- Run exactly the task verification plus any minimal diagnostic command needed for a failure. Do not weaken checks to pass.
- Before stopping, confirm protected files are unchanged, report changed files and verification results, state any limitation, and stop. Keep the report brief and factual.
