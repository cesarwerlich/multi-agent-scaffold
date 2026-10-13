# Harness reliability: bounded first slice

Scope: Issue #6. No runtime, new dependency, credentials, paid calls or production changes.
Baseline: scaffold 73e114005d2f201297b82c7c221048607d0cfc7e; validation passed.
Reference inspection: 2026-10-13, Achados d4885431f9d24c5e65667b8a9e2fe3bbf822eaec,
cesar-os a660a8927809ce4cc60b197f8f7aad830bd2fbba.

## Evidence and gap matrix

| Decision | Current scaffold | Reference evidence | Proposed benefit / complexity / maintenance |
| --- | --- | --- | --- |
| KEEP | Canonical AGENTS and thin adapters; optional vendored skills | Both reference AGENTS contracts centralize policy | Keep stack neutrality; zero new runtime or adapter policy |
| ADAPT | AGENTS requires TASKS while lane protocol requires GitHub | [Achados AGENTS](https://github.com/cesarwerlich/achados/blob/d4885431f9d24c5e65667b8a9e2fe3bbf822eaec/AGENTS.md) records deleted drifting boards; [cesar-os AGENTS](https://github.com/cesarwerlich/cesar-os/blob/a660a8927809ce4cc60b197f8f7aad830bd2fbba/AGENTS.md) separates state from knowledge | GitHub canonical when used, TASKS only for local-only work; low complexity, manual adoption for existing contracts |
| ADAPT | Start cannot resume registered lane, copies .env | [cesar-os start](https://github.com/cesarwerlich/cesar-os/blob/a660a8927809ce4cc60b197f8f7aad830bd2fbba/scripts/start-lane.sh) validates identifiers and registered path | Fail closed on collisions, retain interrupted work; low complexity, shell regression coverage |
| ADAPT | Cleanup removes any named worktree; ignored files unprotected | [Achados reaper](https://github.com/cesarwerlich/achados/blob/d4885431f9d24c5e65667b8a9e2fe3bbf822eaec/scripts/reap-worktrees.sh) records 201 worktrees and 156 production .env copies | Stop automatic secret propagation, require merged base and no local artifacts; moderate complexity, no archive subsystem |
| KEEP | Finish checks clean tree, fresh base, checks, PR reuse; no merge | [cesar-os finish](https://github.com/cesarwerlich/cesar-os/blob/a660a8927809ce4cc60b197f8f7aad830bd2fbba/scripts/finish-lane.sh) uses same native flow | Preserve existing helper; remote finish/API failure tests deferred |
| ADAPT | Generic safety and coordinator review | Both AGENTS contracts distinguish bounded autonomy from security/production decisions; Achados contains both no-merge and low-risk self-merge policies | Explicit risk gates, independent head-specific review; low complexity, no imported labels or self-merge exception |
| ADD | Structural validation; generation only in CI | Reference start/cleanup use executable Git preconditions rather than agent promises | Hermetic Git fixture and profile/no-overwrite smoke tests through validator; moderate complexity, Bash/Git only |
| ADAPT | Generic eval record without reproducible coding task | [cesar-os #121](https://github.com/cesarwerlich/cesar-os/issues/121) requests reproducible baselines; no measured coding-agent result established by this audit | Fixed task/head, separate deterministic tests from agent outcomes; low complexity, manual runs optional |
| REJECT | No graph runtime | [#127](https://github.com/cesarwerlich/cesar-os/issues/127) is OPEN and comparative spike not established | No dependency justified; revisit only after measured benefit |
| KEEP | specs, ADR, issue and PR templates already ship | [#126](https://github.com/cesarwerlich/cesar-os/issues/126) remains OPEN | Reuse native discovery → spec when needed → ADR for consequential choices → issue → PR → eval; no extra templates |

This is a targeted audit of actual AGENTS/start/finish/reaper implementations,
not a claim that reference hooks, CI, security controls or agent evals were run.
Project-specific migrations, hooks, business contracts, routing labels and production
leases are not copied. Authenticated CLI availability does not prove subscription
billing or model benchmark quality.

## Staged implementation and acceptance

1. Contract: GitHub-backed state excludes TASKS updates; local-only handoff remains
   available in every existing profile. Document decision in ADR 0002.
2. Lifecycle: validate identifiers, resume exact registered path/branch, reject
   collisions and missing registered paths; never copy secrets. Cleanup only a
   clean registered lane merged into an explicitly chosen local base, with no
   ignored files. Retain branch refs; never force removal.
3. Verification: validator runs hermetic lifecycle and generation/adoption tests.
   Test minimal/github/full report-only no writes, repeat adoption no overwrite,
   generated bootstrap/check, interrupted resume, collisions and retained artifacts.

Default vs optional: contract applies to all profiles; GitHub remains optional;
local-only TASKS is opt-in by workflow choice. Full retains optional .agents;
minimal/github gain the missing finish helper. No mandatory Node/agent login.

## Deferred

Remote finish tests (stale base, duplicate/open/closed PR, API failure), hook/CI
implementation audit, and bounded subscription agent baselines need dedicated
follow-up lanes. Do not claim measured agent improvement from shell smoke tests.
Native CLI usage: use each installed tool's officially supported interactive login;
never extract keys/tokens or assume an SDK uses a subscription. Verify current
provider documentation, limits and billing before a future live eval.

Follow-up lanes: [#7 finish recovery](https://github.com/cesarwerlich/multi-agent-scaffold/issues/7)
and [#8 native agent baselines](https://github.com/cesarwerlich/multi-agent-scaffold/issues/8).

Additional implementation inspection: [Achados checks](https://github.com/cesarwerlich/achados/blob/d4885431f9d24c5e65667b8a9e2fe3bbf822eaec/scripts/check.sh)
compose executable identity, migration, schema, ADR and data-blob guards;
[lane CI](https://github.com/cesarwerlich/achados/blob/d4885431f9d24c5e65667b8a9e2fe3bbf822eaec/.github/workflows/lane-labels.yml)
uses distinct job names because duplicate check names previously made protection
ambiguous. Keep composable deterministic checks; reject copying product labels
and database-specific guards. [cesar-os pre-push](https://github.com/cesarwerlich/cesar-os/blob/a660a8927809ce4cc60b197f8f7aad830bd2fbba/scripts/git-hooks/pre-push)
blocks both local main and remote main pushes; hooks are optional defense, not
proof of server protections. Its [data contract](https://github.com/cesarwerlich/cesar-os/blob/a660a8927809ce4cc60b197f8f7aad830bd2fbba/platform/data-contracts.md)
requires provenance, explicit completeness and privacy boundaries; adapt those
principles to eval records without importing its dataset architecture.
