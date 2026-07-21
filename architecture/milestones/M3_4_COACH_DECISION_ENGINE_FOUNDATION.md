# M3.4 Coach Decision Engine Foundation

**Status:** Engineering Complete; Product Review Pending

**Date:** 2026-07-21

**Implementation commit:** `7edc228`

## Executable Scope

M3.4 creates a deterministic semantic business decision before any AI renderer:

- `CoachDecisionContract` v1 with action, target, structured reasons, trace,
  alternatives, version binding, stable ID, effective time, and digest.
- `CoachDecisionBuilder` consumes only accepted `CoachContextContract`.
- Policy order is persistent correction, then unmastered Technique, then
  readiness for a future Planner to select the next capability.
- Ties use canonical Knowledge ID order and retain non-selected alternatives;
  no score or AI ranking is introduced.
- A readiness decision deliberately has no target because Coach Context does
  not contain a Knowledge planning graph.

## Semantic Actions

1. `correctMistake`: a persistent Mistake exists.
2. `practiceTechnique`: no persistent Mistake exists and a tracked Technique is
   not mastered.
3. `readyForNextCapability`: all tracked Techniques are mastered. This does not
   select or invent the next Knowledge ID.

All output is structured. Natural-language advice, prompts, LLM calls, and UI
rendering are outside the decision boundary.

## Determinism And Auditability

- Decision identity binds Coach Context digest, Knowledge identity, policy
  version, reasons, trace, and alternatives.
- Effective time comes from the latest Experience timeline record, not the
  system clock.
- Equivalent Coach Context produces identical decision JSON and digest.
- Trace stages are contiguous: context validation, candidate collection,
  selection, and semantic decision emission.

## M3.2 Defect Correction

M3.4 exposed an accepted M3.2 identity defect: multiple initial Technique
decisions shared `decision.initial`, causing derived Experience event collisions.
Event identity now binds both Knowledge ID and Decision ID. A multi-Technique
regression test proves unique initial Experience events. This correction does
not change Evidence, Learning policy, Reference Behavior, or M2 digests.

## Verification

- Coach Decision focused tests: 6/6.
- M3.2/M3.4 combined focused regression: 14/14.
- App regression: 249/249.
- Knowledge package regression: 75/75.
- Architecture Fitness: 133 existing / 0 new.
- Focused analyzer: no issues.
- Constitution, Golden Fixtures, Reference Behavior, production Knowledge,
  publication artifacts, and frozen M2 digests are unchanged.

## Explicit Non-Claims

M3.4 does not implement Planner target selection, recommendation scoring, ML,
LLM, prompts, prose, persistence, Vision, Simulation, UI integration, or
production activation.

Product Owner review must decide `Accepted`, `Needs Changes`, or `Rejected`.
