# Post-UAT V1 Actions

## Purpose

This file converts the "Version Next - Product Direction Summary" into
implementation work that Claude/Cursor can execute. It is not a new product
Bible, RFC, or replacement roadmap.

Current product direction:

> Pool OS should become a personal pool coach. The player opens the app,
> follows the next useful action, and can see measurable progress.

## Verified Baseline

- Bottom navigation currently has five destinations: Dashboard, Session,
  Equipment, Coach, and Statistics.
- Dashboard currently renders quick actions plus readiness, equipment, Coach,
  skill radar, weekly/monthly trends, recent matches, and recent sessions. It
  mixes summary and execution workflows.
- Training Center already contains drills, training sessions, progress,
  Knowledge articles, and a Ghost entry point.
- Knowledge items contain type, difficulty, sections, mistakes, corrections,
  related drills, and references, but do not model progressive explanation
  depth such as Result / Cause / Principles / Physics.
- Built-in drills contain target repetitions and common mistakes. The live
  Training session supports Hit/Miss and an attempt target, but has no general
  scoring-mode model for time, percentage, difficulty, Coach, or learning path.
- Routine exists only as drill/content entries; there is no routine consistency
  module.
- Match review is manual. Video review and table-photo analysis do not exist.

## Current Priority

Do not start the navigation redesign or AI research features until the current
UAT-fix branch compiles, tests pass, and the remaining UAT blockers are closed.

## UAT V1.0 Execution Status (2026-07-19)

This is the execution checklist for UATV1.0_01 through UATV1.0_08. It updates
the existing action file; it is not a new roadmap.

### Completed in code

- [x] Daily Readiness has an explicit Save action and Close action.
- [x] Back/gesture on Daily Readiness saves first, then returns to the previous
  screen. Dashboard opens it with navigation history instead of replacing the
  current route.
- [x] Daily Readiness is stored in SQLite, upserts by date, survives a database
  restart, and migrates legacy schema-v22 rows.
- [x] Saving a Shot stays on the screen, shows feedback, resets the form, and
  blocks repeated Save for two seconds.
- [x] Dashboard only shows Continue/Finish when an active Session exists.
- [x] Multiple unfinished Sessions are reconciled transactionally: the newest
  remains active and stale Sessions plus their open Matches are closed.
- [x] Tournament supports individual/team mode, optional third place, automatic
  completion after the final, and manual Finish.
- [x] Dashboard Coach ignores statistics with sample size below five and does
  not fall back to an unverified recommendation when statistics loading fails.
- [x] Today's Focus is one priority; the Coach list filters that duplicate and
  displays up to five other recommendations.
- [x] Dashboard equipment includes playing, break, and jump cues.
- [x] Drill sessions enforce the attempt limit and require a Miss Reason or
  Unknown for failed attempts.
- [x] Drill list items start the selected Training Session directly.
- [x] Knowledge can start a related Drill, Common Mistakes can open corrective
  Drills, Related Drills open the exact Drill, and Learning Path exposes Next.
- [x] Theme, locale, and measurement settings are written to the active player
  row in SQLite and restored when Settings is recreated.
- [x] Session Summary only evaluates win rate from at least three racks and shot
  accuracy from at least ten shots. Break & Run now requires a won rack with at
  least three recorded shots and no misses.
- [x] Match creation no longer offers Practice/Warm-up. It requires a Race,
  opponent, and Objective (Win/Training/Mixed). Training remains in Training
  Center.
- [x] Match Objective policy is covered for 70/30, 20/80, and 50/50 weighting,
  including persisted-objective Coach evaluation.

### Automated verification

- [x] Full Flutter test suite: 151/151 passed.
- [x] New regression coverage: Settings persistence and stale Session cleanup.
- [x] Dart analyzer reports no compile errors. Current baseline is 65 info-only
  lint items; the previous unused Session dialog warning was removed.
- [x] `git diff --check` passes (line-ending notices only).

### Still requires UAT before closing P0

- [ ] Run the eight UAT groups on an Android device, including physical Back,
  edge-swipe Back, process kill, and app restart.
- [ ] Verify every non-Home screen returns inside the app. Automated inspection
  covers the reported Readiness and Match routes, but not every device route.
- [ ] Complete a visual localization sweep. The named labels (Readiness, Session
  Summary, Coach Summary, and Play more sessions) have Vietnamese mappings, but
  Statistics detail dialogs still contain some English explanatory copy.
- [ ] Confirm Theme switching visually on Android for System, Light, and Dark.
- [ ] Decide whether finished Match Sessions should be reopenable. Current
  Continue supports it while guaranteeing only one open Session.

### P0 - Close UAT V1

1. Run `flutter analyze` and the full widget/unit test suite on a machine with
   Flutter SDK. Fix all errors introduced by `codex/uat-fixes`.
2. Re-run the latest UAT checklist on Android, including back gestures and app
   restart persistence.
3. [x] Add tournament competition mode: individual or team.
4. [x] Add optional third-place match with correct loser propagation from the two
   semifinals.
5. [x] Persist Training miss reasons instead of keeping them only in the live
   screen state.
6. [x] Make Coach evaluation use `matchObjective`: result has high weight for
   `win`, low weight for `training`, and balanced weight for `mixed`.

Definition of done:

- No known data-loss or stale-state UAT issue remains.
- Analyzer and automated tests pass.
- Every P0 behavior has a regression test where the logic can be tested without
  device interaction.

## Next Implementation Batches

### P1 - Information Architecture

Change bottom navigation to exactly four product areas:

1. Dashboard
2. Match
3. Training
4. Coach

Routing ownership:

- Match owns normal matches, tournaments, leagues, and match history.
- Training owns Learning Hub, practice sessions, drills, Ghost, and progress.
- Statistics becomes a Dashboard detail screen.
- Equipment moves to Profile / Inventory.

Dashboard constraints:

- Remove direct execution workflows except one clear continue/next action.
- Each section shows only status, short summary, and a route to details.
- Initial target: Today/Readiness, Coach priority, progress summary, recent
  activity, and one continue action.
- Do not delete underlying feature screens or repositories during the routing
  change.

Acceptance criteria:

- All existing features remain reachable in at most three taps.
- Bottom navigation preserves independent state for all four branches.
- Dashboard has no duplicate Coach recommendation or duplicate statistics
  presentation.
- Router widget tests cover every moved destination and system back behavior.

### P2 - Learning Hub MVP

Extend the existing Knowledge system rather than creating another content
module.

Required additions:

- Audience level: beginner, fundamental, intermediate, advanced, professional.
- Explanation depth: result, cause, principles, physics/developer reference.
- Topic taxonomy including stance, bridge, grip, aim, routine, cue-ball
  control, position, pattern, safety, kick, bank, jump, break, mental,
  equipment, strategy, pressure, and tournament play.
- Common-mistake entries with symptoms, causes, corrections, drills, and media
  references.
- Vietnamese terminology/aliases stored as searchable metadata, not embedded
  only in display paragraphs.

Start with beginner content because it is the primary onboarding path. Do not
bulk-generate the entire knowledge catalog before the schema, search, depth
selector, and one complete learning path are proven in UI.

Acceptance criteria:

- A user can choose how deeply an article explains a concept.
- Search finds both standard terms and Vietnamese player terminology.
- One beginner learning path links knowledge, common mistakes, drills, and
  progress from start to finish.
- Every factual article retains source metadata and review status.

### P3 - Coach Closed Loop

Evolve Coach from text advice into an executable loop:

1. Observe player goal, history, current readiness, and match objective.
2. Select one priority that improves the player's performance floor.
3. Assign knowledge, a drill, or a challenge.
4. Measure completion and compare later performance with sufficient samples.
5. Keep, adjust, or replace the assignment with an evidence explanation.

The first success metric is consistency, not peak score: reduce the gap between
good and bad sessions and improve performance on low-readiness days.

## Research Queue - Not Implementation Work Yet

Keep these as discovery items until P0-P3 produce stable data and workflows:

- Short video capture and analysis of failed shots.
- Table-photo ball detection and layout reconstruction.
- Run-out, safety, bank, kick, pattern, and cue-ball route proposals.
- Physics simulation and a billiards-playing bot.

Each research item needs a separate feasibility spike covering data, model
accuracy, device performance, privacy, operating cost, and fallback UX before
it can enter the implementation backlog.

## Guardrails

- Do not create a parallel Learning Hub, Training, Statistics, or Coach data
  model when an existing module can be extended.
- Do not infer coaching conclusions from zero or very small samples.
- Do not copy source material. Store provenance, cross-check sources, and write
  original explanations.
- Do not make manual logging heavier. Every new field must justify the extra
  tap or be captured automatically.
- Do not begin a later batch while its required earlier batch is incomplete.
