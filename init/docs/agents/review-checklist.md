# Coordinator Review Checklist

Use this when reviewing an agent lane before merge. The Reviewer role, verdicts,
and escalation rules live in [review-protocol.md](review-protocol.md).

## Scope review

- The PR matches the issue summary and acceptance criteria.
- The lane stayed within its declared expected files or explained any additions.
- No unrelated product or architecture changes slipped in.

## Verification review

- The PR lists exact verification commands.
- The commands are plausible for the changed files.
- Any unverified areas are called out honestly.

## Overlap review

- No active neighboring lane is editing the same files without coordination.
- If stacked, the dependency chain is explicit in the PR body and issue comments.

## Merge gate

- Scope is clean.
- Verification is acceptable.
- Remaining blockers are documented.
- Coordinator, not the worker, performs the merge.
