# Milestones

## M0 — Offline core-loop MVP (current)

**Outcome:** A solo developer can install the game, complete/retry five challenge types offline, and observe adaptive profile/progression changes.

**Included:** Tasks 001–015 in `backlog.md`.

**Exit criteria**

- Debug builds run on at least one Android and one iOS simulator/device when host access permits.
- Five modules implement the documented deterministic contract and accessibility baseline.
- Play-to-result-to-retry works without network, duplicate resolution, or blocked navigation.
- Director/profile/progression critical logic has deterministic unit coverage.
- One integration smoke test covers a local session; analyze/test pass.
- Performance spot check finds no obvious jank on the supported test device.
- No backend, purchase, social, or LiveOps scope has leaked into the MVP.

## M1 — Cloud account foundation

**Outcome:** Guest progress safely links and syncs through a secured staging backend. Detail this milestone only after M0 evidence and schema review.

## M2 — Daily competition

**Outcome:** Players can complete a common validated daily and view fair daily/all-time rankings.

## M3 — Cosmetic economy

**Outcome:** Players earn, own, equip, and securely spend Brain Chips on non-gameplay cosmetics.

## M4 — Monetization and LiveOps

**Outcome:** Both store sandboxes validate/restores purchases and versioned configurations publish/roll back safely.

## M5 — Public launch

**Outcome:** Privacy, telemetry, accessibility, QA, operations, store compliance, rollback, and staged release gates are complete.

## Post-launch

Operate weekly from player/stability evidence. Plan only the next small release; do not prebuild social/seasons/clans/tournaments.
