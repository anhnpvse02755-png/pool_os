import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/coach_memory/data/coach_memory_repository.dart';
import 'package:pool_os/features/coach_memory/domain/coach_memory.dart';
import 'package:pool_os/features/coach_memory/domain/coach_memory_consolidator.dart';
import 'package:pool_os/features/mastery/domain/models/mastery_models.dart';
import 'package:pool_os/features/performance/domain/performance_snapshot.dart';
import 'package:pool_os/features/player/data/database/app_database.dart';

void main() {
  late AppDatabase db;
  late CoachMemoryRepository repository;
  final now = DateTime(2026, 7, 20);

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = CoachMemoryRepository(db);
  });

  tearDown(() => db.close());

  MemoryObservation observation(String signature, {double value = 55}) =>
      MemoryObservation(
        memoryKey: 'performance.weakness.execution',
        kind: CoachMemoryKind.weakness,
        sourceMetricId: 'performance.execution',
        latestValue: value,
        sampleSize: 20,
        confidence: 0.67,
        evidenceSignature: signature,
      );

  test('unchanged evidence is idempotent; changed evidence increments once',
      () async {
    await repository.synchronize([observation('v1')], observedAt: now);
    await repository.synchronize([observation('v1')], observedAt: now);
    var memory = (await repository.getAll()).single;
    expect(memory.occurrenceCount, 1);
    expect(memory.revision, 1);

    await repository.synchronize(
      [observation('v2', value: 52)],
      observedAt: now.add(const Duration(days: 1)),
    );
    memory = (await repository.getAll()).single;
    expect(memory.occurrenceCount, 2);
    expect(memory.revision, 2);
    expect(memory.latestValue, 52);
  });

  test('a pattern absent from the next snapshot becomes resolved', () async {
    await repository.synchronize([observation('v1')], observedAt: now);
    await repository.synchronize(
      const [],
      observedAt: now.add(const Duration(days: 1)),
    );

    final memory = (await repository.getAll()).single;
    expect(memory.status, CoachMemoryStatus.resolved);
    expect(await repository.getAll(activeOnly: true), isEmpty);
  });

  test('consolidator stores patterns, never recommendations', () {
    final performance = PerformanceSnapshot(
      generatedAt: now,
      sourceMatches: 5,
      sourceRacks: 20,
      sourceShots: 40,
      metrics: {
        PerformanceDimension.execution: const PerformanceMetric(
          dimension: PerformanceDimension.execution,
          score: 55,
          sampleSize: 20,
          requiredSample: 8,
          confidence: PerformanceConfidence.medium,
          methodologyId: 'performance.execution.outcome.v1',
        ),
      },
    );
    final observations = CoachMemoryConsolidator().evaluate(
      performance: performance,
      mastery: MasterySnapshot(
        generatedAt: now,
        entries: const {},
        paths: const [],
      ),
    );

    expect(observations.single.kind, CoachMemoryKind.weakness);
    expect(observations.single.sourceMetricId, 'performance.execution');
  });
}
