# P1.8 Product Error Model, Recovery & Resilience Planning

**Status:** Accepted; Closed
**Date:** 2026-07-23

## Objective

Define logical Product error, recovery and resilience semantics without
implementing exception handling or operational mechanisms. P1.8 preserves
P1.1-P1.7 and the immutable M22 Foundation Freeze digest
`2086946d208e96093ae6699e36ab82bf174e9ec9630727abbce4691ec8c902fb`.

## Error Principles

- The component that establishes a failed fact owns its authoritative error.
- Product may wrap an error with correlation/context but cannot change its source,
  category, retryability or semantic disposition.
- Domain rejection, dependency failure, transport failure and implementation
  defect remain distinguishable.
- Recovery never manufactures success, weakens validation or changes owner.
- Outcome unknown is reconciled before retry.
- Partial success preserves committed owner results and explicit next actions.
- Error evidence is immutable, minimal, provenance-bound and separately governed.

## Logical Error Envelope

Every Product error envelope contains error semantic ID/version, error instance
ID, category, authoritative source owner, failing use-case/stage, request/query/
interaction identity, correlation/causation, target identity/version where safe,
semantic disposition, retry/recovery classification, committed-step references,
safe user action class, source error/evidence reference, provenance and redaction
classification.

It does not contain secrets, credentials, raw Evidence, provider payloads,
internal objects, stack traces or sensitive draft values. A Product wrapper never
replaces the immutable source error identity.

## Error Taxonomy

| Category | Meaning | Authoritative owner | Default recovery class |
|---|---|---|---|
| boundaryInvalid | malformed/missing canonical input | receiving Experience/Application boundary | correct intent, then new submission |
| unauthenticated | no valid access context | Identity/Security | resolve access/profile |
| unauthorized | valid identity lacks accepted permission | Identity/Security | request different authorized action/context; no retry |
| notFound | owner cannot resolve target | target capability owner | refresh reference or safe exit |
| staleConflict | expected version/state lost concurrency | aggregate/projection owner | re-query and form new intent |
| duplicateMismatch | idempotency identity reused with changed input | Application/aggregate owner | stop; new identity only for new intent |
| incompatible | contract/schema/runtime version unsupported | contract owner | obtain compatible context/version |
| provenanceInvalid | identity/digest/custody binding invalid | source/contract owner | repair at source; no fallback |
| invariantRejected | semantic rule/transition rejected | capability owner | correct intent/state; no blind retry |
| dependencyUnavailable | required public dependency unavailable | dependency owner, propagated by caller | isolate; retry only if declared |
| externalExecutionFailed | accepted provider/external execution failed | adapter/provider boundary | owner-declared new attempt/compensation |
| partial | one or more owner steps committed before later failure | Application orchestration, with source errors | resume/compensate explicitly |
| outcomeUnknown | submission outcome cannot yet be established | Application plus target owner | reconcile same request identity |
| cancelled | accepted cancellation/abandonment disposition | interaction or aggregate owner by stage | no retry unless new intent allowed |
| unexpectedDefect | behavior violates declared contract/invariant | implementation owner | fail closed and escalate |

Unknown categories map only to `unexpectedDefect`; they are never guessed into a
retryable business category.

## Ownership Model

| Responsibility | Owner |
|---|---|
| Source failure classification/evidence | failing capability/Platform/dependency owner |
| Product envelope/correlation and propagation | P1.4 Application service |
| Recovery eligibility semantics | source owner contract plus Application workflow |
| User recovery choice | User through P1.7 interaction |
| User-visible state/action rendering | Experience |
| Retry submission/idempotency | Application service |
| Domain correction/compensation | authoritative aggregate owner |
| Escalation for defect/security/operations | accountable implementation/security/operations owner |
| Error evidence custody/retention | evidence/logical record owner under policy |

Experience cannot declare retryable; Application cannot reclassify an invariant
rejection; a provider cannot own Product recovery policy.

## Propagation Boundaries

Owners return typed source failures through public contracts. Application adds
use-case stage, committed-step and correlation references while preserving source
identity. Experience selects a logical visible state and only recovery actions
declared by the application result. Cross-capability propagation forms a cause
chain of immutable references, not copied/reworded competing errors.

Internal failure detail stops at its owner boundary. Public errors are stable and
safe. A downstream failure cannot retroactively convert an upstream accepted
owner transition into failure.

## Deterministic Recovery Order

1. Stop downstream work and contain the affected interaction/workflow.
2. Preserve authoritative error and already committed owner result references.
3. Classify source, category, affected scope and outcome certainty.
4. If outcome unknown, reconcile the original request/idempotency identity.
5. Refresh access, contract, target and expected-version context as required.
6. Determine allowed recovery from the source contract and workflow state.
7. Obtain user/owner authorization for retry, resume, correction or compensation.
8. Execute exactly one declared recovery command/query in dependency order.
9. Verify owner result and remaining partial state.
10. Render resolved, partial or terminal failure with immutable audit references.

Same error envelope, owner states and authorization context produce the same
logical recovery plan. Timing cannot turn a prohibited recovery into an allowed one.

## Retry Rules

- Side-effect-free query failures may retry as a new query attempt when the owner
  declares the dependency available/compatible.
- Boundary-invalid intent is corrected and submitted as a new canonical intent.
- Outcome unknown resolves or replays the exact request with the same idempotency
  key; no new semantic command is created.
- Stale/conflict requires re-query and a new confirmed intent/version.
- Unauthorized, incompatible, provenance-invalid and invariant-rejected errors do
  not receive blind automatic retry.
- Accepted/partial commands are never repeated as new mutations; resume or
  compensation uses explicit workflow commands.
- Unexpected defects fail closed and escalate; Product does not conceal them by
  retrying indefinitely.

No retry count, delay, backoff, timeout, circuit breaker or library is specified.

## Partial Success

A partial result lists committed steps in authoritative order, failed step/source,
unattempted steps, aggregate versions, user-visible consequence and declared
resume/compensation options. Committed owner events remain valid. Product neither
rolls them back implicitly nor presents the workflow as wholly failed/successful.

Resume starts from verified committed references. Compensation is a new
authorized owner command and may itself be rejected/partial. Error acknowledgement
does not erase partial state.

## Unknown-State Handling

Unknown target owner, version, provenance or lifecycle state fails closed. For an
unknown command outcome, Product binds the original request/idempotency key and
queries the authoritative owner. Until resolved, Experience shows
`outcomeUnknown`, blocks semantically duplicate mutation and offers only declared
resolution/safe navigation actions.

No local timeout, missing response, stale cache or navigation event establishes
that a command failed or succeeded.

## Failure Isolation And Capability Degradation

| Failure scope | Isolated effect | Permitted degraded behavior |
|---|---|---|
| Identity/Profile | protected Product use cases/navigation | public/safe error only; no cached authorization |
| Match | Match mutations/queries depending on source | unrelated Training/Knowledge views continue |
| Scoring | score commands/projection refresh | Match lifecycle cannot complete if score precondition required |
| Training | Training lifecycle/projections | Match/Knowledge independent queries continue |
| AI Coach/provider | Coach execution/session result | deterministic Product/Coach foundations remain available |
| Knowledge | Knowledge queries and dependent new planning | verified bound projections may render stale; no inferred replacement |
| Analytics | snapshot build/query | source Match/Score/Training/Evidence remains authoritative |
| Settings | configuration mutation/query | verified prior effective config only if contract permits and marked stale |
| Simulation | simulation request/result | unrelated Training steps continue only when Simulation not a precondition |
| Evidence recording | new fact/correction request | existing owner references remain readable under policy |
| Navigation resolver | affected route/deep link | last safe node or typed recovery route |
| External dependency | workflows declaring that dependency | isolate dependent step; no provider substitution unless separately governed |

Degradation is an explicit capability state, not silent fallback. It cannot use
stale or generated data as current truth, broaden access or change semantics.

## Required Capability Handling

- **Match/Scoring:** stale/conflict requires owner refresh; no optimistic score or
  Match completion when required score reference is unavailable.
- **Training:** stale eligibility/Knowledge blocks the dependent transition; no
  local prerequisite/unlock resolution.
- **AI Coach:** provider failure yields typed Coach failure; deterministic
  AISession/Recommendation/Execution records remain unchanged.
- **Knowledge:** unavailable/incompatible publication never falls back to an
  unverified package or compiler internals.
- **Analytics:** projection failure cannot mutate source facts; rebuild uses new
  request identity and canonical sources.
- **Settings:** conflict re-resolves effective version; defaults are allowed only
  if an accepted owner contract declares them.
- **Simulation/Evidence:** Product failure handles request/reference state only;
  Platform scenario/result/fact/custody remains owner-controlled.
- **Identity/Profile:** authorization failure cannot be bypassed by navigation or
  cached UI state.

## Synchronization And External Dependency Failures

Logical synchronization failure is `outcomeUnknown`, `staleConflict`,
`incompatible` or `dependencyUnavailable` based on owner evidence; it is not a
new authoritative data state. Reconciliation compares immutable identities,
versions and digests at public boundaries. P1.8 defines no synchronization,
networking, storage or merge mechanism.

External dependencies expose provider-neutral public failures. Provider-specific
details remain internal. Substitution/fallback requires a separately accepted
compatibility/policy decision and cannot happen implicitly in Product recovery.

## User-Visible Recovery

Experience displays stable category, affected action/target, committed or stale
state, outcome certainty and only safe allowed actions: correct, refresh, resolve
access, retry eligible query/exact request, resume, compensate, acknowledge, go
to last safe node or exit. It does not expose technical internals or claim that
acknowledgement repairs state.

Accessibility semantics convey failure source, status, consequence and recovery
actions independent of color, gesture or timing.

## Error Audit Boundary

Immutable audit references include error instance/category/version, source owner
and evidence reference, request/correlation, target/version where safe, committed
steps, recovery decisions/commands and final disposition. Audit excludes stack
traces, secrets, raw provider payload, raw Evidence and unnecessary user input.

Error audit does not become monitoring, telemetry or Evidence truth. Custody,
retention, correction and access remain with the declared record owner.

## Resilience Principles

Fail closed; isolate by capability/dependency; preserve accepted state; prefer
reconciliation over guessing; make degradation explicit; keep retries bounded by
source semantics; require idempotency; keep provider mechanisms behind ports;
retain deterministic recovery order; and repair at the accountable source.

## Definition Of Done

- Logical error taxonomy, envelope, ownership and propagation are defined.
- Recovery/retry/partial/unknown/failure-isolation/degradation semantics cover all
  required Product and dependency cases.
- Deterministic recovery, escalation and immutable audit boundaries are explicit.
- Product recovery does not redefine Platform governance or source failures.
- ADR-030 remains Proposed; no runtime implementation exists.
- Exactly the four authorized P1.8 files change.

## Engineering Evidence

- Full app regression passes 969/969.
- Knowledge package regression passes 75/75.
- Protected M3-M22 Foundation Freeze chain passes 76/76.
- Architecture Fitness remains 133 existing violations with 0 new.
- Generated architecture health was restored to its protected baseline.
- Exactly the four authorized P1.8 files change and `git diff --check` is clean.
- Platform, freeze, production, Knowledge/publication, Golden Fixture and M2
  proof artifacts remain unchanged.
