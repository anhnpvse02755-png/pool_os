/// Marker for an Application request with a typed result boundary.
abstract interface class ApplicationRequest<TResult> {}

/// Intent to change system state. It contains no execution behavior.
abstract interface class ApplicationCommand<TResult>
    implements ApplicationRequest<TResult> {}

/// Intent to read system state. It contains no execution behavior.
abstract interface class ApplicationQuery<TResult>
    implements ApplicationRequest<TResult> {}
