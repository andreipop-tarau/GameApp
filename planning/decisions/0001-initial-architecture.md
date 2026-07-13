# ADR 0001: Initial architecture and scope boundaries

- **Status:** Accepted for M0; review purchase provider before M4.
- **Date:** 2026-07-14.

## Context

MindTrap AI must be built and operated by one developer using AI coding agents with limited context budget. It needs fast offline gameplay, later server-authoritative competition/economy, and iOS/Android delivery without early platform complexity.

## Decision

1. Build one Flutter/Dart mobile client using Riverpod and GoRouter.
2. Organize code feature-first. In M0, keep each small feature together and use pure Dart game rules; add data/application boundaries only when a real persistence or API concern appears.
3. Implement the “AI Director” at launch as deterministic configurable rules over player state, not an LLM or hosted ML service.
4. Make Classic gameplay local/offline and deterministic. Supabase becomes authoritative for identity, cloud sync, daily competition, economy, inventory, purchases, and LiveOps configuration.
5. Use PostgreSQL RLS plus idempotent RPC/Edge Function mutations. Do not build microservices, a queue, data warehouse, or custom admin app initially.
6. Use Firebase Analytics and Crashlytics for client telemetry/stability; retain authoritative transaction/audit data in PostgreSQL.
7. Prefer RevenueCat for store integration because it removes substantial dual-platform receipt/webhook/restore handling, but recheck pricing, exportability, and vendor dependency before M4. If rejected, record a replacement ADR before native billing work.
8. Keep social graphs, seasons, battle pass, clans, tournaments, creator tools, and online generative AI outside launch scope.

## Consequences

- The core loop can be tested cheaply and works during outages.
- Seed/config/module/policy versions must be stored for reproducibility.
- Some progress can be locally authoritative in M0, but competitive and currency paths require later server migration and explicit conflict rules.
- Remote config can tune shipped modules but cannot deliver executable mechanics.
- Feature boundaries stay maintainable without generating large amounts of boilerplate.
- RevenueCat adds vendor cost/dependency; the explicit checkpoint prevents an unreviewed commitment.

## References

See `planning/architecture/overview.md`, `technology-stack.md`, `planning/product/mvp.md`, and the original product sources under `Docs/`.
