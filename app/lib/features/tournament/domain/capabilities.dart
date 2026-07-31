// EPIC 04 — Capability primitives shared across formats and generators.
//
// PO direction 2026-07-31: placeholders must NOT throw exceptions. UI reads
// capability flags and disables the action gracefully (cleaner production
// behaviour). The same applies to bracket generators and validators — they
// return [NotAvailable] results instead of throwing.

/// Generic "not available" envelope. Carries a stable [code] for telemetry /
/// i18n and a [reason] for developer logs. No exception.
class NotAvailable {
  final String code;
  final String reason;
  const NotAvailable({required this.code, required this.reason});

  @override
  String toString() => 'NotAvailable($code: $reason)';
}

/// Sentinel for "this branch is not supported yet". Throwing it is forbidden;
/// the only legal use is returning it from a generator / validator method.
const notAvailableDoubleElimination = NotAvailable(
  code: 'tnmt.de_not_implemented',
  reason: 'Double Elimination is architecture-ready only. EPIC 09 — Advanced '
      'Tournament System.',
);

const notAvailableRoundRobin = NotAvailable(
  code: 'tnmt.rr_not_implemented',
  reason: 'Round Robin (Tournament mode) is architecture-ready only. '
      'EPIC 09 — Advanced Tournament System.',
);

const notAvailableSwiss = NotAvailable(
  code: 'tnmt.swiss_not_implemented',
  reason: 'Swiss pairing is architecture-ready only. EPIC 09 — Advanced '
      'Tournament System.',
);

const notAvailableApaHandicap = NotAvailable(
  code: 'tnmt.handicap_apa_not_implemented',
  reason: 'APA handicap is architecture-ready only. EPIC 09 — Advanced '
      'Tournament System.',
);

/// Capability descriptor for a format. PO 2026-07-31: UI reads this and
/// disables the action instead of catching an exception.
class TournamentFormatCapability {
  /// Whether the format's bracket-generation, advance, and champion-detection
  /// rules are actually implemented in this build.
  final bool implemented;

  /// Whether the format is on the Beta product roadmap at all. A format that
  /// is `supported=false` should never appear in the create-tournament flow.
  /// A format that is `supported=true, implemented=false` should be visible
  /// but disabled (with a "coming soon" hint) so users see the roadmap.
  final bool supported;

  const TournamentFormatCapability({
    required this.implemented,
    required this.supported,
  });

  /// Stable code used by telemetry + i18n keys.
  String get code {
    if (implemented) return 'ready';
    if (supported) return 'planned';
    return 'archived';
  }

  @override
  String toString() =>
      'TournamentFormatCapability($code, implemented=$implemented, '
      'supported=$supported)';
}

/// Capability descriptor for a bracket generator. Mirrors the format
/// capability — generators carry their own capability so the engine can
/// surface a generator-level message (e.g. "this generator is in research")
/// without dragging the format layer along.
class BracketGeneratorCapability {
  final bool implemented;
  final bool supported;
  const BracketGeneratorCapability({
    required this.implemented,
    required this.supported,
  });
  String get code {
    if (implemented) return 'ready';
    if (supported) return 'planned';
    return 'archived';
  }
}

/// Capability descriptor for validators. Phase 1 only has a no-op default
/// validator; Phase 2 may add a strict variant.
class BracketValidatorCapability {
  final bool implemented;
  final bool supported;
  const BracketValidatorCapability({
    required this.implemented,
    required this.supported,
  });
  String get code {
    if (implemented) return 'ready';
    if (supported) return 'planned';
    return 'archived';
  }
}