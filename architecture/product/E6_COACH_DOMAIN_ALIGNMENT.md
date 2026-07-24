# E6 Coach Domain Alignment And Gap Analysis

Status: Accepted; Closed

Date: 2026-07-24

## Decision Context

Coach is the Product-facing policy surface of the Intelligence domain. Its
current implementation contains legacy engines, the production Coach V2 flow,
frozen deterministic foundation contracts, learning-runtime slices and AI
boundary adapters. E6 characterizes these surfaces without redesign. This is
documentation-only: no code, schema, runtime, framework, AI model, prompt,
repository, migration, UI or capability/runtime change is introduced.

## Ownership Map

| Concern | Owner | Current evidence | Boundary |
| --- | --- | --- | --- |
| Coaching policy, priority and next action | Coach / Intelligence | `CoachBrain`, deterministic M3 builders | Must use structured inputs and traceable decisions |
| Coach context/read model | Coach / Intelligence | `CoachContext`, `CoachContextContract` | Derived from external owners; not Evidence truth |
| Decision lifecycle, planning, recommendation and execution projections | Coach / Intelligence | M3 contracts/projectors | Immutable deterministic foundation |
| Player observations and history | Evidence/Player domains | source repositories/contracts | Coach reads; never rewrites source facts |
| Knowledge/drill definitions and eligibility source | Knowledge/Learning Runtime | published Knowledge and eligibility projection | Coach selects/uses resolved references only |
| Mastery/readiness/performance/endurance | respective Intelligence projections | Finding producers | Coach interprets; does not duplicate algorithms |
| Coach memory facts | Coach Memory | external repository/consolidator | Facts only, never Coach wording/actions |
| AI input/output/provider/orchestration boundaries | AI infrastructure contracts | M3.9+ builders/adapters | AI is a consumer; no live model in Product flow |
| UI/navigation/localization | Experience | Coach screen/action navigation | Renders keys/projections; no coaching inference |

## Public API Inventory

### Production Coach V2

- `Finding`, `FindingSource`, `ContextValue` describe normalized derived facts.
- `CoachContext`, trajectories and coverage assemble the current read model.
- `CoachBrain` is the documented sole V2 decision-maker.
- `ConfidenceService`, `ActionResolver`, `ReinforcementService`,
  `LevelService` and `PriorityService` hold focused policy.
- `CoachOutput`, `CoachInsightV2`, `CoachAction`, `PlayerLevel` and
  `CoachUnderstanding` drive Product UI.
- Finding producers adapt mastery, performance, Match/Shot context, memory,
  skills, training, readiness, equipment, endurance and coverage.

### Frozen Deterministic Foundation

- `CoachContextBuilder`, `CoachDecisionBuilder` and
  `CoachDecisionLifecycleProjector`.
- `CoachPlanner`, `CoachPlanningEngine` and planning graph contracts.
- `CoachRecommendationBuilder`, `AdaptiveRecommendationEngine`.
- `CoachExecutionProjector`, `SessionExecutionCoordinator` and outcome/
  adaptation projectors.
- `AISessionBuilder`, `CoachAIAdapter`, deterministic stub provider,
  `DeterministicAIOrchestrator` and `PromptAssemblyBuilder`.
- `TrainingSessionBuilder` and `TrainingOutcomeProjector` downstream adapters.

These APIs are contract-driven, deterministic and heavily covered by frozen
foundation tests, but they are not yet the end-to-end source rendered by the
current Coach screen.

### Compatibility And Legacy APIs

- `CoachRuleEngine`, `CoachRecommendationEngine` and `CoachIntelligence`.
- the 1,000-line legacy `CoachNotifier` state/composition path;
- `CoachBrain` V2's local `KnowledgeRegistry` and output model;
- stop-shot `LearningRuntime` and controllers;
- `MatchObjectivePolicy`;
- in-memory `RecommendationHistoryStorage` abstraction.

These remain code compatibility surfaces. E6 does not rename, remove or make
them canonical by documentation.

## Service Inventory

| Service | Responsibility |
| --- | --- |
| `CoachBrain` | Deterministic V2 ranking, confidence, reinforcement and action selection |
| `CoachConversationService` | Structured intent-to-response-key projection through command execution |
| `CoachContextBuilder` | Frozen contract context construction |
| M3 decision/planner/recommendation/execution services | Deterministic lifecycle foundation |
| `LearningRuntime` | Knowledge/Evidence-driven technique and mistake snapshots |
| eligibility projector | Converts Learning Runtime output to resolved eligibility contract |
| AI session/adapter/orchestrator/prompt builders | Frozen AI boundaries and deterministic stub plumbing |
| Training builders/projectors | Convert Coach planning/execution into downstream Training contracts |

Conversation does not call an LLM. It returns structured localization keys,
metrics, Evidence display and action references from existing `CoachOutput`.

## Repository And Persistence Inventory

There is no Coach-owned repository under `features/coach/` and no Coach
Decision/Plan/Recommendation/Execution persistence wired into the Product UI.

Current persistence interactions are indirect:

- `coachContextProvider` reads many external repositories and synchronizes
  Coach Memory through the separately owned `coach_memory` repository;
- legacy provider reads Session, Match, Rack, Shot, Statistics, Skill and Daily
  Readiness repositories directly;
- `RecommendationHistoryStorage` wraps a supplied in-memory map and is not a
  durable Product repository;
- conversation turns live only in Riverpod state and clear on disposal/restart;
- stop-shot Evidence log/controllers are separate vertical-slice state.

The M3 lifecycle and execution contracts are append-only/replayable by design,
but E6 finds no Product persistence wiring and introduces none.

## Provider Inventory

| Provider family | Current role |
| --- | --- |
| `coachContextProvider` | reads source domains, reconciles memory and builds V2 context |
| `coachOutputProvider` | runs `CoachBrain.decide` and supplies production screens |
| `coachConversationProvider` | in-memory structured turns and submit state |
| legacy `coachProvider` | older recommendation/intelligence/report composition |
| stop-shot providers/controllers | Learning Runtime vertical-slice commands/snapshots |

Production Coach, Dashboard, Home, Competition Review and Training Center use
`coachOutputProvider`. The legacy `coachProvider` has no current Product-screen
consumer found by E6 and remains a compatibility/deprecation concern.

## UI And Route Inventory

- `/coach` renders `CoachScreen`, the V2 level/understanding/conversation/
  primary-action/feed experience.
- `/session/review` renders `CoachReviewScreen` using the same V2 output.
- Dashboard and Home consume V2 output projections.
- Training Center and Knowledge detail invalidate V2 context/output after
  relevant user actions.
- `coach_action_navigation.dart` resolves stable Knowledge/action references to
  Experience destinations.

The UI renders localization keys and navigates; it does not calculate Coach
priority or recommendations.

## Execution Ownership Map

```text
Source domain repositories / accepted projections
                    |
                    v
Finding producers + Coach Memory reconciliation
                    |
                    v
CoachContext (V2 read model)
                    |
                    v
CoachBrain (sole V2 policy owner)
                    |
                    v
CoachOutput + structured Conversation turns
                    |
                    v
Experience rendering/navigation
```

The frozen target foundation is more explicit:

```text
CoachContextContract -> Decision -> Lifecycle -> Plan -> Recommendation
  -> Execution -> AISession -> AI boundary -> CoachResponse
  -> Training Session / Outcome / Adaptation projections
```

E6 records the integration gap between these two pipelines. It does not insert
a new orchestrator or bypass either boundary.

## Cross-Domain Dependency Graph

| Direction | Dependency | Alignment decision |
| --- | --- | --- |
| Coach -> Evidence/Match/Rack/Shot/Session | findings/history | Replace direct reads with public projections only under a future packet |
| Coach -> Player Model/Mastery/Performance | inferred snapshots | Producers remain owners of algorithms; Coach interprets outputs |
| Coach -> Knowledge/Training Center | entries, drill runs, eligibility | Knowledge owns content; Training owns execution |
| Coach -> Readiness/Endurance/Equipment | read projections | No ownership transfer |
| Coach -> Coach Memory | recurring fact reconciliation | Memory never stores recommendations or prose |
| Coach -> AI contracts | session/request/response/provider boundaries | No direct deterministic-internal access by future AI |
| Experience -> Coach | render output, submit structured intent | Experience does not infer recommendations |
| Coach -> Training contracts | selected session/execution projection | Training owns execution lifecycle |

## Overlap Analysis

**Three Coach generations are currently present. Their coexistence is treated
as a compatibility condition rather than an architectural defect. No
implementation is selected for removal under this documentation-only
milestone. Future convergence requires an explicitly authorized Adapter and
Deprecation Policy milestone.**

1. Legacy `CoachRuleEngine`/`CoachRecommendationEngine`/`CoachIntelligence`
   produce older recommendation/advice/report models.
2. Production Coach V2 produces `CoachOutput` through Findings and CoachBrain.
3. M3 foundation produces immutable Decision/Plan/Recommendation/Execution and
   AI-boundary contracts.
4. Stop-shot Learning Runtime is a focused Knowledge/Evidence vertical slice,
   not a replacement Coach architecture.

These layers reflect historical delivery stages. They must not be combined by
adding a fourth decision model. None is designated for removal or replacement
by E6. The foundation contracts remain frozen; any future convergence requires
the separately authorized milestone stated above.

## Ownership And Compatibility Risks

- Three generations of Coach decision/recommendation models can diverge in
  priority, lifecycle, terminology and behavior.
- Production V2 bypasses the M3 Decision/Plan/Recommendation/Execution pipeline,
  so its user-visible output lacks those exact contract bindings/digests.
- `coachContextProvider` both reads and writes (memory synchronization), making
  a read provider impure.
- V2 directly imports persistence repositories and even an Endurance
  presentation provider rather than public cross-domain ports.
- V2 `CoachOutput` lists/maps are not defensively immutable and carry no
  deterministic digest/provenance binding.
- `CoachInsightV2.evidence` contains preformatted display text alongside
  structured `evidenceData`; explanation grounding is not enforced by the M3
  Decision Trace contract.
- Coach lifecycle is recomputed and not bound to append-only Decision history.
- wall-clock context construction, legacy engines, request timestamps and UUID
  command IDs reduce deterministic replay.
- conversation sequence/history is process-local and turns are not bound to a
  CoachOutput digest/version/provenance.
- conversation capability bootstrap is recreated per service and cancellation
  is permanently disabled.
- legacy `CoachNotifier` is large, directly reads repositories and duplicates
  analysis/policy responsibilities.
- duplicate concepts include `TrendDirection`, recommendations, advice,
  insights, histories and training plans.
- stop-shot Learning Runtime lives under Coach while resolving Knowledge and
  Evidence; its ownership boundary is historical and easy to misread.
- Knowledge registry action mapping is local and can drift from canonical
  Knowledge navigation contracts.
- no live provider/LLM is wired, but prompt/AI foundation classes may be
  mistaken for active Product AI.

## Genuine Missing Concepts

- authoritative adapter from production V2 context/output to frozen M3
  Decision/Plan/Recommendation/Execution contracts;
- explicit canonicalization and retirement policy for legacy Coach engines;
- stable V2 IDs, canonical JSON, version bindings, provenance and digest;
- structured Decision Trace binding for every user-visible explanation/action;
- pure context projection separated from Coach Memory reconciliation command;
- public read ports for all source-domain inputs;
- durable append-only lifecycle/execution integration for Product actions;
- conversation request/turn contract bound to exact Coach output/session digest;
- deterministic clock, command identity and cancellation policy;
- one authoritative action/Knowledge reference registry;
- compatibility mapping for legacy insights/recommendations/history;
- operational AI activation policy only after existing boundary gates are used.

These are findings only. E6 implements none of them.

## Evolution Matrix

| Artifact | Action | Constraint |
| --- | --- | --- |
| Coach V2 Findings/Context/Brain/Output | Keep as Product compatibility flow | Current screens depend on it |
| M3 deterministic Coach contracts/builders | Freeze/reuse | Canonical target boundary; no changes in E6 |
| legacy rule/recommendation/intelligence engines | Keep pending explicit retirement | Do not extend for new Product behavior |
| legacy `coachProvider` | Keep pending usage/deprecation proof | No removal in alignment packet |
| Conversation service/provider | Keep structured/in-memory | No LLM or persistence expansion |
| stop-shot Learning Runtime | Keep as vertical-slice compatibility | Do not interpret placement as Coach ownership of Evidence/Knowledge |
| AI builders/adapters/orchestrator/stub | Freeze/reuse | No live provider/model activation |
| Coach Memory | Keep external fact owner | Never store Coach output/prose |
| Coach UI/routes | Keep | Experience renders projections only |
| Training builders/projectors | Keep downstream adapters | Training owns execution |

## Compatibility Strategy

1. Preserve current Coach V2 UI behavior, routes, provider names and legacy
   models while no migration packet exists.
2. Do not create another Coach insight, recommendation, lifecycle, planner,
   execution or AI boundary abstraction.
3. Treat frozen M3 contracts as the target integration boundary; bridge V2
   through adapters with characterization tests before retiring legacy paths.
4. Keep Findings factual and keep all priority/action selection in Coach policy.
5. Separate Memory writes from future pure context reads before claiming pure
   deterministic projection.
6. Introduce public source-domain ports before adding new direct repository
   dependencies.
7. Bind future Product explanations to structured Decision Trace and exact
   provenance; formatted text alone is insufficient.
8. Keep AI stubbed and isolated until an explicit activation milestone uses
   AISession/CoachResponse/provider compatibility gates.
9. Preserve Knowledge authorship, Evidence immutability, Player/Performance
   inference and Training execution ownership.
10. Preserve all three generations in E6. Any adapter, deprecation or removal
    decision requires a separately authorized Product milestone after Domain
    Alignment is complete.

## Verification

- Inventory covers ownership, APIs, services, persistence, providers, UI,
  routes, execution, dependencies and overlap.
- Existing concepts are separated from genuine gaps.
- Existing Coach Product characterization tests: 5/5.
- Full app regression: 1184/1184.
- Knowledge package regression: 75/75.
- Foundation freeze: 76/76.
- Architecture Fitness: 133 existing violations, 0 new.
- Analyzer: no errors; unchanged repository baseline of 62 lint infos.
- `git diff --check`: clean.
- No Product code, schema, tests, UI, runtime, prompt or framework was changed.
- Protected generated artifacts are unchanged.
- Diff is limited to the exact E6 documentation allowlist.

## Repository State

Product Owner accepted and closed E6 on 2026-07-24 without requested changes.
The authorization permits the documentation and memory updates to be committed
and pushed. The three Coach generations remain a compatibility condition; no
implementation is selected for removal, convergence or replacement.
