# Gameplay loop

## Core loop

**Purpose:** Deliver a complete, fair challenge in 5–30 seconds and make replay immediate.

**Requirements**

1. Home `Play` creates a session and requests a round plan from the AI Director.
2. The challenge shows a short, unambiguous instruction before or as play begins, depending on the mechanic.
3. Input is evaluated locally against explicit success/failure rules.
4. Resolution freezes input, records the outcome, updates local profile/progression, and shows a compact result.
5. `Again` starts the next generated round without a route transition or network wait; `Home` ends the session.
6. Target: play begins within 2 seconds of `Play`, restart within 500 ms, and supported devices sustain 60 FPS.

**Dependencies:** Challenge Engine, AI Director, Brain Profile, progression, local persistence; feedback preferences are added before launch.

**Acceptance criteria**

- A player completes every MVP challenge with one hand in portrait orientation.
- Win and loss are understandable without relying only on color, sound, or haptics.
- App backgrounding pauses or safely resolves time-sensitive state; returning never creates a phantom score.
- No network loss prevents Classic play or retry.
- Each round records one deduplicated outcome and one analytics event when telemetry is enabled.

**Future extensions:** modes, event modifiers, multi-step and audio challenges; none may change the core challenge contract casually.

## Round lifecycle

`created → briefing → active → resolved → persisted → result`

Only `active` accepts gameplay input. Resolution is idempotent. A round record contains: round ID, session ID, seed, challenge ID/version/category, config version, difficulty parameters, start/end timestamps, outcome, response metrics, reward preview, and source (`classic`, `daily`, `event`).

## Session rules

A session starts on Play and ends on explicit exit or after 30 minutes idle. Fatigue is a selection signal, not a penalty. The app may offer a break but never blocks play. Results appear in under one second; celebratory motion respects reduced-motion settings.

## Offline and failure behavior

Bundled challenge configuration is always valid. Failed local persistence keeps the result visible, reports a non-fatal error, and prevents duplicate rewards on retry. Competitive modes clearly state that a connection is required before an attempt begins.
