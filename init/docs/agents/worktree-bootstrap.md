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
