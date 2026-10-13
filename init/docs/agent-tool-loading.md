# How Agent Tools Load Instructions

`AGENTS.md` is the one shared contract. This table records how each supported
tool reaches it, so adapters exist only where a tool needs one. Re-check the
sources when a tool changes its loading rules, and update the date.

| Tool | Loads natively | What this repo does | Source (checked 2026-10-13) |
| --- | --- | --- | --- |
| Claude Code | `CLAUDE.md`, `.claude/CLAUDE.md`, `CLAUDE.local.md` from the working directory upward. It reads `AGENTS.md` **only when none of those exist**, and never reads `.agents/`. | `CLAUDE.md` starts with `@AGENTS.md`, which imports the contract on every launch. That also keeps it loaded when someone adds a `CLAUDE.local.md`. | [Claude Code memory docs](https://code.claude.com/docs/en/memory#agents-md) |
| Codex | `AGENTS.override.md` or `AGENTS.md` in each directory from the project root to the working directory, up to `project_doc_max_bytes` (default 32 KiB). | Nothing extra. Keep `AGENTS.md` well under the cap (the template ships it under 8 KiB). | [Codex AGENTS.md docs](https://learn.chatgpt.com/docs/agent-configuration/agents-md) |
| Antigravity | `AGENTS.md` or `GEMINI.md`, `.agents/AGENTS.md`, and `.agents/rules/*.md`, from a file's folder up to the workspace root. There is no `ANTIGRAVITY.md`. | Nothing extra. Put Antigravity-only rules in `.agents/rules/` if you ever need them. | [Antigravity rules docs](https://antigravity.google/docs/rules/) |

Other tools (Cursor, Gemini CLI, Copilot) are not adapters in this payload.

## Checking a repo

- Claude Code: run `/context` and confirm `AGENTS.md` appears under memory files.
- Codex: run `/status` or ask which instruction files are loaded.
- Antigravity: open the rules panel and confirm `AGENTS.md` is listed.

Earlier versions of this template shipped an `ANTIGRAVITY.md` wrapper. No tool
loads it; delete it once `AGENTS.md` holds anything it said.
