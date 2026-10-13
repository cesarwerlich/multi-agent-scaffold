# Evals

## When to Use This File

Use `docs/evals.md` when your project has **repeatable, measurable quality checks** that go beyond pass/fail unit tests:

- LLM output quality (accuracy, tone, refusal rate, latency per prompt)
- Model comparison (version A vs B on a fixed dataset)
- Regression benchmarks (does this change make the model worse?)
- Human-in-the-loop scoring pipelines
- Dataset-driven fixtures stored in `evals/`
- Agent behavior acceptance checks across multiple runs

Use `docs/testing.md` for everything else — unit tests, integration tests, E2E, coverage targets, CI setup.

If you're not sure, start with `docs/testing.md`. Promote to evals only when you need reproducible benchmark datasets, score tracking over time, or multi-run comparison.

---

This file is for evaluation criteria, benchmark notes, and repeatable quality checks.

## What Counts As An Eval

- prompt / output quality checks
- content quality ratings
- UI flow scoring
- benchmark comparisons
- acceptance checks for agent behavior
- any repeatable rubric used to compare options over time

## Recommended Eval Record

```md
## Eval Name

## Date

## Hypothesis

## Inputs / Dataset

## Scoring Rubric

## Results

## Decision

## Next Iteration
```

## Suggested Metrics

- correctness
- completeness
- consistency
- latency
- cost
- safety
- user value
- platform fit

## Rules

- Keep evals versioned when the underlying system changes.
- Prefer a small stable eval set over a large noisy one.
- Record what changed between runs.
- If an eval is used to justify a product decision, keep the evidence in the repo.

## Notes

For repos that never run benchmarks or agent evaluations, this file can stay empty or be removed.

## Minimal coding-agent comparison (optional)

Choose one small repository task with a fixed base commit and hidden acceptance
checks reviewed by a maintainer. Use a fresh registered worktree per run; provide
the same Issue, AGENTS and context budget. Pin task/fixture version, tool/model
version, available tools, time limit and attempt count. Run at least three attempts
per configuration before comparing; retain failed and interrupted attempts.

Record base/head SHA, exact invocation (redact secrets), tests passed/total, scope
violations, human interventions, resume outcome, elapsed time and known cost or
`unknown`. Store sanitized evidence with each result. Score correctness first;
report counts and failures, not just an average. Never call an unrun trial passed.

Start with a no-network fixture: repair an idempotent worktree start without
losing a dirty file; acceptance checks repeat start, path collision and interrupted
registration. Keep fixtures and scoring unchanged across the baseline and candidate.
Deterministic script tests establish harness behavior; they are not agent benchmark
results. Do not run paid APIs or external writes as part of this protocol.
