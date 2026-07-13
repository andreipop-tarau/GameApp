# Backend API

Use direct Supabase reads only for RLS-safe resources. Use PostgreSQL functions or Edge Functions for authoritative multi-step mutations, secret-bearing integrations, and validation. APIs are versioned at the function/route or payload contract boundary.

## Launch operations

| Operation | Mechanism | Input | Result |
|---|---|---|---|
| `sync_progress_v1` | RPC/Edge Function | client revision, versioned progress document, operation IDs | merged document and new server revision |
| `issue_daily_attempt_v1` | Edge Function | daily date/version | signed/opaque attempt token, seed/rules, expiry |
| `submit_daily_attempt_v1` | Edge Function | token, operation ID, result/action summary, versions | accepted result, reward, rank or stable rejection |
| `get_leaderboard_v1` | safe view/RPC | board, period, cursor, page size | stable ordered page, next cursor, player-nearby row |
| `spend_chips_v1` | RPC | operation ID, offer ID, expected config version | ledger entry, inventory grant, balance |
| `purchase_webhook_v1` | Edge Function | provider-signed webhook | idempotent acknowledgment; purchase/ledger mutation |
| `get_config_manifest_v1` | safe read/Edge Function | app version, platform, current versions | compatible published namespace versions/checksums |

Auth lifecycle primarily uses Supabase SDK endpoints. Public profile access is limited to a safe leaderboard view. Storage is not needed for MVP; before launch it may hold remotely managed cosmetic assets or generated share cards only with content type, size, access, lifecycle, and signed-URL policies.

## Request rules

- Authenticate server-side; never accept `user_id` as authority.
- Validate schema, enum, numeric bounds, timestamps, config compatibility, and payload size.
- Mutations require a client-generated UUID operation ID and database uniqueness.
- Use cursor pagination, never unbounded arrays or offset pagination on changing leaderboards.
- Apply per-user/IP rate limits appropriate to attempts, sync, purchases, and public reads.
- Include request ID in response and logs. Do not log JWTs, receipts, tokens, raw personal data, or full metrics payloads.

## Response envelope

Success:

```json
{"data": {}, "meta": {"request_id": "uuid", "api_version": 1}}
```

Failure:

```json
{"error": {"code": "stable_machine_code", "message": "Safe user-facing summary", "retryable": false}, "meta": {"request_id": "uuid", "api_version": 1}}
```

HTTP status reflects the class of failure. Client behavior keys off stable codes, not message text. Backward-compatible fields may be added; renaming/removal requires a new version and supported-client migration window.

## Challenge validation

Daily submission validation checks authenticated ownership, unexpired issued attempt, one-submit/idempotency rules, expected date/seed/config/module/policy versions, plausible duration and metrics bounds, valid score computation, and known client/module compatibility. Suspicious submissions are rejected or flagged; never trust client-computed rank/reward.

## Purchase validation

Verify provider signature/authenticity before parsing. Store provider event/transaction IDs uniquely, map configured product ID to a fixed grant, perform purchase and ledger change transactionally, acknowledge retries, and process refund/revocation events. The client polls/refetches entitlement/balance after pending completion.

## Offline and retry behavior

Only idempotent reads/mutations retry automatically with capped exponential backoff and jitter. Queue eligible progress operations locally; never queue expiring shop purchases or begin a scored daily offline. Surface stale data explicitly.

## Verification

Every operation has contract tests for success, auth failure, ownership failure, malformed/boundary payload, duplicate operation, transient retry, and incompatible version. RLS tests are separate and mandatory.
