# Worktree Bootstrap

Use one worktree per active implementation lane.

## Create a new lane

```bash
# Default prefix is "agent" — set AGENT_TOOL to match your tool
AGENT_TOOL=claude ./scripts/worktree-bootstrap.sh 17 lane-protocol
```

This creates:

- branch: `claude/issue-17-lane-protocol`
- worktree: `.worktrees/17-lane-protocol`

Other examples:

```bash
AGENT_TOOL=codex   ./scripts/worktree-bootstrap.sh 17 lane-protocol
AGENT_TOOL=copilot ./scripts/worktree-bootstrap.sh 17 lane-protocol
```


## Recommended bootstrap flow

```bash
cd .worktrees/17-lane-protocol
./scripts/bootstrap.sh
./scripts/check.sh
```

## Finish

When the lane is ready for review, from inside the worktree:

```bash
./scripts/worktree-finish.sh
```

This refuses to run on a dirty tree or a branch that's behind its base,
runs `./scripts/check.sh`, pushes the branch, and opens (or reuses) a PR
via the GitHub CLI if it's installed. It never merges — that's the
coordinator's job. Pass a different base branch as the first argument if
you're not targeting `main`.

## Cleanup

After merge:

```bash
./scripts/worktree-cleanup.sh 17-lane-protocol
```

## Recovery and preservation

Start again with the same issue, slug and AGENT_TOOL to resume the exact
registered worktree. Existing changes remain untouched. A collision or missing
registered path fails: inspect `git worktree list --porcelain` and preserve work
before manual repair. The helper does not fetch; update the chosen local base
before starting a new lane. It never copies `.env` or credentials.

Cleanup accepts an optional local base branch (default `main`). Update that base
after merge. Cleanup refuses tracked, untracked or ignored artifacts and branches
not merged by ancestry; it retains branch refs and never forces removal. Squash
merges require manual equivalence review. Move necessary local artifacts to a safe
location before retrying; do not delete them merely to pass a check.

Safe legacy lane/tool names with uppercase letters or underscores remain
supported, preserving exact case and branch identity. Prefer lowercase kebab-case
for new lanes. Slashes, dots, whitespace and path traversal in these identifiers
are rejected; unusual older names require manual inspection, not automatic rename.
The banner distinguishes creation from resume and reports tracked/untracked dirty
state. Ignored artifacts remain protected by the cleanup check.

For a registered path that disappeared, inspect `git worktree list --porcelain`
and locate any moved directory first. Use `git worktree repair <moved-path>` to
repair a moved worktree, or `git worktree prune --dry-run` to inspect stale
registrations. Run `git worktree prune` only after confirming the directory and
local artifacts are gone and no other lane relies on those registrations. A
locked worktree is preserved; inspect its lock reason before manually unlocking.
