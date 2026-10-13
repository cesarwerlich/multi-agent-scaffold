# AGENTS.md

Guidance for AI coding agents working on this template repository.

## Repository Purpose

This repository maintains a universal repo initializer. The copyable project payload lives in `init/`. The root-level `skills/`, `agents/`, `references/`, and `docs/` folders are source material for the optional agent subsystem included in new projects at `init/.agents/`.

## Start Here

1. Read `README.md` to understand the template layout, then `CONTEXT.md` for architecture and constraints.
2. Inspect `init/` before changing any project bootstrap behavior.
3. Use matching skills from `skills/` when the task benefits from a workflow, but gather repo context first.
4. Preserve user changes. Do not revert unrelated edits.

## Editing Rules

- Keep root docs about maintaining the template itself.
- Keep `init/` files generic and stack-neutral unless a file is explicitly stack-specific.
- Do not add project-specific names, URLs, secrets, or hardcoded package-manager assumptions to the payload.
- Prefer small shell scripts with clear output over a generator framework.
- When adding a new required payload file, update `scripts/validate-template.sh`.
- Treat `AGENTS.md` as canonical for shared instructions. `CLAUDE.md` only imports it (`@AGENTS.md`) plus Claude-only notes; add no adapter a supported tool does not load. Tool loading facts live in `init/docs/agent-tool-loading.md`.

## Agent Skills

Skills are workflows, not mandatory blockers. Use them when they match the work:

- New template capability or larger change: `spec-driven-development`, then `planning-and-task-breakdown`.
- Script or behavior change: `test-driven-development` where practical.
- Security, secrets, auth, or dependency policy: `security-and-hardening`.
- CI or automation: `ci-cd-and-automation`.
- Documentation structure or ADRs: `documentation-and-adrs`.
- Existing repo adoption flow: keep it additive and no-overwrite by default.

If a skill conflicts with local project instructions, local project instructions win.

### Skill Groups

Skills ship in `skills/` and are generated into `.agents/skills/` at repo creation time.

- Define and plan: `idea-refine`, `spec-driven-development`, `planning-and-task-breakdown`
- Build: `incremental-implementation`, `test-driven-development`, `context-engineering`, `source-driven-development`
- Interfaces and UI: `api-and-interface-design`, `frontend-ui-engineering`, `browser-testing-with-devtools`
- Discovery: `web-app-capability-audit`
- Verify and recover: `debugging-and-error-recovery`, `code-review-and-quality`, `code-simplification`
- Production readiness: `security-and-hardening`, `performance-optimization`, `ci-cd-and-automation`, `shipping-and-launch`
- Maintenance: `git-workflow-and-versioning`, `deprecation-and-migration`, `documentation-and-adrs`

### Maintaining Skills

- Every skill lives in `skills/<name>/SKILL.md` with YAML frontmatter (`name`, `description`).
- Keep each skill file focused on workflow and exit criteria. Put long checklists in `references/`.
- Run `./scripts/validate-template.sh` after changing skills.
- The root `skills/`, `agents/`, `references/` directories are the single source — never commit copies under `init/`.

## Safety Rules

- Never commit `.env`, secrets, tokens, generated credentials, or private keys.
- Ask before changing security-sensitive defaults, CI enforcement, or scripts that overwrite user files.
- Run `./scripts/validate-template.sh` before finishing template changes.
- When changing generated-project scripts, dry-run a temporary generated repo and run its check script (`init/scripts/check.sh` in the payload).
- Do not invent missing project facts; record unknowns in `JOURNAL.md` or ask.

## Memory

Use `JOURNAL.md` for template-maintenance notes. New repos get their own `init/docs/memory.md` and should not inherit template-maintenance history.
