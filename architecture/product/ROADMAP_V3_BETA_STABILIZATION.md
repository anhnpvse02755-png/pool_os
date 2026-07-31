# Roadmap V3 — Beta Stabilization

Status:
Active

Roadmap:
V3 (Beta → Release Candidate)

Phase:
H — Final Stabilization

Objective:
Produce the FIRST INTERNAL BETA APK as quickly as possible.
Goal is NOT "add features." Goal is: STABLE / USABLE / TESTABLE / BETA.

---

# Mission

Run ONE global audit over the entire application.

Do NOT repeat architecture reviews already executed during EPIC development.

Focus only on production readiness.

## Checklist

- [ ] Dead code
- [ ] Duplicate widgets
- [ ] Unused providers
- [ ] Broken navigation
- [ ] Invalid routes
- [ ] Loading states (every async screen)
- [ ] Empty states (every list screen)
- [ ] Null handling
- [ ] Responsive layout
- [ ] Startup flow
- [ ] Release build (analyze + build succeeds)
- [ ] Analyzer clean (0 errors, minimize warnings)
- [ ] Regression (flutter test pass)
- [ ] Crash scenarios (cold start / empty DB / network failure)

**Prioritize HIGH and MEDIUM issues only.**

Low-priority cosmetic issues → backlog.

## Deliver

`FINAL_STABILIZATION_REPORT.md` documenting findings + fixes.

---

# H1 — Knowledge Hardening

## Highest-value phase. Do NOT add AI.

Improve Knowledge quality only.

## Focus

- [ ] Category coverage (no orphaned items)
- [ ] Article linking (related knowledge accurate)
- [ ] Drill linking (drills reference correct articles)
- [ ] Lesson linking (lessons have correct prerequisites)
- [ ] Pattern linking (patterns reference correct categories)
- [ ] Search quality (results relevant, ranked correctly)
- [ ] Metadata quality (tags, aliases, descriptions complete)
- [ ] Duplicate detection (no two articles covering the same ground)
- [ ] Relationship completeness (no isolated nodes in the knowledge graph)

## Constraints

- No new screens
- No schema changes unless absolutely required
- No AI features
- No new knowledge content (editing only)

---

# H2 — AI Hardening

## Improve AI using existing architecture only. Do NOT redesign Coach.

## Focus

- [ ] Prompts (context-complete, no hallucinations)
- [ ] Reasoning pipeline (output format consistent)
- [ ] Data snapshot (Coach reads all 9 data sources)
- [ ] Recommendation quality (surface-relevant suggestions)
- [ ] Strategy quality (context-aware, player-skill-appropriate)
- [ ] Review quality (specific, actionable feedback)

## Constraints

- MockAI remains the default provider
- No external API dependency required for H2
- No Coach architecture redesign

---

# H3 — Internal Beta

## Prepare APK for internal testing.

## Deliver

- [ ] Release APK (signed, optimized)
- [ ] Beta Checklist (H7-equivalent gate)
- [ ] Known Issues document
- [ ] Feedback Template

## Constraints

- No feature development
- Only bug fixing from internal testing results

---

# Forbidden

Engineering MUST NOT:

- ❌ Create EPIC 10
- ❌ Redesign architecture
- ❌ Rewrite modules
- ❌ Migrate database
- ❌ Add AI features outside EPIC 06
- ❌ Add Marketplace features outside EPIC 08
- ❌ Add Admin Portal

---

# Workflow

```
H0 — Final Stabilization
  ↓
PO Review
  ↓
H1 — Knowledge Hardening
  ↓
PO Review
  ↓
H2 — AI Hardening
  ↓
PO Review
  ↓
Build Internal Beta APK
  ↓
Internal Testing
  ↓
Bug Fix
  ↓
Release Candidate
```

---

# Success Criteria

The Beta must demonstrate the THREE CORE VALUES of Pool OS:

1. **Knowledge Base** — the app teaches players
2. **AI Coach** — the app analyzes players using real data
3. **Training System** — the app converts analysis into actionable training

Everything else is secondary.

---

# Engineering Principle

Favor stability over new functionality.

A complete beta with fewer bugs is more valuable than additional unfinished features.

---

*Roadmap authored by PO 2026-07-31. Replaces prior H0-H8 Hardening document.*