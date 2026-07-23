import '../../shared/foundation/identifier.dart';
import '../../shared/foundation/immutable.dart';
import '../../shared/foundation/value_object.dart';

final class ApplicationRequestContext extends ValueObject {
  ApplicationRequestContext({
    required this.requestId,
    required this.correlationId,
    required this.requestedAtUtc,
    Map<String, String> metadata = const {},
  }) : metadata = immutableCanonicalMap(metadata);

  final RuntimeIdentifier requestId;
  final RuntimeIdentifier correlationId;
  final DateTime requestedAtUtc;
  final Map<String, String> metadata;

  @override
  List<Object?> get components => [
        requestId,
        correlationId,
        requestedAtUtc.microsecondsSinceEpoch,
        metadata.length,
        for (final entry in metadata.entries) ...[entry.key, entry.value],
      ];
}

/// Cancellation observation boundary only. No cancellation mechanism exists.
abstract interface class CancellationToken {
  bool get isCancellationRequested;
}

final class ApplicationExecutionContext {
  const ApplicationExecutionContext({
    required this.request,
    required this.cancellationToken,
  });

  final ApplicationRequestContext request;
  final CancellationToken cancellationToken;
}
