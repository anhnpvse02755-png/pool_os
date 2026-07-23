import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/application/validation/validation_contracts.dart';
import 'package:pool_os/shared/foundation/identifier.dart';

void main() {
  test('validation value contracts defensively protect canonical data', () {
    final source = {'z': 'last', 'a': 'first'};
    final failure = ValidationFailure(
      code: RuntimeIdentifier(
        namespace: 'application.validation',
        value: 'required',
      ),
      messageKey: 'validation.required',
      context: source,
    );
    final failures = [failure];
    final result = ValidationResult(isValid: false, failures: failures);
    source['later'] = 'ignored';
    failures.clear();

    expect(failure.context.keys, ['a', 'z']);
    expect(result.failures, [failure]);
    expect(() => result.failures.clear(), throwsUnsupportedError);
  });

  test('validation ports retain compile-time generic boundaries', () {
    Validator<String>? validator;
    ValidationRule<String>? rule;
    CompositeValidator<String>? composite;

    _acceptValidator<String>(validator);
    _acceptRule<String>(rule);
    _acceptValidator<String>(composite);

    expect([validator, rule, composite], everyElement(isNull));
  });
}

void _acceptValidator<T>(Validator<T>? validator) {}

void _acceptRule<T>(ValidationRule<T>? rule) {}
