import '../../application/foundation/application_context.dart';
import '../../application/foundation/application_handlers.dart';
import '../../framework/execution/execution_pipeline.dart';
import '../../shared/foundation/failure.dart';
import '../../shared/foundation/identifier.dart';
import '../../shared/foundation/result.dart';
import '../../shared/foundation/value_object.dart';

final class QueryPolicy extends ValueObject {
  const QueryPolicy({
    this.execution = const ExecutionPolicy(),
  });

  final ExecutionPolicy execution;

  @override
  List<Object?> get components => [execution];
}

final class QueryDiagnostics extends ValueObject {
  const QueryDiagnostics({
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

final class QueryExecutor<TQuery extends ValueObject,
    TResult extends ValueObject> {
  const QueryExecutor({
    required this.handler,
    required this.handlerId,
    this.policy = const QueryPolicy(),
  });

  final QueryHandler<TQuery, TResult> handler;
  final RuntimeIdentifier handlerId;
  final QueryPolicy policy;

  Future<({Result<TResult> result, QueryDiagnostics diagnostics})> execute({
    required TQuery query,
    required ApplicationExecutionContext context,
  }) async {
    final pipeline = ExecutionPipeline<_QueryInvocation<TQuery, TResult>>(
      stages: [_QueryHandlerStage(handlerId, handler)],
      policy: policy.execution,
    );
    final execution = await pipeline.execute(
      initialValue: _QueryInvocation(query: query),
      context: ExecutionContext(application: context),
    );
    final diagnostics = QueryDiagnostics(
      executionId: context.request.requestId,
      handlerId: handlerId,
      execution: execution.diagnostics,
    );

    if (execution.cancelled) {
      return (
        result: FailureResult<TResult>(_failure(
          id: context.request.requestId,
          code: 'query-execution-cancelled',
          category: FailureCategory.cancelled,
        )),
        diagnostics: diagnostics,
      );
    }
    if (execution.error != null) {
      return (
        result: FailureResult<TResult>(_failure(
          id: context.request.requestId,
          code: 'query-handler-threw',
          category: FailureCategory.unexpectedDefect,
        )),
        diagnostics: diagnostics,
      );
    }

    final result = execution.value?.result;
    if (result == null) {
      throw StateError('Successful query execution must contain a result');
    }
    return (result: result, diagnostics: diagnostics);
  }
}

final class _QueryInvocation<TQuery extends ValueObject,
    TResult extends ValueObject> extends ValueObject {
  const _QueryInvocation({required this.query, this.result});

  final TQuery query;
  final Result<TResult>? result;

  @override
  List<Object?> get components => [query, result];
}

final class _QueryHandlerStage<TQuery extends ValueObject,
        TResult extends ValueObject>
    implements ExecutionStage<_QueryInvocation<TQuery, TResult>> {
  const _QueryHandlerStage(this.identity, this.handler);

  @override
  final RuntimeIdentifier identity;

  final QueryHandler<TQuery, TResult> handler;

  @override
  int get order => 0;

  @override
  Future<_QueryInvocation<TQuery, TResult>> execute(
    _QueryInvocation<TQuery, TResult> value,
    ExecutionContext context,
  ) async {
    final result = await handler.handle(value.query, context.application);
    return _QueryInvocation(query: value.query, result: result);
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
      sourceOwner: 'query-executor',
      stage: 'handler-invocation',
    );
