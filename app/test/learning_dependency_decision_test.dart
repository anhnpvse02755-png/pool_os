import 'dart:io';

import 'package:billiard_knowledge/billiard_knowledge.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/stop_shot_contracts.dart';
import 'package:pool_os/features/coach/application/learning_runtime.dart';
import 'package:pool_os/features/event/domain/stop_shot_evidence_log.dart';

void main() {
  late ExecutableKnowledgePack pack;

  setUpAll(() {
    pack = ExecutableKnowledgePack.fromJsonString(
      File(
        '../packages/billiard_knowledge/test/fixtures/lr_2/generated/'
        'published_candidate.json',
      ).readAsStringSync(),
    );
  });

  group('LR-2 dependency-aware learning decisions', () {
    test('unmet direct prerequisite is selected with structured evidence',
        () async {
      final runtime = _runtime(pack, _MemoryLearningEvidenceLog());
      final snapshot = await runtime.replayTechnique('technique.stop_control');

      expect(snapshot.decision.recommendations.selected.id,
          'technique.straight_stroke');
      final reason = snapshot.decision.trace.singleWhere(
        (item) => item.code == DecisionReasonCodes.prerequisiteUnsatisfied,
      );
      expect(reason.parameters['dependencyId'], 'technique.straight_stroke');
      expect(reason.parameters['evidence'], {
        'successes': 0,
        'attempts': 10,
        'mastered': false,
        'evidenceCount': 0,
      });
      expect(reason.policyVersion, 'learning-dependency/1.0.0');
    });

    test('mastered direct prerequisite makes current Technique available',
        () async {
      final log = _MemoryLearningEvidenceLog();
      final runtime = _runtime(pack, log);
      await runtime.recordCompletedDrill(
        knowledgeId: 'technique.straight_stroke',
        commandId: 'straight-mastered',
        successes: 8,
      );

      final snapshot = await runtime.replayTechnique('technique.stop_control');
      expect(snapshot.decision.recommendations.selected.id,
          'technique.stop_control');
      final reason = snapshot.decision.trace.singleWhere(
        (item) => item.code == DecisionReasonCodes.prerequisiteSatisfied,
      );
      expect(reason.parameters['dependencyId'], 'technique.straight_stroke');
      expect(
        (reason.parameters['evidence'] as Map<String, dynamic>)['mastered'],
        isTrue,
      );
    });

    test('multiple direct dependencies use implicit ALL semantics', () async {
      final log = _MemoryLearningEvidenceLog();
      final runtime = _runtime(pack, log);
      await runtime.recordCompletedDrill(
        knowledgeId: 'technique.stop_control',
        commandId: 'stop-mastered',
        successes: 8,
      );

      final snapshot =
          await runtime.replayTechnique('technique.position_control');
      expect(snapshot.decision.recommendations.selected.id,
          'technique.follow_control');
      final dependencyReasons = snapshot.decision.trace.where(
        (item) => item.code.startsWith('PREREQUISITE_'),
      );
      expect(dependencyReasons, hasLength(2));
      expect(
        dependencyReasons.map((item) => item.parameters['dependencyId']),
        ['technique.follow_control', 'technique.stop_control'],
      );
      expect(
        dependencyReasons.map((item) => item.code),
        [
          DecisionReasonCodes.prerequisiteUnsatisfied,
          DecisionReasonCodes.prerequisiteSatisfied,
        ],
      );
    });

    test('dependency evaluation is direct-only and does not traverse',
        () async {
      final log = _MemoryLearningEvidenceLog();
      final runtime = _runtime(pack, log);
      await runtime.recordCompletedDrill(
        knowledgeId: 'technique.stop_control',
        commandId: 'stop-without-straight',
        successes: 8,
      );

      final snapshot =
          await runtime.replayTechnique('technique.follow_control');
      expect(snapshot.decision.recommendations.selected.id,
          'technique.follow_control');
      expect(
        snapshot.decision.trace
            .where((item) => item.code.startsWith('PREREQUISITE_'))
            .map((item) => item.parameters['dependencyId']),
        ['technique.stop_control'],
      );
    });
  });
}

LearningRuntime _runtime(
  ExecutableKnowledgePack pack,
  LearningEvidenceLog log,
) =>
    LearningRuntime(
      pack: pack,
      evidenceLog: log,
      clock: () => DateTime.utc(2026, 7, 21, 12),
    );

class _MemoryLearningEvidenceLog implements LearningEvidenceLog {
  final List<LearningEvidenceBatch> _batches = [];

  @override
  Future<bool> append(LearningEvidenceBatch batch) async {
    if (_batches.any((item) => item.commandId == batch.commandId)) return false;
    _batches.add(batch);
    return true;
  }

  @override
  Future<List<LearningEvidenceBatch>> readAll() async =>
      List.unmodifiable(_batches);
}
