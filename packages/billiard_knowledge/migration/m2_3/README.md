# M2.3 Migration Artifacts

This directory contains generated candidate artifacts for the Pack v1.4
36-entry migration. It is not the production Knowledge corpus and must not be
edited by hand.

Rebuild:

```powershell
dart run tool/knowledge_migration_v1_4.dart
```

Verify drift:

```powershell
dart run tool/knowledge_migration_v1_4.dart --check
```

The production pointer remains under `publication/current.json`. M2.3 only
proves an isolated publication pipeline; M2.4 owns clean-checkout rebuild and
any production activation decision.
