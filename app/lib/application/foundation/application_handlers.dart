import '../../shared/foundation/result.dart';
import 'application_context.dart';

abstract interface class ApplicationHandler<TRequest, TResult> {
  Future<Result<TResult>> handle(
    TRequest request,
    ApplicationExecutionContext context,
  );
}

abstract interface class CommandHandler<TCommand, TResult>
    implements ApplicationHandler<TCommand, TResult> {}

abstract interface class QueryHandler<TQuery, TResult>
    implements ApplicationHandler<TQuery, TResult> {}

/// Pipeline contract only. Ordering and execution policy are not implemented.
abstract interface class ApplicationPipeline<TRequest, TResult> {
  Future<Result<TResult>> execute(
    TRequest request,
    ApplicationExecutionContext context,
    ApplicationHandler<TRequest, TResult> terminal,
  );
}
