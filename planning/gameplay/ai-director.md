# AI Director, Brain Profile, and difficulty

## AI Director

**Purpose:** Select the next fair round to sustain variety and an approximate 60–70% success band without fixed levels.

**Requirements:** Use a deterministic scoring policy over eligible modules. Inputs are recent outcomes, per-category skill estimates, session length, streaks, recent module history, requested mode, config, and a fatigue proxy. Filter invalid/disabled candidates; score target fit and variety; apply recovery-round rules; break ties with the seeded random source; return the selection plus non-sensitive reason codes.

**Dependencies:** Challenge catalog/config, Brain Profile snapshot, session history, seeded random source.

**Acceptance criteria:** Same inputs and seed return the same selection; no recent duplicate when alternatives exist; three consecutive failures force an easier recovery candidate; cold-start players receive a balanced rotation; selection completes synchronously without network access; policy behavior is unit tested across bounds.

**Future extensions:** remotely tuned weights, contextual bandit experiments after sufficient trustworthy data, event policies. Launch does not include ML training or an LLM.

## Brain Profile

**Purpose:** Provide a gradual, private summary of player performance and inputs for adaptation; it never grants power.

**Requirements:** MVP tracks normalized 0–100 estimates for reaction, memory, attention, logic, and timing. Update only from completed eligible rounds using bounded exponential smoothing plus a confidence/sample count. Retain per-category recent aggregates and personal bests. Show “not enough data” rather than false precision. Brain Type is derived presentation, not stored authority.

**Dependencies:** Valid round metrics, category mapping, local persistence; cloud sync later.

**Acceptance criteria:** One round cannot move a skill by more than the configured cap; invalid/abandoned rounds do not update it; repeated identical input produces predictable convergence; profile remains private by default; upgrades can migrate stored profile versions.

**Future extensions:** prediction, reading accuracy, risk, patience, impulsiveness, pattern recognition, learning speed, adaptability, trends and shareable insights only after enough data exists.

## Difficulty

**Purpose:** Translate player state into safe module parameters.

**Requirements:** Maintain a hidden skill estimate per category, select a target difficulty within module bounds, and change by at most one configured step per round. Difficulty changes use recent success, response quality, confidence, streaks, and recovery state. Never silently change the rules during an active round.

**Dependencies:** Brain Profile, module parameter bands, director policy.

**Acceptance criteria:** Cold start begins at accessible baseline; success gradually raises and failure gradually lowers challenge; impossible parameter combinations are rejected; recovery rounds are visibly normal and award normal base progress; simulations remain within configured success targets using test fixtures.

**Future extensions:** cohort-informed tuning and experiments with server-delivered weight sets.

## Reference policy (initial)

For candidate `c`, calculate a simple weighted score:

`fit + variety + underplayed + mode_bonus - repetition - fatigue_cost - failure_risk`

Weights and caps are named configuration values. Keep the formula small until measured data justifies change. Store policy version with every round for diagnosis.
