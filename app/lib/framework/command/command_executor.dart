import '../../application/foundation/application_context.dart';
import '../../application/foundation/application_handlers.dart';
import '../../framework/execution/execution_pipeline.dart';
import '../../shared/foundation/failure.dart';
import '../../shared/foundation/identifier.dart';
import '../../shared/foundation/result.dart';
import '../../shared/foundation/value_object.dart';

final class CommandPolicy extends ValueObject {
  const CommandPolicy({
    this.execution = const ExecutionPolicy(),
  });

  final ExecutionPolicy execution;

  @override
  List<Object?> get components => [execution];
}

final class CommandDiagnostics extends ValueObject {
  const CommandDiagnostics({
    required this.executionId,
    required this.handlerId,
    required this.execution,
  });

  final RuntimeIdentifier executionId;
  final RuntimeIdentifier handlerId;
  final ExecutionDiagnostics execution;

  @override
  List<Object?> get components => [executionId, handlerId, execution];
}

final class CommandExecutor<TCommand extends ValueObject,
    TResult extends ValueObject> {
  const CommandExecutor({
    required this.handler,
    required this.handlerId,
    this.policy = const CommandPolicy(),
  });

  final CommandHandler<TCommand, TResult> handler;
  final RuntimeIdentifier handlerId;
  final CommandPolicy policy;

  Future<({Result<TResult> result, CommandDiagnostics diagnostics})> execute({
    required TCommand command,
    required ApplicationExecutionContext context,
  }) async {
    final pipeline = ExecutionPipeline<_CommandInvocation<TCommand, TResult>>(
      stages: [_CommandHandlerStage(handlerId, handler)],
      policy: policy.execution,
    );
    final execution = await pipeline.execute(
      initialValue: _CommandInvocation(command: command),
      context: ExecutionContext(application: context),
    );
    final diagnostics = CommandDiagnostics(
      executionId: context.request.requestId,
      handlerId: handlerId,
      execution: execution.diagnostics,
    );

    if (execution.cancelled) {
      return (
        result: FailureResult<TResult>(_failure(
          id: context.request.requestId,
          code: 'command-execution-cancelled',
          category: FailureCategory.cancelled,
        )),
        diagnostics: diagnostics,
      );
    }
    if (execution.error != null) {
      return (
        result: FailureResult<TResult>(_failure(
          id: context.request.requestId,
          code: 'command-handler-threw',
          category: FailureCategory.unexpectedDefect,
        )),
        diagnostics: diagnostics,
      );
    }

    final result = execution.value?.result;
    if (result == null) {
      throw StateError('Successful command execution must contain a result');
    }
    return (result: result, diagnostics: diagnostics);
  }
}

final class _CommandInvocation<TCommand extends ValueObject,
    TResult extends ValueObject> extends ValueObject {
  const _CommandInvocation({required this.command, this.result});

  final TCommand command;
  final Result<TResult>? result;

  @override
  List<Object?> get components => [command, result];
}

final class _CommandHandlerStage<TCommand extends ValueObject,
        TResult extends ValueObject>
    implements ExecutionStage<_CommandInvocation<TCommand, TResult>> {
  const _CommandHandlerStage(this.identity, this.handler);

  @override
  final RuntimeIdentifier identity;

  final CommandHandler<TCommand, TResult> handler;

  @override
  int get order => 0;

  @override
  Future<_CommandInvocation<TCommand, TResult>> execute(
    _CommandInvocation<TCommand, TResult> value,
    ExecutionContext context,
  ) async {
    final result = await handler.handle(value.command, context.application);
    return _CommandInvocation(command: value.command, result: result);
  }
}

Failure _failure({
  required RuntimeIdentifier id,
  required String code,
  required FailureCategory category,
}) =>
    Failure(
      id: id.value,
      code: code,
      category: category,
      sourceOwner: 'command-executor',
      stage: 'handler-invocation',
    );
