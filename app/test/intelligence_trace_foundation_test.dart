import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/coach_context_contracts.dart';
import 'package:pool_os/contracts/intelligence_trace_contracts.dart';
import 'package:pool_os/contracts/ordered_recommendation_view_contracts.dart';
import 'package:pool_os/contracts/player_model_contracts.dart';
import 'package:pool_os/contracts/experience_projection_contracts.dart';
import 'package:pool_os/contracts/learning_eligibility_contracts.dart';

void main() {
  test('trace is immutable, structured, and deterministic', () {
    final context = _context();
    const builder = IntelligenceTraceBuilder();
    IntelligenceTraceContract build() => builder.build(
          context: context,
          recommendationView: _view(context),
        );
    final first = build();
    final replay = build();

    expect(replay.digest, first.digest);
    expect(jsonEncode(replay.toJson()), jsonEncode(first.toJson()));
    expect(() => first.entries.clear(), throwsUnsupportedError);
    final json = jsonEncode(first.toJson());
    expect(json, isNot(contains('prose')));
    expect(json, isNot(contains('prompt')));
  });

  test('trace rejects empty, duplicate, and broken entries', () {
    final context = _context();
    const entry = IntelligenceTraceEntryContract(
      sequence: 1,
      stage: IntelligenceTraceStage.recommendation,
      ruleId: 'pendingRecommendation',
      inputReferences: ['recommendation.1'],
      outputReferences: ['recommendation.1'],
      reasonCode: 'noExecutionRecorded',
    );
    expect(
      () =>
          IntelligenceTraceContract.create(context: context, entries: const []),
      throwsArgumentError,
    );
    expect(
      () => IntelligenceTraceContract.create(
        context: context,
        entries: const [entry, entry],
      ),
      throwsArgumentError,
    );
    expect(
      () => IntelligenceTraceContract.create(
        context: context,
        entries: const [
          IntelligenceTraceEntryContract(
            sequence: 2,
            stage: IntelligenceTraceStage.recommendation,
            ruleId: 'rule',
            inputReferences: ['recommendation.1'],
            outputReferences: ['recommendation.1'],
            reasonCode: 'reason',
          )
        ],
      ),
      throwsArgumentError,
    );
  });

  test('builder rejects stale or foreign public outputs', () {
    final context = _context();
    final foreign = _context(suffix: '.foreign');
    const builder = IntelligenceTraceBuilder();
    expect(
      () => builder.build(context: context, recommendationView: _view(foreign)),
      throwsArgumentError,
    );
    expect(
      () => builder.build(context: context),
      throwsArgumentError,
    );
  });
}

OrderedRecommendationViewContract _view(CoachContextContract context) =>
    OrderedRecommendationViewContract.create(
      context: context,
      items: const [
        RecommendationPriorityItemContract(
          position: 1,
          recommendationId: 'recommendation.1',
          recommendationDigest: 'digest.1',
          band: RecommendationPriorityBand.pendingRecommendation,
          reasons: [RecommendationPriorityReason.noExecutionRecorded],
          executionId: null,
          executionDigest: null,
        )
      ],
    );

CoachContextContract _context({String suffix = ''}) {
  final progress = PlayerProgressSnapshot.create(
    playerId: 'player.trace$suffix',
    knowledgeVersion: 'knowledge.trace/1',
    knowledgeDigest: 'trace-digest$suffix',
    sourceDecisionReferences: const [],
    state: PlayerModelState(
      mastery: const [],
      mistakes: const [],
      preferences: const [],
      historyReferences: const [],
    ),
  );
  final event = ExperienceEventContract(
    eventId: 'trace.event$suffix',
    playerId: progress.playerId,
    sessionId: 'trace.session$suffix',
    occurredAt: DateTime.utc(2026, 7, 21),
    kind: ExperienceEventKind.techniqueProgress,
    knowledgeId: 'technique.trace',
    state: 'inProgress',
    sourceDecisionReference: 'source',
  );
  return CoachContextContract.create(
    profile: PlayerProfileContract(
        playerId: progress.playerId, dominantHand: 'right', locale: 'vi'),
    progress: progress,
    experience: ExperienceSnapshot.create(
      playerId: progress.playerId,
      playerProgressDigest: progress.digest,
      knowledgeVersion: progress.knowledgeVersion,
      knowledgeDigest: progress.knowledgeDigest,
      timeline: ExperienceTimelineProjection.create([event]),
      sessions: [
        SessionSummaryProjection.create(
            sessionId: event.sessionId, events: [event])
      ],
    ),
    eligibility: LearningEligibilityProjection.create(
      knowledgeVersion: progress.knowledgeVersion,
      knowledgeDigest: progress.knowledgeDigest,
      items: const [],
    ),
  );
}
