# Progression and retention

## Retention principles

Retention comes from mastery, learned troll tells, personal-best improvement, faster sequences, funny but informative failures, new deterministic variations, and cosmetic collection. It must not come from waiting, energy, paid lives, streak punishment, fake scarcity, mandatory ads, or hidden odds.

## XP and levels

Keep the implemented idempotent XP and monotonic level system. Rebalance values only through versioned config after the new run scoring exists. XP grants cosmetic access and presentation only; it never changes hitboxes, timing, lives, director fairness, runner physics, or ranking eligibility.

Round and run reward operation IDs remain deterministic and deduplicated. Practice/introduction rounds may grant a small explicitly configured amount but cannot be farmed by restart. Abandoned and invalid rounds grant nothing.

## Mastery and personal bests

Add per-microgame mastery, gesture familiarity, learned modifier/tell state, best Gauntlet score/furthest round, best Rush distance/combo, and Calm completion history. Defaults for old saves are empty/zero; no existing Brain Profile or XP is discarded.

Personal-best tie rules are deterministic. Results show one meaningful insight, such as a new furthest round or a troll tell learned, rather than a dashboard. `Play Again` is always the strongest result action.

## Brain Profile migration

Keep the five existing estimates, confidence, samples, and applied IDs for compatibility and possible secondary presentation. Adapt the screen away from a clinical card grid and make it subordinate to game mastery. Do not reset or silently translate old values into new mastery. New microgame outcomes may map to an existing skill category for director evidence while maintaining separate per-game mastery.

## Cosmetic progression

Cosmetics include Trapling characters/skins, trails, runner environments, sound packs, reaction animations, result styles, and profile decorations. Unlock/equip state is separate from XP and competitive results. Cosmetic assets can change presentation only; collision, timing, interaction regions, tell language, and accessibility remain invariant.

## Persistence compatibility

The implemented local save is schema v1 and strictly accepts only the five current module IDs. Task 057 must decode v1, retain Brain Profile, progression, and recent outcomes, then write an additive v2 document with explicit defaults for new run stats, mastery, and settings that already have consumers. Cosmetic state is added only with the cosmetic feature. Unknown future versions remain unsupported with a non-destructive recovery path. Tests must cover v1 fixtures, v2 round trips, default values, corrupt data, deduplication, history caps, and failed writes. No task may reset existing saves merely to simplify the repath.

## Future competition

Daily challenges and leaderboards remain deferred until the three-mode local product proves retention and fair reproducibility. If activated, scored attempts and rankings become server-authoritative while unlimited local play remains free and offline.
