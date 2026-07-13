# Task handoff system

`current-task.md` is the only active implementation assignment. It points to one self-contained prompt under `prompts/` and is replaced when the developer advances the backlog; do not append completed task history.

A coding session should load only:

1. `/AGENTS.md`.
2. `/planning/tasks/current-task.md`.
3. The active prompt and only the documents it names.
4. Target files discovered with narrow search.

Do not load all planning documents or anything in `/Docs`. Prompts are implementation handoffs; the backlog is the task index. Permanent decisions belong in `planning/decisions`.

Task completion means implementation and stated verification are complete, scope deviations are reported, and the working tree is left understandable. Agents do not choose the next task automatically.
