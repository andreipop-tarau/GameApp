# AI Director, mastery, and difficulty

## Director v2

The existing director is deterministic, synchronous, offline, tested for recent-module avoidance and recovery, and should be adapted rather than replaced. Its `MvpModuleId` coupling and five-category rotation are legacy constraints that must move to v2 metadata.

Each candidate exposes:

- identifier/version and primary gesture;
- skill category and base difficulty;
- compatible modifiers with difficulty costs;
- estimated duration;
- mechanic-introduction and recent-use state;
- local success rate, confidence, and recent failure reasons;
- accessibility compatibility for the active settings/viewport;
- boss/recovery eligibility.

The selection request contains run seed/round index, remaining lives, recent microgames and gestures, consecutive failures, per-game mastery, introduced mechanics/modifiers, current intensity, session duration, accessibility settings, and validated catalog/config snapshots.

## Selection order

1. Filter disabled, invalid, inaccessible, duration-incompatible, and boss-ineligible candidates.
2. Enforce no immediate microgame repeat and no gesture more than twice consecutively when alternatives exist.
3. Force an unmodified introduction before a mechanic's modified form.
4. After two consecutive failures, prefer an easier unmodified recovery candidate in a demonstrated gesture.
5. Increase difficulty or modifier cost only after demonstrated competence and minimum samples.
6. Permit at most one major modifier in a normal round.
7. Schedule one eligible discovery boss in rounds 20-24; never use discovery bosses in consecutive runs.
8. Score close-but-beatable fit, variety, underused content, duration budget, and intensity curve; seeded tie-break selects deterministically.

An initial 65-75% normal-round target is a tunable design hypothesis. It is not a scientific constant and must not become a hidden losing-streak controller. The director may simplify after failure; it may never choose unavoidable failure or secretly alter an active plan.

## Deterministic replay

The same run seed, catalog/config/policy versions, profile snapshot, accessibility settings, and ordered prior outcomes must reproduce every selection and modifier. Store stable reason codes. Derive independent random streams for selection, microgame generation, modifiers, and cosmetics so presentation changes cannot alter rules.

## Mastery profile

Preserve the current five stored Brain Profile estimates and applied-outcome IDs. During migration they remain local, private adaptation evidence and are displayed secondarily as historical skill data. New v2 state adds per-microgame mastery, gesture familiarity, modifier/tell familiarity, samples, success rate, and personal bests with additive defaults.

Do not call the model intelligence, diagnosis, mental health, or treatment. Sparse data remains explicit. A single round has bounded influence; abandoned, practice, duplicate, invalid, or inaccessible rounds do not update ranked mastery.

## Difficulty

Difficulty combines base mechanic parameters plus modifier cost. Change at most one configured step or one cost point between comparable rounds. Minimum visible target, reaction-time, movement-speed, path-clearance, and instruction-display bounds override adaptation. Reduced motion may select an equivalent static/short-translation plan and must not silently make ranked play easier or harder; if equivalence cannot be guaranteed, mark the variant non-ranked.

## Required tests

- identical request/seed replay;
- microgame and gesture repetition constraints;
- introduction before modifier;
- two-failure recovery;
- difficulty/cost step bounds;
- boss window and rarity;
- accessibility filtering with a valid fallback;
- no valid-candidate failure behavior;
- deterministic reason codes and random-stream independence.
