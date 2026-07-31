# EPIC 09 — Administration & User Settings

Status:
Authorized

Classification:
Final Product Epic

Roadmap:
Roadmap V3 (Beta) — completion Epic

Owner:
Product Owner

Priority:
High

Dependencies:

- All Foundation Features 001–012
- EPIC 01 — Match Engine
- EPIC 02 — Statistics & Analytics
- EPIC 03 — Training System
- EPIC 04 — Tournament & Competition System
- EPIC 05 — Knowledge System
- EPIC 06 — AI Coach
- EPIC 07 — Community System
- EPIC 08 — Marketplace

Wave Model:
**Phase 1 (current): Track A — User Settings (mobile app) only.**
Phase 2 (Track B — Admin Portal Web) spec will be provided later by PO.

---

# §0 — Objective

EPIC 09 has two tracks:

1. **User Settings (App)** — personal settings and data management for
   end users. No admin permissions required. Lives in Pool OS mobile app.

2. **Administration Portal (Web)** — system administration for operators.
   Lives in Pool OS Admin Portal (separate project — Flutter Web / React / Vue).

No player-facing functionality shall be introduced in the Admin Portal.

---

# §1 — Track A: User Settings (Mobile App)

## 1A.1 User Settings

Personal user preferences.

**Settings:** Theme (light/dark/system) / Language / Currency / Units / Measurement system.

## 1A.2 Backup & Restore (User)

Personal data backup and restore.

**Backup:** Export full personal data (matches / training / statistics / knowledge progress / settings).

**Restore:** Import personal backup. Validate first / Preview / Execute.

**Metadata:** Date / Version / Schema Version / Build Version / Checksum.

No cloud backup. Manual only.

## 1A.3 Import / Export (User)

Personal data export and import.

**Formats:** JSON / CSV.

**Export scope:** Equipment / Knowledge / Training / Statistics.

**Import:** Validate first / Preview / Execute / Rollback on failure.

No partial corruption allowed.

---

# §2 — Track B: Administration Portal (Web)

## 1B.1 Admin Console

Administrator Console (web).

**Capabilities:**

- User Management
- Player lookup
- Equipment lookup
- Tournament lookup
- Statistics overview
- Training overview

**Roles:** Super Admin / Administrator / Moderator / Read-only Admin.

Read-only dashboards where possible.

## 1B.2 Moderation

Moderation over Community and Marketplace (web).

**Capabilities:** Hide review / Hide comment / Archive listing / Suspend challenge / Flag content / Restore content.

**States:** Pending / Approved / Rejected / Archived / Removed.

No AI moderation. No automatic moderation.

## 1B.3 Configuration

Application configuration (web).

**Categories:** General / Marketplace / Community / Tournament / Training / Knowledge / AI / System.

Configuration is data-driven. No hardcoded configuration.

## 1B.4 Audit

Administrative audit trail (web).

**Track:** Configuration changes / Role changes / Admin actions / Import / Export / Backup / Restore / Moderation actions.

**Audit Record:** Timestamp / Actor / Action / Entity / Before / After / Result.

Audit is append-only.

## 1B.5 System Settings

Global settings (web).

**Examples:** Theme / Language / Units / Currency / Date format / Measurement system / Developer Mode / Logging Level / Debug Mode / Read-only version information.

## 1B.6 Backup

System backup (web).

**Support:** Export full backup / Export user backup / Restore backup.

**Backup metadata:** Date / Version / Schema Version / Build Version / Checksum.

No cloud backup. No automatic scheduling. Manual only.

## 1B.7 Import / Export (Admin)

System import/export (web).

**Support:** JSON / CSV / ZIP package.

**Export:** Equipment / Knowledge / Training / Statistics / Marketplace / Community / Tournament.

**Import:** Validate first / Preview / Execute / Rollback on failure.

No partial corruption allowed.

---

# §3 — Architecture

## Track A — Mobile App

```
Settings UI
  ↓
UserSettingsService           ← sole entry point
  ↓
UserSettingsPipeline
  ↓
SettingsEngine
BackupEngine
ImportExportEngine
```

## Track B — Admin Portal (Web — separate project)

```
Administration UI (Web)
  ↓
AdministrationService
  ↓
AdministrationPipeline
  ↓
AdminEngine
ModerationEngine
ConfigurationEngine
AuditEngine
BackupEngine
ImportExportEngine
```

Administration NEVER owns business data. Only orchestrates.

---

# §4 — Data Ownership

User Settings (Track A) OWNS:

- Personal settings (theme, language, currency, units)
- Personal backup metadata
- Personal import/export jobs

Administration (Track B) OWNS:

- Audit
- Backup Metadata
- Configuration
- System Settings
- Import Jobs
- Export Jobs

Both tracks NEVER OWN: Match / Training / Knowledge / Statistics / Marketplace / Community / AI / Equipment / Player.

---

# §5 — Capability Pattern

Unavailable functions return `CapabilityResult.notAvailable(...)`.
Never throw production exceptions.

Examples (both tracks):

- Cloud Backup → `notAvailable`
- Remote Restore → `notAvailable`
- Scheduled Backup → `notAvailable`
- LDAP / SSO → `notAvailable`
- Email Service → `notAvailable`
- Push Notification → `notAvailable`

---

# §6 — Beta Constraints

### Mobile App (Track A)

- No cloud backup
- No admin permissions
- Manual execution only
- No server-side operations

### Admin Portal (Track B)

- No cloud deployment
- No distributed administration
- No SSO / LDAP
- No scheduled jobs
- No background daemon
- No push service
- Manual execution only

---

# §7 — Forbidden

Engineering MUST NOT implement:

- ❌ Cloud Backup / Google Drive / Dropbox / OneDrive
- ❌ Email Service
- ❌ Push Notification
- ❌ AI Moderation / AI Administration
- ❌ Remote Administration
- ❌ Scheduled Tasks / Cron Engine
- ❌ Server Management
- ❌ Analytics Service
- ❌ Payment Administration
- ❌ Admin features in mobile app (User Settings only)

---

# §8 — Split Rationale

**Why NOT put admin features in the mobile app?**

- Increases app size significantly
- Increases complexity (permission systems)
- Normal users never need User Management / Moderation / Audit / System Configuration
- Separate Admin Portal (Flutter Web / React / Vue) keeps the mobile app lean

**Pool OS Mobile App** → Player / Coach / Marketplace / Community / User Settings

**Pool OS Admin Portal (Web)** → Dashboard / Users / Marketplace / Community / Moderation / Audit / Configuration / System / Reports

---

# §9 — Lifecycle (single — Roadmap V3 Beta)

```
Wave 1  — User Settings (Track A: Settings/Backup/Import/Export)
Wave 2  — Administration Portal foundations (Track B: Admin/Moderation/Config)
Wave 3  — Admin Portal completion (Track B: Audit/Settings/Backup/Import-Export)
         ↓
1 Engineering Report
         ↓
1 Full Regression
         ↓
1 PO Review
         ↓
1 Merge
         ↓
1 Close
```

Engineering may work internally by waves. Official lifecycle remains:
Engineering → Engineering Report → Full Regression → PO Review → Merge → accepted_closed.

---

# §10 — Roadmap V3 Beta Completion

After EPIC 09 is closed:

- ✅ Foundation FEATURE_001–012 complete
- ✅ EPIC 01–09 complete
- ✅ Pool OS Mobile App Beta complete (Player / Coach / Marketplace / Community / User Settings)
- ✅ Pool OS Admin Portal (Beta) scaffolded
- ✅ Product Beta complete

The project transitions to **Roadmap V4 / Release Candidate** phase focusing on:

- Performance
- Security Hardening
- Stability
- Release Engineering

---

# §11 — Success Criteria

The Epic is accepted when:

- [ ] All 7 deliverables implemented (Track A: 3, Track B: 7 minus 3 already in A).
- [ ] User Settings isolated in mobile app (no admin permissions).
- [ ] Administration Portal scaffolded (Track B).
- [ ] Audit covers all admin operations.
- [ ] Backup and Restore validated.
- [ ] Import includes preview and validation.
- [ ] No AI introduced.
- [ ] No cloud dependency introduced.
- [ ] No admin features in mobile app.
- [ ] One Engineering Report.
- [ ] One Full Regression.
- [ ] One PO Review.
- [ ] One Merge.
- [ ] One accepted_closed.

---

*Spec authored by PO 2026-07-31, recorded by Engineering.*