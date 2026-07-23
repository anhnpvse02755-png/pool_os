# Product Experience Flows

**Status:** Accepted Planning Baseline; Closed
**Version:** Planning baseline v1
**Date:** 2026-07-23

## Boundary

Experience renders immutable projections, captures explicit intent and navigates
between logical nodes. Application services coordinate use cases. Capability
owners validate and mutate state. Navigation never substitutes for a command.

## Route Catalog

| Logical route identity | Owner-facing source | Entry condition |
|---|---|---|
| product.startup.v1 | Application compatibility/access | Product launch |
| product.profile.select.v1 | User/Profile service | multiple/unresolved eligible profiles |
| product.home.v1 | composed public projections | compatible resolved profile |
| product.match.list.v1 | Match query | authorized profile |
| product.match.create.v1 | Match command boundary | create permission decision |
| product.match.detail.v1 | Match projection | valid authorized Match reference |
| product.score.detail.v1 | Scoring projection | valid Match/Score reference |
| product.training.list.v1 | Training query | authorized profile |
| product.training.session.v1 | Training projection | valid Training reference |
| product.coach.session.v1 | Coach Session projection | valid AISession/Coach reference |
| product.knowledge.browse.v1 | Knowledge query | compatible publication context |
| product.knowledge.detail.v1 | Knowledge projection | valid published reference |
| product.analytics.overview.v1 | Analytics query | authorized profile |
| product.analytics.snapshot.v1 | Performance Snapshot | valid snapshot reference |
| product.simulation.request.v1 | Simulation request service | authorized scenario reference |
| product.simulation.result.v1 | Simulation result reference | accepted completed request |
| product.settings.v1 | Configuration query | authorized configuration scope |
| product.error.recovery.v1 | Application failure envelope | typed failure/partial state |

Route identities are logical planning IDs, not paths or code constants.

## Journey Outcomes

| Journey | Successful destination | Deterministic alternative |
|---|---|---|
| Startup | Profile Selection or Home | incompatible/access/error recovery |
| Profile selection | Home | unauthorized/stale/error recovery |
| Match create | Match Detail | validation/conflict/error recovery |
| Match scoring | updated Score Detail | stale/invariant/partial error |
| Training | Training Session | stale eligibility/error recovery |
| AI Coach | structured Coach Session result | typed boundary/provider failure |
| Knowledge browse | Knowledge Detail | unavailable/stale reference |
| Analytics | Snapshot Detail | build partial/failed/stale source |
| Settings | effective configuration view | conflict/validation/unauthorized |
| Simulation | Simulation Result | rejected/failed/cancelled request |

## Navigation Invariants

1. A route cannot grant authorization.
2. Route entry cannot mutate domain state.
3. Every displayed domain fact names one authoritative projection source.
4. A command result precedes navigation that depends on its mutation.
5. Deep links pass compatibility, authorization and target-resolution gates.
6. Unknown/stale/offline conditions are visible and never converted to ready.
7. Back navigation changes view history, not domain history.
8. Cross-capability links carry typed references and independently resolve target.
9. Generated Coach output cannot select or authorize a route.
10. Same resolved inputs produce the same logical destination and visible state.

## Error Recovery Matrix

| Condition | Visible state | Permitted recovery |
|---|---|---|
| offline | offline/stale | retry query; return safe node |
| unauthorized | unauthorized | refresh access; profile resolution; safe exit |
| not found | notFound | return source/Home; re-resolve reference |
| incompatible version | incompatible | refresh compatible context; safe exit |
| stale projection | stale | re-query owner; retain marked prior projection |
| command rejected | failed | correct input or retry identical idempotent intent where allowed |
| partial workflow | partial | show committed steps; explicit compensation/resume action |
| unknown owner/state | failed | safe exit and diagnostic reference; no fallback |

## Planning Constraint

No UI layout, theme, widget, screen/page, coded route, navigation engine,
authentication, state management, API or runtime behavior is created here.
