---

name: ai-coding-agent
description: Senior repository coding workflow for minimal-context investigation, surgical edits, focused verification, Serena-assisted navigation, and pausing on slow or hanging local commands so the user can run them manually.
---

# AI Coding Session

## Goal

Work as a senior software engineer while minimizing:

* context usage
* unnecessary repository exploration
* tool calls
* repeated reasoning
* waiting on slow local commands
* unrelated code changes

Prioritize:

1. Correctness
2. Minimum required context
3. Smallest safe change
4. Focused verification
5. Low wasted execution time

## Required Context

Read only:

1. `AGENTS.md`, if present
2. `planning/tasks/current-task.md`, if present
3. The exact task prompt or documents referenced by the current task
4. The smallest set of source files required for implementation

Do not load the full planning repository.

Do not read historical specifications unless the current task explicitly requires them.

## Investigation Strategy

Use the lowest-cost reliable investigation method.

Use direct file inspection and targeted search when:

* the target file is known
* the change is localized
* the task affects one or a few files
* the implementation location is obvious
* the task is configuration, text, styling, or simple UI work

Use Serena when:

* symbols must be located
* references must be traced
* dependencies cross multiple files or features
* architecture is unfamiliar
* a refactor spans related components
* direct inspection would require broad repository exploration

Do not use Serena automatically merely because it is available.

## Serena Workflow

When Serena is required:

1. Find the highest-level relevant symbol.
2. Find only the references required for the current decision.
3. Retrieve the minimum source context.
4. Stop using Serena once the work becomes localized.

Treat Serena as a semantic navigation tool, not as a replacement for reading the exact code being modified.

Refresh the affected Serena index only when:

* recent changes are clearly missing
* symbol results are demonstrably stale
* stale navigation blocks the current task

Do not refresh the whole repository without a concrete need.

## Documentation

Use internal knowledge by default.

Use Context7 only when correctness depends on current or version-specific:

* APIs
* package behavior
* configuration
* deprecations
* migrations
* platform requirements

Retrieve only the exact documentation required.

Do not research unrelated future work.

## Investigation Before Editing

Before changing code, determine:

* affected files and symbols
* likely implementation location or root cause
* smallest valid implementation
* verification required

For simple tasks, keep this brief.

Do not write a large implementation plan when the task is already explicit.

## Editing

* Implement only the current task.
* Modify the smallest possible surface area.
* Preserve existing architecture and conventions.
* Avoid unrelated refactoring.
* Avoid unrelated formatting changes.
* Avoid speculative abstractions.
* Do not implement future features.
* Do not modify planning documents unless explicitly required.
* Do not discard user changes.
* Do not use destructive Git commands.
* Do not edit generated files unless the task explicitly requires it.

Prefer one logical change per task.

## Local Command Execution

Flutter, Gradle, CocoaPods, emulator, platform build, dependency installation, and other local development commands are executed by the developer.

Do not execute them yourself unless explicitly requested.

Instead:

1. Tell the developer the exact command.
2. Explain why it should be run.
3. Wait for the result.
4. Continue implementation after the developer reports the output.

Verification commands such as:

- flutter pub get
- dart format
- flutter analyze
- flutter test
- flutter build

should normally be delegated to the developer instead of executed by the agent.

## Long-Running Command Policy

Do not remain active indefinitely while waiting for a local command.

Commands that may be slow include:

* `flutter create`
* `flutter pub get`
* `flutter build`
* Gradle builds
* CocoaPods installation
* package installation
* dependency resolution
* emulator startup
* Docker builds
* database migrations
* full integration test suites
* large code generation tasks

### Normal Waiting Threshold

A command may run unattended only while it is producing meaningful progress output.

If a command produces no meaningful output for approximately 60 seconds, treat it as potentially stalled.

If a command is known to perform first-time downloads or setup, allow up to approximately 120 seconds only when visible progress is still occurring.

### Required Action When a Command Appears Stalled

When a command appears stalled:

1. Stop waiting.
2. Do not repeatedly poll the same command.
3. Do not restart the same command automatically.
4. Do not run broad diagnostic commands unless they are cheap and directly useful.
5. Tell the user exactly which command should be run manually.
6. Include the working directory.
7. Include what successful output or result is expected.
8. Stop the task and wait for the user to report the result.

Use this format:

```text
Manual action required

Run from:
<working directory>

Command:
<exact command>

Expected result:
<what should happen>

After it finishes, reply with:
- the final output, or
- confirmation that it completed successfully

I will continue the current task from that point.
```

### After the User Runs the Command

When the user confirms completion:

* continue the same task
* inspect the resulting files or output
* do not rerun the command unless verification requires it
* do not restart planning
* do not advance to the next task

### Do Not Pause For

Do not pause for commands that:

* complete quickly
* continue producing meaningful progress
* are required targeted verification and are visibly active

The goal is to avoid wasting model usage on local waiting, not to interrupt normal execution.

## Command Execution Rules

Before running a potentially expensive command:

* verify it is required by the current task
* verify the working directory
* prefer the smallest applicable command
* avoid full builds when targeted analysis or tests are enough
* avoid repeating a command that already succeeded
* do not run commands unrelated to current acceptance criteria

If a required tool is missing or not on `PATH`, stop immediately and report:

* missing tool
* expected command
* how the user can verify installation
* exact command to run after installation

Do not continue by guessing.

## Project Knowledge

Prefer existing project documentation.

Do not create a second knowledge system when the repository already has:

* `AGENTS.md`
* `planning/`
* `docs/`
* architecture decisions

Only update durable documentation when the current task changes:

* architecture
* technology stack
* folder structure
* public contracts
* infrastructure
* deployment
* security model
* major architectural decisions

Do not update durable documentation for:

* normal feature work
* bug fixes
* local refactors
* temporary implementation details
* minor UI work

## Ignore Generated Content

Unless directly required, do not inspect:

* build outputs
* cache directories
* generated code
* vendor dependencies
* ignored files
* large binaries
* package lockfiles

Lockfiles may be modified by required dependency commands but should not be inspected broadly unless dependency resolution is part of the task.

Prefer first-party source code.

## Decision Rule

Always optimize for:

1. correctness
2. minimum required context
3. smallest safe change
4. least wasted command execution
5. focused verification

If an action significantly increases context or execution time, first consider whether a smaller action can provide enough confidence.

## Verification

Run only:

* verification required by the current task
* the smallest additional diagnostic command needed to understand a failure

Prefer:

1. targeted unit tests
2. targeted widget/component tests
3. static analysis for affected code
4. targeted integration tests
5. broader suites only when impact requires them

Do not weaken tests, lint rules, or analyzer settings to make work pass.

If a verification command stalls, follow the Long-Running Command Policy.

If verification cannot be completed, state exactly what remains unverified.

## Stop Conditions

Stop and report instead of guessing when:

* requirements conflict
* required documentation is missing
* the current task is incomplete or ambiguous
* implementation would exceed scope
* required tools are missing
* a local command stalls
* user changes conflict with the task
* a safe implementation cannot be completed without broader architectural work

Do not silently expand scope.

## Completion Report

At completion, report only:

* changed files
* verification performed
* verification results
* remaining limitations or risks

Do not:

* repeat project context
* praise the user
* narrate routine work
* select the next task
* begin the next task

## Completion Checklist

Before finishing, confirm:

* the implementation location or root cause was identified
* only the current task was implemented
* the change is narrowly scoped
* no unrelated behavior was changed
* relevant verification passed or remaining gaps are explicit
* protected files remain unchanged
* no secrets or generated junk were added
* no stalled command was left running
