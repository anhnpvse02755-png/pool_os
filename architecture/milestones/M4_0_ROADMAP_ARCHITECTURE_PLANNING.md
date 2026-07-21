# M4.0 Roadmap & Architecture Planning

**Status:** Accepted; Closed

**Date:** 2026-07-21

**Scope:** Planning only. No M4 production implementation is included.

## Objective

Define the Intelligence layer that follows the closed M3 Foundation without
redesigning or bypassing M3 contracts. M4 consumes frozen M3 boundaries and
preserves the dependency direction:

```text
Knowledge -> Learning Runtime -> Coach -> AI
```

The Framework-First order remains authoritative:

```text
Framework -> Freeze -> Knowledge expansion -> Application -> Internal Alpha -> Beta
```

## M3 Reuse Boundary

M3 is closed and frozen. M4 may consume its public Player, Experience, Coach,
Decision, Lifecycle, Plan, Recommendation, Execution, AISession, Response,
Capability Registry, Provider, and Orchestration boundaries, plus their
provenance, version, compatibility, digest, replay, immutable, and append-only
invariants.

M4 must not mutate M3 history, replace M3 ownership, import persistence or
compiler internals, or make AI a source of deterministic domain truth.

## Capability Inventory

| ID | Capability | Objective | Inputs | Outputs | Dependencies | Reused M3 foundations |
| --- | --- | --- | --- | --- | --- | --- |
| M4.1 | Coach Planning Engine | Turn resolved context and lifecycle state into a deterministic coaching plan. | Coach Context, Decision History, published Knowledge projections | Planning result/projection | M3.3-M3.6, Learning Runtime | Context, Decision, Lifecycle, Plan |
| M4.2 | Adaptive Recommendation Engine | Select an eligible next technique or correction under policy. | Coach Context, Coach Plan, Decision History | Recommendation projection | M4.1, M3.7, eligibility projection | Context, Plan, Recommendation |
| M4.3 | Intelligence Trace and Explanation Foundation | Establish auditability before session and adaptive reasoning. | Planning and recommendation policy results, provenance | Structured trace/explanation projection | M4.1-M4.2, Constitution Section 14 | Decision Trace, provenance, digests |
| M4.4 | Training Session Builder | Compose traced recommendations into a bounded training session. | Coach Plan, Recommendations, trace, player readiness | Session plan | M4.2-M4.3, M3.8 | Plan, Recommendation, Execution, Trace |
| M4.5 | Session Execution Coordinator | Coordinate accepted, deferred, and completed records and expose traced progress. | Session plan, Execution Records, trace | Session progress projection | M4.4, M3.8 | Execution lifecycle, provenance, Trace |
| M4.6 | Outcome Evaluation Projection | Convert structured outcomes into deterministic, traced progress and mastery projections. | Evidence/Outcome public ports, execution records, trace | Outcome and progress projections | M4.5, Knowledge and Learning Runtime | Player Model, Experience, Decision Trace |
| M4.7 | Coach Adaptation Loop | Re-plan from measured outcomes while preserving append-only history and trace continuity. | Progress projection, Coach Context, history, trace | Next-cycle plan/recommendation request | M4.1, M4.3, M4.6 | Lifecycle, Plan, Recommendation, Orchestration, Trace |
| M4.8 | AI Runtime Activation Gate | Introduce a reviewed provider/capability activation path after deterministic Intelligence is proven. | AISession, registered capability, provider result | Bound Coach Response | M4.7, M3.9-M3.13 | AISession, Response, Registry, Provider, Orchestration |

Expected future contracts are planning references only. M4.0 creates and
approves no contract.

## Capability Dependency Graph

```text
M3 Foundation
    |
    v
M4.1 Coach Planning Engine
    |
    v
M4.2 Adaptive Recommendation Engine
    |
    v
M4.3 Intelligence Trace and Explanation Foundation
    |
    v
M4.4 Training Session Builder
    |
    v
M4.5 Session Execution Coordinator
    |
    v
M4.6 Outcome Evaluation Projection
    |
    v
M4.7 Coach Adaptation Loop
    |
    v
M4.8 AI Runtime Activation Gate
```

The graph is capability-level, acyclic, and deterministic. Trace is established
before session composition so all subsequent reasoning is auditable and
replayable. M4.6 consumes
Evidence and Outcome through public ports; it does not make Evidence an AI
input. M4.8 is gated last so deterministic Coach use remains useful without an
AI provider.

## Architecture Layer Map

```text
Published Knowledge
        |
Learning Runtime and Evidence ports
        |
Player Model / Experience Projections
        |
Coach Context and Decision Lifecycle (M3, frozen)
        |
M4 Planning -> Recommendation -> Trace -> Session -> Evaluation -> Adaptation
        |
Structured Decision Trace and provenance
        |
AISession -> Capability Registry -> Provider -> Coach Response (M3 boundary)
```

Ownership rules:

- Learning Runtime remains the sole owner of prerequisite, unlock, availability
  and dependency resolution.
- Coach capabilities own policy and orchestration, not raw Evidence storage or
  Knowledge compilation.
- Execution remains append-only and never mutates Recommendation.
- AI remains a consumer of AISession and cannot read Evidence, Event Log,
  Player internals, Coach internals, or Decision History directly.
- AI activation is optional. It cannot bypass Planning, Recommendation, or
  Execution and cannot become a source of truth for the deterministic pipeline.
- Experience remains a projection/command surface and does not infer mastery
  or recommendations.

## Dependency and Reuse Analysis

Every M4 capability must document prerequisite public ports, downstream
consumers, protected artifacts at risk, and reused M3 contracts before its
implementation starts:

```text
M4.1: Context + Decision + Lifecycle + Plan
M4.2: Context + Plan + Recommendation + Eligibility projection
M4.3: Trace + provenance + compatibility + digest
M4.4: Plan + Recommendation + Execution + Trace
M4.5: Execution lifecycle + provenance + Trace
M4.6: Player + Experience + Evidence/Outcome ports + Trace
M4.7: Planning + Recommendation + Execution + Orchestration + Trace
M4.8: AISession + Registry + Provider + Orchestration + Response
```

No capability may duplicate an M3 projection, resolve a graph owned by Learning
Runtime, or introduce a second AI boundary.

## Invariants

M4 reuses existing M3 invariants; it adds none in the planning phase:

- immutable public contracts;
- append-only lifecycle/history;
- deterministic canonicalization and digest;
- replay produces the same state and provenance;
- compatibility failures reject loudly;
- no hidden fallback or provider-specific business logic;
- structured explanation is grounded in Decision Trace;
- AI only reads AISession and returns through Coach Response.
- AI Runtime Activation is an optional consumer of the deterministic pipeline;
  it cannot bypass Planner, Recommendation, or Execution and is never a source
  of truth.

## Engineering Sequencing

1. M4.1 establishes deterministic planning policy over the frozen boundary.
2. M4.2 depends on an explicit plan and keeps eligibility ownership in Runtime.
3. M4.3 establishes auditability before any session or adaptive reasoning.
4. M4.4 and M4.5 make a traced training cycle executable without AI.
5. M4.6 supplies measured outcomes before adaptation can be meaningful.
6. M4.7 closes the deterministic, traced Coach feedback loop.
7. M4.8 is an activation gate, not a prerequisite for deterministic Coach use.

Each capability requires separate Product Owner review and an executable DoD
before implementation. This planning document alone authorizes none of them.

## M4 Definition of Done Template

Each milestone must provide an owner and public-port map; immutable/versioned
contracts only when a contract gap is proven; deterministic replay and digest
tests; compatibility and fail-closed tests; architecture fitness with no new
violations; protected artifacts and Golden Fixtures unchanged; app and
Knowledge regression evidence where affected; and an explicit out-of-scope
statement.

## Explicitly Out of Scope

- M4 production implementation, new contracts, runtime metadata, Planner,
  Recommendation, AI, UI, persistence, API, or network code;
- LLM, prompt engineering, RAG, memory, tool calling, Vision, or production
  provider activation;
- changes to M3 frozen contracts, Constitution, Knowledge publication,
  Reference Behavior, Golden Fixtures, or protected artifacts.

## Review State

Product Owner accepted the revised planning package on 2026-07-21. M4.0 is
closed. M4.1 is Ready to Start under its separately reviewed executable scope;
the repository still contains planning evidence only until implementation begins.
