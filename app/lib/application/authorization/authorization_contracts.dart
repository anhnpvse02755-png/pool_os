import '../../shared/foundation/identifier.dart';
import '../../shared/foundation/immutable.dart';
import '../../shared/foundation/result.dart';
import '../../shared/foundation/value_object.dart';

enum AuthorizationDecision { authorized, denied, indeterminate }

final class AuthorizationRequirement extends ValueObject {
  const AuthorizationRequirement({required this.id});

  final RuntimeIdentifier id;

  @override
  List<Object?> get components => [id];
}

final class AuthorizationContext extends ValueObject {
  AuthorizationContext({
    required this.correlationId,
    required this.subjectReferenceId,
    Map<String, String> attributes = const {},
  }) : attributes = immutableCanonicalMap(attributes);

  final RuntimeIdentifier correlationId;
  final RuntimeIdentifier subjectReferenceId;
  final Map<String, String> attributes;

  @override
  List<Object?> get components => [
        correlationId,
        subjectReferenceId,
        attributes.length,
        for (final entry in attributes.entries) ...[entry.key, entry.value],
      ];
}

final class AuthorizationResult extends ValueObject {
  AuthorizationResult({
    required this.decision,
    Iterable<AuthorizationRequirement> requirements = const [],
  }) : requirements = immutableList(requirements);

  final AuthorizationDecision decision;
  final List<AuthorizationRequirement> requirements;

  @override
  List<Object?> get components =>
      [decision, requirements.length, ...requirements];
}

abstract interface class AuthorizationHandler<
    TRequirement extends AuthorizationRequirement> {
  Result<AuthorizationResult> evaluate(
    TRequirement requirement,
    AuthorizationContext context,
  );
}

abstract interface class AuthorizationService {
  Result<AuthorizationResult> evaluate(
    Iterable<AuthorizationRequirement> requirements,
    AuthorizationContext context,
  );
}
