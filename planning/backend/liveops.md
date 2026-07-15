# LiveOps and remote configuration

## Launch scope

LiveOps at launch is versioned configuration and scheduled records managed through Supabase tooling/scripts. Do not build a custom admin panel for one developer.

Config namespaces initially cover:

- Challenge parameter bounds and module enablement.
- AI Director weights, caps, and recovery policy.
- XP curve and fixed rewards.
- Daily challenge definitions/rules.
- Cosmetics and shop offers.
- Kill switches for remote/networked features.

## Publish workflow

1. Create immutable draft with schema/config version.
2. Validate JSON schema, bounds, referenced IDs/assets, date windows, and compatibility against supported app versions.
3. Test in staging using an explicit version.
4. Mark published and optionally schedule activation.
5. Client fetches, validates, caches, and activates atomically; otherwise retains last-known-good/bundled config.
6. Roll back by activating a prior compatible version; record audit entry.

Config changes cannot add executable challenge logic. A module implementation/version must already ship in the client. Unsupported modules remain disabled.

## Daily scheduling

A scheduled Edge Function/cron job publishes future daily definitions from compatible module/config versions. It uses UTC dates, is idempotent, never replaces a daily after scored attempts exist, and alerts/logs when no valid definition can be produced. Pre-publish several days to tolerate outages.

## Realtime

Realtime is not required for the game loop. Use pull-to-refresh/pagination for launch leaderboards. Consider Realtime later for visible rank refresh or community goals only after measuring benefit and connection cost.

## Analytics and operations

Firebase Analytics owns client behavior events. PostgreSQL records authoritative transactions and audit events. Crashlytics owns client crashes/non-fatals. Edge Functions emit structured logs with request ID, function/version, latency, outcome code, and no secrets/receipts.

Before launch define alerts for daily publication failure, purchase webhook errors, score rejection spikes, Edge Function error/latency spikes, database capacity, and config activation failure. Weekly KPI review is an operating process, not an app feature.

## Security and recovery

Only service/admin roles publish configuration. Validate payload size and fields, audit every state change, and require a safe rollback. Back up published config separately. An unavailable or malformed remote config must never block bundled local core play.

## Future extensions

Weekly events, missions, seasons, community goals, feature experiments, and an admin UI are post-launch. Add an admin UI only when recurring operational work exceeds the cost of scripts/dashboard use.

## Acceptance criteria

- Staging publish, activation, invalid-config rejection, client fallback, and rollback are tested.
- Scheduled daily creation is idempotent and UTC-correct.
- Config/version used for a round is recorded.
- Kill switch degrades the affected network feature without blocking local core play.
- Logs and audit rows identify failures without sensitive player data.
