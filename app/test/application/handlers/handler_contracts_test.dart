import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/application/foundation/application_handlers.dart'
    show ApplicationHandler;
import 'package:pool_os/application/handlers/handler_contracts.dart';

void main() {
  test('handler namespace retains compile-time generic contracts', () {
    RequestHandler<String, int>? request;
    CommandHandler<String, int>? command;
    QueryHandler<String, int>? query;

    _acceptHandler<String, int>(request);
    _acceptHandler<String, int>(command);
    _acceptHandler<String, int>(query);

    expect([request, command, query], everyElement(isNull));
  });
}

void _acceptHandler<TRequest, TResult>(
  ApplicationHandler<TRequest, TResult>? handler,
) {}
