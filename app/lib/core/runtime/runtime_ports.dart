import '../../shared/foundation/identifier.dart';

abstract interface class Clock {
  DateTime nowUtc();
}

abstract interface class UuidGenerator {
  String nextUuid();
}

extension UuidGeneratorIdentifiers on UuidGenerator {
  RuntimeIdentifier nextIdentifier(String namespace) =>
      RuntimeIdentifier(namespace: namespace, value: nextUuid());
}

enum RuntimeLogLevel { debug, info, warning, error }

final class RuntimeLogEntry {
  RuntimeLogEntry({
    required this.eventId,
    required this.level,
    required this.source,
    required this.code,
    Map<String, String> context = const {},
  }) : context = Map<String, String>.unmodifiable(
          Map<String, String>.fromEntries(
            context.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
          ),
        );

  final String eventId;
  final RuntimeLogLevel level;
  final String source;
  final String code;
  final Map<String, String> context;
}

abstract interface class RuntimeLogger {
  void record(RuntimeLogEntry entry);
}

abstract interface class RuntimeConfiguration {
  String? value(String key);

  Map<String, String> snapshot();
}
