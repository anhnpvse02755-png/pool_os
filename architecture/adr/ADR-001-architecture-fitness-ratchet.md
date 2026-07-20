# ADR-001: Ratchet Existing Architecture Debt

**Status:** Accepted  
**Date:** 2026-07-20  
**Owners:** Pool OS architecture  
**Supersedes:** None  
**Superseded by:** None

## Context

Pool OS has an approved target domain model but the current Flutter code remains
organized mainly by feature and contains direct repository, persistence, and
framework dependencies that violate the target boundaries. Requiring zero
violations immediately would either block all work or encourage disabling the
architecture gate.

The initial scan found 143 violations across 222 Dart files and 913 import/export
directives. The project needs immediate protection against new debt while existing
violations are removed incrementally.

## Decision

Adopt an architecture debt ratchet:

- machine-readable rules classify current files into transitional domains;
- current violations are committed as a reviewed baseline;
- any new violation fails the architecture check;
- resolving a violation also fails until the baseline is regenerated, ensuring
  the improvement is committed;
- rule changes require explicit baseline review;
- each run generates an architecture health report;
- the mapping evolves as physical domain packages replace feature folders.

The baseline records debt; it does not approve the violations as compliant.

## Normative Authority

```yaml
constitution:
  version: 1.4.0
  sections:
    - "Section 5 - Dependency Rules"
    - "Section 18 - Enforcement"
    - "Section 20.2 - ADR authority and evidence linkage"
parentAdrs: []
contracts: []
```

## Architecture Evidence Plan

```yaml
contractTests: []
architectureTests:
  - ruleId: domain_dependency
    status: active
  - ruleId: direct_persistence_access
    status: active
  - ruleId: cross_domain_data_import
    status: active
  - ruleId: domain_framework_dependency
    status: active
integrationTests:
  - path: tool/architecture_test.dart
    status: active
productionSignals:
  - metric: not_available
    owner: Pool OS architecture
    plan: Track CI health artifacts and add a trend projection after sufficient runs.
healthReports:
  - path: build/architecture/health.json
```

## Evidence Status

Verified locally on 2026-07-20:

- Dart analyzer reports no issues for the checker.
- Baseline check passes with 143 known violations and zero new violations.
- A temporary `Simulation -> Knowledge` import was rejected by
  `domain_dependency` and removed after the negative-path test.
- The final clean scan passes.
- CI workflow is configured for push, pull request, manual, and daily execution.

## Alternatives Considered

**Enforce zero violations immediately:** rejected because current physical
boundaries do not yet match the Constitution and the resulting gate would be
permanently red.

**Document rules without executable checks:** rejected because document maturity
is not implementation or enforcement maturity.

**Allow the baseline to grow:** rejected because it converts the baseline into a
waiver mechanism rather than a debt ratchet.

## Consequences

New architecture debt is blocked immediately. Existing debt remains visible and
must be reduced deliberately. Transitional domain classification is imperfect and
requires updates as modules are extracted. Baseline diffs require architectural
review.

## Compatibility and Migration

This decision changes no runtime behavior or persisted data. Domain extraction can
proceed incrementally. Moving a file may resolve or reclassify violations and must
be accompanied by a reviewed baseline update.

## Security, Privacy, and Provenance

The checker reads source paths and import directives only. Health artifacts contain
repository paths and rule IDs, not player or production data. GitHub Actions are
pinned to reviewed commit SHAs.

## Enforcement

- `dart run tool/architecture_test.dart`
- `.github/workflows/architecture.yml`
- `architecture/fitness_rules.json`
- `architecture/fitness_baseline.json`

## Exceptions

None. New baseline entries require an approved constitutional exception or a new
ADR; `--update-baseline` alone does not authorize them.
