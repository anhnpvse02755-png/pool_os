# P1.6 Product Experience Flow & Navigation Planning

**Status:** Accepted; Closed
**Date:** 2026-07-23

## Objective

Define logical Product journeys, navigation and user-visible state without
designing or implementing UI. P1.6 preserves P1.1-P1.5 and the immutable M22
Foundation Freeze digest
`2086946d208e96093ae6699e36ab82bf174e9ec9630727abbce4691ec8c902fb`.

## Experience Ownership

Experience owns route intent, navigation history, presentation state,
accessibility semantics and rendering of owner-produced projections. Application
owns use-case orchestration. Capabilities own commands, domain state and
projections. Experience never infers Mastery, eligibility, recommendation,
authorization or workflow success.

Navigation changes what the user is viewing. It does not mutate an aggregate.
Domain mutation occurs only after a separately submitted P1.4 application
command succeeds; navigation reacts to its accepted result.

## Logical Entry Points

- application startup;
- authenticated/profile-resolved Product shell;
- authorized deep link with route identity and entity reference;
- notification/reference handoff through a future public Product link contract;
- deterministic recovery entry after restorable navigation failure.

An entry point passes through startup compatibility, access context and route
resolution gates. No deep link bypasses these gates.

## Logical Navigation Graph

```text
Startup
  -> Access/Profile Resolution
       -> Profile Selection (when required)
       -> Dashboard/Home
            -> Match List -> Match Create -> Match Detail -> Match Scoring
            -> Training List -> Training Session
            -> AI Coach Session
            -> Knowledge Browse -> Knowledge Detail
            -> Performance Analytics -> Snapshot Detail
            -> Simulation Request -> Simulation Result
            -> Settings

Any node -> typed Error/Recovery state -> prior safe node or Dashboard/Home
Any authorized detail node -> owner-defined related detail through typed reference
```

Arrows express permitted logical navigation, not Flutter routes or screen code.
Back navigation returns to the last valid safe node; it never reverses a command.

## Logical Screen Responsibilities

| Experience node | Renders/query responsibility | Permitted command intent |
|---|---|---|
| Startup | compatibility/loading/access resolution state | none |
| Access/Profile Resolution | access-context status and eligible profiles | select profile/request access flow |
| Dashboard/Home | owner-produced summary projections and pending actions | navigate only |
| Match List/Create | match summaries and creation input state | create match |
| Match Detail | Match/Rack projection plus Scoring reference | schedule/start/complete/cancel Match/Rack |
| Match Scoring | Scoring-owned scoreboard/history projection | record/correct score transition |
| Training List/Session | Training projection and accepted target references | plan/start/complete/cancel session |
| AI Coach Session | Coach Session and structured response projection | prepare/execute/cancel Coach session |
| Knowledge Browse/Detail | accepted published Knowledge projections | query/navigate only |
| Performance Analytics | immutable snapshots and source status | request rebuild/invalidation where authorized |
| Simulation Request/Result | request state and Platform result reference | prepare/submit/cancel request |
| Settings | effective/draft Product configuration projection | draft/activate/supersede/retire configuration |
| Error/Recovery | typed failure, source stage and safe actions | retry same intent only if authorized; dismiss/navigate |

These are responsibility labels only, not screen/page definitions or layouts.

## Primary User Journeys

### Startup And Profile

Startup validates Product/Platform compatibility, resolves access context and
routes deterministically to profile selection, Dashboard/Home or a typed blocking
error. Profile selection submits one application intent, then enters Home only
after an accepted profile/access result.

### Match Creation And Scoring

Home -> Match List -> Match Create submits create command -> accepted Match Detail
-> lifecycle commands -> Match Scoring for Scoring-owned commands/projection.
Returning to Match Detail never copies or writes Score state.

### Training

Home -> Training List -> plan session using accepted eligibility/Knowledge
references -> Training Session -> lifecycle commands. Knowledge/Simulation/Coach
links open only with typed references and return without mutating Training.

### AI Coach

Home or an authorized contextual link -> AI Coach Session -> prepare/execute via
AISession -> render structured CoachResponse/typed failure. Experience cannot
construct prompts, read raw Evidence or bypass the AI boundary.

### Knowledge And Analytics

Home -> Knowledge Browse -> Detail is query-only. Home -> Analytics -> Snapshot
Detail renders immutable rebuildable projections; rebuild/invalidation is an
explicit command, not refresh-side mutation.

### Settings And Simulation

Home -> Settings queries effective configuration and submits version-bound
commands. Home/context -> Simulation Request -> accepted request state -> Result;
Product renders the Platform result reference and never edits it.

## Command Query And Visible State Rules

Queries occur on node entry/refresh and return immutable version-bound
projections. Commands require explicit user intent, target one P1.4 service and
show `submitting` without assuming success. Accepted results render the owner
state/version; rejection renders typed failure while preserving last known valid
projection and clearly marking it stale when applicable.

Logical visible states are `initial`, `loading`, `ready`, `empty`, `submitting`,
`partial`, `stale`, `offline`, `unauthorized`, `notFound`, `incompatible` and
`failed`. A state is mutually exclusive at the primary node level and carries
source/query/request identity. Presentation details are not defined.

## Authorization-Dependent Navigation

Route visibility may be filtered by an accepted access decision, but hidden
navigation is not authorization enforcement. Every query/command/deep link is
re-authorized by its owner boundary. Changed/suspended access invalidates the
current protected node and routes to Access/Profile Resolution or a typed error.

Experience cannot invent roles, infer permission from a prior screen or retain a
successful route after its bound access context becomes stale.

## Cross-Capability Navigation

Permitted cross-links carry typed identity/version/provenance and open a public
query node: Match -> Scoring/Analytics; Training -> Knowledge/Simulation/AI Coach;
Analytics -> source Match/Training detail; Coach -> referenced structured Product
detail when authorized. Each target independently resolves its owner projection.

Prohibited shortcuts include writing Score from Match UI state, starting Training
from a Knowledge object without an application command, navigating directly to
raw Evidence, opening Platform internals, deriving authorization from a link,
using Coach generation as navigation authority or mutating on route entry.

## Deep-Link Identity Planning

A logical deep link carries route semantic ID/version, Product environment,
target entity/reference ID and version, optional safe return route, purpose and
correlation identity. It contains no secret, raw Evidence, mutable object or
provider payload. Route identity is stable and independent of labels/paths.

Resolution order is compatibility -> access context -> route version -> target
owner query -> target authorization -> projection version -> render. Unknown,
stale, unauthorized or incompatible links enter a typed recovery state; no
closest-route or stale-data fallback is allowed.

## Offline And Unknown Behavior

Offline is an explicit transport condition, not domain failure. A previously
verified projection may be displayed only with its bound version/provenance and
stale/offline status. Mutating intent is not accepted or queued unless a later
milestone explicitly authorizes offline command semantics. Unknown ownership,
version, target or state fails closed and offers safe navigation/re-resolution.

## Error And Recovery Flow

Errors preserve request/query identity, source owner/stage, category and last
safe node. Recovery options are deterministic: retry the same idempotent query or
permitted command, refresh access/version, return to the last safe node, or go to
Home. Recovery cannot alter intent, select another owner, erase partial progress
or claim success. Terminal command failure remains visible until acknowledged.

## Deterministic Navigation Rules

1. Resolve Product/Platform compatibility.
2. Resolve current access/profile context.
3. Validate route identity/version and declared source node.
4. Resolve target owner and typed entity/reference.
5. Obtain target authorization decision.
6. Query the bound immutable projection.
7. Select exactly one logical visible state.
8. Commit navigation history only after resolution.

Same route intent, access context and owner projection state produce the same
logical destination/state. Timing, rendering and animation cannot change it.

## Consistency Principles

Stable semantic route and action names, one source owner per displayed fact,
consistent typed failures, no mutation on navigation, explicit stale/offline
state, preserved context on recovery, accessible semantic intent and predictable
back behavior apply across every journey.

## Definition Of Done

- Required journeys, entry points, logical nodes and navigation graph are defined.
- Screen responsibilities remain logical and preserve capability ownership.
- Commands, queries, visible states, authorization, deep links and cross-links
  have deterministic fail-closed rules.
- Error/recovery/offline/unknown behavior is explicit.
- UI/Application/Domain separation and Platform boundaries remain intact.
- ADR-028 remains Proposed; no UI/runtime implementation exists.
- Exactly the four authorized P1.6 files change.

## Engineering Evidence

- Full app regression passes 969/969.
- Knowledge package regression passes 75/75.
- Protected M3-M22 Foundation Freeze chain passes 76/76.
- Architecture Fitness remains 133 existing violations with 0 new.
- Generated architecture health was restored to its protected baseline.
- Exactly the four authorized P1.6 files change and `git diff --check` is clean.
- Platform, freeze, production, Knowledge/publication, Golden Fixture and M2
  proof artifacts remain unchanged.
