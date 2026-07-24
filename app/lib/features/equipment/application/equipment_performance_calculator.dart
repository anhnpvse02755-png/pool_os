import '../domain/equipment_performance_projection.dart';

enum EquipmentActivityKind { match, training }

final class EquipmentPerformanceActivity {
  const EquipmentPerformanceActivity({
    required this.kind,
    required this.sourceId,
    required this.sessionId,
    required this.endedAt,
    required this.durationSeconds,
    required this.won,
    required this.attempts,
    required this.successes,
  });

  final EquipmentActivityKind kind;
  final String sourceId;
  final int sessionId;
  final DateTime endedAt;
  final int durationSeconds;
  final bool won;
  final int attempts;
  final int successes;

  Map<String, Object> toJson() => {
        'kind': kind.name,
        'sourceId': sourceId,
        'sessionId': sessionId,
        'endedAt': endedAt.toUtc().toIso8601String(),
        'durationSeconds': durationSeconds,
        'won': won,
        'attempts': attempts,
        'successes': successes,
      };
}

final class EquipmentPerformanceCalculator {
  const EquipmentPerformanceCalculator();

  EquipmentPerformanceProjection calculate({
    required int playerId,
    required int equipmentId,
    required List<EquipmentPerformanceActivity> activities,
  }) {
    final ordered = [...activities]..sort((left, right) {
        final byTime = left.endedAt.toUtc().compareTo(right.endedAt.toUtc());
        if (byTime != 0) return byTime;
        final byKind = left.kind.index.compareTo(right.kind.index);
        return byKind != 0 ? byKind : left.sourceId.compareTo(right.sourceId);
      });
    final identities = <String>{};
    for (final activity in ordered) {
      if (activity.sourceId.trim().isEmpty ||
          !identities.add('${activity.kind.name}:${activity.sourceId}') ||
          activity.sessionId <= 0 ||
          activity.durationSeconds < 0 ||
          activity.attempts < 0 ||
          activity.successes < 0 ||
          activity.successes > activity.attempts) {
        throw ArgumentError('Equipment performance activity is invalid.');
      }
    }

    final matches = ordered
        .where((item) => item.kind == EquipmentActivityKind.match)
        .toList();
    final training = ordered
        .where((item) => item.kind == EquipmentActivityKind.training)
        .toList();
    final trainingSessionIds = training.map((item) => item.sessionId).toSet();
    final trainingAttempts =
        training.fold(0, (sum, item) => sum + item.attempts);
    final trainingSuccesses =
        training.fold(0, (sum, item) => sum + item.successes);
    final trainingDurations = <int, int>{};
    for (final item in training) {
      final prior = trainingDurations[item.sessionId] ?? 0;
      if (item.durationSeconds > prior) {
        trainingDurations[item.sessionId] = item.durationSeconds;
      }
    }
    final recordedDuration = matches.fold<int>(
          0,
          (sum, item) => sum + item.durationSeconds,
        ) +
        trainingDurations.values.fold<int>(0, (sum, value) => sum + value);

    return EquipmentPerformanceProjection.create(
      playerId: playerId,
      equipmentId: equipmentId,
      totalMatches: matches.length,
      matchWinRate: matches.isEmpty
          ? 0
          : matches.where((item) => item.won).length * 100 / matches.length,
      totalTrainingSessions: trainingSessionIds.length,
      trainingSuccessRate: trainingAttempts == 0
          ? 0
          : trainingSuccesses * 100 / trainingAttempts,
      recordedDurationSeconds: recordedDuration,
      lastUsed: ordered.isEmpty ? null : ordered.last.endedAt,
      sourceDigest: equipmentPerformanceDigest({
        'playerId': playerId,
        'equipmentId': equipmentId,
        'activities': ordered.map((item) => item.toJson()).toList(),
      }),
    );
  }
}
