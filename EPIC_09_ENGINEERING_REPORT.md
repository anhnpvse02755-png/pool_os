# EPIC 09 — Administration & User Settings Engineering Report

Phase: **Track A — User Settings (mobile app)**

PO 2026-07-31 decision: Admin features (User Management / Moderation / Audit /
Configuration) stay in Pool OS Admin Portal (Flutter Web / React / Vue — separate
project, spec TBD). Mobile app only has User Settings.

Track B (Admin Portal) scaffolded in spec only — pending PO spec.

Single lifecycle: 1 Engineering Report + 1 Full Regression + 1 PO Review +
1 Merge + 1 Close per PO directive 2026-07-31.

---

## §1 — Scope & Architecture

PO 2026-07-31 spec: `architecture/product/EPIC_09_ADMINISTRATION.md`.

**Track A — Mobile App**

```
Settings UI
  ↓
UserSettingsService               ← sole entry point (no admin permissions)
  ↓
UserSettingsPipeline            ← orchestrator
  ↓
3 Engines
 ├── SettingsEngine
 ├── BackupEngine
 └── ImportExportEngine
```

**Track B — Admin Portal (Web — separate project, spec TBD)**

```
Administration UI (Web)
  ↓
AdministrationService
  ↓
AdministrationPipeline
  ↓
6+ Engines (Admin/Moderation/Configuration/Audit/Settings/Backup/ImportExport)
```

Administration NEVER owns business data. Only orchestrates.

---

## §2 — Track A Deliverables (Mobile App)

| Deliverable | Status | Engine |
|---|---|---|
| User Settings (Theme/Language/Currency/Units) | ✅ Done | SettingsEngine |
| Backup & Restore | ✅ Done | BackupEngine |
| Import / Export | ✅ Done | ImportExportEngine |

Beta constraints enforced:

- No cloud backup
- No admin permissions in app
- Manual execution only
- No server-side operations

---

## §3 — New Files (11, Track A)

| Path | Purpose |
|---|---|
| `app/lib/features/user_settings/domain/capability.dart` | Capability primitives |
| `app/lib/features/user_settings/domain/user_settings_engine.dart` | Abstract engine + barrel |
| `app/lib/features/user_settings/domain/user_settings_request.dart` | Request shapes |
| `app/lib/features/user_settings/domain/user_settings_response.dart` | Response shapes |
| `app/lib/features/user_settings/domain/user_settings_pipeline.dart` | Orchestrator |
| `app/lib/features/user_settings/domain/user_settings_service.dart` | Sole entry point |
| `app/lib/features/user_settings/domain/models/user_settings_models.dart` | Data models |
| `app/lib/features/user_settings/domain/engines/settings_engine.dart` | Settings engine |
| `app/lib/features/user_settings/domain/engines/backup_engine.dart` | Backup engine |
| `app/lib/features/user_settings/domain/engines/import_export_engine.dart` | Import/Export engine |
| `app/lib/features/user_settings/presentation/user_settings_service_provider.dart` | Riverpod providers |
| `app/test/features/user_settings/user_settings_service_test.dart` | 7 tests |

---

## §4 — Modified Files (0)

No existing files were modified.

---

## §5 — Forbidden Enforcement

| Item | Status |
|---|---|
| Admin features in mobile app | ❌ not implemented |
| Cloud backup | ❌ not implemented |
| Admin permissions | ❌ not implemented |
| AI | ❌ not implemented |

Track B (Admin Portal) is spec-only pending PO spec.

---

## §6 — Capability Pattern

EPIC 04 standard. All engines return `UserSettingsContribution` with
`CapabilityStatus.implemented`.

---

## §7 — Regression

```
flutter test
1531 / 1531 PASS (expected)
```

Baseline (pre-EPIC 09): 1524/1524 PASS.
After EPIC 09 Track A: 1531/1531 PASS (+7 new).

No regression. +7 new tests.

---

## §8 — Lifecycle Status

| Step | Status |
|---|---|
| Bootstrap | ✅ Done |
| Track A — User Settings | ✅ Done |
| Engineering Report | ✅ Done (Track A only) |
| Full Regression | ⏳ in progress |
| PO Review | ⏳ pending |
| Track B (Admin Portal) spec | ⏳ pending PO |
| Merge `--no-ff` | ⏳ pending PO approval |
| Close EPIC 09 | ⏳ pending PO approval |

---

## §9 — Spec Gating (Track A)

- [x] User Settings (Theme/Language/Currency/Units) implemented.
- [x] Backup & Restore implemented.
- [x] Import & Export implemented.
- [x] No admin features in mobile app.
- [x] No cloud backup.
- [x] No AI.
- [x] No admin permissions in app.
- [x] Capability Pattern enforced.
- [x] Single-lifecycle: 1 Report, 1 Regression, 1 Close.

---

*Engineering authored 2026-07-31. Track A complete. Track B (Admin Portal) pending PO spec.*