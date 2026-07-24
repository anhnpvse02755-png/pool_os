import '../../application/foundation/application_context.dart';
import '../../shared/foundation/identifier.dart';
import '../../shared/foundation/immutable.dart';
import '../../shared/foundation/value_object.dart';

final class ExecutionContext {
  const ExecutionContext({required this.application});

  final ApplicationExecutionContext application;
}

abstract interface class ExecutionStage<TValue extends ValueObject> {
  RuntimeIdentifier get identity;

  int get order;

  Future<TValue> execute(TValue value, ExecutionContext context);
}

final class ExecutionPolicy extends ValueObject {
  const ExecutionPolicy({
    this.checkCancellationBeforeEachStage = true,
    this.rethrowStageErrors = false,
  });

  final bool checkCancellationBeforeEachStage;
  final bool rethrowStageErrors;

  @override
  List<Object?> get components => [
        checkCancellationBeforeEachStage,
        rethrowStageErrors,
      ];
}

final class ExecutionDiagnostics extends ValueObject {
  ExecutionDiagnostics({
    Iterable<RuntimeIdentifier> traversedStages = const [],
    this.failedStage,
    this.cancelledStage,
  }) : traversedStages = immutableList(traversedStages);

  final List<RuntimeIdentifier> traversedStages;
  final RuntimeIdentifier? failedStage;
  final RuntimeIdentifier? cancelledStage;

  @override
  List<Object?> get components => [
        traversedStages.length,
        ...traversedStages,
        failedStage,
        cancelledStage,
      ];
}

final class ExecutionResult<TValue extends ValueObject> {
  const ExecutionResult._({
    required this.value,
    required this.error,
    required this.cancelled,
    required this.diagnostics,
  });

  factory ExecutionResult.success({
    required TValue value,
    required ExecutionDiagnostics diagnostics,
  }) =>
      ExecutionResult._(
        value: value,
        error: null,
        cancelled: false,
        diagnostics: diagnostics,
      );

  factory ExecutionResult.failure({
    required Object error,
    required ExecutionDiagnostics diagnostics,
  }) =>
      ExecutionResult._(
        value: null,
        error: error,
        cancelled: false,
        diagnostics: diagnostics,
      );

  factory ExecutionResult.cancelled({
    required ExecutionDiagnostics diagnostics,
  }) =>
      ExecutionResult._(
        value: null,
        error: null,
        cancelled: true,
        diagnostics: diagnostics,
      );

  final TValue? value;
  final Object? error;
  final bool cancelled;
  final ExecutionDiagnostics diagnostics;

  bool get isSuccess => value != null && error == null && !cancelled;
  bool get isFailure => error != null;
}

final class ExecutionPipeline<TValue extends ValueObject> {
  ExecutionPipeline({
    Iterable<ExecutionStage<TValue>> stages = const [],
    this.policy = const ExecutionPolicy(),
  }) : stages = _orderedStages(stages);

  final List<ExecutionStage<TValue>> stages;
  final ExecutionPolicy policy;

  Future<ExecutionResult<TValue>> execute({
    required TValue initialValue,
    required ExecutionContext context,
  }) async {
    var value = initialValue;
    final traversedStages = <RuntimeIdentifier>[];

    for (final stage in stages) {
      if (policy.checkCancellationBeforeEachStage &&
          context.application.cancellationToken.isCancellationRequested) {
        return ExecutionResult.cancelled(
          diagnostics: ExecutionDiagnostics(
            traversedStages: traversedStages,
            cancelledStage: stage.identity,
          ),
        );
      }

      try {
        value = await stage.execute(value, context);
        traversedStages.add(stage.identity);
      } catch (error) {
        if (policy.rethrowStageErrors) rethrow;
        return ExecutionResult.failure(
          error: error,
          diagnostics: ExecutionDiagnostics(
            traversedStages: traversedStages,
            failedStage: stage.identity,
          ),
        );
      }
    }

    return ExecutionResult.success(
      value: value,
      diagnostics: ExecutionDiagnostics(traversedStages: traversedStages),
    );
  }
}

List<ExecutionStage<TValue>> _orderedStages<TValue extends ValueObject>(
  Iterable<ExecutionStage<TValue>> stages,
) {
  final snapshot = stages.toList();
  final identities = <RuntimeIdentifier>{};
  for (final stage in snapshot) {
    if (!identities.add(stage.identity)) {
      throw ArgumentError.value(
        stage.identity,
        'stages',
        'Execution stage identities must be unique',
      );
    }
  }
  snapshot.sort((left, right) {
    final order = left.order.compareTo(right.order);
    return order != 0 ? order : left.identity.compareTo(right.identity);
  });
  return immutableList(snapshot);
}
