import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/application/usecases/use_case_contracts.dart';
import 'package:pool_os/application/usecases/use_case_messages.dart';
import 'package:pool_os/shared/foundation/identifier.dart';

void main() {
  test('use-case request and response carriers have typed value equality', () {
    final payload = RuntimeIdentifier(
      namespace: 'application.payload',
      value: 'payload-1',
    );

    expect(
      UseCaseRequest<RuntimeIdentifier>(payload: payload),
      UseCaseRequest<RuntimeIdentifier>(payload: payload),
    );
    expect(
      UseCaseResponse<RuntimeIdentifier>(payload: payload),
      UseCaseResponse<RuntimeIdentifier>(payload: payload),
    );
  });

  test('use-case ports retain compile-time generic boundaries', () {
    UseCase<UseCaseRequest<RuntimeIdentifier>,
        UseCaseResponse<RuntimeIdentifier>>? useCase;
    CommandUseCase<UseCaseRequest<RuntimeIdentifier>,
        UseCaseResponse<RuntimeIdentifier>>? command;
    QueryUseCase<UseCaseRequest<RuntimeIdentifier>,
        UseCaseResponse<RuntimeIdentifier>>? query;

    _acceptUseCase(useCase);
    _acceptUseCase(command);
    _acceptUseCase(query);

    expect([useCase, command, query], everyElement(isNull));
  });
}

void _acceptUseCase<TRequest, TResult>(
  UseCase<TRequest, TResult>? useCase,
) {}
