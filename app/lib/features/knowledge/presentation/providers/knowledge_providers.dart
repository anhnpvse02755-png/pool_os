import 'package:billiard_knowledge/billiard_knowledge.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/knowledge/application/knowledge_mvp_service.dart';
import 'package:pool_os/features/knowledge/data/knowledge_repository.dart';

final knowledgeMvpServiceProvider = Provider<KnowledgeMvpService>((ref) {
  return KnowledgeMvpService(ref.watch(knowledgeRepositoryProvider).load);
});

final knowledgeBrowseProvider =
    FutureProvider.family<KnowledgeBrowseView, KnowledgeBrowseRequest>(
        (ref, request) async {
  return ref.watch(knowledgeMvpServiceProvider).browse(request);
});

final knowledgeCatalogProvider = FutureProvider<KnowledgeCatalog>((ref) async {
  return ref.watch(knowledgeRepositoryProvider).load();
});

final knowledgeEntryProvider = FutureProvider.family<KnowledgeEntry?, String>((
  ref,
  id,
) async {
  final catalog = await ref.watch(knowledgeCatalogProvider.future);
  return catalog.entryById(id);
});

final knowledgeCoachEntryProvider =
    FutureProvider.family<KnowledgeEntry?, String>((ref, coachId) async {
  final catalog = await ref.watch(knowledgeCatalogProvider.future);
  final direct = catalog.entryById(coachId);
  if (direct != null) return direct;
  final normalized = coachId.replaceAll('_', '.');
  return catalog.entryById(normalized);
});
