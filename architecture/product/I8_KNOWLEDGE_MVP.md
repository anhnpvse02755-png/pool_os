# I8 Knowledge MVP

Status: Accepted; Closed

Date: 2026-07-24

## Objective

Deliver a Product-level Knowledge Center over the existing canonical Knowledge
package and frozen Product foundations. I8 does not create a search framework,
repository layer, schema or AI capability.

## Query Flow

```text
Knowledge Home / Category / Search
  -> KnowledgeMvpService
  -> P6 Knowledge capability compatibility preflight
  -> P8 Knowledge capability runtime bootstrap
  -> P9 QueryExecutor
  -> existing KnowledgeRepository asset loader
  -> canonical KnowledgeCatalog search
  -> Knowledge Home / Learning Path / Detail
```

## Implemented Behavior

- Knowledge Home displays existing Learning Paths and the complete catalog.
- Category chips expose every populated canonical `KnowledgeKind` with counts.
- Audience-level chips combine with category and text filters.
- Search delegates to the existing bilingual `KnowledgeCatalog.search` API.
- Learning Path steps open the existing Knowledge Detail experience.
- Detail continues to render explanation depth, related Knowledge, drills,
  sources and Mastery integration already owned by the existing feature.
- Existing Coach-to-Knowledge article navigation remains unchanged and valid.

Favorites were not implemented because no accepted favorites data or ownership
exists in the current Knowledge package. Adding persistence or schema solely for
Favorites would violate the I8 packet.

## Ownership And Reuse

- The Knowledge package remains the canonical owner of catalog data, search
  semantics, ordering, validation, paths and entry contracts.
- Existing `KnowledgeRepository` remains the asset-loading owner.
- The I8 application service owns Product browse-query traversal only.
- P6/P8 perform Knowledge capability compatibility preflight.
- P9 executes the private feature-local query and handler.
- Presentation renders returned entries and sends browse parameters; it does not
  rank, classify or infer Knowledge locally.

No vector database, embedding, ranking engine, AI search, network, API, new
runtime, repository, schema, framework, registry, bus or cross-domain business
behavior was introduced.

## Verification

- Focused I8 tests: 6/6.
- Focused analyzer: clean.
- Focused formatter and `git diff --check`: clean.
- Full app regression: 1162/1162.
- Knowledge package regression: 75/75.
- Foundation freeze: 76/76.
- Architecture Fitness: 133 existing violations, 0 new.
- Dependency and prohibition scans: clean.
- Generated Architecture Fitness health output restored to baseline.
- Protected Foundation M1-M22, P6-P9, Coach navigation, Knowledge package,
  persistence, schema and production artifacts are unchanged.
- Diff is limited to the exact I8 allowlist.

## Scope Confirmation

I8 is a concrete Product feature over accepted public boundaries. It reuses the
canonical catalog search and does not duplicate Foundation or package ownership.

## Repository State

Product Owner accepted I8 on 2026-07-24 and authorized repository commit and
push without redesign.
