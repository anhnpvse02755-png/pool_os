import '../foundation/application_handlers.dart';

export '../foundation/application_handlers.dart'
    show CommandHandler, QueryHandler;

/// Generic handler ownership contract. Execution remains implementation-free.
abstract interface class RequestHandler<TRequest, TResult>
    implements ApplicationHandler<TRequest, TResult> {}
