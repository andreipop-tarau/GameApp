# Database design

PostgreSQL is the authoritative store for account-linked progress, competition, economy, purchases, and LiveOps. All tables use UUID primary keys unless a natural composite key is stated, `timestamptz` in UTC, explicit foreign keys, and RLS. Migrations live in `supabase/migrations`; generated schema is never edited directly.

## Launch tables

| Table | Essential columns | Ownership and notes |
|---|---|---|
| `profiles` | `user_id` PK/FK auth, `display_name`, `country_code?`, `level`, `xp`, `privacy_json`, `created_at`, `updated_at`, `deleted_at?` | User reads/updates allowed fields; level/XP mutate through trusted function |
| `brain_profiles` | `user_id` PK, `model_version`, `skills_json`, `confidence_json`, `recent_aggregates_json`, `updated_at` | Private to user; validated sync, never public by default |
| `player_sync_state` | `user_id` PK, `save_version`, `revision`, `device_id?`, `progress_json`, `updated_at` | Small cloud-save document for non-authoritative progress; optimistic revision |
| `challenge_results` | `id`, `user_id`, `operation_id`, `mode`, `challenge_id`, `challenge_version`, `category`, `seed`, `config_version`, `policy_version`, `difficulty`, `outcome`, `score`, `duration_ms`, `metrics_json`, `completed_at`, `received_at` | User reads own; insert only via validation path; unique `(user_id, operation_id)` |
| `daily_challenges` | `challenge_date` PK, `definition_version`, `seed`, `config_version`, `rules_json`, `starts_at`, `ends_at`, `status` | Public read only when published; admin writes |
| `daily_attempts` | `id`, `user_id`, `challenge_date`, `attempt_no`, `token_hash`, `status`, `issued_at`, `expires_at`, `submitted_at?`, `result_id?` | User reads own; Edge Function creates/transitions; unique rule matches configured scored attempts |
| `leaderboard_entries` | `board_type`, `period_key`, `user_id`, `best_score`, `best_duration_ms`, `achieved_at`, `result_id` | Composite PK; trusted upsert only; public-safe view exposes rank/name |
| `cosmetics` | `id` text PK, `type`, `asset_key`, `rarity`, `metadata_json`, `active` | Authenticated catalog read; admin write |
| `inventories` | `user_id`, `cosmetic_id`, `acquired_at`, `source`, `source_ref` | Composite PK; user reads; trusted grants only |
| `economy_ledger` | `id`, `user_id`, `operation_id`, `currency`, `amount`, `reason`, `related_type`, `related_id`, `created_at` | Append-only trusted writes; unique `(user_id, operation_id)`; balance view sums entries |
| `shop_offers` | `id`, `config_version`, `contents_json`, `chip_price?`, `store_product_id?`, `starts_at`, `ends_at`, `active` | Published offers readable; trusted management only |
| `purchases` | `id`, `user_id`, `provider`, `store`, `product_id`, `provider_transaction_id`, `status`, `purchased_at`, `raw_ref?`, `created_at`, `updated_at` | User reads sanitized own rows; webhook writes; provider transaction unique |
| `remote_configs` | `namespace`, `version`, `schema_version`, `payload_json`, `status`, `starts_at?`, `created_by?`, `created_at` | Published read; admin/service writes; immutable version rows |
| `liveops_events` | `id`, `type`, `config_version`, `starts_at`, `ends_at`, `status`, `metadata_json` | Published read; admin/service writes |
| `audit_log` | `id`, `actor_id?`, `action`, `target_type`, `target_id`, `request_id`, `metadata_json`, `created_at` | Service/admin read only; append-only |

Post-launch tables such as friends, blocks, referrals, seasons, missions, notifications, clans, and tournaments are not created early.

## Relationships and invariants

- Auth user owns one profile, Brain Profile, and sync state.
- Results reference the user and published configuration versions. A daily leaderboard entry must reference a validated result for the same user/date.
- Ledger is immutable; cached balances, if added, are updated transactionally and reconciled against the ledger.
- Inventory acquisition and negative Chip ledger entry occur in one transaction.
- Purchase transaction uniqueness and operation IDs prevent double grants.
- Use check constraints for nonnegative durations/scores, allowed enums, bounded JSON size, and event time ordering.
- JSON is limited to versioned, genuinely variable payloads; searchable/reporting fields remain typed columns.

## RLS baseline

Enable RLS on every exposed table. Users select/update their own permitted profile fields and select their private data. They cannot directly insert results, attempts, leaderboard entries, inventory, ledger, or purchases. Catalog/published config access uses restricted read policies or safe views. Administrative writes use service-role Edge Functions and are audited. Add automated policy tests for owner, other authenticated user, anonymous user, and service role.

## Indexes and retention

Add indexes only for known queries: results by user/time, daily attempts by user/date, leaderboard by board/period/order, ledger by user/time, active offers/events by time, and provider transaction lookup. Raw high-volume telemetry belongs in Firebase or a later analytics pipeline, not `challenge_results`. Define retention/anonymization before launch; account deletion removes/anonymizes personal rows while preserving required financial records.

## Backups

Use Supabase production backups/PITR appropriate to the selected plan, export critical configuration, and document a restore rehearsal before launch. The original RPO <15 minutes and RTO <1 hour are targets subject to paid-plan capability, not assumed guarantees.
