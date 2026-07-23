import '../../shared/foundation/immutable.dart';
import 'runtime_ports.dart';

final class ImmutableRuntimeConfiguration implements RuntimeConfiguration {
  ImmutableRuntimeConfiguration(Map<String, String> values)
      : _values = immutableCanonicalMap(values) {
    for (final entry in _values.entries) {
      if (entry.key.trim().isEmpty || entry.value.trim().isEmpty) {
        throw ArgumentError('Configuration keys and values must not be empty');
      }
    }
  }

  final Map<String, String> _values;

  @override
  String? value(String key) => _values[key];

  @override
  Map<String, String> snapshot() => _values;
}
