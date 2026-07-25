import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/match/domain/match_lifecycle_policy.dart';

void main() {
  const policy = MatchLifecyclePolicy();

  test('failure codes are stable literals', () {
    expect(
      MatchLifecycleFailureCode.values.map((code) => code.value),
      const [
        'match-lifecycle-target-not-found',
        'match-lifecycle-invalid-source-state',
        'match-lifecycle-invalid-transition',
        'match-lifecycle-timestamp-missing',
        'match-lifecycle-timestamp-order-invalid',
        'match-lifecycle-idempotency-conflict',
        'match-lifecycle-database-failure',
        'match-lifecycle-source-read-failure',
      ],
    );
  });

  test('null or present start with null end classifies as recording', () {
    for (final start in [null, DateTime.utc(2026, 7, 25, 10)]) {
      final assessment = policy.assess(
        MatchLifecycleSource(startTime: start, endTime: null),
      );
      expect(assessment.policyVersion, matchLifecyclePolicyVersion);
      expect(assessment.state, MatchLifecycleState.recording);
      expect(assessment.isValid, isTrue);
    }
  });

  test('ordered start and end classify as completed', () {
    final start = DateTime.utc(2026, 7, 25, 10);
    for (final end in [start, start.add(const Duration(hours: 1))]) {
      expect(
        policy
            .assess(MatchLifecycleSource(startTime: start, endTime: end))
            .state,
        MatchLifecycleState.completed,
      );
    }
  });

  test('end without start and end before start classify as invalid', () {
    final start = DateTime.utc(2026, 7, 25, 10);
    expect(
      policy
          .assess(MatchLifecycleSource(startTime: null, endTime: start))
          .state,
      MatchLifecycleState.invalid,
    );
    expect(
      policy
          .assess(
            MatchLifecycleSource(
              startTime: start,
              endTime: start.subtract(const Duration(seconds: 1)),
            ),
          )
          .state,
      MatchLifecycleState.invalid,
    );
  });

  test('command instants canonicalize to UTC whole Unix seconds', () {
    final localOffset = DateTime.parse('2026-07-25T17:30:15.987654+07:00');
    final canonical = policy.canonicalize(localOffset)!;

    expect(canonical.isUtc, isTrue);
    expect(canonical.toIso8601String(), '2026-07-25T10:30:15.000Z');
    expect(canonical.millisecond, 0);
    expect(canonical.microsecond, 0);
  });

  test('start and finish require their locked timestamps', () {
    expect(
      () => policy.requireStart(null),
      throwsA(_failure(MatchLifecycleFailureCode.timestampMissing)),
    );
    expect(
      () => policy.requireFinish(startTime: null, endTime: null),
      throwsA(_failure(MatchLifecycleFailureCode.timestampMissing)),
    );
  });

  test('supplied finish start must not follow end', () {
    final end = DateTime.utc(2026, 7, 25, 10);
    expect(
      () => policy.requireFinish(
        startTime: end.add(const Duration(seconds: 1)),
        endTime: end,
      ),
      throwsA(_failure(MatchLifecycleFailureCode.timestampOrderInvalid)),
    );
  });
}

Matcher _failure(MatchLifecycleFailureCode code) =>
    isA<MatchLifecycleException>().having(
      (error) => error.code,
      'code',
      code,
    );
