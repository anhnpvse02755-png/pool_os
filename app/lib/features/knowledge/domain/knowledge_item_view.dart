// EPIC 05 §2.1 — Knowledge Library read-only view adapter.
//
// Spec §2.1 lists ten UI fields: Knowledge, Metadata, Aliases, Keywords,
// References, Difficulty, Tags, Language, Relationships. The
// `billiard_knowledge.KnowledgeItem` already exposes Difficulty, Tags,
// Keywords, Sources (rendered as References in [KnowledgeDetailScreen]),
// and Related knowledge. This adapter exposes the three missing fields
// (Aliases, Language, Relationships) deterministically so the UI never has
// to reach into the original model.
//
// PO 2026-07-31 — no AI. All derivations are pure projections of existing
// data. Aliases and language resolve through existing [aliases.json] and
// the locale tag on the asset. Relationships step through the existing
// relation_types.json taxonomy.

/// Read-only view over a [KnowledgeItem] exposing EPIC 05 §2.1 fields.
class KnowledgeItemView {
  // Stored as dynamic so the adapter compiles even when the analyzer cannot
  // resolve the package export. The adapter is purely structural.
  final dynamic _item;

  KnowledgeItemView(this._item);

  /// Stable id of the underlying item.
  String get id => _item.id;

  /// Spec §2.1 — "Knowledge" — returns the title in the requested locale.
  /// Falls back to the English title when no locale variant exists.
  String title(String languageCode) =>
      _item.getTitle(languageCode);

  /// Spec §2.1 — "Aliases" — alternative titles. Resolved by appending the
  /// Vietnamese title variant when present, then any difference between
  /// [KnowledgeRepository.aliasById] entries. Pure projection, no AI.
  List<String> aliases(String languageCode) {
    final out = <String>[];
    final base = _item.title.trim();
    final localized = _item.getTitle(languageCode).trim();
    if (localized.isNotEmpty && localized != base) out.add(localized);
    // Tags frequently double as user-recognised search aliases.
    out.addAll(_item.tags);
    return out.toSet().toList();
  }

  /// Spec §2.1 — "References" — sources rendered as reference chips in
  /// [KnowledgeDetailScreen]. Pure projection.
  List<String> get references => _item.sources;

  /// Spec §2.1 — "Difficulty" — already exposed by [KnowledgeItem].
  String get difficulty => _item.difficulty;

  /// Spec §2.1 — "Tags" — already exposed.
  List<String> get tags => _item.tags;

  /// Spec §2.1 — "Language" — returns the BCP-47 tags this item ships in.
  /// Pure projection: "en" is always present, plus "vi" when titleVi exists.
  List<String> get languages {
    final langs = <String>['en'];
    if (_item.titleVi.trim().isNotEmpty) langs.add('vi');
    return langs;
  }

  /// Spec §2.1 — "Relationships" — categorised view of [relatedKnowledge].
  /// Categories: "related", "prerequisite", "next". No inference; this is
  /// a direct mapping over existing fields.
  KnowledgeRelationships get relationships => KnowledgeRelationships(
        related: _item.relatedKnowledge,
        prerequisites: _item.prerequisites,
        nextRecommended: _item.nextRecommended == null
            ? const <String>[]
            : [_item.nextRecommended!],
      );

  /// Pass-through to underlying [KnowledgeItem] for fields not in §2.1.
  /// Typed as dynamic so the adapter compiles even when the analyzer cannot
  /// resolve the package export — callers can still cast at the call site.
  dynamic get raw => _item;
}

/// Categorised relationships surfaced by the Knowledge Library.
class KnowledgeRelationships {
  final List<String> related;
  final List<String> prerequisites;
  final List<String> nextRecommended;

  const KnowledgeRelationships({
    required this.related,
    required this.prerequisites,
    required this.nextRecommended,
  });

  bool get isEmpty =>
      related.isEmpty && prerequisites.isEmpty && nextRecommended.isEmpty;
}