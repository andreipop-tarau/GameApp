# Scope definition

## MVP: prove the core loop

The MVP is an internal, playable vertical slice—not the store launch.

- Flutter iOS/Android shell, theme, navigation, accessibility baseline.
- Guest player with local versioned save data.
- Classic play with five challenge modules: reaction tap, sequence memory, selective attention, timing stop, and simple logic choice.
- Deterministic seeded challenge generation and immediate result/retry.
- Initial adaptive difficulty, repetition control, and recovery rounds.
- Local Brain Profile, XP, level, and session history.
- Offline-first play with bundled configuration.
- Unit/widget tests for the challenge contract, director, progression, and core navigation.

MVP excludes onboarding, preference screens, Supabase, accounts, leaderboards, shop, purchases, social, LiveOps tooling, push notifications, and production analytics. Those do not validate the core game.

## Required before public launch

- Supabase environments, anonymous auth with account upgrade, cloud save, RLS, and migrations.
- Server-validated daily challenge and global daily/all-time leaderboards.
- Cosmetics inventory, Brain Chips ledger, shop rotation, and restored purchases.
- RevenueCat-backed StoreKit/Google Play purchase validation, subject to a checkpoint before integration.
- Firebase Analytics and Crashlytics with consent/privacy handling.
- Versioned remote configuration with bundled safe fallback.
- Onboarding, settings, account deletion/export path, legal links, and offline/error recovery.
- Accessibility, localization readiness, performance/device QA, security review, store assets, beta, monitoring, backup and rollback procedures.

## Post-launch

- Weekly events and leaderboards, expanded challenges and cosmetics.
- Friends, friend challenges, referrals, profile sharing, notifications.
- Seasons and community goals only after retention and operational capacity justify them.

## Future ideas

Clans, tournaments, battle pass, creator/community packs, replay/spectator modes, AI-generated events, and cross-platform expansion remain uncommitted options.

## Scope rule

A feature enters a milestone only when its player value, data ownership, failure behavior, analytics, tests, and operating cost are understood. See `planning/development/milestones.md`; do not use the source roadmap as a task queue.
