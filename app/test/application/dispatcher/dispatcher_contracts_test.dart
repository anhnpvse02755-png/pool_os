import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/application/dispatcher/dispatcher_contracts.dart';

void main() {
  test('dispatcher ports retain compile-time generic boundaries', () {
    ApplicationDispatcher<String, int>? application;
    CommandDispatcher<String, int>? command;
    QueryDispatcher<String, int>? query;

    _acceptDispatcher<String, int>(application);
    _acceptDispatcher<String, int>(command);
    _acceptDispatcher<String, int>(query);

    expect([application, command, query], everyElement(isNull));
  });
}

void _acceptDispatcher<TRequest, TResult>(
  ApplicationDispatcher<TRequest, TResult>? dispatcher,
) {}
