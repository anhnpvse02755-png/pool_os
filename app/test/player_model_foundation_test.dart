import 'dart:io';

import 'package:billiard_knowledge/billiard_knowledge.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/player_model_contracts.dart';
import 'package:pool_os/contracts/stop_shot_contracts.dart';
import 'package:pool_os/features/coach/application/learning_runtime.dart';
import 'package:pool_os/features/event/domain/stop_shot_evidence_log.dart';
import 'package:pool_os/features/player_model/application/player_model_projector.dart';

void main() {
  late ExecutableKnowledgePack pack;
  const projector = PlayerModelProjector();
  final profile = PlayerProfileContract(
    playerId: 'player.primary',
    dominantHand: 'right',
    locale: 'vi',
    preferences: const ['steady', 'control'],
    historyReferences: const ['history.local.v1'],
  );

  setUpAll(() {
    pack = ExecutableKnowledgePack.fromJsonString(
      File(
        '../packages/billiard_knowledge/test/fixtures/lr_1/generated/'
        'published_candidate.json',
      ).readAsStringSync(),
    );
  });

  test('Learning Runtime replay produces a deterministic Player Snapshot',
      () async {
    final log = _MemoryLearningEvidenceLog();
    final runtime = _runtime(pack, log);
    await runtime.recordCompletedDrill(
      knowledgeId: 'technique.bank_shot',
      commandId: 'bank-16',
      successes: 16,
    );
    await runtime.recordMistakeObservation(
      knowledgeId: 'mistake.bank_alignment_left',
      commandId: 'left-detected',
      resolved: false,
      confidence: 1,
    );
    final technique = await runtime.replay('technique.bank_shot');
    final mistake = await runtime.replay('mistake.bank_alignment_left');

    final first = projector.project(
      profile: profile,
      learningSnapshots: [technique, mistake],
    );
    final reordered = projector.project(
      profile: profile,
      learningSnapshots: [mistake, technique],
    );

    expect(reordered.digest, first.digest);
    expect(reordered.toJson(), first.toJson());
    expect(first.state.mastery.single.mastered, isTrue);
    expect(first.state.mistakes.single.state, 'persistent');
  });

  test('Coach Input contains Player Model, not Evidence records', () async {
    final runtime = _runtime(pack, _MemoryLearningEvidenceLog());
    final progress = projector.project(
      profile: profile,
      learningSnapshots: [await runtime.replay('technique.bank_shot')],
    );
    final input = projector.coachInput(profile: profile, progress: progress);
    final json = input.toJson();

    expect(json['profile'], isNotNull);
    expect(json['progress'], isNotNull);
    expect(json.containsKey('evidence'), isFalse);
    expect(input.digest, isNotEmpty);
  });

  test('new replay state changes snapshot without mutating the old snapshot',
      () async {
    final log = _MemoryLearningEvidenceLog();
    final runtime = _runtime(pack, log);
    final before = projector.project(
      profile: profile,
      learningSnapshots: [await runtime.replay('technique.bank_shot')],
    );
    await runtime.recordCompletedDrill(
      knowledgeId: 'technique.bank_shot',
      commandId: 'bank-progress',
      successes: 16,
    );
    final after = projector.project(
      profile: profile,
      learningSnapshots: [await runtime.replay('technique.bank_shot')],
    );

    expect(after.digest, isNot(before.digest));
    expect(before.state.mastery.single.evidenceCount, 0);
    expect(after.state.mastery.single.evidenceCount, 1);
  });

  test('duplicate Knowledge snapshots fail instead of creating ambiguous state',
      () async {
    final runtime = _runtime(pack, _MemoryLearningEvidenceLog());
    final snapshot = await runtime.replay('technique.bank_shot');

    expect(
      () => projector.project(
        profile: profile,
        learningSnapshots: [snapshot, snapshot],
      ),
      throwsArgumentError,
    );
  });

  test('Player Model rejects empty Learning Runtime input', () {
    expect(
      () => projector.project(profile: profile, learningSnapshots: const []),
      throwsArgumentError,
    );
  });

  test('Player Model rejects snapshots from different Knowledge packs',
      () async {
    final first = await _runtime(
      pack,
      _MemoryLearningEvidenceLog(),
    ).replay('technique.bank_shot');
    final otherPack = ExecutableKnowledgePack(
      schemaVersion: pack.schemaVersion,
      compilerVersion: pack.compilerVersion,
      knowledgeVersion: 'different-knowledge-version',
      generatedAt: pack.generatedAt,
      contentDigest: 'different-content-digest',
      masteryPolicyVersion: pack.masteryPolicyVersion,
      masteryPolicies: pack.masteryPolicies,
      entries: pack.entries,
    );
    final second = await _runtime(
      otherPack,
      _MemoryLearningEvidenceLog(),
    ).replay('mistake.bank_alignment_left');

    expect(
      () => projector.project(
        profile: profile,
        learningSnapshots: [first, second],
      ),
      throwsArgumentError,
    );
  });

  test('Coach Input rejects a profile for another player', () async {
    final runtime = _runtime(pack, _MemoryLearningEvidenceLog());
    final progress = projector.project(
      profile: profile,
      learningSnapshots: [await runtime.replay('technique.bank_shot')],
    );
    final otherPlayer = PlayerProfileContract(
      playerId: 'player.other',
      dominantHand: 'left',
      locale: 'vi',
    );

    expect(
      () => projector.coachInput(
        profile: otherPlayer,
        progress: progress,
      ),
      throwsArgumentError,
    );
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
