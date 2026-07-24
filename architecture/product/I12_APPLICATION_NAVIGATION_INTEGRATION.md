# I12 Application Navigation Integration

Status: Accepted; Closed

Date: 2026-07-24

## Objective

Integrate the accepted I11 Home Dashboard into the existing GoRouter without
changing feature behavior or replacing the navigation framework.

## Route Semantics

- `/home` is the default application entry and first shell branch.
- `/dashboard` remains a top-level backward-compatible route to the legacy
  Dashboard screen.
- The existing four-destination bottom navigation structure and labels remain
  unchanged.
- Home opens Match, Training, Coach, Knowledge, Analytics and Simulation using
  the accepted I11 destination actions.
- System back from every Home destination returns to Home.
- The legacy Dashboard Statistics detail flow remains covered.

## Scope Resolution

The original I12 allowlist conflicted with legacy `app/test/widget_test.dart`
assertions that froze Dashboard as the entry screen. Product Owner explicitly
expanded the allowlist to that one test file. Only entry-screen assertions and
the legacy Dashboard deep-link setup were updated; unrelated coverage was not
removed or relaxed.

## Ownership And Reuse

I12 changes only route registration and navigation acceptance tests. It reuses
the existing GoRouter, I11 Home and existing feature screens. No feature
service, repository, schema, runtime, framework or business behavior changed.

## Verification

- Focused I12 navigation tests: 7/7.
- Legacy widget compatibility tests: 4/4.
- Combined focused tests: 11/11.
- Focused analyzer: clean.
- Focused formatter and `git diff --check`: clean.
- Full app regression: 1184/1184.
- Knowledge package regression: 75/75.
- Foundation freeze: 76/76.
- Architecture Fitness: 133 existing violations, 0 new.
- Dependency and prohibition scans: clean.
- Generated Architecture Fitness health output restored to baseline.
- Protected Foundation M1-M22, P1-P9, feature services, repositories,
  persistence, schema and production artifacts are unchanged.
- Diff is limited to the revised exact I12 allowlist.

## Scope Confirmation

I12 uses the current GoRouter and only changes the application entry route and
route compatibility. It does not introduce a second router or navigation
framework.

## Repository State

Product Owner accepted I12 on 2026-07-24, declared Product MVP I1-I12 complete,
and authorized repository commit and push without redesign.
