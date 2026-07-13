# Authentication and account lifecycle

## Model

Classic play begins with an app-local guest identity so network/auth never blocks the first round. Before cloud sync, daily ranking, shop currency, or purchases, create/sign into a Supabase user. Prefer Supabase anonymous auth for server-bound guests, then link Apple/Google identity rather than creating a second account.

At launch:

- Sign in with Apple on iOS when third-party sign-in is offered.
- Google sign-in where configured and appropriate.
- No passwords unless recovery/support needs prove they are necessary.
- Secure session tokens use platform secure storage through the Supabase SDK integration.

## Guest upgrade and merge

1. Preserve a versioned local snapshot before auth.
2. Authenticate/link identity.
3. Fetch server revision.
4. Send an idempotent merge request with local revision and operation IDs.
5. Server preserves authoritative economy/competitive data, unions owned cosmetics, takes max monotonic achievements/progress where valid, and applies explicit last-write rules to settings.
6. Return merged snapshot/revision; save locally atomically.

Never silently overwrite two established accounts. An account collision stops and explains recovery/support choices.

## Authorization

RLS is mandatory; authenticated identity is never accepted from request payload. Edge Functions verify JWTs and authorize the target object. Admin operations use separate credentials, MFA-capable provider controls, least privilege, and audit logging. Service-role keys are server-only.

## Lifecycle and privacy

- Sign-out ends the remote session and leaves an explicit local guest state; it does not silently erase data.
- Account deletion requires recent authentication, revokes sessions, removes/anonymizes data according to retention rules, and provides visible completion/failure state.
- Provide a data export path before public launch if required by applicable law/policy.
- Display name validation, profanity/moderation fallback, and privacy defaults precede public leaderboard exposure.
- Brain Profile is private by default and excluded from public APIs.

## Acceptance criteria

- Offline first launch reaches Classic play.
- Guest upgrade preserves eligible local progress and is idempotent.
- A user cannot read or mutate another user’s private rows under RLS tests.
- Expired sessions recover or return to guest-capable UI without a loop.
- Sign-in cancellation and provider failure do not lose progress.
- Deletion/export flows are auditable and do not expose financial secrets.
