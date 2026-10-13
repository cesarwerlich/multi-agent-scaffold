# ADR 0001: Template Structure

## Status

Accepted. Amended 2026-06-13 (agent subsystem is generated, not committed; `AGENTS.md` is canonical; payload knowledge/ops docs moved under `docs/`).

## Context

New projects need consistent scaffolding: documentation, CI, scripts, and optional AI agent guidance. A central template avoids rederiving this per project. The key question: how should the template be organized so source material is maintainable and the generated payload stays clean?

## Decision

1. **`init/` is the payload, root is the source.** Most files copied into new projects live under `init/`. Root-level `skills/`, `agents/`, and `references/` are the single canonical source for the agent subsystem; they are **not** committed under `init/`. Instead `new-repo.sh` generates them into each new repo's `.agents/` at creation time. *(Amended: the original design committed a hand-synced copy under `init/.agents/`. That copy was byte-identical to root and drifted only by human error, so it was replaced with generation-at-create-time — one source, zero stored duplication.)*

2. **Agent subsystem is optional and bundled under `.agents/`.** Skills, personas, and reference checklists ship as `.agents/` inside the payload. Projects that don't use AI coding agents can delete the directory. Projects that do can customize or extend it.

3. **Shell scripts over a generator framework.** `bootstrap.sh`, `check.sh`, and `new-repo.sh` are small, POSIX-friendly Bash scripts with no dependencies. They detect the project's stack from marker files (`package.json`, `go.mod`, `pyproject.toml`, `Cargo.toml`) rather than requiring configuration. This keeps the template zero-dependency and easy to audit.

4. **`AGENTS.md` is canonical; tool adapters exist only where a tool needs one.** `AGENTS.md` holds the full contract (session start, multi-session coordination, safety, verification). Adapters carry no separate policy. *(Amended for #12: a prose pointer does not load anything. `CLAUDE.md` now imports `@AGENTS.md`, because Claude Code skips `AGENTS.md` when a `CLAUDE.md` exists. `ANTIGRAVITY.md` was removed because Antigravity reads `AGENTS.md` and no tool loads that file. See `init/docs/agent-tool-loading.md`.)* *(Amended: originally `CLAUDE.md` was described as the primary file, which contradicted the canonical-`AGENTS.md` model used everywhere else.)*

## Consequences

- Easier: The agent subsystem has one home (root) and is generated on demand, so there is no committed copy to keep in sync.
- Easier: New projects start with a safety baseline (`SECURITY.md`, `docs/operations.md`) without any tooling dependency.
- Harder: Adding a new required payload file means updating both the `init/` tree and `scripts/validate-template.sh`.
- Constraint: `init/` must stay stack-neutral — no project-specific names, URLs, or secrets.

## Alternatives Considered

- **Generator CLI tool:** Would centralize options but adds a dependency, maintenance burden, and platform-specific behavior. Rejected in favor of auditable shell scripts.
- **Single AGENTS.md with no CLAUDE.md:** Some agent tools prefer `CLAUDE.md`. Rather than force a rename, both files exist and `CLAUDE.md` delegates.
- **Flat init/ without `.agents/` subdirectory:** Would put 22 skill files in `init/` directly. The `.agents/` namespace keeps the agent subsystem separable and deletable.
