const matchLifecyclePolicyVersion = 1;

enum MatchLifecycleState {
  recording,
  completed,
  invalid,
}

enum MatchLifecycleFailureCode {
  targetNotFound('match-lifecycle-target-not-found'),
  invalidSourceState('match-lifecycle-invalid-source-state'),
  invalidTransition('match-lifecycle-invalid-transition'),
  timestampMissing('match-lifecycle-timestamp-missing'),
  timestampOrderInvalid('match-lifecycle-timestamp-order-invalid'),
  idempotencyConflict('match-lifecycle-idempotency-conflict'),
  databaseFailure('match-lifecycle-database-failure'),
  sourceReadFailure('match-lifecycle-source-read-failure');

  const MatchLifecycleFailureCode(this.value);

  final String value;
}

final class MatchLifecycleException implements Exception {
  const MatchLifecycleException(this.code, {this.cause});

  final MatchLifecycleFailureCode code;
  final Object? cause;

  @override
  String toString() => code.value;
}

final class MatchLifecycleSource {
  const MatchLifecycleSource({
    required this.startTime,
    required this.endTime,
  });

  final DateTime? startTime;
  final DateTime? endTime;
}

final class MatchLifecycleAssessment {
  const MatchLifecycleAssessment({
    required this.policyVersion,
    required this.state,
    required this.startTime,
    required this.endTime,
  });

  final int policyVersion;
  final MatchLifecycleState state;
  final DateTime? startTime;
  final DateTime? endTime;

  bool get isValid => state != MatchLifecycleState.invalid;
}

final class MatchLifecyclePolicy {
  const MatchLifecyclePolicy();

  MatchLifecycleAssessment assess(MatchLifecycleSource source) {
    final start = canonicalize(source.startTime);
    final end = canonicalize(source.endTime);
    final state = switch ((start, end)) {
      (_, null) => MatchLifecycleState.recording,
      (null, _) => MatchLifecycleState.invalid,
      (final DateTime start, final DateTime end) when end.isBefore(start) =>
        MatchLifecycleState.invalid,
      _ => MatchLifecycleState.completed,
    };
    return MatchLifecycleAssessment(
      policyVersion: matchLifecyclePolicyVersion,
      state: state,
      startTime: start,
      endTime: end,
    );
  }

  DateTime requireStart(DateTime? value) {
    if (value == null) {
      throw const MatchLifecycleException(
        MatchLifecycleFailureCode.timestampMissing,
      );
    }
    return canonicalize(value)!;
  }

  ({DateTime? startTime, DateTime endTime}) requireFinish({
    required DateTime? startTime,
    required DateTime? endTime,
  }) {
    if (endTime == null) {
      throw const MatchLifecycleException(
        MatchLifecycleFailureCode.timestampMissing,
      );
    }
    final canonicalStart = canonicalize(startTime);
    final canonicalEnd = canonicalize(endTime)!;
    if (canonicalStart != null && canonicalEnd.isBefore(canonicalStart)) {
      throw const MatchLifecycleException(
        MatchLifecycleFailureCode.timestampOrderInvalid,
      );
    }
    return (startTime: canonicalStart, endTime: canonicalEnd);
  }

  DateTime? canonicalize(DateTime? value) {
    if (value == null) return null;
    final seconds = value.toUtc().millisecondsSinceEpoch ~/ 1000;
    return DateTime.fromMillisecondsSinceEpoch(
      seconds * 1000,
      isUtc: true,
    );
  }
}
