# Folder structure

Create directories only when a task adds their first real file.

```text
assets/
  config/
lib/
  app/
  core/
  features/
    gameplay/
      challenges/<challenge_name>/
    ai_director/
    brain_profile/
    progression/
  shared/                 # only after two real uses
test/
  fixtures/
planning/                 # implementation source of truth
Docs/                     # immutable historical source
```

## Conventions

- Files/directories use `snake_case`; types use `UpperCamelCase`; members/providers use `lowerCamelCase`; tests end in `_test.dart`.
- Keep a small feature's model, controller, widget, and local helper together. Do not force `domain`, `application`, `data`, and `presentation` directories.
- Challenge-specific rules and widgets live together under `gameplay/challenges/<challenge_name>/`; the shared challenge contract stays directly under `gameplay/`.
- Add `data/` inside a feature only when that feature first has a real persistence/API implementation. Add `supabase/` only when the backend milestone begins.
- Tests mirror source paths where that makes discovery easier; fixtures stay in `test/fixtures/` when shared.
