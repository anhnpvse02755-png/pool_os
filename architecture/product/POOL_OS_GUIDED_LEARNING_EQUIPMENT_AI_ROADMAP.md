# Pool OS Guided Learning, Equipment Research And AI Roadmap

Status: Accepted; Authoritative Product Sequence

Date: 2026-07-25

## Product Outcome

Pool OS will reach an invited Android pilot for 10-30 independent users. The
pilot combines Player-bound Match, Training, Career and Equipment evidence with
a bilingual Pool 8/9/10-ball curriculum, a traceable Coach, a Vietnam-first
Equipment catalog, and grounded AI research over catalog and live web sources.

The pilot remains local-first for personal facts. Account, community review,
cloud sync, club administration and affiliate commerce are outside this
roadmap. A managed relay may provide search and LLM access without shipping
provider secrets in the APK.

With one Product Owner/Engineer workflow supported by Codex, the complete pilot
is estimated at 68-88 weeks. This estimate is a planning range, not authority to
implement phases in parallel.

## Delivery Sequence

### Phase 1 - Player And Source Integrity

- FEATURE_004 Atomic Active Player Lifecycle.
- FEATURE_005 Player Profile Compatibility And Provenance.
- FEATURE_006-009 Match and Training identity, lifecycle, transactions and
  public source ports.
- FEATURE_010 Product request, failure and cancellation boundary.
- FEATURE_011 Player-scoped Experience state.
- FEATURE_012 Analytics Snapshot v2.
- FEATURE_013 Home Snapshot v2.

Gate: every non-empty local Player set has exactly one active identity and no
screen renders facts or projections from mixed Players.

### Phase 2 - Equipment Market Platform

- FEATURE_014 Versioned Equipment Market Pack.
- FEATURE_015 Product, variant, component and compatibility model.
- FEATURE_016 Vietnam new/used price snapshots and segment policies.
- FEATURE_017 review evidence and publication workflow.
- FEATURE_018 comparison and personal setup builder.

The canonical product kinds are `completeCue`, `cueButt`, `cueShaft` and
`cueTip`. A personal `customSetup` composes a butt, shaft and tip without
becoming a market product. Comparison accepts at most four products of the same
kind or four complete personal setups.

The initial published catalog targets 250-350 Vietnam-relevant SKUs: 60-90
complete cues, 50-80 butts, 80-110 shafts and 60-90 tip variants. Product facts
require official specification provenance. Editorial review synthesis requires
independent sources and must distinguish manufacturer claims, reviewer
observations and Pool OS summaries.

### Phase 3 - Knowledge And Guided Learning

- FEATURE_019 Knowledge pack compatibility and publication.
- FEATURE_020 typed Knowledge-to-Drill and Coach-to-Knowledge references.
- FEATURE_021 media provenance and external playback.
- FEATURE_022 learning paths, prerequisites and availability diagnostics.

Pilot content targets 100-140 bilingual Vietnamese/English lessons, 12-16
learning paths, 70-100 measurable drills and at least 90 attributed public
videos. Every core capability links lesson, video, drill, pass criteria and the
next eligible step. Public video means playback or navigation through the
original source; it does not authorize copying or repackaging media.

### Phase 4 - Deterministic Coach

- FEATURE_023 canonical Coach adapter.
- FEATURE_024 recommendation and Decision Trace.
- FEATURE_025 guided learning loop.
- FEATURE_026 achievement and progress projections.

The deterministic Coach remains the recommendation owner. It may point to
Knowledge, Training or Equipment Research, but market review never substitutes
for a Player's immutable Equipment Performance evidence.

### Phase 5 - Managed AI And Equipment Research

- FEATURE_027 managed AI relay and governance.
- FEATURE_028 grounded Coach conversation.
- FEATURE_029 evaluation, quota and offline fallback.
- FEATURE_030 Equipment search provider and web retrieval.
- FEATURE_031 product resolution and evidence claims.
- FEATURE_032 price normalization and criterion rating.
- FEATURE_033 personalized Equipment fit.
- FEATURE_034 research snapshots and comparison experience.

The Equipment experience follows the useful shape of a search AI overview: a
short synthesis, reference prices, criterion assessments, trade-offs,
conflicts, alternatives and claim-level source links. AI can make mistakes, so
every material statement remains inspectable and unsupported fields render as
unavailable rather than being inferred.

### Phase 6 - Android Pilot

Create a production-signed Android artifact, validate fresh install, upgrade,
restart, backup/restore, offline behavior, low storage, unavailable sources and
AI relay failure. Complete seven days of dogfood and at least four weeks with
10-30 invited users. Release requires no P0/P1 defect and green Product,
Knowledge, Foundation Freeze and Architecture Fitness evidence.

## Equipment Price Contract

New retail and used-market prices are separate observations and separate
segment classifications. `cheap`, `midRange`, `highEnd` and `luxury` thresholds
are versioned per product kind and market condition in VND; they are not UI
constants.

A price observation records product and variant identity, condition, amount,
currency, source, observed time and evidence type. Used listings distinguish an
asking price from a confirmed transaction price. Promotions, used goods sold as
new, custom one-offs and incompatible variants cannot silently affect the
reference range.

The overview may show new range, used range, reference median, depreciation
ratio and data confidence. Depreciation is a resale-liquidity/value-retention
signal, not proof that product quality is poor. Source conflicts and sparse
used-market samples remain visible.

## Guided Equipment Discovery

Before searching, AI may ask bounded questions that materially affect results:

- product kind and playing/break/jump role;
- new, used or either condition;
- budget or target segment;
- Player level, game type and playing style;
- preferred feedback, stiffness, diameter and deflection behavior;
- existing joint and component compatibility constraints.

Answers become a typed search request. AI cannot invent missing preferences,
and the user may skip discovery for direct search. Results expose two separate
values: deterministic evidence-based `QualityScore` and personalized
`FitScore`. A versioned rubric calculates both; the LLM may extract and explain
evidence but cannot assign scores directly.

## Equipment Assessment Rubric

Every criterion is scored from 0-10 only when evidence is sufficient and also
carries `low`, `medium` or `high` confidence. Missing evidence produces `N/A`
and is never converted to a neutral score.

- Complete cue and butt: finish/build, balance and feel, joint/upgradability,
  consistency, durability/warranty, value and Vietnam availability.
- Shaft: reported deflection, stiffness/feedback, taper/diameter/control,
  consistency, durability/maintenance, joint compatibility and value.
- Tip: hardness consistency, reported grip/chalk retention, feedback,
  durability/mushrooming, installation/maintenance, value and availability.

`QualityScore` reflects only the versioned evidence rubric. `FitScore` applies
the user's typed needs and hard compatibility constraints. A low used price or
high depreciation may affect value retention but cannot directly lower
technical quality.

## Research And Publication Boundary

Catalog search runs first. Missing or stale coverage may invoke live web
research. Every research result is a time-bound personal snapshot containing
query, locale, product/variant identities, URLs, access times, new/used price
observations, evidence claims, criterion assessments, policy/provider versions,
confidence, warnings and digest.

Web content is untrusted data and cannot issue instructions to the system.
Prompt injection, fabricated citations, unresolved variants and unsupported
compatibility fail closed. A saved research snapshot never auto-publishes to
the shared catalog. Catalog updates never rewrite saved snapshots or historical
Match Equipment attribution. The pilot has no affiliate ranking.

## Working Agreement

1. The user gives product ideas and requirements to the Product Owner task.
2. Product Owner resolves the contract and records the accepted plan in the
   repository.
3. Product Owner sends one exact implementation authorization to the Code task.
4. Code implements and runs the required suites, then sends an Engineering
   Report without commit or push.
5. Product Owner reviews business scope and Engineering evidence without
   duplicating the same test execution unless evidence is missing or
   contradictory.
6. After acceptance, Product Owner authorizes closure commit and push so both
   work computers remain synchronized.

This roadmap authorizes order, not simultaneous implementation. FEATURE_004 is
the only implementation authorized at roadmap start. Each later FEATURE
requires its own accepted specification and explicit Product Owner command.

## Pilot Acceptance Evidence

- Similar names and variants resolve without merging different product kinds.
- New, used asking, and confirmed used transaction prices remain distinct.
- Sparse, stale, promotional and outlier prices cannot create false segments.
- Every visible fact or review claim has a source; conflicts remain visible.
- Missing evidence produces `N/A`; the LLM cannot fabricate score or citation.
- Web prompt injection cannot alter system behavior or publication state.
- At most four products compare without Android overflow.
- Saved research snapshots remain immutable across catalog/web changes.
- Personal needs can change FitScore without changing QualityScore.
- FEATURE_002 historical Equipment attribution remains immutable.
- Full Product, Knowledge, Foundation Freeze and Architecture Fitness evidence
  remains green at every accepted implementation closure.
