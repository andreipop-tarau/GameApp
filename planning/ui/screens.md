# Screen specifications

Unless stated otherwise, every networked screen retains last-known data, exposes retry, avoids raw errors, and records one `screen_view` through the centralized analytics adapter. M0 screens are Home, Gameplay/Result, and Profile (basic). Splash, Onboarding, Settings, and all networked screens are pre-launch.

## Splash / bootstrap

- **Purpose:** Prepare local config/save and choose the first route.
- **Components:** Brand mark, static progress indicator, optional recovery message.
- **Actions/navigation:** Automatic to Onboarding or Home; retry failed local initialization.
- **Loading/offline/error:** Local bootstrap has a bounded timeout; network is not required. Corrupt optional cache falls back safely; unrecoverable save errors offer retry/reset with confirmation.
- **Analytics:** `app_open`, `bootstrap_failed` with safe reason code.
- **Acceptance:** No artificial delay; Classic play is reachable offline; no navigation loop or blank frame.

## Onboarding

- **Purpose:** Explain play, adaptation/privacy, and accessibility controls in at most three short pages.
- **Components:** Illustrated instruction, page progress, Skip/Next/Play, audio/haptics toggles.
- **Actions/navigation:** Skip or complete to Home; settings remain editable later.
- **Loading/offline/error:** Fully bundled; save failure reports and retries without trapping the user.
- **Analytics:** `onboarding_started`, `onboarding_completed`, `onboarding_skipped` with page index.
- **Acceptance:** Finish/skip in under 30 seconds; no account request; screen reader and large text usable.

## Home

- **Purpose:** Put the player one tap from Classic play and expose current goals.
- **Components:** Primary Play button, level/XP summary, daily card (when available), Profile, Leaderboards, Shop, Settings.
- **Actions/navigation:** Routes from the graph in `navigation.md`; Play starts immediately.
- **Loading/offline/error:** Local progress renders first. Offline hides/marks network content and keeps Play active. Remote card failures are non-blocking.
- **Analytics:** `play_tapped`, destination intent events.
- **Acceptance:** Play is the strongest and thumb-reachable action; no modal/store interstitial interrupts it; initial content does not jump excessively.

## Gameplay and result overlay

- **Purpose:** Present the active challenge and resolve/retry with minimum friction.
- **Components:** Instruction, progress/timer when relevant, module play area, pause/exit affordance, feedback layer; result state shows outcome, explanation, XP/profile delta, Again/Home.
- **Actions/navigation:** Module-specific one-handed input; Again replaces round state; Home ends session; back confirms only during active play.
- **Loading/offline/error:** Generation is local and near-instant. Invalid plan regenerates once then uses a known-safe fallback. Persistence failure keeps the outcome visible and prevents duplicate rewards.
- **Analytics:** `round_started`, exactly one `round_completed` or `round_abandoned`, `retry_tapped`; properties follow the event contract, never raw instruction text.
- **Acceptance:** Active input is accepted only in lifecycle `active`; result appears under one second; retry target under 500 ms; interruption and rapid double-tap tests pass; feedback is not color/audio-only.

## Daily challenge

- **Purpose:** Explain today’s common challenge, attempt rule, reward, and standing.
- **Components:** Date/UTC reset, rules, reward, prior result/rank, Start, practice option if enabled.
- **Actions/navigation:** Start obtains attempt token then opens daily play; leaderboard link; back Home.
- **Loading/offline/error:** Cached prior result may display as stale. Offline disables scored Start and points to Classic. Token failures offer retry without consuming an attempt.
- **Analytics:** `daily_viewed`, `daily_start_requested`, `daily_start_failed`, `daily_result_submitted`.
- **Acceptance:** Rules and whether the attempt counts are visible before Start; date comes from server; no attempt consumed before acknowledged token.

## Leaderboards

- **Purpose:** Show fair daily and all-time ranking plus the player’s nearby position.
- **Components:** Board selector, paginated rows, player row, privacy/name prompt, refresh timestamp.
- **Actions/navigation:** Switch board, paginate/refresh, open own Profile; no arbitrary user profile at launch.
- **Loading/offline/error:** Skeleton on first load; cached board is marked stale offline; empty and privacy-disabled states are explicit.
- **Analytics:** `leaderboard_viewed` with board type, `leaderboard_page_loaded`.
- **Acceptance:** Stable order/tie display; no duplicate rows while paging; rank is server supplied; blocked/deleted display names use safe fallback.

## Profile

- **Purpose:** Show level, Brain Profile, personal bests, cosmetics, and sync status.
- **Components:** Identity summary, XP bar, five skill cards with confidence, Brain Type when eligible, bests, equipped cosmetics, sign-in/sync prompt.
- **Actions/navigation:** Equip owned cosmetics, open Account, optional share after launch scope permits.
- **Loading/offline/error:** Local profile appears immediately; stale cloud state is labeled; incomplete data shows “not enough data”; sync failures are retryable.
- **Analytics:** `profile_viewed`, `cosmetic_equipped`, `brain_type_viewed`.
- **Acceptance:** No diagnostic/intelligence claims; private details are not shared by default; equipped state persists; skill values match repository snapshot.

## Shop

- **Purpose:** Browse and acquire cosmetics transparently.
- **Components:** Chip balance, offer/catalog cards, filters only if needed, preview, buy/restore entry, owned state.
- **Actions/navigation:** Preview, confirm Chip spend, initiate platform purchase, restore, back Home.
- **Loading/offline/error:** Cached catalog is view-only when authority cannot be confirmed; no offline spend. Separate pending, canceled, failed, and completed purchase states.
- **Analytics:** `shop_viewed`, `offer_viewed`, `purchase_started/completed/failed`, `chip_spend_completed` using product/offer IDs.
- **Acceptance:** Exact contents/price shown before confirmation; owned/expired offers cannot be purchased; repeated taps do not duplicate transactions; restore is reachable.

## Settings

- **Purpose:** Control experience, privacy, and support behavior.
- **Components:** Audio, haptics, reduced motion/system preference, notifications when implemented, analytics consent where required, privacy/terms/support links, app version, Account.
- **Actions/navigation:** Toggle/save locally, open system/app links, Account route.
- **Loading/offline/error:** Core settings are local and instant; external links explain offline failure; notification permission is requested only from contextual action.
- **Analytics:** `setting_changed` with setting key and coarse value; never track sensitive account actions as generic settings.
- **Acceptance:** Changes apply immediately and survive restart; defaults are safe; legal/version information is available offline where required.

## Account and authentication

- **Purpose:** Explain guest/cloud state and support sign-in, linking, recovery, export, sign-out, and deletion.
- **Components:** Current status, benefits, Apple/Google sign-in as platform-appropriate, sync status, destructive action confirmations.
- **Actions/navigation:** Authenticate/link, retry sync, sign out, request export/deletion, return to initiating route.
- **Loading/offline/error:** Offline preserves guest play and disables server actions. Account collision/link conflicts show explicit choices without overwriting data. Deletion has re-authentication and final confirmation.
- **Analytics:** `auth_started/completed/failed` by provider and safe reason; `account_deletion_requested`. Do not log identifiers.
- **Acceptance:** Cancel returns safely; guest progress is preserved through successful linking; sign-out does not silently delete local data; deletion workflow meets store/backend policy.

## Generic empty/error standards

An empty state explains why it is empty and the next useful action. An error includes a stable user-safe message and retry/escape route. Full-screen blocking errors are reserved for data needed to render that screen; Home and Classic gameplay degrade instead of blocking.
