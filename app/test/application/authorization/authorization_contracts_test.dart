import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/application/authorization/authorization_contracts.dart';
import 'package:pool_os/shared/foundation/identifier.dart';

void main() {
  test('authorization contracts defensively protect canonical data', () {
    final source = {'z': 'last', 'a': 'first'};
    final context = AuthorizationContext(
      correlationId: RuntimeIdentifier(
        namespace: 'application.correlation',
        value: 'correlation-1',
      ),
      subjectReferenceId: RuntimeIdentifier(
        namespace: 'application.subject',
        value: 'subject-1',
      ),
      attributes: source,
    );
    final requirement = AuthorizationRequirement(
      id: RuntimeIdentifier(
        namespace: 'application.requirement',
        value: 'requirement-1',
      ),
    );
    final requirements = [requirement];
    final result = AuthorizationResult(
      decision: AuthorizationDecision.indeterminate,
      requirements: requirements,
    );
    source['later'] = 'ignored';
    requirements.clear();

    expect(context.attributes.keys, ['a', 'z']);
    expect(result.requirements, [requirement]);
    expect(() => result.requirements.clear(), throwsUnsupportedError);
  });

  test('authorization ports retain compile-time boundaries', () {
    AuthorizationHandler<AuthorizationRequirement>? handler;
    AuthorizationService? service;

    _acceptHandler(handler);
    _acceptService(service);

    expect([handler, service], everyElement(isNull));
  });
}

void _acceptHandler(
  AuthorizationHandler<AuthorizationRequirement>? handler,
) {}

void _acceptService(AuthorizationService? service) {}
