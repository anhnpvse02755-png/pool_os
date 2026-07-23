import '../../shared/foundation/value_object.dart';

final class UtcTimestamp extends ValueObject
    implements Comparable<UtcTimestamp> {
  UtcTimestamp(DateTime value) : value = _validate(value);

  final DateTime value;

  int get microsecondsSinceEpoch => value.microsecondsSinceEpoch;

  @override
  List<Object?> get components => [microsecondsSinceEpoch];

  @override
  int compareTo(UtcTimestamp other) => value.compareTo(other.value);

  static DateTime _validate(DateTime value) {
    if (!value.isUtc) {
      throw ArgumentError.value(value, 'value', 'Must be UTC');
    }
    return value;
  }
}

final class NonNegativeDuration extends ValueObject
    implements Comparable<NonNegativeDuration> {
  NonNegativeDuration(this.value) {
    if (value.isNegative) {
      throw ArgumentError.value(value, 'value', 'Must not be negative');
    }
  }

  final Duration value;

  @override
  List<Object?> get components => [value.inMicroseconds];

  @override
  int compareTo(NonNegativeDuration other) => value.compareTo(other.value);
}
