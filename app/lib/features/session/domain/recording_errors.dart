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

/// FEATURE_008 — Match Recording Transaction Integrity failure literals.
///
/// The coordinator raises these failures when a Match creation cannot
/// safely allocate a per-Session match number or would violate the
/// "at most one open Match per Session" invariant. The string [value]
/// is the portable, cross-process stable code that must survive end-to-end
/// through `MatchRecordingService` and any `FailureResult`.
///
/// Precedence (per spec): lifecycle/input validation → unexpected database
/// failure → source-read failure → missing Session → invalid source state
/// → exactly one open Match → allocation conflict.
enum MatchRecordingFailureCode {
  sessionTargetNotFound('match-recording-session-target-not-found'),
  invalidSourceState('match-recording-invalid-source-state'),
  openMatchExists('match-recording-open-match-exists'),
  allocationConflict('match-recording-allocation-conflict'),
  databaseFailure('match-recording-database-failure'),
  sourceReadFailure('match-recording-source-read-failure');

  const MatchRecordingFailureCode(this.value);

  final String value;
}

/// Typed exception that carries one of the FEATURE_008 failure literals.
///
/// Mirrors `MatchLifecycleException` (`match_lifecycle_policy.dart`) so the
/// two transactional subsystems share the same exception-class shape and
/// the same portable `value` literal contract.
final class MatchRecordingException implements Exception {
  const MatchRecordingException(this.code, {this.cause});

  final MatchRecordingFailureCode code;
  final Object? cause;

  @override
  String toString() => cause == null ? code.value : '${code.value}: $cause';
}
