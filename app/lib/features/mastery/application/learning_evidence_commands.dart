import 'package:billiard_knowledge/billiard_knowledge.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/mastery/data/knowledge_learning_repository.dart';

final learningEvidenceCommandsProvider =
    Provider<LearningEvidenceCommands>((ref) {
  return LearningEvidenceCommands(
      ref.watch(knowledgeLearningRepositoryProvider));
});

class LearningEvidenceCommands {
  final KnowledgeLearningRepository _repository;

  const LearningEvidenceCommands(this._repository);

  Future<void> recordDepthCompleted({
    required String entryId,
    required ExplanationDepth depth,
    required String packVersion,
  }) {
    return _repository.recordDepthCompleted(
      entryId: entryId,
      depth: depth,
      packVersion: packVersion,
    );
  }
}
