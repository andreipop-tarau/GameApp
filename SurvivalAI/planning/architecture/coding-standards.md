# Coding standards

## Dart and Flutter

- Follow effective Dart and repository analyzer rules. Format all changed Dart files.
- Prefer immutable models and `const` widgets. Keep widgets small enough to explain locally.
- Widgets render state and forward intent; controllers coordinate workflows; pure domain services hold game rules.
- Use Riverpod providers for dependencies and state ownership. No global mutable singletons or service locators.
- Represent asynchronous state explicitly. Cancel/dispose session-scoped work.
- Centralize GoRouter routes and redirects. Do not navigate from repositories or domain code.
- Inject time and randomness into deterministic logic.
- Avoid `dynamic`, forced null assertions, silent catches, and unbounded retries.

## Data and APIs

- Map vendor DTOs at the data boundary; never expose them to domain or UI.
- All server mutations validate authentication, authorization, payload schema, bounds, and idempotency.
- Database changes require migrations and RLS review. Never use service-role credentials in the client.
- Use UTC instants in storage and convert only for display. Use integer minor units for prices and integer ledger amounts for currency.
- Public API errors use a stable code, safe message, and request ID; log detail server-side.

## UX, accessibility, and telemetry

- Meet 44×44 pt minimum targets, readable contrast, text scaling, reduced-motion behavior, and screen-reader labels.
- Gameplay must not rely on color, sound, or haptics alone.
- Every event name/property is defined before instrumentation. Never send free text, email, auth tokens, Brain Profile detail, or other unnecessary personal data.
- Crash reports include non-sensitive diagnostic context only.

## Testing expectations

Test behavior, not implementation. Each task adds the smallest tests that protect its acceptance criteria. Critical deterministic logic needs boundary, failure, and repeatability cases. A bug fix includes a regression test when practical.

## Review limits

Keep task changes focused. Do not refactor unrelated code, add speculative abstractions, upgrade dependencies incidentally, or reformat untouched files.
