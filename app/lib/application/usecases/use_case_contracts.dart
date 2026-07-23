import '../../shared/foundation/result.dart';
import '../foundation/application_context.dart';

/// Application use-case boundary only. No orchestration is implemented.
abstract interface class UseCase<TRequest, TResult> {
  Future<Result<TResult>> execute(
    TRequest request,
    ApplicationExecutionContext context,
  );
}

abstract interface class CommandUseCase<TRequest, TResult>
    implements UseCase<TRequest, TResult> {}

abstract interface class QueryUseCase<TRequest, TResult>
    implements UseCase<TRequest, TResult> {}
