import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/application/foundation/application_context.dart';
import 'package:pool_os/application/foundation/application_handlers.dart';
import 'package:pool_os/framework/execution/execution_pipeline.dart';
import 'package:pool_os/framework/query/query_executor.dart';
import 'package:pool_os/shared/foundation/failure.dart';
import 'package:pool_os/shared/foundation/identifier.dart';
import 'package:pool_os/shared/foundation/result.dart';
import 'package:pool_os/shared/foundation/value_object.dart';

void main() {
  test('invokes the accepted query handler exactly once', () async {
    final handler = _Handler((query) => Success(_Output(query.value + 1)));

    final execution = await _executor(handler).execute(
      query: const _Query(4),
      context: _context(const _CancellationToken(false)),
    );

    expect(handler.invocationCount, 1);
    expect(execution.result, isA<Success<_Output>>());
    expect((execution.result as Success<_Output>).value, const _Output(5));
    expect(execution.diagnostics.handlerId.value, 'fixture');
    expect(
      execution.diagnostics.execution.traversedStages,
      [execution.diagnostics.handlerId],
    );
  });

  test('preserves a fail-closed result returned by the query handler',
      () async {
    final failure = _failure('rejected');
    final handler = _Handler((_) => FailureResult<_Output>(failure));

    final execution = await _executor(handler).execute(
      query: const _Query(1),
      context: _context(const _CancellationToken(false)),
    );

    expect(execution.result, isA<FailureResult<_Output>>());
    expect((execution.result as FailureResult<_Output>).failure, failure);
    expect(handler.invocationCount, 1);
  });

  test('cancellation prevents query handler invocation', () async {
    final handler = _Handler((query) => Success(_Output(query.value)));

    final execution = await _executor(handler).execute(
      query: const _Query(1),
      context: _context(const _CancellationToken(true)),
    );

    expect(handler.invocationCount, 0);
    final result = execution.result as FailureResult<_Output>;
    expect(result.failure.category, FailureCategory.cancelled);
    expect(execution.diagnostics.execution.cancelledStage?.value, 'fixture');
  });

  test('query handler exceptions fail closed', () async {
    final handler = _Handler((_) => throw StateError('unexpected'));

    final execution = await _executor(handler).execute(
      query: const _Query(1),
      context: _context(const _CancellationToken(false)),
    );

    final result = execution.result as FailureResult<_Output>;
    expect(result.failure.category, FailureCategory.unexpectedDefect);
    expect(execution.diagnostics.execution.failedStage?.value, 'fixture');
  });

  test('query policy can propagate handler exceptions', () async {
    final error = StateError('propagated');
    final handler = _Handler((_) => throw error);
    final executor = _executor(
      handler,
      policy: const QueryPolicy(
        execution: ExecutionPolicy(rethrowStageErrors: true),
      ),
    );

    expect(
      () => executor.execute(
        query: const _Query(1),
        context: _context(const _CancellationToken(false)),
      ),
      throwsA(same(error)),
    );
  });

  test('query diagnostics are immutable and deterministic', () async {
    final first = await _executor(
      _Handler((query) => Success(_Output(query.value))),
    ).execute(
      query: const _Query(1),
      context: _context(const _CancellationToken(false)),
    );
    final second = await _executor(
      _Handler((query) => Success(_Output(query.value))),
    ).execute(
      query: const _Query(1),
      context: _context(const _CancellationToken(false)),
    );

    expect(first.diagnostics, second.diagnostics);
    expect(
      () => first.diagnostics.execution.traversedStages.clear(),
      throwsUnsupportedError,
    );
  });
}

QueryExecutor<_Query, _Output> _executor(
  QueryHandler<_Query, _Output> handler, {
  QueryPolicy policy = const QueryPolicy(),
}) =>
    QueryExecutor(
      handler: handler,
      handlerId: _id('product.query-handler', 'fixture'),
      policy: policy,
    );

final class _Handler implements QueryHandler<_Query, _Output> {
  _Handler(this.callback);

  final Result<_Output> Function(_Query query) callback;
  int invocationCount = 0;

  @override
  Future<Result<_Output>> handle(
    _Query query,
    ApplicationExecutionContext context,
  ) async {
    invocationCount += 1;
    return callback(query);
  }
}

final class _Query extends ValueObject {
  const _Query(this.value);

  final int value;

  @override
  List<Object?> get components => [value];
}

final class _Output extends ValueObject {
  const _Output(this.value);

  final int value;

  @override
  List<Object?> get components => [value];
}

final class _CancellationToken implements CancellationToken {
  const _CancellationToken(this.isCancellationRequested);

  @override
  final bool isCancellationRequested;
}

ApplicationExecutionContext _context(CancellationToken token) =>
    ApplicationExecutionContext(
      request: ApplicationRequestContext(
        requestId: _id('product.query-execution', 'request-1'),
        correlationId: _id('product.query-correlation', 'correlation-1'),
        requestedAtUtc: DateTime.utc(2026, 7, 24),
      ),
      cancellationToken: token,
    );

Failure _failure(String code) => Failure(
      id: 'fixture-failure',
      code: code,
      category: FailureCategory.invariantRejected,
      sourceOwner: 'fixture',
      stage: 'handler',
    );

RuntimeIdentifier _id(String namespace, String value) =>
    RuntimeIdentifier(namespace: namespace, value: value);
