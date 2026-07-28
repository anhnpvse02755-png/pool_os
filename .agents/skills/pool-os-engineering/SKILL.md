---
name: pool-os-engineering
description: Production engineering workflow for the Pool OS Flutter application. Use for every non-trivial Pool OS requirement analysis, bug diagnosis, implementation, refactor, architecture review, database or navigation change, UAT fix, test task, and release-readiness check. Enforces project source precedence, Flutter/Riverpod/GoRouter/Drift boundaries, Memory and Graphify usage, scope control, security, offline integrity, self-review, and the required seven-section delivery format.
---

# Pool OS Engineering

Apply this skill as the first-party engineering control plane for Pool OS. Use
specialized project skills for their focused workflows, but never let a generic
skill override Pool OS business rules, UAT evidence, or the current Flutter code.

Read [references/project-source-map.md](references/project-source-map.md) before
working on an unfamiliar module or when documents disagree. Read
[references/skill-routing.md](references/skill-routing.md) before choosing a
specialized skill.

## Source precedence

Resolve conflicts in this order:

1. The user's current explicit request and latest UAT evidence
2. Locked Pool OS development rules and an approved task/FIX/RFC scope
3. Current executable code, `app/pubspec.yaml`, Drift schema, and tests
4. Applicable approved RFC and domain specification
5. `MEMORY.md` and dated memory as historical decision context
6. Legacy or generic documents

Never silently choose between conflicting sources. State the conflict and use
the highest-precedence source. Treat TypeScript, React, Node.js, Kotlin, or old
Cursor descriptions as stale unless the current task explicitly targets them.

## Mandatory startup

For every non-trivial task:

1. Read `MEMORY.md` and search memory for related decisions.
2. Inspect the current task/FIX/RFC and the smallest relevant code path.
3. Confirm the active stack from `app/pubspec.yaml`.
4. Identify affected modules and source-of-truth documents.
5. Classify the request as explain, review, diagnose, implement, or release.

Use Graphify when the request spans multiple modules, needs durable architecture
understanding, or asks for relationship tracing. Read
`graphify-out/GRAPH_REPORT.md` first and prefer a focused query or incremental
refresh over a whole-repo rebuild.

## Required analysis

Before editing, explicitly assess:

- Business rules and acceptance criteria
- Architecture and layer ownership
- Drift/database and migration impact
- API or service-contract impact
- Riverpod state and lifecycle impact
- GoRouter/navigation impact
- Performance and rebuild/query impact
- Security, privacy, and external-input validation
- Offline behavior, transaction integrity, backup, and sync impact
- Edge cases, null safety, empty/loading/error states, and localization

List assumptions when evidence is missing. Do not invent requirements.

## Implementation workflow

Follow this order:

1. Understand the request and reproduce observable behavior when diagnosing.
2. Analyze existing documents, code, tests, and memory.
3. Identify impacted modules and files.
4. Detect risks and define out-of-scope areas.
5. Produce a focused implementation plan.
6. Implement the smallest coherent change.
7. Run targeted tests, static analysis, and relevant build checks.
8. Self-review and fix discovered issues.
9. Update memory for durable decisions and Graphify for material structure changes.

Do not implement a diagnosis-only request. Do not broaden authorization because
a task says finish or continue.

## Flutter boundaries

The current application uses Flutter/Dart, Riverpod, GoRouter, and Drift/SQLite.

- Keep business logic out of widgets.
- Keep navigation and `BuildContext` out of providers and repositories.
- Let providers own workflow/state, repositories own persistence, domain/services
  own algorithms, and Drift own storage mechanics.
- Preserve feature-first structure and existing naming conventions.
- Prefer composition, small widgets, immutable state, explicit async states, and
  targeted provider rebuilds.
- Do not edit generated `*.g.dart` files manually.
- Do not add a new state, routing, persistence, or serialization framework unless
  the approved scope requires it.

## Database and backend gates

- Never change the database schema unless explicitly required.
- For required schema changes, explain the reason, migration path, rollback/data
  risk, fresh-install behavior, upgrade behavior, and backward compatibility.
- Use transactions for related writes and reject orphan/invalid identifiers.
- Preserve offline-first behavior and local data integrity.
- Supabase skills are available for approved Supabase work only. Their presence
  does not authorize adding Supabase, replacing Drift, or introducing cloud sync.

## Security and privacy

- Never expose or hardcode secrets, service-role keys, private tokens, or user data.
- Validate every external input and persisted identifier.
- Keep secrets out of memory files, screenshots, logs, reports, and graph outputs.
- Require explicit approval for production deploys, destructive Git operations,
  credential changes, or external side effects.

## Verification

Scale verification to risk. Prefer this sequence when applicable:

1. Focused Dart unit tests
2. Focused Flutter widget/integration tests
3. `flutter analyze`
4. Full `flutter test`
5. Target-platform build or APK build when acceptance requires it
6. Manual UAT workflow and regression checklist

Do not claim success for checks that were not run. Treat user UAT as the final
authority for user-visible behavior.

## Self-review

Review for bugs, null safety, async lifecycle errors, invalid IDs, transaction
gaps, unnecessary rebuilds, security/privacy problems, duplication, dead code,
memory leaks, architecture violations, localization gaps, and unrelated edits.

## Delivery format

Always report Pool OS engineering work using:

1. Analysis
2. Plan
3. Implementation
4. Files Modified
5. Risks
6. Manual Testing
7. Future Improvements

Keep the report factual. Include commands/checks actually run and disclose any
verification that remains pending.

