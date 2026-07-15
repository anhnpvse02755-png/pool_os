import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/drill/data/drill_library.dart';
import 'package:pool_os/features/drill/domain/models/drill.dart';
import 'package:pool_os/features/knowledge/domain/models/knowledge_item.dart';

final knowledgeRepositoryProvider = Provider<KnowledgeRepository>((ref) {
  return KnowledgeRepository();
});

/// RFC-KB-002 — the read-only gateway to the Knowledge Pack. Loads bundled JSON
/// from `assets/knowledge/**` (the app's first asset-bundle loading; mirrors the
/// existing `Drill.fromJson` pattern) and caches it in memory. It NEVER writes,
/// and it NEVER copies drill content: a knowledge item only references drills by
/// code (`drillRefs`), and [drillsFor] resolves them live from [DrillLibrary]
/// (the single source of truth for drill content).
///
/// Assets can't be directory-listed at runtime, so the pack ships an index file
/// `assets/knowledge/index.json` (a list of relative item paths). Later the CMS
/// can serve the same shapes from an API with no model/UI change.
class KnowledgeRepository {
  static const String _indexPath = 'assets/knowledge/index.json';

  List<KnowledgeItem>? _cache;

  /// Load + cache all knowledge items. Idempotent.
  Future<List<KnowledgeItem>> getAll() async {
    if (_cache != null) return _cache!;
    final indexRaw = await rootBundle.loadString(_indexPath);
    final paths = (jsonDecode(indexRaw) as List).map((e) => e.toString());
    final items = <KnowledgeItem>[];
    for (final rel in paths) {
      final raw = await rootBundle.loadString('assets/knowledge/$rel');
      items.add(KnowledgeItem.fromJson(jsonDecode(raw) as Map<String, dynamic>));
    }
    _cache = items;
    return items;
  }

  Future<List<KnowledgeItem>> byType(KnowledgeType type) async =>
      (await getAll()).where((k) => k.type == type).toList();

  Future<List<KnowledgeItem>> byCategory(String category) async =>
      (await getAll()).where((k) => k.category == category).toList();

  Future<KnowledgeItem?> byId(String id) async {
    final all = await getAll();
    for (final k in all) {
      if (k.id == id) return k;
    }
    return null;
  }

  /// Resolve a Coach [KnowledgeId] (from the coach registry) to a knowledge item.
  /// The mapping is by convention: the coach id equals the item id, OR the item
  /// declares the coach id in its [KnowledgeItem.coachTriggers]. Returns null if
  /// nothing matches (the caller then falls back to a route).
  Future<KnowledgeItem?> byCoachKnowledgeId(String coachKnowledgeId) async {
    final all = await getAll();
    for (final k in all) {
      if (k.id == coachKnowledgeId) return k;
    }
    for (final k in all) {
      if (k.coachTriggers.contains(coachKnowledgeId)) return k;
    }
    return null;
  }

  /// Resolve a knowledge item's graph edges to the actual KnowledgeItems.
  Future<List<KnowledgeItem>> related(KnowledgeItem item) async {
    final all = await getAll();
    final ids = item.relatedKnowledge.map((r) => r.id).toSet();
    return all.where((k) => ids.contains(k.id)).toList();
  }

  /// Resolve a knowledge item's [KnowledgeItem.drillRefs] LIVE from DrillLibrary.
  /// Drill content is never duplicated into Knowledge — this reads the built-in
  /// drill repository each time. Unknown codes are skipped.
  List<Drill> drillsFor(KnowledgeItem item) {
    final out = <Drill>[];
    for (final code in item.drillRefs) {
      final d = DrillLibrary.getDrillByCode(code);
      if (d != null) out.add(d);
    }
    return out;
  }
}
