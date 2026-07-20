# Architecture Fitness Tests

The architecture test reads Dart import/export directives, resolves local
targets, classifies files using `fitness_rules.json`, and compares violations
with a committed debt baseline.

Run from the repository root:

```powershell
dart run tool/architecture_test.dart
```

When an intentional refactor removes existing violations, rebuild the baseline:

```powershell
dart run tool/architecture_test.dart --update-baseline
dart run tool/architecture_test.dart
```

`--update-baseline` must not be used to approve new violations. Review its diff
and explain every addition. A healthy change keeps the count stable or reduces it.

The current mapping is transitional because the application is still organized
under `app/lib/features`. Update domain roots as physical packages/modules are
extracted. Presentation paths are always classified as Experience, regardless of
their feature folder.

The checker enforces:

- allowed domain-to-domain dependencies;
- Experience does not import repositories/database implementations directly;
- cross-domain imports do not target another domain's data layer;
- domain-layer files remain free of Flutter/Riverpod dependencies;
- current debt cannot silently grow;
- removed debt must be deleted from the baseline.

Every run writes `build/architecture/health.json`. The report contains scan
coverage, domain dependency edges/cycles, debt grouped by rule, and baseline
deltas. Capabilities that are not implemented yet (contract, Knowledge, and
compiler drift) are reported as `not_configured` rather than appearing healthy.

`.github/workflows/architecture.yml` runs the same gate on pushes, pull requests,
manual dispatch, and once per day. It retains each health report for 30 days so
architecture debt can be inspected over time. The initial report is a machine-
readable health artifact, not yet a trend dashboard.
