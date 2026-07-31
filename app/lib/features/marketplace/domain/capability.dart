// EPIC 08 — Marketplace Capability primitives.
//
// EPIC 04 standardized the Capability Pattern. Marketplace uses this local
// copy to stay decoupled from other features.

enum CapabilityStatus { implemented, notAvailable, planned }

class CapabilityReason {
  final String code;
  final String message;
  const CapabilityReason({required this.code, required this.message});
  @override String toString() => '[$code] $message';
}

class CapabilityResult<T> {
  final CapabilityStatus status;
  final T? value;
  final CapabilityReason? reason;
  const CapabilityResult._({required this.status, this.value, this.reason});
  const CapabilityResult.withValue(T value)
      : status = CapabilityStatus.implemented, value = value, reason = null;
  const CapabilityResult.notAvailable(CapabilityReason reason)
      : status = CapabilityStatus.notAvailable, value = null, reason = reason;
  const CapabilityResult.planned(CapabilityReason reason)
      : status = CapabilityStatus.planned, value = null, reason = reason;
  bool get isImplemented => status == CapabilityStatus.implemented;
  bool get isNotAvailable => status == CapabilityStatus.notAvailable;
  bool get isPlanned => status == CapabilityStatus.planned;
  T getOrThrow() {
    if (isImplemented) return value as T;
    throw StateError('Capability closed: $reason');
  }
}