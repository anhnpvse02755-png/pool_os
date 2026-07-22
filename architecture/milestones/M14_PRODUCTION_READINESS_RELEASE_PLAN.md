# M14 Production Readiness & Release Plan

**Status:** Planning Baseline; Pending Product Owner Review
**Date:** 2026-07-22

## Release Architecture And Topology

Plan four isolated stages: local development, integration, release candidate,
and production. Deployment units remain a modular monolith unless operational
evidence justifies extraction. Define ingress, application runtime, persistence,
artifact storage, telemetry, backup, and external AI/provider trust boundaries
without selecting products in M14.0. Production identity, configuration, and
secrets must be environment-scoped and auditable.

## Operational Ownership

| Area | Accountable owner | Required evidence before release |
|---|---|---|
| Release decision | Product Owner | Signed readiness record |
| Runtime and deployment | Platform owner | Deployment/rollback rehearsal |
| Application behavior | Application owner | Acceptance suite and error budget |
| Knowledge publication | Knowledge owner | Current publication proof |
| Evidence/privacy | Evidence owner | Retention, consent, restore audit |
| AI providers | Intelligence owner | Capability/version compatibility evidence |
| Security | Security owner | Threat and dependency gate report |
| Incident response | Operations owner | On-call and incident exercise record |

## Production Readiness Checklist

- Immutable release identity links source revision, build, configuration schema,
  Knowledge release, runtime contracts, and migration set.
- Environment configuration is validated fail-closed; secrets never enter logs,
  artifacts, source control, or client-readable configuration.
- Database/schema compatibility, capacity, retention, privacy, support, incident,
  and dependency ownership are approved.
- Release candidate is promoted unchanged; production is not rebuilt from a
  different source or dependency set.

## Monitoring And Alerting Strategy

Define SLIs for availability, request success, latency, startup success,
dependency/provider health, persistence errors, publication compatibility, and
queue/backlog age where applicable. Alerts must be actionable, severity-based,
deduplicated, routed to a named owner, linked to a runbook, and tested. Logs,
metrics, and traces must carry release/runtime correlation IDs without Evidence
payloads, secrets, or unnecessary player data.

## Backup, Restore, And Disaster Recovery

Classify each store as source, event history, projection, cache, or artifact.
Set RPO/RTO per class. A backup is not accepted until a clean-environment restore
proves integrity, access controls, schema compatibility, and application-level
readability. Plan regional/site loss, provider loss, credential compromise, and
corrupted release recovery. Record restore drills and unresolved gaps.

## Rollback Strategy

Prefer immutable release rollback and forward-only data repair. Every rollout
stage needs abort thresholds, last-known-good identity, configuration rollback,
provider disablement, migration compatibility window, and owner. Never roll
back by rewriting Evidence or published Knowledge history.

## Security Readiness

Require threat-model review, least privilege, secret rotation, dependency/SBOM
review, artifact signing/provenance, encryption policy, audit logging, privacy
and retention verification, abuse/rate controls, incident contacts, and AI data
boundary verification. Critical findings block release; exceptions must be
owned, expiring, and approved.

## Performance Readiness

Define representative startup, steady-state, burst, degraded-provider, and
recovery workloads. Establish budgets for latency, throughput, memory, CPU,
storage growth, battery/client impact, and provider cost. Tests must identify
saturation points and graceful-degradation behavior. Results are release-bound
and cannot be reused after material topology or contract changes.

## Acceptance Test Matrix

| Gate | Minimum pass condition |
|---|---|
| Contract/freeze | M3-M13 protected suites pass |
| Functional | Critical user journeys and failure states pass |
| Migration/restore | Forward migration and clean restore pass |
| Security/privacy | No unaccepted critical issue; retention/consent verified |
| Performance | All budgets pass at target load with capacity margin |
| Operations | Dashboards, alerts, runbooks, on-call and incident exercise pass |
| Rollback | Staged rollback rehearsal restores last-known-good service |
| Product | Product Owner signs release candidate evidence record |

## Production Rollout Sequence

1. Freeze a release candidate and evidence bundle.
2. Deploy to integration; run contracts, migrations, security and recovery gates.
3. Promote unchanged to a production-like stage; run load and rollback rehearsal.
4. Begin production canary with explicit observation window and abort thresholds.
5. Expand progressively only while health and error-budget gates pass.
6. Complete rollout, retain evidence, and conduct post-release review.

Any failed or missing mandatory gate stops promotion. Emergency exceptions do
not rewrite the evidence record and require explicit Product Owner and owner
approval.
