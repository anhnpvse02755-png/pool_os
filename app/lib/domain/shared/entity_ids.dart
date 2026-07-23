import '../../shared/foundation/identifier.dart';
import '../../shared/foundation/value_object.dart';

abstract class EntityId extends ValueObject implements Comparable<EntityId> {
  EntityId._({required String namespace, required String value})
      : _identifier = RuntimeIdentifier(namespace: namespace, value: value);

  final RuntimeIdentifier _identifier;

  String get namespace => _identifier.namespace;
  String get value => _identifier.value;
  String get canonical => _identifier.canonical;

  @override
  List<Object?> get components => [_identifier];

  @override
  int compareTo(EntityId other) => canonical.compareTo(other.canonical);

  @override
  String toString() => canonical;
}

final class GenericEntityId extends EntityId {
  GenericEntityId(String value)
      : super._(namespace: 'entity.generic', value: value);
}

final class MatchId extends EntityId {
  MatchId(String value) : super._(namespace: 'entity.match', value: value);
}

final class PlayerId extends EntityId {
  PlayerId(String value) : super._(namespace: 'entity.player', value: value);
}

final class SessionId extends EntityId {
  SessionId(String value) : super._(namespace: 'entity.session', value: value);
}
