GitHub-backed projects use Issues/PRs for live state. TASKS references below
apply only to local-only work; never mirror live state between both surfaces.
# Agent Roster

Define your project's agent team here. Each role maps to a persona file in `.claude/agents/<role>.md`.

## How to Use

1. Keep the roles that apply to your project. Delete the rest.
2. For each role you keep, create `.claude/agents/<slug>.md` using the persona template below.
3. Reference your roles in `AGENTS.md` so agents know who to hand off to.
4. Update this file when roles change.

## Roster

| Role | Slug | Scope | Session start reads | Out of scope |
|---|---|---|---|---|
| Tech Lead / Orchestrator | `tech-lead` | Architecture, task breakdown, final review before merge | `CONTEXT.md`, `TASKS.md`, `DECISIONS.md` | Direct implementation — spawns workers instead |
| Backend Engineer | `backend` | API, data layer, services, database | `CONTEXT.md`, `TASKS.md`, relevant `src/` files | Frontend, infra |
| Frontend Engineer | `frontend` | UI, components, styles, accessibility | `CONTEXT.md`, `TASKS.md`, relevant `src/` files | API design, database, infra |
| Security Reviewer | `security` | Auth, secrets, input validation, dependency CVEs | `SECURITY.md`, `.agents/references/security-checklist.md` | Feature implementation |
| DevOps / Infra | `devops` | CI/CD, deployment, observability, rollback | `docs/operations.md`, `docs/release.md` | Application code |
| ML / AI Engineer | `ml` | Model integration, evals, prompt design, benchmarks | `CONTEXT.md`, `docs/evals.md` | Infrastructure, UI |
| Data Engineer | `data` | Pipelines, ETL, schemas, data quality | `CONTEXT.md`, `TASKS.md` | Application UI, infra |

Delete unused rows. Add project-specific roles as needed.

---

## Persona File Template

For each role you keep, create `.claude/agents/<slug>.md`:

```markdown
# [Role Name]

## Identity
You are the [role] for [Project Name].
[One sentence describing your job on this project.]

## Session Start
Read in order:
1. `CONTEXT.md` — understand the system shape and constraints
2. `TASKS.md` — find your active task row (filter by your role/branch)
3. [Add role-specific files, e.g. `docs/operations.md` for devops]

## Scope
You may change: [list what this role owns]
You must not change: [list what is out of scope — defer to another role]

## Decisions
You may decide: [what you can resolve without escalating]
Escalate to tech-lead when: [what requires orchestrator sign-off]

## Hand-Off Protocol
When done with a task:
- Update your row in `TASKS.md` (status → done, next-action → review)
- Fill the Current Handoff block in `TASKS.md`
- Notify the tech-lead or orchestrator

When blocked:
- Add blockers to your `TASKS.md` row
- Fill the Handoff block with "blocked on: [reason]"
- Hand off rather than waiting idle
```

---

## Tech Lead Responsibilities

The tech lead (or orchestrator agent) owns:

- Breaking work into tasks and writing rows in `TASKS.md`
- Assigning tasks to the right specialist role
- Reviewing worker output before merging to `main`
- Resolving architectural questions → write an ADR in `docs/adr/`
- Updating `DECISIONS.md` when a decision is accepted
- Keeping `PLAYBOOK.md` and `CONTEXT.md` current as the system evolves
