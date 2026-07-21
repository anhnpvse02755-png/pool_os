# ADR-004: M5 AI Integration Layering And Sequencing

**Status:** Accepted

**Date:** 2026-07-21

**Owners:** Product Owner, Architecture

**Supersedes:** None

**Superseded by:** None

## Context

M3 freezes deterministic Coach and AI boundaries. M4 freezes the Intelligence
loop and AI Runtime Activation Gate. M5 is the first phase allowed to add real
AI behavior, so layering, sequencing, safety, memory, tool, Provider, and
provenance decisions are required before implementation.

## Decision

Sequence M5 as Prompt Assembly, Response Processing, Tool Invocation,
Conversation Memory, Provider Runtime Integration, Safety Enforcement, AI
Observability, and Production Activation. Safety constraints apply throughout;
M5.6 centralizes their production enforcement.

AI is an optional consumer of an activated AISession. Provider code is
infrastructure. Provider output and Memory are untrusted derived data. Tools
cross a deterministic allowlisted gateway. AI cannot write deterministic
source-of-truth state. Vision remains deferred and may later enter only as an
Evidence producer.

This ADR authorizes planning only until Product Owner acceptance.

## Normative Authority

```yaml
constitution:
  version: 1.4.0
  sections:
    - "Section 4: Domain Ownership"
    - "Section 5: Dependency Rules"
    - "Section 6: Contract Constitution"
    - "Section 14: Decision Trace and Alternatives"
    - "Section 17: Explicit Prohibitions"
    - "Section 20: Governance and Amendments"
parentAdrs:
  - ADR-003
contracts:
  - id: m3.foundation.baseline
    version: 1.0.0
  - id: m4.foundation.baseline
    version: 1.0.0
```

## Architecture Evidence Plan

```yaml
contractTests:
  - path: architecture/milestones/m3_freeze/proof_record.json
    status: retained
  - path: architecture/milestones/m4_freeze/proof_record.json
    status: retained
architectureTests:
  - ruleId: domain_dependency
    status: active
  - ruleId: ai_boundary
    status: planned-for-M5.1
integrationTests: []
productionSignals:
  - metric: ai_request_cost_latency_safety
    owner: Product Owner / Architecture
    plan: Define provider-neutral budgets and safety signals before M5.5.
healthReports:
  - path: build/architecture/health.json
```

## Evidence Status

As of 2026-07-21, M3 and M4 freeze gates are Accepted. M4 records 8 contracts,
55 public symbols, 10 edges, 0 cycles, clean app tests 371/371, Knowledge 75/75,
and Architecture Fitness 133 existing / 0 new. M5 has no production evidence.

## Alternatives Considered

- Provider integration first: rejected because it couples semantics to an SDK.
- Tools and Memory inside adapters: rejected because authorization, retention,
  and audit policy would be hidden in infrastructure.
- Direct AI updates to Coach/Player state: rejected because replay and ownership
  would break.
- Vision in M5.0: rejected because it requires separate Evidence governance.

## Consequences

The sequence preserves replaceability, deterministic authority, auditable tool
use, and rollback. It adds lifecycle, safety, observability, and approval work
before production activation.

## Compatibility and Migration

M5.0 changes no runtime contract. Future contracts must be additive and bind to
frozen M3/M4 identities. Incompatible changes require explicit governance,
versioning, adapters, and rollback evidence.

## Security, Privacy, and Provenance

Provider output, Prompts, Memory, retrieved content, and tool results are
untrusted. Data minimization, consent, retention, erasure, secret isolation,
human override, and model/Provider/Prompt/policy provenance are mandatory.
Prose remains subordinate to structured Decision Trace.

## Enforcement

- Reject production AI code before ADR-004 and M5.0 are Accepted.
- Reject AI access bypassing AISession and Activation Gate.
- Reject Provider adapters containing Coach, Learning, or tool authorization.
- Reject direct AI writes to deterministic source-of-truth state.
- Run architecture fitness and M3/M4 baseline checks per capability.

## Exceptions

None.
