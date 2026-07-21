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
        '../packages/billiard_knowledge/test/fixtures/lr_4/generated/'
        'published_candidate.json',
      ).readAsStringSync(),
    );
  });

  group('LR-4 allOf runtime evaluation', () {
    test('failed expression identifies leaf and allOf nodes', () async {
      final snapshot = await _runtime(pack, _MemoryLearningEvidenceLog())
          .replayTechnique('technique.position_control');

      expect(snapshot.decision.recommendations.selected.id,
          'technique.follow_control');
      final leafReasons = snapshot.decision.trace.where(
        (reason) => reason.code == DecisionReasonCodes.prerequisiteUnsatisfied,
      );
      expect(leafReasons, hasLength(3));
      expect(
        leafReasons.map((reason) => reason.parameters['expressionNodeId']),
        containsAll([
          'unlock.allOf[0].allOf[0]',
          'unlock.allOf[0].allOf[1]',
          'unlock.allOf[1]',
        ]),
      );
      final failedNodes = snapshot.decision.trace.where(
        (reason) =>
            reason.code == DecisionReasonCodes.unlockExpressionUnsatisfied,
      );
      expect(
        failedNodes.map((reason) => reason.parameters['expressionNodeId']),
        ['unlock.allOf[0]', 'unlock'],
      );
    });

    test('partial evidence reports the exact remaining failed branch',
        () async {
      final log = _MemoryLearningEvidenceLog();
      final runtime = _runtime(pack, log);
      await runtime.recordCompletedDrill(
        knowledgeId: 'technique.stop_control',
        commandId: 'stop-mastered',
        successes: 8,
      );
      await runtime.recordCompletedDrill(
        knowledgeId: 'technique.straight_stroke',
        commandId: 'straight-mastered',
        successes: 8,
      );

      final snapshot =
          await runtime.replayTechnique('technique.position_control');
      expect(snapshot.decision.recommendations.selected.id,
          'technique.follow_control');
      final root = snapshot.decision.trace.singleWhere(
        (reason) =>
            reason.code == DecisionReasonCodes.unlockExpressionUnsatisfied &&
            reason.parameters['expressionNodeId'] == 'unlock',
      );
      expect(root.parameters['failedChildNodeIds'], ['unlock.allOf[0]']);
    });

    test('all satisfied leaves unlock the current Technique', () async {
      final log = _MemoryLearningEvidenceLog();
      final runtime = _runtime(pack, log);
      for (final id in [
        'technique.stop_control',
        'technique.follow_control',
        'technique.straight_stroke',
      ]) {
        await runtime.recordCompletedDrill(
          knowledgeId: id,
          commandId: 'master-$id',
          successes: 8,
        );
      }

      final snapshot =
          await runtime.replayTechnique('technique.position_control');
      expect(snapshot.decision.recommendations.selected.id,
          'technique.position_control');
      expect(
        snapshot.decision.trace.where(
          (reason) =>
              reason.code == DecisionReasonCodes.unlockExpressionSatisfied,
        ),
        hasLength(2),
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
