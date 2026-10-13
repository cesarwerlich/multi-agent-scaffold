# Project Name

Short description of what this project does, who it serves, and why it exists.

## Quick Start

```bash
./scripts/bootstrap.sh
./scripts/check.sh
```

If the project needs environment variables:

```bash
cp .env.example .env
```

## Project Context

Read these first (kept small on purpose):

- `CONTEXT.md` - purpose, architecture, constraints, and local commands.
- `TASKS.md` (local-only; use the Issue/PR for GitHub work) - current objective, active work, and handoff between sessions.
- `DECISIONS.md` - accepted decisions still in force.
- `AGENTS.md` - the canonical contract for AI coding agents.

Read on demand:

- `docs/roadmap.md` - priorities and open questions.
- `docs/memory.md` - durable facts, traps, and compiled Q&A.
- `docs/journal.md` - chronological notes and discussion outcomes.
- `docs/testing.md` / `docs/evals.md` - verification and benchmark notes.
- `docs/agents/lane-protocol.md` - issue lanes, worktrees, and coordinator rules when multiple agents work in parallel.
- `CLAUDE.md` and `ANTIGRAVITY.md` - thin tool wrappers that point back to `AGENTS.md`.

## Common Commands

```bash
./scripts/bootstrap.sh  # install/setup what this repo needs
./scripts/check.sh      # run stack-aware verification
# optional: lane/worktree helpers (requires Node.js for lane-update.mjs)
AGENT_TOOL=claude ./scripts/worktree-bootstrap.sh <issue-n> <slug>
node ./scripts/lane-update.mjs --help
```

## Repository Layout

```text
.
  CONTEXT.md      Purpose, architecture, constraints
  TASKS.md        Optional local-only handoff
  DECISIONS.md    Accepted decisions still in force
  AGENTS.md       Canonical contract for AI coding agents
  scripts/        Bootstrap, checks, and project automation
  .agents/        Optional agent skills, personas, and references
  docs/           Project docs and knowledge base
    roadmap.md      Priorities and open questions
    memory.md       Durable facts, traps, and compiled Q&A
    journal.md      Chronological working log
    testing.md      Testing strategy and verification notes
    evals.md        Evaluation or benchmark notes, when relevant
    operations.md   Deploy, rollback, observability
    release.md      Release and rollback checklists
    adr/            Architectural decision records
    history/        Archived journal entries
    specs/          Feature specs, when relevant
    agents/         Shared personas and playbooks for any agent tool
```

Update this section as the project takes shape.
