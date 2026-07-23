import 'value_object.dart';

final class RuntimeIdentifier extends ValueObject
    implements Comparable<RuntimeIdentifier> {
  factory RuntimeIdentifier({
    required String namespace,
    required String value,
  }) {
    final normalizedNamespace = namespace.trim();
    final normalizedValue = value.trim();
    if (!_namespacePattern.hasMatch(normalizedNamespace)) {
      throw ArgumentError.value(namespace, 'namespace', 'Invalid namespace');
    }
    if (!_valuePattern.hasMatch(normalizedValue)) {
      throw ArgumentError.value(value, 'value', 'Invalid identifier value');
    }
    return RuntimeIdentifier._(normalizedNamespace, normalizedValue);
  }

  const RuntimeIdentifier._(this.namespace, this.value);

  static final RegExp _namespacePattern = RegExp(r'^[a-z][a-z0-9.-]{1,63}$');
  static final RegExp _valuePattern =
      RegExp(r'^[A-Za-z0-9][A-Za-z0-9._:-]{0,127}$');

  final String namespace;
  final String value;

  String get canonical => '$namespace:$value';

  @override
  List<Object?> get components => [namespace, value];

  @override
  int compareTo(RuntimeIdentifier other) =>
      canonical.compareTo(other.canonical);

  @override
  String toString() => canonical;
}
