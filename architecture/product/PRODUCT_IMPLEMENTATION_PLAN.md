# Product Implementation Plan

**Status:** Accepted Planning Baseline; Closed
**Date:** 2026-07-23

## Governance Root

All Product work is rooted in M22 Foundation Freeze digest
`2086946d208e96093ae6699e36ab82bf174e9ec9630727abbce4691ec8c902fb`.
Platform is immutable; Product consumes Platform public contracts.

## Roadmap

### P1 Core Runtime Foundation
Establish authorized composition, lifecycle and runtime shell boundaries.

### P2 Domain Runtime
Implement domain behavior behind existing public contracts without ownership drift.

### P3 Cross-domain Runtime
Compose deterministic flows using ports, provenance and fail-closed compatibility.

### P4 User Experience
Implement accessible query/command experiences without domain inference.

### P5 Intelligence
Integrate deterministic Intelligence/Coach capabilities and Decision Trace.

### P6 Knowledge Integration
Consume accepted published Knowledge without authoring/compiler ownership leakage.

### P7 Simulation
Integrate deterministic physics while excluding player models, policy and strategy.

### P8 Release Readiness
Validate Product evidence, security, operations, recovery and release governance.

## Program Rules

Each program requires separately authorized milestones with exact files, scope,
owners, evidence, tests, rollback and PO acceptance. Product ADRs cannot
supersede Platform ADRs. Platform freezes and Constitution remain protected.
No roadmap item is implementation authority by itself.
