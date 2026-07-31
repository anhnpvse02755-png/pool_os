// EPIC 04 Phase 2.6 — Season domain model (skeleton only).
//
// PO 2026-07-31: NO Season Engine. This file is the place-holder so the
// navigation / UI shell can reference a stable shape. Persistence comes in a
// later Epic — no schema bump here.
//
// Architecture: Season groups [Tournament]s over a date range, optionally
// ranking them on a per-season ranking table. Phase 2 only defines the
// model. The engine (fixture generator, schedule builder, season standings)
// is post-Beta.

class Season {
  /// Stable identifier. Optional in skeleton because no schema yet.
  final int? id;

  /// Human label (e.g. "Summer 2026").
  final String name;

  /// Inclusive start of the season window.
  final DateTime startDate;

  /// Inclusive end of the season window.
  final DateTime endDate;

  /// Optional memo.
  final String? notes;

  const Season({
    this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    this.notes,
  });
}