# Third-Party Notices

This repository combines two things under one root:

1. **Original work** — the template scaffolding: `init/`, `scripts/`,
   `docs/`, ADRs, CI workflows, and the worktree/lane coordination system.
   Copyright (c) 2026 Cesar Werlich. See [`LICENSE`](LICENSE).

2. **Vendored work** — the agent-skill subsystem under `skills/`, `agents/`,
   and `references/`, adapted from
   [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills)
   (MIT License, Copyright (c) 2025 Addy Osmani). Most skill files are
   near-verbatim; a handful of paths and descriptions were trimmed for this
   template's layout. The original license text is preserved in
   `skills/LICENSE`, `agents/LICENSE`, and `references/LICENSE`.

`init/scripts/new-repo.sh` copies `skills/`, `agents/`, and `references/`
into every generated project's `.agents/` directory, including their
`LICENSE` files — so downstream projects stay compliant automatically
without needing to know the subsystem is vendored.

If you regenerate or diff against upstream, check
`https://github.com/addyosmani/agent-skills` for newer skills before
assuming this copy is current.
