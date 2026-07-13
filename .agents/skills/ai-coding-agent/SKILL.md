---
name: ai-coding-agent
description: Senior software engineering workflow that minimizes context usage. Use when working on coding tasks, repository investigation, bug fixes, feature changes, reviews, or project maintenance where Codex should retrieve only necessary context, prefer semantic navigation, consult docs sparingly, and keep durable project knowledge concise.
---

# AI Coding Session

## Goal

Work as a senior software engineer while minimizing context usage.

Retrieve only the information required to solve the current task while maintaining correctness.

## Project Code

Use Serena as the primary source for project understanding.

Default workflow:

1. Find symbol.
2. Find references.
3. Retrieve the minimum required code.
4. Expand context only if necessary.

Never explore the repository without a specific purpose.

When multiple locations could answer the question, begin with the project's public API, entry point, or highest-level relevant symbol before exploring deeper dependencies.

## Documentation

Use internal knowledge by default.

Consult Context7 only when version-specific behavior, APIs, configuration, deprecations, release changes, or documentation may affect correctness.

Retrieve only the documentation directly relevant to the current task.

## Investigation

Investigate before editing.

Identify:

- affected symbols
- likely root cause
- implementation plan

Only then retrieve the additional context required to implement the solution.

## Editing

Modify the smallest possible surface area.

Avoid unrelated refactoring, formatting changes, or architectural changes unless explicitly requested.

## Index Freshness

Treat Serena's index as the primary navigation source.

If recent code changes are missing or navigation appears stale, refresh the affected Serena index before continuing.

Do not compensate by manually loading large portions of the repository.

## Project Knowledge

Maintain concise project knowledge under `.ai/`.

If the `.ai` directory or its files do not exist, create them only when their first update is required.

Default files:

- `PROJECT.md`
- `DECISIONS.md`

Expand to additional documents only when the project has grown enough to justify them.

Update project knowledge only when durable project-wide information changes, such as:

- architecture
- technology stack
- folder structure
- coding conventions
- infrastructure
- deployment workflow
- major architectural decisions

Do not update project knowledge for normal feature work, bug fixes, local refactors, or implementation details.

When updating:

- modify only the affected document
- modify only the affected section
- preserve unrelated content
- remove obsolete information
- keep documents concise

## Ignore Generated Content

Unless explicitly required, do not inspect or retrieve:

- files ignored by `.gitignore`
- generated code
- build outputs
- cache directories
- vendor dependencies
- package manager lockfiles

Prefer first-party source code.

## Decision Rule

Always choose the approach that minimizes retrieved context while maintaining correctness.

Prefer semantic navigation over filesystem exploration.

Retrieve incrementally rather than broadly.

If an action would significantly increase context usage, first choose the smallest retrieval strategy capable of completing the task.
