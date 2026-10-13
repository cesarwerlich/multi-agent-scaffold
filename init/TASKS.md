# Tasks (local-only workflow)

Use only when GitHub Issues/PRs are not used for live work tracking. For GitHub
work, record handoff on the Issue/PR and leave this file unused. Never mirror
live state between both surfaces.

Live handoff file between work sessions — human or AI, single or concurrent.
This is the one place that answers: *what is being worked on right now, by whom,
and what is the next action?* Keep it short and current. It is rewritten in
place, not appended forever.

- Durable architecture/context → `CONTEXT.md`
- Accepted decisions → `DECISIONS.md`
- Future direction → `docs/roadmap.md`
- Durable lessons / traps → `docs/memory.md`
- Historical narrative → `docs/journal.md` (or just `git log`)

## How To Use

- **At session start:** read this file. If you begin work, add or update your row
  in *Active Work* to claim it (your branch or worktree is the lock key).
- **Before you stop:** update the *Current Handoff* block with the next action and
  any blockers, and move finished items into *Recently Done*.
- **Keep it lean.** When a fact becomes durable, promote it (see links above) and
  remove it from here. Do not let this file accumulate history.

## Active Work

One row per in-flight task. Concurrent sessions coordinate here: claim by branch
or worktree, never edit another session's active task.

| Task | Owner / session | Branch / worktree | Updated | Next step | Blockers |
| --- | --- | --- | --- | --- | --- |
<!-- | Example feature | claude-cli | feat/login | 2025-01-01 | wire validation | none | -->

## Current Handoff

- **Current objective:** <!-- the larger goal this work serves -->
- **Current status:** <!-- not started | in progress | blocked | ready for review -->
- **Active task:** <!-- the one concrete thing being done now -->
- **Definition of done:** <!-- how we know this task is complete -->
- **Files likely involved:** <!-- paths a next session should look at first -->
- **Next action:** <!-- the single next step to take -->
- **Blockers:** <!-- what is stopping progress, if anything -->
- **Notes for the next agent/session:** <!-- context that is not yet durable -->

## Recently Done

Keep only the last few. Older history belongs in `git log` or `docs/journal.md`.

```text
YYYY-MM-DD - what shipped - where it landed
```
