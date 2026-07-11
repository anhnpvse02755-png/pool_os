/// Player State System (Player State Model doc).
///
/// A [PlayerStateLog] is ONE self-reported state snapshot in the continuous
/// chain the doc describes: Readiness (baseline, owned by daily_readiness) →
/// pre-match → warm-up → in-match endurance → post-match fatigue. This log
/// row captures the self-reported points only (pre-match readiness §2 and
/// post-match/session fatigue §5). The computed warm-up (§3) and endurance
/// (§4) indices are derived on demand from rack history by
/// PlayerStateAnalyzer and are deliberately NOT stored here — the doc (§9)
/// forbids fabricated/overwritten data, so we never persist a guessed metric.
///
/// Each event appends a new row (history, never overwritten — doc §9).
class PlayerStateLog {
  final int? id;
  final int sessionId;
  final int? matchId;

  /// One of [PlayerStateKind].
  final String kind;

  // State §2 — pre-match self-report (0-10, null when not that kind of log).
  final int? readyToCompete;
  final int? warmedUp;
  final int? handFeel;

  // State §5 — post-match/session self-report (0-10).
  final int? fatigueLevel;

  final String? notes;
  final DateTime createdAt;

  PlayerStateLog({
    this.id,
    required this.sessionId,
    this.matchId,
    required this.kind,
    this.readyToCompete,
    this.warmedUp,
    this.handFeel,
    this.fatigueLevel,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  PlayerStateLog copyWith({
    int? id,
    int? sessionId,
    int? matchId,
    String? kind,
    int? readyToCompete,
    int? warmedUp,
    int? handFeel,
    int? fatigueLevel,
    String? notes,
    DateTime? createdAt,
  }) {
    return PlayerStateLog(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      matchId: matchId ?? this.matchId,
      kind: kind ?? this.kind,
      readyToCompete: readyToCompete ?? this.readyToCompete,
      warmedUp: warmedUp ?? this.warmedUp,
      handFeel: handFeel ?? this.handFeel,
      fatigueLevel: fatigueLevel ?? this.fatigueLevel,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Average of the three pre-match self-report axes present (0-10), or null
  /// if this is not a pre-match log / has no data. Distinct from Readiness:
  /// readiness is the start-of-day baseline; this is "ready to compete NOW".
  double? get preMatchScore {
    final values = [readyToCompete, warmedUp, handFeel].whereType<int>().toList();
    if (values.isEmpty) return null;
    return values.reduce((a, b) => a + b) / values.length;
  }
}

class PlayerStateKind {
  static const String preMatch = 'pre_match';
  static const String postMatch = 'post_match';
  static const String postSession = 'post_session';

  static const List<String> all = [preMatch, postMatch, postSession];
}

/// Post-match/session fatigue buckets (doc §5): Không mệt / Hơi mệt / Mệt /
/// Rất mệt. Stored as the 0-10 [PlayerStateLog.fatigueLevel] so it composes
/// with numeric analysis, but presented as these four choices.
class FatigueLevel {
  static const int none = 0; // Không mệt
  static const int light = 3; // Hơi mệt
  static const int tired = 6; // Mệt
  static const int exhausted = 9; // Rất mệt

  static const List<int> all = [none, light, tired, exhausted];
}
