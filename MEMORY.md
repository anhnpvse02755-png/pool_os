# Pool OS Project Memory

## Product Owner Strategic Direction

- Pool OS is an Operating System / Intelligence Platform for billiards, not a
  conventional mobile application. Framework completion takes priority over
  early product release.
- The authoritative order is: complete framework capabilities, freeze
  architecture, expand Knowledge, build the application/product layer, then
  run Internal Alpha and Public Beta. Do not reverse this order without
  explicit Product Owner direction.
- Framework Freeze requires stable Knowledge Runtime, Compiler, Publication,
  Learning Runtime, Player Model, Experience, Coach Runtime, Decision,
  Planning, Recommendation, Execution, AI Session, AI Response Boundary,
  future AI runtime contracts, replay, deterministic execution,
  compatibility, versioning, Evidence, provenance, and digest capabilities.
- AI must not compensate for missing Knowledge. The dependency remains
  Knowledge -> Runtime -> Coach -> AI.
- AI Vision is deferred beyond Framework Freeze and will later be an Evidence
  producer, not a reasoning engine.
- Application features such as Flutter UX, authentication, sync, dashboards,
  reports, analytics, and session/training/coach UI come after framework
  completion and consume frozen contracts.
- No early public beta, temporary shortcuts, publication bypasses, replay
  bypasses, deterministic execution bypasses, or redesign of frozen contracts.

## Official State (2026-07-21)

- M1 - Executable Architecture: Closed.
- M1.5 - Integrated Baseline: Closed. Tag: `v0.6.0-M1.5`.
- M2 - Runtime Hardening & Deterministic Publication: Closed.
- Evidence Runtime Hardening: Closed.
- Compiler & Publication Hardening: Closed.
- Knowledge Generalization (Compiler & Publication scope): Closed.
  - M2.1 Scale Conformance: Closed at `716c23a`.
  - M2.2 Production Dependency Validation: Closed at `0809c83`.
  - M2.3 36-entry Migration: Closed at `cc54024`.
  - M2.4 Reproducibility Proof: Closed; executable gate added at `b1f3316`,
    fresh-clone proof passed at `bbc1d67`.
- Learning Runtime Generalization: Closed.
  - LR-1 Policy Dispatch and Deterministic Ranking: Engineering Closed at
    `75dbec2`; Product Review Accepted and capability Closed.
  - LR-2 Dependency-aware Learning Decisions: Engineering Closed at
    `3c50e12`; Product Review Accepted and capability Closed.
  - LR-3 Policy-driven Availability and Recommendation Pipeline: Engineering
    Closed at `35a5457`; Product Review Accepted and capability Closed.
  - LR-4 Unlock Expression Contract: Engineering Closed at `eaf635b`; Product
    Review Accepted and capability Closed. Only `allOf`/AND is implemented.
- Canonical Knowledge Package v1: Closed.
  - LR-5 Canonical Knowledge Package v1 Publication: Engineering Closed at
    `77c5412`; Product Review Accepted and capability Closed.
  - Product Owner approved the executable scope: deterministic Package
    Manifest v1 is separate from the audit-oriented Publication Record.
  - Manifest is the runtime entry point: Manifest -> Compatibility -> Artifact
    -> Runtime Load. Direct package.json runtime load is not the LR-5 canonical
    path.
  - Compatibility declares versioned required runtime contracts, not generic
    capabilities, and enforces a minimum runtime version.
  - LR-5 ends at Published Candidate Package, Not Current. It must not update
    the production current pointer.
  - Product Owner resolved the reference direction: Publication Record ->
    Manifest Digest. Manifest never contains Publication Record digest and
    runtime never reads Publication Record.
  - LR-5 Accepted and Closed. Manifest `7e65f849`,
    Candidate Pack `419b2bc0`, RC `69d71e22`, isolated Publication Record
    `69224e17`; Knowledge package 75/75, app 222/222, architecture 133/0.
- M2 Final Validation: Engineering Complete at `689ba7e`; Product Review
  Accepted and M2 Closed. Corrected fresh-clone gate passed compiler, publication, Manifest
  compatibility/runtime load, replay, package 75/75, app 222/222, architecture
  133/0, governance linkage, and no unexpected content drift.
- M3 - AI Platform: Open.
  - M3.1 Player Model Foundation: Accepted and Closed; implementation at
    `261988a`. Versioned Profile, State, Progress Snapshot, and Coach Input
    contracts now run through a deterministic projector from Learning Runtime
    snapshots. No LLM, new recommendation, or M2 runtime semantic change was
    introduced.
  - M3.2 Experience Projection Foundation: Accepted and Closed; implementation
    at `2722e0d`. Deterministic timeline, session summary, and
    Experience Snapshot projections consume Learning Runtime and Player Model
    outputs without raw Evidence access, persistence, scoring, recommendation,
    or AI.
  - M3.3 Coach Context Foundation: Accepted and Closed; implementation at
    `8f6b98a`. The version-bound deterministic AI input contract combines
    Profile, Progress, and Experience without Evidence/Runtime access,
    inference, recommendation, persistence, or AI.
  - M3.4 Coach Decision Engine Foundation: Accepted and Closed; implementation
    at `7edc228`. Structured semantic decisions consume only Coach
    Context and retain reasons, trace, alternatives, version binding, and
    digest; no LLM, prompt, ML, scoring, or prose.
  - M3.5 Coach Decision Lifecycle Foundation: Accepted and Closed;
    implementation at `4856c4e`. Immutable decision states, deterministic
    transitions, replayable history, supersede rules, lifecycle digest, and
    history projection are implemented without Planner, AI, persistence, or
    mutation of the original Coach Decision.
  - M3.6 Coach Planning Foundation: Accepted and Closed; implementation at
    `b8786ce`. A pure deterministic Planner reads Coach Context plus Decision
    History and emits an immutable Coach Plan. It continues the sole active
    Decision or requests a new Decision after terminal history without selecting
    a Knowledge target, creating a Decision, ranking, Recommendation, prose,
    AI/LLM output, or persistence.
  - M3.7 Coach Recommendation Foundation: Accepted and Closed. Coach Context
    v2 adds a resolved Learning Eligibility Projection; Decision History
    remains v1. Recommendation consumes Coach Context, Decision History, and
    Coach Plan, may select a Technique or persistent Mistake correction only
    from those read models, and must not resolve prerequisite/unlock/
    dependency itself, create Coach Decisions, mutate inputs, use AI/LLM/ML
    scoring, or read Evidence directly.
  - M3.8 Coach Execution Foundation: Accepted and Closed. Execution accepts an
    immutable Recommendation and emits immutable append-only replayable
    Execution Records for Accepted, Rejected, Deferred, Expired, and Completed
    states. Only Accepted may append Completed; Execution must not mutate
    Recommendations, create Decisions, change Decision History, read Evidence,
    invoke Planner, or use AI/LLM.
  - M3.9 AI Session Boundary Foundation: Accepted and Closed.
    `AISessionContract` v1 and pure `AISessionBuilder` normalize and
    version-bind Coach Context, Coach Plan, Recommendation, and Execution
    Record into one deterministic `AISession` boundary. It contains only
    references/provenance and compatibility metadata; it must not call an LLM,
    engineer prompts, infer, plan, recommend, score, or persist. Future AI may
    read only `AISession`.
  - M3.10 AI Coach Response Foundation: Accepted and Closed. It adds immutable
    structured `CoachResponseContract` v1, deterministic
    `CoachAIRequestEnvelope`, and a stub/provider adapter that accepts only
    AISession. There is no real LLM integration, prompt, prose, streaming,
    tools, Vision, Memory, or AI planning.
  - M3.11 AI Capability Registry Foundation: Accepted and Closed. It adds an
    immutable capability registry and compatibility gate before any provider
    integration. `CoachAIAdapter` requires a registered compatible capability
    while AISession, CoachResponse, and M3.1-M3.10 contracts remain unchanged.
    It adds no LLM, prompts, tool calling, Vision, or provider implementation.
  - M3.12 AI Provider Foundation: Accepted and Closed. Providers are
    infrastructure plugins only; they must not contain Coach, Planner,
    Learning, or capability business logic. Provider replacement must not
    affect Pool OS core contracts.
  - M3.13 AI Orchestration Foundation: Accepted and Closed. The orchestrator
    owns deterministic capability/provider routing over existing contracts.
    It adds no prompt, AI, network, retry, fallback, timeout, queue,
    persistence, or application logic. M3 Foundation Freeze & Architecture
    Validation is Accepted and Closed. M3 Foundation is fully closed; the next
    governed step is Roadmap & Architecture Planning for M4, with no M4
    implementation before Product Owner review.

Active branch: `m2/evidence-runtime-hardening`.

## Locked Invariants

- Reference Behavior 0.6.0 Revision 2 and current Golden Fixtures are
  regression invariants.
- Player Model and Experience Snapshot are rebuildable projections, never
  sources of truth. Evidence remains factual input and Learning Runtime remains
  the versioned interpretation boundary.
- Coach Context is the API boundary for future AI consumers. AI must not bypass
  it to read Evidence, Event Log, Learning Runtime, or internal projection
  implementations.
- Coach Decision is immutable. Lifecycle changes create deterministic
  Transition records and never mutate the original Decision.
- Decision History is append-only. Existing transitions are immutable and may
  not be edited or deleted; lifecycle changes append a new transition.
- Planner is a pure read-only function over Coach Context and Decision History.
  It must not append, complete, supersede, or otherwise mutate Decision History.
- An active Decision cannot be bypassed. Planner may produce a next step only
  after lifecycle state permits it, and identical accepted inputs must produce
  an identical Coach Plan digest.
- Recommendation may select a concrete Technique or Mistake correction only
  from Coach Context, Decision History, and Coach Plan. Learning Runtime is
  the single source of truth for prerequisite, unlock, dependency, and
  availability resolution; Recommendation must consume its resolved
  eligibility projection and never resolve those rules itself. It must not
  create a Coach Decision, mutate its inputs, read Evidence directly, or use
  AI, LLM, or ML scoring.
- Hardening work must introduce zero new architecture debt and must include
  failure-path tests.
- Candidate Artifact -> Review -> Publication Record -> Atomic Current Pointer
  Commit -> Published Package.
- `Published` and `Current` are distinct. Published packages remain immutable
  for replay, rollback, and audit; `current` only selects the runtime package.
- Entry candidates end as `Eligible` or `Quarantined(reason)`.
- Quarantine cascades through dependency edges, not across unrelated entries.
- RC Content Digest includes RC schema version, compiler version, canonical
  entries, and the resolved dependency graph.
- Each resolved edge binds `entryId`, `dependencyId`, and
  `resolvedDependencyContentDigest`.
- Reviewer, review time, publication metadata, and runtime timestamps do not
  participate in RC Content Digest.
- Hard dependencies are projected only from typed Knowledge relations with
  `type: requires`. Legacy string relations remain associations; there is no
  separately authored dependency graph.
- Dependency validation applies only to relations that the schema defines as
  dependencies (`type: requires`). Other relations remain semantic
  associations and do not participate in dependency publication gating.
- Dependency validation rejects dangling, self, duplicate, and cyclic hard
  dependencies. Isolated entries remain valid under the current schema.
- A valid dependency whose target is not Eligible is quarantined as
  `dependencyUnavailable`.
- One `knowledgeVersion` maps to one RC Content Digest. Persistence-level
  uniqueness in the publication store remains future M2 work.
- Do not branch on Knowledge IDs, add policy/kind/capability, change runtime,
  migrate the 36 entries, or publish Canonical Knowledge Package v1 outside
  the explicitly authorized capability.

## Latest Verification

M3.6 verification at implementation commit `b8786ce`:

- `CoachPlanContract` v1 binds Context, Decision History, Knowledge, and Planner
  policy provenance into deterministic plan identity and digest.
- One active Decision produces `continueActiveDecision`; terminal history
  produces `requestNextDecision` without inventing a Decision or Knowledge
  target. Multiple active Decisions fail instead of being ranked.
- Planner does not import or duplicate the Knowledge dependency/unlock graph.
  Eligibility remains at the accepted Decision/Learning boundary, and Planner
  cannot bypass it by selecting a target.
- Planner and the public plan factory are pure read paths and do not append,
  complete, supersede, or otherwise mutate Decision History.
- Focused Coach Planning tests: 7/7; app tests: 269/269; Knowledge package
  tests: 75/75; Architecture Fitness: 133 existing / 0 new.
- Focused analyzer: no issues. Constitution, Reference Behavior, Golden
  Fixtures, production Knowledge/publication, and M2 proof records remain
  unchanged.
- Product Owner review accepted the executable scope on 2026-07-21 with no
  blocker or requested correction.

M3.6 milestone:
`architecture/milestones/M3_6_COACH_PLANNING_FOUNDATION.md`.

M3.7 verification:

- `LearningEligibilityProjection` v1 is a deterministic resolved read model
  with Knowledge provenance and bounded blocker reasons; it contains no
  Evidence, graph, compiler internals, or score.
- Coach Context v2 binds eligibility version/digest while Decision History
  remains the unchanged append-only v1 lifecycle projection.
- Active Plans continue the exact Decision ID/digest. Terminal Plans select
  only a resolved eligibility target or persistent Mistake correction.
- Focused M3.7 tests: 8/8; combined Coach foundation tests: 27/27; app tests:
  277/277; Knowledge package tests: 75/75; Architecture Fitness: 133 existing
  / 0 new.
- Focused analyzer: no issues. Protected Reference Behavior, Golden Fixtures,
  production Knowledge/publication, and M2 proof records remain unchanged.
- Product Owner accepted and closed M3.8 on 2026-07-21 with no requested
  correction.
- Product Owner accepted and closed M3.7 on 2026-07-21 with no requested
  correction.

M3.7 milestone:
`architecture/milestones/M3_7_COACH_RECOMMENDATION_FOUNDATION.md`.

M3.8 verification:

- Execution transitions bind Recommendation ID/digest and policy provenance;
  initial outcomes are Accepted, Rejected, Deferred, or Expired, and only
  Accepted can append Completed.
- Replay validates append-only sequence, transition shape, chronological order,
  Recommendation binding, and deterministic final state/digest. Recommendation
  and prior transitions remain unchanged.
- Focused M3.8 tests: 7/7; combined Coach foundation tests: 47/47; app tests:
  284/284; Knowledge package tests: 75/75; Architecture Fitness: 133 existing
  / 0 new.
- Focused analyzer: no issues. Protected Reference Behavior, Golden Fixtures,
  production Knowledge/publication, and M2 proof records remain unchanged.

M3.8 milestone:
`architecture/milestones/M3_8_COACH_EXECUTION_FOUNDATION.md`.

M3.9 verification:

- `AISessionContract` v1 is immutable, versioned, deterministic, and carries
  Knowledge identity, four input digests/IDs, provenance, required runtime
  contracts, and minimum AI contract version without raw deterministic internals.
- `AISessionBuilder` is pure and gates Context v2, Plan v1, Recommendation v1,
  Execution Record v1, Knowledge identity, provenance, compatibility metadata,
  stale inputs, mixed identity, duplicate IDs, and unsupported contract sets.
- Focused M3.9 tests: 7/7; combined M3.1-M3.9 Coach tests: 69/69; app tests:
  291/291; Knowledge package tests: 75/75; Architecture Fitness: 133 existing
  / 0 new.
- Focused analyzer: no issues. Protected Reference Behavior, Golden Fixtures,
  production Knowledge/publication, M2 proof records, and prior M3 identities
  remain unchanged.
- Product Owner accepted and closed M3.9 on 2026-07-21 with no requested
  correction.

M3.9 milestone:
`architecture/milestones/M3_9_AI_SESSION_BOUNDARY_FOUNDATION.md`.

M3.10 verification:

- `CoachResponseContract` v1 binds AISession ID/digest, Context digest,
  Knowledge version/digest, Recommendation ID, and Execution digest. The
  adapter request envelope is deterministic and provider-versioned.
- `DeterministicStubAIAdapter` accepts only AISession, emits a structured
  acknowledgement, and keeps generated content explicitly `notGenerated`.
  Response creation rejects request/session mismatch and leaves inputs
  unchanged.
- Focused M3.10 tests: 7/7; combined M3.1-M3.10 foundation tests: 76/76; app
  tests: 298/298; Knowledge package tests: 75/75; Architecture Fitness: 133
  existing / 0 new.
- Focused analyzer: no issues. Protected Reference Behavior, Golden Fixtures,
  production Knowledge/publication, M2 proof records, and M3.1-M3.9 identities
  remain unchanged.
- Product Owner accepted and closed M3.10 on 2026-07-21 with no requested
  correction.

M3.10 milestone:
`architecture/milestones/M3_10_AI_COACH_RESPONSE_FOUNDATION.md`.

M3.11 verification:

- `AICapabilityRegistryContract` v1 canonically stores capability definitions,
  AI contract version, minimum supported version, required runtime contracts,
  and compatibility rules. Duplicate IDs and invalid metadata fail loudly.
- Registry resolution rejects unknown or incompatible capabilities and emits a
  deterministic binding. `CoachAIAdapter` cannot create a request or response
  without successful registry resolution.
- Focused M3.11 tests: 8/8; combined M3.1-M3.11 foundation tests: 84/84; app
  tests: 306/306; Knowledge package tests: 75/75; Architecture Fitness: 133
  existing / 0 new.
- Focused analyzer: no issues. Protected Reference Behavior, Golden Fixtures,
  production Knowledge/publication, M2 proof records, and M3.1-M3.10
  identities remain unchanged.
- Product Owner accepted and closed M3.11 on 2026-07-21 with no requested
  correction.

M3.11 milestone:
`architecture/milestones/M3_11_AI_CAPABILITY_REGISTRY_FOUNDATION.md`.

M3.12 verification:

- `AIProvider` is a narrow infrastructure port over the public
  `CoachAIRequestEnvelope`; `AIProviderResult` is immutable, deterministic,
  provider-bound, and request-bound. The deterministic stub is the only
  implementation and contains no Coach, Planner, Learning, or capability
  business logic.
- `CoachAIAdapter` injects the provider after the M3.11 registry gate. It
  rejects provider identity mismatches and stale/foreign provider results;
  provider replacement does not change the deterministic session provenance.
- Focused M3.12 tests: 7/7; combined M3.1-M3.12 foundation tests: 91/91; app
  tests: 313/313; Knowledge package tests: 75/75; Architecture Fitness: 133
  existing / 0 new.
- Focused analyzer: no issues. Protected Reference Behavior, Golden Fixtures,
  production Knowledge/publication, M2 proof records, and M3.1-M3.11
  identities remain unchanged.
- M3.12 milestone:
  `architecture/milestones/M3_12_AI_PROVIDER_FOUNDATION.md`.
- Product Owner accepted and closed M3.12 on 2026-07-21. The next locked
  capability is M3.13 AI Orchestration Foundation; it must remain an
  immutable, deterministic coordinator over existing capability/provider
  contracts, with no prompt, AI, network, retry, queue, or application logic.

M3.13 verification:

- `AIOrchestrationRequest` v1 is immutable, canonical, and bound to AISession
  plus the capability registry. Callers request capability IDs only; provider
  routes remain orchestrator-owned infrastructure wiring.
- `DeterministicAIOrchestrator` resolves capability compatibility, selects the
  configured provider, invokes the provider-backed adapter, and emits immutable
  step/result records bound to session, registry, capability, request, and
  response digests.
- Duplicate capabilities/providers, ambiguous or missing routes, unknown
  capabilities, stale inputs, and foreign result steps fail closed. There is
  no real retry, fallback, timeout, async, queue, network, prompt, or AI.
- Focused M3.13 tests: 8/8; combined M3.1-M3.13 foundation tests: 99/99; app
  tests: 321/321; Knowledge package tests: 75/75; Architecture Fitness: 133
  existing / 0 new.
- Focused analyzer: no issues. Protected Reference Behavior, Golden Fixtures,
  production Knowledge/publication, M2 proof records, and M3.1-M3.12
  identities remain unchanged.
- M3.13 milestone:
  `architecture/milestones/M3_13_AI_ORCHESTRATION_FOUNDATION.md`.
- Product Owner accepted and closed M3.13 on 2026-07-21. The next backlog is
  M3 Foundation Freeze & Architecture Validation: audit M3.1-M3.13 contracts,
  freeze public boundaries, verify the dependency graph and clean-checkout
  reproducibility, keep the deterministic stub, and publish an Architecture
  Freeze Report before any AI integration.

M3 Foundation Freeze & Architecture Validation verification:

- The 14-contract manifest records normalized SHA-256 identities, version
  bindings, and the frozen application boundary.
- The executable validator reports 60 unique public symbols, 17 dependency
  edges, zero cycles, no contract drift, and no forbidden imports.
- Freeze-focused tests pass 4/4. Current app tests pass 325/325, Knowledge
  package tests pass 75/75, and Architecture Fitness remains 133 existing / 0
  new.
- The clean-checkout runner passes deterministic proof comparison, app,
  Knowledge, and architecture gates. Flutter generated plugin registrants are
  explicitly outside scope and allowlisted; no semantic Pool OS drift is
  accepted.
- Freeze report:
  `architecture/milestones/M3_FOUNDATION_FREEZE_ARCHITECTURE_VALIDATION.md`.
- Product Owner accepted and closed M3 Foundation Freeze on 2026-07-21.
- Baseline index:
  `architecture/milestones/M3_FOUNDATION_BASELINE_MANIFEST.json`.
- The next governed deliverable is Roadmap & Architecture Planning for M4;
  no M4 implementation, contract, runtime, UI, persistence, network, or
  production activation is authorized before Product Owner review.

M4.0 Roadmap & Architecture Planning is engineering complete and Product Owner
review pending. It is planning-only and defines an acyclic M4.1-M4.8 sequence
from deterministic Coach planning through AI runtime activation. No M4
production code, contract, runtime metadata, or protected-artifact change is
authorized until the planning package is accepted.

Product Owner accepted M4.0 on 2026-07-21 after the required revision moved
Intelligence Trace before session/adaptive reasoning and locked AI Runtime
Activation as an optional consumer of the deterministic pipeline. ADR-003 is
Accepted, M4.0 is Closed, and M4.1 Coach Planning Engine Foundation is Ready to
Start under its own executable scope.

M4.1 Coach Planning Engine Foundation is engineering complete and Product Owner
review pending. It adds a separate M4 graph contract and deterministic engine
over frozen M3 Context, Decision, Recommendation, and Execution public ports.
It creates only Decision -> Recommendation -> Execution structure, never reads
Knowledge graph internals, and fails closed on duplicate, mixed-session,
orphan, invalid/cyclic, stale Recommendation, or stale Execution inputs.
Focused tests pass 9/9; combined M3+M4.1 pass 108/108; app passes 334/334;
Knowledge passes 75/75; Architecture Fitness remains 133 existing / 0 new;
M3 freeze remains 14 contracts / 13 suites / 0 cycles.

Product Owner accepted and closed M4.1 on 2026-07-21. M4.2 Adaptive
Recommendation Engine Foundation is Ready to Start. It may reorder immutable
Recommendations by deterministic, explainable rules derived from execution
state, Player Progress, and Experience; it must not use ML/probability/LLM
scores or mutate Recommendation.

M4.2 Adaptive Recommendation Engine Foundation is engineering complete and
Product Owner review pending. `OrderedRecommendationViewContract` v1 exposes
priority bands and structured reasons, canonical tie-breaking, and fail-closed
stale/duplicate/inconsistent binding validation without mutating M3
Recommendations. Focused tests pass 8/8; combined M3+M4.1+M4.2 pass 116/116;
app passes 342/342; Knowledge passes 75/75; Architecture Fitness remains 133
existing / 0 new.

Product Owner accepted and closed M4.2 on 2026-07-21. M4.3 Intelligence Trace
and Explanation Foundation is Ready to Start. Trace is an observation-only,
structured audit layer for Planning and Recommendation; it must not change
their outputs or read Evidence, Runtime internals, AI, or Provider.

M4.3 Intelligence Trace and Explanation Foundation is engineering complete and
Product Owner review pending. `IntelligenceTraceContract` v1 and its builder
bind structured rule/input/output/reason entries to Context and preserve
deterministic replay without prose or prompt. Focused tests pass 3/3; combined
foundation tests pass 119/119; Architecture Fitness remains 133 existing / 0
new; M3 freeze remains PASS with 14 contracts and 0 cycles.

Product Owner accepted and closed M4.3 on 2026-07-21. M4.4 Training Session
Builder Foundation is Ready to Start. The trace remains observation-only and
must not alter Planner or Recommendation outputs.

M4.4 Training Session Builder Foundation is engineering complete and Product
Owner review pending. `TrainingSessionContract` v1 preserves ordered
Recommendation positions and binds each item to Recommendation ID/digest,
Planning Node ID, and Context digest without reorder/rescore/regeneration.
Focused tests pass 5/5; combined foundation tests pass 124/124; app passes
350/350; Architecture Fitness remains 133 existing / 0 new; M3 freeze remains
PASS.

M4.5 Session Execution Coordinator Foundation is engineering complete and
Product Owner review pending. `TrainingSessionExecutionContract` v1 derives
Pending/InProgress/Completed only from existing Execution Records and preserves
Session/Recommendation/Planning provenance without creating or evaluating
Execution. Focused tests pass 5/5; combined foundation tests pass 129/129; app
passes 355/355; Architecture Fitness remains 133 existing / 0 new.

Product Owner accepted and closed M4.5 on 2026-07-21. M4.6 Outcome Evaluation
Projection Foundation is Ready to Start. It may aggregate Session coverage and
Execution outcome states only; it must not compute score/mastery/confidence or
update Runtime, Player Progress, Decision, Recommendation, or Execution.

M4.6 Outcome Evaluation Projection Foundation is engineering complete and
Product Owner review pending. `TrainingOutcomeProjectionContract` v1 aggregates
completed/pending/deferred/rejected/expired counts and coverage with Session and
Execution provenance, without score/mastery/confidence or mutations. Focused
tests pass 3/3; combined foundation tests pass 132/132; app passes 358/358;
Architecture Fitness remains 133 existing / 0 new.

Product Owner accepted and closed M4.6 on 2026-07-21. M4.7 Coach Adaptation
Loop Foundation is Ready to Start. It may deterministically classify existing
Outcome items as continue/repeat/escalate/stop while preserving Outcome,
Session, and Context provenance. It is a read model and must not update Player
Progress, Learning Runtime, Planning, Decision, Recommendation, or Execution.

M4.7 Coach Adaptation Loop Foundation is engineering complete and Product Owner
review pending. `CoachAdaptationProjectionContract` v1 and its projector classify
completed/pending as continue, deferred as repeat, rejected as escalate, and
expired as stop. The projection binds Outcome, Session, and Context provenance,
rejects mixed-player/stale-session inputs and contradictory direct construction,
and performs no mutation or AI/scoring/analytics behavior. Focused tests pass
5/5; combined foundation tests pass 137/137; app passes 363/363; Knowledge
passes 75/75; Architecture Fitness remains 133 existing / 0 new; M3 freeze
proof record and protected artifacts remain unchanged. No M4.7 commit or push
has been performed before Product Owner review.

Product Owner accepted and closed M4.7 on 2026-07-21. M4.8 AI Runtime
Activation Gate Foundation is Ready to Start. The gate may consume only
AISession, Coach Adaptation Projection, and the Capability Registry, returning
Activated or Not Activated with a deterministic structured reason. It must not
invoke Provider/Orchestration, generate Prompt or Response, or add Memory,
Vision, RAG, Embedding, Scheduler, Persistence, or UI behavior.

M4.8 AI Runtime Activation Gate Foundation is engineering complete and Product
Owner review pending. `AIRuntimeActivationGateContract` v1 and its pure gate
bind AISession, Adaptation Projection, Capability Registry, capability ID, and
an activation key. The gate returns Activated or Not Activated and fails closed
for stale context, incompatible/unavailable capability, broken provenance, and
duplicate activation. Focused tests pass 4/4; combined foundation tests pass
141/141; app passes 367/367; Knowledge passes 75/75; Architecture Fitness
remains 133 existing / 0 new; M3 freeze proof record and protected artifacts
remain unchanged. No Provider, Orchestrator, Prompt, Response, Memory, Vision,
RAG, Embedding, Scheduler, Persistence, or UI behavior was added. No M4.8
commit or push has been performed before Product Owner review.

Product Owner accepted and closed M4.8 on 2026-07-21. M4 Foundation Freeze &
Architecture Validation is Ready to Start. This is a validation/freeze gate,
not a new capability. It must inventory M4 contracts/symbols/graphs/version
bindings, validate no cycles or M4-to-M3 leakage, prove M4.1-M4.8 replay and
immutability, and preserve Knowledge, M3 contracts, protected artifacts, and
AI behavior. Its outputs are an index-only manifest, machine-readable proof
record, and M4 freeze report before the M5 AI Integration phase can open.

M4 Foundation Freeze & Architecture Validation is engineering complete and
Product Owner review pending. The index-only baseline inventories 8 M4
contracts, 55 public symbols, 10 dependency edges with 0 cycles, and 8 focused
suites. Manifest digest is
`f7cdba7f41cd312f752293b3a073997c9bb1299514e981da2804e18bcd392d04`;
contract-set digest is
`54629ce61fd50b31b8f8d628292bac4768cc0700bdfca90f91dfc9ce4546f79e`.
Freeze-focused tests pass 4/4; combined foundation tests pass 141/141; current
app regression passes 367/367; clean-checkout app including freeze tests passes
371/371; Knowledge passes 75/75; Architecture Fitness remains 133 existing / 0
new. M3 does not import M4, the AI activation boundary does not import Learning
Runtime, deterministic replay/immutability checks pass, and protected artifacts
remain unchanged. No M4 freeze commit or push has been performed before Product
Owner review.

Product Owner accepted and closed M4 Foundation Freeze & Architecture
Validation on 2026-07-21. M3 Foundation and the complete deterministic M4
Intelligence Loop are frozen. M5 AI Integration Layer is Ready to Start, but
M5.0 must be planning-only: roadmap, dependency/layering, provider abstraction,
Prompt lifecycle, Memory, tool boundary, deferred Vision placement, human
override, cost/latency, and safety. No production code, runtime contract,
Provider, Prompt, LLM, or network work is authorized before M5.0 acceptance.

M5.0 AI Integration Architecture Planning is engineering complete and Product
Owner review pending. The proposed sequence is M5.1 Prompt Assembly, M5.2
Response Processing, M5.3 Tool Invocation, M5.4 Conversation Memory, M5.5
Provider Runtime Integration, M5.6 Safety & Policy Enforcement, M5.7 AI
Observability, and M5.8 Production AI Activation. ADR-004 preserves AISession
and Activation Gate as the only AI entry, keeps Providers in infrastructure,
treats output/Memory/tool results as untrusted derived data, requires
deterministic tool authorization and human override, and keeps Vision deferred
as an Evidence producer. M5.0 adds no production code or runtime contract.

Product Owner accepted and closed M5.0 on 2026-07-21. M5.1 Prompt Assembly
Foundation is Ready to Start. The AI layer now has a durable invariant:
Assembly -> Rendering -> Transport are separate responsibilities. M5.1 may only
build immutable, versioned, deterministic structured references bound to
AISession, Capability Registry, Coach Context, Planning Graph, Ordered
Recommendation View, and Adaptation Projection. It must not emit prompt text,
templates, Markdown/XML/JSON prompts, Provider payloads, Responses, Memory, or
tool calls.

M5.1 Prompt Assembly Foundation is engineering complete and Product Owner
review pending. `PromptAssemblyContract` v1 and `PromptAssemblyBuilder` contain
only canonical IDs, digests, capability/session bindings, and structured
metadata. They reject stale/mixed inputs, missing capability, duplicate
references, and broken provenance without rendering or transport behavior.
Focused tests pass 4/4; combined foundation tests pass 145/145; app passes
375/375; Knowledge passes 75/75; Architecture Fitness remains 133 existing / 0
new; M3/M4 baselines and protected artifacts remain unchanged. No M5.1 commit
or push has been performed before Product Owner review.

Product Owner accepted and closed M5.2 on 2026-07-22. M5.3 Tool Invocation
Foundation is Ready to Start. It may consume Prompt Rendering only and create
an immutable deterministic Tool Invocation Plan bound to Rendering, Capability,
Session, and Registry. It must not execute a tool or access HTTP, filesystem,
database, MCP, shell, plugin, Provider, or external APIs.

Product Owner approved the Prompt Rendering v2 contract alignment before M5.3.
The only additive fields are `sessionDigest` and `registryDigest`, copied
unchanged from Prompt Assembly. Product Owner accepted and closed the alignment
on 2026-07-22; Prompt Rendering v2 is the official M5.3 baseline:
v2 round-trip and v1 legacy read/replay pass, focused rendering tests pass 5/5,
app passes 380/380, Knowledge passes 75/75, and Architecture Fitness remains
133 existing / 0 new.

Product Owner accepted and closed M5.1 on 2026-07-22. M5.2 Prompt Rendering
Foundation is Ready to Start. Rendering consumes Prompt Assembly only and emits
a provider-neutral structured payload with its own version and digest. It must
not consume Context/Planning/Recommendation directly or perform Provider
formatting, token counting, HTTP, retry, credential, SDK, or network behavior.

M5.2 Prompt Rendering Foundation is engineering complete and Product Owner
review pending. `PromptRenderingContract` v1 and `PromptRenderer` consume Prompt
Assembly only and create five canonical provider-neutral structured sections
with independent payload/contract digests. Unsupported targets/strategies,
invalid ordering, duplicate references, and broken provenance fail closed.
Focused tests pass 4/4; combined foundation tests pass 149/149; app passes
379/379; Knowledge passes 75/75; Architecture Fitness remains 133 existing / 0
new; M3/M4 baselines and protected artifacts remain unchanged. No M5.2 commit
or push has been performed before Product Owner review.

Product Owner accepted and closed M4.4 on 2026-07-21. M4.5 Session Execution
Coordinator Foundation is Ready to Start. It must manage only Session lifecycle
over Training Session and existing Execution Records, without creating or
evaluating Execution or mutating Recommendation.

M3.5 verification at implementation commit `4856c4e`:

- Coach Decision lifecycle transitions are immutable, sequence-bound,
  chronological, and replayable into deterministic lifecycle and history
  projections.
- Completion and supersede are terminal; supersede requires a distinct newer
  Decision and preserves the replacement Decision ID and digest.
- The lifecycle factory rejects terminal projections that omit the initial
  issued transition, closing the direct-construction path outside projector
  replay.
- Focused Coach Decision Lifecycle tests: 13/13; app tests: 262/262; Knowledge
  package tests: 75/75; Architecture Fitness: 133 existing / 0 new.
- Focused analyzer: no issues. Constitution, Reference Behavior, Golden
  Fixtures, production Knowledge/publication, and M2 proof records remain
  unchanged. The three pre-existing generated plugin changes remain untouched.
- Product Owner review accepted the executable scope on 2026-07-21 with no
  blocker or requested correction.

M3.5 milestone:
`architecture/milestones/M3_5_COACH_DECISION_LIFECYCLE_FOUNDATION.md`.

M3.4 verification at implementation commit `7edc228`:

- Decision priority is persistent correction, unmastered Technique, then
  readiness; readiness does not invent a Planner target.
- Ties use canonical IDs and retain alternatives without scores.
- Context/Knowledge/policy versions, reasons, trace, and alternatives bind the
  deterministic decision digest.
- M3.4 exposed and corrected an M3.2 initial-decision Experience event ID
  collision by binding Knowledge ID plus Decision ID.
- Focused Coach Decision tests: 6/6; combined M3.2/M3.4: 14/14; app tests:
  249/249; Knowledge package: 75/75; Architecture Fitness: 133/0.
- Focused analyzer: no issues; all protected M1/M2 artifacts remain unchanged.

M3.4 milestone:
`architecture/milestones/M3_4_COACH_DECISION_ENGINE_FOUNDATION.md`.

M3.3 verification at implementation commit `8f6b98a`:

- Coach Context Contract v1 contains Profile, Progress, and Experience only.
- Version binding covers all three contract versions plus Knowledge version and
  digest; the complete deterministic payload participates in Context digest.
- Player mismatch, stale Player Progress binding, and Knowledge mismatch fail
  loudly.
- The builder imports projections/contracts only and has no Evidence, Event
  Log, persistence, Flutter, recommendation, planning, or AI dependency.
- Focused Coach Context tests: 6/6; app tests: 242/242; Knowledge package tests:
  75/75; Architecture Fitness: 133 existing / 0 new.
- Focused analyzer: no issues. Constitution, Reference Behavior, Golden
  Fixtures, production Knowledge/publication, and M2 digests are unchanged.

M3.3 milestone:
`architecture/milestones/M3_3_COACH_CONTEXT_FOUNDATION.md`.

M3.2 verification at implementation commit `2722e0d`:

- Experience Event Contract v1 records derived Learning Decision timeline
  items; it is not a canonical Evidence event or source of truth.
- Timeline ordering is canonical by UTC occurrence time and stable event ID.
- Session Summary covers its timeline events exactly and introduces no score or
  inference.
- Experience Snapshot binds the timeline to Player Progress and Knowledge
  identities with a deterministic SHA-256 digest.
- Empty, duplicate, mixed-Knowledge, incomplete-summary, and cross-player paths
  fail loudly.
- Focused Experience tests: 7/7; app tests: 236/236; Knowledge package tests:
  75/75; Architecture Fitness: 133 existing / 0 new.
- Focused analyzer: no issues. Constitution, Reference Behavior, Golden
  Fixtures, production Knowledge/publication, and M2 digests are unchanged.

M3.2 milestone:
`architecture/milestones/M3_2_EXPERIENCE_PROJECTION_FOUNDATION.md`.

M3.1 verification at implementation commit `261988a`:

- Player Model is an Intelligence capability and its projector is an
  application service.
- Player Profile and Progress Snapshot are UI-independent versioned contracts.
- Coach Input contains Player Model contracts and never raw Evidence records.
- Snapshot JSON and SHA-256 digest are deterministic across input ordering.
- Empty, duplicate, mixed-Knowledge, and player-ID mismatch cases fail loudly.
- Focused Player Model tests: 7/7; app tests: 229/229; Knowledge package tests:
  75/75; Architecture Fitness: 133 existing / 0 new.
- Focused analyzer: no issues. Existing full analyzer baselines remain app 62
  info and package 4 info + 1 warning.
- Constitution, Reference Behavior, Golden Fixtures, production Knowledge,
  publication artifacts, and M2 digests remain unchanged.

M3.1 milestone:
`architecture/milestones/M3_1_PLAYER_MODEL_FOUNDATION.md`.

LR-4 verification at implementation commit `eaf635b`:

- Additive `unlock.allOf` authoring compiles to a canonical nested AND tree.
- Expression leaves populate the existing hard dependency graph and RC digest;
  compiler rejects cycles before runtime.
- Runtime trace identifies failed dependency leaves and failed `allOf` nodes
  using structured node IDs; no prose is embedded.
- OR, NOT, empty allOf, and mixed `requires` plus `unlock` declarations fail
  loudly. Existing typed `requires` remains backward compatible.
- LR-4 compiler conformance: 5/5; runtime conformance: 3/3.
- LR-4 RC digest:
  `69d71e22e2f47d85060cc5bd03a1e5af0fd34b6e3e1bbb82f0764648971b71f6`.
- LR-4 Candidate Pack digest:
  `419b2bc04c402726d9b4b382523e83a83a23467e1c4c83dcc8b1cac05080dc38`.
- Knowledge package tests: 72/72; app tests: 222/222.
- Architecture Fitness: 133 existing / 0 new.
- Production compiler, M2.3 migration, M2.4 reproducibility, LR-2 fixture,
  Golden, and replay regression: PASS with prior identities unchanged.
- Publication, Evidence, Reference Behavior, Constitution, production
  Knowledge 0.2.1, and current are unchanged.

LR-4 milestone:
`architecture/milestones/LR_4_UNLOCK_EXPRESSION_CONTRACT.md`.

LR-3 verification at implementation commit `35a5457`:

- Technique decisions execute explicit Availability -> Mastery ->
  Recommendation -> Correction -> Decision stages.
- Availability returns typed state and blockers without creating
  Recommendation candidates.
- Mastery returns assessment and structured reasons without creating
  Recommendation candidates.
- Recommendation consumes resolved Availability and Mastery; it does not
  evaluate dependency evidence itself.
- Correction resolution has no Mastery or Recommendation input.
- LR-3 stage conformance: 4/4; focused LR-1/LR-2/Golden regression: 26/26.
- App tests: 219/219; Knowledge package baseline: 67/67.
- Architecture Fitness: 133 existing / 0 new.
- Analyzer: no errors or warnings; existing app info baseline remains 62.
- Production compiler drift, M2.3 migration, and M2.4 reproducibility: PASS;
  all prior RC and Candidate Pack digests are unchanged.
- Compiler, Publication, Evidence, Golden Fixtures, Reference Behavior,
  Constitution, production Knowledge 0.2.1, and current are unchanged.

LR-3 milestone:
`architecture/milestones/LR_3_POLICY_DRIVEN_DECISION_PIPELINE.md`.

LR-2 verification at implementation commit `3c50e12`:

- Executable Knowledge preserves typed `requires` relations in an optional,
  additive `dependencies` field; semantic `relations` remain unchanged.
- Learning decisions gate the current Technique on direct dependencies using
  implicit ALL semantics, with no recursive or transitive traversal.
- Structured `PREREQUISITE_UNSATISFIED` and `PREREQUISITE_SATISFIED` reasons
  carry dependency ID, measurement evidence, and policy version.
- Compiler/publication remains the primary dependency graph gate; runtime
  defensively rejects dangling and cyclic executable graphs.
- LR-2 RC digest:
  `ee09ca62a354fb6cf8c3754f72dac105e2e1d46f087a7a349145e8794cfe189b`.
- LR-2 Candidate Pack digest:
  `531a7e6d5066fc1dca33aaca10b6080648dfdc70dfd2b1278bd3d3959a6dcc82`.
- LR-2 fixture tests: 4/4; LR-2 app behavior tests: 4/4.
- Knowledge package tests: 67/67.
- App tests, including accepted Golden/replay behavior: 215/215.
- Architecture Fitness: 133 existing / 0 new.
- Production Knowledge/current, M2.3/M2.4 identities, Golden Fixtures,
  Reference Behavior, Evidence contracts, Publication records, and
  Constitution are unchanged.

LR-2 milestone:
`architecture/milestones/LR_2_DEPENDENCY_AWARE_LEARNING_DECISIONS.md`.

LR-1 verification at implementation commit `75dbec2`:

- Generic Learning Runtime dispatch resolves payload kind plus versioned
  policy; no Knowledge-ID branch.
- Third Technique proof passed Markdown -> compile -> scoped review -> RC ->
  isolated candidate publication -> runtime load.
- LR-1 RC digest:
  `f9b7d6f5fd280d183e2f973fab9e46c43f4a8c3d614bdb8f16ff671e629bdc8d`.
- LR-1 Candidate Pack digest:
  `4d4faab782d90d389cfc1d49e6b9703f47fdbc26a04e354b5346842e463e4060`.
- Existing `advanced` policy: 15/20 remains below threshold; 16/20 achieves
  Mastery and changes the recommendation.
- Evidence isolation across two Techniques and two Mistakes: PASS.
- Equal-score ranking uses policy score then stable semantic ID and is stable
  across pack order: PASS.
- Unsupported kind, missing capability, unknown ID, and probabilistic policy
  fail with `ExecutableKnowledgeException`: PASS.
- Knowledge package tests: 63/63.
- App tests, including accepted Golden/replay behavior: 211/211.
- Architecture Fitness: 133 existing / 0 new.
- Production Knowledge/current, Golden Fixtures, Reference Behavior,
  Constitution, and M2.3/M2.4 identities are unchanged.

LR-1 milestone:
`architecture/milestones/LR_1_POLICY_DISPATCH_DETERMINISTIC_RANKING.md`.

M2.4 fresh-clone verification at commit `bbc1d67`:

- Clone source: GitHub branch `m2/evidence-runtime-hardening`.
- RC Content Digest reproduced exactly:
  `fbe07edcaa9db94326db2d204ac2a9753d50ea32163a52995cd875251fba26ac`.
- Candidate Pack Digest reproduced exactly:
  `22f60cdcaab064c07f1feaf600d9f9f9ea2b892db23fcc490304c9024e4e5e02`.
- Publication schema, provenance linkage, review scope, and semantics:
  equivalent.
- Candidate Runtime Load and production Knowledge 0.2.1 Runtime Load: PASS.
- Knowledge package tests: 61/61.
- App tests, including replay/restart coverage: 207/207.
- Architecture Fitness: 133 existing / 0 new.
- Production current pointer unchanged; no activation or production publish.
- Different-machine/user/locale proof remains Extended Evidence and was not
  required for M2.4 closure.

M2.4 machine-readable evidence is stored at
`architecture/milestones/m2_4/proof_record.json`.

M2.2 verification at commit `0809c83`:

- M2.2 conformance: 8/8.
- App tests: 207/207.
- Knowledge package tests: 51/51.
- Compiler conformance: 5/5.
- Golden vertical slice: 14/14.
- Frozen regression: 28 files unchanged.
- Architecture Fitness: 133 existing / 0 new.
- Analyzer baseline: 62 app info + 4 package info; no errors or warnings.
- Production Knowledge 0.2.1 compiler drift, Publication Check, and Runtime
  Load: PASS.
- Production corpus, runtime, Golden Fixtures, and Reference Behavior were not
  changed by M2.2.

## M2.3 Readiness Review (2026-07-21)

This section records the pre-implementation review. M2.3 subsequently closed at
`cc54024`; the observed risks below became explicit migration outcomes rather
than being hidden or coerced.

The migration input at `packages/billiard_knowledge/assets/pack_v1.json`
contains 36 entries, 4 learning paths, and 15 sources. It is not yet canonical
authoring and must remain a read-only migration input.

Observed inventory:

- 34 entries are `reviewed`; `term.tro` and `term.cu_le` are still `draft`.
- The input has 8 kinds: 12 Technique, 7 Concept, 4 Terminology, 5 Rule,
  4 Strategy, 2 Common Mistake, 1 Equipment, and 1 Mental.
- The executable runtime currently supports only Technique, Mistake, and
  Concept. Scale conformance used synthetic entries and does not prove that all
  production shapes can compile.
- `control.stop_shot` and `control.follow_shot` collide with existing canonical
  IDs. They must be reconciled as revisions, not added as duplicate entries.
- `aim.ghost_ball` is a semantic collision with canonical
  `aiming.ghost_ball`; the stable-ID mapping requires explicit review.
- Legacy `commonMistake` does not match the current `mistake` contract.
- Current Technique payloads require Outcome, Measurement, Drill, mastery
  category, and next recommendation. Most legacy Technique entries do not
  satisfy that contract and must not be coerced into another kind.
- Current compiler output does not yet preserve the full source/provenance and
  entry revision fields required for bulk migration.

### Authorized next batch: M2.3A Migration Inventory and ID Mapping

M2.3A is a dry-run/governance batch, not a publication batch. It must:

1. Produce a deterministic mapping row for every one of the 36 inputs.
2. Classify each row as `merge_existing`, `migrate_candidate`, or
   `quarantine` with a stable reason code.
3. Record the target semantic ID, target kind, source IDs, review state, and
   relation interpretation without changing the source pack.
4. Quarantine the two draft terminology entries unless Domain Review changes
   their review state.
5. Keep Knowledge 0.2.1, the production current pointer, runtime behavior,
   Golden Fixtures, and Reference Behavior unchanged.

### Conditional pilot: M2.3B Concept Migration

After the mapping is reviewed, migrate the 7 reviewed Concept inputs as the
first compiler-backed pilot:

- `fundamental.alignment.visual`
- `aim.ghost_ball` -> reviewed target `aiming.ghost_ball`
- `aim.cut_angle`
- `physics.throw.awareness`
- `control.tangent_line`
- `physics.squirt`
- `physics.swerve`

This pilot adds 6 new canonical IDs and revises one existing canonical entry.
It must stop at Candidate/Entry Review/Eligible-or-Quarantined/immutable RC.
It must not publish or move `publication/current.json`; activation remains an
M2.4 concern.

M2.3B exit gates:

- stable-ID mapping approved;
- source provenance and entry revision survive compilation;
- typed relation meaning is preserved without inventing hard dependencies;
- deterministic compiler and RC digests pass reorder/rebuild checks;
- every candidate has a scoped review decision or quarantine reason;
- production 0.2.1 drift, Golden Fixtures, Reference Behavior, and frozen M1.5
  baseline remain unchanged;
- architecture fitness reports zero new violations.

M2.3 remains one 36-entry migration capability despite the internal A/B batch
sequence. Its completion report must include:

- total migration inputs: 36;
- published/eligible count and quarantined count;
- quarantine reason-code breakdown;
- manual generated-output fixes: 0;
- direct publications or publication bypasses: 0;
- deterministic RC rebuild: PASS;
- publication pipeline check: PASS without activating the production current
  pointer before the separately authorized M2.4 proof.

Focused verification on the remote M2 HEAD `58a46ef` passed 21/21 tests across
M2.1 scale conformance, M2.2 dependency validation, and compiler conformance.
This proves the hardening baseline, not production-shape migration readiness.

## M2.3 Completion (2026-07-21)

M2.3 engineering migration is Closed at `cc54024`.

- 36 Pack v1.4 inputs received deterministic dispositions.
- 31 inputs became new canonical candidates.
- 3 inputs merged into existing stable IDs: Stop Shot, Follow Shot, and Ghost
  Ball (`aim.ghost_ball` -> `aiming.ghost_ball`).
- `term.tro` and `term.cu_le` remain quarantined with `reviewStateDraft`.
- Migration input candidates: 36. Eligible migration inputs: 34. Quarantined
  migration inputs: 2.
- The RC contains 35 target entries because the 34 reviewed inputs are
  reconciled with stable IDs and canonical Poor Speed Control is retained.
  `Eligible` does not mean `Published`, and no M2.3 candidate is
  production-current.
- Release Candidate digest:
  `fbe07edcaa9db94326db2d204ac2a9753d50ea32163a52995cd875251fba26ac`.
- Candidate Pack digest:
  `22f60cdcaab064c07f1feaf600d9f9f9ea2b892db23fcc490304c9024e4e5e02`.
- Deterministic rebuild and isolated publication pipeline: PASS.
- Manual generated-output fixes: 0. Direct production publications: 0.
- Production Knowledge remains 0.2.1; production current, runtime behavior,
  Golden Fixtures, Reference Behavior, and frozen M1.5 files are unchanged.

Verification at `cc54024`:

- App tests: 207/207.
- Knowledge package tests: 58/58.
- M2.3 conformance: 6/6.
- Compiler drift: PASS.
- Production Publication Check and Runtime Load: PASS on Windows after
  canonical newline verification was added.
- Frozen regression: 28 files unchanged.
- Architecture Fitness: 133 existing / 0 new.
- Analyzer baseline: 62 app info + 4 package info; no errors or warnings.

Canonical Knowledge Package v1 remains blocked from production activation
until later publication work explicitly handles:

- 15 source records that currently have `legacy_metadata_only` rather than
  content-addressed source snapshots;
- four deferred learning paths;
- the two quarantined draft terminology entries, unless they remain excluded
  by an approved publication decision.

## Cross-machine Continuation Rule

Before continuing on either machine:

1. Fetch origin and tags.
2. Read this file from the active remote branch, then read `AGENTS.md` and
   `ARCHITECTURE_CONSTITUTION.md`.
3. Compare local HEAD and worktree status with the active remote branch before
   editing.
4. At the end of a completed capability or review decision, update this file,
   commit the evidence, and push the active branch so the other machine can
   continue from GitHub.
5. Never overwrite or discard a dirty worktree to synchronize machines; stash
   or isolate it first and record the recovery reference.

## Continue On Another Machine

```powershell
git fetch origin --prune --tags
git switch m2/evidence-runtime-hardening
git pull --ff-only origin m2/evidence-runtime-hardening
```

Before continuing Learning Runtime Generalization, read `AGENTS.md`,
`ARCHITECTURE_CONSTITUTION.md`, and this file. M2.4 closed reproducibility only;
do not treat its isolated publication proof as authorization to move production
current or publish Canonical Knowledge Package v1. LR-1 is engineering-complete
and Product Accepted. Do not reopen LR-1 without a regression or governance
decision. LR-2 Dependency-aware Learning Decisions is the next batch and must
receive its own executable scope before implementation.
Product Owner accepted and closed the additive Capability Registry v2
alignment on 2026-07-22. The frozen M3 `AICapabilityRegistryContract` v1
remains unchanged; v2 exposes canonical `allowedToolIds`, optional
`defaultToolId`, and a fixed invocation-policy enum for Tool Invocation
planning. Focused v2 alignment tests 4/4, app 384/384, Knowledge 75/75, M3
Foundation Freeze PASS, and Architecture Fitness 133 existing / 0 new. M5.3
Tool Invocation Foundation is now Ready to Start with PromptRendering v2 and
Registry v2 as its baselines.
Product Owner accepted and closed M5.3 Tool Invocation Foundation on
2026-07-22. `ToolInvocationPlanner` consumes only PromptRendering v2 and
Capability Registry v2, then creates immutable deterministic invocation/plan
contracts bound to Rendering, Session, Registry, capability, registered default
tool, and structured policy reason. It rejects stale or legacy Rendering,
registry mismatch, unknown capability, missing default tool, duplicates, and
broken bindings. Focused tests pass 7/7; app passes 391/391; Knowledge passes
75/75; Architecture Fitness remains 133 existing / 0 new. No tool execution,
Provider, HTTP, filesystem, database, MCP, shell, plugin, commit, or push is
present. M5.4 AI Response Processing Foundation is Ready to Start; it may
consume only AIProviderResult and ToolInvocationPlan to validate, canonicalize,
normalize, and bind a provider-neutral structured artifact. It must not
interpret, summarize, score, rank, explain, persist, or mutate deterministic
sources of truth.
Product Owner accepted and closed M5.3A AI Provider Request Foundation on
2026-07-22. `AIProviderRequestContract` binds Tool Invocation Plan
provenance to the unchanged nested `CoachAIRequestEnvelope`.
`providerPayloadDigest` is the envelope digest referenced by Provider Result;
`providerRequestDigest` is the separate outer provenance/replay identity.
Focused tests pass 6/6; app passes 397/397; Knowledge passes 75/75;
Architecture Fitness remains 133 existing / 0 new. No frozen Provider port,
Provider Result, envelope, Tool Invocation Plan, Provider implementation,
has changed. M5.4 AI Response Processing Foundation is Ready to Start and may
consume only AIProviderRequestContract and AIProviderResult.
Product Owner accepted and closed M5.4 AI Response Processing Foundation on
2026-07-22. `AIResponseProcessor` consumes only Provider Request and
Provider Result and creates an immutable provider-neutral structured projection
bound to payload/request/result digests and capability. It validates Provider
identity/version/status and fails closed on stale or broken provenance. Focused
tests pass 6/6; app passes 403/403; Knowledge passes 75/75; Architecture Fitness
remains 133 existing / 0 new. No interpretation, summarization, scoring,
recommendation, Provider invocation, tool execution, commit, or push is present
present. M5.5 AI Conversation Memory Foundation is Ready to Start as an
immutable replayable projection consuming only AIResponseProcessingContract;
it is not persistence, canonical chat history, semantic memory, retrieval, or
a deterministic source of truth.
Product Owner accepted and closed M5.5 AI Conversation Memory Foundation on
2026-07-22. The immutable deterministic projection consumes only AI
Response Processing artifacts, stores canonical capability/provider-processing
references, rejects duplicates and foreign capability, and contains no raw
prompt/completion, embeddings, vectors, persistence, retrieval, or semantic
memory. Focused tests pass 6/6; app passes 409/409; Knowledge passes 75/75;
Architecture Fitness remains 133 existing / 0 new. No commit or push has been
performed. M5.6 AI Tool Result Projection Foundation is Ready to Start; its
projector may consume only AIResponseProcessingContract and must remain a
reference-only projection with no tool execution or raw tool payload.
Product Owner accepted and closed M5.6A/B tool identity alignments on
2026-07-22. Additive v2 wrappers copy `toolId` along the locked chain
ToolInvocationPlan -> AIProviderRequest v2 -> AIResponseProcessing v2 without
lookup, inference, recomputation, or transformation; v1 contracts and frozen
artifacts remain unchanged. Focused alignment tests pass 5/5; app passes
414/414; Knowledge passes 75/75; Architecture Fitness remains 133 existing /
0 new. M5.6 Tool Result Projection is not implemented until both alignments are
Accepted and Closed. M5.6 AI Tool Result Projection Foundation is Ready to
Start and consumes only AIResponseProcessing v2.
Product Owner accepted and closed M5.6 AI Tool Result Projection Foundation on
2026-07-22. The projector consumes only AIResponseProcessing v2 and
creates immutable canonical tool/capability/processing/Provider reference
entries with execution status and deterministic ordering. It contains no raw
tool output, execution, runtime lookup, persistence, or reasoning. Focused tests
pass 6/6; app passes 420/420; Knowledge passes 75/75; Architecture Fitness
remains 133 existing / 0 new. No commit or push has been performed before
Product Owner review. M5.7 AI Observability Foundation is Ready to Start as a
deterministic reference projection across public AI pipeline contracts, not a
logging, telemetry, metrics, tracing, persistence, or monitoring runtime.
Product Owner accepted and closed M5.7 AI Observability Foundation on
2026-07-22. The immutable deterministic projection verifies and records the
fixed nine-stage public AI pipeline reference chain without logging, telemetry,
metrics, latency, tokens, cost, persistence, monitoring, or Provider
instrumentation. Focused tests pass 5/5; app passes 425/425; Knowledge passes
75/75; Architecture Fitness remains 133 existing / 0 new. No commit or push has
been performed. M5.8 Production AI Activation Foundation is Ready to Start as
the final M5 activation boundary consuming only AIRuntimeActivationGate and
AIObservabilityProjection; it must not invoke any real AI runtime.
Product Owner accepted and closed M5.8 AI Production Activation Foundation on
2026-07-22. The immutable activation projection consumes only the
existing AIRuntimeActivationGate and AIObservabilityProjection, fail closes on
inactive/duplicate/foreign/broken provenance, and contains no runtime/provider
integration. Focused tests pass 5/5; app passes 430/430; Knowledge passes 75/75;
Architecture Fitness remains 133 existing / 0 new. No commit or push has been
performed. M5 Foundation Freeze & Architecture Validation is Ready to Start;
no M6 capability is authorized before that freeze is Accepted.
Product Owner accepted and closed M5 Foundation Freeze on 2026-07-22. M5 is a
frozen deterministic baseline: 12 contracts, 11 suites, 33 public symbols, 25
edges, 0 cycles, manifest `588fa4df...f91f2`, contract-set
`3208f6e1...bc32`, app 434/434, Knowledge 75/75, Architecture 133/0, and
protected M3/M4 hashes PASS. M6.0 Runtime & Product Architecture Planning is
Ready to Start; no M6 implementation is authorized.
Product Owner accepted and closed M6.0 Runtime & Product Architecture Planning
on 2026-07-22. The planning package defines M6.1-M6.8 sequencing, ownership,
layering, and ADR-005 without implementation. M6.1 Runtime Composition Engine
Foundation is Ready to Start; it may only compose public M3-M5 contracts and
must not contain business flow, persistence, Provider, API, UI, or AI reasoning.
Product Owner accepted and closed M6.1 Runtime Composition Engine Foundation
on 2026-07-22. Evidence: 11 nodes, 10 edges, 0 cycles, focused 7/7, app
441/441, Knowledge 75/75, Architecture 133/0, and M3-M5 freeze 12/12. M6.2
Runtime Pipeline Engine Foundation is Ready to Start and may only describe
execution topology from RuntimeCompositionContract without executing runtime.
Product Owner accepted and closed M6.2 Runtime Pipeline Engine Foundation on
2026-07-22. Evidence: 3 stages, 2 transitions, 0 cycles, focused 7/7, app
448/448, Knowledge 75/75, and Architecture 133/0. M6.3 Runtime Execution Graph
Foundation is Ready to Start and may consume only RuntimePipelineContract to
describe structural execution relationships without execution or side effects.
Product Owner accepted and closed M6.4 Runtime State Projection Foundation on
2026-07-22. Evidence: 3 state nodes, Ready 1, Waiting 2, focused 7/7, app
462/462, Knowledge 75/75, Architecture 133/0. M6.5 Runtime Transition
Foundation is Ready to Start and may only validate transition candidates from
RuntimeStateProjectionContract without changing state or executing runtime.
M6.5 Runtime Transition Foundation is engineering complete and pending Product
Owner review. It validates only the allowed transition matrix against the
immutable M6.4 projection; no state machine, current state, execution, or side
effects are present and no commit/push is authorized before acceptance.
M6.4 Runtime State Projection Foundation is engineering complete and pending
Product Owner review. It consumes only RuntimeExecutionGraphContract and emits
an immutable topology-derived snapshot; no state transitions, execution, or
side effects are present and no commit/push is authorized before acceptance.
Product Owner accepted and closed M6.5 Runtime Transition Foundation on
2026-07-22. Evidence: allowed matrix validated, focused 7/7, app 469/469,
Knowledge 75/75, Architecture 133/0. M6.6 Runtime Validation Foundation is
Ready to Start and may validate consistency across M6.1-M6.5 only.
M6.6 Runtime Validation Foundation is engineering complete and pending Product
Owner review. It validates the five M6 artifact identity boundaries
deterministically and performs no runtime execution or mutation.
Product Owner accepted and closed M6.6 Runtime Validation Foundation on
2026-07-22. Evidence: 5 artifacts checked, focused 7/7, app 476/476, Knowledge
75/75, Architecture 133/0. M6 Foundation Freeze & Architecture Validation is
Ready to Start; no new capability or runtime behavior is authorized.
M6 Foundation Freeze & Architecture Validation is engineering complete and
pending Product Owner review. Freeze inventory: 6 contracts, 19 public symbols,
5 dependency edges, 0 cycles; focused freeze 2/2. The last full regression is
app 476/476, Knowledge 75/75, Architecture 133/0. No commit/push before review.
Product Owner accepted and closed M6.3 Runtime Execution Graph Foundation on
2026-07-22. Evidence: 3 execution nodes, 2 dependencies, reachability/cycle/
replay proofs, focused 7/7, app 455/455, Knowledge 75/75, Architecture 133/0.
M6.4 Runtime State Projection Foundation is Ready to Start and may only derive
deterministic snapshots from RuntimeExecutionGraphContract.
M6.3 Runtime Execution Graph Foundation is engineering complete and pending
Product Owner review. It consumes only RuntimePipelineContract and produces an
immutable deterministic structural graph with reachability and cycle checks;
no execution or side effects are present and no commit/push is authorized
before acceptance.
Product Owner accepted and closed M6 Foundation Freeze on 2026-07-22. M6 is
officially Closed with 6 frozen contracts, 19 public symbols, 5 dependency
edges, 0 cycles, focused freeze 2/2, app 476/476, Knowledge 75/75, and
Architecture 133/0. M7.0 Product Runtime & Integration Architecture Planning
is Ready to Start and remains planning-only.
M7.0 Product Runtime & Integration Architecture Planning is engineering
complete and pending Product Owner review. The package defines 8 capabilities,
9 dependency edges, 0 cycles, Runtime Core/Application/Adapter/Operations
layers, ownership, sequencing, and ADR-006. No production implementation is
authorized before Product Owner acceptance.
Product Owner accepted and closed M7.0 Product Runtime & Integration
Architecture Planning on 2026-07-22. Evidence: 8 capabilities, 9 dependency
edges, 0 cycles, protected freeze 14/14, Architecture 133/0. M7.1 Runtime
Composition Coordinator Foundation is Ready to Start and may consume only the
M6 composition and pipeline public contracts.
M7.1 Runtime Composition Coordinator Foundation is engineering complete and
pending Product Owner review. It adds only canonical immutable mapping between
M6 composition nodes and pipeline stages; no execution, dispatch, transition,
or mutation is present and no commit/push is authorized before acceptance.
Product Owner accepted and closed M7.1 Runtime Composition Coordinator
Foundation on 2026-07-22. Evidence: 2 mappings, focused 7/7, app 483/483,
Knowledge 75/75, protected freeze 14/14, Architecture 133/0. M7.2 Runtime
Dispatcher Foundation is Ready to Start and may consume only the coordination
contract to produce a deterministic dispatch projection.
M7.2 Runtime Dispatcher Foundation is engineering complete and pending Product
Owner review. It produces only canonical dispatch entries from the M7.1
coordination contract; no execution, scheduling, queue, or mutation is present
and no commit/push is authorized before acceptance.
Product Owner accepted and closed M7 Foundation Freeze on 2026-07-22. M7 is
officially Frozen with 6 contracts, 18 public symbols, 5 dependency edges, 0
cycles, focused freeze 2/2, app 518/518, Knowledge 75/75, and Architecture
133/0. M8.0 Product Runtime Services & Delivery Architecture Planning is Ready
to Start and remains planning-only.
Product Owner accepted and closed M7.2 Runtime Dispatcher Foundation on
2026-07-22. Evidence: 2 dispatch entries, focused 7/7, app 490/490, Knowledge
75/75, protected freeze 14/14, Architecture 133/0. M7.3 Runtime Activation
Projection Foundation is Ready to Start and may consume only RuntimeDispatchContract.
M7.3 Runtime Activation Projection Foundation is engineering complete and
pending Product Owner review. It produces only immutable activation identity,
position, and provenance from M7.2 dispatch; no activation or runtime mutation
is present and no commit/push is authorized before acceptance.
Product Owner accepted and closed M7.3 Runtime Activation Projection
Foundation on 2026-07-22. Evidence: 2 activation entries, focused 7/7, app
497/497, Knowledge 75/75, protected freeze 14/14, Architecture 133/0. M7.4
Runtime Lifecycle Projection Foundation is Ready to Start and may consume only
RuntimeActivationProjectionContract.
M7.4 Runtime Lifecycle Projection Foundation is engineering complete and
pending Product Owner review. It projects only canonical lifecycle phases from
activation provenance; no lifecycle control or state transition is present and
no commit/push is authorized before acceptance.
M8.0 Product Runtime Services & Delivery Architecture Planning is engineering
complete and pending Product Owner review. The package defines 8 capabilities,
9 dependency edges, 0 cycles, ownership/mutation boundaries, M3-M7 reuse,
sequencing, and ADR-007. No production implementation is authorized before
Product Owner acceptance.
Product Owner accepted and closed M11.5 Product Feature Assembly Foundation on
2026-07-22. M11.6 Runtime Observability Integration Foundation is authorized
next. It may consume only RuntimeHealthDiagnosticsProjectionContract and
ProductFeatureAssemblyPlan and may implement deterministic structural
observability planning, immutable integration plan/entries, canonical ordering,
provenance validation, deterministic integration logs, and replay-safe digest.
Each assembled feature binds only to the complete runtime-health projection
digest; no feature-to-runtime-service observability mapping may be inferred. It
must reject stale inputs, orphan features, duplicate entries/positions, broken
provenance, and incomplete feature coverage. It must not collect telemetry,
metrics, traces or logs; poll/monitor/inspect runtime; schedule work; use event
bus, persistence, networking, Provider, UI, AI, or runtime mutation.
M11.6 Runtime Observability Integration Foundation is engineering complete and
pending Product Owner review. The stateless
`RuntimeObservabilityIntegrationPlanner` imports only
RuntimeHealthDiagnosticsProjectionContract and ProductFeatureAssemblyPlan. It
produces immutable integration entries/plans, canonical feature ordering,
whole-projection health provenance, deterministic structural logs, and
replay-safe digests. No entry contains serviceId or runtimeNodeId, so no
feature-to-service observability ownership is inferred. Stale provenance,
incomplete coverage, orphan/duplicate features, duplicate positions, and
malformed logs fail closed. It performs no telemetry collection, metrics,
tracing, log emission, polling, monitoring, runtime inspection, scheduling,
event bus, persistence, networking, Provider, UI, AI, or runtime mutation.
Evidence: focused 8/8, analyzer clean, app 722/722, Knowledge 75/75, protected
M3-M10 freeze 30/30, Architecture 133/0, and git diff --check clean. No
commit/push before Product Owner acceptance.
Product Owner accepted and closed M11.6 Runtime Observability Integration
Foundation on 2026-07-22. M11.7 Production Startup Validation Foundation is
authorized next. It may consume only ApplicationBootstrapHostRun and
RuntimeActivationDeliveryGateContract and may implement deterministic
structural startup-validation planning, immutable validation plan/entries,
canonical ordering, provenance validation, deterministic logs, and a
replay-safe digest. Entries are expected to bind bootstrap-host-run and gate
entry identities/digests by canonical position. It must reject stale inputs,
orphans, duplicates, inconsistent identity binding, broken provenance, and
incomplete coverage. It must not start the application, activate runtime,
execute lifecycle, construct services, schedule/async work, load configuration,
execute DI, persist, network, use Provider/UI/AI, or mutate runtime state.
Product Owner accepted and closed M8.0 Product Runtime Services & Delivery
Architecture Planning on 2026-07-22. Evidence: 8 capabilities, 9 edges, 0
cycles, protected M3-M7 freeze 16/16, Architecture 133/0. M8.1 Runtime Service
Composition Foundation is Ready to Start and may consume only the M6 Runtime
Composition public contract.
M8.1 Runtime Service Composition Foundation is engineering complete and
pending Product Owner review. It adds immutable deterministic service
descriptors bound to M6 Runtime Composition identity, digest, canonical order,
and service type without DI, registration, instantiation, execution, or
persistence. Evidence: focused 7/7, analyzer clean, app 529/529, Knowledge
75/75, protected M3-M7 freeze 16/16, Architecture 133/0.
Product Owner accepted and closed M8.1 Runtime Service Composition Foundation
on 2026-07-22. The service descriptors remain composition-only metadata with
canonical service identity/type/position and provenance digest. M8.2 Runtime
Service Registry Foundation is Ready to Start.
M8.2 Runtime Service Registry Foundation is engineering complete and pending
Product Owner review. It consumes only the immutable M8.1 service composition
and produces canonical immutable registry entries bound to service identity,
composition digest, position, type, and provenance; no runtime lookup,
dependency resolution, activation, instantiation, DI, execution, persistence,
or mutation is present. Evidence: focused 7/7, analyzer clean, app 536/536,
Knowledge 75/75, protected M3-M7 freeze 16/16, Architecture 133/0.
Product Owner accepted and closed M8.2 Runtime Service Registry Foundation on
2026-07-22. M8.3 Runtime Dependency Resolution Foundation is Ready to Start and
may consume only the M8.2 registry projection.
M8.3 Runtime Dependency Resolution Foundation is engineering complete and
pending Product Owner review. Per the approved contract-gap decision, its pure
builder consumes only M8.2 RuntimeServiceRegistryContract plus public M6
RuntimeCompositionContract, joining service identity with authoritative runtime
topology without inferring, resolving, activating, executing, or mutating.
Evidence: focused 8/8, analyzer clean, app 544/544, Knowledge 75/75,
protected M3-M7 freeze 16/16, Architecture 133/0.
Product Owner accepted and closed M8.3 Runtime Dependency Resolution Foundation
on 2026-07-22. M8.4 Runtime Activation Coordinator Foundation is Ready to
Start and may consume only the M8.3 dependency projection.
M8.4 Runtime Activation Coordinator Foundation is engineering complete and
pending Product Owner review. It projects only canonical activation identities
and topological order from the immutable M8.3 dependency projection; it does
not activate, execute, schedule, retry, transition lifecycle, persist, or
mutate runtime state. Evidence: focused 7/7, analyzer clean, app 551/551,
Knowledge 75/75, protected M3-M7 freeze 16/16, Architecture 133/0.
Product Owner accepted and closed M8.4 Runtime Activation Coordinator Foundation
on 2026-07-22. M8.5 Runtime Service Exposure Foundation is Ready to Start and
may consume only the M8.4 activation coordination projection.
M8.5 Runtime Service Exposure Foundation is engineering complete and pending
Product Owner review. Per the approved contract-gap decision, it joins only
M8.4 activation coordination and M8.2 registry service types, applying the fixed
v1 scope mapping Core/Internal, Coordinator+Registry/Application,
Projection/AIConsumer, and Adapter/API without publishing or runtime exposure.
Evidence: focused 8/8, analyzer clean, app 559/559, Knowledge 75/75,
protected M3-M7 freeze 16/16, Architecture 133/0.
Product Owner accepted and closed M8.5 Runtime Service Exposure Foundation on
2026-07-22. M8.6 Runtime Delivery Projection Foundation is Ready to Start and
may consume only the M8.5 exposure projection.
M8.6 Runtime Delivery Projection Foundation is engineering complete and pending
Product Owner review. It consumes only M8.5 exposure metadata and applies the
fixed v1 mapping Internal/Runtime, Application/Application, API/API, and
AIConsumer/AI without deployment, packaging, transport, activation, execution,
or mutation. Evidence: focused 7/7, analyzer clean, app 566/566, Knowledge
75/75, protected M3-M7 freeze 16/16, Architecture 133/0.
Product Owner accepted and closed M8.6 Runtime Delivery Projection Foundation
on 2026-07-22. M8 Foundation Freeze & Architecture Validation is Ready to Start
and may create only manifest, proof, tests, and documentation without changing
M3-M8 contracts or protected/generated artifacts.
M8 Foundation Freeze & Architecture Validation is engineering complete and
pending Product Owner review. Freeze evidence: 6 contracts, 22 public symbols,
7 dependency edges, 0 cycles, normalized SHA-256 manifest pass, public symbol
uniqueness pass, version/canonical/replay/hidden-state proofs pass, protected
M3-M7 baseline unchanged.
Product Owner accepted and closed M8 Foundation Freeze & Architecture
Validation on 2026-07-22. M9.0 Product Features & User Experience Architecture
Planning is Authorized to Start; it is planning-only and must preserve frozen
M3-M8 contracts and add no production behavior.
M9.0 Product Features & User Experience Architecture Planning is engineering
complete and pending Product Owner review. Planning defines 8 capabilities, 15
dependency edges, 0 cycles, product ownership/mutation boundaries, M3-M8 reuse,
implementation sequence, and proposed ADR-008 without production code.
Product Owner accepted and closed M9.0 Product Features & User Experience
Architecture Planning on 2026-07-22. M9.1 Product Shell & Navigation Foundation
is Authorized to Start.
M9.1 Product Shell & Navigation Foundation is accepted and closed on 2026-07-22.
Per the approved contract-gap decision, the pure product
shell builder consumes only public M8 RuntimeServiceExposureContract,
RuntimeDeliveryProjectionContract, and immutable ProductNavigationPolicy v1.
The policy fixes feature category, canonical position, visibility, and parent
topology; it is content-addressed and is not runtime business state. The shell
contract binds exposure, delivery, and policy digests and fails closed for
stale, mixed, duplicate, orphan, cyclic, or missing-edge inputs. Evidence:
focused 8/8, app 578/578, Knowledge 75/75, protected M3-M8 freeze 20/20,
Architecture 133/0, git diff --check clean.
Product Owner accepted and closed M9.1 Product Shell & Navigation Foundation
on 2026-07-22. M9.2 Player Profile & Progress Foundation is Authorized to
Start. M9.2 may consume only public M3 PlayerProgressContract and M9.1
ProductShellContract to produce an immutable profile/progress projection; it
must not calculate mastery/statistics, mutate player or runtime state, persist,
or call AI.
M9.2 Player Profile & Progress Foundation was accepted and closed by the
Product Owner on 2026-07-22. The pure projector consumes only the public M3
PlayerProgressSnapshot progress contract and M9.1 ProductShellContract. It
produces canonical immutable entries binding player ID, feature ID, position,
progress digest, and shell digest without copying business state or calculating
mastery/statistics. Evidence: focused 8/8, analyzer clean, app 586/586,
Knowledge 75/75, protected M3-M8 freeze 20/20, Architecture 133/0, git diff
check clean. M9.3 Training Session Workspace Foundation is Authorized to Start
and may consume only M9.2 PlayerProfileProjectionContract plus the public M3
CoachPlanningGraphContract (the approved TrainingPlanProjection alias) to
produce an immutable workspace projection.
M9.3 Training Session Workspace Foundation is engineering complete and pending
Product Owner review. The workspace projector consumes only
PlayerProfileProjectionContract and CoachPlanningGraphContract; it does not
consume TrainingSessionContract, Recommendation, Execution, Runtime, AI, or
persistence. Evidence: focused 8/8, analyzer clean, app 594/594, Knowledge
75/75, protected M3-M8 freeze 20/20, Architecture 133/0, git diff --check
clean. Product Owner accepted and closed M9.3 on 2026-07-22. M9.4 Coach
Context & Decision View Foundation is Authorized to Start and may consume only
M9.3 TrainingSessionWorkspaceContract and public M3 CoachContextContract.
M9.4 Coach Context & Decision View Foundation was accepted and closed by the
Product Owner on 2026-07-22. It produces only immutable decision-view
references bound to workspace digest, Coach Context digest, player ID, and
canonical planning-node position; no decision, recommendation, runtime, AI,
or persistence behavior is present. Evidence: focused 7/7, analyzer clean,
app 601/601, Knowledge 75/75, protected M3-M8 freeze 20/20, Architecture
133/0, git diff --check clean. M9.5 Plan & Recommendation Inbox Foundation
is Authorized to Start and may consume only CoachDecisionViewContract plus
public M3 OrderedRecommendationViewContract.
M9.5 Plan & Recommendation Inbox Foundation was accepted and closed by the
Product Owner on 2026-07-22. It consumes only M9.4 CoachDecisionViewContract
and public M3 OrderedRecommendationViewContract to produce immutable inbox
references; it does not create, rerank, score, mutate, execute, or persist
recommendations. Evidence: focused 5/5, analyzer clean, app 606/606,
Knowledge 75/75, protected M3-M8 freeze 20/20, Architecture 133/0,
git diff --check clean. M9.6 Execution & Outcome Tracking Foundation is
Authorized to Start and may consume only RecommendationInboxContract plus the
public immutable M3 execution-result projection contract or its officially
mapped equivalent.
M9.6 Execution & Outcome Tracking Foundation was accepted and closed by the
Product Owner on 2026-07-22. The repository's public immutable
ExecutionResultView equivalent is TrainingOutcomeProjectionContract v1, so the
pure Product projector consumes only that contract plus M9.5
RecommendationInboxContract. It produces references to execution status and
outcome records without executing, evaluating, scoring, mutating, persisting,
or analyzing them. Evidence: focused 5/5, analyzer clean, app 611/611,
Knowledge 75/75, protected M3-M8 freeze 20/20, Architecture 133/0,
git diff --check clean. M9.7 AI Coach Interaction Surface Foundation is
Authorized to Start and may consume only ExecutionOutcomeProjectionContract
plus public M5 AIConversationMemoryContract.
M9.7 AI Coach Interaction Surface Foundation was accepted and closed by the
Product Owner on 2026-07-22. Per Product Owner clarification, canonical
position is the only authorized join between M9.6 execution outcomes and the
player-neutral M5 AIConversationMemoryContract; coverage must be equal,
contiguous, duplicate-free, and gapless. Foreign-player and semantic
execution-to-conversation ownership validation are structurally unavailable
and are not inferred. Evidence: focused 5/5, analyzer clean, app 616/616,
Knowledge 75/75, protected M3-M8 freeze 20/20, Architecture 133/0,
git diff --check clean. M9.8 Product Analytics & Feedback Loop Foundation is
Authorized to Start and may consume only PlayerProfileProjectionContract,
RecommendationInboxContract, ExecutionOutcomeProjectionContract, and
AICoachInteractionSurfaceContract to produce reference-only aggregate
identity without KPI, scoring, trend, feedback, AI, persistence, or UI.
M9.8 was accepted and closed by the Product Owner on 2026-07-22.
`ProductAnalyticsProjectionContract` v1 is an immutable deterministic
reference projection over exactly those four approved public inputs. It binds
player/capability identity, canonical position, semantic IDs, and all source
digests; stale or foreign identity, broken provenance, incomplete coverage,
gaps, and duplicates fail closed. It performs no KPI calculation, scoring,
trend detection, recommendation, feedback generation, AI, persistence, or UI.
Evidence: focused 5/5, analyzer clean, app 621/621, Knowledge 75/75, protected
M3-M8 freeze 20/20, Architecture 133/0, git diff --check clean.
The Product Owner authorized M9 Foundation Freeze & Architecture Validation
next. It may add only `architecture/milestones/M9_FOUNDATION_FREEZE.md`, the
`architecture/milestones/m9_freeze/` machine proof artifacts, and
`app/test/m9_foundation_freeze_test.dart`; it must not mutate frozen M9
contracts or add runtime/product behavior, UI, persistence, API, provider, AI,
scheduler, analytics computation, recommendation logic, or feature behavior.
M9 Foundation Freeze & Architecture Validation was accepted and closed by the
Product Owner on 2026-07-22. The freeze records 8 contracts, 28 unique public
type symbols, 10 internal dependency edges, 0 cycles, and contract-set digest
`267e80f664e80c3ea6956ff2d740bea447f3dea598ce84865d4b98582494d5f1`.
Evidence: focused freeze 5/5, analyzer clean, app 626/626, Knowledge 75/75,
protected M3-M8 freeze 20/20, Architecture 133/0, git diff --check clean.
M10.0 Production Runtime & Application Delivery Architecture Planning is
Authorized to Start as planning-only work. It must define M10.1-M10.8 through
the approved milestone, inventory, graph, layer, ownership, mutation, reuse,
sequence, and proposed ADR artifacts without production code, DI, startup,
activation, scheduler, persistence, HTTP/API, UI, provider integration,
deployment infrastructure, or runtime mutation.
M10.0 was accepted and closed by the Product Owner on 2026-07-22. Evidence:
planning graph valid with 8 nodes, 14 edges, 0 cycles; app 626/626; Knowledge
75/75; protected M3-M9 freeze 25/25; Architecture 133/0; git diff --check
clean. M10.1 Application Bootstrap Foundation is authorized next and may
consume only RuntimeCompositionContract, RuntimeValidationContract, and
RuntimeDeliveryProjectionContract to produce an immutable projection. No
startup, main(), Flutter initialization, DI, service locator, Provider,
Riverpod, Bloc, UI, persistence, configuration loading, HTTP, scheduler,
lifecycle execution, runtime mutation, async orchestration, resource creation,
or plugin initialization is allowed.
M10.1 Application Bootstrap Foundation was accepted and closed by the Product
Owner on 2026-07-22. `ApplicationBootstrapContract` v1 is a
pure immutable projection over exactly RuntimeCompositionContract,
RuntimeValidationContract, and RuntimeDeliveryProjectionContract. It binds
composition/validation/delivery IDs and digests, requires validation's
composition/delivery artifact references to match, rejects failed validation,
stale/foreign/orphan/duplicate/incomplete inputs, and does not introduce
startup, main(), Flutter, DI, Provider, UI, persistence, config loading, HTTP,
scheduler, lifecycle execution, async orchestration, resources, plugins, or
runtime mutation. Evidence: focused 6/6, analyzer clean, app 632/632,
Knowledge 75/75, protected M3-M9 freeze 25/25, Architecture 133/0,
git diff --check clean.
M10.2 Dependency Composition Root Foundation is authorized next and may
consume only ApplicationBootstrapContract and
RuntimeServiceCompositionContract. It must remain an immutable deterministic
reference projection and must not implement GetIt, a DI container, service
locator, Provider/Riverpod/Bloc registration, constructor injection, object or
singleton creation, lazy loading, resource lifetime, startup, Flutter,
activation, persistence, HTTP, provider integration, scheduler, configuration
loading, or runtime mutation.
M10.2 Dependency Composition Root Foundation was accepted and closed by the
Product Owner on 2026-07-22. The immutable deterministic
`DependencyCompositionRootContract` v1 consumes only
ApplicationBootstrapContract and RuntimeServiceCompositionContract, joins by
public serviceId, binds bootstrap/service/runtime-node references and digests,
and fails closed for stale, orphan, duplicate, broken, or incomplete coverage.
It implements no DI container, locator, registration, injection, object or
singleton creation, lazy loading, resource lifetime, startup, Flutter,
activation, persistence, HTTP, Provider, scheduler, configuration, or runtime
mutation. Evidence: focused 6/6, analyzer clean, app 638/638, Knowledge 75/75,
protected M3-M9 freeze 25/25, Architecture 133/0, git diff --check clean.
M10.3 Runtime Service Activation Projection Foundation is authorized next and
may consume only DependencyCompositionRootContract and
RuntimeActivationCoordinationContract. It must project immutable reference-only
activation ordering and must not activate services, execute lifecycle, inject
dependencies, construct objects/singletons, start the application, schedule or
run async work, use an event bus/retry/queue, initialize Flutter, persist, call
HTTP/API/providers, load configuration, or mutate runtime state.
M10.3 Runtime Service Activation Projection Foundation was accepted and closed
by the Product Owner on 2026-07-22. The immutable deterministic
`RuntimeServiceActivationProjectionContract` v1 consumes only
DependencyCompositionRootContract and RuntimeActivationCoordinationContract,
preserves M8 activation order, joins by public serviceId, and binds activation,
composition, runtime-node, projection, and source-digest references. Stale,
foreign, orphan, duplicate, broken, or incomplete coverage fails closed. It
performs no activation, lifecycle, DI, construction, startup, scheduling,
async/event/retry/queue work, Flutter, persistence, HTTP/API, Provider,
configuration, or runtime mutation. Evidence: focused 6/6, analyzer clean, app
644/644, Knowledge 75/75, protected M3-M9 freeze 25/25, Architecture 133/0,
git diff --check clean.
M10.4 Runtime Lifecycle Host Projection Foundation is authorized next and may
consume only RuntimeServiceActivationProjectionContract and
RuntimeLifecycleProjectionContract. It must remain a pure immutable hosting
relationship projection and must not execute lifecycle/transitions/activation,
host or instantiate services, schedule or run async/queue/retry/timer/event-bus
work, inject dependencies, start Flutter, persist, call HTTP/API/providers,
load configuration, or mutate runtime state.
M10.4 Runtime Lifecycle Host Projection Foundation was accepted and closed by
the Product Owner on 2026-07-22. The immutable deterministic
`RuntimeLifecycleHostProjectionContract` v1 consumes only
RuntimeServiceActivationProjectionContract and RuntimeLifecycleProjectionContract.
M7 lifecycle entries have no independent lifecycle ID and belong to a different
activation chain than M10.3, so runtimeNodeId is the only shared public join;
coverage must be equal and unique, and no cross-chain digest relation is
inferred. The projection creates its own lifecycle-entry reference and rejects
stale, foreign, orphan, duplicate, inconsistent, broken, or incomplete inputs.
It performs no lifecycle/activation/hosting, construction, scheduler,
async/queue/retry/timer/event-bus work, DI, Flutter, persistence, HTTP/API,
Provider, configuration, or runtime mutation. Evidence: focused 6/6, analyzer
clean, app 650/650, Knowledge 75/75, protected M3-M9 freeze 25/25,
Architecture 133/0, git diff --check clean.
M10.5 Runtime Health & Diagnostics Projection Foundation is authorized to
consume only RuntimeLifecycleHostProjectionContract and
RuntimeValidationContract. Before implementation, a public-contract gap must be
resolved: M6 RuntimeValidationContract exposes five runtime-level artifact
digests but no runtimeNodeId, serviceId, or position binding, so a per-host-entry
validationArtifactDigest cannot be joined without an explicit Product Owner
rule. No positional or key-name inference is authorized implicitly.
The Product Owner resolved both M10.5 contract gaps with two normative rules:
RuntimeValidationContract is one runtime-wide proof, so every health entry
binds validationArtifactDigest to the same RuntimeValidationContract.digest;
and M10.5 operates under Pair Authority, treating the lifecycle-host projection
and supplied validation as the complete authoritative pair without inferring
bootstrap/composition/activation ancestry.
M10.5 Runtime Health & Diagnostics Projection Foundation was accepted and
closed by the Product Owner on 2026-07-22. The immutable
deterministic `RuntimeHealthDiagnosticsProjectionContract` v1 projects only
host, node, service, aggregate-validation, status, position, and digest
references. It rejects stale internal bindings, malformed/orphan/duplicate/
inconsistent/incomplete output and performs no monitoring, telemetry, metrics,
tracing, logging, diagnostics, runtime inspection, scheduler, async/event/retry
work, persistence, HTTP/API, Provider, configuration, or mutation. Evidence:
focused 6/6, analyzer clean, app 656/656, Knowledge 75/75, protected M3-M9
freeze 25/25, Architecture 133/0, git diff --check clean.
M10.6 Runtime Configuration & Environment Projection Foundation is authorized
next and may consume only RuntimeHealthDiagnosticsProjectionContract and M8
RuntimeDeliveryProjectionContract. It must remain an immutable deterministic
reference-only projection and must not load configuration, read environment
variables or `.env`, handle secrets, implement runtime configuration or feature
flags/providers/DI, start Flutter, persist, call HTTP/API, schedule, mutate
runtime state, or add production behavior.
M10.6 Runtime Configuration & Environment Projection Foundation was accepted
and closed by the Product Owner on 2026-07-22. The immutable
deterministic `RuntimeConfigurationEnvironmentProjectionContract` v1 consumes
only RuntimeHealthDiagnosticsProjectionContract and M8
RuntimeDeliveryProjectionContract, joins exact public runtimeNodeId/serviceId
coverage, and projects ownership identities, delivery target/references, source
digests, and reference-only configuration provenance. It contains no config
values, env reads, `.env`, secrets, flags, providers, DI, Flutter, persistence,
HTTP/API, scheduler, runtime mutation, or production behavior. Evidence:
focused 6/6, analyzer clean, app 662/662, Knowledge 75/75, protected M3-M9
freeze 25/25, Architecture 133/0, git diff --check clean.
M10.7 Production Readiness Validation Foundation is authorized next and may
consume only RuntimeConfigurationEnvironmentProjectionContract and
RuntimeValidationContract. It must remain a pure immutable structural-readiness
proof with no deployment/startup/bootstrap/activation/lifecycle execution,
operating-system checks, configuration loading, HTTP/API, persistence,
filesystem/environment reads, scheduler/async, telemetry/monitoring/polling,
Provider/DI, AI, deployment state, or runtime mutation.
The Product Owner then approved Pair Authority for M10.7: the configuration
projection and supplied RuntimeValidationContract are the complete inputs;
readiness binds the supplied aggregate validation digest directly and does not
reconstruct M10.5/M10.1 or earlier ancestry.
M10.7 Production Readiness Validation Foundation was accepted and closed by
the Product Owner on 2026-07-22. `ProductionReadinessProjectionContract`
v1 is immutable, deterministic, reference-only, and projects ready/blocked from
the supplied validation summary. It rejects stale internal bindings,
orphan/duplicate/malformed/incomplete output and performs no deployment,
startup, OS checks, monitoring, diagnostics, activation, config loading,
scheduler, DI, persistence, networking, Provider, UI, AI, or runtime mutation.
Evidence: focused 6/6, analyzer clean, app 674/674, Knowledge 75/75, protected
M3-M9 freeze 25/25, Architecture 133/0, git diff --check clean.
M10.8 Runtime Activation & Delivery Gate Foundation is authorized next and may
consume only ProductionReadinessProjectionContract and M8
RuntimeDeliveryProjectionContract. It must remain a declarative immutable gate
projection joined by public runtimeNodeId/serviceId and must not activate,
deploy, execute runtime, start up, schedule, execute lifecycle, load config,
use DI/Provider/network/persistence/UI/AI, or mutate runtime state.
M10.8 Runtime Activation & Delivery Gate Foundation was accepted and closed by
the Product Owner on 2026-07-22. The immutable
`RuntimeActivationDeliveryGateContract` v1 joins readiness and delivery only by
the exact public runtimeNodeId/serviceId pair, uses delivery order as canonical
order, and projects ready/blocked into declarative eligible/blocked gate status.
It fails closed for stale bindings, orphan coverage, inconsistent identity,
duplicates, broken provenance, malformed status, and incomplete projection. It
contains no activation, deployment, runtime execution, startup, scheduler,
lifecycle execution, configuration loading, DI, Provider, network,
persistence, UI, AI, fallback, ownership inference, or runtime mutation.
Evidence: focused 6/6, analyzer clean, app 674/674, Knowledge 75/75, protected
M3-M9 freeze 25/25, Architecture 133/0, git diff --check clean. M10 Foundation
Freeze & Architecture Validation is authorized next.
M10 Foundation Freeze & Architecture Validation was accepted and closed by the
Product Owner on 2026-07-22. It freezes the accepted M10.1-M10.8 public
contracts in `m10_freeze/contract_manifest.json` and `proof_record.json`, with
8 contracts, 27 public symbols, 7 dependency edges, zero cycles, and contract
set digest `913e682a8a8e9247260872ba32fbb94a91763221ec23d403f97ff3fed7bc4295`.
The machine proof verifies normalized SHA-256 hashes, canonical JSON, replay,
version bindings, hidden mutable/runtime mechanism absence, and unchanged
protected M3-M9 freeze artifacts. Evidence: focused freeze 5/5, analyzer clean,
app 679/679, Knowledge 75/75, protected M3-M9 25/25, Architecture 133/0, and
git diff --check clean.
M11.0 Production Application Implementation Planning is authorized next as
planning-only work. It must produce the approved milestone, capability/layer/
runtime/ownership/mutation/reuse/sequence maps, an eight-node acyclic capability
graph, and proposed ADR-010. It must preserve frozen M3-M10 contracts and must
not implement production startup, DI containers, service instantiation,
Provider/Riverpod/Bloc wiring, runtime activation/lifecycle execution, UI,
persistence, networking, scheduler, AI behavior, or runtime mutation.
Product Owner accepted and closed M7.5 Runtime Integration Projection
Foundation on 2026-07-22. Evidence: 2 integration entries, focused 7/7, app
511/511, Knowledge 75/75, protected freeze 14/14, Architecture 133/0. M7.6
Runtime Exposure Projection Foundation is Ready to Start and may consume only
RuntimeIntegrationProjectionContract.
Product Owner accepted and closed M7.6 Runtime Exposure Projection Foundation
on 2026-07-22. Evidence: 2 exposure entries, focused 7/7, app 518/518,
Knowledge 75/75, protected freeze 14/14, Architecture 133/0. M7 Foundation
Freeze & Architecture Validation is Ready to Start.
M7 Foundation Freeze & Architecture Validation is engineering complete and
pending Product Owner review. Inventory: 6 contracts, 18 public symbols, 5
dependency edges, 0 cycles; focused freeze 2/2. Last full regression is app
518/518, Knowledge 75/75, Architecture 133/0. No commit/push before review.
M7.6 Runtime Exposure Projection Foundation is engineering complete and
pending Product Owner review. It projects only exposure scope metadata from
integration provenance; no endpoint, publish, adapter registration, or runtime
export is present and no commit/push is authorized before acceptance.
Product Owner accepted and closed M7.4 Runtime Lifecycle Projection Foundation
on 2026-07-22. Evidence: 2 lifecycle entries, focused 7/7, app 504/504,
Knowledge 75/75, protected freeze 14/14, Architecture 133/0. M7.5 Runtime
Integration Projection Foundation is Ready to Start and may consume only the
M7.4 lifecycle projection.
M7.5 Runtime Integration Projection Foundation is engineering complete and
pending Product Owner review. It projects only immutable integration metadata
from lifecycle provenance; no adapter call or runtime integration is present
and no commit/push is authorized before acceptance.
M11.0 Production Application Implementation Planning was accepted and closed by
the Product Owner on 2026-07-22. Planning-only artifacts define M11.1-M11.8,
with an eight-node, twelve-edge, zero-cycle capability graph; application and
runtime integration layers; ownership and mutation boundaries; frozen-contract
reuse; implementation sequence; and proposed ADR-010. M3-M10 remain frozen,
Runtime Core remains deterministic truth, Composition Root owns wiring/lifetime
only, Product consumes public application services, AI remains observational,
and infrastructure/UI remain adapters. No startup, DI container, service
instantiation, Provider/Riverpod/Bloc wiring, activation, lifecycle execution,
UI behavior, persistence, network, scheduler, AI behavior, or runtime mutation
was implemented. Evidence: graph/JSON/dependency validation passed (8 nodes,
12 edges, 0 cycles), app 679/679, Knowledge 75/75, protected M3-M10 freeze
30/30, Architecture 133/0, and git diff --check clean.
M11.1 Application Bootstrap Implementation Foundation is authorized next. It
may consume only ApplicationBootstrapContract and
DependencyCompositionRootContract and may implement an ApplicationBootstrapHost,
immutable bootstrap configuration, ordered deterministic startup orchestration,
composition-root invocation, and structural startup lifecycle logging. It must
not activate Runtime/services, execute Runtime lifecycle, add business/Product/
Coach/AI behavior, scheduler/workers, HTTP, database/persistence,
Provider/Riverpod/Bloc, widget/navigation/UI, or mutation outside approved
bootstrap state.
M11.1 Application Bootstrap Implementation Foundation was accepted and closed
by the Product Owner on 2026-07-22. The stateless
`ApplicationBootstrapHost` imports only ApplicationBootstrapContract and
DependencyCompositionRootContract, creates immutable provenance-bound
configuration/bindings, and emits a deterministic structural lifecycle in the
fixed order validateBootstrap, invokeCompositionRoot, bindBootstrapEntries,
completed. Mixed roots, stale or incomplete binding, dependency-order drift,
duplicates, and malformed lifecycle provenance fail closed. The host retains no
mutable state and performs no Runtime/service activation, lifecycle execution,
business/Product/Coach/AI behavior, scheduler/workers, HTTP, database,
persistence, Provider/Riverpod/Bloc, widget/navigation/UI, or external runtime
mutation. Evidence: focused 6/6, analyzer clean, app 685/685, Knowledge 75/75,
protected M3-M10 freeze 30/30, Architecture 133/0, git diff --check clean.
M11.2 Dependency Injection Composition Foundation is authorized next. It may
consume only DependencyCompositionRootContract and
RuntimeServiceActivationProjectionContract and may implement deterministic
registration planning, dependency ordering, composition validation, immutable
registration descriptors, canonical ordering, replay-safe digest, and
structural logging. It must not implement GetIt/service locator/DI container,
singleton or lazy construction, object creation, runtime activation/lifecycle,
business/Product/Coach/AI logic, persistence, HTTP, Provider/Riverpod/Bloc,
scheduler, Flutter widgets, or runtime mutation.
M11.2 Dependency Injection Composition Foundation is engineering complete and
pending Product Owner review. The stateless `DependencyCompositionEngine`
imports only DependencyCompositionRootContract and
RuntimeServiceActivationProjectionContract. It produces immutable registration
descriptors, canonical activation-position ordering, exact provenance binding,
a replay-safe registration-plan digest, and deterministic structural logs.
Mixed/stale inputs, incomplete or orphan bindings, order drift, duplicate
semantic identities, and malformed logs fail closed. It creates no service
objects and contains no DI container/service locator, singleton/lazy behavior,
runtime activation/lifecycle execution, business/Product/Coach/AI behavior,
persistence, HTTP, Provider/Riverpod/Bloc, scheduler, Flutter widgets, or
runtime mutation. Evidence: focused 7/7, analyzer clean, app 692/692, Knowledge
75/75, protected M3-M10 freeze 30/30, Architecture 133/0, and git diff --check
clean. No commit/push before Product Owner acceptance.
Before M11.7 implementation, a structural cardinality/identity gap was
surfaced: ApplicationBootstrapHostRun has four lifecycle phases without entry
IDs, while RuntimeActivationDeliveryGateContract is runtime-service scoped and
has N entries. The Product Owner withdrew per-service pairing and approved an
aggregate certification refinement. M11.7 entries represent bootstrap phases
and bind lifecycle phase/event/position/digest, complete host-run digest,
complete gate digest, and aggregate gate eligibility. Eligibility is true iff
all gate entries are eligible. No serviceId, runtimeNodeId, gateEntryId, or
deliveryTarget is allowed.
M11.7 Production Startup Validation Foundation is engineering complete and
pending Product Owner review. The stateless
`ProductionStartupValidationPlanner` imports only ApplicationBootstrapHostRun
and RuntimeActivationDeliveryGateContract. It rejects stale inputs, duplicate
phases/positions, malformed lifecycle order/event codes, broken provenance, and
incomplete four-phase coverage. It performs no startup execution, runtime or
service activation, lifecycle execution, service construction, scheduler,
async execution, configuration loading, DI execution, persistence, networking,
Provider, UI, AI, or runtime mutation. Evidence: focused 8/8, analyzer clean,
app 730/730, Knowledge 75/75, protected M3-M10 freeze 30/30, Architecture
133/0, and git diff --check clean. No commit/push before Product Owner
acceptance.
M11.8 End-to-End Application Composition Foundation is engineering complete
and pending Product Owner review. The stateless
`EndToEndApplicationCompositionPlanner` imports only
ProductionStartupValidationPlan and RuntimeObservabilityIntegrationPlan. Each
immutable composition entry represents one assembled feature and binds its
observability integration identity/position to complete startup-validation and
observability-integration digests. The plan is canonical, replay-safe, and
fail-closed for stale provenance, duplicate feature/integration identity,
duplicate positions, orphan features, incomplete coverage, and malformed logs.
No feature-to-runtime-service mapping or application/Flutter execution, widget
tree/routing creation, runtime activation, service instantiation, lifecycle
execution, Provider/Riverpod/Bloc wiring, persistence, networking, AI,
telemetry execution, or runtime mutation is present. Evidence: focused 8/8,
analyzer clean, app 738/738, Knowledge 75/75, protected M3-M10 freeze 30/30,
Architecture 133/0, and git diff --check clean. No commit/push before Product
Owner acceptance.
Product Owner accepted and closed M11.8 End-to-End Application Composition
Foundation on 2026-07-22 and declared M11.1-M11.8 architecturally complete.
M11 Foundation Freeze & Architecture Validation is authorized next. It must
produce M11_FOUNDATION_FREEZE.md, m11_freeze/contract_manifest.json,
m11_freeze/proof_record.json, and m11_foundation_freeze_test.dart. The proof
must freeze all eight accepted M11 foundation files with normalized hashes,
public symbols, dependency graph/cycle validation, deterministic replay,
hidden mutable/runtime mechanism scan, and protected M3-M10 verification. No
frozen M3-M11 implementation may be modified and no runtime/startup/activation/
lifecycle/DI/Provider/UI/persistence/network/AI/telemetry/deployment behavior or
runtime mutation may be introduced.
M11 Foundation Freeze & Architecture Validation is engineering complete and
pending Product Owner review. The freeze manifest locks 8 accepted M11
application foundation files, 42 unique public symbols, 6 dependency edges, 0
cycles, and contract-set digest
`0f62c5453e4b90ad878dbaef0ae478f3105b1abbe66f85164c81a1700b82ca2d`.
Machine proof covers normalized hashes, version markers, symbol uniqueness,
dependency graph/cycle validation, canonical JSON/replay, hidden mutable/runtime
mechanism scan, and protected M3-M10 artifact hashes. No frozen M11 source was
modified. Evidence: focused freeze 5/5, analyzer clean, app 743/743, Knowledge
75/75, protected M3-M10 30/30, Architecture 133/0, and git diff --check clean.
No commit/push before Product Owner acceptance.
Product Owner accepted and closed M11 Foundation Freeze on 2026-07-22 and
declared M11 closed. The accepted freeze contains 8 sources, 42 public symbols,
6 dependency edges, 0 cycles, and contract-set digest
`0f62c5453e4b90ad878dbaef0ae478f3105b1abbe66f85164c81a1700b82ca2d`.
Evidence remains focused freeze 5/5, analyzer clean, app 743/743, Knowledge
75/75, protected M3-M10 30/30, Architecture 133/0, and git diff --check clean.
M12.0 Infrastructure & Adapter Implementation Planning is the next roadmap
phase. It is planning-only and must preserve frozen M3-M11 contracts and
ownership boundaries while covering Flutter shell integration, DI framework/
adapter planning, configuration/environment, persistence, networking/API, AI
provider, observability adapters, and deployment/packaging strategy. No
production adapter behavior is authorized until M12.0 executable deliverables
and Definition of Done are explicitly locked by the Product Owner.
Product Owner accepted and closed M11.7 Production Startup Validation
Foundation on 2026-07-22. M11.8 End-to-End Application Composition Foundation
is authorized next. It may consume only ProductionStartupValidationPlan and
RuntimeObservabilityIntegrationPlan and may implement deterministic structural
composition planning, immutable composition plan/entries, canonical feature
ordering, deterministic provenance/logs, and replay-safe digest. Each entry
represents an assembled product feature and binds complete startup-validation
and observability-integration digests; no feature-to-runtime-service mapping may
be inferred. It must reject stale inputs, duplicate feature identities or
positions, orphan features, incomplete coverage, and broken provenance. It must
not execute the application/Flutter, create widgets/routes, activate runtime,
instantiate services, execute lifecycle, wire Provider/Riverpod/Bloc, persist,
network, execute AI/telemetry, or mutate runtime state.
Product Owner accepted and closed M11.4 Application Service Wiring Foundation
on 2026-07-22. M11.5 Product Feature Assembly Foundation is authorized next.
It may consume only ApplicationServiceWiringPlan and
ProductAnalyticsProjectionContract and may implement a deterministic
ProductFeatureAssemblyPlanner, immutable assembly plan/entries, canonical
feature ordering, provenance validation, deterministic assembly logs, and a
replay-safe assembly digest. It must reject stale wiring/analytics inputs,
orphan feature/service references, duplicate entries or positions,
inconsistent feature/service bindings, broken provenance, and incomplete
coverage. It must not instantiate features, construct UI/widget trees or
navigation, use Provider/Riverpod/Bloc, activate runtime, perform dependency
injection, add business/Coach logic or AI execution, persist, network, or mutate
runtime state.
Before M11.5 implementation, a contract gap was surfaced: the originally
authorized ProductAnalyticsProjectionContract owns analytics records, not
feature inventory or feature-to-service mapping. The Product Owner approved a
scope adjustment: M11.5 consumes only ApplicationServiceWiringPlan and frozen
ProductShellContract. Each feature binds to the complete wiring-plan digest;
no individual feature/service assignment may be inferred and no `serviceId`
may appear in an assembly entry.
M11.5 Product Feature Assembly Foundation is engineering complete and pending
Product Owner review. The stateless `ProductFeatureAssemblyPlanner` imports only
ApplicationServiceWiringPlan and ProductShellContract. It produces immutable
feature assembly entries/plans, canonical Product Shell ordering, exact shell
identity/topology and whole-plan wiring provenance, deterministic structural
logs, and replay-safe digests. It rejects stale provenance, incomplete shell
coverage, orphan/duplicate feature identity, duplicate positions, invalid
topology binding, and malformed logs. It performs no feature instantiation,
service selection/assignment, UI/widget/navigation, Provider/Riverpod/Bloc,
runtime activation, dependency injection, business/Coach behavior, AI
execution, persistence, networking, or runtime mutation. Evidence: focused
8/8, analyzer clean, app 714/714, Knowledge 75/75, protected M3-M10 freeze
30/30, Architecture 133/0, and git diff --check clean. No commit/push before
Product Owner acceptance.
Product Owner accepted and closed M11.2 Dependency Injection Composition
Foundation on 2026-07-22. M11.3 Runtime Host Initialization Foundation is
authorized next. It may consume only RuntimeServiceActivationProjectionContract
and RuntimeLifecycleHostProjectionContract and may implement a deterministic
RuntimeHostInitializer, immutable initialization plan/entries, canonical
initialization ordering, lifecycle-host validation, structural host
orchestration, deterministic logs, and a replay-safe digest. It must reject
stale projections, orphan nodes, duplicate entries/positions, inconsistent
service/node bindings, broken provenance, and incomplete coverage. It must not
create a runtime host, activate services, execute lifecycle behavior, use
schedulers/timers/event buses/async execution/DI, start Flutter, load
configuration, persist or network, use Provider/Riverpod/Bloc, add
Product/Coach/AI logic, or mutate runtime state.
M11.3 Runtime Host Initialization Foundation is engineering complete and
pending Product Owner review. The stateless `RuntimeHostInitializer` imports
only RuntimeServiceActivationProjectionContract and
RuntimeLifecycleHostProjectionContract. It produces immutable initialization
entries/plans, canonical activation-position ordering, exact service/node/
lifecycle binding, deterministic structural logs, and replay-safe digests. It
rejects stale or foreign projections, orphan nodes, duplicate entries or
positions, inconsistent bindings, broken provenance, incomplete coverage, and
malformed logs. It performs no runtime host creation, service activation,
lifecycle execution, scheduler/timer/event-bus/async behavior, dependency
injection, Flutter startup, configuration loading, persistence, networking,
Provider/Riverpod/Bloc, Product/Coach/AI behavior, or runtime mutation.
Evidence: focused 7/7, analyzer clean, app 699/699, Knowledge 75/75, protected
M3-M10 freeze 30/30, Architecture 133/0, and git diff --check clean. No
commit/push before Product Owner acceptance.
Product Owner accepted and closed M11.3 Runtime Host Initialization Foundation
on 2026-07-22. M11.4 Application Service Wiring Foundation is authorized next.
It may consume only RuntimeHostInitializationPlan and
RuntimeServiceCompositionContract and may implement a deterministic
ApplicationServiceWiringPlanner, immutable wiring plan/entries, canonical
wiring ordering, provenance validation, deterministic wiring logs, and a
replay-safe wiring digest. It must reject stale initialization plans or service
composition, orphan services/nodes, duplicate wiring entries or positions,
inconsistent service/runtime bindings, broken provenance, and incomplete
coverage. It must not construct services, perform dependency injection, create
objects, activate runtime, execute lifecycle, start Flutter, schedule work, use
Provider/Riverpod/Bloc, persist, network, add Product/Coach/AI behavior, or
mutate runtime state.
M11.4 Application Service Wiring Foundation is engineering complete and
pending Product Owner review. The stateless
`ApplicationServiceWiringPlanner` imports only RuntimeHostInitializationPlan
and RuntimeServiceCompositionContract. It produces immutable wiring entries/
plans, canonical position ordering, exact initialization/service/node binding,
deterministic structural logs, and replay-safe digests. It rejects stale or
foreign inputs, orphan services/nodes, duplicate entries or positions,
inconsistent bindings, broken provenance, incomplete coverage, and malformed
logs. It performs no service construction, dependency injection, object
creation, runtime activation, lifecycle execution, Flutter startup, scheduler,
Provider/Riverpod/Bloc, persistence, networking, Product/Coach/AI behavior, or
runtime mutation. Evidence: focused 7/7, analyzer clean, app 706/706, Knowledge
75/75, protected M3-M10 freeze 30/30, Architecture 133/0, and git diff --check
clean. No commit/push before Product Owner acceptance.
M12.0 Infrastructure & Adapter Implementation Planning is engineering complete
and pending Product Owner review. The planning package defines M12.1 Flutter,
M12.2 Configuration, M12.3 Persistence, M12.4 Transport, M12.5 AI Provider,
M12.6 Observability, M12.7 Packaging & Deployment, and M12.8 Infrastructure
Integration Validation as outward adapters around frozen M3-M11 public
contracts. Configuration is the first dependency; integration validation is
last. The graph contains 8 nodes, 12 edges, and 0 cycles. Ownership and mutation
boundaries explicitly prevent adapters from becoming business truth, bypassing
Runtime Core/Product projections, owning Coach decisions or AI reasoning, or
importing domain internals. No production source or runtime effect was added.
Evidence: app 743/743, Knowledge 75/75, protected M3-M11 35/35, Architecture
133/0, JSON/cycle validation clean, and git diff --check clean. App analyzer has
0 errors and 0 warnings; its 62 info-level findings predate and are outside the
documentation-only M12.0 diff. No commit/push before Product Owner acceptance.
Product Owner accepted and closed M12.0 Infrastructure & Adapter Implementation
Planning on 2026-07-22. The accepted package contains 8 capabilities, 12
dependency edges, and 0 cycles, with unchanged ownership and explicit adapter
mutation boundaries. M12.1 Flutter Application Adapter Foundation is authorized
next. It may consume only EndToEndApplicationCompositionPlan and
ApplicationBootstrapHostRun. It may implement a deterministic
FlutterApplicationAdapterPlanner, immutable plan/entries, canonical feature
ordering, exact whole-plan/bootstrap provenance, a four-phase structural log,
and replay-safe digest. It must reject stale inputs, duplicate feature identity
or position, orphan composition references, incomplete feature coverage, broken
provenance, and malformed logs. It must not create or execute Flutter, main,
runApp, bindings, app widgets, routing/navigation/widget trees, BuildContext,
Provider/Riverpod/Bloc, GetIt, plugins, services, runtime activation/lifecycle,
persistence, networking, AI, or runtime mutation.
M12.1 Flutter Application Adapter Foundation is engineering complete and
pending Product Owner review. The stateless
`FlutterApplicationAdapterPlanner` imports only
EndToEndApplicationCompositionPlan and ApplicationBootstrapHostRun. Each
immutable feature entry binds adapter/feature/composition identity and canonical
position to the complete composition-plan and bootstrap-host-run digests plus a
deterministic provenance digest. The plan is canonical and replay-safe with the
fixed structural log validateInputs, orderFeatures, bindBootstrapHost,
completed. Stale entry binding, duplicate identity/position, orphan composition
reference, incomplete coverage, broken provenance, and malformed logs fail
closed. There is no Flutter/runtime object, main/runApp, binding, app widget,
routing/navigation/widget tree, BuildContext, Provider/Riverpod/Bloc, GetIt,
plugin initialization, service instantiation, activation/lifecycle execution,
persistence, networking, AI, or runtime mutation. Evidence: focused 10/10,
analyzer clean, app 753/753, Knowledge 75/75, protected M3-M11 35/35,
Architecture 133/0, and git diff --check clean. No commit/push before Product
Owner acceptance.
Product Owner accepted and closed M12.1 Flutter Application Adapter Foundation
on 2026-07-22. M12.2 Configuration Adapter Foundation is authorized next. It
may consume only RuntimeConfigurationEnvironmentProjectionContract and
FlutterApplicationAdapterPlan. It may implement a deterministic
ConfigurationAdapterPlanner, immutable plan/entries, canonical feature order,
exact whole-configuration-projection and Flutter-plan provenance, a four-phase
structural log, and replay-safe digest. Each entry represents one assembled
feature and binds configurationAdapterEntryId, featureId,
flutterAdapterEntryId, position, both complete input digests, and deterministic
provenance. It must reject stale inputs, duplicate feature identity/position,
orphan feature references, incomplete coverage, broken provenance, and
malformed logs. Output must contain no configuration/environment values,
secrets, feature flags, or provider state. It must not load .env, read
environment variables, parse configuration, manage secrets/flags, implement
runtime configuration or Provider, execute Flutter, persist, network, execute
AI, or mutate runtime state.
M12.2 Configuration Adapter Foundation is engineering complete and pending
Product Owner review. The stateless `ConfigurationAdapterPlanner` imports only
RuntimeConfigurationEnvironmentProjectionContract and
FlutterApplicationAdapterPlan. Each immutable feature entry binds
configuration-adapter/feature/Flutter-entry identity and canonical position to
the complete configuration-projection and Flutter-plan digests plus a
deterministic provenance digest. The plan is canonical and replay-safe with the
fixed structural log validateInputs, orderFeatures,
bindConfigurationProvenance, completed. Stale binding, duplicate identity or
position, orphan feature reference, incomplete coverage, broken provenance,
and malformed logs fail closed. Output contains no configuration/environment
values or IDs, secrets, feature flags, provider state, runtime node/service
identity, or delivery target. There is no .env loading, environment reading,
configuration parsing, secret/flag management, runtime configuration, Provider,
Flutter execution, persistence, networking, AI, or runtime mutation. Evidence:
focused 8/8, analyzer clean, app 761/761, Knowledge 75/75, protected M3-M11
35/35, Architecture 133/0, and git diff --check clean. No commit/push before
Product Owner acceptance.
Product Owner accepted and closed M12.2 Configuration Adapter Foundation on
2026-07-22. M12.3 Persistence Adapter Foundation is authorized next. It may
consume only ConfigurationAdapterPlan and RuntimeDeliveryProjectionContract.
It may implement a pure deterministic PersistenceAdapterPlanner, immutable
plan/entries, canonical Configuration Adapter feature order, complete input
digest bindings, deterministic provenance, the fixed log validateInputs,
orderFeatures, bindPersistenceProvenance, completed, and replay-safe digest. It
must reject stale bindings, duplicate identities/positions, orphan features,
incomplete coverage, malformed logs, and broken provenance. It must not
implement SQLite, Hive, Isar, Drift, ObjectBox, SharedPreferences, filesystem,
serialization, migrations, repositories, DAOs, cache, encryption, transactions,
runtime persistence, async I/O, Provider, Flutter, networking, AI, or runtime
mutation.
M12.3 Persistence Adapter Foundation is engineering complete and pending Product
Owner review. The stateless `PersistenceAdapterPlanner` imports only
ConfigurationAdapterPlan and RuntimeDeliveryProjectionContract. Each immutable
feature entry binds persistence/configuration adapter identity and canonical
Configuration Adapter position to both complete input digests plus deterministic
provenance. No feature-to-delivery/service mapping is inferred. The plan is
canonical and replay-safe with validateInputs, orderFeatures,
bindPersistenceProvenance, completed. Stale bindings, duplicate identity or
position, orphan features, incomplete coverage, malformed logs, and broken
provenance fail closed. No persistence technology, filesystem, serialization,
migration, repository/DAO, cache, encryption, transaction, runtime persistence,
async I/O, Provider, Flutter, networking, AI, or runtime mutation exists.
Evidence: focused 8/8, analyzer clean, app 769/769, Knowledge 75/75, protected
M3-M11 35/35, Architecture 133/0, and git diff --check clean. No commit/push
before Product Owner acceptance.
Product Owner accepted and closed M12.3 Persistence Adapter Foundation on
2026-07-22. M12.4 Transport Adapter Foundation is authorized next. It may
consume only PersistenceAdapterPlan and RuntimeServiceExposureContract. It may
implement a pure deterministic TransportAdapterPlanner, immutable plan/entries,
canonical Persistence Adapter feature order, aggregate exposure digest binding,
deterministic provenance, fixed log validateInputs, orderFeatures,
bindTransportProvenance, completed, and replay-safe digest. No feature-to-
service or endpoint mapping may be inferred. It must reject stale bindings,
duplicate identities/positions, orphan features, incomplete coverage, broken
provenance, and malformed logs. It must not implement HTTP, REST, GraphQL,
WebSocket, gRPC, MQTT, sockets, serialization, request/response models, retry,
authentication, endpoints, networking, Flutter, Provider, persistence, AI, or
runtime mutation.
M12.4 Transport Adapter Foundation is engineering complete and pending Product
Owner review. The stateless `TransportAdapterPlanner` imports only
PersistenceAdapterPlan and RuntimeServiceExposureContract. Canonical feature
ownership/order comes only from the Persistence plan; exposure is bound only by
its complete aggregate digest, with no feature-to-service/endpoint inference.
Immutable entries/plans, deterministic provenance, canonical replay, and the
fixed log validateInputs, orderFeatures, bindTransportProvenance, completed are
implemented fail-closed. No transport protocol, serialization, request/response
model, retry, auth, endpoint, networking, Flutter, Provider, persistence, AI,
or runtime mutation exists. Evidence: focused 8/8, analyzer clean, app 777/777,
Knowledge 75/75, protected M3-M11 35/35, Architecture 133/0, diff check clean.
No commit/push before Product Owner acceptance.
Product Owner accepted and closed M12.4 on 2026-07-22. M12.5 AI Provider
Adapter Foundation is authorized next, consuming only TransportAdapterPlan and
AICoachInteractionSurfaceContract as aggregate provenance. No feature-to-AI
capability/provider/conversation/prompt/model mapping or AI execution is allowed.
M12.5 AI Provider Adapter Foundation is engineering complete and pending
Product Owner review. The stateless `AIProviderAdapterPlanner` imports only
TransportAdapterPlan and AICoachInteractionSurfaceContract. Canonical feature
ownership/order comes only from the Transport plan; the AI interaction surface
is bound only by its complete aggregate digest. Immutable feature entries/plans,
deterministic provenance, canonical replay, and the fixed log validateInputs,
orderFeatures, bindAIInteractionProvenance, completed are fail-closed for stale
bindings, duplicates, positions, orphan/incomplete coverage, broken provenance,
and malformed logs. Output contains no capability/player/interaction/provider/
conversation/prompt/model/processing mapping. No provider SDK, model/prompt,
tokenization, embedding, conversation/memory execution, streaming, inference,
AI runtime, networking, Flutter, Provider, or runtime mutation exists. Evidence:
focused 8/8, analyzer clean, app 785/785, Knowledge 75/75, protected M3-M11
35/35, Architecture 133/0, and diff check clean. No commit/push before PO
acceptance.
Product Owner accepted and closed M12.5 AI Provider Adapter Foundation on
2026-07-22. M12.6 Observability Adapter Foundation is authorized next. It may
consume only AIProviderAdapterPlan and RuntimeHealthDiagnosticsProjectionContract.
It may implement a pure deterministic ObservabilityAdapterPlanner, immutable
plan/entries, canonical AI Provider Adapter feature order, aggregate health
diagnostics digest binding, deterministic provenance, fixed log validateInputs,
orderFeatures, bindHealthProvenance, completed, and replay-safe digest. No
feature-to-runtime-service, diagnostics entry, metric, log, trace, or telemetry
mapping may be inferred. It must reject stale bindings, duplicate identities or
positions, orphan features, incomplete coverage, broken provenance, and
malformed logs. It must not implement logging, metrics, telemetry, tracing,
OpenTelemetry, Prometheus, health polling, diagnostics execution, monitoring,
event emission, runtime inspection, networking, Flutter, Provider, or runtime
mutation.
M12.6 Observability Adapter Foundation is engineering complete and pending
Product Owner review. The stateless `ObservabilityAdapterPlanner` imports only
AIProviderAdapterPlan and RuntimeHealthDiagnosticsProjectionContract. Canonical
feature ownership/order comes only from the AI Provider Adapter plan; health
diagnostics is bound only by its complete aggregate digest. Immutable feature
entries/plans, deterministic provenance, canonical replay, and the fixed log
validateInputs, orderFeatures, bindHealthProvenance, completed are fail-closed
for stale bindings, duplicates, positions, orphan/incomplete coverage, broken
provenance, and malformed logs. Output contains no runtime-service, diagnostics-
entry, metric, log, trace, telemetry, capability, provider, prompt, or model
mapping. No logging, metrics, telemetry, tracing, OpenTelemetry, Prometheus,
health polling, diagnostics execution, monitoring, event emission, runtime
inspection, networking, Flutter, Provider, or runtime mutation exists. Evidence:
focused 8/8, analyzer clean, app 793/793, Knowledge 75/75, protected M3-M11
35/35, Architecture 133/0, and diff check clean. No commit/push before PO
acceptance.
Product Owner accepted and closed M12.6 Observability Adapter Foundation on
2026-07-22. M12.7 Packaging & Deployment Adapter Foundation is authorized
next. It may consume only ObservabilityAdapterPlan and
RuntimeActivationDeliveryGateContract. It may implement a pure deterministic
PackagingDeploymentAdapterPlanner, immutable plan/entries, canonical
Observability Adapter feature order, aggregate activation/delivery gate digest
binding, deterministic provenance, fixed log validateInputs, orderFeatures,
bindDeploymentGateProvenance, completed, and replay-safe digest. No feature-to-
delivery-target, deployment-unit, runtime-node, activation-entry, or packaging
ownership mapping may be inferred. It must reject stale bindings, duplicate
identities or positions, orphan features, incomplete coverage, broken
provenance, and malformed logs. It must not implement APK/AAB or IPA generation,
installers, Docker/OCI/Kubernetes, CI/CD, Gradle, Xcode, signing, deployment
scripts, release automation, runtime deployment, Flutter, Provider, networking,
AI, or runtime mutation.
M12.7 Packaging & Deployment Adapter Foundation is engineering complete and
pending Product Owner review. The stateless
`PackagingDeploymentAdapterPlanner` imports only ObservabilityAdapterPlan and
RuntimeActivationDeliveryGateContract. Canonical feature ownership/order comes
only from the Observability Adapter plan; the activation/delivery gate is bound
only by its complete aggregate digest. Immutable feature entries/plans,
deterministic provenance, canonical replay, and the fixed log validateInputs,
orderFeatures, bindDeploymentGateProvenance, completed are fail-closed for stale
bindings, duplicates, positions, orphan/incomplete coverage, broken provenance,
and malformed logs. Output contains no delivery-target, deployment-unit,
runtime-node, activation-entry, or packaging ownership mapping. No APK/AAB or
IPA generation, installers, Docker/OCI/Kubernetes, CI/CD, Gradle, Xcode,
signing, deployment scripts, release automation, runtime deployment, Flutter,
Provider, networking, AI, or runtime mutation exists. Evidence: focused 8/8,
analyzer clean, app 801/801, Knowledge 75/75, protected M3-M11 35/35,
Architecture 133/0, and diff check clean. No commit/push before PO acceptance.
Product Owner accepted and closed M12.7 Packaging & Deployment Adapter
Foundation on 2026-07-22. M12.8 Infrastructure Integration Validation
Foundation is authorized next. It may consume only
PackagingDeploymentAdapterPlan and ProductionReadinessProjectionContract. It
may implement a pure deterministic InfrastructureIntegrationValidationPlanner,
immutable plan/entries, canonical Packaging Deployment Adapter feature order,
aggregate readiness digest binding, deterministic provenance, fixed log
validateInputs, orderFeatures, bindReadinessProvenance, completed, and
replay-safe digest. No feature-to-readiness-entry, deployment-gate,
runtime-node, or infrastructure ownership mapping may be inferred. It must
reject stale bindings, duplicate identities or positions, orphan features,
incomplete coverage, broken provenance, and malformed logs. It must not
implement deployment validation, infrastructure checks, cloud APIs,
Kubernetes, Docker, VM provisioning, health checks, readiness/startup
execution, Flutter, Provider, networking, persistence, AI, or runtime mutation.
M12.8 Infrastructure Integration Validation Foundation is engineering complete
and pending Product Owner review. The stateless
`InfrastructureIntegrationValidationPlanner` imports only
PackagingDeploymentAdapterPlan and ProductionReadinessProjectionContract.
Canonical feature ownership/order comes only from the Packaging Deployment
Adapter plan; readiness is bound only by its complete aggregate digest.
Immutable feature entries/plans, deterministic provenance, canonical replay,
and the fixed log validateInputs, orderFeatures, bindReadinessProvenance,
completed are fail-closed for stale bindings, duplicates, positions,
orphan/incomplete coverage, broken provenance, and malformed logs. Output
contains no readiness-entry, deployment-gate, runtime-node, or infrastructure
ownership mapping. No deployment validation, infrastructure checks, cloud APIs,
Kubernetes, Docker, VM provisioning, health checks, readiness/startup execution,
Flutter, Provider, networking, persistence, AI, or runtime mutation exists.
Evidence: focused 8/8, analyzer clean, app 809/809, Knowledge 75/75, protected
M3-M11 35/35, Architecture 133/0, and diff check clean. No commit/push before
PO acceptance.
Product Owner accepted and closed M12.8 Infrastructure Integration Validation
Foundation on 2026-07-22. M12 Foundation Freeze & Architecture Validation is
authorized next. It may add only M12_FOUNDATION_FREEZE.md,
m12_freeze/contract_manifest.json, m12_freeze/proof_record.json, and
m12_foundation_freeze_test.dart. It must freeze exactly M12.1-M12.8, verify
normalized SHA-256 hashes, unique public symbols, reconstructed acyclic
dependencies, canonical replay, version markers, hidden mutable/runtime
mechanism absence, unchanged protected M3-M11 artifacts, and a deterministic
M12 contract-set digest. No production source or ownership boundary may change,
and no runtime, UI, networking, persistence, AI, Provider, Flutter execution,
or deployment behavior may be added.

M13.0 Production Behavior Implementation Planning was accepted and closed on
2026-07-22 at `f5fb640`. The accepted acyclic plan contains 8 capabilities and
14 prerequisite edges. M13.1 Configuration Loading Behavior is the first
authorized production behavior and may consume only the frozen M10.6
`RuntimeConfigurationEnvironmentProjectionContract` and M12.2
`ConfigurationAdapterPlan`.

M13.1 Configuration Loading Behavior was accepted and closed by the Product
Owner on 2026-07-22. The Application-owned `ConfigurationLoader` validates
the exact aggregate plan/projection binding, creates immutable canonical
ownership requests, loads values only through an abstract
`ConfigurationValueProvider`, and returns an immutable deterministic
`RuntimeConfiguration`. It does not infer a feature-to-configuration mapping
because the frozen inputs define none. Missing/foreign coverage, duplicate
entry or value identity, empty required configuration, stale provenance, and
invalid ownership fail closed with no fallback. It adds no direct environment,
filesystem, persistence, networking, Flutter, state management, DI, startup,
activation, lifecycle, Coach, Recommendation, or AI behavior. Evidence:
focused 7/7, analyzer clean, app 821/821, Knowledge 75/75, protected M3-M12
40/40, Architecture 133/0, and diff check clean. M13.2 Persistence
Implementation is authorized next and may consume only the frozen M12.3
`PersistenceAdapterPlan` and M13.1 `RuntimeConfiguration`. It may introduce an
abstract persistence backend and deterministic initialization state, but no
concrete database, SQL, repository, DAO, cache, migration, networking,
Flutter, state management, DI, activation, scheduler, AI, business logic, or
post-initialization runtime mutation.
