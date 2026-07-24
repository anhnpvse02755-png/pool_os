import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/application/foundation/application_context.dart';
import 'package:pool_os/application/foundation/application_handlers.dart';
import 'package:pool_os/framework/command/command_executor.dart';
import 'package:pool_os/framework/execution/execution_pipeline.dart';
import 'package:pool_os/shared/foundation/failure.dart';
import 'package:pool_os/shared/foundation/identifier.dart';
import 'package:pool_os/shared/foundation/result.dart';
import 'package:pool_os/shared/foundation/value_object.dart';

void main() {
  test('invokes the accepted handler exactly once and returns its result',
      () async {
    final handler = _Handler((command) => Success(_Output(command.value + 1)));
    final executor = _executor(handler);

    final execution = await executor.execute(
      command: const _Command(4),
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

  test('preserves a fail-closed result returned by the handler', () async {
    final failure = _failure('rejected');
    final handler = _Handler((_) => FailureResult<_Output>(failure));

    final execution = await _executor(handler).execute(
      command: const _Command(1),
      context: _context(const _CancellationToken(false)),
    );

    expect(execution.result, isA<FailureResult<_Output>>());
    expect((execution.result as FailureResult<_Output>).failure, failure);
    expect(handler.invocationCount, 1);
  });

  test('cancellation prevents handler invocation and returns cancellation',
      () async {
    final handler = _Handler((command) => Success(_Output(command.value)));

    final execution = await _executor(handler).execute(
      command: const _Command(1),
      context: _context(const _CancellationToken(true)),
    );

    expect(handler.invocationCount, 0);
    final result = execution.result as FailureResult<_Output>;
    expect(result.failure.category, FailureCategory.cancelled);
    expect(execution.diagnostics.execution.cancelledStage?.value, 'fixture');
  });

  test('handler exceptions fail closed without leaking a partial value',
      () async {
    final handler = _Handler((_) => throw StateError('unexpected'));

    final execution = await _executor(handler).execute(
      command: const _Command(1),
      context: _context(const _CancellationToken(false)),
    );

    final result = execution.result as FailureResult<_Output>;
    expect(result.failure.category, FailureCategory.unexpectedDefect);
    expect(execution.diagnostics.execution.failedStage?.value, 'fixture');
  });

  test('policy can propagate a handler exception directly', () async {
    final error = StateError('propagated');
    final handler = _Handler((_) => throw error);
    final executor = _executor(
      handler,
      policy: const CommandPolicy(
        execution: ExecutionPolicy(rethrowStageErrors: true),
      ),
    );

    expect(
      () => executor.execute(
        command: const _Command(1),
        context: _context(const _CancellationToken(false)),
      ),
      throwsA(same(error)),
    );
  });

  test('diagnostics are immutable and deterministic for the same invocation',
      () async {
    final first = await _executor(
      _Handler((command) => Success(_Output(command.value))),
    ).execute(
      command: const _Command(1),
      context: _context(const _CancellationToken(false)),
    );
    final second = await _executor(
      _Handler((command) => Success(_Output(command.value))),
    ).execute(
      command: const _Command(1),
      context: _context(const _CancellationToken(false)),
    );

    expect(first.diagnostics, second.diagnostics);
    expect(
      () => first.diagnostics.execution.traversedStages.clear(),
      throwsUnsupportedError,
    );
  });
}

CommandExecutor<_Command, _Output> _executor(
  CommandHandler<_Command, _Output> handler, {
  CommandPolicy policy = const CommandPolicy(),
}) =>
    CommandExecutor(
      handler: handler,
      handlerId: _id('product.command-handler', 'fixture'),
      policy: policy,
    );

final class _Handler implements CommandHandler<_Command, _Output> {
  _Handler(this.callback);

  final Result<_Output> Function(_Command command) callback;
  int invocationCount = 0;

  @override
  Future<Result<_Output>> handle(
    _Command command,
    ApplicationExecutionContext context,
  ) async {
    invocationCount += 1;
    return callback(command);
  }
}

final class _Command extends ValueObject {
  const _Command(this.value);

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
        requestId: _id('product.command-execution', 'request-1'),
        correlationId: _id('product.command-correlation', 'correlation-1'),
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
