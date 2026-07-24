# I7 AI Coach MVP

Status: Accepted; Closed

Date: 2026-07-24

## Objective

Deliver the first Product-level Coach session and structured conversation flow
on the accepted Coach capability/runtime and execution framework. I7 does not
integrate a real AI provider or add another framework abstraction.

## Execution Flow

```text
CoachOutput
  -> structured user intent
  -> CoachConversationService
  -> P6 Coach capability compatibility preflight
  -> P8 Coach capability runtime bootstrap
  -> P9 CommandExecutor
  -> immutable CoachConversationTurn
  -> in-memory session transcript
```

## Implemented Behavior

- Adds three bounded conversation intents: next action, player level and Coach
  data coverage.
- Renders quick actions and an append-only in-memory transcript in the existing
  Coach screen.
- Returns only localization keys, metrics, evidence and action bindings already
  present in `CoachOutput`.
- Preserves the existing Knowledge action navigation when a response contains
  an accepted `CoachAction` binding.
- Allows the current ephemeral transcript to be cleared without changing any
  persisted domain data.
- Serializes submissions and fails visibly if command execution fails.

## Ownership And Reuse

- Existing Coach Brain remains the sole owner of coaching decisions, priority,
  confidence and next-action selection.
- The I7 application service owns Product conversation traversal only.
- P6/P8 perform Coach capability compatibility preflight.
- P9 executes the private feature-local command and handler.
- Existing AI Session, Adapter, Capability Registry and deterministic stub
  provider remain unchanged. I7 creates no second provider abstraction.
- Conversation state is session-local presentation state. No repository,
  database, schema, migration or persistence path is introduced.

No LLM, prompt, prose generation, ranking, recommendation, framework, runtime,
contract, registry, bus, DI container, service locator, reflection, discovery,
network, persistence or cross-domain business behavior was added.

## Verification

- Focused I7 tests: 5/5.
- Focused analyzer: clean.
- Focused formatter and `git diff --check`: clean.
- Full app regression: 1156/1156.
- Knowledge package regression: 75/75.
- Foundation freeze: 76/76.
- Architecture Fitness: 133 existing violations, 0 new.
- Dependency and prohibition scans: clean.
- Generated Architecture Fitness health output restored to baseline.
- Protected Foundation M1-M22, P6-P9, Knowledge, persistence, schema and
  production artifacts are unchanged.
- Diff is limited to the exact I7 allowlist.

## Scope Confirmation

I7 is a concrete Product feature over frozen contracts. It does not duplicate
P1-P9 ownership and does not activate a real AI provider.

## Repository State

Product Owner accepted I7 on 2026-07-24 and authorized repository commit and
push without redesign.
