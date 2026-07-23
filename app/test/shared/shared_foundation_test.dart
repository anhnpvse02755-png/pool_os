import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/shared/foundation/failure.dart';
import 'package:pool_os/shared/foundation/identifier.dart';
import 'package:pool_os/shared/foundation/immutable.dart';
import 'package:pool_os/shared/foundation/result.dart';

void main() {
  test('Result maps success and preserves structured failure', () {
    const Result<int> success = Success(4);
    expect(
        success.map((value) => value * 2).fold(
              onSuccess: (value) => value,
              onFailure: (_) => -1,
            ),
        8);

    final failure = Failure(
      id: 'request.failure.1',
      code: 'request.stale',
      category: FailureCategory.staleConflict,
      sourceOwner: 'test.owner',
      stage: 'test.stage',
      retryDirective: RetryDirective.afterRefresh,
    );
    final Result<int> failed = FailureResult(failure);
    expect(failed.map((value) => value * 2), isA<FailureResult<int>>());
    expect(
      failed.fold(onSuccess: (_) => null, onFailure: (value) => value),
      same(failure),
    );
  });

  test('Failure is canonical, immutable, and source preserving', () {
    final failure = Failure(
      id: 'error.1',
      code: 'dependency.unavailable',
      category: FailureCategory.dependencyUnavailable,
      sourceOwner: 'knowledge.publication',
      stage: 'query.resolve',
      retryDirective: RetryDirective.ownerPolicy,
      recoveryActions: const ['returnSafeNode', 'retryEligibleQuery'],
      context: const {'version': '2', 'contract': 'knowledge.query.v1'},
      sourceFailureId: 'knowledge.error.7',
    );

    expect(failure.context.keys, orderedEquals(['contract', 'version']));
    expect(() => failure.context['x'] = 'y', throwsUnsupportedError);
    expect(
        () => failure.recoveryActions.add('fallback'), throwsUnsupportedError);
    expect(failure.sourceFailureId, 'knowledge.error.7');
    expect(
      failure,
      Failure(
        id: 'error.1',
        code: 'dependency.unavailable',
        category: FailureCategory.dependencyUnavailable,
        sourceOwner: 'knowledge.publication',
        stage: 'query.resolve',
        retryDirective: RetryDirective.ownerPolicy,
        recoveryActions: const ['returnSafeNode', 'retryEligibleQuery'],
        context: const {'contract': 'knowledge.query.v1', 'version': '2'},
        sourceFailureId: 'knowledge.error.7',
      ),
    );
  });

  test('RuntimeIdentifier is stable, typed, and validated', () {
    final left =
        RuntimeIdentifier(namespace: 'runtime.request', value: 'abc-123');
    final right =
        RuntimeIdentifier(namespace: 'runtime.request', value: 'abc-123');

    expect(left, right);
    expect(left.canonical, 'runtime.request:abc-123');
    expect(
      () => RuntimeIdentifier(namespace: 'Runtime Request', value: 'abc'),
      throwsArgumentError,
    );
  });

  test('immutable helpers copy and canonicalize collections', () {
    final source = ['a'];
    final list = immutableList(source);
    source.add('b');
    expect(list, ['a']);
    expect(() => list.add('c'), throwsUnsupportedError);

    final map = immutableCanonicalMap({'z': 1, 'a': 2});
    expect(map.keys, orderedEquals(['a', 'z']));
    expect(() => map['x'] = 3, throwsUnsupportedError);
  });
}
