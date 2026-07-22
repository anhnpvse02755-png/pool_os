# M18.5 Platform Integration Security, Privacy & Trust Planning

**Status:** Accepted; Closed
**Date:** 2026-07-22

## Objective

Define security, privacy and trust governance for future platform integration.
M18.5 is planning only. It introduces no runtime contract, cryptographic,
authentication/authorization, Flutter, infrastructure, networking, persistence,
AI, CI/CD, deployment, monitoring, ADR, Product or frozen-artifact change.

## Authority And Protected Inputs

Constitution v1.4.0, M17 Foundation Freeze and accepted M18.0-M18.4 identity,
compatibility, evidence and recovery governance remain protected. Security and
Privacy govern controls/risk; data/domain owners retain semantic/data authority;
Architecture assures boundaries; Integration coordinates; Product Owner
authorizes future implementation and acceptance.

## Cross-Domain Trust Model

Trust is an explicit, scoped, expiring claim bound to exact candidate/freeze,
actor/workload/provider, boundary, capability, data class, purpose, interface
version, evidence, owner and authority. Repository access, deployment location,
network adjacency, prior success or provider reputation never implies trust.

| Trust relationship | Required assertion | Owner |
|---|---|---|
| Caller -> public port | Identity class, permitted capability/scope and current authority | Port/domain owner |
| Producer -> consumer | Contract/provenance integrity and compatible failure semantics | Both contract owners |
| Infrastructure -> domain | Adapter identity, least capability and no semantic authority | Platform plus domain owner |
| Provider -> adapter | Provider/result identity, bounded purpose and attributable failure | Adapter/provider owner |
| Evidence custodian -> verifier | Integrity, custody, access purpose and independence | Evidence owner/Quality |
| AI adapter -> AI boundary | AISession-only input and accepted structured output | AI contract owner |
| Operations -> recovery port | Named continuity authority, scope/expiry and retained audit | Domain/recovery owner |
| Repository authority -> closure | PO acceptance and exact commit/push identity | PO/Repository Authority |

## Security Boundary Governance

Every integration boundary declares identity classes, resources/capabilities,
allowed direction, least privilege, trust assumptions, denial/failure semantics,
evidence/audit, exception/expiry, recovery/revocation and accountable owners.
Private persistence/internals are never security surfaces. Infrastructure cannot
grant a domain capability absent public-port and semantic-owner authority.

## Privacy And Data-Handling Governance

| Concern | Governance requirement |
|---|---|
| Purpose | Specific authorized integration purpose; no compatible-but-unrelated reuse |
| Minimization | Only fields required by the public contract/capability cross boundary |
| Classification | Data sensitivity and Evidence/projection/derived status remain explicit |
| Consent/legal basis | Source owner validates before collection/use and retains evidence |
| Retention | Owner, duration/event, archive/deletion constraints and audit are defined |
| Access | Least privilege, role/scope, effective/expiry and denial evidence |
| Redaction/erasure | Attributable event preserves allowable lineage/reference integrity |
| Export/provider | Exact destination/purpose/contract/provider identity and constraints |
| Incident/recovery | Containment authority preserves evidence and domain history |

Raw Evidence, secrets and unnecessary player data are excluded. Derived
projections never replace source consent/retention authority.

## Trust Establishment Lifecycle

```text
requested -> classified -> ownerReviewed -> evidenceVerified
          -> authorized -> active -> revoked/expired/superseded -> retained
```

Each transition appends actor/authority, scope, evidence, predecessor and digest.
Authorization requires current identity/compatibility, boundary/data policy,
positive/negative evidence and no blocking finding. Revocation/expiry takes
precedence; re-establishment creates a new linked trust revision.

## Deterministic Trust Verification

For the same canonical candidate, relationship, boundary, capability, data,
policy and evidence identities, verification returns the same ordered findings,
`trusted`/`untrusted` determination and digest. It checks completeness,
authority/delegation/expiry, least privilege, compatibility, provenance,
purpose/minimization/retention, negative denial cases, recovery/revocation and
independence. No score, implicit inheritance, provider fallback or timeout
approval exists.

## Authorization And Evidence Ownership

Domain/port owners authorize capabilities; data owners authorize purpose/access;
Security/Privacy approves control/risk posture; Architecture validates boundary;
Quality independently verifies; Repository Authority records closure; PO grants
scope and final acceptance. Each evidence record has one custodian and immutable
lineage. No actor can authorize beyond owned scope or self-verify its own claim.

## Trust Failure And Recovery

Fail closed and revoke/hold on unknown/mixed identity, expired/revoked authority,
private edge, excess capability, incompatible contract, stale provenance,
unauthorized purpose/data/provider, missing consent/retention, evidence conflict,
separation-of-duties failure, unresolved incident, unsafe rollback or
nondeterministic verification. Availability pressure does not preserve trust.

Recovery binds failed and last-known-good trust identities, containment,
evidence, owner authority, corrected boundary/data policy, verification,
revocation of obsolete authority and successor linkage. Rollback restores only
verified compatible trust; forward repair is versioned. History is never
rewritten.

## Supersession And Exceptions

Supersession links immutable predecessor/successor trust records and rechecks all
bound identities. Exceptions name violated rule, risk owner, scope, evidence,
compensating control, start/expiry, review and removal; they cannot weaken
constitutional boundaries, authorize private access or self-renew.

## Product Owner Acceptance Gates

Future implementation requires exact mechanism/file scope, accepted
predecessors, current trust/boundary/data inventory, owners and authorization,
deterministic positive/negative evidence, security/privacy review,
revocation/recovery/rollback, no active blocking exception, protected freezes,
Architecture Fitness 0 new, clean diff and explicit PO acceptance before
commit/push. This plan grants none of those mechanisms.

## Definition Of Done

- Eight trust relationships and security boundary governance are explicit.
- Nine privacy/data-handling concerns preserve ownership and minimization.
- Eight trust lifecycle states and deterministic verification are defined.
- Authorization/evidence ownership, recovery, supersession, exceptions and
  fail-closed PO gates are explicit.
- Exactly this milestone and `MEMORY.md` change.
- No crypto/auth/runtime contract, implementation, ADR, Product or frozen
  change.
- Architecture Fitness, protected freezes, generated health and clean diff are
  verified.

## Engineering Evidence

- Planning defines eight trust relationships, nine data-handling concerns and
  eight lifecycle states.
- App regression: 949/949.
- Knowledge package regression: 75/75.
- Protected foundation freezes: 56/56.
- Architecture Fitness: 133 existing violations, 0 new.
- Generated architecture health restored to its protected baseline.
- `git diff --check` is clean and the diff contains exactly this milestone and
  `MEMORY.md`.
