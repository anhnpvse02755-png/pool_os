import '../../shared/foundation/value_object.dart';

final class NonEmptyString extends ValueObject
    implements Comparable<NonEmptyString> {
  factory NonEmptyString(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      throw ArgumentError.value(value, 'value', 'Must not be empty');
    }
    if (normalized.contains('\u0000')) {
      throw ArgumentError.value(value, 'value', 'Must not contain null bytes');
    }
    return NonEmptyString._(normalized);
  }

  const NonEmptyString._(this.value);

  final String value;

  @override
  List<Object?> get components => [value];

  @override
  int compareTo(NonEmptyString other) => value.compareTo(other.value);

  @override
  String toString() => value;
}

final class PositiveInteger extends ValueObject
    implements Comparable<PositiveInteger> {
  PositiveInteger(this.value) {
    if (value <= 0) {
      throw ArgumentError.value(value, 'value', 'Must be greater than zero');
    }
  }

  final int value;

  @override
  List<Object?> get components => [value];

  @override
  int compareTo(PositiveInteger other) => value.compareTo(other.value);
}

final class VersionNumber extends ValueObject
    implements Comparable<VersionNumber> {
  VersionNumber(this.value) {
    if (value <= 0) {
      throw ArgumentError.value(value, 'value', 'Must be greater than zero');
    }
  }

  final int value;

  VersionNumber next() => VersionNumber(value + 1);

  @override
  List<Object?> get components => [value];

  @override
  int compareTo(VersionNumber other) => value.compareTo(other.value);
}

final class Percentage extends ValueObject implements Comparable<Percentage> {
  Percentage(this.value) {
    if (!value.isFinite || value < 0 || value > 100) {
      throw ArgumentError.value(value, 'value', 'Must be between 0 and 100');
    }
  }

  final double value;

  double get fraction => value / 100;

  @override
  List<Object?> get components => [value];

  @override
  int compareTo(Percentage other) => value.compareTo(other.value);
}

final class ScoreValue extends ValueObject implements Comparable<ScoreValue> {
  ScoreValue(this.value) {
    if (value < 0) {
      throw ArgumentError.value(value, 'value', 'Must not be negative');
    }
  }

  final int value;

  @override
  List<Object?> get components => [value];

  @override
  int compareTo(ScoreValue other) => value.compareTo(other.value);
}
