# E9 Simulation Domain Alignment And Expansion Readiness

Status: Accepted; Closed

Date: 2026-07-24

## Decision Context

I10 is a read-only Product experience that replays and compares recorded Match
and Training summary observations. Despite its Product name, it is not the
physics Simulation Domain defined by the Architecture Constitution. It has no
table/ball state, units, calibration, physical model, trajectories,
uncertainty, engine version or prediction. E9 characterizes this distinction
without changing replay semantics or adding physics, billiards simulation,
Monte Carlo, prediction, AI/ML, numerical solvers, repositories, schemas,
persistence, runtimes, frameworks, caches or workers.

## Ownership Map

| Concern | Owner | Current evidence | Boundary |
| --- | --- | --- | --- |
| Recorded Match/Rack observations | Match/Rack | `MatchStatisticsService` | I10 reads summary samples only |
| Recorded Training observations | Training | `TrainingStatisticsService` | I10 reads summary samples only |
| Product observed-data replay/comparison | Product Simulation I10 | `SimulationMvpService` | No physical inference or prediction |
| Session-local selector/history state | Experience | provider/notifier | Clearable, non-durable UI state |
| Physical scenario/request/result | Platform Simulation | Constitution and versioned port | Not implemented or invoked by I10 |
| Player state/mastery | Player/Intelligence | external domains | I10 has no player input |
| Coach policy/action selection | Coach/Intelligence | external domain | I10 does not recommend or rank |
| Analytics dashboard | Analytics | I9 projection | I10 shares source services, not Analytics output |

## Constitutional Classification

The constitutional Simulation Domain answers what physical outcomes are
possible. Its contract requires geometry, ball state, units, cue impact,
environment/calibration, requested outputs, engine/model versions, input
digest, trajectories, uncertainty and deterministic seed where required.

I10 answers a different Product question: what rates and durations were already
observed in recent Match and Training records? It performs no simulation
execution. The I10 capability implements lifecycle, scenario preparation,
result collection and statistics markers; it deliberately does not implement
`SimulationExecutionCapability`.

I10 therefore remains an observed-data replay/Experience capability. It must
not become the implementation of the constitutional physics boundary by
incremental additions.

## Public API Inventory

- `SimulationScenarioKind`: Match replay, Training replay or combined replay.
- `SimulationSampleKind`: source discriminator for Match or Training.
- `SimulationReplaySample`: immutable source kind, local ID, occurrence time,
  observed rate and recorded duration.
- feature-local `SimulationRequest`: request ID, observed-data scenario and
  positive sample-limit intent.
- `SimulationPreview`: immutable selected samples plus arithmetic mean observed
  rate and summed recorded duration.
- `SimulationComparison`: left/right previews and observed-rate delta.
- `SimulationMvpService.preview()` and `compare()`.
- `simulationMvpServiceProvider`, `simulationSessionProvider`, session state and
  notifier.
- `SimulationMvpScreen`: scenario selection, compare action, chart and
  session-local history.

The shared Product domain also contains a different `SimulationRequest` entity
with entity ID/version/created-at, scenario reference/digest and lifecycle
state. It is a structural Product request skeleton and is not wired to I10.
The two same-named request models are a compatibility overlap; E9 does not
merge, rename or select either for removal.

## Replay Model Inventory

### Source samples

Match samples adapt completed per-match performance from
`MatchStatisticsService`: Match ID/end time, rack win rate and duration.
Training samples adapt completed-session summaries from
`TrainingStatisticsService`: session ID/date, exercise success rate and
duration.

### Scenario replay

- Match replay loads only Match samples.
- Training replay loads only Training samples.
- Combined replay loads and concatenates both sources.
- Samples sort by occurrence descending, then kind, then source-local ID, and
  are truncated to the request limit.

This is deterministic ordering over supplied observations. It is not event-log
replay, deterministic physics replay or reconstruction of original domain
state.

### Comparison

Comparison previews the left scenario, then the right scenario, and subtracts
their arithmetic mean observed rates. It predicts nothing. Summed duration is
display-only recorded duration, not simulated time.

### Session history

Each successful compare appends two previews to an immutable in-memory list.
The user may clear the list. This is presentation history, not an append-only
domain audit record and not persisted replay evidence.

## Dependency Inventory

| Dependency | Role | Ownership decision |
| --- | --- | --- |
| `MatchStatisticsService` | loads recorded Match samples | Match owns aggregation |
| `TrainingStatisticsService` | loads recorded Training samples | Training owns aggregation |
| Query executor | executes feature-local read query | accepted generic framework |
| Simulation capability/runtime | identity/version preflight | no physical execution |
| Riverpod | session-local state/wiring | Experience only |
| `fl_chart` | two-bar comparison rendering | presentation only |
| Home | opens I10 and requests combined preview | Product composition only |

I10 imports no repository, database, physics model, Coach, Player, Knowledge or
Analytics implementation.

## Runtime Interaction

```text
Match persistence -> MatchStatisticsService -----+
                                                |
Training records -> TrainingStatisticsService ---+-> I10 replay adapters
                                                        |
                                                        v
                                               SimulationMvpService
                                                        |
                                         preview / sequential compare
                                                        |
                                                        v
                                            screen + local history
```

The service runs capability compatibility preflight at construction and each
preview through the accepted query executor. Cancellation is permanently
disabled. Execution request time is local metadata and does not enter the
preview value.

## Existing Chart And Experience

The screen offers two scenario selectors, one compare command, a two-bar chart
of observed rates, two preview summaries, observed delta and the six most
recent session-history previews. It performs formatting only.

There is no named Simulation route. Home opens the screen with an in-memory
route and separately requests a combined preview of three samples for its
summary card. Home and the screen can therefore observe different source
moments.

## Cross-Domain Dependency Map

| Direction | Dependency | Alignment decision |
| --- | --- | --- |
| I10 -> Match | completed statistics projection | no repository access |
| I10 -> Training | completed statistics projection | no execution mutation |
| Home -> I10 | combined observed preview/screen | Experience composition |
| I10 -> Analytics | none | services share sources, not projection ownership |
| I10 -> Coach | none | no recommendation or policy |
| I10 -> Player | none | no identity, mastery or profile |
| I10 -> Knowledge | none | no patterns or learning paths |
| I10 -> Platform Simulation | none | physics port is not implemented |

## Match, Training, Analytics, Coach And Player Interaction

Match and Training remain the owners of source records and aggregate rates.
I10 copies only the fields needed for observed replay and cannot change source
definitions.

Analytics I9 independently adapts the same services into a dashboard. I10 does
not consume `AnalyticsDashboardView`; shared source use is not an Analytics
dependency.

Coach and Player have no I10 dependency. I10 neither filters by player nor
selects a coaching action. Any future Coach use of physical Simulation must go
through Intelligence and a constitutional versioned Simulation port, never
through the I10 Experience provider.

## Concept Alignment And Overlap

| Concept | Current meaning | Compatibility overlap |
| --- | --- | --- |
| I10 replay | sorted historical summary samples | name can imply physics/event replay |
| I10 scenario | Match/Training source selection | not physical table scenario |
| I10 result | observed preview/comparison | not physical outcome/result contract |
| I10 request | feature query with sample limit | shared Product entity has same name |
| capability runtime | registration/version preflight | execution marker exists but I10 does not implement it |
| Analytics I9 | dashboard over same services | separate projection with similar samples |
| Platform Simulation | future physics boundary | no implementation in I10 |

The naming overlap is an accepted repository fact. E9 documents it and does
not authorize a rename, adapter, convergence or removal.

## Evolution Matrix

| Artifact | Action | Constraint |
| --- | --- | --- |
| I10 replay samples/request/preview/comparison | Keep as observed-data Product contract | Never claim physics semantics |
| `SimulationMvpService` | Keep read-only | No prediction, solver or physical model |
| I10 capability preflight | Keep/freeze | Does not imply execution capability |
| provider/notifier/history | Keep session-local | No persistence or audit claim |
| I10 screen/chart | Keep | Experience formatting only |
| Match/Training loaders | Keep/reuse | Source domains own calculations |
| shared Product `SimulationRequest` entity | Preserve | Separate lifecycle skeleton; no merge in E9 |
| constitutional Simulation contract | Preserve as future Platform boundary | Not implemented by I10 |

## Genuine Gaps

- explicit Product naming/compatibility policy separating observed replay from
  physical Simulation without breaking accepted I10 consumers;
- public Match/Training replay projections with version, provenance and source
  snapshot identity;
- one consistent source cutoff for sequential left/right comparisons;
- validation for request IDs, sample limits, rates, durations, timestamps and
  duplicate kind/ID pairs;
- semantic policy for combined arithmetic means across Match win rate and
  Training success rate, which have different denominators;
- cancellation and typed/stable error diagnostics;
- explicit lifecycle relationship, if any, between feature-local and shared
  Product request models;
- localization/accessibility and chart semantics;
- a separately authorized Intelligence-to-Platform-Simulation adapter only
  when a real versioned physics contract and engine exist.

These are findings only. E9 implements none of them.

## Compatibility Strategy

1. Keep I10 strictly labeled and behaved as observed-data replay/comparison.
2. Do not add physics fields or algorithms to I10 models or providers.
3. Reserve constitutional Simulation request/result semantics for the Platform
   physics port with versions, units, calibration, uncertainty and provenance.
4. Keep Match and Training as source aggregation owners; I10 reads public
   projections only.
5. Keep Analytics, Coach, Player and Knowledge semantics outside I10.
6. Preserve both request models until an explicitly authorized naming/adapter
   milestone defines compatibility and deprecation policy.
7. Do not treat presentation history as domain replay evidence or persistence.

## Risk Assessment

- High: the Simulation/replay/scenario/result names can cause observed summary
  comparison to be mistaken for the constitutional physics boundary.
- High: combined and cross-scenario rate averages compare different source
  denominators without an explicit semantic contract.
- High: sequential previews lack one source cutoff and may compare different
  repository moments.
- Medium: two same-named `SimulationRequest` models can lead to the wrong
  lifecycle or contract being used.
- Medium: samples/results lack version, provenance, digest, player scope and
  validation.
- Medium: the capability enum exposes execution while I10 intentionally does
  not implement physical execution.
- Low: local history is unbounded during a session even though only six items
  render, and UI strings are English-only.

## Verification

- Inventory covers I10 service/presentation, source services, capability/runtime,
  replay/comparison models, chart, replay pipeline, Home composition and the
  constitutional Simulation boundary.
- Allowlist compliance: only the E9 document and `MEMORY.md` are changed.
- Outside allowlist changes: 0.
- `git diff --check`: clean.
- Protected artifacts: unchanged.
- No regression suite was run because E9 is documentation-only and requires no
  implementation verification.

## Repository State

Product Owner accepted and closed E9 on 2026-07-24 without requested changes.
The authorization permits the documentation and memory updates to be committed
and pushed. No naming convergence, request-model merge or physics implementation
is authorized by this acceptance.
