# DEBUG-002 RUNTIME REPORT

**Date:** July 8, 2026  
**Mode:** RUNTIME DEBUG ONLY  
**Device:** Chrome (web-javascript)  
**Flutter Output:** `terminals/90387.txt`

---

## EXECUTION RESULT

`flutter run -d chrome` **FAILED AT LAUNCH**.

The application did not reach runtime. No Flutter UI was rendered. No user interaction was possible.

### Blocker Exception

```
../../../../../AppData/Local/Pub/Cache/hosted/pub.dev/drift-2.23.1/lib/src/sqlite3/database_tracker.dart:1:8: Error: Dart library 'dart:ffi' is not available on this platform.
import 'dart:ffi';
```

### Blocker Exception

```
Error: Building with plugins requires symlink support.

Please enable Developer Mode in your system settings. Run
  start ms-settings:developers
```

### Complete Stack Trace Summary

The failure originates from `dart:ffi` being unavailable on the web platform. The compiler traces the import path through:

- `package:pool_os/main.dart`
- `package:pool_os/app/router.dart`
- `package:pool_os/app/router/app_router.dart`
- `package:pool_os/features/dashboard/presentation/dashboard_screen.dart`
- `package:pool_os/features/dashboard/presentation/dashboard_provider.dart`
- `package:pool_os/features/session/data/repositories/session_repository.dart`
- `package:pool_os/features/player/data/database/app_database.dart`
- `package:drift/native.dart`
- `package:sqlite3/sqlite3.dart`
- `package:sqlite3/src/ffi/api.dart`
- `dart:ffi`

### First Project File in Stack Trace

`app/lib/features/player/data/database/app_database.dart`

### Root Cause

The current debug target is Chrome/web. The project database layer depends on `drift` + `sqlite3`, which require `dart:ffi`. `dart:ffi` is unavailable on web, so the debug build fails before any screen is rendered.

### Evidence

- `flutter devices` reported only `Windows`, `Chrome`, and `Edge`.
- `flutter run -d chrome` exited with code `1`.
- Terminal output contains repeated `dart:ffi` import errors through drift/sqlite3 paths.

### Affected Modules

- Player/Data/Database
- Session/Data/Repositories
- Dashboard/Presentation
- All downstream screens that import the database/repository layer

### Recommended Fix Location

`app/lib/features/player/data/database/app_database.dart` and the repository layer that imports native drift on web.

---

## BUG REPRODUCTION STATUS

| Bug | Can Reproduce | Result |
|-----|---------------|--------|
| BUG-001 Dashboard Crash | NO | NOT REPRODUCED |
| BUG-002 Session Race | NO | NOT REPRODUCED |
| BUG-003 Match Grey Screen | NO | NOT REPRODUCED |
| BUG-004 Session UI | NO | NOT REPRODUCED |
| BUG-005 Shot/Event No Save | NO | NOT REPRODUCED |
| BUG-006 Drill Grey Screen | NO | NOT REPRODUCED |
| BUG-007 Equipment Tick | NO | NOT REPRODUCED |
| BUG-008 Coach Grey Screen | NO | NOT REPRODUCED |
| BUG-009 Statistics Grey Screen | NO | NOT REPRODUCED |

### Reason

All 9 bugs are blocked by the same runtime blocker: the app cannot launch in Chrome debug mode because `dart:ffi` is unavailable on web. No screens were rendered, no interactions were performed, and no Flutter console runtime exceptions were collected.

---

## NEXT STEP NEEDED

Run debug on a supported native target, such as:

- `flutter run -d windows`
- `flutter run` on a connected Android/iOS device

Then reproduce the 9 bugs and collect runtime stack traces.
