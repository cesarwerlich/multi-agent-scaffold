# 0002: One work-state surface and conservative lane recovery

Status: proposed in Issue #6 PR; mark accepted when the reviewed PR merges.

GitHub-backed projects use Issues/PRs for live execution state and Markdown for
durable knowledge. TASKS remains available only when GitHub is not used for work
tracking. Existing repositories migrate guidance manually through additive
adoption; no existing files are overwritten.

Keep native Git worktrees and existing scripts. Start may resume only its exact
registered branch/path. Do not propagate .env. Cleanup requires clean tracked,
untracked and ignored state and a branch merged into the selected local base;
it never forces removal or deletes branches. Squash merges may require manual
review and cleanup because ancestry cannot establish equivalence.

This trades cleanup convenience for preservation of local work and secrets.
No graph engine, archival service, label taxonomy or second state store is added.
Evidence and staged acceptance: [audit](../research/issue-6-harness.md).

Safe uppercase/underscore legacy identifiers are supported without renaming.
Ancestry uses explicit local branch refs, so same-named tags cannot affect cleanup.
