import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/domain/entities/coach_session.dart';
import 'package:pool_os/domain/entities/external_references.dart';
import 'package:pool_os/domain/entities/match_entity.dart';
import 'package:pool_os/domain/entities/performance_snapshot.dart';
import 'package:pool_os/domain/entities/player_profile.dart';
import 'package:pool_os/domain/entities/settings_profile.dart';
import 'package:pool_os/domain/entities/simulation_request.dart';
import 'package:pool_os/domain/entities/training_session.dart';
import 'package:pool_os/domain/entities/user_profile.dart';
import 'package:pool_os/domain/shared/entity_ids.dart';
import 'package:pool_os/domain/shared/scalar_values.dart';
import 'package:pool_os/domain/shared/temporal_values.dart';

void main() {
  final createdAt = UtcTimestamp(DateTime.utc(2026, 7, 23));
  final version = VersionNumber(1);
  final state = NonEmptyString('planned');

  test(
      'ProductMatch is immutable, identity-equal, and defensively copies lists',
      () {
    final participants = [PlayerId('player-1')];
    final match = ProductMatch(
      id: MatchId('match-1'),
      version: version,
      createdAt: createdAt,
      lifecycleState: state,
      participantIds: participants,
      sessionIds: [SessionId('rack-1')],
    );
    participants.add(PlayerId('player-2'));

    expect(match.participantIds, [PlayerId('player-1')]);
    expect(() => match.participantIds.add(PlayerId('player-3')),
        throwsUnsupportedError);
    expect(
      match,
      ProductMatch(
        id: MatchId('match-1'),
        version: VersionNumber(2),
        createdAt: createdAt,
        lifecycleState: NonEmptyString('completed'),
      ),
    );
  });

  test('PlayerProfile keeps approved primitives only', () {
    final profile = PlayerProfile(
      id: PlayerId('player-1'),
      version: version,
      createdAt: createdAt,
      displayName: NonEmptyString('Player One'),
      lifecycleState: NonEmptyString('active'),
    );
    expect(profile.displayName.value, 'Player One');
    expect(profile.id, PlayerId('player-1'));
  });

  test('TrainingSession copies target references without behavior', () {
    final references = [GenericEntityId('exercise-1')];
    final session = TrainingSession(
      id: SessionId('training-1'),
      version: version,
      createdAt: createdAt,
      playerId: PlayerId('player-1'),
      lifecycleState: state,
      targetReferenceIds: references,
    );
    references.add(GenericEntityId('exercise-2'));
    expect(session.targetReferenceIds, [GenericEntityId('exercise-1')]);
    expect(() => session.targetReferenceIds.clear(), throwsUnsupportedError);
  });

  test('CoachSession binds immutable AI session reference primitives', () {
    final session = CoachSession(
      id: SessionId('coach-1'),
      version: version,
      createdAt: createdAt,
      aiSessionReferenceId: GenericEntityId('ai-session-1'),
      aiSessionDigest: NonEmptyString('digest-1'),
      lifecycleState: state,
    );
    expect(session.aiSessionReferenceId, GenericEntityId('ai-session-1'));
    expect(session.aiSessionDigest.value, 'digest-1');
  });

  test('PerformanceSnapshot copies source references', () {
    final sources = [GenericEntityId('source-1')];
    final snapshot = PerformanceSnapshot(
      id: GenericEntityId('snapshot-1'),
      version: version,
      createdAt: createdAt,
      playerId: PlayerId('player-1'),
      digest: NonEmptyString('snapshot-digest'),
      lifecycleState: NonEmptyString('materialized'),
      sourceReferenceIds: sources,
    );
    sources.add(GenericEntityId('source-2'));
    expect(snapshot.sourceReferenceIds, [GenericEntityId('source-1')]);
    expect(() => snapshot.sourceReferenceIds.clear(), throwsUnsupportedError);
  });

  test('UserProfile has an optional typed Player reference', () {
    final profile = UserProfile(
      id: GenericEntityId('user-1'),
      version: version,
      createdAt: createdAt,
      displayName: NonEmptyString('User One'),
      lifecycleState: NonEmptyString('active'),
      playerId: PlayerId('player-1'),
    );
    expect(profile.playerId, PlayerId('player-1'));
  });

  test('SettingsProfile copies configuration references', () {
    final references = [GenericEntityId('configuration-1')];
    final profile = SettingsProfile(
      id: GenericEntityId('settings-1'),
      version: version,
      createdAt: createdAt,
      userProfileId: GenericEntityId('user-1'),
      lifecycleState: state,
      configurationReferenceIds: references,
    );
    references.clear();
    expect(profile.configurationReferenceIds,
        [GenericEntityId('configuration-1')]);
    expect(() => profile.configurationReferenceIds.clear(),
        throwsUnsupportedError);
  });

  test('SimulationRequest binds scenario reference without Simulation behavior',
      () {
    final request = SimulationRequest(
      id: GenericEntityId('simulation-request-1'),
      version: version,
      createdAt: createdAt,
      scenarioReferenceId: GenericEntityId('scenario-1'),
      scenarioDigest: NonEmptyString('scenario-digest'),
      lifecycleState: state,
    );
    expect(request.scenarioReferenceId, GenericEntityId('scenario-1'));
  });

  test('EvidenceReference uses complete value equality', () {
    final left = EvidenceReference(
      id: GenericEntityId('evidence-1'),
      version: version,
      digest: NonEmptyString('evidence-digest'),
      sourceOwner: NonEmptyString('platform.evidence'),
    );
    final replay = EvidenceReference(
      id: GenericEntityId('evidence-1'),
      version: VersionNumber(1),
      digest: NonEmptyString('evidence-digest'),
      sourceOwner: NonEmptyString('platform.evidence'),
    );
    expect(left, replay);
    expect(
      left,
      isNot(EvidenceReference(
        id: GenericEntityId('evidence-1'),
        version: VersionNumber(2),
        digest: NonEmptyString('evidence-digest'),
        sourceOwner: NonEmptyString('platform.evidence'),
      )),
    );
  });

  test('KnowledgeReference binds version, digest, and provenance', () {
    final reference = KnowledgeReference(
      id: GenericEntityId('knowledge-1'),
      version: version,
      digest: NonEmptyString('knowledge-digest'),
      provenance: NonEmptyString('publication-proof-1'),
    );
    expect(reference.version, VersionNumber(1));
    expect(reference.provenance.value, 'publication-proof-1');
  });

  test('invalid primitive construction fails before entity construction', () {
    expect(() => NonEmptyString(' '), throwsArgumentError);
    expect(() => MatchId('bad id'), throwsArgumentError);
    expect(() => UtcTimestamp(DateTime(2026, 7, 23)), throwsArgumentError);
  });
}
