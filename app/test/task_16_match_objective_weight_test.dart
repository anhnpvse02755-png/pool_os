import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/coach/domain/coach_intelligence.dart';
import 'package:pool_os/features/coach/domain/match_objective_policy.dart';
import 'package:pool_os/features/match/domain/models/match.dart';
import 'package:pool_os/features/rack/domain/models/rack.dart';
import 'package:pool_os/features/session/domain/models/session.dart';
import 'package:pool_os/features/shot/domain/models/shot.dart';

void main() {
  group('MatchObjectivePolicy', () {
    test('win, training and mixed apply 70/30, 20/80 and 50/50', () {
      final win = MatchObjectivePolicy.evaluate(
        objectiveCode: 'win',
        resultRate: 0.2,
        executionRate: 0.8,
      );
      final training = MatchObjectivePolicy.evaluate(
        objectiveCode: 'training',
        resultRate: 0.2,
        executionRate: 0.8,
      );
      final mixed = MatchObjectivePolicy.evaluate(
        objectiveCode: 'mixed',
        resultRate: 0.2,
        executionRate: 0.8,
      );

      expect(win.resultWeight, 0.70);
      expect(training.resultWeight, 0.20);
      expect(mixed.resultWeight, 0.50);
      expect(win.score, closeTo(0.38, 0.0001));
      expect(mixed.score, closeTo(0.50, 0.0001));
      expect(training.score, closeTo(0.68, 0.0001));
    });

    test('unknown objective falls back to balanced mixed weighting', () {
      final evaluation = MatchObjectivePolicy.evaluate(
        objectiveCode: 'unknown',
        resultRate: 1,
        executionRate: 0,
      );
      expect(evaluation.objective, CoachMatchObjective.mixed);
      expect(evaluation.score, 0.5);
    });
  });

  test('Coach report reads the persisted match objective', () {
    final at = DateTime(2026, 7, 19, 9);
    final match = Match(
      id: 1,
      sessionId: 1,
      matchNumber: 1,
      gameType: '9ball',
      matchObjective: 'training',
    );
    final rack = Rack(
      id: 1,
      matchId: 1,
      rackNumber: 1,
      result: false,
      createdAt: at,
    );
    final shots = List.generate(
      5,
      (index) => Shot(
        rackId: 1,
        shotNumber: index + 1,
        shotType: ShotTypes.normalShot,
        difficulty: ShotDifficulty.medium,
        result: index < 4 ? ShotResult.made : ShotResult.missed,
        createdAt: at,
      ),
    );

    final report = CoachIntelligence.analyzeSession(
      session: Session(
        id: 1,
        sessionType: SessionTypes.match,
        startedAt: at,
      ),
      matches: [match],
      racksByMatch: {
        1: [rack],
      },
      shotsByRack: {1: shots},
      missReasonCounts: const {},
      locale: 'en',
    );

    expect(report.objectiveEvaluation.objective, CoachMatchObjective.training);
    expect(report.objectiveEvaluation.resultWeight, 0.20);
    expect(report.objectiveEvaluation.executionWeight, 0.80);
    expect(report.evaluationScore, closeTo(0.64, 0.0001));
    expect(report.whyPoints.first, contains('20%'));
    expect(report.whyPoints.first, contains('80%'));
  });
}
