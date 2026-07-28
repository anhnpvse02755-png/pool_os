# Pool OS Skill Routing

Use the smallest set of skills that covers the task.

| Task | Primary skill | Notes |
|---|---|---|
| Any non-trivial Pool OS work | `pool-os-engineering` | First-party scope, source precedence, and delivery format |
| Recall or save project decisions | `memory` | Mandatory; never store secrets |
| Durable architecture/corpus graph | `graphify` | Mandatory for graph work; scope narrowly and read report first |
| Dart domain/repository test | `dart-add-unit-test` | Use focused regression tests |
| Flutter widget behavior | `flutter-add-widget-test` | Validate rendering and interaction |
| End-to-end Flutter workflow | `flutter-add-integration-test` | Use for critical UAT flows |
| Static analysis | `dart-run-static-analysis` | Review automatic fixes before keeping them |
| Coverage | `dart-collect-coverage` | Use to locate high-risk untested rules |
| Package resolution failure | `dart-resolve-package-conflicts` | Preserve SDK and existing architecture constraints |
| Layering/architecture | `flutter-apply-architecture-best-practices` | Pool OS boundaries override generic advice |
| Responsive UI | `flutter-build-responsive-layout` | Test mobile/tablet/desktop constraints |
| Overflow/constraint failure | `flutter-fix-layout-issues` | Diagnose before editing |
| Routing/deep links | `flutter-setup-declarative-routing` | Preserve current GoRouter flow |
| GitHub review comments | `gh-address-comments` | Requires GitHub auth and selected comments |
| GitHub Actions failure | `gh-fix-ci` | Diagnose first; implement after approval |
| Flutter Web browser flow | `playwright` | Does not replace Flutter tests |
| OS-level capture | `screenshot` | Avoid private data in captures |
| Statistics exploration | `jupyter-notebook` | Keep notebook analysis separate from app business logic |
| Threat model | `security-threat-model` | Explicit security request only |
| Security ownership/bus factor | `security-ownership-map` | Requires Git history |
| Approved Supabase feature | `supabase` | Does not authorize adoption or migration |
| Approved Postgres work | `supabase-postgres-best-practices` | Apply after Supabase/Postgres scope is approved |

## Excluded project skill

Do not route Pool OS tasks to `godmode`. Its autonomous commit/reset/deploy
workflows conflict with Pool OS scope control and approval requirements.

