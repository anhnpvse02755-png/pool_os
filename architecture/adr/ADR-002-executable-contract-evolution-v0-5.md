# ADR-002: Evolve Executable Contracts for Sprint 0.5

**Status:** Accepted  
**Date:** 2026-07-20  
**Owners:** Pool OS architecture  
**Supersedes:** None  
**Superseded by:** None

## Context

Sprint 0 proved one Stop Shot path but exposed single-entry Knowledge, unversioned
Evidence storage records, and prose Decision Traces. Sprint 0.5 must support
multiple Knowledge shapes and preserve already-written Sprint 0 Evidence without
moving inference into Evidence or Experience.

## Decision

- Knowledge packs use a discriminated union with common entry metadata and
  `TechniquePayload`, `MistakePayload`, or `ConceptPayload`.
- Dispatch uses payload type and declared capability, never a Knowledge ID.
- Evidence batches and their contained events carry independent schema versions.
- New batches have a content digest. Sprint 0 batches are explicitly upcast to
  Evidence batch schema v1 when read.
- Decision Trace contains typed reason codes, parameters, and policy versions.
  Localized prose is an Experience projection and is not persisted reasoning.

Domain ownership, Outcome semantics, append-only Evidence, replay, provenance,
and the rule that Experience does not infer remain unchanged.

## Normative Authority

```yaml
constitution:
  version: 1.4.0
  sections:
    - "Section 4 - Domain Ownership"
    - "Section 6 - Contract Constitution"
    - "Section 7 - Versioning and Provenance"
parentAdrs: []
contracts:
  - id: knowledge.executable-pack
    version: 0.5.0
  - id: evidence.batch
    version: 1.0.0
  - id: intelligence.decision
    version: 0.5.0
```

## Architecture Evidence Plan

```yaml
contractTests:
  - path: packages/billiard_knowledge/test/knowledge_compiler_v0_test.dart
    status: active
architectureTests:
  - ruleId: domain_dependency
    status: active
integrationTests:
  - path: app/test/stop_shot_vertical_slice_test.dart
    status: active
productionSignals:
  - metric: not_available
    owner: Pool OS architecture
    plan: Add event upcast and decision reason coverage before production rollout.
healthReports:
  - path: build/architecture/health.json
```

## Evidence Status

Verified locally on 2026-07-20. Compiler tests cover three payload kinds,
determinism, duplicate IDs, dangling references, review state, and pack tampering.
Runtime tests cover independent versions, digest tampering, unknown event versions,
legacy upcast round-trip, two policies, replay, typed trace, and Experience output.
Architecture fitness passes with 143 known violations and zero new violations.

## Alternatives Considered

**One object with nullable fields:** rejected because invalid combinations become
representable and every consumer must infer the entry shape.

**Version the JSONL file only:** rejected because storage framing and event
semantics evolve independently.

**Persist explanation prose:** rejected because prose is localization output, not
auditable reasoning.

## Consequences

The compiler and runtime can add payload types and policies without ID branches.
Consumers must project typed reasons. Version negotiation is still local and
supports only the versions implemented in Sprint 0.5; unsupported versions fail.

## Compatibility and Migration

Knowledge pack V0 is replaced before ratification and has no persisted consumer.
Decision Trace V0 is migrated atomically across its in-repository consumers and
was not persisted. Existing JSONL Evidence is retained: unversioned Sprint 0
batches are read through a deterministic upcaster and can round-trip as valid v1.

## Security, Privacy, and Provenance

No new player fields are collected. Evidence digests detect accidental or
unauthorized modification but are not signatures. Decision records retain
Knowledge digest/version and policy versions; legacy upcast provenance remains
observable in memory.

## Enforcement

- `dart run tool/knowledge_compiler_v0.dart --check`
- `flutter test test/knowledge_compiler_v0_test.dart`
- `flutter test test/stop_shot_vertical_slice_test.dart`
- `dart run tool/architecture_test.dart`

## Exceptions

None.
