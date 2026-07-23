import '../../shared/foundation/identifier.dart';
import '../../shared/foundation/immutable.dart';
import '../../shared/foundation/value_object.dart';

enum MappingDirection { forward, reverse }

final class MappingContext extends ValueObject {
  MappingContext({
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

final class MappingMetadata extends ValueObject {
  const MappingMetadata({
    required this.mappingId,
    required this.direction,
  });

  final RuntimeIdentifier mappingId;
  final MappingDirection direction;

  @override
  List<Object?> get components => [mappingId, direction];
}

final class MappingFailure extends ValueObject {
  MappingFailure({
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

final class MappingResult<T extends ValueObject> extends ValueObject {
  MappingResult({
    required this.metadata,
    this.value,
    Iterable<MappingFailure> failures = const [],
  }) : failures = immutableList(failures);

  final MappingMetadata metadata;
  final T? value;
  final List<MappingFailure> failures;

  @override
  List<Object?> get components =>
      [metadata, value, failures.length, ...failures];
}

abstract interface class Mapper<TSource, TDestination extends ValueObject> {
  MappingResult<TDestination> map(TSource source, MappingContext context);
}

abstract interface class BidirectionalMapper<TLeft extends ValueObject,
    TRight extends ValueObject> {
  MappingResult<TRight> mapRight(TLeft source, MappingContext context);

  MappingResult<TLeft> mapLeft(TRight source, MappingContext context);
}
