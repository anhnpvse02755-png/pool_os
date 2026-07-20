import 'package:billiard_knowledge/billiard_knowledge.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final knowledgeRepositoryProvider = Provider<KnowledgeRepository>((ref) {
  return KnowledgeRepository();
});

class KnowledgeRepository {
  static const packAsset = 'packages/billiard_knowledge/assets/pack_v1.json';

  KnowledgeCatalog? _catalog;

  Future<KnowledgeCatalog> load() async {
    final cached = _catalog;
    if (cached != null) return cached;

    final raw = await rootBundle.loadString(packAsset);
    final catalog = KnowledgeCatalog.fromJsonString(raw);
    final issues = catalog.validate();
    if (issues.isNotEmpty) {
      final summary = issues
          .take(5)
          .map((issue) => '${issue.code}: ${issue.message}')
          .join('; ');
      throw FormatException('Invalid Billiard Knowledge pack: $summary');
    }
    _catalog = catalog;
    return catalog;
  }

  void invalidate() => _catalog = null;
}
