import 'dart:convert';
import 'dart:io';

import 'package:billiard_knowledge/billiard_knowledge.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/experience_projection_contracts.dart';
import 'package:pool_os/contracts/player_model_contracts.dart';
import 'package:pool_os/contracts/stop_shot_contracts.dart';
import 'package:pool_os/features/coach/application/learning_runtime.dart';
import 'package:pool_os/features/event/domain/stop_shot_evidence_log.dart';
import 'package:pool_os/features/player_model/application/experience_projector.dart';
import 'package:pool_os/features/player_model/application/player_model_projector.dart';

void main() {
  late ExecutableKnowledgePack pack;
  const experienceProjector = ExperienceProjector();
  const playerProjector = PlayerModelProjector();
  final profile = PlayerProfileContract(
    playerId: 'player.primary',
    dominantHand: 'right',
    locale: 'vi',
  );

  setUpAll(() {
    pack = ExecutableKnowledgePack.fromJsonString(
      File(
        '../packages/billiard_knowledge/test/fixtures/lr_1/generated/'
        'published_candidate.json',
      ).readAsStringSync(),
    );
  });

  test('same replay produces the same canonical Experience Snapshot', () async {
    final runtime = _runtime(pack, _MemoryLearningEvidenceLog());
    final technique = await runtime.recordCompletedDrill(
      knowledgeId: 'technique.bank_shot',
      commandId: 'bank-16',
      successes: 16,
    );
    final mistake = await runtime.recordMistakeObservation(
      knowledgeId: 'mistake.bank_alignment_left',
      commandId: 'alignment-left',
      resolved: false,
      confidence: 1,
    );
    final progress = playerProjector.project(
      profile: profile,
      learningSnapshots: [technique, mistake],
    );
    final first = experienceProjector.project(
      progress: progress,
      inputs: [
        ExperienceProjectionInput(
          sessionId: 'session.a',
          learningSnapshot: technique,
        ),
        ExperienceProjectionInput(
          sessionId: 'session.a',
          learningSnapshot: mistake,
        ),
      ],
    );
    final reordered = experienceProjector.project(
      progress: progress,
      inputs: [
        ExperienceProjectionInput(
          sessionId: 'session.a',
          learningSnapshot: mistake,
        ),
        ExperienceProjectionInput(
          sessionId: 'session.a',
          learningSnapshot: technique,
        ),
      ],
    );

    expect(reordered.digest, first.digest);
    expect(reordered.toJson(), first.toJson());
    expect(first.timeline.events, hasLength(2));
  });

  test('Session Summary groups events without scoring', () async {
    final runtime = _runtime(pack, _MemoryLearningEvidenceLog());
    final technique = await runtime.replay('technique.bank_shot');
    final mistake = await runtime.replay('mistake.bank_alignment_left');
    final progress = playerProjector.project(
      profile: profile,
      learningSnapshots: [technique, mistake],
    );
    final experience = experienceProjector.project(
      progress: progress,
      inputs: [
        ExperienceProjectionInput(
          sessionId: 'session.technique',
          learningSnapshot: technique,
        ),
        ExperienceProjectionInput(
          sessionId: 'session.mistake',
          learningSnapshot: mistake,
        ),
      ],
    );

    expect(experience.sessions, hasLength(2));
    expect(experience.sessions.first.sessionId, 'session.mistake');
    expect(experience.sessions.last.sessionId, 'session.technique');
    expect(jsonEncode(experience.toJson()), isNot(contains('score')));
  });

  test('new replay creates a new snapshot without mutating the old one',
      () async {
    final log = _MemoryLearningEvidenceLog();
    final runtime = _runtime(pack, log);
    final beforeLearning = await runtime.replay('technique.bank_shot');
    final beforeProgress = playerProjector.project(
      profile: profile,
      learningSnapshots: [beforeLearning],
    );
    final before = experienceProjector.project(
      progress: beforeProgress,
      inputs: [
        ExperienceProjectionInput(
          sessionId: 'session.before',
          learningSnapshot: beforeLearning,
        ),
      ],
    );
    final afterLearning = await runtime.recordCompletedDrill(
      knowledgeId: 'technique.bank_shot',
      commandId: 'bank-progress',
      successes: 16,
    );
    final afterProgress = playerProjector.project(
      profile: profile,
      learningSnapshots: [afterLearning],
    );
    final after = experienceProjector.project(
      progress: afterProgress,
      inputs: [
        ExperienceProjectionInput(
          sessionId: 'session.after',
          learningSnapshot: afterLearning,
        ),
      ],
    );

    expect(after.digest, isNot(before.digest));
    expect(before.timeline.events.single.state, 'inProgress');
    expect(after.timeline.events.single.state, 'mastered');
  });

  test('Coach-facing Experience Snapshot contains no raw Evidence log',
      () async {
    final runtime = _runtime(pack, _MemoryLearningEvidenceLog());
    final learning = await runtime.replay('technique.bank_shot');
    final progress = playerProjector.project(
      profile: profile,
      learningSnapshots: [learning],
    );
    final experience = experienceProjector.project(
      progress: progress,
      inputs: [
        ExperienceProjectionInput(
          sessionId: 'session.a',
          learningSnapshot: learning,
        ),
      ],
    );
    final json = jsonEncode(experience.toJson());

    expect(json, isNot(contains('evidenceLog')));
    expect(json, isNot(contains('rawEvidence')));
    expect(experience.playerProgressDigest, progress.digest);
  });

  test('empty and duplicate Experience inputs fail loudly', () async {
    final runtime = _runtime(pack, _MemoryLearningEvidenceLog());
    final learning = await runtime.replay('technique.bank_shot');
    final progress = playerProjector.project(
      profile: profile,
      learningSnapshots: [learning],
    );
    final input = ExperienceProjectionInput(
      sessionId: 'session.a',
      learningSnapshot: learning,
    );

    expect(
      () => experienceProjector.project(progress: progress, inputs: const []),
      throwsArgumentError,
    );
    expect(
      () => experienceProjector.project(
        progress: progress,
        inputs: [input, input],
      ),
      throwsArgumentError,
    );
  });

  test('Experience rejects Learning snapshots from another Knowledge pack',
      () async {
    final learning = await _runtime(
      pack,
      _MemoryLearningEvidenceLog(),
    ).replay('technique.bank_shot');
    final progress = playerProjector.project(
      profile: profile,
      learningSnapshots: [learning],
    );
    final otherPack = ExecutableKnowledgePack(
      schemaVersion: pack.schemaVersion,
      compilerVersion: pack.compilerVersion,
      knowledgeVersion: 'different-version',
      generatedAt: pack.generatedAt,
      contentDigest: 'different-digest',
      masteryPolicyVersion: pack.masteryPolicyVersion,
      masteryPolicies: pack.masteryPolicies,
      entries: pack.entries,
    );
    final otherLearning = await _runtime(
      otherPack,
      _MemoryLearningEvidenceLog(),
    ).replay('technique.bank_shot');

    expect(
      () => experienceProjector.project(
        progress: progress,
        inputs: [
          ExperienceProjectionInput(
            sessionId: 'session.other',
            learningSnapshot: otherLearning,
          ),
        ],
      ),
      throwsArgumentError,
    );
  });

  test('Experience Snapshot rejects an incomplete Session Summary', () async {
    final runtime = _runtime(pack, _MemoryLearningEvidenceLog());
    final technique = await runtime.replay('technique.bank_shot');
    final mistake = await runtime.replay('mistake.bank_alignment_left');
    final progress = playerProjector.project(
      profile: profile,
      learningSnapshots: [technique, mistake],
    );
    final valid = experienceProjector.project(
      progress: progress,
      inputs: [
        ExperienceProjectionInput(
          sessionId: 'session.a',
          learningSnapshot: technique,
        ),
        ExperienceProjectionInput(
          sessionId: 'session.a',
          learningSnapshot: mistake,
        ),
      ],
    );
    final incomplete = SessionSummaryProjection.create(
      sessionId: 'session.a',
      events: [valid.timeline.events.first],
    );

    expect(
      () => ExperienceSnapshot.create(
        playerId: progress.playerId,
        playerProgressDigest: progress.digest,
        knowledgeVersion: progress.knowledgeVersion,
        knowledgeDigest: progress.knowledgeDigest,
        timeline: valid.timeline,
        sessions: [incomplete],
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
      clock: () => DateTime.utc(2026, 7, 21, 14),
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
