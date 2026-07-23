import '../../shared/foundation/identifier.dart';
import '../../shared/foundation/immutable.dart';
import '../../shared/foundation/value_object.dart';

final class ValidationFailure extends ValueObject {
  ValidationFailure({
    required this.code,
    required this.messageKey,
    Map<String, String> context = const {},
  }) : context = immutableCanonicalMap(context);

  final RuntimeIdentifier code;
  final String messageKey;
  final Map<String, String> context;

  @override
  List<Object?> get components => [
        code,
        messageKey,
        context.length,
        for (final entry in context.entries) ...[entry.key, entry.value],
      ];
}

final class ValidationContext extends ValueObject {
  ValidationContext({
    required this.correlationId,
    Map<String, String> attributes = const {},
  }) : attributes = immutableCanonicalMap(attributes);

  final RuntimeIdentifier correlationId;
  final Map<String, String> attributes;

  @override
  List<Object?> get components => [
        correlationId,
        attributes.length,
        for (final entry in attributes.entries) ...[entry.key, entry.value],
      ];
}

final class ValidationResult extends ValueObject {
  ValidationResult({
    required this.isValid,
    Iterable<ValidationFailure> failures = const [],
  }) : failures = immutableList(failures);

  final bool isValid;
  final List<ValidationFailure> failures;

  @override
  List<Object?> get components => [isValid, failures.length, ...failures];
}

abstract interface class Validator<T> {
  ValidationResult validate(T value, ValidationContext context);
}

abstract interface class ValidationRule<T> {
  ValidationResult evaluate(T value, ValidationContext context);
}

abstract interface class CompositeValidator<T> implements Validator<T> {}
