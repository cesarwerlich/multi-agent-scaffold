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
