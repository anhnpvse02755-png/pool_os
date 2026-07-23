import 'dart:collection';

List<T> immutableList<T>(Iterable<T> values) => List<T>.unmodifiable(values);

Map<String, T> immutableCanonicalMap<T>(Map<String, T> values) {
  final ordered = SplayTreeMap<String, T>()..addAll(values);
  return Map<String, T>.unmodifiable(ordered);
}
