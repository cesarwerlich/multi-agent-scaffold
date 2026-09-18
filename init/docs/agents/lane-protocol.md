# Lane Protocol

Use this workflow whenever an agent picks up a scoped implementation lane.

## Durable surfaces

- GitHub issue: lane status, scope, acceptance criteria, and durable handoff
- Pull request: implementation diff and review discussion
- Agent chat: scratch work only

## Required workflow

1. Read the assigned issue and stay within that scope.
2. Work on an isolated branch and worktree.
3. Post an issue pickup update before editing files.
4. Run `./scripts/worktree-finish.sh` to verify, push, and open exactly one PR for the lane.
5. Post a final issue update with verification and PR link.
6. Do not merge your own PR.

## Recommended rules

- Keep `main` or the primary release branch coordinator-only.
- Default to one issue, one lane, one worktree, and one PR.
- Use stacked PRs only when one lane truly depends on another.
- List expected files in the pickup update so overlap is obvious early.
- Include exact verification commands in the final handoff.
- Use the agent tool name as the branch prefix so parallel work is clearly attributable. Examples: `claude/issue-17-slug`, `codex/issue-17-slug`, `copilot/issue-17-slug`, `gemini/issue-17-slug`. Each agent uses its own convention — the prefix identifies who owns the lane.

## Lane update helper

Preview a pickup comment:

```bash
node ./scripts/lane-update.mjs pickup \
  --issue 17 \
  --branch codex/issue-17-lane-protocol \
  --worktree .worktrees/17-lane-protocol \
  --scope "Document the lane contract" \
  --scope "Add the agent lane issue template" \
  --expected-file docs/agents/lane-protocol.md \
  --expected-file .github/ISSUE_TEMPLATE/agent_lane.md
```

Preview a final lane update:

```bash
node ./scripts/lane-update.mjs final \
  --issue 17 \
  --branch codex/issue-17-lane-protocol \
  --worktree .worktrees/17-lane-protocol \
  --change "Added the lane protocol docs and worktree helper scripts" \
  --verify "./scripts/check.sh" \
  --pr 23
```

Post directly to GitHub (requires `gh` CLI):

```bash
node ./scripts/lane-update.mjs final \
  --issue 17 \
  --branch codex/issue-17-lane-protocol \
  --worktree .worktrees/17-lane-protocol \
  --change "Added the lane protocol docs and worktree helper scripts" \
  --verify "./scripts/check.sh" \
  --pr 23 \
  --post
```

Notes:

- Without `--post`, the script prints the comment for review only.
- With `--post`, the script uses the authenticated `gh` CLI and infers the repo from `origin`.
- Pass `--repo owner/name` if the repo cannot be inferred correctly.
- If your project has a `package.json`, add a script: `"lane:update": "node scripts/lane-update.mjs"` and then use `npm run lane:update -- pickup ...` for shorter invocation.
