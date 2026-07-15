import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/knowledge/data/knowledge_repository.dart';
import 'package:pool_os/features/knowledge/domain/models/knowledge_item.dart';

// RFC-KB-002 — Knowledge providers. All read-only FutureProviders over the
// asset-backed repository. No writes, no persistence.

/// Every knowledge item in the pack.
final knowledgeAllProvider = FutureProvider<List<KnowledgeItem>>((ref) async {
  return ref.watch(knowledgeRepositoryProvider).getAll();
});

/// Knowledge items of one type (technique/mistake/equipment/mental/strategy).
final knowledgeByTypeProvider =
    FutureProvider.family<List<KnowledgeItem>, KnowledgeType>((ref, type) async {
  return ref.watch(knowledgeRepositoryProvider).byType(type);
});

/// One knowledge item by its semantic id.
final knowledgeByIdProvider =
    FutureProvider.family<KnowledgeItem?, String>((ref, id) async {
  return ref.watch(knowledgeRepositoryProvider).byId(id);
});

/// Resolve a Coach KnowledgeId (from the coach registry) to a knowledge item,
/// or null when the coach id maps to a plain route instead of an article.
final knowledgeByCoachIdProvider =
    FutureProvider.family<KnowledgeItem?, String>((ref, coachId) async {
  return ref.watch(knowledgeRepositoryProvider).byCoachKnowledgeId(coachId);
});
