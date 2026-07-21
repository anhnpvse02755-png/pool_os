import 'dart:convert';
import 'dart:io';

import 'package:billiard_knowledge/billiard_knowledge.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/coach_context_contracts.dart';
import 'package:pool_os/contracts/experience_projection_contracts.dart';
import 'package:pool_os/contracts/player_model_contracts.dart';
import 'package:pool_os/contracts/stop_shot_contracts.dart';
import 'package:pool_os/features/coach/application/coach_context_builder.dart';
import 'package:pool_os/features/coach/application/learning_runtime.dart';
import 'package:pool_os/features/event/domain/stop_shot_evidence_log.dart';
import 'package:pool_os/features/player_model/application/experience_projector.dart';
import 'package:pool_os/features/player_model/application/player_model_projector.dart';

void main() {
  late ExecutableKnowledgePack pack;
  const builder = CoachContextBuilder();

  setUpAll(() {
    pack = ExecutableKnowledgePack.fromJsonString(
      File(
        '../packages/billiard_knowledge/test/fixtures/lr_1/generated/'
        'published_candidate.json',
      ).readAsStringSync(),
    );
  });

  test('same projections produce the same versioned Coach Context', () async {
    final fixture = await _fixture(pack);
    final first = builder.build(
      profile: fixture.profile,
      progress: fixture.progress,
      experience: fixture.experience,
    );
    final second = builder.build(
      profile: fixture.profile,
      progress: fixture.progress,
      experience: fixture.experience,
    );

    expect(second.digest, first.digest);
    expect(second.toJson(), first.toJson());
    expect(first.toJson()['schemaVersion'], coachContextContractVersion);
    expect(first.versions.playerProfileVersion, playerProfileContractVersion);
    expect(
      first.versions.playerProgressVersion,
      playerProgressSnapshotVersion,
    );
    expect(
      first.versions.experienceSnapshotVersion,
      experienceSnapshotContractVersion,
    );
  });

  test('Coach Context is the AI boundary and contains no runtime inputs',
      () async {
    final fixture = await _fixture(pack);
    final context = builder.build(
      profile: fixture.profile,
      progress: fixture.progress,
      experience: fixture.experience,
    );
    final json = jsonEncode(context.toJson());

    expect(json, isNot(contains('rawEvidence')));
    expect(json, isNot(contains('evidenceLog')));
    expect(json, isNot(contains('learningRuntime')));
    expect(context.progress.digest, fixture.experience.playerProgressDigest);
  });

  test('Coach Context rejects mismatched player identities', () async {
    final fixture = await _fixture(pack);
    final other = PlayerProfileContract(
      playerId: 'player.other',
      dominantHand: 'left',
      locale: 'vi',
    );

    expect(
      () => builder.build(
        profile: other,
        progress: fixture.progress,
        experience: fixture.experience,
      ),
      throwsArgumentError,
    );
  });

  test('Coach Context rejects an Experience built from stale Progress',
      () async {
    final log = _MemoryLearningEvidenceLog();
    final runtime = _runtime(pack, log);
    final profile = _profile();
    final beforeLearning = await runtime.replay('technique.bank_shot');
    final beforeProgress = const PlayerModelProjector().project(
      profile: profile,
      learningSnapshots: [beforeLearning],
    );
    final beforeExperience = const ExperienceProjector().project(
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
      commandId: 'bank-16',
      successes: 16,
    );
    final afterProgress = const PlayerModelProjector().project(
      profile: profile,
      learningSnapshots: [afterLearning],
    );

    expect(
      () => builder.build(
        profile: profile,
        progress: afterProgress,
        experience: beforeExperience,
      ),
      throwsArgumentError,
    );
  });

  test('Coach Context rejects a mismatched Knowledge identity', () async {
    final fixture = await _fixture(pack);
    final incompatibleExperience = ExperienceSnapshot.create(
      playerId: fixture.experience.playerId,
      playerProgressDigest: fixture.progress.digest,
      knowledgeVersion: 'different-version',
      knowledgeDigest: 'different-digest',
      timeline: fixture.experience.timeline,
      sessions: fixture.experience.sessions,
    );

    expect(
      () => builder.build(
        profile: fixture.profile,
        progress: fixture.progress,
        experience: incompatibleExperience,
      ),
      throwsArgumentError,
    );
  });

  test('new projections create a new context without mutating the old one',
      () async {
    final firstFixture = await _fixture(pack);
    final first = builder.build(
      profile: firstFixture.profile,
      progress: firstFixture.progress,
      experience: firstFixture.experience,
    );
    final log = _MemoryLearningEvidenceLog();
    final runtime = _runtime(pack, log);
    final profile = _profile();
    final learning = await runtime.recordCompletedDrill(
      knowledgeId: 'technique.bank_shot',
      commandId: 'bank-new',
      successes: 16,
    );
    final progress = const PlayerModelProjector().project(
      profile: profile,
      learningSnapshots: [learning],
    );
    final experience = const ExperienceProjector().project(
      progress: progress,
      inputs: [
        ExperienceProjectionInput(
          sessionId: 'session.new',
          learningSnapshot: learning,
        ),
      ],
    );
    final second = builder.build(
      profile: profile,
      progress: progress,
      experience: experience,
    );

    expect(second.digest, isNot(first.digest));
    expect(first.experience.timeline.events.single.state, 'inProgress');
    expect(second.experience.timeline.events.single.state, 'mastered');
  });
}

Future<_ContextFixture> _fixture(ExecutableKnowledgePack pack) async {
  final profile = _profile();
  final learning = await _runtime(
    pack,
    _MemoryLearningEvidenceLog(),
  ).replay('technique.bank_shot');
  final progress = const PlayerModelProjector().project(
    profile: profile,
    learningSnapshots: [learning],
  );
  final experience = const ExperienceProjector().project(
    progress: progress,
    inputs: [
      ExperienceProjectionInput(
        sessionId: 'session.foundation',
        learningSnapshot: learning,
      ),
    ],
  );
  return _ContextFixture(
    profile: profile,
    progress: progress,
    experience: experience,
  );
}

PlayerProfileContract _profile() => PlayerProfileContract(
      playerId: 'player.primary',
      dominantHand: 'right',
      locale: 'vi',
    );

LearningRuntime _runtime(
  ExecutableKnowledgePack pack,
  LearningEvidenceLog log,
) =>
    LearningRuntime(
      pack: pack,
      evidenceLog: log,
      clock: () => DateTime.utc(2026, 7, 21, 15),
    );

class _ContextFixture {
  const _ContextFixture({
    required this.profile,
    required this.progress,
    required this.experience,
  });

  final PlayerProfileContract profile;
  final PlayerProgressSnapshot progress;
  final ExperienceSnapshot experience;
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
