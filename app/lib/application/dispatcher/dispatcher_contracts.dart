import '../../shared/foundation/result.dart';
import '../foundation/application_context.dart';

/// Interface-only Application dispatch boundary.
abstract interface class ApplicationDispatcher<TRequest, TResult> {
  Future<Result<TResult>> dispatch(
    TRequest request,
    ApplicationExecutionContext context,
  );
}

abstract interface class CommandDispatcher<TCommand, TResult>
    implements ApplicationDispatcher<TCommand, TResult> {}

abstract interface class QueryDispatcher<TQuery, TResult>
    implements ApplicationDispatcher<TQuery, TResult> {}
