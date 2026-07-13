# Challenge Engine

## System contract

**Purpose:** Generate varied, valid rounds from independent reusable challenge modules.

**Requirements**

- A module declares stable ID/version, category, supported difficulty range, input modes, accessibility capabilities, and parameter schema.
- Given the same module version, config version, seed, and difficulty, generation is deterministic.
- Generation returns an immutable round plan; validation rejects impossible, inaccessible, or out-of-bounds plans before play.
- Evaluation accepts typed player actions and current round time, resolves once, and returns outcome plus metrics.
- Rewards and analytics tags are metadata; modules cannot mutate profile, economy, or navigation.
- New modules register through one catalog without edits to existing modules.

**Dependencies:** Seeded random source, clock, challenge configuration, AI Director selection request.

**Acceptance criteria**

- Seed replay produces identical plans in tests.
- Invalid configuration fails fast and bundled fallback remains usable.
- A module has generator, validator, evaluator, UI, accessibility, and unit/widget tests.
- Identical mechanics are not selected consecutively unless the catalog has no valid alternative.
- Every generated MVP plan passes its module validator.

**Future extensions:** remotely enabled module versions, seasonal presentation skins, compound challenges, and replay diagnostics. Remote data may tune known parameters but cannot download executable Dart code.

## MVP module set

| Module | Category | Player action | Difficulty controls | Success |
|---|---|---|---|---|
| Reaction tap | Reaction | Tap target after valid cue | cue delay, target size, distractors, timeout | Correct target within window; early taps fail |
| Sequence memory | Memory | Replay shown sequence | length, display speed, symbol count | Entire sequence correct before timeout |
| Selective attention | Attention | Select item matching rule | item count, similarity, motion, timeout | Correct item selected |
| Timing stop | Timing | Stop moving marker in zone | speed, zone size, direction changes | Marker is in target zone on tap |
| Logic choice | Logic | Choose one answer | rule complexity, choices, timeout | Correct option selected |

Each module must provide a non-color-only mode. Audio is optional feedback, never a prerequisite in the MVP.

## Configuration

Config has a schema version, content version, activation constraints, module enable flags, and bounded parameter bands per difficulty tier. The app ships a tested fallback. Unknown schema versions are rejected and logged. See `planning/backend/liveops.md` for remote activation.

## Challenge validation

Local validation protects playability. Server validation protects daily scores by checking attempt token, seed/config/module versions, plausible timing, submitted action summary, one-result rule, and score bounds. The server does not attempt to authoritatively simulate ordinary offline Classic rounds.
