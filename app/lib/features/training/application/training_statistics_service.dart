import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../session/application/training_session_execution_service.dart';

final trainingStatisticsServiceProvider =
    Provider<TrainingStatisticsService>((ref) {
  return TrainingStatisticsService(
    ref.watch(trainingSessionExecutionServiceProvider),
  );
});

final class TrainingStatisticsService {
  const TrainingStatisticsService(this._sessions);

  final TrainingSessionExecutionService _sessions;

  Future<
      ({
        int sessionCount,
        int exerciseCount,
        int attempts,
        int successes,
        Duration duration,
        List<
            ({
              int sessionId,
              DateTime date,
              Duration duration,
              int exercises,
              int attempts,
              int successes,
              double successRate,
            })> recent,
        List<
            ({
              String code,
              String name,
              int attempts,
              int successes,
              double successRate,
            })> drills,
        List<
            ({
              int sessionId,
              DateTime date,
              double successRate,
            })> trend,
      })> load() async {
    final history = await _sessions.loadCompletedSessions();
    var exerciseCount = 0;
    var attempts = 0;
    var successes = 0;
    var duration = Duration.zero;
    final recent = <({
      int sessionId,
      DateTime date,
      Duration duration,
      int exercises,
      int attempts,
      int successes,
      double successRate,
    })>[];
    final drillTotals =
        <String, ({String name, int attempts, int successes})>{};
    for (final entry in history) {
      final sessionAttempts = entry.exercises.fold<int>(
        0,
        (sum, exercise) => sum + exercise.attempts,
      );
      final sessionSuccesses = entry.exercises.fold<int>(
        0,
        (sum, exercise) => sum + exercise.successes,
      );
      exerciseCount += entry.exercises.length;
      attempts += sessionAttempts;
      successes += sessionSuccesses;
      duration += entry.session.duration;
      recent.add((
        sessionId: entry.session.id!,
        date: entry.session.startedAt,
        duration: entry.session.duration,
        exercises: entry.exercises.length,
        attempts: sessionAttempts,
        successes: sessionSuccesses,
        successRate:
            sessionAttempts == 0 ? 0 : sessionSuccesses / sessionAttempts,
      ));
      for (final exercise in entry.exercises) {
        final current = drillTotals[exercise.code];
        drillTotals[exercise.code] = (
          name: current?.name ?? exercise.name,
          attempts: (current?.attempts ?? 0) + exercise.attempts,
          successes: (current?.successes ?? 0) + exercise.successes,
        );
      }
    }
    final drills = drillTotals.entries.map((entry) {
      final total = entry.value;
      return (
        code: entry.key,
        name: total.name,
        attempts: total.attempts,
        successes: total.successes,
        successRate:
            total.attempts == 0 ? 0.0 : total.successes / total.attempts,
      );
    }).toList()
      ..sort((left, right) => right.attempts.compareTo(left.attempts));
    final trend = recent
        .take(5)
        .toList()
        .reversed
        .map((entry) => (
              sessionId: entry.sessionId,
              date: entry.date,
              successRate: entry.successRate,
            ))
        .toList();
    return (
      sessionCount: history.length,
      exerciseCount: exerciseCount,
      attempts: attempts,
      successes: successes,
      duration: duration,
      recent: recent,
      drills: drills,
      trend: trend,
    );
  }
}
