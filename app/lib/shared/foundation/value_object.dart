abstract class ValueObject {
  const ValueObject();

  List<Object?> get components;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType || other is! ValueObject) {
      return false;
    }
    final left = components;
    final right = other.components;
    if (left.length != right.length) {
      return false;
    }
    for (var index = 0; index < left.length; index++) {
      if (left[index] != right[index]) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(runtimeType, Object.hashAll(components));
}
