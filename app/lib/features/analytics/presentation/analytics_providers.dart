import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../match/application/match_statistics_service.dart';
import '../../training/application/training_statistics_service.dart';
import '../application/analytics_mvp_service.dart';

final analyticsMvpServiceProvider = Provider<AnalyticsMvpService>((ref) {
  final matches = ref.watch(matchStatisticsServiceProvider);
  final training = ref.watch(trainingStatisticsServiceProvider);
  return AnalyticsMvpService(
    loadMatches: () async {
      final source = await matches.load();
      return MatchAnalyticsSource(
        matchCount: source.matchCount,
        rackCount: source.rackCount,
        wins: source.wins,
        losses: source.losses,
        duration: source.duration,
        recent: [
          for (final entry in source.performance)
            MatchAnalyticsActivity(
              id: entry.match.id!,
              occurredAt: entry.match.endTime!,
              winRate: entry.winRate,
              duration: entry.match.duration ?? Duration.zero,
            ),
        ],
      );
    },
    loadTraining: () async {
      final source = await training.load();
      return TrainingAnalyticsSource(
        sessionCount: source.sessionCount,
        exerciseCount: source.exerciseCount,
        attempts: source.attempts,
        successes: source.successes,
        duration: source.duration,
        recent: [
          for (final entry in source.recent)
            TrainingAnalyticsActivity(
              id: entry.sessionId,
              occurredAt: entry.date,
              successRate: entry.successRate,
              duration: entry.duration,
            ),
        ],
      );
    },
  );
});

final analyticsDashboardProvider = FutureProvider<AnalyticsDashboardView>(
  (ref) => ref.watch(analyticsMvpServiceProvider).load(),
);
