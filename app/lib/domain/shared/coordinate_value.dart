import '../../shared/foundation/value_object.dart';

final class CoordinateValue extends ValueObject {
  CoordinateValue({required this.x, required this.y}) {
    if (!x.isFinite || !y.isFinite) {
      throw ArgumentError('Coordinates must be finite');
    }
  }

  final double x;
  final double y;

  @override
  List<Object?> get components => [x, y];
}
