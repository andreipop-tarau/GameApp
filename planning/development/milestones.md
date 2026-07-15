# Milestones and validation gates

## Foundation history — Tasks 001-015

Tasks 001-014 are implemented and preserved. Task 015 lifecycle code landed, but its final automated/manual verification is uncertain; R1 revalidates equivalent behavior.

## R1 — Two-game vertical slice (Tasks 047-052, current)

**Outcome:** Home launches a deterministic two-game Troll Gauntlet using Stop the Machine and Hold It, three lives, concise failure feedback, and immediate replay.

**Exit:** focused contract/runtime/module/director/run/integration tests pass when run by the developer, then Gate G1 is recorded.

### Gate G1 — first playable slice

Use one real Android device and the implemented accessibility variants. Record pass/fail plus the device/build and any defect; do not replace failures with subjective approval.

- Each objective is understood within approximately one second after it appears.
- Tap and hold show visible response by the next rendered frame; no critical touch-latency issue is observed.
- No duplicate round resolution, score, XP, or progress update occurs during rapid input/replay.
- Backgrounding, pointer cancel, active back, result back, and foreground return follow the documented abandon/resume rule.
- The genuine tell is correctly identified with sound disabled and without relying only on color.
- Reduced motion preserves input-open, genuine-change, success, and failure meaning.
- At 200% text, instructions remain readable and no critical interaction region is hidden.
- `Play Again` starts immediately without route/network wait.
- No critical frame pacing, first-use jank, or hit-target problem is observed on the device.
- During an unprompted observation, the tester chooses `Play Again` at least twice; record the behavior without treating it as a retention statistic.

Any failed safety, determinism, accessibility, or performance item blocks R2. Subjective humor/art issues become narrow follow-ups only when they obscure comprehension or replay interest.

## R2 — Representative catalog proof (Tasks 053-056)

**Outcome:** Five playable games represent tap, hold, drag, swipe, inactivity/deception, and a genuine troll modifier inside the real run loop.

**Dependency:** G1 has no blocking defect.

### Gate G2 — primary-loop evidence

- A completed run is approximately 4-6 minutes under the current 24-round policy, or the measured mismatch is explained and corrected before expansion.
- No identical game appears consecutively and no primary gesture appears more than twice consecutively when alternatives exist.
- First exposure is unmodified/forgiving; modified selection occurs only after demonstrated base competence.
- Two consecutive failures produce the documented easier recovery behavior without hidden life/reward changes.
- All five objectives and failure explanations remain understandable without sound and without color-only cues.
- Home, results, and all five scenes use the approved tokens, tell frame, and feedback states; capture one light and one dark reference set and record any fallback to generic card/grid presentation or inconsistent identity.
- One-handed play, background/back behavior, immediate replay, reduced motion, 200% text, and low-end Android performance still satisfy G1.
- At least one observed tester voluntarily starts multiple runs and can explain the genuine tell and one deception after play; record behavior and comments, not a scientific threshold.

G2 unlocks R3 and detailed planning for R4. A failed core-loop item causes a focused correction task before more catalog or Flow Run work.

## R3 — Local product compatibility (Tasks 057-061)

**Outcome:** Existing saves migrate safely; mastery and personal bests are visible; accessibility settings and interaction-led onboarding persist; the legacy primary-session path is removed.

**Dependency:** G2 passes.

**Exit:** frozen v1 migration fixtures, idempotent progression, restart persistence, first-session behavior, accessibility settings, and reference cleanup are verified. No user reset, purchases, cloud dependency, broad cosmetic system, or production asset framework is introduced.

## R4 — Conditional expansion

**Outcome:** Complete the approved remaining catalog, then Flow Run/Calm/Rush, cosmetics presentation, production assets, and release-quality validation in the order defined by `roadmap.md`.

**Dependency:** G2 passes and R3 data/settings boundaries are stable.

R4 has no active implementation task IDs yet. Create focused prompts immediately before each approved outcome so tests and file boundaries reflect the validated runtime rather than assumptions.
