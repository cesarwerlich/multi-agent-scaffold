# Template Session Journal

Running log of decisions, changes, and discussions about this template repository. New projects receive their own `docs/memory.md`; do not copy this maintenance journal into generated repos.

## Instructions for AI Coding Assistants

- On session start: read the latest entries when they are relevant to the task.
- On session end: append a new entry if durable template-maintenance context was created.
- After significant decisions mid-session: add a note immediately.

## Entry Format

```text
---
## YYYY-MM-DD - Short topic label

Done this session:
-

Decisions made:
-

Open questions:
-

Next session should:
-
```

## Entries

---
## 2025-05-19 - Template creation

Done this session:
- Bootstrap the universal repo-initializer template with `init/` payload model.
- Bundle agent subsystem under `init/.agents/` (skills, personas, references).
- Add CI workflows, issue templates, and validation script.

Decisions made:
- Keep `init/` stack-neutral by default. No project-specific names, URLs, or secrets.
- Maintain root `skills/`/`agents/`/`references/` as source material; copy into `init/.agents/`.
- Prefer small shell scripts over a generator framework.
- ROADMAP.md, MEMORY.md, and DECISIONS.md are lightweight templates — projects fill them in or delete them.

---
## 2026-05-20 - Documentation and maintenance improvements

Done this session:
- Added `init/CLAUDE.md` to validator required-files check.
- Created root CONTEXT.md documenting the template's own architecture.
- Replaced bare TBD markers in init/ files with commented-out example guidance.
- Deduplicated agent persona documentation (single source: agents/README.md).
- Created ADR for template structure.

Decisions made:
- TBD placeholders are noise; commented-out examples are better scaffolding.
- The template repo itself deserves a CONTEXT.md and ADR — practice what we preach.
