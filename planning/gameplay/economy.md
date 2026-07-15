# Cosmetics and ethical monetization

## Direction

Monetization is cosmetics-first and is architecture-only during the repath. Unlimited Troll Gauntlet, Calm Run, and Rush Run remain free. No implementation task before the post-validation monetization milestone may add purchases, store SDKs, paid currency, offers, or failure-triggered selling.

Potential cosmetics are Trapling characters and skins, trails, Flow Run environments, sound packs, reaction animations, result-screen styles, profile decorations, and transparent bundles. They cannot modify stats, lives, director difficulty, collision, timing, visibility, ranked eligibility, or accessibility.

## Local cosmetic foundation

Before purchases, a versioned shipped catalog may support free unlocks, ownership, preview, and equip state. Stable cosmetic IDs and explicit compatibility let future cloud inventory migrate without changing gameplay code. Unknown/missing assets fall back to the default Trapling/theme and never block play.

## Future authority boundary

If monetization is approved after retention and ethics review:

- server inventory and an append-only ledger become authoritative for paid currency and entitlements;
- every grant/spend/purchase uses an idempotent operation ID;
- platform price and exact bundle contents appear before confirmation;
- restore/refund/revocation and offline read-only behavior are explicit;
- purchases are never promoted immediately after failure;
- no loot boxes, hidden odds, fake discounts/scarcity, paid lives, stat boosts, difficulty reduction affecting rankings, or exclusive competitive advantage.

RevenueCat remains a possible provider, not an approved dependency. Recheck cost, exportability, webhook/recovery behavior, privacy, and current platform rules in a future ADR before integration.

## Deferred currency

The previously planned Brain Chips economy is deferred. Adding a premium currency before cosmetics and retention are validated would add ledger, pricing, support, and trust costs without improving the core game. If reintroduced, it must remain server-derived, non-negative, auditable, and separate from XP.
