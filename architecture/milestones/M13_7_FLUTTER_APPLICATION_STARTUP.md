# M13.7 Flutter Application Startup

**Status:** Accepted; Closed
**Date:** 2026-07-22

M13.7 implements a deterministic Flutter startup boundary over accepted M13.6
`RuntimeExecutionState` and frozen M12.1 `FlutterApplicationAdapterPlan`.
These are the only Pool OS inputs imported by
`flutter_application_startup_runtime.dart`.

The M13-owned immutable `FlutterStartupAuthorization` explicitly
co-authorizes the exact execution-state and Flutter-plan IDs/digests without
claiming ancestry. The runtime validates the complete canonical feature plan,
then invokes only the abstract async `FlutterStartupExecutor`. It does not map
features to runtime services or execute Flutter.

Requests, targets, results, startup entries, fixed log, and aggregate state are
immutable, deterministic, provenance-bound, canonical, and replay-safe. The
fixed log is `validateAuthorization`, `orderStartup`, `bindFlutterCoverage`,
`invokeFlutterExecutor`, `completed`.

Stale authorization/state/plan, duplicate or gapped features, malformed plan
entries, orphan or incomplete results, duplicate target/handle, malformed
result, and stale request binding fail closed without fallback.

## Scope Boundaries

- No frozen M3-M12 or accepted M13.1-M13.6 artifact was changed.
- No feature-to-service/activation inference or ancestry reconstruction.
- No runApp, WidgetsFlutterBinding, MaterialApp/CupertinoApp, BuildContext,
  Navigator/Route, Widget, or Flutter execution.
- No Provider/Riverpod/Bloc, GetIt, scheduler, lifecycle implementation, HTTP,
  persistence, AI execution, object construction, global registry, or runtime
  mutation.

## Engineering Evidence

- Focused M13.7 tests: 8/8.
- Focused analyzer: no issues.
- Full app regression: 869/869.
- Knowledge package regression: 75/75.
- Protected M3-M12 freeze suites: 40/40.
- Architecture Fitness: 133 known violations / 0 new.
- `git diff --check`: clean.
- Frozen/protected sources and artifacts, Golden Fixtures, production
  Knowledge/publication, and generated plugin artifacts remain unchanged.

Product Owner accepted and closed M13.7 on 2026-07-22. M13.8 End-to-End
Production Runtime is authorized next with only `RuntimeFlutterStartupState`,
`InfrastructureIntegrationValidationPlan`, and the M13-owned
`ProductionRuntimeAuthorization`. No M13.8 source is included here.
