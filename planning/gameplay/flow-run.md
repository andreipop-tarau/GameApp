# Flow Run design

`Flow Run` is the internal shared deterministic runner system behind the player-facing Calm Run and Rush Run modes.

## Shared contract

- Portrait-only, automatic forward motion, one-touch jump, optional hold for longer jump.
- Seeded ordering of handcrafted, versioned obstacle segments; no runtime-generated impossible geometry.
- Physics uses fixed simulation steps or elapsed-time deterministic integration with explicit tolerances and replay tests.
- A segment declares entry/exit state ranges, obstacle silhouettes/collision shapes, jump windows, rhythm/intensity, Calm/Rush eligibility, reduced-motion behavior, and cosmetic-safe layers.
- Validation proves reachable transitions between adjacent segments for supported speed/jump parameters.
- Cosmetics and parallax never alter collision shapes or obscure timing boundaries.
- Pause/resume and app lifecycle cannot advance hidden simulation time or duplicate results.

## Calm Run

Duration is 60-90 seconds. Segment selection favors predictable rhythm, generous windows, low object density, and a gradual final-third cooldown. No lives, death screen, competitive countdown, combo pressure, or forced restart. Collision applies one documented non-terminal response per environment: a short bounded rewind, soft bounce, or temporary slowdown. The player continues in the same run.

Music, ambience, effects, and haptics are optional and independently controlled. The mode remains understandable without them and is described only as an optional mental-reset activity, never treatment.

## Rush Run

Rush uses stronger speed/rhythm, increasing validated difficulty, distance score, visible combo, personal best, instant restart, and controlled camera feedback. Segment combinations remain seeded and handcrafted. A collision ends the scored attempt under one clear rule. Results prioritize distance, personal-best difference, one insight, and `Play Again`.

## Presentation

Both modes share Trapling characters and brand shapes. Calm reduces density, contrast changes, camera effects, and simultaneous movement; calmness comes from predictability and pacing rather than mandatory pastel colors. Rush can add rhythm pulses, richer environment movement, and combo feedback while preserving obstacle silhouettes.

## Accessibility and performance

Provide reduced camera/background motion, sound-independent rhythm cues, haptic/music/effect toggles, pause/resume, large-text-safe overlays, and color-independent obstacles. Normal gameplay targets 60 FPS on the selected low-end Android validation device, next-frame touch response, bounded active actors/particles, and no real-time blur in the playfield.

## Delivery order

Build the segment/physics validator first, then Calm Run, then Rush Run, then shared persistence/cosmetic integration. Flow Run starts only after the Troll Gauntlet vertical slice and full normal microgame catalog validate the v2 runtime and visual system.
