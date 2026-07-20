import 'package:billiard_knowledge/billiard_knowledge.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/mastery/domain/models/mastery_models.dart';
import 'package:pool_os/features/player/data/database/app_database.dart' as db;
import 'package:pool_os/features/player/data/providers/database_providers.dart';

final knowledgeLearningRepositoryProvider =
    Provider<KnowledgeLearningRepository>((ref) {
  return KnowledgeLearningRepository(ref.watch(databaseProvider));
});

class KnowledgeLearningRepository {
  final db.AppDatabase _db;

  KnowledgeLearningRepository(this._db);

  Future<void> recordDepthCompleted({
    required String entryId,
    required ExplanationDepth depth,
    required String packVersion,
    DateTime? occurredAt,
  }) async {
    final existing = await (_db.select(_db.knowledgeLearningEvents)
          ..where((row) =>
              row.entryId.equals(entryId) &
              row.eventType.equals(LearningEventType.depthCompleted) &
              row.depth.equals(depth.name))
          ..limit(1))
        .getSingleOrNull();
    if (existing != null) return;

    await _db.into(_db.knowledgeLearningEvents).insert(
          db.KnowledgeLearningEventsCompanion.insert(
            entryId: entryId,
            eventType: LearningEventType.depthCompleted,
            depth: Value(depth.name),
            packVersion: packVersion,
            occurredAt: occurredAt ?? DateTime.now(),
          ),
        );
  }

  Future<List<LearningEvidence>> getAll() async {
    final rows = await (_db.select(_db.knowledgeLearningEvents)
          ..orderBy([(row) => OrderingTerm.asc(row.occurredAt)]))
        .get();
    return rows
        .map((row) => LearningEvidence(
              id: row.id,
              entryId: row.entryId,
              eventType: row.eventType,
              depth:
                  row.depth == null ? null : ExplanationDepth.parse(row.depth!),
              packVersion: row.packVersion,
              source: row.source,
              occurredAt: row.occurredAt,
            ))
        .toList(growable: false);
  }
}
