import 'dart:io';

import 'package:billiard_knowledge/billiard_knowledge.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/stop_shot_contracts.dart';
import 'package:pool_os/features/mastery/domain/learning_decision_engine.dart';

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

  group('LR-3 policy-driven decision pipeline', () {
    test('Availability Resolver returns typed blockers, not recommendations',
        () {
      final stop = pack.byId('technique.stop_control')!;
      final result = const LearningAvailabilityResolver().resolve(
        pack,
        stop,
        const [],
      );

      expect(result.available, isFalse);
      expect(result.blockers, hasLength(1));
      expect(result.blockers.single.entryId, 'technique.straight_stroke');
      expect(
        result.blockers.single.reasonCode,
        LearningAvailabilityReasonCode.notMastered,
      );
      expect(
        result.reasons.single.code,
        DecisionReasonCodes.prerequisiteUnsatisfied,
      );
    });

    test('Recommendation Resolver consumes availability without re-evaluation',
        () {
      final stop = pack.byId('technique.stop_control')!;
      final technique = stop.payload as TechniquePayload;
      final availability = const LearningAvailabilityResolver().resolve(
        pack,
        stop,
        const [],
      );
      final mastery = const TechniqueMasteryPolicy()
          .assess(pack, stop, technique, const []).mastery;

      final result = const LearningRecommendationResolver().resolve(
        stop,
        technique,
        mastery,
        availability,
        const {},
      );
      final byId = {for (final item in result.candidates) item.id: item};

      expect(byId['technique.stop_control']!.available, isFalse);
      expect(byId['technique.follow_control']!.available, isFalse);
      expect(byId['technique.straight_stroke']!.available, isTrue);
    });

    test('Correction Resolver is independent of Mastery and Recommendation',
        () {
      final stop = pack.byId('technique.stop_control')!;
      final result = const CorrectionResolver().resolve(
        pack,
        stop,
        const [],
      );

      expect(result.candidates, isEmpty);
      expect(result.reasons, isEmpty);
    });

    test('Decision Pipeline executes the authorized stage order', () {
      final stages = <String>[];
      final pipeline = PolicyDrivenLearningDecisionPipeline(
        availabilityResolver: _TrackingAvailabilityResolver(stages),
        masteryPolicy: _TrackingMasteryPolicy(stages),
        recommendationResolver: _TrackingRecommendationResolver(stages),
        correctionResolver: _TrackingCorrectionResolver(stages),
      );
      final entry = pack.byId('technique.straight_stroke')!;

      final result = pipeline.evaluateTechnique(
        pack,
        entry,
        entry.payload as TechniquePayload,
        const [],
      );

      expect(stages, [
        'availability',
        'mastery',
        'recommendation',
        'correction',
      ]);
      expect(
        result.decision.recommendations.selected.id,
        'technique.straight_stroke',
      );
    });
  });
}

class _TrackingAvailabilityResolver extends LearningAvailabilityResolver {
  _TrackingAvailabilityResolver(this.stages);

  final List<String> stages;

  @override
  LearningAvailabilityResolution resolve(
    ExecutableKnowledgePack pack,
    ExecutableKnowledgeEntry technique,
    List<LearningEvidenceBatch> evidence,
  ) {
    stages.add('availability');
    return const LearningAvailabilityResolution(
      available: true,
      blockers: [],
      reasons: [],
    );
  }
}

class _TrackingMasteryPolicy extends TechniqueMasteryPolicy {
  _TrackingMasteryPolicy(this.stages);

  final List<String> stages;

  @override
  TechniqueMasteryResult assess(
    ExecutableKnowledgePack pack,
    ExecutableKnowledgeEntry entry,
    TechniquePayload technique,
    List<LearningEvidenceBatch> evidence,
  ) {
    stages.add('mastery');
    return TechniqueMasteryResult(
      mastery: MasteryAssessment(
        knowledgeId: entry.id,
        successes: 0,
        attempts: technique.measurement.attempts,
        score: 0,
        mastered: false,
        evidenceCount: 0,
      ),
      reasons: const [],
    );
  }
}

class _TrackingRecommendationResolver extends LearningRecommendationResolver {
  _TrackingRecommendationResolver(this.stages);

  final List<String> stages;

  @override
  RecommendationResolution resolve(
    ExecutableKnowledgeEntry entry,
    TechniquePayload technique,
    MasteryAssessment mastery,
    LearningAvailabilityResolution availability,
    Set<MasteryCategory> activeCorrectionCategories,
  ) {
    stages.add('recommendation');
    return RecommendationResolution(
      candidates: [
        RecommendationCandidate(
          id: entry.id,
          title: entry.title,
          score: 100,
          available: true,
        ),
      ],
      reasons: const [],
    );
  }
}

class _TrackingCorrectionResolver extends CorrectionResolver {
  _TrackingCorrectionResolver(this.stages);

  final List<String> stages;

  @override
  CorrectionResolution resolve(
    ExecutableKnowledgePack pack,
    ExecutableKnowledgeEntry technique,
    List<LearningEvidenceBatch> evidence,
  ) {
    stages.add('correction');
    return const CorrectionResolution([], []);
  }
}
