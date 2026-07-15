# Folder structure

Create a directory only when its first assigned task adds real code.

```text
assets/
  config/
  audio/                    # only when production feedback assets are assigned
  cosmetics/                # only with the local cosmetic catalog
lib/
  app/
  core/
  features/
    gameplay/
      microgame.dart        # v2 pure contract
      microgame_runtime.dart
      troll_modifier.dart
      gauntlet/
      microgames/<microgame_name>/
      challenges/           # legacy pure rules/IDs retained for v1 compatibility after Task 061
    flow_run/
      segments/
      calm/
      rush/
    ai_director/
    brain_profile/
    progression/
    cosmetics/
    settings/
  shared/
    design_system/          # tokens/components with central ownership
    feedback/               # sound/haptic hooks when implemented
test/
  fixtures/
planning/                   # implementation source of truth
Docs/                       # immutable historical source; never implementation input
```

## Conventions

- Files/directories use `snake_case`; types use `UpperCamelCase`; members/providers use `lowerCamelCase`; tests end in `_test.dart`.
- Keep pure rules free of Flutter/vendor imports. Scene widgets live beside their microgame when they are not shared.
- A microgame directory owns generator, validator/reducer/evaluator, scene adapter, and focused tests. Do not build a generic physics/content framework for one game.
- Shared gameplay framework owns phase/instruction/feedback only; it does not switch on every microgame ID. Catalog registrations provide factories/adapters.
- Flow Run remains separate from Troll Gauntlet runtime; share only proven primitives such as clock, seeded random, settings, feedback, and design tokens.
- Add `data/` only when a feature first has real persistence/API work. Add backend/vendor directories only in an assigned future milestone.
- Tests mirror source paths when useful. Frozen save/config fixtures live under `test/fixtures/`.
