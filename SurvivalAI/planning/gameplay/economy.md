# Economy and monetization

## Brain Chips economy

**Purpose:** Fund cosmetic collection without selling gameplay strength.

**Requirements:** Brain Chips are a premium cosmetic currency. Server balance is derived from an append-only ledger; every grant/spend has a unique operation ID, reason, amount, related object, and timestamp. Initial earn sources are bounded achievements, daily rewards/events, and verified purchases. Classic grinding does not yield unlimited Chips. Prices are config-driven; balance cannot be negative.

**Dependencies:** Auth, economy ledger, inventory, remote config, analytics.

**Acceptance criteria:** Duplicate operations have no effect; client cannot set balance; purchase/spend is atomic with inventory change; transaction history supports support investigation; free play remains unlimited at zero Chips.

**Future extensions:** referrals only with abuse protection, community rewards, additional earn sinks after economy review.

## Progression rewards

**Purpose:** Connect play to cosmetic goals without power gain.

**Requirements:** XP/levels remain separate from Chips. Reward definitions reference immutable cosmetic IDs and config versions. Owned non-consumables cannot be re-granted without an explicit duplicate policy.

**Dependencies:** Progression, cosmetics catalog, inventory.

**Acceptance criteria:** Rewards are idempotent, previewed accurately, and recoverable after reconnect; no reward changes challenge parameters or score.

**Future extensions:** achievements, collections, seasonal tracks.

## Shop

**Purpose:** Offer transparent cosmetic choices.

**Requirements:** Launch catalog may contain avatars, frames, themes, and effects that do not obscure gameplay. Offers show exact contents, currency/real price, ownership, and availability. Rotation comes from versioned server config with a cached fallback. No loot boxes or free spin at launch.

**Dependencies:** Catalog, config, economy, purchases, inventory, asset delivery.

**Acceptance criteria:** Owned items cannot be bought again accidentally; expired offers fail safely; cosmetic preview is accurate; unavailable network never spends local currency; gameplay-critical contrast is preserved.

**Future extensions:** collections, event cosmetics, ethical bundles.

## Purchases

**Purpose:** Sell Brain Chip packs and/or direct cosmetics with store-compliant server verification.

**Requirements:** Use RevenueCat unless the decision checkpoint rejects vendor cost/lock-in. The app initiates platform purchase and restores; trusted webhook/Edge Function maps verified store transaction to one ledger grant. Product IDs are environment-specific. Pending/canceled/failed states are distinct. Never grant from client callback alone.

**Dependencies:** Store accounts/products, RevenueCat, Edge Function webhook, purchase and ledger tables, auth account linkage.

**Acceptance criteria:** Sandbox purchase and restore pass on both stores; replayed webhook is idempotent; refunds/revocations are recorded and handled; no receipt/token is logged; failure never traps the player or charges twice.

**Future extensions:** direct cosmetic products and regional offer tests; no gameplay boosts.

## Monetization rule

Anything purchasable must be cosmetic or currency used only for cosmetics. Ads, subscriptions, battle pass, limited scarcity, and randomized paid rewards are outside launch scope and require a new decision record.
