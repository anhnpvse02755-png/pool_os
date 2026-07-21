import 'dart:convert';
import 'dart:io';

import 'package:billiard_knowledge/billiard_knowledge.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/coach_context_contracts.dart';
import 'package:pool_os/contracts/coach_decision_contracts.dart';
import 'package:pool_os/contracts/player_model_contracts.dart';
import 'package:pool_os/contracts/stop_shot_contracts.dart';
import 'package:pool_os/features/coach/application/coach_context_builder.dart';
import 'package:pool_os/features/coach/application/learning_runtime.dart';
import 'package:pool_os/features/coach/domain/coach_decision_builder.dart';
import 'package:pool_os/features/event/domain/stop_shot_evidence_log.dart';
import 'package:pool_os/features/player_model/application/experience_projector.dart';
import 'package:pool_os/features/player_model/application/player_model_projector.dart';

void main() {
  late ExecutableKnowledgePack pack;
  const decisionBuilder = CoachDecisionBuilder();

  setUpAll(() {
    pack = ExecutableKnowledgePack.fromJsonString(
      File(
        '../packages/billiard_knowledge/test/fixtures/lr_1/generated/'
        'published_candidate.json',
      ).readAsStringSync(),
    );
  });

  test('persistent Mistake takes deterministic priority over Technique',
      () async {
    final context = await _context(
      pack,
      includePersistentMistake: true,
    );
    final decision = decisionBuilder.build(context);

    expect(decision.action, CoachDecisionAction.correctMistake);
    expect(decision.targetKnowledgeId, 'mistake.bank_alignment_left');
    expect(
      decision.reasons.single.code,
      CoachDecisionReasonCode.persistentMistakeRequiresCorrection,
    );
    expect(decision.alternatives.single.action,
        CoachDecisionAction.practiceTechnique);
    expect(
      decision.alternatives.single.reason,
      CoachDecisionAlternativeReason.correctionPriority,
    );
  });

  test('unmastered Technique produces a semantic practice decision', () async {
    final decision = decisionBuilder.build(await _context(pack));

    expect(decision.action, CoachDecisionAction.practiceTechnique);
    expect(decision.targetKnowledgeId, 'technique.bank_shot');
    expect(
      decision.reasons.single.code,
      CoachDecisionReasonCode.masteryBelowThreshold,
    );
  });

  test('mastered tracked capability produces readiness without invented target',
      () async {
    final decision = decisionBuilder.build(
      await _context(pack, bankSuccesses: 16),
    );

    expect(decision.action, CoachDecisionAction.readyForNextCapability);
    expect(decision.targetKnowledgeId, isNull);
    expect(
      decision.reasons.single.code,
      CoachDecisionReasonCode.allTrackedCapabilitiesMastered,
    );
  });

  test('canonical tie-break records non-selected alternatives without scores',
      () async {
    final decision = decisionBuilder.build(
      await _context(pack, includeKickShot: true),
    );
    final json = jsonEncode(decision.toJson());

    expect(decision.targetKnowledgeId, 'technique.bank_shot');
    expect(decision.alternatives.single.knowledgeId, 'technique.kick_shot');
    expect(
      decision.alternatives.single.reason,
      CoachDecisionAlternativeReason.lowerCanonicalPriority,
    );
    expect(json, isNot(contains('score')));
  });

  test('same Coach Context produces the same decision, trace, and digest',
      () async {
    final context = await _context(pack, includeKickShot: true);
    final first = decisionBuilder.build(context);
    final second = decisionBuilder.build(context);

    expect(second.digest, first.digest);
    expect(second.toJson(), first.toJson());
    expect(first.trace.map((step) => step.sequence), [1, 2, 3, 4]);
    expect(first.versions.contextContractVersion, coachContextContractVersion);
    expect(first.versions.contextDigest, context.digest);
    expect(first.versions.policyVersion, coachDecisionPolicyVersion);
  });

  test('Coach Decision contains structured semantics and no generated prose',
      () async {
    final decision = decisionBuilder.build(await _context(pack));
    final json = jsonEncode(decision.toJson());

    expect(decision.toJson()['schemaVersion'], coachDecisionContractVersion);
    expect(json, isNot(contains('recommendation')));
    expect(json, isNot(contains('prompt')));
    expect(json, isNot(contains('message')));
    expect(json, isNot(contains('title')));
    expect(decision.id, startsWith('coach-decision.'));
  });
}

Future<CoachContextContract> _context(
  ExecutableKnowledgePack pack, {
  int? bankSuccesses,
  bool includeKickShot = false,
  bool includePersistentMistake = false,
}) async {
  final log = _MemoryLearningEvidenceLog();
  final runtime = LearningRuntime(
    pack: pack,
    evidenceLog: log,
    clock: () => DateTime.utc(2026, 7, 21, 16),
  );
  final learning = <LearningSnapshot>[];
  if (bankSuccesses == null) {
    learning.add(await runtime.replay('technique.bank_shot'));
  } else {
    learning.add(
      await runtime.recordCompletedDrill(
        knowledgeId: 'technique.bank_shot',
        commandId: 'bank-$bankSuccesses',
        successes: bankSuccesses,
      ),
    );
  }
  if (includeKickShot) {
    learning.add(await runtime.replay('technique.kick_shot'));
  }
  if (includePersistentMistake) {
    learning.add(
      await runtime.recordMistakeObservation(
        knowledgeId: 'mistake.bank_alignment_left',
        commandId: 'alignment-left',
        resolved: false,
        confidence: 1,
      ),
    );
  }
  final profile = PlayerProfileContract(
    playerId: 'player.primary',
    dominantHand: 'right',
    locale: 'vi',
  );
  final progress = const PlayerModelProjector().project(
    profile: profile,
    learningSnapshots: learning,
  );
  final experience = const ExperienceProjector().project(
    progress: progress,
    inputs: [
      for (final snapshot in learning)
        ExperienceProjectionInput(
          sessionId: 'session.decision',
          learningSnapshot: snapshot,
        ),
    ],
  );
  return const CoachContextBuilder().build(
    profile: profile,
    progress: progress,
    experience: experience,
  );
}

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
