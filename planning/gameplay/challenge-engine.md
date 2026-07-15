# Microgame engine, catalog, and troll modifiers

## Runtime v2 contract

The existing `ChallengeModule` contract is deterministic and well tested but resolves from one terminal action and exposes only `tap`, `sequence`, and `choice`. It cannot safely express hold, drag, swipe, trace, continuous tracking, or intentional inactivity. Introduce a v2 microgame boundary beside it, migrate consumers incrementally, and remove the old main-session path only after the full Gauntlet catalog is validated.

Each `MicrogameDefinition` owns pure Dart generation, validation, state reduction, resolution, and failure explanation. Its Flutter scene renders immutable state and converts pointer/semantic actions into typed input events; it does not decide success, navigate, persist, or award progression.

Required types and responsibilities:

- `MicrogameMetadata`: stable identifier/version, primary gesture, skill category, base difficulty/cost, compatible modifier IDs, estimated duration, accessibility flags, and presentation capabilities.
- `MicrogamePlan`: seed/config/version, deterministic parameters, normalized visible interaction regions, input-open rule, time bounds, selected modifier, genuine-tell requirements, and safe-area assumptions.
- `MicrogameInputEvent`: tap, pointer down/move/up/cancel, swipe summary, trace sample, semantic equivalent, and timeout/inactivity tick with monotonic elapsed time.
- `MicrogameState`: immutable mechanic state reduced from the plan and ordered input events.
- `MicrogameResolution`: success/failure, stable reason code, immediate feedback hooks, concise explanation, metrics, and deterministic replay data.
- `MicrogameRuntimeController`: owns phase, monotonic time, ordered event dispatch, pause/abandon, one-result enforcement, and communication with the run controller.

Generation must be deterministic from microgame version, modifier version, config version, seed, difficulty, viewport class, and relevant accessibility settings. Gameplay-relevant motion is derived from elapsed time, never accumulated frames.

### Initial configuration boundary

R1/R2 do not create a general remote-ready content framework. Each microgame owns one small immutable, versioned typed parameter table for its validated difficulty bands; those constants are bundled with the module and validated by its tests. Task 056 may add one minimal typed Gauntlet snapshot for run-policy values plus module enable/version references once five real consumers exist. Module-specific geometry/timing bounds stay with their module. JSON/remote configuration, executable transforms, and a generic schema registry remain deferred until measured tuning needs justify them.

## Fairness and validation invariants

- Every plan has one understandable objective, one primary interaction, and at most one major modifier outside bosses.
- Every required interaction region is visible while relevant, inside the gameplay safe area, at least 44x44 logical pixels for taps, and reachable one-handed under the supported viewport classes.
- Drag/trace/tracking paths include a deterministic beatability proof or multi-seed invariant test with speed, path width, and obstacle clearance bounds.
- Input activation has a visible and semantic signal. Pre-open input behavior is explicit.
- Time limits include accessibility-safe floors and never depend on frame rate or network timing.
- The generated outcome is beatable; decoys and obstructions cannot cover required cues or hit regions.
- Failure produces a stable reason and one- or two-line explanation.
- No hidden hitboxes, input lag, impossible seeds, OS-UI imitation, paid/device-warning deception, or punishment for leaving.

## Primary gestures

`tap`, `hold`, `drag`, `swipe`, `trace`, `continuousTrack`, and `intentionalInactivity`. A game may observe release/cancel as part of its primary gesture, but it may not quietly require a second unrelated gesture. The director treats intentional inactivity as its own gesture for repetition control.

## Initial catalog and current-code reuse

| Microgame | Gesture | Existing evidence/reuse | Initial action |
|---|---|---|---|
| Don't Press It | inactivity, then tap after genuine change | Reaction Tap cue/timing/evaluation concepts | Adapt later; remove old quiz presentation from main run |
| Escape Button | tap | Selective Attention seeded layout/decoy invariants | Adapt generator ideas; replace static grid UI |
| Protect the Egg | drag | none beyond deterministic primitives | New module |
| Feed the Idiot | drag | Selective Attention uniqueness checks | New module with reusable target/decoy validation |
| Hold It | hold | Reaction Tap timing and lifecycle ownership | New v2 module; first vertical slice |
| Wrong Way | swipe | none | New module |
| Keep Inside | continuous tracking | timing/lifecycle clock seams | New module |
| Parking Disaster | drag | none | New module |
| Clean the Screen | trace/wipe, then tap as one staged mechanic | sequence phase concepts | New module |
| Stop the Machine | tap | Timing Stop generator, elapsed-time motion, validator, tests | Adapt first; first vertical slice |
| Boss: The App Is Broken | discovery drag/other declared boss gesture | runtime phases and modifier composition | New rare boss after normal catalog |

### Existing module disposition

- **Reaction Tap — Adapt:** reuse cue timing, early/correct/timeout evaluation ideas, and tests for Don't Press It/Hold It. Remove its current button-grid presentation from the main session after replacements pass.
- **Sequence Memory — Defer to secondary content:** keep deterministic generator/evaluator/tests; its long observe-and-repeat loop is not primary Gauntlet pacing. Reassess as an occasional unmodified bonus, never preserve by default.
- **Selective Attention — Adapt:** reuse deterministic target uniqueness, reachable/non-overlapping layout validation, and metrics for Escape Button/Feed the Idiot. Replace the static quiz grid.
- **Timing Stop — Migrate:** it is the closest match to Stop the Machine. Preserve elapsed-time motion, seeded zone generation, evaluator, semantics, and boundary tests behind v2.
- **Logic Choice — Defer to secondary content:** keep templates/evaluator/tests but remove from the main Gauntlet because text-choice presentation conflicts with the direct-manipulation direction.

Do not delete a legacy module until its replacement is integrated, save compatibility is proven, and the legacy catalog cutover task is complete.

## Deterministic modifier contract

Every modifier declares stable ID/version, compatible microgames/gestures, seed derivation, difficulty cost, plan transform, fairness constraints, accessibility behavior, failure explanation contribution, and required deterministic/invariant/widget tests. The seed is split by stable namespace (`run -> round -> microgame -> modifier`) so adding cosmetic randomness cannot change gameplay.

| Modifier | Compatible use | Cost | Fairness and accessibility constraints | Required tests |
|---|---|---:|---|---|
| Target-position swap before input opens | tap, drag | 1 | completes before the input-open signal; final target remains visible/reachable | seed replay, final bounds, no post-open swap |
| Decoy targets | tap, drag | 1 | one genuine target; decoys differ by non-color semantics and cannot overlap it | uniqueness, reachability, semantic labels |
| Inverted rule | swipe, tap-rule games | 2 | instruction and genuine tell appear before input; no mid-gesture inversion | rule timing, text/shape cue, failure reason |
| Moving target | tap, drag | 1-3 | speed/route bounded; reachable window meets configured floor | path invariants, low-FPS elapsed-time replay |
| Fake instruction | all compatible games | 2 | may copy one tell signal but never the full genuine pattern | tell matrix, screen reader wording, reason code |
| Genuine instruction change | all compatible games | 2 | uses the complete central tell and leaves adequate reaction time | multimodal tell, timing floor, recognition check |
| Visual obstruction | tap, drag, trace | 1 | never covers required cue/hit region beyond bounded percentage | occlusion geometry, contrast, reduced motion |
| Temporary direction reversal | moving/runner mechanics | 2 | announced by genuine tell before change; bounded duration | elapsed-time path, pause/resume, cue timing |
| Fake pointer | tap/drag | 1 | visually distinct without relying only on color; never intercepts input | hit testing, semantics exclusion, contrast |
| Shrinking valid region | hold, tracking, timing | 1-3 | minimum size and shrink rate remain beatable for selected difficulty | size floor, multi-seed beatability, large text |
| Harmless decoy hazards | drag, tracking, runners | 1 | decoys never collide or conceal real hazards | collision exclusion, visual/semantic distinction |

Major modifier cost is added to base difficulty. Normal rounds allow a total modifier cost of at most 2 initially; bosses may use documented combinations after dedicated validation. Cosmetic or joke reactions have zero gameplay cost and cannot alter hitboxes or timing.

## First vertical slice selection

1. **Stop the Machine:** proves the v2 adapter with a discrete tap while preserving the strongest working generator and frame-independent motion.
2. **Hold It:** proves pointer down/move/up/cancel, continuous elapsed-time state, early release, lifecycle cancellation, and accessibility alternatives.

This pair is lower risk and more architecturally useful than two tap games. It deliberately postpones drag/trace physics until the runtime and visual language have passed manual validation.

## Legacy compatibility period

The old `ChallengeModule`, five modules, v1 config, and current `GameSessionController` may coexist with v2 through representative-catalog Task 056. New microgames never depend on old UI types. Task 056 makes v2 the primary route; Task 061 removes the unreachable legacy main-session path while preserving pure legacy rules/IDs until Task 057 proves persistence compatibility and the user decides secondary-content disposition.
