# Adopting The Template In Existing Repos

Use `scripts/adopt-existing-repo.sh` when a repository already exists and you want to add the template's best-practice structure without creating conflicts.

## Default Rule

Adoption is additive and no-overwrite by default. Existing files stay authoritative.

## Usage

```bash
./scripts/adopt-existing-repo.sh /path/to/existing-repo
```

Preview without writing:

```bash
./scripts/adopt-existing-repo.sh --report-only /path/to/existing-repo
```

Profiles:

- `minimal`: core docs, agent guidance, memory, journal, roadmap, testing, evals, security, operations, basic scripts, and lane/worktree coordination scaffolding.
- `github`: minimal plus GitHub issue, PR, CI, and security workflow templates when missing.
- `full`: every top-level item from `init/`, still no overwrites.

Optional:

```bash
./scripts/adopt-existing-repo.sh --with-evals-dir /path/to/existing-repo
```

This creates `evals/README.md` only when a repo needs repeatable eval datasets, fixtures, run logs, or benchmark artifacts.

## What Gets Created

The minimal profile creates these files (never overwrites existing ones):

| File | Purpose |
| --- | --- |
| `CONTEXT.md` | Purpose, architecture, constraints — fill in after adoption |
| `TASKS.md` (local-only; use the Issue/PR for GitHub work) | Optional local-only handoff; GitHub work stays on Issues/PRs |
| `DECISIONS.md` | Accepted decisions still in force |
| `AGENTS.md` | Canonical agent contract (session start, coordination, safety) |
| `PLAYBOOK.md` | Why each area exists and how to use it — onboarding for humans and agents |
| `CLAUDE.md` | Thin pointer → `AGENTS.md` |
| `ANTIGRAVITY.md` | Thin pointer → `AGENTS.md` |
| `docs/roadmap.md` | Priorities and open questions |
| `docs/memory.md` | Durable facts, traps, compiled Q&A |
| `docs/journal.md` | Chronological notes and discussion outcomes |
| `docs/testing.md` | Testing strategy |
| `docs/evals.md` | Evaluation or benchmark notes |
| `docs/operations.md` | Deploy, rollback, observability |
| `SECURITY.md` | Security policy |
| `SUPPORT.md` | Support channels |
| `scripts/bootstrap.sh` | Install/setup automation |
| `scripts/check.sh` | Stack-aware verification |

The `full` profile also generates `.agents/` (skills, personas, references) from the template's root source.

## Folder Guidance

- `AGENTS.md`: canonical shared instructions for Codex, Claude, Antigravity, Copilot, and other coding agents.
- `CLAUDE.md`, `ANTIGRAVITY.md`: thin compatibility wrappers that point back to `AGENTS.md`.
- `docs/agents/`: tool-neutral playbooks, rubrics, and personas.
- `docs/agents/lane-protocol.md`: recommended when the repo will use multiple agents or worktrees in parallel.
- `.agents/`: optional bundled skills, specialist personas, and references — generated, not committed.
- `.claude/`: create only when the target repo needs Claude-native agents, commands, settings, or skills.
- `docs/`: recommended for durable project documentation.
- `docs/memory.md`: durable facts and compiled Q&A that would otherwise be lost in chat.
- `tests/`: create when the repo contains code and has a real test suite.
- `evals/`: create only for repeatable eval artifacts (datasets, fixtures, run logs).
- `src/`: do not create automatically. Existing repos decide their source layout.

## Manual Merge Policy

When the adoption script skips an existing file, review it manually. Do not replace mature project files with generic template files unless the owner explicitly chooses to.
