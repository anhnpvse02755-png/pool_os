# Pool OS Project Source Map

Use this map to choose sources; do not load the full documentation corpus for
every task.

## Always read

- `MEMORY.md`: durable decisions, mandatory Memory/Graphify policy, legacy import
- `app/pubspec.yaml`: current language, SDK, packages, and framework truth
- `Pool OS Development Rules.md`: UAT-first change and scope rules
- `DS-001 - Development & Bug Fix Rules`: detailed investigation, architecture,
  Riverpod, repository, database, and Coach standards

## Product and priority

- `00_PROJECT.md`: current Flutter/offline product description
- `00_PRODUCT_VISION.md`: product identity and decision philosophy
- `MASTER_IMPLEMENTATION_PRIORITY.md`: historical active priority baseline; verify
  status against code and newer UAT before treating an item as open
- `PRODUCT_GAP_ANALYSIS_V2_ALPHA.md`: identified product gaps
- `PRODUCT_COMPLETION_REPORT.md`: completion evidence and remaining work

## Domain and intelligence

- `02_DOMAIN_DEFINITIONS_*.md`: billiards domain definitions
- `DOMAIN_DEFINITIONS_REFERENCE.md`: larger domain reference
- `09_COACH_AI_RULEBOOK_PART_*.md`: Coach rules
- `10_INTELLIGENCE_ENGINE.md`: intelligence pipeline
- `10_STATISTICS_ENGINE_PART_*.md`: statistics definitions and calculations
- `RFC-010*` through `RFC-019*`: Coach, sessions, statistics, training, workflow,
  UI, and business-logic contracts

## Data, API, and architecture

- `app/lib/features/player/data/database/app_database.dart`: executable Drift
  schema; current code beats stale schema prose
- `11_DATABASE_SCHEMA_PART_01.md`: intended data model, subject to current schema
- `12_API_SPECIFICATION_PART_01.md`: intended internal contracts
- `RFC_001_DOMAIN_MODEL_REFACTOR.md`: domain refactor decisions
- `RFC_002_SKILL_ENGINE_ARCHITECTURE.md`: product Skill Engine, unrelated to Codex
  agent skills
- `RFC-020 - Definition of Done (DoD).md`: acceptance checklist

## UI and navigation

- `app/lib/app/router/app_router.dart` and current screen code: executable truth
- `DS-003-UX-Architecture.md`: UX architecture reference
- `15_COMPONENT_LIBRARY.md`: intended component guidance

## Legacy warnings

- `13_FOLDER_STRUCTURE.md` currently describes `src/` and TypeScript/React. Do not
  use it to restructure the Flutter app.
- `14_CODING_STANDARDS.md` currently says TypeScript-only. Do not apply that rule
  to Dart.
- Recovered `.cursorrules` history contains obsolete Node/React/Kotlin context.
  Use `memory/2026-06-30-legacy-cursor-memory.md` only as dated history.
- DOCX and Markdown duplicates may diverge. Prefer the latest approved source and
  current executable behavior; report material conflicts.

## Source selection examples

- Match bug: latest UAT/FIX -> Match/Rack code -> relevant provider/repository ->
  Drift schema -> RFC-011/RFC-019 -> tests
- Coach recommendation: Coach rulebook -> statistics/coach code -> RFC-010/012/013/015
- Database issue: current Drift schema -> repository -> migration history ->
  applicable approved RFC -> schema prose
- UI layout issue: current widget -> UAT screenshot/report -> UX architecture ->
  component library

