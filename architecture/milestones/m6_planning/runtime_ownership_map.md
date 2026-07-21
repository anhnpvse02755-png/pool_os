# M6 Runtime Ownership Map

| Runtime concern | Owner | Reads | Writes |
|---|---|---|---|
| Knowledge publication/runtime load | Knowledge Runtime | authored/released Knowledge | generated release artifacts |
| Evidence ingestion and append-only history | Evidence Runtime | commands/artifacts | Evidence events/projections |
| Coach state and decision workflow | Intelligence Runtime | public Context/History/Knowledge contracts | versioned projections/decisions |
| AI boundary and provider calls | AI infrastructure/application boundary | activation/session/request contracts | derived response/projection artifacts |
| Persistence | Infrastructure | public persistence ports | storage records, never domain truth |
| Product interaction | Experience/API | public projections | commands only |

No AI component writes Coach, Evidence, Knowledge, Player, or Event state
directly. Persistence is a rebuildable implementation concern, not a new source
of truth.
