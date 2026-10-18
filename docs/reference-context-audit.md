# Reference context adoption audit

Scope: D/LAYER PR #68 merged as 165c2b8000b13e994348ea1047c8ef6878f636e5;
reviewed scripts/xerj.sh, .codex/config.toml, .xerjignore, .serena/project.yml,
docs/reference-coding.md and docs/references manifests. No product pipeline,
paid services or deployment was run for this review.

## Findings and adaptation

- Repository state/credentials/catalogs are scoped to the Git common checkout,
  AgentMemory disabled, lexical retrieval explicit. That is a useful accepted
  pattern; do not copy D/LAYER corpus names, port 9280 or language assumptions.
- The documented installer checksum mismatch branch only echoes and exits zero.
  It must fail nonzero, clean its temp directory, extract only the expected binary
  member, and validate the selected platform. This template ships no installer;
  its operator guide requires those checks before a binary becomes trusted.
- D/LAYER's arbitrary CLI passthrough permits flags overriding default budgets or
  index exclusions. The optional template helper exposes only project/peer queries
  with fixed endpoint, three passages and 600 characters, no indexing flags.
- Process ownership relies on command-line substring matches; startup timeout
  leaves a child running for manual inspection. Do not generalize that into an
  unattended lifecycle manager. This minimal bundle manages no processes; an
  operator must verify executable/data-directory arguments, authenticated health
  and all three ports separately. Disk safeguards remain unchanged.
- No global binary, insecure node, maintainer config or existing repository setup
  is adopted. Explicit enablement refuses existing destination files and symlink
  parents before any copy, and requires ignored .cache state. No hooks/MCP start.
- The optional bundle does not install Serena or claim symbol/relationship graph
  readiness. Pinned catalogs start empty to require useful project-specific peers.

## Live read-only evidence (2026-10-18)

D/LAYER's existing recorded PID 8880 was the expected repository-local executable,
with loopback bind, port 9280, lexical mode and correct data-directory arguments.
The existing-node start path authenticated health successfully; lsof showed that
same PID listening on ports 9280, 9281, 9282. No new node was launched. Binary
reported v1.0.0-rc.96; SHA-256 of installed binary was
4a3c8223d1b25b89d5814ee169768c689f249b43b409ec89f70bfead395f75aa
(binary hash is different from the documented archive hash by design).

The bounded D/LAYER feedparser query returned useful source at
feedparser/datetimes/w3dtf.py:61 and docs/date-parsing.rst; its manifest pin is
a22c5521cbb109871f1a2318948581901bd47e26. This does not validate every corpus,
source freshness, Serena, or complete graphs. Scaffold retrieval returned no
project match and an unindexed copier corpus; used scoped rg at the pinned local
Copier clone e5d798446a1ff51a67221cb9d5c89b62386fd396, copier/_main.py:259,263,514.
No upstream code was copied, so existing upstream license notices stay intact.

## Limits and release evidence

The template's offline fixture exercises clean generation and explicit enablement
in a path with spaces, conflict preservation, ignored state, symlink rejection,
fixed budgets and endpoint, invalid flags/ports, repo-local credentials and
worktree namespace sharing. A fake CLI verifies behavior without starting a node.
It does not prove a clean-machine download, occupied-port rejection, foreign-PID
rejection or lifecycle races; those remain per-project runtime acceptance checks.
An independently reviewed PR and owner-authorized merge are required for adoption.
