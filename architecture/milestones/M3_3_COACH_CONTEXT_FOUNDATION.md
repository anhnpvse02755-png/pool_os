# M3.3 Coach Context Foundation

**Status:** Accepted; Closed

**Date:** 2026-07-21

**Implementation commit:** `8f6b98a`

## Executable Scope

M3.3 creates one versioned API boundary for future AI consumers:

1. `CoachContextContract` contains exactly `PlayerProfileContract`,
   `PlayerProgressSnapshot`, and `ExperienceSnapshot`.
2. `CoachContextVersionBinding` records Profile, Progress, and Experience
   contract versions plus Knowledge version and digest.
3. The context has a deterministic SHA-256 digest over its version binding and
   complete projected inputs.
4. `CoachContextBuilder` is an Intelligence application service that accepts
   projections only. It has no Evidence, Event Log, Learning Runtime,
   persistence, or framework dependency.
5. The accepted M3.1 `CoachInputContract` remains unchanged; M3.3 introduces a
   new canonical AI context boundary without breaking the earlier contract.

The executable flow is:

```text
Evidence
  -> Learning Runtime
  -> Player Progress
  -> Experience Snapshot
  -> Coach Context
  -> future AI consumer
```

## Compatibility And Failure Semantics

- Profile, Progress, and Experience must identify the same player.
- Experience must bind the exact Player Progress digest supplied to the
  context; stale Experience is rejected.
- Progress and Experience must bind the same Knowledge version and digest.
- Version bindings are explicit contract data and participate in context
  identity.
- Rebuilding from equivalent projections produces identical JSON and digest.
- New projections create a new context without mutating an older context.

## Architecture Invariant

`CoachContextContract` is the API boundary for future AI capabilities. AI
consumers must not bypass it to read Evidence, Event Log, Learning Runtime, or
internal Player/Experience projection implementations. M3.3 establishes the
contract and builder; enforcement against future AI modules must be added when
the first AI consumer is introduced.

## Verification

- Coach Context focused tests: 6/6.
- App regression: 242/242.
- Knowledge package regression: 75/75.
- Architecture Fitness: 133 existing / 0 new.
- M3.3 focused analyzer: no issues.
- Constitution, Reference Behavior, Golden Fixtures, production Knowledge,
  publication artifacts, and all frozen M2 digests are unchanged.

## Explicit Non-Claims

M3.3 does not implement:

- AI, LLM, recommendation, ranking, planning, or Coach policy;
- persistence, caching, or context storage;
- raw Evidence/Event Log/Learning Runtime access;
- Vision or Simulation integration;
- Experience UI integration;
- production activation or Knowledge publication changes.

## Product Review

Product Owner Nguyễn Phú Việt Anh accepted M3.3 on 2026-07-21. The next
authorized capability is M3.4 - Coach Decision Engine Foundation.
