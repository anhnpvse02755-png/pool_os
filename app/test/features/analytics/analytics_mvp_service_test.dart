import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/analytics/application/analytics_mvp_service.dart';

void main() {
  group('AnalyticsMvpService', () {
    test('loads existing Match and Training statistics through P9', () async {
      final dashboard = await _service.load();

      expect(dashboard.matches.matchCount, 2);
      expect(dashboard.training.sessionCount, 3);
      expect(dashboard.matchWinRate, 0.6);
      expect(dashboard.trainingSuccessRate, 0.75);
    });

    test('merges recent activity newest first', () async {
      final dashboard = await _service.load();

      expect(
        dashboard.recentActivity
            .map((item) => '${item.kind.name}:${item.id}')
            .toList(),
        ['training:21', 'match:11', 'match:10', 'training:20'],
      );
    });

    test('repeated queries return the same immutable view', () async {
      final first = await _service.load();
      final second = await _service.load();

      expect(first, second);
      expect(
        () => first.recentActivity.add(first.recentActivity.first),
        throwsUnsupportedError,
      );
    });

    test('empty sources produce zero rates without fallback', () async {
      final dashboard = await AnalyticsMvpService(
        loadMatches: () async => MatchAnalyticsSource(
          matchCount: 0,
          rackCount: 0,
          wins: 0,
          losses: 0,
          duration: Duration.zero,
          recent: const [],
        ),
        loadTraining: () async => TrainingAnalyticsSource(
          sessionCount: 0,
          exerciseCount: 0,
          attempts: 0,
          successes: 0,
          duration: Duration.zero,
          recent: const [],
        ),
      ).load();

      expect(dashboard.matchWinRate, 0);
      expect(dashboard.trainingSuccessRate, 0);
      expect(dashboard.recentActivity, isEmpty);
    });
  });
}

final _service = AnalyticsMvpService(
  loadMatches: () async => MatchAnalyticsSource(
    matchCount: 2,
    rackCount: 5,
    wins: 3,
    losses: 2,
    duration: const Duration(minutes: 90),
    recent: [
      MatchAnalyticsActivity(
        id: 10,
        occurredAt: DateTime.utc(2026, 7, 20),
        winRate: 0.5,
        duration: const Duration(minutes: 40),
      ),
      MatchAnalyticsActivity(
        id: 11,
        occurredAt: DateTime.utc(2026, 7, 22),
        winRate: 2 / 3,
        duration: const Duration(minutes: 50),
      ),
    ],
  ),
  loadTraining: () async => TrainingAnalyticsSource(
    sessionCount: 3,
    exerciseCount: 6,
    attempts: 20,
    successes: 15,
    duration: const Duration(minutes: 120),
    recent: [
      TrainingAnalyticsActivity(
        id: 20,
        occurredAt: DateTime.utc(2026, 7, 19),
        successRate: 0.7,
        duration: const Duration(minutes: 50),
      ),
      TrainingAnalyticsActivity(
        id: 21,
        occurredAt: DateTime.utc(2026, 7, 23),
        successRate: 0.8,
        duration: const Duration(minutes: 70),
      ),
    ],
  ),
);
