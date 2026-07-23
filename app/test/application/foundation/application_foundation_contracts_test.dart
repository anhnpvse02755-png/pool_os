import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/application/foundation/application_context.dart';
import 'package:pool_os/application/foundation/application_handlers.dart';
import 'package:pool_os/application/foundation/application_messages.dart';
import 'package:pool_os/shared/foundation/identifier.dart';

void main() {
  test('request context canonicalizes and protects metadata', () {
    final source = {'z': 'last', 'a': 'first'};
    final context = ApplicationRequestContext(
      requestId: RuntimeIdentifier(
        namespace: 'application.request',
        value: 'request-1',
      ),
      correlationId: RuntimeIdentifier(
        namespace: 'application.correlation',
        value: 'correlation-1',
      ),
      requestedAtUtc: DateTime.utc(2026, 7, 23),
      metadata: source,
    );
    source['later'] = 'ignored';

    expect(context.metadata.keys, ['a', 'z']);
    expect(() => context.metadata['x'] = 'blocked', throwsUnsupportedError);
    expect(
      context,
      ApplicationRequestContext(
        requestId: RuntimeIdentifier(
          namespace: 'application.request',
          value: 'request-1',
        ),
        correlationId: RuntimeIdentifier(
          namespace: 'application.correlation',
          value: 'correlation-1',
        ),
        requestedAtUtc: DateTime.utc(2026, 7, 23),
        metadata: {'a': 'first', 'z': 'last'},
      ),
    );
  });

  test('Application ports retain compile-time generic boundaries', () {
    ApplicationCommand<String>? command;
    ApplicationQuery<int>? query;
    CommandHandler<ApplicationCommand<String>, String>? commandHandler;
    QueryHandler<ApplicationQuery<int>, int>? queryHandler;
    ApplicationPipeline<ApplicationCommand<String>, String>? pipeline;
    CancellationToken? cancellationToken;

    _acceptRequest<String>(command);
    _acceptRequest<int>(query);
    _acceptHandler<ApplicationCommand<String>, String>(commandHandler);
    _acceptHandler<ApplicationQuery<int>, int>(queryHandler);
    _acceptPipeline<ApplicationCommand<String>, String>(pipeline);

    expect(
      [
        command,
        query,
        commandHandler,
        queryHandler,
        pipeline,
        cancellationToken,
      ],
      everyElement(isNull),
    );
  });
}

void _acceptRequest<TResult>(ApplicationRequest<TResult>? request) {}

void _acceptHandler<TRequest, TResult>(
  ApplicationHandler<TRequest, TResult>? handler,
) {}

void _acceptPipeline<TRequest, TResult>(
  ApplicationPipeline<TRequest, TResult>? pipeline,
) {}
