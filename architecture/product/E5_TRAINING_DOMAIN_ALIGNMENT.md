# E5 Training Domain Alignment And Gap Analysis

Status: Accepted; Closed

Date: 2026-07-24

## Decision Context

Training exists across an accepted Product execution flow and an older Training
Center flow. E5 characterizes both without redesign. This milestone is
documentation-only: no code, schema, runtime, framework, repository, migration,
UI or capability/runtime addition is authorized.

## Ownership Map

| Concern | Current owner | Evidence | Boundary |
| --- | --- | --- | --- |
| Training intent and exercise lifecycle | Training | Product views and execution service | Does not own Match/Rack facts |
| Product Training Session lifecycle | Session application | `TrainingSessionExecutionService`, recording `Session` | Uses `sessionType=training` |
| Cross-recording transactions | Session | `RecordingCoordinator` | Only write choke-point |
| Exercise recording envelope | Match/Rack | drill Match plus summary Rack | Reused persistence, not Training ownership transfer |
| Legacy drill library/custom practice | Training Center | `CustomDrill`, `TrainingSession`, `DrillRun` | Separate persisted compatibility flow |
| Knowledge-backed drill identity | Knowledge | optional knowledge references | Training consumes references only |
| Player identity/state | Player / Player State | external owners | Training may reference, never own |
| Coach recommendation/plan | Coach | Coach contracts | Training executes selected work only |
| Analytics | Analytics/Statistics | derived projections | Training statistics are read models |
| Simulation | Simulation | physics | Training may consume results through future adapters |

The foundation `TrainingSession`/`TrainingAggregate`, Product recording flow and
legacy Training Center model are representations/surfaces in the broader
Training capability. They must be aligned through explicit adapters rather than
creating another Training Session concept.

## Public API Inventory

The `features/training/` Product surface exposes:

- `TrainingStatisticsService.load` for completed-session, exercise, drill and
  trend projections;
- `TrainingSessionView` for add/complete exercise and finish-session actions;
- `TrainingHistoryView` and `TrainingDetailScreen` for completed history;
- `TrainingStatisticsPanel` for aggregate performance display.

Execution is provided by Session-owned `TrainingSessionExecutionService`:

- `createSession`;
- `addExercise`;
- `completeExercise`;
- `finishSession`;
- `loadExercises`, `loadCompletedSession(s)`.

Legacy Training Center exposes `CustomDrill`, its own `TrainingSession`,
`DrillRun`, `TrainingCompletion`, `DrillProgress`, repository CRUD, favorites,
progress calculator and drill-picker/session screens. Foundation contracts add
typed Training identity, structural aggregate and frozen capabilities/runtime.

## Repository Inventory

The Product Training flow has no Training-owned repository. It deliberately
uses `SessionRepository`, `MatchRepository`, `RackRepository` and
`RecordingCoordinator` through its execution service.

`TrainingCenterRepository` separately owns legacy:

- custom drill CRUD;
- Training Center session create/complete/delete/history;
- drill-run append/read;
- favorite keys.

It manually cascades Training Center session deletion to DrillRun rows and uses
soft references for custom drills and Knowledge entries.

## Persistence Inventory

| Flow | Tables/encoding | Meaning |
| --- | --- | --- |
| Product Training | `sessions` (`training`), drill `matches`, summary `racks` | Shared recording truth and I3/I4/I6 Product flow |
| Legacy Training Center | `custom_drills`, `training_center_sessions`, `drill_runs`, `drill_favorites` | Task 09 library/practice compatibility flow |

In the Product flow, exercise code/name are stored in Match notes/objective;
attempts/successes are encoded in Rack miss/potted fields and completion is
Match end time. In Training Center, DrillRun stores explicit target, attempts,
successes, category and denormalized name. E5 neither merges nor migrates these
representations.

## Service And Provider Inventory

| Surface | Responsibility |
| --- | --- |
| `TrainingSessionExecutionService` | Product commands, validation and history composition |
| `RecordingCoordinator` | atomic creation/completion/finish operations |
| `TrainingStatisticsService` | Product completed-history projections |
| `trainingSessionExecutionServiceProvider` | Product execution wiring |
| `trainingStatisticsServiceProvider` | Product statistics wiring |
| Training Center repository/providers | legacy library/session/favorite/progress wiring |

The Product service uses accepted `CommandExecutor` and application context,
but request sequence/time are process and wall-clock based and cancellation is
hard-coded off. Structured failures are converted to `StateError(code)`.

## UI And Route Inventory

- `/training-center` is the primary Training navigation destination.
- `SessionScreen` embeds `TrainingSessionView` for the Product recording flow.
- Home and Session screens embed `TrainingHistoryView`.
- `TrainingDetailScreen` links to Session summary.
- Training Center owns category, drill picker, custom drill editor, progress,
  stop-shot and legacy Training Center session experiences.

Some Training Center screens are pushed locally rather than registered as
top-level routes. E5 changes none of these experiences.

## Execution Ownership Map

```text
TrainingSessionView
        |
        v
Session-owned TrainingSessionExecutionService
        |
        +-- CommandExecutor / application context
        +-- Training validation
        |
        v
Session-owned RecordingCoordinator
        |
        +-- transaction
        v
Session -> drill Match -> summary Rack
```

The Training Center legacy path writes only its four dedicated tables through
`TrainingCenterRepository`; it intentionally does not use the recording chain.
That coexistence is current compatibility behavior, not an architectural ideal
to change during E5.

## Cross-Domain Dependency Graph

| Direction | Dependency | Alignment decision |
| --- | --- | --- |
| Training -> Session | lifecycle container/execution service | Session owns transaction/lifecycle infrastructure |
| Training -> Match/Rack | exercise persistence envelope | Match/Rack retain fact ownership |
| Training Center -> Knowledge | optional drill entry reference | Knowledge remains source of authored content |
| Training -> Player | optional player association | Player identity remains external |
| Coach -> Training | future recommended work | Coach decides; Training executes |
| Analytics -> Training | history/statistics projection | Analytics does not own Training facts |
| Simulation -> Training | future result/reference | Simulation physics stays separate |
| Product Training -> accepted command framework | execution | Reuse frozen framework; no parallel abstraction |

## Overlap Analysis

- Product and Training Center both model a training session, exercise/drill and
  attempt/success outcome, but use different storage and lifecycle semantics.
- Foundation `TrainingSession`/`TrainingAggregate` is a structural typed model,
  not a third production store.
- Recording `Session` is a generic lifecycle container; Training owns the
  training meaning of the workflow.
- Drill Match/Rack rows are a persistence envelope and do not make Training a
  subtype of Match.
- Training statistics and progress are projections, never source records.
- Knowledge drills are authored content; custom drills are user-authored
  Training data.

## Ownership And Compatibility Risks

- Two persisted Training flows can diverge and produce incomplete combined
  history/statistics.
- Multiple classes named `TrainingSession` exist with different identities and
  lifecycle fields; there is no explicit mapping contract.
- Product exercise data is encoded into generic Match/Rack fields, coupling
  meaning to storage conventions.
- Legacy Training Center explicitly avoids the recording pipeline, so cross-
  flow atomicity and unified identity do not exist.
- Product session creation checks active Session then inserts without one
  encompassing transaction, leaving concurrency risk.
- Product UI keeps mutable `_ExerciseDraft` state and a fixed target of 10;
  process death before completion loses unsaved attempts.
- Exercise codes are generated from names and can be empty/collide.
- Product history silently skips drill Matches without a Rack.
- Only the first Rack is interpreted for an exercise.
- Wall-clock IDs/timestamps and never-cancelled execution reduce replayability.
- Training Center soft references and manual cascades have limited integrity.
- Training Center completion/favorites use wall-clock time and procedural
  uniqueness.
- Denormalized names preserve history but can diverge from current catalog.
- Direct repository consumers risk bypassing execution/recording policy.

## Genuine Missing Concepts

- authoritative compatibility map among Product, Training Center and foundation
  Training Session representations;
- explicit decision whether/when histories are unified, with migration policy;
- stable Training Session, exercise and drill-run identities;
- versioned Training lifecycle and outcome contract with provenance;
- durable incremental attempt recording/recovery;
- configurable target/success criteria bound to drill identity;
- public Training command/read ports for Coach and Analytics;
- atomic active-Session creation policy;
- deterministic execution clock/request/cancellation inputs;
- typed Knowledge/custom drill references and compatibility validation;
- deletion/retention policy across both flows;
- structured Product failure mapping and audit trail.

These are findings only. E5 implements none of them.

## Evolution Matrix

| Artifact | Action | Constraint |
| --- | --- | --- |
| Product Training views/services | Keep | Accepted I3/I4/I6 Product flow |
| `TrainingSessionExecutionService` | Keep Session-owned | Do not duplicate executor |
| `RecordingCoordinator` | Keep | Sole cross-recording write choke-point |
| recording Session/Match/Rack representation | Keep | Compatibility persistence envelope |
| Training Center models/repository/UI | Keep as legacy compatibility flow | No silent migration or deletion |
| foundation Training entity/aggregate | Keep as typed direction | Adapter required before Product convergence |
| Training statistics/progress | Keep as projections | Never become source truth |
| Knowledge/custom drill references | Keep distinct | Authored vs user-created ownership |
| frozen Training capability/runtime | Reuse | No additions in E5 |

## Compatibility Strategy

1. Preserve both persisted flows, schemas, stored codes, APIs and routes.
2. Do not introduce another Training Session, exercise or outcome aggregate.
3. Define adapters and identity mapping before unifying reads or writes.
4. Keep `RecordingCoordinator` as the only Product cross-recording writer.
5. Preserve Training Center history until an explicit migration proves semantic
   equivalence and rollback.
6. Keep Knowledge content, Player identity, Coach decisions, Analytics and
   Simulation under their accepted owners.
7. Characterize fixed targets, code generation, active-session concurrency and
   partial exercise recovery before changing behavior.
8. Introduce public ports before adding new direct repository consumers.
9. Fail closed in future versioned adapters while retaining existing data.
10. Do not modify frozen capability/runtime contracts for Product convenience.

## Verification

- Inventory covers ownership, API, repositories, persistence, services,
  providers, UI/routes, execution, dependencies and overlap.
- Existing concepts are separated from genuine gaps.
- Existing Product Training characterization tests: 7/7.
- Full app regression: 1184/1184.
- Knowledge package regression: 75/75.
- Foundation freeze: 76/76.
- Architecture Fitness: 133 existing violations, 0 new.
- Analyzer: no errors; unchanged repository baseline of 62 lint infos.
- `git diff --check`: clean.
- No Product code, schema, tests, UI, runtime or framework was changed.
- Protected generated artifacts are unchanged.
- Diff is limited to the exact E5 documentation allowlist.

## Repository State

Product Owner accepted E5 on 2026-07-24 and authorized repository commit and
push without implementation changes.

## Accepted Product Policies

- Current dual Training persistence is accepted. No merge, migration,
  replacement or implicit convergence is authorized.
- There is exactly one semantic Training aggregate. Compatibility adapters are
  allowed; a third aggregate is prohibited.
- `RecordingCoordinator` remains the only Product recording owner and Training
  must never bypass it.
- Legacy Training Center remains a valid bounded context until an explicit
  migration milestone is approved.
- Knowledge owns authored drills; Training owns execution. This ownership
  separation remains frozen.
