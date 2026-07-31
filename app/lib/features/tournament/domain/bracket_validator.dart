// EPIC 04 — Bracket Validator abstraction.
//
// PO direction 2026-07-31 (second pass):
//   BracketValidator lives BETWEEN [BracketGenerator] and
//   [TournamentService]. The service composes the generator + the validator
//   and never inspects bracket math itself. Phase 1 ships a no-op validator
//   that always reports ok=true; Phase 2 will tighten the rules.
//
// Validation surface:
//   - duplicate seed (e.g. two participants seeded #1)
//   - bye validity (bye only on the byes that the layout expects)
//   - power-of-two invariant (after padding, fixture count == size/2^(round))
//   - champion path (final has a resolved winner; every parent slot has its
//     two children resolved before it can resolve)

import 'package:pool_os/features/tournament/domain/capabilities.dart';
import 'package:pool_os/features/tournament/domain/models/tournament_models.dart';

class BracketValidationIssue {
  final String code;
  final String message;
  /// Participant id this issue is anchored to, when applicable.
  final int? participantId;
  /// Bracket match id this issue is anchored to, when applicable.
  final int? matchId;

  const BracketValidationIssue({
    required this.code,
    required this.message,
    this.participantId,
    this.matchId,
  });
}

class BracketValidationReport {
  final List<BracketValidationIssue> issues;

  const BracketValidationReport(this.issues);

  bool get isClean => issues.isEmpty;
  bool get isValid => issues.isEmpty;

  /// Convenient pre-built "everything is fine" report.
  static const empty = BracketValidationReport([]);
}

abstract class BracketValidator {
  /// Identifier so the engine can pick a specific validator per format.
  TournamentType get type;

  /// Capability descriptor — PO 2026-07-31: placeholders return NotAvailable
  /// instead of throwing. Validator capability mirrors the format family.
  BracketValidatorCapability get capability;

  /// Validate a bracket layout (pre-persistence). Returns a report; the
  /// service checks [BracketValidationReport.isValid] before persisting.
  BracketValidationReport validate({
    required List<TournamentParticipant> participants,
    required List<TournamentMatch> bracket,
  });
}

/// Phase 1 — no-op validator. Always clean. Phase 2 will tighten the rules.
class PermissiveBracketValidator implements BracketValidator {
  const PermissiveBracketValidator();

  @override
  TournamentType get type => TournamentType.singleElimination;

  @override
  BracketValidatorCapability get capability => const BracketValidatorCapability(
        implemented: true,
        supported: true,
      );

  @override
  BracketValidationReport validate({
    required List<TournamentParticipant> participants,
    required List<TournamentMatch> bracket,
  }) {
    return BracketValidationReport.empty;
  }
}

/// Phase 2+ — placeholder strict validator. Capability says "planned" so
/// the UI can show a "validation coming soon" hint; the engine does not
/// invoke it (Phase 2 will).
class StrictBracketValidator implements BracketValidator {
  const StrictBracketValidator();

  @override
  TournamentType get type => TournamentType.singleElimination;

  @override
  BracketValidatorCapability get capability => const BracketValidatorCapability(
        implemented: false,
        supported: true,
      );

  @override
  BracketValidationReport validate({
    required List<TournamentParticipant> participants,
    required List<TournamentMatch> bracket,
  }) {
    // PO 2026-07-31: placeholders MUST NOT throw. Returning empty is safe
    // (no false-positives). Phase 2 replaces this with the strict checks.
    return BracketValidationReport.empty;
  }
}