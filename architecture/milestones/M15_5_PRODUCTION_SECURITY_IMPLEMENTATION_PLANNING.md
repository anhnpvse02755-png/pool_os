# M15.5 Production Security Implementation Planning

**Status:** Accepted; Closed
**Date:** 2026-07-22

## Objective

Define implementation planning for accepted M14.4 security governance using
accepted M15.2 topology and M15.3 evidence custody. No security mechanism,
provider, protocol, credential store, cryptography or runtime code is added.

## Invariants

- Identity, authentication and authorization are separate, environment-bound
  decisions; default access is denied.
- Humans, workloads, releases, recovery and providers use distinct identities.
- Secrets and private key material never enter source, artifacts, logs, domain
  facts, AI inputs or client-readable configuration.
- Security controls cannot grant domain authority or bypass public ports.
- Missing owner, identity, policy, evidence, revocation or rollback fails closed.

## Implementation Units

| Unit | Planned responsibility | Owner |
|---|---|---|
| Identity inventory | Eight M14.4 identity classes, lifecycle and ownership | Security/identity owner |
| Authentication boundary | Assurance, session, renewal and revocation per surface | Security/Application/Platform |
| Authorization policy | Subject/action/resource/purpose/environment decisions | Resource owner/Security |
| Privileged access | Time-bound elevation, separation and audit | Security/Operations |
| Secret lifecycle | Request, approve, issue, distribute, rotate, revoke, verify | Security/Platform |
| Key governance | Purpose separation, custody, use, rotation and retirement | Security |
| Certificate governance | Identity/scope/issuer/validity/revocation inventory | Security/Platform |
| Data protection | Four-class field/flow policy and boundary protection | Domain/Security |
| Audit evidence | Attributable access, policy, lifecycle and exception records | Security/Operations |
| Compliance mapping | Obligation-to-control/evidence/gap/owner mapping | Compliance/Security |

## Implementation Sequence

Bind candidate/topology -> classify identities/data/resources -> freeze policy
schemas -> plan identity lifecycle -> authentication -> authorization ->
privileged access -> secret/key/certificate lifecycle -> data protection ->
audit/evidence -> compliance mapping -> isolated verification -> bounded rollout
and rollback -> accepted M15.6 handoff.

No later unit may use an earlier unit before its owner, denial semantics,
evidence and revocation/rollback are accepted.

## Authentication And Authorization Planning

Future adapters remain provider-neutral and expose immutable request/decision
records binding identity class, environment, purpose, resource, action, policy
version, outcome, reason class, time/expiry and evidence identity. Authentication
success never implies authorization. Cross-environment, stale, ambiguous or
undeclared claims fail closed.

## Secret, Key And Certificate Planning

Future lifecycle records store metadata and evidence, never protected values.
They bind owner/custodian, environment, purpose, consumer, issuance, activation,
rotation, expiry, revocation, compromise response and removal validation.
Signing, encryption, authentication and wrapping purposes remain distinct.
Algorithms, protocols, KMS/HSM, CA and storage products are deferred.

## Data Protection Planning

Public, Internal, Confidential and Restricted classifications apply to fields
and flows. Derived data inherits the highest source classification unless an
approved transformation proves otherwise. Future boundary plans state
confidentiality, integrity, termination/plaintext exposure, key authority,
failure behavior, retention and audit without selecting cryptography.

## Evidence Classes

| Evidence | Minimum scope | Owner |
|---|---|---|
| Identity lifecycle | Principal, owner, environment, status and review | Identity owner |
| Authentication decision | Surface, claim class, policy, result and expiry | Security/Application |
| Authorization decision | Subject/action/resource/purpose/policy/result | Resource owner |
| Privileged session | Authority, scope, reason, time, actions and closure | Security/Operations |
| Secret/key/certificate lifecycle | Metadata, custody, rotation/revocation outcomes | Security/Platform |
| Data-boundary assessment | Classification, flow, control intent, result and gaps | Domain/Security |
| Security test/rehearsal | Candidate/topology scope, method class, result, remediation | Security |
| Incident/exception | Timeline/risk/authority/compensation/expiry | Security/PO |
| Compliance mapping | Obligation, applicability, control, evidence, gap and owner | Compliance |

Evidence is append-only, candidate-bound and redacted.

## Ownership RACI

Product Owner accepts product risk/exceptions; Security owns trust/policy and
security evidence; Platform owns infrastructure/workload identity realization;
Application owns enforcement at public application boundaries; domains own
data classification and resource policy; Operations owns incident/evidence
custody; Compliance/Privacy owns applicability interpretation.

## Rollout And Verification

Future rollout progresses schema/policy validation, isolated identity/policy
simulation, integration boundary verification, RC topology, bounded production
enablement and M15.6 handoff. Verification covers default denial, exact identity
and environment binding, separation of duties, lifecycle/expiry/revocation,
classification, redaction, audit completeness, incident/exception behavior and
rollback. M15.5 implements no tests or controls.

## Rollback

Rollback revokes candidate authority, disables integrations, restores a named
compatible policy/lifecycle identity, preserves audit/incident evidence and
validates removal of obsolete access. Unknown compromise or incomplete
revocation blocks rollback completion and downstream handoff.

## Fail-Closed Gates

Block future implementation or rollout without exact candidate/topology,
identity/resource/data inventories, owners, default-deny policy, lifecycle,
revocation, evidence, audit, incident/exception, compliance, compatibility,
rollback and verification plans. Tool availability is not security readiness.

## Acceptance Criteria

- Identity/authentication/authorization, secrets/keys/certificates, data
  protection, evidence, ownership, compliance, rollout, rollback, verification
  and fail-closed gates are explicit.
- No IAM/OAuth/OpenID/JWT/TLS/certificate/KMS/HSM/crypto/auth implementation,
  secret storage, cloud selection, runtime/production source, CI/CD, automation,
  ADR, contract or extra planning document is introduced.
- Frozen and accepted artifacts remain unchanged; only this file and MEMORY.md
  change.

## Engineering Evidence

- Planning inventory: 10 implementation units and 9 evidence classes with
  explicit rollout, rollback, verification and fail-closed governance.
- Full app regression: 881/881 tests passed.
- Knowledge package regression: 75/75 tests passed.
- Protected M3-M13 freeze regression: 44/44 tests passed.
- Architecture Fitness: 133 existing violations, 0 new violations.
- `git diff --check`: clean.
- Worktree: exactly this planning artifact and `MEMORY.md`.
- Frozen, accepted, generated, production and publication artifacts: unchanged.

## Product Owner Decision

Accepted and closed on 2026-07-22. M15.6 Production Performance & Capacity
Implementation Planning is authorized next as planning-only work.
