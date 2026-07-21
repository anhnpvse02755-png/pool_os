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

Product Owner accepted and closed M5.1 on 2026-07-22. M5.2 Prompt Rendering
Foundation is Ready to Start. Rendering consumes Prompt Assembly only and emits
a provider-neutral structured payload with its own version and digest. It must
not consume Context/Planning/Recommendation directly or perform Provider
formatting, token counting, HTTP, retry, credential, SDK, or network behavior.

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
