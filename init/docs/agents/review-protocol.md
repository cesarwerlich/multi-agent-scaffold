# Review and Escalation Protocol

Who reviews a lane, what the verdict looks like, and when a worker should stop
and ask instead of deciding. Complements [lane-protocol.md](lane-protocol.md)
(how a lane runs) and [review-checklist.md](review-checklist.md) (what the
coordinator checks before merging).

## Roles

- **Worker** — owns one lane (one issue, one worktree, one PR).
- **Reviewer** — independent of the implementation. A replaceable role, not a
  specific agent or model; one durable Reviewer may work the PR queue
  sequentially across sessions. Independence means it never reviews code it
  implemented, not that every PR needs a fresh session.
- **Coordinator** — the human or architect agent who approves lanes and makes
  material decisions.

The worker never reviews or approves their own pull request.

## Reviewer procedure

The Reviewer receives the issue, the PR, the repo instructions, and the test
entry points — and never relies on the implementer's summary as evidence.

1. Read the issue body, comments, and every applicable `Coordinator Decision`.
2. Inspect the actual merge-base diff. Map each acceptance criterion to code,
   tests, documentation, or an explicit omission.
3. Run `./scripts/check.sh` plus focused tests appropriate to the change's risk.
4. Check for scope drift, security or data exposure, duplication of something
   that already exists, missing documentation, and unrelated regressions.
5. Return exactly one verdict, with findings and test evidence:
   - `PASS`
   - `REQUEST CHANGES`
   - `ESCALATE` — a material architecture decision for the Coordinator. Keep
     routine implementation-quality findings in the PR review.

On `REQUEST CHANGES`, the original worker fixes the same lane without
re-approval and returns the unchanged scope to the same Reviewer.

## Who merges

Record the choice in `AGENTS.md`. The default is that the Coordinator merges
after `PASS`. A project that delegates integration to the Reviewer should
require **all** of: the reviewed head is unchanged, required checks pass, the
lane was approved, no freeze applies, and no unresolved `Coordinator Decision`
blocks it. An `ESCALATE` verdict or an explicit merge restriction always wins.

## Lane autonomy

Once the Coordinator approves a bounded lane, its worker owns normal execution
end to end. Within scope, the worker may inspect, implement, refactor, test,
manage fixtures, commit, push, update the PR, address review findings, and post
durable evidence without per-step approval.

Escalate only for:

- a material architecture or scope decision
- a conflict with another lane
- a security or personal-data boundary change
- a paid external action
- an irreversible or high-blast-radius production change
- unclear product authority
- a conflict with durable project policy

Routine implementation choices and review fixes stay with the lane owner.

## Asking mid-work

Don't make the human relay technical questions. When an escalation condition
above applies, comment on the lane's issue and add the `coord:request` label:

```text
Coordinator Request

Context:
Decision needed:
Evidence:
Recommendation:
Impact:
Work that can continue independently:
```

Keep going on anything independent of the answer. The Coordinator replies on the
same issue and swaps the label to `coord:cleared` or `coord:blocked`:

```text
Coordinator Decision

Decision:
Reason:
Constraints:
Continue with:
```

Read the decision before continuing. This does not replace PR review.
