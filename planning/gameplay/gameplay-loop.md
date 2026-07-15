# Gameplay loop and modes

## Troll Gauntlet core loop

Home opens Troll Gauntlet with one prominent action. A seeded run creates a deterministic round sequence. Each round presents a one-to-four-word objective, signals when input opens, accepts one primary gesture, resolves once, gives immediate layered feedback, and transitions in no more than 350 ms unless a short failure explanation is needed. `Play Again` starts a new deterministic run in no more than 500 ms and never waits for a network.

### Selected run model: three lives with a finite gauntlet

The run starts with three lives and ends when all lives are lost or the player clears the late boss. It contains at most 24 rounds; the director schedules a boss in rounds 20-24 after enough eligible normal rounds. Expected successful runs are approximately 4-6 minutes because normal games last 5-15 seconds and transitions are brief.

Why this model:

- Three lives creates a clear survival/retry loop and is the smallest safe change from the existing per-round session controller.
- A shared time bank would make instruction reading and accessibility accommodations feel punitive and would complicate pause/lifecycle behavior.
- A score-only fixed run would guarantee duration but weaken survival tension.

The consequence is that weak runs may end early. First exposure to a mechanic is unmodified and forgiving; two consecutive failures force an easier recovery round when one is valid. Recovery does not secretly restore lives or reduce rewards. A mechanic-introduction round may be explicitly marked as practice and not consume a life, but only once per newly introduced mechanic and never invisibly.

### Sequence rules

- Never select the same microgame consecutively when another eligible game exists.
- Never use the same primary gesture more than twice consecutively.
- Introduce a microgame without a major modifier before selecting modified variants.
- Apply at most one major modifier in a normal round.
- Raise difficulty only after demonstrated competence; simplify after repeated failures.
- Reserve combined modifiers and discovery interactions for rare bosses.
- Store run seed, policy version, microgame/modifier versions, and ordered outcomes for deterministic diagnosis and replay.

Initial selection tuning aims for close-but-beatable normal rounds and an approximate 65-75% success band after onboarding. This is a product hypothesis to tune through playtesting, not a scientific constant or a promise to manipulate outcomes.

### Score and progression

Score combines cleared rounds, speed within mechanic-safe bounds, and a visible success combo. Failure removes one life and resets combo; it never changes a past result. Personal best records score and furthest round with deterministic tie rules. XP, mastery, tell familiarity, and cosmetic unlocks are applied idempotently after a resolved eligible round/run.

For R1/R2 validation, use one explicit provisional formula: a success grants `100 + 10 * min(previousConsecutiveSuccesses, 10)` points; a failure grants zero, removes one life, and resets combo. Speed bonus is deferred until at least five games expose comparable validated metrics. The separate onboarding practice round in Task 060 grants no run score, XP, life loss, mastery, or personal-best progress. Numeric values are tunable design hypotheses, not permanent balance claims.

## Round lifecycle

`created -> briefing -> inputOpen -> active -> resolved -> feedback -> transition`

Only `inputOpen`/`active` accept the gestures declared by the plan. Resolution is idempotent. Backgrounding or confirmed exit abandons an active round without profile, progression, score, or reward mutation. Resume never restarts the same timer silently; the session either resumes a safely paused non-competitive state or creates the documented replacement round. Task 015 behavior is verification-uncertain and must be retested against this lifecycle.

A resolved record contains run/round IDs, seed, mode, microgame and modifier IDs/versions, config/policy versions, difficulty, input-open time, terminal time, outcome, failure reason, response metrics, accessibility settings relevant to reproduction, and reward operation IDs.

## Calm Run

Calm Run uses automatic forward movement and tap-to-jump, with optional hold for a longer jump. A run lasts about 60-90 seconds, uses predictable seeded handcrafted segment sequences, contains no lives or competitive countdown, and gradually lowers movement density and feedback intensity near the end. Collision causes a bounded rewind, bounce, or slowdown and play continues without a death screen. Score pressure is absent by default.

## Rush Run

Rush Run uses the same one-touch runner contract with faster pacing, seeded handcrafted segment combinations, increasing difficulty, visible combos, personal-best distance, instant restart, and cosmetic presentation. Collision ends the scored attempt under an explicit rule; it must never alter collision boundaries with cosmetics or effects.

## Shared runner constraints

Flow Run is the internal runtime shared by Calm Run and Rush Run. Initial orientation is portrait only: it matches the app, supports one-handed use, avoids a costly orientation transition, and lets the first implementation validate readable obstacle silhouettes on existing devices. Supporting landscape or both orientations is deferred until portrait playtesting shows a real gameplay need.

## Failure and feedback

Failure is clear, brief, and slightly funny. It names the action and the learnable tell, for example:

```text
Too early.
The real signal uses the broken-circle mark.
```

Feedback layers are: response under the finger, object/environment reaction, optional haptic, optional sound, score/progress update, then Trapling reaction. Meaning must remain available without color, audio, haptics, or large motion.
