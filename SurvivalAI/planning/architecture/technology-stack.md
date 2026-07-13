# Technology stack

Pin versions when a dependency is first introduced; do not add a package for a future milestone.

| Concern | M0 choice | Later choice |
|---|---|---|
| Client | Flutter/Dart, iOS and Android | unchanged |
| State | Riverpod | unchanged |
| Navigation | GoRouter | guards/deep links when needed |
| Local state | one versioned JSON save through `shared_preferences` | reconsider a local database only when queryable history needs it |
| Backend | none | Supabase Auth, PostgreSQL, Edge Functions, Storage when needed |
| Purchases | none | RevenueCat, subject to ADR checkpoint |
| Telemetry | none | Firebase Analytics and Crashlytics |
| CI | none | GitHub Actions after M0 |

## Excluded until a task needs them

No code generation, mock framework, local database, custom server, queue, admin app, Redis, ML/LLM service, Realtime subscription, Stripe, or second state/navigation package.

## Environments and secrets

Backend work uses separate staging and production projects. Compile-time selection uses `--dart-define` or non-secret checked-in config. Service-role keys, store credentials, and signing material are never in the app or repository.
