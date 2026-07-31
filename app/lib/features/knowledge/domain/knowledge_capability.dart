// EPIC 05 §5 — Capability pattern for disabled features.
//
// PO 2026-07-31 — the Recommendation capability is closed in Pool OS Beta
// per spec §5 Forbidden. The pattern follows EPIC 04's "Implemented /
// Capability / NotAvailable" standardization:
//
//   Implemented   → CapabilityResult.withValue(value)
//   NotAvailable  → CapabilityResult.notAvailable(reason)
//   Planned       → CapabilityResult.planned(reason)
//
// Callers must NEVER throw from capability-closed entries; they return
// [CapabilityResult.notAvailable] and UI surfaces a deterministic notice.
// The pattern is plain Dart — no exceptions, no Result.fromException.

/// Capability status — three values, no more, no less. Mirrors EPIC 04.
enum CapabilityStatus { implemented, notAvailable, planned }

/// Reason describing why the capability is not available. Stored as a
/// plain string so the UI can display it without unwrapping.
class CapabilityReason {
  final String code;
  final String message;

  const CapabilityReason({required this.code, required this.message});

  @override
  String toString() => '[$code] $message';
}

/// Discriminated union. Either the capability is implemented with a [value]
/// OR it is not-available / planned with a [reason]. Exactly one of the
/// two factories is used to construct.
class CapabilityResult<T> {
  final CapabilityStatus status;
  final T? value;
  final CapabilityReason? reason;

  const CapabilityResult._({
    required this.status,
    this.value,
    this.reason,
  });

  /// Implemented path.
  const CapabilityResult.withValue(T value)
      : status = CapabilityStatus.implemented,
        value = value,
        reason = null;

  /// Not-available path — capability is closed (Beta scope).
  const CapabilityResult.notAvailable(CapabilityReason reason)
      : status = CapabilityStatus.notAvailable,
        value = null,
        reason = reason;

  /// Planned path — capability is on the roadmap but not yet shipped.
  const CapabilityResult.planned(CapabilityReason reason)
      : status = CapabilityStatus.planned,
        value = null,
        reason = reason;

  bool get isImplemented => status == CapabilityStatus.implemented;
  bool get isNotAvailable => status == CapabilityStatus.notAvailable;
  bool get isPlanned => status == CapabilityStatus.planned;

  /// Caller-side helper: `T` when implemented, otherwise throws a
  /// [StateError] describing the capability closure. UI should NOT use
  /// this — it is for tests only and mirrors the EPIC 04 "fail loudly
  /// in tests" contract.
  T getOrThrow() {
    if (isImplemented) return value as T;
    throw StateError(
      'Capability closed: ${reason ?? const CapabilityReason(code: 'unknown', message: 'unknown')}',
    );
  }
}

/// Recommendation capability — the only closed capability in EPIC 05.
/// PO 2026-07-31 — Spec §5 forbids Recommendations in Beta. The reason
/// is fixed for the Beta lifetime.
class RecommendationCapability {
  static const CapabilityReason _closedReason = CapabilityReason(
    code: 'recommendation_closed_beta',
    message:
        'Recommendation capability is closed in Pool OS Beta. '
        'Spec §5 Forbidden list, PO 2026-07-31.',
  );

  /// Always returns `CapabilityStatus.notAvailable` in Beta. The constant
  /// exists so UI surfaces never branch on a missing flag.
  static const bool unavailable = true;

  /// Reason surfaced in the UI banner.
  static const CapabilityReason reason = _closedReason;
}