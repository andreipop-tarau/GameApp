# Progression and retention

## XP and levels

**Purpose:** Make every valid round contribute to long-term progress without affecting competitive power.

**Requirements:** Award base XP by resolved difficulty (initial reference: easy 10, medium 20, hard 35; daily 50) through one progression service. Use a monotonic level curve stored in versioned configuration. Failed rounds may grant a small, capped participation amount only if abuse tests allow it. Level unlocks cosmetic access or presentation only.

**Dependencies:** Valid outcome, difficulty, config version, local save/cloud sync.

**Acceptance criteria:** Identical outcome IDs never grant twice; level never decreases; offline awards reconcile safely; UI explains XP change; numeric rules are test fixtures, not scattered constants.

**Future extensions:** achievements, missions, season progress.

## Brain Profile presentation

**Purpose:** Turn the private model defined in `ai-director.md` into understandable progress.

**Requirements:** Show five MVP skills, confidence, recent direction, personal bests, and a clearly labeled descriptive Brain Type when enough data exists. Avoid medical, intelligence, or diagnostic claims.

**Dependencies:** Brain Profile repository, profile screen, localization.

**Acceptance criteria:** Sparse data is represented honestly; screen works offline; values match the stored snapshot; no detail is public without opt-in.

**Future extensions:** weekly/monthly trends and optional share cards.

## Daily challenge

**Purpose:** Give all eligible players a comparable daily objective.

**Requirements:** One UTC-dated, server-published seed/config/module sequence; practice may be unlimited but only the first scored attempt (or another explicitly configured rule) enters ranking; attempt token is acquired before the scored run; server validates submission and returns rank/reward. If offline, show prior cached result and allow Classic mode, not a fake scored attempt.

**Dependencies:** Auth, Edge Function/RPC validation, daily tables, challenge engine compatible versions, leaderboard.

**Acceptance criteria:** Same date/version yields equivalent content; duplicate submissions are idempotent; device clock cannot select a future challenge; failed upload can retry the same signed attempt; rules are visible before play.

**Future extensions:** weekly sets, friend comparison, event modifiers.

## Leaderboards

**Purpose:** Provide fair asynchronous competition.

**Requirements:** Launch supports daily and global/all-time boards only. Store server-validated best scores with deterministic tie-breakers: score descending, completion time ascending where relevant, achieved timestamp ascending. Paginate and show the player’s nearby rank. Participation/profile display obeys privacy settings.

**Dependencies:** Auth, validated submissions, profiles, moderation-safe display names.

**Acceptance criteria:** Clients cannot write rank or arbitrary score; repeated lower submissions do not replace a best; pagination has stable order; blocked/deleted users are handled; offline screen shows cached data marked stale.

**Future extensions:** country, friends, weekly/monthly/seasonal boards.

## Social

**Purpose:** Increase friendly competition without making launch dependent on a moderation-heavy system.

**Requirements:** No social graph in MVP or initial launch. Launch may support OS share sheets for a non-sensitive result card only. Sharing is explicit and excludes private Brain Profile detail by default.

**Dependencies:** Results/profile privacy and platform sharing.

**Acceptance criteria:** Canceling share has no side effect; shared text/image contains no account identifier; game works fully without sharing.

**Future extensions:** friends, challenges, referrals, blocks/reports, public profiles after moderation and abuse controls exist.

## LiveOps gameplay

**Purpose:** Keep challenge selection and goals fresh without making core play depend on an online event.

**Requirements:** Launch LiveOps may schedule daily definitions, enable compatible shipped modules, tune bounded parameters/rewards, and rotate cosmetics. Every round records its config version. Event failure or expiry falls back to normal Classic play. No event may introduce paid power, forced waiting, or an executable mechanic not shipped in the app.

**Dependencies:** Versioned remote config, challenge catalog, AI Director, daily challenge, economy, bundled fallback, operational audit/rollback.

**Acceptance criteria:** Activation and expiry are UTC-correct and deterministic; unsupported/invalid config is rejected; cached/bundled fallback works offline; rollback restores a known-good version; event rewards are idempotent and do not alter competitive fairness.

**Future extensions:** Weekly events, seasons, missions, community goals, and themed challenge packs only after launch operations are stable.
