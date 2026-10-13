# Coordinator Review Checklist

Use this when reviewing an agent lane before merge.

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

## Independent verdict

The reviewer must not have implemented the diff. Read the Issue, comments and
actual diff; run the checks rather than relying on the implementer's summary.
Record the reviewed head SHA, findings and test evidence with one verdict: PASS,
REQUEST CHANGES or ESCALATE. A changed head needs another review. Security,
production, paid or out-of-scope actions need explicit authorization for their
target; a passing test does not authorize them. Never bypass branch protections.
