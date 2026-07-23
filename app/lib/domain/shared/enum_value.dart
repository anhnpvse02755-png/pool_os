import '../../shared/foundation/value_object.dart';

final class EnumValue<T extends Enum> extends ValueObject {
  const EnumValue(this.value);

  final T value;

  String get name => value.name;

  @override
  List<Object?> get components => [value];
}
