# E7 Knowledge Domain Alignment And Expansion Readiness

Status: Accepted; Closed

Date: 2026-07-24

## Decision Context

Knowledge authoring and the `billiard_knowledge` package are the source of
truth for billiards content. Product consumes published package assets and
projects them into browse, detail, Mastery, Coach and Training experiences.
E7 characterizes those boundaries without changing code, schema, assets,
runtime, framework, repositories, search, indexing, recommendation or UI.

## Ownership Map

| Concern | Owner | Current evidence | Boundary |
| --- | --- | --- | --- |
| Authored billiards content and stable semantic IDs | Billiard Knowledge package | corpus, migration authoring, package assets | Generated JSON is never hand-edited |
| Content schema, localization fields and citations | Billiard Knowledge package | `models.dart`, compiler/publication tools | Product renders; it does not redefine content |
| Catalog validation, relations and learning paths | Billiard Knowledge package | `KnowledgeCatalog`, `LearningPath` | Product must not create a second canonical graph |
| Canonical catalog search semantics | Billiard Knowledge package | `KnowledgeCatalog.search`, text normalizer | Product may submit filters, not own a second classifier |
| Executable dependencies, unlocks and mastery policy data | Billiard Knowledge package / Learning Runtime | `ExecutableKnowledgePack` and payload contracts | Runtime evaluates accepted authored policy |
| Package loading and in-process cache | Product Knowledge adapter | `KnowledgeRepository` | Loader is not a second Knowledge source |
| Browse/detail projection and navigation | Product Experience | Knowledge MVP service, providers and screens | UI renders catalog data and sends commands |
| Player-specific Mastery assessment | Mastery / Intelligence | `MasteryEngine`, immutable learning evidence | Knowledge supplies requirements, not player state |
| Coaching priority and action selection | Coach / Intelligence | CoachBrain and M3 contracts | Coach references Knowledge IDs; it does not author content |
| Drill/session execution | Training | Training Center and `DrillRun` | Knowledge supplies drill references only |

## Package Inventory

The package exposes one public library, `billiard_knowledge.dart`, exporting:

- catalog models, bilingual text, citations, relations and learning paths;
- deterministic normalization, filtering and ranked search;
- executable Technique, Mistake and Concept contracts;
- dependency/unlock expressions, outcome/measurement/drill definitions and
  authored next-recommendation references;
- canonical package manifest, digest and runtime compatibility validation.

The display catalog asset is pack `1.4.0`: 36 bilingual entries, 4 learning
paths and 15 sources. Its kinds are 12 techniques, 7 concepts, 5 rules, 4
terminology entries, 4 strategies, 2 common mistakes, 1 equipment entry and 1
mental entry.

The executable asset is Knowledge `0.2.1`: 4 verified entries (2 techniques,
1 mistake and 1 concept), content digest
`da81ba18127c8298276cbdc0ac0f035bf305b73da7489f9309dca52e48a4ee29`.
Its accepted publication record digest is
`0199a037f444b4aa3a2e84c049c6ca96b7995e02944954547c157f1c61af1b6d`.

These are two accepted package projections for different consumers, not two
Product-owned Knowledge repositories. E7 neither merges nor replaces them.

## Public Product API Inventory

### Current Product I8 path

- `KnowledgeRepository.load()` loads and validates the package display catalog,
  caches it in memory and supports explicit invalidation.
- `KnowledgeMvpService.browse()` reuses `KnowledgeCatalog.search` and derives
  category counts through the accepted query execution framework.
- `knowledgeCatalogProvider`, `knowledgeBrowseProvider`,
  `knowledgeEntryProvider` and `knowledgeCoachEntryProvider` expose Product
  read projections.
- `KnowledgeLibraryScreen` browses paths, categories, audience levels and text.
- `KnowledgeDetailScreen` renders layered explanations, relations, sources,
  media, Mastery and Training actions.
- `/knowledge` and `/knowledge/:id` are the public routes.

The MVP service registers one private lifecycle/search/retrieval/classification
capability with the accepted Knowledge capability runtime. This is a
compatibility gate around the Product query path, not a second catalog or
search implementation.

### Package API

- `KnowledgeCatalog.fromJsonString`, `validate`, `entryById`, `pathById`,
  `byDiscipline`, `byDrillRef`, `relationTargets`, `relatedTo` and `search`.
- `ExecutableKnowledgePack.fromJsonString`, `validate`, `byId`,
  `masteryPolicy` and `withCapability`.
- `CanonicalPackageRuntimeLoader.load` verifies runtime contracts, artifact
  bytes/digest and package metadata before returning an executable pack.

## Repository Inventory

`KnowledgeRepository` is the only live Product Knowledge repository. It is an
asset loader plus in-memory cache for
`packages/billiard_knowledge/assets/pack_v1.json`; it validates the catalog
before publishing it to providers. It does not author, persist or mutate
Knowledge.

No database-backed Knowledge repository, network repository or second live
catalog repository is present. Product learning evidence and Training records
are external repositories keyed by Knowledge IDs and remain owned by their
domains.

## Asset Ownership

The package owns and declares:

- `assets/pack_v1.json` for the Product catalog;
- `assets/executable_pack_v0_6.json` for the focused Learning Runtime;
- authoring corpus, mastery policies, compiler/migration/publication tools,
  publication manifests/objects/reviews and test fixtures.

Product also contains 900 tracked historical files under
`app/assets/knowledge/`, including entry JSON, search index, learning paths,
drill mappings and recommendation metadata. The app pubspec declares none of
these assets. Their loader/service family has no Product consumer outside that
family and references historical model/repository APIs not present in the
current Knowledge feature. They are compatibility evidence, not a second live
source of truth. E7 does not delete, publish or revive them.

## Runtime Interaction

```text
Package authoring/publication
          |
          v
pack_v1.json -> KnowledgeRepository -> KnowledgeCatalog
          |                              |
          |                              +-> Product browse/detail
          |                              +-> Mastery requirements
          |                              +-> Coach/Training references
          v
executable_pack_v0_6.json -> focused Learning Runtime -> Evidence decisions
```

The Product catalog path validates the display pack but does not bind a
publication manifest/digest at the repository boundary. The focused stop-shot
provider directly loads the executable asset and relies on the pack's embedded
digest validation; it does not currently use `CanonicalPackageRuntimeLoader`
or the accepted publication pointer. This is a genuine integration gap, not
authorization to add a loader in E7.

## Search, Category And Localization

The live Product search is `KnowledgeCatalog.search`. It normalizes English and
Vietnamese text, searches titles, summaries, aliases, metadata and content,
applies kind/level/topic/discipline filters, and uses stable ID tie-breaking.
I8 category browsing derives counts directly from `KnowledgeKind`; it does not
introduce another classifier.

The package owns bilingual content fields. Product owns UI chrome and currently
uses inline locale branching in the I8 screens, while the shared localization
catalog also contains older Knowledge keys. This is presentation overlap, not
Knowledge-content ownership.

The historical Product `KnowledgeSearchEngine`, `KnowledgeSearchService`,
`CategoryBrowserService` and `SearchIndex` form a parallel dormant search path
over undeclared Product assets. They are not consumed by I8. Their coexistence
is a compatibility condition; E7 selects nothing for removal.

## Learning Path And Mastery Alignment

The package `LearningPath` model and four catalog paths are the live authored
learning sequence. Product renders these paths and Mastery computes progress
from immutable depth-completion evidence and Training runs.

Knowledge owns path steps, minimum explanation depths, executable mastery
policy data, prerequisites and unlock expressions. Mastery owns the algorithm
that derives a player's stage, score and confidence. Knowledge never persists
player progress and Mastery never authors Knowledge.

The historical Product `LearningPathLoaderService` defines another path model
over undeclared assets. It has no current Product consumer outside the dormant
recommendation family and is not canonical.

## Coach Interaction

Coach consumes stable Knowledge IDs and resolved eligibility; it owns priority,
decision and action selection. Coach V2's local `KnowledgeRegistry` maps Coach
action IDs to exact article IDs, Training categories or existing routes. The
`learning_entry:` prefix can carry a package entry ID without duplicating the
entry.

The local registry can drift from published package IDs and is therefore an
integration risk. It does not make Coach the Knowledge owner. The historical
Knowledge recommendation services contain player/goal ranking logic, but have
no current Product consumer and must not become a second Coach engine.

## Training Interaction

Knowledge entries publish drill references. The detail screen resolves those
references against Training Center drills and starts Training while preserving
`knowledgeEntryId` on the resulting run. Training owns attempts, successes,
completion and persistence; Knowledge owns only the authored reference and
instructional meaning.

The current resolver accepts key, drill code or category. Category fallback can
associate one reference with several drills and is weaker than an exact typed
reference. This is a genuine compatibility risk, not a change authorized by
E7.

## Player Interaction

Knowledge has no Player repository and stores no Player profile, score or
progress. Player-specific state enters through Mastery evidence and Training
runs. Frozen Player/Experience/Coach contracts bind Knowledge version/digest
and semantic IDs without transferring Knowledge ownership.

## Concept Alignment And Overlap

| Concept | Current live owner | Compatibility overlap |
| --- | --- | --- |
| Catalog/schema/content | package | 900 undeclared historical Product assets |
| Product loader/cache | `KnowledgeRepository` | dormant services expect an older repository API |
| Search/category | `KnowledgeCatalog.search` + I8 filters | dormant Product search engine/index/services |
| Learning path | package `LearningPath` | dormant Product path model/loader |
| Mastery requirements | package | Player assessment correctly remains in Mastery |
| Recommendation | Coach policy over resolved Knowledge IDs | dormant Product Knowledge recommendation engines |
| Runtime pack | package executable contracts | direct stop-shot asset loading bypasses publication manifest |
| Localization | package content + Product UI | inline I8 strings and older shared keys coexist |

Knowledge Package is both versioned data and executable domain semantics. That
is intentional ownership, not a defect. Product adapters may render or execute
accepted contracts but must not create another Knowledge domain or repository.

## Evolution Matrix

| Artifact | Action | Constraint |
| --- | --- | --- |
| Package authoring, compiler and publication | Keep/freeze | Source of truth; generated JSON not hand-edited |
| `KnowledgeCatalog` and canonical search | Keep/reuse | One live catalog/search semantic owner |
| `ExecutableKnowledgePack` | Keep/reuse | Learning policy input, not player state |
| `KnowledgeRepository` | Keep as Product adapter | Asset load/cache only |
| I8 MVP service/providers/screens/routes | Keep | Experience projection over package APIs |
| Mastery integration | Keep | Mastery owns player assessment |
| Coach ID mapping | Keep pending explicit adapter policy | Exact IDs only; no Knowledge authorship |
| Training drill reference integration | Keep pending typed-reference policy | Training owns execution |
| historical Product assets/services | Preserve/deprecate-later | No removal or revival under E7 |
| direct executable-pack provider | Preserve pending authorized runtime adapter | No manifest integration under E7 |

## Genuine Gaps

- one explicit compatibility policy for display pack `1.4.0` and executable
  Knowledge `0.2.1` without merging their distinct contracts;
- Product loading bound to accepted publication identity, digest and runtime
  compatibility where the consumer requires executable guarantees;
- typed, exact Knowledge-to-Training drill references without category fallback;
- validated Coach-action-to-Knowledge mapping against the published catalog;
- one localization ownership rule for package content versus Product UI chrome;
- explicit deprecation evidence/policy for the dormant Product asset and
  service family;
- public read ports that prevent Experience/Mastery consumers from depending
  on presentation providers;
- stable error/diagnostic contracts for unavailable or incompatible assets;
- scale/performance evidence for Product browsing without introducing a second
  search or index owner.

These are findings only. E7 implements none of them.

## Compatibility Strategy

1. Keep the package as the only authored Knowledge and semantic catalog owner.
2. Keep `KnowledgeRepository` as a thin Product loader/cache, never an authoring
   or persistence source.
3. Reuse `KnowledgeCatalog.search`; do not activate or extend a parallel search
   engine, classifier, cache or index.
4. Preserve both accepted package projections until an explicit compatibility
   milestone defines their adapter/version policy.
5. Keep Mastery, Coach and Training ownership separate and exchange only stable
   Knowledge IDs, versions, digests and public projections.
6. Preserve historical Product assets/services without removal, migration or
   revival until a separately authorized deprecation milestone has evidence.
7. Add no recommendation logic to Knowledge; authored relations are data while
   personalized choice remains Coach policy.
8. Add no Player progress, Evidence or Training execution state to Knowledge.

## Risk Assessment

- High: historical Product assets/services look authoritative despite being
  undeclared and unconsumed, inviting a second repository/search/path stack.
- High: display and executable pack consumers use different identity and
  loading paths, so compatibility can be assumed rather than proven.
- Medium: local Coach ID mappings and category-based drill fallback can drift
  from package semantic IDs.
- Medium: Product consumers reach Knowledge through presentation providers,
  weakening a future public-port boundary.
- Medium: inline and shared localization surfaces can diverge.
- Low: I8 request IDs and timestamps are process-local, though the returned
  browse projection remains deterministic for the same catalog and request.

## Verification

- Inventory covers package, repository, catalog, search, category, learning
  paths, Mastery, Coach, Training, Player, localization, assets, runtime,
  capabilities and Product I8.
- Allowlist compliance: only the E7 document and `MEMORY.md` are changed.
- Outside allowlist changes: 0.
- `git diff --check`: clean.
- Protected artifacts: unchanged.
- No regression suite was run because the Product Owner explicitly classified
  E7 as documentation-only and did not require regression execution.

## Repository State

Product Owner accepted and closed E7 on 2026-07-24 without requested changes.
The authorization permits the documentation and memory updates to be committed
and pushed. No dormant asset/service removal, package merge or implementation
work is authorized by this acceptance.
