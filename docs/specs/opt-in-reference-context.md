# Opt-in repository reference context

Owner request: adapt D/LAYER's curated, explicit retrieval pattern to future
projects without global settings, capture hooks, paid services or deployment.
The payload remains stack neutral and disabled in ordinary generation/adoption.

Acceptance: explicit enablement adds only missing files, refuses all conflicts
before copying, and blocks symlink escapes. An installed helper only retrieves
from an authenticated repository-local node, with three 600-character passages;
it cannot install, start, index or mutate that node. AgentMemory is disabled by a
repo override; an existing config is never replaced. Catalogs start empty and
require project-specific full pins and license review. Credentials/state stay in
the Git common checkout's ignored cache, shared only by that repo's worktrees.

Implementation: (1) offline failing fixture tests; (2) optional payload + explicit
copy helper; (3) maintainer audit and operator instructions; (4) template/harness,
new-project checks, independent review and PR. No self merge. Use Bash 3.2,
existing shell fixture style and no dependencies beyond installed Git/CLI tools.
Lifecycle installation remains a deliberate per-project action, not a universal
platform-specific binary bootstrap or a copied process manager.

Source evidence: D/LAYER 165c2b8000b13e994348ea1047c8ef6878f636e5,
scripts/xerj.sh and docs/reference-coding.md. XERJ scaffold-project returned no
match and scaffold-copier reported unindexed; inspected the pinned clone with rg:
Copier e5d798446a1ff51a67221cb9d5c89b62386fd396 copier/_main.py:259,263,514
(MIT): opt-in skip/overwrite controls inform conflict refusal; no code copied.
