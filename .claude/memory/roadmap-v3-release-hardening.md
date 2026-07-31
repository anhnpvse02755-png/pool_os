---
name: roadmap-v3-release-hardening
description: Roadmap V3 Release Hardening — H0-H8 phases (PO 2026-07-31). No new features until H7 gate 100% green.
metadata:
  type: project
---

Roadmap V3 Release Hardening — authored by PO 2026-07-31.

Philosophy: 9 EPICs closed does NOT mean production-ready. All effort goes to
quality. The value of Pool OS lives in three pillars:
  1. Knowledge Base — deep enough to learn
  2. AI Coach — using real player data for analysis
  3. Training System — connected to statistics and knowledge

Priority order (PO-defined):
  H5 Knowledge  >  H6 AI  >  H3 UX  >  H1 Architecture  >
  H4 Performance  >  H2 Feature  >  H7 Checklist

Gates:
  H1 — Architecture Audit: dependency graph, circular deps, dead code,
        naming consistency, folder consistency
  H2 — Feature Audit: every feature has its complete deliverable surface
  H3 — UX Audit: every screen has Loading/Empty/Error/Success/Retry/
        PullRefresh/Search/Sort/Filter/Pagination
  H4 — Performance Audit: rebuilds, memory leaks, dispose, image cache,
        lazy loading, list virtualization, isolate
  H5 — Knowledge Audit: no duplicates, no broken links, no dead videos,
        correct categories, AI context complete
  H6 — AI Audit: Coach reads from ALL sources (Knowledge/Statistics/
        Training/Equipment/Pattern/History/Match/Video/Article)
  H7 — Beta Readiness Checklist: 100% green before V3 RC tag
  H8 — Release Criteria: all gates pass, nothing ships until H7 is 100%

Forbidden: No new Epic. No new feature. No new screen until H7 gate
is 100% green.

Spec: `architecture/product/ROADMAP_V3_RELEASE_HARDENING.md`

Related: [[roadmap-v3-beta-wave-model]], [[capability-pattern]], [[epic-09-close]]
