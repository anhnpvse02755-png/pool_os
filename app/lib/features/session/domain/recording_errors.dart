/// RFC-301 Recording Pipeline errors.
///
/// The recording pipeline enforces the business invariant that every object
/// (Match → Rack → Shot → Event) has a valid, persisted parent. When that
/// invariant would be violated, the pipeline throws instead of writing an
/// orphan row or inventing a fake ID (e.g. rackId=0 / shotId=0). Callers
/// surface these as user-facing errors rather than silently corrupting data.
class RecordingIntegrityException implements Exception {
  final String message;

  const RecordingIntegrityException(this.message);

  @override
  String toString() => 'RecordingIntegrityException: $message';
}
