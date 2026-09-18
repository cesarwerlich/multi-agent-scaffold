# Context

## What This Project Is

A universal repo-initializer template. It produces the scaffolding for new repositories: documentation, CI, scripts, and an optional AI agent subsystem. The payload lives in `init/`; the root maintains source material.

## Who It Serves

Developers starting new projects, and AI coding agents working inside generated repos. Maintainers of the template itself are a secondary audience.

## Internal Structure

- `init/` — the payload copied into new projects (docs, scripts, CI, `.agents/`).
- `skills/`, `agents/`, `references/` — the single source for the agent subsystem, vendored from [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) (MIT — see `NOTICE.md`). Not committed under `init/`; generated into each new repo's `.agents/` at creation time by `new-repo.sh`, `LICENSE` files included.
- `docs/agents/` — shared tool-neutral personas and playbooks in generated repos.
- `docs/adr/` — architectural decisions about the template itself.
- `scripts/` — validation and maintenance tooling.

## Architecture

The template is a file tree, not a runtime system. It has no build step, no dependencies, and no deployment target. The only executable entry points are `scripts/validate-template.sh` and `init/scripts/new-repo.sh`.

New repos receive the `init/` payload. The agent subsystem (`init/.agents/`) is optional — projects that don't use AI agents can delete it.

For multi-tool repos, `AGENTS.md` is the canonical instruction file, while `CLAUDE.md` and `ANTIGRAVITY.md` are thin compatibility wrappers that point back to the shared context.

## Local Commands

```bash
./scripts/validate-template.sh   # verify template integrity
./init/scripts/new-repo.sh /path/to/new-project "Project Name"   # create a new repo
./scripts/adopt-existing-repo.sh /path/to/existing-project   # add missing best-practice files safely
```

## Constraints

- `init/` must stay stack-neutral and generic.
- No project-specific names, URLs, or secrets in the payload.
- Scripts must stay POSIX-friendly Bash.
- Agent skills are helpers, not blockers — local project context always wins.

## Non-Goals

- This is not a framework, a CLI tool, or a SaaS product.
- It does not prescribe a tech stack, package manager, or deployment target.
- It does not replace per-project `CONTEXT.md`, `ROADMAP.md`, or ADRs — it provides the scaffolding for them.
