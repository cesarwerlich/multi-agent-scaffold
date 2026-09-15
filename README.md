# Universal Repo Init Template

[![CI](https://github.com/cesarwerlich/repo-template/actions/workflows/ci.yml/badge.svg)](https://github.com/cesarwerlich/repo-template/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Reusable starter files for new repositories and work folders. The template is intentionally stack-neutral: it gives each project a clear operating model, agent instructions, memory, security/ops docs, and lightweight scripts without assuming Node, Python, Go, Rust, or any single deployment target.

It is also tool-neutral: `AGENTS.md` is the canonical shared contract, while `CLAUDE.md` and `ANTIGRAVITY.md` are thin compatibility wrappers that point back to the shared docs.

## Why This Exists

I run several AI coding agents in parallel across different projects — each in its own git worktree, each accountable to an issue and a PR, none of them allowed to merge their own work. That only stays sane if every repo starts from the same operating model: where memory lives, how a lane is picked up and closed out, what "done" means before a human looks at it. This is that starting point, extracted once instead of rebuilt per project. It's plain scripts and docs, not a framework — audit it in a few minutes, keep what's useful, delete what isn't.

## What Gets Copied

The `init/` directory is the payload for new projects:

```text
init/
  README.md
  CONTEXT.md       Purpose, architecture, constraints     ┐ startup
  TASKS.md         Live handoff: active work, next action  ├ reads
  DECISIONS.md     Accepted decisions still in force       ┘
  AGENTS.md        Canonical agent contract
  CLAUDE.md        Thin wrapper -> AGENTS.md
  ANTIGRAVITY.md   Thin wrapper -> AGENTS.md
  PLAYBOOK.md      Why each area exists and how to use it
  SECURITY.md  SUPPORT.md  CONTRIBUTING.md  CODEOWNERS   (kept at root for GitHub)
  .env.example  .gitignore  .editorconfig
  CLAUDE.local.md.example   Copy → CLAUDE.local.md (gitignored) for machine-specific config
  scripts/
    bootstrap.sh
    check.sh
    lane-update.mjs
    worktree-bootstrap.sh
    worktree-finish.sh
    worktree-cleanup.sh
    check-commit-identity.sh
    new-repo.sh
  .github/
    workflows/{ci.yml, security.yml}
    pull_request_template.md
    ISSUE_TEMPLATE/
  .agents/
    README.md         (skills/, agents/, references/ generated at create time)
  docs/
    roadmap.md  memory.md  journal.md
    testing.md  evals.md  operations.md  release.md
    adr/  history/  specs/  agents/  runbooks/  template-adoption/
```

The root `skills/`, `agents/`, and `references/` folders are the single source for the bundled agent subsystem, vendored from [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) (MIT — see [`NOTICE.md`](NOTICE.md)). They are **not** committed under `init/`; instead `new-repo.sh` generates them into each new repo's `.agents/` at creation time, `LICENSE` included, so there is no stored duplicate to drift. `docs/agents/` ships as a shared home for tool-neutral personas and playbooks.

The default payload also includes lane coordination scaffolding for teams that want one issue, one worktree, and one PR per agent lane: `worktree-bootstrap.sh` opens a lane, `worktree-finish.sh` verifies it (clean tree, not behind its base, checks pass) and opens the PR, and it's never allowed to merge itself.

## Use It

### New repository

```bash
./init/scripts/new-repo.sh /path/to/new-project "Project Name"
```

Then in the new project:

```bash
./scripts/bootstrap.sh
./scripts/check.sh
```

If the target folder already exists, `new-repo.sh` copies only missing files and leaves existing files untouched.

### Existing repository

Already have a repo and want to add the template's docs, agent guidance, and scripts without touching what's there?

```bash
# Preview what would be created — writes nothing
./scripts/adopt-existing-repo.sh --report-only /path/to/existing-repo

# Apply (additive only, never overwrites existing files)
./scripts/adopt-existing-repo.sh /path/to/existing-repo
```

Profiles: `minimal` (default, core docs + agent files), `github` (adds CI/PR templates), `full` (everything including `.agents/`).

See `docs/adopting-existing-repos.md` for what gets created, folder guidance, and conflict-safe adoption details.

## Maintain It

1. Read `CONTEXT.md` — template's own architecture and constraints.
2. Edit `init/` for payload changes; edit root `skills/`, `agents/`, `references/` for the agent subsystem.
3. When adding a required payload file, update `scripts/validate-template.sh`.
4. Run validation before finishing:

```bash
./scripts/validate-template.sh
```

Validation checks for unresolved placeholders, required payload files, malformed skill frontmatter, broken local markdown links, unresolved merge-conflict markers, and ignored OS/secret files. CI runs this on every push and PR, plus a dry-run generation, so a broken payload never reaches `main` silently.

5. Dry-run a new repo to confirm the full tree generates correctly:

```bash
./init/scripts/new-repo.sh /tmp/test-project "Test" && cd /tmp/test-project && ./scripts/check.sh
```

## Navigation

| File / Folder | Purpose |
|---|---|
| `README.md` | Usage, design principles, full file list (you are here) |
| `CONTEXT.md` | Template architecture, constraints, local commands |
| `AGENTS.md` | Agent guidance, skill groups, safety rules |
| `CONTRIBUTING.md` | Change guidelines and review checklist |
| `PLAYBOOK.md` | Design intent for each template lane |
| `docs/adr/` | Architectural decision records |
| `docs/adopting-existing-repos.md` | Adoption profiles and conflict-safe guidance |
| `init/` | The payload — what new projects receive |
| `skills/` | Source for bundled agent skills (generated into `.agents/` at create time) |
| `NOTICE.md` | Third-party attribution for the vendored skills subsystem |

## Design Principles

- Every repo should explain what it is, how to run it, how to change it safely, and what future agents should remember.
- Every repo benefits from separating durable memory, chronological notes, and compiled reference answers.
- Every repo should also explain how it is tested and how evaluations or benchmarks are recorded.
- Every repo should support multiple agent tools by keeping shared guidance in `AGENTS.md` and using thin adapter files for tool-specific entrypoints.
- Agent skills are optional helpers, not a substitute for reading local project context first.
- Security, rollback, ownership, and checks belong in the first commit, not after production hurts.
- The template should stay lightweight enough to use for a scratch folder and strong enough to grow into a production service.
