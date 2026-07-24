# F1 Product Expansion Candidate Catalog And Prioritization

Status: Accepted; Closed

Date: 2026-07-24

## Purpose And Authority

This is the authoritative evidence-derived catalog of Product Expansion
candidates recorded by accepted E1-E12 Domain Alignment reports. It identifies
what may be considered in future Product decisions. It does not authorize
implementation, create a roadmap, assign a milestone, define order or schedule,
merge gaps, reinterpret ownership or add a requirement.

AR1 keeps P1-P9.3 closed and assigns Product behavior to domain/application
owners rather than generic foundations. Accepted M1-M22, P1-P9 and I1-I12
remain frozen compatibility evidence. Every row below maps one-to-one to one
accepted E-report gap bullet.

## Classification Method

- **Impact** estimates architectural blast radius: Low, Medium or High.
- **Scope** estimates implementation breadth: Small, Medium or Large.
- **Duplication risk** estimates the chance of recreating an accepted concept or
  owner: Low, Medium or High.
- **Essential** means a prerequisite for safe expansion of the named boundary.
- **Important** means material hardening or product capability with an existing
  owner, but not a universal prerequisite.
- **Optional** means useful experience/maintainability work whose absence does
  not invalidate current ownership.
- **Future Research** means a new Product concept or capability whose value and
  executable scope require separate evidence.

Priority is classification, not sequencing. Dependencies describe prerequisite
relationships only and do not authorize the referenced candidate.

## Candidate Inventory And Decision Matrix

### Tournament (E1)

| ID | Candidate | Owner | Dependencies | Impact | Scope | Dup risk | Priority |
| --- | --- | --- | --- | --- | --- | --- | --- |
| E1-G01 | Time-bounded `Season` grouping | future League/Tournament policy | identity and calendar policy | High | Large | Medium | Future Research |
| E1-G02 | Competitive `Division` within Season | future League policy | E1-G01 | High | Large | Medium | Future Research |
| E1-G03 | Independent League aggregate | future League domain | E1-G01, E1-G02; preserve legacy league enum | High | Large | High | Future Research |
| E1-G04 | Schedule with time, venue, rounds and conflicts | Tournament/scheduling owner | calendar and venue semantics | High | Large | Medium | Future Research |
| E1-G05 | Promotion/relegation | future League policy | E1-G01-E1-G03 | High | Large | Low | Future Research |
| E1-G06 | Federation/organizer authority | future organization owner | identity and authorization | High | Large | High | Future Research |
| E1-G07 | Ranking period and rating policy | ranking owner | Player identity and competition results | High | Large | High | Future Research |
| E1-G08 | Team aggregate and roster | future Team domain | Player identity; Tournament adapters | High | Large | High | Future Research |
| E1-G09 | Versioned Tournament identity/provenance/compatibility | Tournament | legacy ID/code adapters | High | Medium | Medium | Important |

### Club (E2)

| ID | Candidate | Owner | Dependencies | Impact | Scope | Dup risk | Priority |
| --- | --- | --- | --- | --- | --- | --- | --- |
| E2-G01 | Versioned Membership lifecycle/transitions | Club | member identity and compatibility | High | Medium | Medium | Essential |
| E2-G02 | Invitation aggregate and audit trail | Club | E2-G01; acting identity | Medium | Medium | Medium | Important |
| E2-G03 | Permission policy and acting-member identity | Club/security policy | E2-G01; Player/account identity | High | Large | High | Essential |
| E2-G04 | Typed Club-to-Match/Training/Tournament adapters | Club | public source ports and typed IDs | High | Medium | High | Essential |
| E2-G05 | Team/squad/roster distinct from membership | future Team/Club policy | E2-G01; E1-G08 boundary | High | Large | High | Future Research |
| E2-G06 | Club competition/League enrollment | Club/future League | E1-G03; E2-G01 | High | Large | High | Future Research |
| E2-G07 | Club event/calendar ownership | Club/calendar policy | scheduling semantics | Medium | Large | High | Future Research |
| E2-G08 | Organization/federation hierarchy | future organization owner | E1-G06 | High | Large | High | Future Research |
| E2-G09 | Ranking policy/version and period identity | Club/ranking owner | E1-G07; typed results | High | Medium | High | Important |
| E2-G10 | Stable typed Club/Member IDs and provenance | Club | legacy integer adapters | High | Medium | Medium | Essential |
| E2-G11 | Cross-device membership synchronization | Club/sync owner | E2-G01, E2-G03, identity | High | Large | High | Future Research |

### Player (E3)

| ID | Candidate | Owner | Dependencies | Impact | Scope | Dup risk | Priority |
| --- | --- | --- | --- | --- | --- | --- | --- |
| E3-G01 | Adapter among legacy Player, foundation profile and contract | Player | frozen contract compatibility | High | Medium | High | Essential |
| E3-G02 | Stable identity mapping/version and cross-device semantics | Player/identity | E3-G01 | High | Large | High | Essential |
| E3-G03 | Profile contract version, provenance and digest | Player | E3-G01, E3-G02 | High | Medium | Medium | Essential |
| E3-G04 | Atomic active-player invariant and multi-profile lifecycle | Player | repository transaction semantics | High | Medium | Low | Essential |
| E3-G05 | Referenced Player deletion/deactivation policy | Player | E3-G02; cross-domain reference inventory | High | Medium | Medium | Essential |
| E3-G06 | Public career achievement/timeline read ports | Player/Career | E3-G02; source ownership | Medium | Medium | High | Important |
| E3-G07 | Privacy/consent/export classification for profile fields | Player/privacy owner | data classification and identity | High | Medium | Medium | Important |
| E3-G08 | Validated hand/locale/rank/game/preference value objects | Player | legacy value adapters | Medium | Medium | Medium | Important |
| E3-G09 | Account/device identity separated from Player | identity owner | E3-G02 | High | Large | High | Essential |
| E3-G10 | Deterministic clock for tenure/timeline | Player/Career | request-time policy | Medium | Small | Low | Important |
| E3-G11 | Multi-device synchronization/merge semantics | sync owner | E3-G02, E3-G09 | High | Large | High | Future Research |

### Match (E4)

| ID | Candidate | Owner | Dependencies | Impact | Scope | Dup risk | Priority |
| --- | --- | --- | --- | --- | --- | --- | --- |
| E4-G01 | Adapter among legacy Match, ProductMatch, MatchAggregate and MatchId | Match | frozen contracts and persistence mapping | High | Large | High | Essential |
| E4-G02 | Versioned Match lifecycle/state-transition policy | Match | E4-G01 | High | Medium | Medium | Essential |
| E4-G03 | Atomic one-open-Match and monotonic number allocation | Match/Session | transaction boundary | High | Medium | Medium | Essential |
| E4-G04 | Match retention/deletion across Rack/Shot/Event/context | Match | reference inventory and lifecycle | High | Large | Medium | Essential |
| E4-G05 | One-to-one MatchContext identity/referential/audit semantics | Match | E4-G01; persistence constraints | High | Medium | Low | Important |
| E4-G06 | Typed participant/opponent/team references preserving text | Match | Player/Team identity adapters | High | Large | High | Important |
| E4-G07 | Tournament-fixture-to-recorded-Match adapter | Match/Tournament | E1 existing fixture; E4-G01 | High | Medium | High | Important |
| E4-G08 | Public Match read ports for Coach/Analytics/Club/Equipment/Player | Match | E4-G01, E4-G02 | High | Large | High | Essential |
| E4-G09 | Deterministic clock/request identity/cancellation at Product adapter | Match/Application | Product execution policy | Medium | Medium | Medium | Important |
| E4-G10 | Validated format/context values with legacy compatibility | Match | value/code adapters | Medium | Medium | Medium | Important |
| E4-G11 | Structured execution failure mapping for UI | Match/Application | typed Product failure policy | Medium | Small | Medium | Essential |
| E4-G12 | Lifecycle/history provenance and digest for replay | Match | E4-G01, E4-G02; replay requirement | High | Large | Medium | Important |

### Training (E5)

| ID | Candidate | Owner | Dependencies | Impact | Scope | Dup risk | Priority |
| --- | --- | --- | --- | --- | --- | --- | --- |
| E5-G01 | Compatibility map across Product, Training Center and foundation sessions | Training | frozen contract inventory | High | Medium | High | Essential |
| E5-G02 | History-unification decision and migration policy | Training | E5-G01; consumer evidence | High | Large | High | Important |
| E5-G03 | Stable Training Session/exercise/drill-run identities | Training | E5-G01; legacy adapters | High | Medium | Medium | Essential |
| E5-G04 | Versioned lifecycle/outcome contract with provenance | Training | E5-G03 | High | Medium | Medium | Essential |
| E5-G05 | Durable incremental attempt recording/recovery | Training/Session | E5-G03, E5-G04; transaction policy | High | Large | Medium | Important |
| E5-G06 | Configurable target/success criteria bound to drill | Training/Knowledge | typed drill identity | Medium | Medium | High | Important |
| E5-G07 | Public Training command/read ports for Coach/Analytics | Training | E5-G03, E5-G04 | High | Large | High | Essential |
| E5-G08 | Atomic active-Session creation policy | Training/Session | transaction boundary | High | Medium | Medium | Essential |
| E5-G09 | Deterministic execution clock/request/cancellation | Training/Application | Product execution policy | Medium | Medium | Medium | Important |
| E5-G10 | Typed Knowledge/custom-drill references and validation | Training/Knowledge | E7 typed references | High | Medium | High | Essential |
| E5-G11 | Deletion/retention policy across both Training flows | Training | E5-G01-E5-G04 | High | Large | Medium | Important |
| E5-G12 | Structured Product failures and audit trail | Training/Application | typed failure and provenance policies | High | Medium | Medium | Essential |

### Coach (E6)

| ID | Candidate | Owner | Dependencies | Impact | Scope | Dup risk | Priority |
| --- | --- | --- | --- | --- | --- | --- | --- |
| E6-G01 | V2-to-frozen-M3 Decision/Plan/Recommendation/Execution adapter | Coach | M3 frozen contracts; V2 identity | High | Large | High | Essential |
| E6-G02 | Canonicalization and retirement policy for legacy Coach engines | Coach/Product | E6-G01; usage/deprecation evidence | High | Large | High | Important |
| E6-G03 | Stable V2 IDs, JSON, versions, provenance and digest | Coach | source projection versions | High | Large | Medium | Essential |
| E6-G04 | Decision Trace for every visible explanation/action | Coach/Intelligence | E6-G01, E6-G03 | High | Medium | Medium | Essential |
| E6-G05 | Pure context projection separated from Memory reconciliation command | Coach | typed source ports and command boundary | High | Medium | Medium | Essential |
| E6-G06 | Public read ports for all Coach source inputs | source domains/Coach | source identity/provenance | High | Large | High | Essential |
| E6-G07 | Durable append-only lifecycle/execution integration | Coach | E6-G01; persistence authorization | High | Large | High | Important |
| E6-G08 | Conversation request/turn bound to output/session digest | Coach | E6-G03 | Medium | Medium | Low | Important |
| E6-G09 | Deterministic clock, command ID and cancellation | Coach/Application | Product execution policy | Medium | Medium | Medium | Important |
| E6-G10 | Authoritative action/Knowledge reference registry | Coach/Knowledge | published Knowledge identity | High | Medium | High | Essential |
| E6-G11 | Legacy insight/recommendation/history compatibility mapping | Coach | E6-G01-E6-G03 | High | Large | High | Important |
| E6-G12 | Operational AI activation policy after boundary gates | AI governance/Coach | M3 AI boundaries and provider evidence | High | Large | High | Future Research |

### Knowledge (E7)

| ID | Candidate | Owner | Dependencies | Impact | Scope | Dup risk | Priority |
| --- | --- | --- | --- | --- | --- | --- | --- |
| E7-G01 | Display-pack/executable-Knowledge compatibility policy | Knowledge | both accepted package identities | High | Medium | High | Essential |
| E7-G02 | Publication-bound Product loading and runtime compatibility | Knowledge/Product adapter | E7-G01; publication identity | High | Medium | Medium | Essential |
| E7-G03 | Exact Knowledge-to-Training drill references | Knowledge/Training | E5-G10; catalog validation | High | Medium | High | Essential |
| E7-G04 | Validate Coach-action mappings against catalog | Knowledge/Coach | E6-G10; published catalog | High | Medium | High | Essential |
| E7-G05 | Localization ownership for package content vs UI chrome | Knowledge/Experience | localization policy | Medium | Small | Medium | Important |
| E7-G06 | Deprecation evidence/policy for dormant assets/services | Knowledge/Product | consumer scan and compatibility evidence | Medium | Medium | High | Important |
| E7-G07 | Public read ports for Experience/Mastery consumers | Knowledge | E7-G01, E7-G02 | High | Medium | High | Essential |
| E7-G08 | Stable unavailable/incompatible asset diagnostics | Knowledge/Application | E7-G02 | Medium | Small | Low | Essential |
| E7-G09 | Browse scale/performance evidence before new indexing | Knowledge | measured usage/data scale | Medium | Medium | High | Future Research |

### Analytics (E8)

| ID | Candidate | Owner | Dependencies | Impact | Scope | Dup risk | Priority |
| --- | --- | --- | --- | --- | --- | --- | --- |
| E8-G01 | Policy separating I9 Analytics from legacy Statistics/convergence | Analytics/Product | accepted surface usage evidence | High | Medium | High | Essential |
| E8-G02 | Consistent Match/Training snapshot/provenance boundary | Analytics/source domains | public source projections | High | Large | Medium | Essential |
| E8-G03 | Projection version, source IDs/digests and generated-at | Analytics | E8-G02 | High | Medium | Medium | Essential |
| E8-G04 | Player/profile scope for Analytics request/result | Analytics/Player | stable Player identity | High | Medium | Medium | Essential |
| E8-G05 | Public source-domain read contracts | Match/Training | E4-G08, E5-G07 | High | Large | High | Essential |
| E8-G06 | Cancellation and typed error diagnostics | Analytics/Application | Product execution policy | Medium | Medium | Medium | Important |
| E8-G07 | Validate counts/rates/duplicate IDs/timestamps | Analytics | E8-G02, E8-G03 | Medium | Medium | Low | Important |
| E8-G08 | Analytics UI localization/accessibility ownership | Analytics/Experience | Experience policy | Low | Medium | Low | Optional |
| E8-G09 | Authorized removal of redundant Home source loads | Home/Analytics | E10 one-load policy and snapshot boundary | Medium | Medium | High | Important |
| E8-G10 | Scale/query evidence before cache/warehouse/index | Analytics | measured usage/data scale | High | Medium | High | Future Research |

### Product Simulation I10 And Platform Simulation (E9)

| ID | Candidate | Owner | Dependencies | Impact | Scope | Dup risk | Priority |
| --- | --- | --- | --- | --- | --- | --- | --- |
| E9-G01 | Naming/compatibility policy for observed replay vs physics Simulation | Product/Platform architecture | accepted I10 and constitutional boundary | High | Medium | High | Essential |
| E9-G02 | Versioned/provenanced Match/Training replay projections | source domains/I10 | E4-G08, E5-G07 | High | Large | High | Essential |
| E9-G03 | Consistent cutoff for sequential comparisons | I10/source domains | E9-G02 | Medium | Medium | Low | Essential |
| E9-G04 | Validate request/sample/rate/duration/time/duplicate IDs | I10 | E9-G02 | Medium | Medium | Low | Important |
| E9-G05 | Semantic policy for combining unlike rates | I10/Product | source metric definitions | High | Medium | Medium | Essential |
| E9-G06 | Cancellation and typed stable diagnostics | I10/Application | Product execution policy | Medium | Medium | Medium | Important |
| E9-G07 | Relationship between feature-local/shared request models | Product Simulation | E9-G01; lifecycle evidence | High | Medium | High | Important |
| E9-G08 | I10 localization/accessibility/chart semantics | I10/Experience | Experience policy | Low | Medium | Low | Optional |
| E9-G09 | Intelligence-to-physics-Simulation adapter | Intelligence/Platform Simulation | real versioned physics contract and engine | High | Large | High | Future Research |

### Home (E10)

| ID | Candidate | Owner | Dependencies | Impact | Scope | Dup risk | Priority |
| --- | --- | --- | --- | --- | --- | --- | --- |
| E10-G01 | Versioned Home contract with provenance/shared cutoff | Home/source domains | public versioned projections | High | Large | Medium | Essential |
| E10-G02 | Public source read ports replacing concrete feature imports | source domains/Home | E4-G08, E5-G07, E7-G07, E8-G05 | High | Large | High | Essential |
| E10-G03 | One-load-per-source Home composition | Home | E10-G01, E10-G02 | Medium | Medium | High | Important |
| E10-G04 | Typed failures and all-or-nothing/partial-dashboard policy | Home/Application | Product failure policy | Medium | Medium | Medium | Essential |
| E10-G05 | Cancellation and refresh coalescing | Home/Experience | request/cancellation policy | Medium | Medium | Medium | Important |
| E10-G06 | Side-effect-free Coach summary projection | Coach/Home | E6 public projection/adapter | Medium | Medium | Medium | Important |
| E10-G07 | Stable localization keys/value models for summaries | Home/Experience | localization ownership | Low | Medium | Medium | Optional |
| E10-G08 | Player/account scope for every source projection | source domains/Home | stable Player/account identity | High | Large | Medium | Essential |
| E10-G09 | Accessibility/responsive/destination-state coverage | Home/Experience | Experience policy | Low | Medium | Low | Optional |
| E10-G10 | Navigation compatibility policy | Application/Experience | I12 evidence and route inventory | High | Medium | High | Important |
| E10-G11 | Home versus legacy Dashboard compatibility/deprecation decision | Product/Experience | usage and migration evidence | High | Large | High | Important |

### Product Application Boundary (E11)

| ID | Candidate | Owner | Dependencies | Impact | Scope | Dup risk | Priority |
| --- | --- | --- | --- | --- | --- | --- | --- |
| E11-G01 | Product Application responsibility policy | Product architecture | E11 inventory; frozen P3/P6/P8/P9 | High | Medium | High | Essential |
| E11-G02 | Versioned public cross-feature read/write ports | source domains/Application | semantic IDs and provenance | High | Large | High | Essential |
| E11-G03 | Typed failure policy preserving diagnostics | Product Application | P3/P9 Result semantics | High | Medium | Medium | Essential |
| E11-G04 | Request ID/time/correlation and cancellation ownership | Product Application | P3 context/P9 execution | High | Medium | Medium | Essential |
| E11-G05 | Transaction/atomicity for Match/Training multi-repository writes | Match/Training/Session | RecordingCoordinator and persistence evidence | High | Large | High | Essential |
| E11-G06 | Compatibility policy for partial P6/P8/P9 adoption | Product architecture | AR1 and current consumers | High | Medium | High | Essential |
| E11-G07 | Separately authorized removal of IO/Flutter from conceptual Application | owning features | E11-G01; migration evidence | High | Large | High | Optional |
| E11-G08 | Riverpod controller side-effect/invalidation maps | Product Application/Experience | provider inventory | Medium | Medium | Low | Important |
| E11-G09 | Snapshot/coalescing for Home/Analytics/I10 nested reads | source domains/Home | E8-G02, E9-G02, E10-G01 | High | Large | High | Essential |
| E11-G10 | Public application surfaces for Session/Tournament/Club/Player | owning domains | E11-G01, E11-G02 | High | Large | High | Important |
| E11-G11 | Dependency fitness against new presentation-to-foreign-repository imports | Product architecture | accepted legacy-path allowlist | Medium | Medium | Low | Essential |

### Product Experience Boundary (E12)

| ID | Candidate | Owner | Dependencies | Impact | Scope | Dup risk | Priority |
| --- | --- | --- | --- | --- | --- | --- | --- |
| E12-G01 | Experience responsibility policy across UI/provider/application/data | Product Experience architecture | P5 and E11-G01 | High | Medium | High | Essential |
| E12-G02 | GoRouter/Navigator route, deep-link and restoration policy | Application/Experience | I12 and E10-G10 | High | Large | High | Essential |
| E12-G03 | Versioned presentation projections and typed loading/failure | Experience/source applications | E11-G02, E11-G03 | High | Large | High | Essential |
| E12-G04 | Command boundary preventing direct foreign repository mutation | Application/Experience | E11-G01, E11-G02 | High | Large | High | Essential |
| E12-G05 | Riverpod invalidation/cascading-refresh ownership | Experience/Application | E11-G08 | Medium | Medium | Low | Important |
| E12-G06 | Player/account scope and snapshot identity for composite screens | Experience/source domains | E3-G02, E10-G08 | High | Large | Medium | Essential |
| E12-G07 | Localization/date/number formatting ownership | Experience | localization inventory | Medium | Medium | Medium | Important |
| E12-G08 | Accessibility, keyboard/focus and responsive coverage | Experience | UI acceptance criteria | Medium | Large | Low | Optional |
| E12-G09 | Cancellation/stale-result/duplicate-submit behavior | Experience/Application | E11-G04 | High | Medium | Medium | Essential |
| E12-G10 | Decomposition evidence for large mixed screens | owning feature Experience | E12-G01; measured change/test burden | Medium | Medium | Medium | Optional |
| E12-G11 | Dependency fitness against new presentation-to-foreign-data imports | Product architecture | E11-G11 | Medium | Medium | Low | Essential |
| E12-G12 | Policy for evidence-based P5 use in Product UI | Product architecture | concrete consumer need | Medium | Small | High | Important |

## Dependency Relationships

The row-level matrix is authoritative. The following clusters make the major
relationships easier to audit without merging their candidates:

- Stable Player, Match, Training, Club and Tournament identities underpin typed
  cross-domain adapters and scoped projections.
- Public source-domain ports underpin Coach, Analytics, I10, Home and
  presentation-facing projections.
- Provenance/version/snapshot policies underpin deterministic composite reads,
  replay comparison and Home consistency.
- Product Application failure, request, cancellation and transaction policies
  underpin feature-specific execution and Experience async behavior.
- Navigation and Experience responsibility policies underpin later UI-specific
  compatibility decisions.
- New League, Team, federation, synchronization, physics and operational-AI
  concepts remain research candidates dependent on explicit Product evidence.

These relationships express prerequisites only. They do not define an
implementation sequence.

## Existing Owner Mapping

| Candidate group | Existing owner preserved |
| --- | --- |
| E1 | Tournament; future League concepts remain unassigned until authorized |
| E2 | Club; Player/Match/Training/Tournament remain external owners |
| E3 | Player; account/device/privacy need explicit owners before implementation |
| E4 | Match with Session recording boundary; source consumers remain read-only |
| E5 | Training/Session; Knowledge owns authored drill identity |
| E6 | Coach/Intelligence; source domains and Knowledge retain their facts |
| E7 | Knowledge package for semantics; Product adapter for loading/rendering |
| E8 | Analytics projection; Match/Training own source aggregation |
| E9 | I10 owns observed replay; Platform Simulation owns future physics |
| E10 | Home/Experience owns composition only |
| E11 | Product Application policy; feature domains own behavior |
| E12 | Experience owns rendering/interaction; Application/domain own execution |

## Duplication Risk Rules

- A High rating means a candidate touches a known overlap or could create a
  second owner: legacy/foundation models, multiple Coach generations, dual
  Knowledge packages, Analytics/Statistics, observed/physics Simulation,
  Home/legacy Dashboard, or P3/P5/P6/P8/P9 foundations.
- A Medium rating means additive work still requires an adapter or compatibility
  policy around existing IDs, providers, persistence or UI.
- A Low rating means the gap is mostly a missing policy/validation concern with
  a clear existing owner.

No rating authorizes convergence or removal.

## Explicit Exclusions

F1 excludes:

- any candidate not traceable to E1-E12;
- implementation, source/schema/test/runtime/provider/router/UI changes;
- a roadmap, milestone assignment, sequence, schedule, estimate in time or
  delivery commitment;
- merging similar gaps across contexts or selecting one existing generation for
  removal;
- reinterpretation of accepted domain ownership;
- automatic adoption of P3, P5, P6, P8 or P9 by every feature;
- League, Team, federation, synchronization, physics Simulation or operational
  AI as approved Product features;
- deprecation of legacy Coach, Knowledge, Analytics/Statistics, I10, Home/
  Dashboard, navigation or application compatibility surfaces;
- changes to M1-M22, P1-P9, I1-I12, AR1, Constitution, protected artifacts,
  production Knowledge, publication outputs or Golden Fixtures.

## Catalog Totals

| Priority | Count |
| --- | ---: |
| Essential | 63 |
| Important | 41 |
| Optional | 7 |
| Future Research | 18 |
| **Total** | **129** |

Counts are a catalog integrity check, not a delivery plan.

## Verification

- All 129 accepted gap bullets from E1-E12 have exactly one candidate ID.
- Every candidate records source, owner, dependencies, impact, scope,
  duplication risk and priority classification.
- Candidate grouping preserves the accepted bounded-context source.
- No new requirement, roadmap, milestone, sequence or schedule is introduced.
- Exact allowlist: this document and `MEMORY.md` only.
- Outside-allowlist changes: 0.
- `git diff --check`: clean.
- Protected artifacts: unchanged.
- No regression suite was run because F1 is documentation-only.

## Repository State

Product Owner accepted and closed F1 on 2026-07-24 and authorized the catalog
and memory updates to be committed and pushed. Product Expansion Discovery ends
at F1; no F2 or later analysis packet is authorized. Future Product work starts
from one authoritative feature specification and proceeds directly through
implementation, verification and review. Catalog inclusion remains distinct
from implementation authorization.
