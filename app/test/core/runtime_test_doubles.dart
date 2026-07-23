import 'package:pool_os/core/runtime/runtime_ports.dart';

final class FixedClock implements Clock {
  const FixedClock(this.value);

  final DateTime value;

  @override
  DateTime nowUtc() => value.toUtc();
}

final class SequenceUuidGenerator implements UuidGenerator {
  SequenceUuidGenerator(Iterable<String> values)
      : _values = List<String>.of(values);

  final List<String> _values;
  var _index = 0;

  @override
  String nextUuid() {
    if (_index >= _values.length) {
      throw StateError('UUID sequence exhausted');
    }
    return _values[_index++];
  }
}

final class RecordingRuntimeLogger implements RuntimeLogger {
  final List<RuntimeLogEntry> entries = [];

  @override
  void record(RuntimeLogEntry entry) => entries.add(entry);
}
