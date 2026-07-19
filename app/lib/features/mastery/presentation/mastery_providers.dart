import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/knowledge/presentation/providers/knowledge_providers.dart';
import 'package:pool_os/features/mastery/data/knowledge_learning_repository.dart';
import 'package:pool_os/features/mastery/domain/mastery_engine.dart';
import 'package:pool_os/features/mastery/domain/models/mastery_models.dart';
import 'package:pool_os/features/training_center/data/repositories/training_center_repository.dart';

final masterySnapshotProvider = FutureProvider<MasterySnapshot>((ref) async {
  final catalog = await ref.watch(knowledgeCatalogProvider.future);
  final evidence =
      await ref.watch(knowledgeLearningRepositoryProvider).getAll();
  final runs = await ref.watch(trainingCenterRepositoryProvider).getAllRuns();
  return MasteryEngine().build(
    catalog: catalog,
    learningEvidence: evidence,
    drillRuns: runs,
  );
});

final entryMasteryProvider =
    FutureProvider.family<EntryMastery?, String>((ref, entryId) async {
  final snapshot = await ref.watch(masterySnapshotProvider.future);
  return snapshot.entry(entryId);
});
