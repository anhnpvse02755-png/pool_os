# E2 Club Domain Alignment And Gap Analysis

Status: Accepted; Closed

Date: 2026-07-24

## Decision Context

Club is an existing Product bounded context created by Task 14. E2 inventories
its ownership and compatibility surfaces before Product Expansion. This is a
documentation-only milestone: no code, schema, repository, persistence, UI,
runtime, capability, API or migration is introduced.

## Bounded Context Ownership

| Concern | Current owner | Evidence | Boundary |
| --- | --- | --- | --- |
| Club identity and profile | Club domain | `Club` | Does not own Player identity |
| Membership and role label | Club domain | `ClubMember`, `ClubRole` | `playerId` is a nullable soft reference |
| Source association | Club domain | `ClubLink`, `ClubLinkKind` | References Match, Training and Tournament by kind/id only |
| Internal ranking | Club domain | `ClubCalculator`, `ClubRankingRow` | Derived projection; does not own Match results |
| Club statistics | Club domain | `ClubCalculator`, `ClubStatistics` | Derived projection; not persisted |
| Club persistence | Club repository | `ClubRepository` | Owns Club tables and reads linked source tables |
| Product orchestration | Club presentation providers | `ClubController`, Riverpod providers | Invalidates Club read projections after writes |
| Product experience | Club presentation | list/create/detail screens and five tabs | Existing MVP; unchanged by E2 |

Player owns player identity/profile, Tournament owns tournaments, Match owns
recorded matches/racks, and Training owns training sessions. Club owns only its
membership and association records plus projections over linked source data.
`Player.clubRegion` is profile metadata and is not Club membership.

## Public API Inventory

### Domain Models

| API | Current semantic role |
| --- | --- |
| `ClubRole` | Owner/admin/member role code and `canManageMembers` metadata |
| `Club` | Persisted club profile |
| `ClubMember` | Persisted member/invite with optional Player reference |
| `ClubLinkKind` | Match/training/tournament discriminator |
| `ClubLink` | Persisted generic soft association to an external source row |
| `ClubMatchResult` | Read-only adapter projection of linked Match data |
| `ClubRankingRow` | Derived internal ranking/leaderboard row |
| `ClubStatistics` | Derived Club aggregate counts/names |
| `LeaderboardPeriod` | Week/month/year time-window selector |

The classes use final fields and replacement `copyWith`, but most do not
implement shared value equality. Nullable `copyWith` properties cannot be
explicitly cleared. Models have no schema version, provenance, typed identity
or canonical serialization.

### Domain Algorithms

| API | Current behavior |
| --- | --- |
| `ClubCalculator.ranking` | Points, win-rate, wins and name ordering with current streak |
| `ClubCalculator.leaderboard` | Ranking filtered by a wall-clock period |
| `ClubCalculator.statistics` | Match/rack/training totals and most-active/most-wins names |
| `LeaderboardPeriod.since` | Inclusive lower bound derived from a supplied time |

`ClubRankingRow.clubPoints` is fixed at three points per win and one point per
loss. This is current Product behavior, not a reusable ranking policy.

## Repository Inventory

`ClubRepository` is the sole Club persistence gateway and exposes:

- list, load, create, update and delete Club records;
- list, add, remove, role-update and invitation-confirm Member records;
- list, idempotently add and remove source links;
- resolve linked Match/Rack rows into `ClubMatchResult` projections;
- resolve linked Training rows into per-member training duration.

Deletion manually removes Club-owned Member and Link rows and never deletes the
referenced Player, Match, Training or Tournament rows.

## Persistence Inventory

Schema version 20 introduced three additive Drift tables:

| Table | Purpose | Cross-domain references |
| --- | --- | --- |
| `clubs` | Profile, local logo path, location, description and manager text | None |
| `club_members` | Role/invitation state and denormalized member name | Nullable `player_id` soft reference |
| `club_links` | Generic source association | `(kind, ref_id)` soft reference to Match, Training or Tournament |

There are no foreign keys into external domains. `ClubLink` makes source
deletion non-cascading; orphan links are tolerated and skipped by read paths.

## Provider And UI Inventory

Read providers expose Club list/detail, members, ranking, period leaderboard,
statistics and typed link filters. `ClubController` exposes Club CRUD, member
changes, role/invite changes and link changes, then invalidates derived reads.

Existing Product experience:

- `ClubListScreen`: list/create/delete entry.
- `ClubCreateScreen`: profile creation.
- `ClubDetailScreen`: Members, Ranking, Leaderboard, Statistics and History.
- Member, ranking, leaderboard, statistics and history tab widgets.
- Existing route: `/clubs`.

E2 changes none of these surfaces.

## Concept Alignment

| Future concept | Existing equivalent | Alignment decision |
| --- | --- | --- |
| Club | `Club` | Keep as compatibility aggregate; never recreate |
| Membership | `ClubMember` | Keep; future lifecycle must extend it additively |
| Club role | `ClubRole` | Keep as role code; permission enforcement is a separate concern |
| Club source association | `ClubLink` | Keep persisted generic link; add typed adapters rather than new link tables by default |
| Club ranking entry | `ClubRankingRow` | Keep as immutable projection, never aggregate |
| Club statistics | `ClubStatistics` | Keep as projection |
| Match contribution | `ClubMatchResult` | Keep as Club-facing adapter projection, not Match ownership |
| Leaderboard period | `LeaderboardPeriod` | Keep current display filter; do not treat as a ranking season |

## Ownership And Compatibility Risks

- `ClubRepository` directly reads internal Match, Rack and Training Drift tables
  instead of public application ports. This is existing cross-domain technical
  debt and must not be copied into future Club features.
- Match-to-member binding uses lower-cased opponent names, selects the first
  member with a `playerId` as "me", and may infer a winner from rack counts.
  These heuristics are not authoritative Player/Match identity contracts.
- `ClubRole.canManageMembers` is metadata only; controller/repository write
  operations do not enforce caller authorization.
- Club has denormalized `managerName` independent of owner/admin membership, so
  the two representations can diverge.
- Invitation state is a boolean only: there is no inviter, invite identity,
  expiry, rejection, cancellation or audit history.
- No uniqueness rule guarantees one Club owner, one membership per Player, or
  one role policy.
- Unknown persisted role/link codes silently fall back to member/match.
- The leaderboard provider reads `DateTime.now()` directly, so replay depends
  on wall-clock time. Month/year window behavior is not a versioned calendar
  policy.
- Invited members are not explicitly excluded from ranking inputs.
- Ranking points and tie-break order are hard-coded inside the projection.
- `mostImprovedMemberName` is supported by the result type but current providers
  do not calculate it, so it remains null.
- Linked Tournament history is an association only; Club does not own
  Tournament lifecycle, participants, brackets or standings.

## Genuine Missing Concepts

The following are absent and may justify later value-specific milestones:

- versioned Membership lifecycle and status transitions;
- Invitation aggregate/audit trail;
- explicit permission/authorization policy and acting member identity;
- typed Club-to-Match, Club-to-Training and Club-to-Tournament adapters;
- Club team/squad/roster distinct from generic membership;
- Club competition/league enrollment;
- Club event/calendar ownership;
- organization/federation hierarchy;
- ranking policy/version and ranking period identity;
- stable typed Club/Member identities and provenance;
- cross-device/community membership synchronization.

These are findings only. E2 implements none of them.

## Evolution Matrix

| Artifact | Action | Rationale / constraint |
| --- | --- | --- |
| `Club` | Keep/extend later | Permanent profile compatibility surface |
| `ClubMember` | Extend later | Canonical membership record; lifecycle additions must preserve stored rows |
| `ClubRole` | Keep | Preserve enum codes; enforce policy outside enum getters later |
| `ClubLink` | Keep behind typed adapters | Preserve generic table and idempotency; avoid parallel links |
| `ClubMatchResult` | Keep as adapter projection | Must be produced from authoritative ports in a later refactor |
| `ClubRankingRow` | Keep | Projection only; never evolve into aggregate |
| `ClubStatistics` | Keep | Projection only |
| `LeaderboardPeriod` | Keep as legacy filter | Future ranking period must be a distinct versioned concept |
| `ClubCalculator` | Extend behind policy later | Preserve current points/order until explicit compatibility packet |
| `ClubRepository` | Keep | Sole current persistence owner; future cross-domain reads should migrate to ports |
| Club providers/controller | Keep | Existing Product orchestration surface |
| Club UI and `/clubs` | Keep | Existing MVP compatibility surface |

No rename, merge, deprecation or implementation occurs in E2.

## Compatibility Strategy

1. Preserve current class names, enum codes, three Drift tables, provider names
   and `/clubs` route.
2. Preserve Player, Match, Training and Tournament ownership; Club stores only
   soft associations and Club-owned membership data.
3. Introduce typed read adapters before changing current direct cross-domain
   repository reads; never create a second source of Match/Training truth.
4. Add membership/invitation state additively with explicit compatibility for
   existing `invited` rows.
5. Keep `ClubRankingRow` and `ClubStatistics` as projections. Version future
   ranking policies instead of silently changing current points.
6. Inject an explicit clock before claiming deterministic period replay.
7. Fail closed for new unsupported codes through versioned adapters while
   retaining readability of current persisted codes.
8. Add characterization tests before any future milestone changes repository,
   ranking, authorization, link or membership semantics.
9. Do not add capability/runtime registration until a real cross-capability
   execution requirement is demonstrated.

## Accepted Product Policies

- Direct Match/Training persistence reads in `ClubRepository` are accepted
  technical debt. They must not be fixed during alignment reviews; typed
  adapters are introduced only when a concrete product feature requires them.
- Membership is a long-lived Club aggregate. Future work extends
  `ClubMember`; it must not create parallel Member profile/state/record concepts
  without a proven distinct requirement.
- `ClubLink` remains the persisted compatibility layer. Future typed adapters
  wrap it rather than replace it.
- Club statistics and `ClubRankingRow` remain projections. Ranking policy may
  become a future aggregate only when configurable rules or periods are a real
  Product requirement.

## Verification

- Inventory covers domain, algorithms, repository, persistence, providers, UI,
  routing and existing Task 14 tests.
- Existing concepts are separated from genuine gaps.
- Evolution and compatibility decisions are additive and ownership-preserving.
- Existing Club characterization tests: 10/10.
- Full app regression: 1184/1184.
- Knowledge package regression: 75/75.
- Foundation freeze: 76/76.
- Architecture Fitness: 133 existing violations, 0 new.
- `git diff --check`: clean.
- No Product code, schema, tests, UI, runtime or framework was changed.
- Diff is limited to the exact E2 documentation allowlist.

## Repository State

Product Owner accepted E2 on 2026-07-24 and authorized repository commit and
push without implementation changes.
