# Product Owner Strategic Direction

**Status:** Authoritative

**Scope:** Long-term Pool OS platform roadmap and release governance

## Primary Goal

Pool OS is an Operating System / Intelligence Platform for billiards, not a
conventional mobile application. The first objective is to complete and freeze
the platform architecture. Product release is intentionally delayed until the
framework is stable.

## Framework-First Order

The implementation order is fixed:

1. Complete the framework.
2. Freeze the architecture.
3. Expand Knowledge.
4. Build the application/product layer.
5. Run Internal Alpha.
6. Run Public Beta.

This order must not be reversed without explicit Product Owner direction.

## Framework Freeze

Framework Freeze requires complete, compatible, replayable, and deterministic
capabilities across:

- Knowledge Runtime, Compiler, and Publication;
- Learning Runtime, Player Model, Experience Projection, and Coach Runtime;
- Decision Engine, Planning, Recommendation, and Execution;
- AI Session and AI Response boundaries;
- future AI runtime contracts, replay, deterministic execution, compatibility,
  versioning, Evidence, provenance, projections, and digests.

After Framework Freeze:

- domain, runtime, compiler, publication, Coach, and AI boundary contracts are
  frozen;
- changes are limited to critical defects or additive compatible extensions;
- new features must consume and extend existing contracts rather than redesign
  them.

## Dependency Priority

Knowledge quality is the foundation. AI must never compensate for missing
Knowledge. The dependency direction is:

```text
Knowledge
    -> Runtime
        -> Coach
            -> AI
```

AI Vision is deferred beyond Framework Freeze. When introduced, Vision will be
an Evidence producer:

```text
Vision -> Evidence -> Learning Runtime -> Coach -> Recommendation
```

Vision is not a reasoning engine.

## Application And Release Policy

The application layer follows framework completion. Flutter UX, authentication,
sync, dashboards, reports, analytics, and session/training/Coach UI must consume
stable contracts and must not drive architecture decisions.

There is no early public beta. Internal Alpha begins only after Framework
Freeze. Feedback may change Knowledge, policy, Recommendation, and UX, but must
not destabilize the platform architecture.

## Prohibitions

- Do not ship an incomplete architecture to obtain early feedback.
- Do not introduce temporary shortcuts.
- Do not redesign frozen contracts without the required governance process.
- Do not bypass Knowledge publication, replay, or deterministic execution.
- Do not add LLM, prompt, chat, or Vision behavior before its approved
  foundation and boundary exist.

## Current Roadmap Position

M3.1 through M3.13 and M3 Foundation Freeze & Architecture Validation are
closed. M4.0 Roadmap & Architecture Planning is closed and ADR-003 is
Accepted. M4.1 Coach Planning Engine Foundation is closed. The next governed
capabilities M4.1 Coach Planning Engine Foundation and M4.2 Adaptive
Recommendation Engine Foundation are closed. The next governed capability is
M4.3 Intelligence Trace and Explanation Foundation. It must preserve frozen M3
contracts and receive its own Product Owner review before repository closure.
