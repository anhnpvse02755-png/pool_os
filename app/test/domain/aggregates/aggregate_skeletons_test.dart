import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/domain/aggregates/coach_aggregate.dart';
import 'package:pool_os/domain/aggregates/configuration_aggregate.dart';
import 'package:pool_os/domain/aggregates/match_aggregate.dart';
import 'package:pool_os/domain/aggregates/training_aggregate.dart';
import 'package:pool_os/domain/aggregates/user_aggregate.dart';
import 'package:pool_os/domain/entities/coach_session.dart';
import 'package:pool_os/domain/entities/external_references.dart';
import 'package:pool_os/domain/entities/match_entity.dart';
import 'package:pool_os/domain/entities/settings_profile.dart';
import 'package:pool_os/domain/entities/training_session.dart';
import 'package:pool_os/domain/entities/user_profile.dart';
import 'package:pool_os/domain/shared/entity_ids.dart';
import 'package:pool_os/domain/shared/scalar_values.dart';
import 'package:pool_os/domain/shared/temporal_values.dart';

void main() {
  final createdAt = UtcTimestamp(DateTime.utc(2026, 7, 23));
  final version = VersionNumber(1);
  final state = NonEmptyString('structural');

  test('MatchAggregate exposes root identity and copies child identities', () {
    final children = [SessionId('rack-1')];
    final aggregate = MatchAggregate(
      root: ProductMatch(
        id: MatchId('match-1'),
        version: version,
        createdAt: createdAt,
        lifecycleState: state,
      ),
      rackSessionIds: children,
    );
    children.add(SessionId('rack-2'));

    expect(aggregate.id, MatchId('match-1'));
    expect(aggregate.version, VersionNumber(1));
    expect(aggregate.rackSessionIds, [SessionId('rack-1')]);
    expect(() => aggregate.rackSessionIds.clear(), throwsUnsupportedError);
  });

  test('aggregate equality is runtime type plus root identity', () {
    final left = MatchAggregate(
      root: ProductMatch(
        id: MatchId('match-1'),
        version: version,
        createdAt: createdAt,
        lifecycleState: state,
      ),
      rackSessionIds: [SessionId('rack-1')],
    );
    final replay = MatchAggregate(
      root: ProductMatch(
        id: MatchId('match-1'),
        version: VersionNumber(2),
        createdAt: createdAt,
        lifecycleState: NonEmptyString('other'),
      ),
    );
    expect(left, replay);
  });

  test('TrainingAggregate defensively copies owner references', () {
    final knowledge = [
      KnowledgeReference(
        id: GenericEntityId('knowledge-1'),
        version: version,
        digest: NonEmptyString('knowledge-digest'),
        provenance: NonEmptyString('publication-proof'),
      ),
    ];
    final evidence = [
      EvidenceReference(
        id: GenericEntityId('evidence-1'),
        version: version,
        digest: NonEmptyString('evidence-digest'),
        sourceOwner: NonEmptyString('platform.evidence'),
      ),
    ];
    final aggregate = TrainingAggregate(
      root: TrainingSession(
        id: SessionId('training-1'),
        version: version,
        createdAt: createdAt,
        playerId: PlayerId('player-1'),
        lifecycleState: state,
      ),
      knowledgeReferences: knowledge,
      evidenceReferences: evidence,
      simulationRequestIds: [GenericEntityId('simulation-request-1')],
    );
    knowledge.clear();
    evidence.clear();

    expect(aggregate.knowledgeReferences, hasLength(1));
    expect(aggregate.evidenceReferences, hasLength(1));
    expect(
        () => aggregate.simulationRequestIds.clear(), throwsUnsupportedError);
  });

  test('CoachAggregate stores immutable response and execution references', () {
    final responses = [GenericEntityId('response-1')];
    final aggregate = CoachAggregate(
      root: CoachSession(
        id: SessionId('coach-1'),
        version: version,
        createdAt: createdAt,
        aiSessionReferenceId: GenericEntityId('ai-session-1'),
        aiSessionDigest: NonEmptyString('ai-session-digest'),
        lifecycleState: state,
      ),
      responseReferenceIds: responses,
      executionReferenceIds: [GenericEntityId('execution-1')],
    );
    responses.clear();
    expect(aggregate.responseReferenceIds, [GenericEntityId('response-1')]);
    expect(
        () => aggregate.executionReferenceIds.clear(), throwsUnsupportedError);
  });

  test('UserAggregate is structural and copies profile references', () {
    final references = [GenericEntityId('profile-reference-1')];
    final aggregate = UserAggregate(
      root: UserProfile(
        id: GenericEntityId('user-1'),
        version: version,
        createdAt: createdAt,
        displayName: NonEmptyString('User One'),
        lifecycleState: state,
      ),
      profileReferenceIds: references,
    );
    references.clear();
    expect(aggregate.profileReferenceIds,
        [GenericEntityId('profile-reference-1')]);
    expect(() => aggregate.profileReferenceIds.clear(), throwsUnsupportedError);
  });

  test('ConfigurationAggregate copies configuration references', () {
    final references = [GenericEntityId('configuration-1')];
    final aggregate = ConfigurationAggregate(
      root: SettingsProfile(
        id: GenericEntityId('settings-1'),
        version: version,
        createdAt: createdAt,
        userProfileId: GenericEntityId('user-1'),
        lifecycleState: state,
      ),
      configurationReferenceIds: references,
    );
    references.add(GenericEntityId('configuration-2'));
    expect(aggregate.configurationReferenceIds,
        [GenericEntityId('configuration-1')]);
    expect(() => aggregate.configurationReferenceIds.clear(),
        throwsUnsupportedError);
  });
}
