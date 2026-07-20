import 'package:billiard_knowledge/billiard_knowledge.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/knowledge/data/knowledge_repository.dart';
import 'package:pool_os/features/mastery/domain/mastery_engine.dart';
import 'package:pool_os/features/mastery/domain/models/mastery_models.dart';
import 'package:pool_os/features/training_center/domain/models/training_center_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late KnowledgeCatalog catalog;
  final at = DateTime(2026, 7, 20);

  setUpAll(() async {
    catalog = await KnowledgeRepository().load();
  });

  LearningEvidence learned(String entryId) => LearningEvidence(
        entryId: entryId,
        eventType: LearningEventType.depthCompleted,
        depth: ExplanationDepth.result,
        packVersion: catalog.packVersion,
        occurredAt: at,
      );

  DrillRun run({
    required String entryId,
    required int attempts,
    required int successes,
    String drillCode = 'B001',
    int day = 0,
  }) =>
      DrillRun(
        sessionId: day + 1,
        drillCode: drillCode,
        knowledgeEntryId: entryId,
        drillName: drillCode,
        category: 'straightShot',
        targetReps: attempts,
        attempts: attempts,
        successes: successes,
        createdAt: at.add(Duration(days: day)),
      );

  test('new learner starts at first path step and later steps are locked', () {
    final snapshot = MasteryEngine().build(
      catalog: catalog,
      learningEvidence: const [],
      drillRuns: const [],
      now: at,
    );
    final path = snapshot.paths
        .firstWhere((item) => item.path.id == 'path.beginner.fundamentals');

    expect(path.nextEntryId, 'fundamental.stance.basic');
    expect(path.steps.first.current, isTrue);
    expect(path.steps[1].locked, isTrue);
    expect(path.steps.first.mastery.score, 0);
  });

  test('one strong run cannot produce reliable or mastered status', () {
    const entryId = 'fundamental.stance.basic';
    final snapshot = MasteryEngine().build(
      catalog: catalog,
      learningEvidence: [learned(entryId)],
      drillRuns: [
        run(entryId: entryId, attempts: 10, successes: 10),
      ],
    );
    final mastery = snapshot.entry(entryId)!;

    expect(mastery.score, greaterThan(0));
    expect(mastery.stage, MasteryStage.practicing);
    expect(mastery.isReliable, isFalse);
  });

  test('mastered requires volume plus three stable qualifying runs', () {
    const entryId = 'fundamental.stance.basic';
    final snapshot = MasteryEngine().build(
      catalog: catalog,
      learningEvidence: [learned(entryId)],
      drillRuns: [
        run(entryId: entryId, attempts: 10, successes: 8),
        run(entryId: entryId, attempts: 10, successes: 8, day: 1),
        run(entryId: entryId, attempts: 10, successes: 8, day: 2),
      ],
    );

    expect(snapshot.entry(entryId)!.stage, MasteryStage.mastered);
  });

  test('explicit knowledge link prevents cross-credit from the same drill', () {
    const stop = 'control.stop_shot';
    final snapshot = MasteryEngine().build(
      catalog: catalog,
      learningEvidence: [learned(stop)],
      drillRuns: [
        run(
          entryId: 'control.follow_shot',
          drillCode: 'B002',
          attempts: 25,
          successes: 25,
        ),
      ],
    );

    expect(snapshot.entry(stop)!.attempts, 0);
    expect(snapshot.entry(stop)!.stage, MasteryStage.practicing);
  });

  test('ambiguous legacy drill code grants no Mastery', () {
    final snapshot = MasteryEngine().build(
      catalog: catalog,
      learningEvidence: [learned('control.follow_shot')],
      drillRuns: [
        DrillRun(
          sessionId: 1,
          drillCode: 'B005',
          drillName: 'Basic Position Control',
          category: 'position',
          targetReps: 25,
          attempts: 25,
          successes: 25,
          createdAt: at,
        ),
      ],
    );

    expect(snapshot.entry('control.follow_shot')!.attempts, 0);
    expect(snapshot.entry('control.draw_shot')!.attempts, 0);
    expect(snapshot.entry('position.zone_planning')!.attempts, 0);
  });

  test('each learning path enforces its own explanation depth', () {
    const text = LocalizedText(en: 'Test', vi: 'Test');
    const entry = KnowledgeEntry(
      id: 'concept.test',
      kind: KnowledgeKind.concept,
      level: AudienceLevel.beginner,
      reviewState: ReviewState.draft,
      topic: 'test',
      title: text,
      summary: text,
      layers: [
        ContentLayer(
          depth: ExplanationDepth.result,
          heading: text,
          paragraphs: [text],
        ),
        ContentLayer(
          depth: ExplanationDepth.physics,
          heading: text,
          paragraphs: [text],
        ),
      ],
      sourceIds: [],
    );
    const beginner = LearningPath(
      id: 'path.beginner',
      title: text,
      description: text,
      level: AudienceLevel.beginner,
      steps: [LearningStep(entryId: 'concept.test')],
    );
    const advanced = LearningPath(
      id: 'path.advanced',
      title: text,
      description: text,
      level: AudienceLevel.advanced,
      steps: [
        LearningStep(
          entryId: 'concept.test',
          minimumDepth: ExplanationDepth.physics,
        ),
      ],
    );
    final custom = KnowledgeCatalog(
      packVersion: 'test',
      generatedAt: at,
      sources: const [],
      entries: const [entry],
      paths: const [beginner, advanced],
    );
    final snapshot = MasteryEngine().build(
      catalog: custom,
      learningEvidence: [
        LearningEvidence(
          entryId: entry.id,
          eventType: LearningEventType.depthCompleted,
          depth: ExplanationDepth.result,
          packVersion: 'test',
          occurredAt: at,
        ),
      ],
      drillRuns: const [],
    );

    expect(snapshot.paths.first.isComplete, isTrue);
    expect(snapshot.paths.last.isComplete, isFalse);
    expect(snapshot.paths.last.nextEntryId, entry.id);
    expect(snapshot.paths.last.steps.single.score, 0);
  });
}
