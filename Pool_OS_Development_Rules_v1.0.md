# Pool OS Development Rules v1.0

Status: **LOCKED**

These rules are mandatory for all AI developers (Cursor, Claude Code,
Gemini, etc.).

## 1. General Principles

1.  Workflow Specification has the highest priority.
2.  Never redesign product workflows unless explicitly instructed.
3.  Preserve Clean Architecture.
4.  Fix the root cause, not the symptom.
5.  One FIX = one scope.

## 2. Before Writing Code

For every FIX:

-   Reproduce the bug.
-   Identify the root cause.
-   List impacted files.
-   Explain why the bug occurs.
-   Stop if the root cause is unknown.

Never guess.

## 3. Scope Control

Do not:

-   Refactor unrelated modules.
-   Rename files without approval.
-   Change database schema unless the FIX explicitly requires it.
-   Modify business logic for UI-only fixes.

## 4. Architecture

Presentation → Riverpod Provider → Repository → Domain → Drift →
Database

Never bypass Repository.

## 5. UI Rules

-   Never change workflow.
-   Never remove existing features unless requested.
-   Empty state instead of crash.
-   Loading state instead of grey screen.
-   Error state instead of exception.

## 6. Null Safety

Never use `!` unless logically guaranteed.

Prefer:

-   null checks
-   early return
-   fallback widgets

## 7. Database

Do not edit generated Drift files manually.

Always regenerate code after schema changes.

## 8. Navigation

Do not change navigation flow without approval.

Prefer existing routing.

## 9. Debug Rules

Every debug report must contain:

-   Reproduction steps
-   Root cause
-   Evidence
-   Fix plan
-   Regression risk

## 10. Implementation Rules

Every FIX must include:

-   Root cause
-   Files changed
-   Reason for each change
-   Expected UAT result

## 11. Verification

Before building APK:

-   flutter analyze = 0 errors
-   No compilation issues
-   Verify modified workflow manually

## 12. UAT

A FIX is NOT complete until:

1.  Analyze passes.
2.  APK builds.
3.  User UAT passes.

## 13. Forbidden

Never:

-   Invent workflow
-   Rewrite architecture
-   Introduce breaking refactors
-   Modify unrelated modules
-   Close a FIX without UAT

## 14. Coding Style

-   Small focused commits
-   Minimal file changes
-   Preserve naming conventions
-   Preserve localization
-   Preserve repository boundaries

## 15. Final Rule

If code conflicts with: - Workflow Specification - Architecture Guide -
Development Rules

The documentation wins.
