# Vertical-slice roadmap

Detailed tasks exist only for the current milestone in `backlog.md`. Later slices are outcome-level and are elaborated shortly before work begins.

## Slice 1 — Core loop MVP (current)

Deliver an installable offline app with central navigation/theme, five deterministic challenge types, result/retry, an initial AI Director, Brain Profile, XP/levels, settings, and a tested local session. Tasks 001–015 define this slice.

## Slice 2 — Account and cloud foundation

Add staging Supabase, anonymous/linked auth, migrations/RLS, local-to-cloud progress sync, environment configuration, and recovery behavior. The build remains fully playable offline.

## Slice 3 — Daily competition

Add server-published daily challenges, validated attempts, daily/all-time leaderboards, display-name/privacy controls, cached read-only offline states, and operational monitoring.

## Slice 4 — Cosmetic economy

Add cosmetic catalog/inventory/equip flow, append-only Brain Chips ledger, shop offers, secure spend, and economy analytics. Seed enough free cosmetics to test the loop before real-money sales.

## Slice 5 — Purchases and LiveOps

Complete the RevenueCat checkpoint, then add sandboxed iOS/Android products, verified webhook grants/restores/refunds, versioned remote configuration, scheduled daily publication, config rollback, and kill switches.

## Slice 6 — Launch readiness

Add Firebase Analytics/Crashlytics, consent/privacy/account lifecycle, accessibility and localization pass, device/performance testing, CI/release workflow, backups/restore rehearsal, store assets/legal content, closed beta, staged production release, and monitoring.

## Post-launch direction

Expand challenge quality and balance first. Consider weekly events, friends/referrals, seasons, community systems, clans, tournaments, and creator tools only from measured retention and operating capacity. See `planning/product/mvp.md`; no post-launch item is committed by this roadmap.

## Slice gate

Each slice ends with a usable build, passing critical-path tests, updated decision/task docs, no unresolved critical defects, and a short manual smoke test on both platform targets when available.
