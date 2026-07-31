// EPIC 06 — read-only data sources snapshot for AI engines.
//
// PO 2026-07-31 — AI reads from EPIC 01-05 repositories. The Coach layer
// NEVER mutates upstream repositories. The `AiDataSnapshot` shape carries
// a denormalized projection that the engines understand; collecting it
// is the only time the Coach layer walks the data sources.
//
// The snapshot fields are typed as `dynamic` and `List<dynamic>` to
// avoid forcing this file to depend on every concrete model class.
// Engines read this through the typed accessors upstream; the snapshot
// is a transport surface, not a schema.

class AiDataSnapshot {
  final List<dynamic> matches;
  final dynamic statistics;
  final List<dynamic> programs;
  final List<dynamic> tournaments;
  final List<dynamic> knowledge;
  final List<dynamic> equipment;

  const AiDataSnapshot({
    this.matches = const <dynamic>[],
    this.statistics,
    this.programs = const <dynamic>[],
    this.tournaments = const <dynamic>[],
    this.knowledge = const <dynamic>[],
    this.equipment = const <dynamic>[],
  });

  static const AiDataSnapshot empty = AiDataSnapshot();
}