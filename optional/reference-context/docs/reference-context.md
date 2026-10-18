# Optional repository reference context

This bundle is explicitly installed, with no automatic tool startup, indexing,
MCP registration, capture hooks, paid services or deployment. AgentMemory is
repo-disabled; restart existing sessions to reload the project configuration.
Read curated CONTEXT.md, TASKS.md and DECISIONS.md first, then relevant docs only.

Workflow: requirements/context → affected symbols → reference source/tests →
appropriate regression test → small implementation → checks → independent review
→ authorized merge → concise handoff. Record upstream full commit and file:line.
Empty retrieval results are a reason to refine a query or use scoped `rg` at a
known pin; they are not proof that a solution does not exist.

## Explicit runtime preparation

The helper requires Git, Bash and a repository-local verified XERJ binary. It
never uses PATH/global tool installations. Nothing is downloaded during template
creation or enablement. Runtime preparation and source indexing are separate
operator actions. Review the current upstream CLI documentation for the chosen
platform/version before running commands. Do not weaken authentication or disk
watermarks. Keep credentials, indexes, logs, clones and PID files ignored under
`.cache/reference-context/` at the Git common checkout root; worktrees share it.

For a macOS Apple Silicon bootstrap, the audited D/LAYER reference pins XERJ
v1.0.0-rc.96, asset `xerj-1.0.0-rc.96-aarch64-apple-darwin.tar.gz`, SHA-256
`514491a36018e28b09df92487aba003f1df4401511dfbd9dfd1153a24c461d7b`.
Do not use that binary on another platform. Verify the checksum from a reviewed
release before extraction; mismatch must exit nonzero. Extract only the exact
binary archive member to a temporary location, then install to
`.cache/reference-context/bin/xerj`. Remove only that temporary folder. No curl
pipe to shell. This template does not claim an automated cross-platform installer.

Choose and record a free three-port range (base in 1024..65533) in
`.cache/reference-context/port`. Check base, base+1 and base+2 before starting.
Start XERJ explicitly on `127.0.0.1`, lexical embeddings, default API-key auth,
`--data-dir <state>/data` and feedback disabled. Record the child PID; report ready
only after an authenticated health request to `/_cluster/health` succeeds. Keep
the key out of command arguments and logs: use curl config stdin and the CLI's
child environment. Confirm the exact executable and data-directory arguments
before reusing or terminating a recorded PID; never pkill/killall. Serialize
startup, refuse foreign PIDs/occupied ports, and recover explicitly from startup
failure. This read-only bundle deliberately does not manage a node process.

Set XERJ_CODE_HOME to `<state>/code` and XERJ_HUB_HOME to `<state>/hub` for every
manual corpus operation, so the CLI cannot fall back to global catalogs. Set the
same loopback URL and API-key environment as the helper. Index only this repo's
sources, honoring `.gitignore` and `.xerjignore`, no external symlinks, no
`--no-ignore`, no relationship graph, no global source tree. Use project prefix
`reference-<first 12 hex characters of git hash-object of the absolute state path>`;
the helper computes it identically for all worktrees. Scope sources explicitly
when a project has private/generated datasets; exclusions need project review.

Index peers sequentially after creating and reviewing full-pinned manifests in
docs/references/. Keep license notices. Do not automatically approve size/time
prompts (exit 4), disk refusals, or partial-index reports. Check useful source
passages and record counts before declaring retrieval ready. Refresh from the
active worktree deliberately, since its project index is shared.

## Bounded retrieval

```bash
./scripts/reference-search.sh project 'symbol or problem'
./scripts/reference-search.sh peer reviewed-corpus 'specific question'
```

Both commands request three passages of 600 characters and accept query text
only. CLI headers/metadata can add output; the budget describes passage content,
not a strict total response byte limit. No arbitrary flags, endpoint override,
indexing or startup is exposed. Secrets are passed only to the child environment;
local processes with OS-level access to this user remain in the trust boundary.

## Verified versus configured

Offline contracts cover disabled-by-default generation, opt-in conflict refusal,
symlink rejection, bounded arguments, local credentials/state, invalid ports and
shared worktree prefixes. They use a mock CLI and do not prove live retrieval,
release installation, authenticated startup, PID ownership or port isolation.
Verify those separately in each project before marking its runtime ready.
Serena symbols, a complete code graph and semantic embedding quality are not
configured or claimed here. The empty catalog is intentional: select useful
references for the future project's actual needs.
