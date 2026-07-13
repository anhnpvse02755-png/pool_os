import 'package:pool_os/features/rack/domain/models/rack.dart';
import 'package:pool_os/features/shot/domain/models/shot.dart';
import 'package:pool_os/features/player_state/domain/player_state_analyzer.dart';

/// Task 08 — Player Endurance Intelligence.
///
/// Answers, from data the app ALREADY records (no new user input, no schema
/// change): how long a player holds form, when it starts to drop, whether the
/// drop is technical or physical, and which race length suits them now.
///
/// Design constraints from the Task 08 spec:
///  * NO fixed thresholds — the "good" level is LEARNED from each player's own
///    history (their personal peak and natural rack-to-rack variability), so a
///    beginner and a pro are each judged against themselves.
///  * NO fabricated data — every number traces back to real racks/shots. When
///    there is not enough history the result is [EnduranceProfile.insufficient]
///    and the UI must say "Chưa đủ dữ liệu để đánh giá".
///  * Reuses the LOCKED [PlayerStateAnalyzer.rackQuality] as the single source
///    of per-rack quality; this class never redefines quality.
///
/// Pure Dart (no Flutter, no DB) so it is unit-testable in isolation.
class EnduranceAnalyzer {
  /// Quality scorer is owned by Player State (Task 01/06); we reuse it so both
  /// features always agree on what a "good rack" is.
  final PlayerStateAnalyzer _quality;

  const EnduranceAnalyzer([this._quality = const PlayerStateAnalyzer()]);

  /// A single racks-in-order sequence from ONE match, paired with each rack's
  /// shots (used to attribute decline to technique vs physical/mental).
  ///
  /// Below this many racks a single match cannot show a decline curve.
  static const int minRacksPerMatch = 6;

  /// Across history we want at least this many analyzable matches before we
  /// claim to know a player's endurance pattern. One match is an anecdote.
  static const int minMatchesForProfile = 3;

  /// Build the player's endurance profile from their recent matches, newest
  /// first is fine — order within a match is what matters. Each entry is one
  /// match's racks (rackNumber-ordered) plus a lookup of shots by rackId.
  EnduranceProfile analyze(List<MatchRackData> matches) {
    // Keep only matches long enough to show a curve.
    final usable =
        matches.where((m) => m.racks.length >= minRacksPerMatch).toList();
    if (usable.length < minMatchesForProfile) {
      return EnduranceProfile.insufficient(
        analyzedMatches: usable.length,
        analyzedRacks: usable.fold(0, (s, m) => s + m.racks.length),
      );
    }

    // 1) The player's personal peak: the average of their best window across
    //    all matches. This is the "learned baseline" — no hardcoded number.
    final peaks = usable.map(_peakWindowQuality).toList();
    final personalPeak = _avg(peaks);

    // 2) Per-match decline onset (rack index, 1-based rackNumber) and the drop
    //    magnitude relative to that match's own early form.
    final onsets = <int>[];
    double totalDrop = 0;
    int declineMatches = 0;
    // Accumulators to attribute decline cause across all declining matches.
    int techErrorsLate = 0;
    int physMentalLate = 0;

    for (final m in usable) {
      final quality = m.racks.map(_quality.rackQuality).toList();
      final onset = _declineOnset(quality);
      if (onset != null) {
        onsets.add(m.racks[onset].rackNumber);
        final early = _avg(quality.sublist(0, onset));
        final late = _avg(quality.sublist(onset));
        totalDrop += (early - late);
        declineMatches++;
        // Attribute cause using the shots in the racks AT/AFTER the onset.
        final cause = _lateCause(m, onset);
        techErrorsLate += cause.technical;
        physMentalLate += cause.physicalMental;
      }
    }

    final declines = declineMatches > 0;
    final avgOnsetRack = onsets.isEmpty ? null : _avgInt(onsets);
    final avgDrop = declineMatches == 0 ? 0.0 : totalDrop / declineMatches;

    // 3) Endurance score 0-100: how well form is held. Full marks when no
    //    decline is ever seen; otherwise scaled by how early and how hard the
    //    drop is, relative to the player's own peak.
    final endurance = _enduranceScore(
      declineFraction: declineMatches / usable.length,
      avgDrop: avgDrop,
      personalPeak: personalPeak,
    );

    // 4) Cause: only claim a dominant cause when there is a clear majority; a
    //    near-tie stays "mixed" rather than guessing (spec: no suy đoán).
    final cause = _dominantCause(techErrorsLate, physMentalLate, declines);

    // 5) Recommended race length: derived from the average decline onset. If
    //    form holds past rack N, races up to N are safe. Null when steady
    //    (any race is fine) — never invents a number without a decline signal.
    final recommendedRace = _recommendRace(avgOnsetRack, declines);

    return EnduranceProfile(
      hasEnoughData: true,
      analyzedMatches: usable.length,
      analyzedRacks: usable.fold(0, (s, m) => s + m.racks.length),
      personalPeakQuality: personalPeak,
      enduranceScore: endurance,
      declines: declines,
      averageDeclineRack: avgOnsetRack,
      averageDrop: avgDrop,
      cause: cause,
      recommendedRaceTo: recommendedRace,
    );
  }

  /// Per-rack quality series (0-100) for one match's racks, in rackNumber
  /// order — the shape the UI plots as the performance curve. Pure passthrough
  /// of [PlayerStateAnalyzer.rackQuality]; no smoothing, no fabrication.
  List<double> qualitySeries(List<Rack> racksInOrder) =>
      racksInOrder.map(_quality.rackQuality).toList();

  /// The best contiguous third of a match — the player's demonstrated ceiling
  /// in that match. Averaged across matches this becomes their personal peak.
  double _peakWindowQuality(MatchRackData m) {
    final quality = m.racks.map(_quality.rackQuality).toList();
    final window = (quality.length / 3).ceil().clamp(1, quality.length);
    double best = 0;
    for (int i = 0; i + window <= quality.length; i++) {
      final avg = _avg(quality.sublist(i, i + window));
      if (avg > best) best = avg;
    }
    return best;
  }

  /// Find the rack index (0-based into the list) where form drops and STAYS
  /// down for the rest of the match, relative to this match's own early form.
  /// The margin is derived from the match's own variability (learned, not
  /// fixed) so a naturally streaky player is not mislabelled as fading.
  int? _declineOnset(List<double> quality) {
    if (quality.length < minRacksPerMatch) return null;
    final third = (quality.length / 3).floor().clamp(1, quality.length);
    final early = _avg(quality.sublist(0, third));
    // Learned margin: half a standard deviation of the whole match, floored so
    // a very steady match still needs a real gap to count as decline.
    final margin = (0.5 * _std(quality)).clamp(6.0, 25.0);

    for (int i = third; i < quality.length; i++) {
      final rest = _avg(quality.sublist(i));
      if (rest < early - margin) return i;
    }
    return null;
  }

  /// Look at the racks from [onset] onward and count error signals, splitting
  /// them into technical (aim/position/stroke execution) vs physical/mental
  /// (rushing, nerves, scratches from loss of control, self-rated fatigue via
  /// low confidence). Uses both rack error counts and shot miss reasons.
  _CauseTally _lateCause(MatchRackData m, int onset) {
    int technical = 0;
    int physicalMental = 0;
    for (int i = onset; i < m.racks.length; i++) {
      final r = m.racks[i];
      // Rack-level error columns.
      technical +=
          r.easyMissCount + r.hardMissCount + r.positionErrorCount;
      physicalMental += r.scratchErrorCount;
      // Shot-level miss reasons give the clearest technical/physical split.
      final shots = m.shotsByRackId[r.id] ?? const [];
      for (final s in shots) {
        final reason = s.missReason;
        if (reason == null) continue;
        if (_technicalReasons.contains(reason)) {
          technical++;
        } else if (_physicalMentalReasons.contains(reason)) {
          physicalMental++;
        }
      }
    }
    return _CauseTally(technical, physicalMental);
  }

  DeclineCause _dominantCause(int technical, int physicalMental, bool declines) {
    if (!declines) return DeclineCause.none;
    final total = technical + physicalMental;
    if (total == 0) return DeclineCause.unknown;
    final techShare = technical / total;
    // Require a clear majority (60%+) to name a cause; otherwise it is mixed.
    if (techShare >= 0.6) return DeclineCause.technical;
    if (techShare <= 0.4) return DeclineCause.physical;
    return DeclineCause.mixed;
  }

  double _enduranceScore({
    required double declineFraction,
    required double avgDrop,
    required double personalPeak,
  }) {
    if (declineFraction == 0) return 100;
    // Normalize the drop against the player's own peak so it is relative.
    final relDrop = personalPeak <= 0 ? 0.0 : (avgDrop / personalPeak);
    // Penalty grows with how often they fade and how deep the fade is.
    final penalty = (declineFraction * 40) + (relDrop.clamp(0, 1) * 60);
    return (100 - penalty).clamp(0, 100).toDouble();
  }

  /// Map average decline onset to a recommended race length. The player can
  /// comfortably race to about the rack where they still hold form (rounded to
  /// a common race value). Steady players get null (any race is fine).
  int? _recommendRace(int? avgOnsetRack, bool declines) {
    if (!declines || avgOnsetRack == null) return null;
    // They start fading AT this rack, so the safe target is just below it.
    final safe = avgOnsetRack - 1;
    const common = [3, 5, 7, 9, 11, 13, 15];
    int best = common.first;
    for (final c in common) {
      if (c <= safe) best = c;
    }
    return best;
  }

  // --- small stats helpers ---

  double _avg(List<double> xs) =>
      xs.isEmpty ? 0 : xs.reduce((a, b) => a + b) / xs.length;

  int _avgInt(List<int> xs) =>
      xs.isEmpty ? 0 : (xs.reduce((a, b) => a + b) / xs.length).round();

  double _std(List<double> xs) {
    if (xs.length < 2) return 0;
    final m = _avg(xs);
    final variance =
        xs.map((x) => (x - m) * (x - m)).reduce((a, b) => a + b) / xs.length;
    return _sqrt(variance);
  }

  double _sqrt(double v) {
    if (v <= 0) return 0;
    // Newton's method — avoids importing dart:math into a pure-domain file
    // that is otherwise dependency-free (matches the analyzer's minimalism).
    double x = v;
    for (int i = 0; i < 20; i++) {
      x = 0.5 * (x + v / x);
    }
    return x;
  }

  static const Set<String> _technicalReasons = {
    'aim',
    'position',
    'english',
    'bad_decision',
  };
  static const Set<String> _physicalMentalReasons = {
    'speed',
    'kick',
    'rush',
    'nerves',
  };
}

/// Input for one match: its racks in rackNumber order plus its shots keyed by
/// rackId (so the analyzer can attribute decline without another DB round-trip
/// inside the pure domain layer).
class MatchRackData {
  final List<Rack> racks;
  final Map<int, List<Shot>> shotsByRackId;

  const MatchRackData({required this.racks, this.shotsByRackId = const {}});
}

class _CauseTally {
  final int technical;
  final int physicalMental;
  const _CauseTally(this.technical, this.physicalMental);
}

/// Why form drops. [none] = it does not; [unknown] = it does but we have no
/// error signal to attribute it (still honest, never guessed).
enum DeclineCause { none, technical, physical, mixed, unknown }

/// The learned endurance profile. When [hasEnoughData] is false the UI shows
/// "Chưa đủ dữ liệu để đánh giá" and nothing else (Task 08: no suy đoán).
class EnduranceProfile {
  final bool hasEnoughData;
  final int analyzedMatches;
  final int analyzedRacks;

  /// The player's own learned ceiling (0-100), averaged best-window quality.
  final double personalPeakQuality;

  /// 0-100: how well form is maintained. 100 = never fades.
  final double enduranceScore;

  /// True when a real, repeated decline was detected.
  final bool declines;

  /// Average rack number at which form starts to drop, or null if steady.
  final int? averageDeclineRack;

  /// Average quality points lost after the decline onset (0-100 scale).
  final double averageDrop;

  final DeclineCause cause;

  /// Suggested race-to length given the decline onset, or null when steady.
  final int? recommendedRaceTo;

  const EnduranceProfile({
    required this.hasEnoughData,
    required this.analyzedMatches,
    required this.analyzedRacks,
    required this.personalPeakQuality,
    required this.enduranceScore,
    required this.declines,
    required this.averageDeclineRack,
    required this.averageDrop,
    required this.cause,
    required this.recommendedRaceTo,
  });

  factory EnduranceProfile.insufficient({
    required int analyzedMatches,
    required int analyzedRacks,
  }) =>
      EnduranceProfile(
        hasEnoughData: false,
        analyzedMatches: analyzedMatches,
        analyzedRacks: analyzedRacks,
        personalPeakQuality: 0,
        enduranceScore: 0,
        declines: false,
        averageDeclineRack: null,
        averageDrop: 0,
        cause: DeclineCause.none,
        recommendedRaceTo: null,
      );
}
