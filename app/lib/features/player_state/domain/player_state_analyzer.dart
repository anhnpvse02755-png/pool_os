import 'package:pool_os/features/rack/domain/models/rack.dart';

/// Player State System — computed indices (doc §3 "vào tay"/warm-up and §4
/// in-match endurance).
///
/// These are DERIVED on demand from the rack history that already exists; they
/// are never stored (doc §9 forbids fabricated/overwritten metrics). The class
/// is pure Dart (no Flutter, no DB) so it is unit-testable in isolation.
///
/// Guiding rules from the doc:
///  * §3: a player often plays badly in the first few racks then improves —
///    "you need ~N racks to warm up". This is LEARNED from history, not typed
///    in by the user.
///  * §7-9: never conclude "you play badly"; find the cause; and never emit a
///    conclusion without enough data — hence [minRacksForWarmUp] and the
///    `hasEnoughData` flags.
class PlayerStateAnalyzer {
  /// Below this many racks there is not enough signal to judge a warm-up curve.
  static const int minRacksForWarmUp = 4;

  const PlayerStateAnalyzer();

  /// Per-rack quality score in 0-100. Combines the objective rack fields that
  /// already exist: whether the rack was won, balls potted, largest run, and
  /// (subtracted) the various error counts, nudged by self-rated confidence.
  /// Higher = cleaner rack. Deterministic and bounded.
  double rackQuality(Rack r) {
    double score = 0;
    // Winning the rack is the strongest single signal.
    if (r.result) score += 40;
    // Offense: balls potted (cap contribution) + largest run.
    score += (r.ballsPotted * 3).clamp(0, 24).toDouble();
    score += (r.largestRun * 2).clamp(0, 16).toDouble();
    // A clean break helps; a scratch/foul break hurts.
    if (r.breakSuccess) score += 6;
    if (r.breakScratch) score -= 6;
    if (r.breakFoul) score -= 6;
    // Errors drag the score down (each weighted by how avoidable it is).
    final errors = r.easyMissCount * 4 +
        r.hardMissCount * 2 +
        r.scratchErrorCount * 3 +
        r.positionErrorCount * 2 +
        r.safetyErrorCount * 1 +
        r.kickErrorCount * 1 +
        r.jumpErrorCount * 1;
    score -= errors.toDouble();
    // Confidence (0-10) gently pulls toward its own level — small weight so it
    // never dominates the objective signal.
    if (r.confidence != null) {
      score += (r.confidence! - 5); // -5..+5
    }
    return score.clamp(0, 100).toDouble();
  }

  /// Analyze the warm-up curve of one match's racks (must be rackNumber-order,
  /// as returned by RackRepository.getRacksByMatchId). Returns an insight the
  /// UI/Coach can present. Never fabricates when data is thin.
  WarmUpInsight warmUpIndex(List<Rack> racksInOrder) {
    final racks = racksInOrder;
    if (racks.length < minRacksForWarmUp) {
      return WarmUpInsight.insufficient(racks.length);
    }

    final quality = racks.map(rackQuality).toList();

    // "Warm-up racks" = the leading prefix that is clearly below the player's
    // later baseline. Baseline = average quality of the back half (their
    // settled form). Count how many leading racks fall a margin below it.
    final backHalf = quality.sublist(quality.length ~/ 2);
    final baseline = _avg(backHalf);
    const margin = 12.0; // quality points below baseline = "not warmed up yet"

    int warmUpRacks = 0;
    for (final q in quality) {
      if (q < baseline - margin) {
        warmUpRacks++;
      } else {
        break; // warm-up ends at the first rack that reaches form
      }
    }

    final earlyAvg = _avg(quality.sublist(0, (quality.length / 2).ceil()));
    final lateAvg = baseline;
    // Positive slope = improves as the session goes on (classic slow starter).
    final slope = lateAvg - earlyAvg;

    return WarmUpInsight(
      hasEnoughData: true,
      rackCount: racks.length,
      warmUpRacks: warmUpRacks,
      earlyQuality: earlyAvg,
      settledQuality: lateAvg,
      improvementSlope: slope,
    );
  }

  /// Below this many racks there is not enough signal to judge endurance decay.
  static const int minRacksForEndurance = 6;

  /// Analyze in-match endurance (doc §4): does quality hold across the session
  /// or fall off after a point? Compares the front third to the back third and,
  /// if it declines, estimates the rack where the drop sets in. Never fabricates
  /// on thin data.
  EnduranceInsight enduranceProfile(List<Rack> racksInOrder) {
    final racks = racksInOrder;
    if (racks.length < minRacksForEndurance) {
      return EnduranceInsight.insufficient(racks.length);
    }

    final quality = racks.map(rackQuality).toList();
    final third = (quality.length / 3).floor().clamp(1, quality.length);
    final front = _avg(quality.sublist(0, third));
    final back = _avg(quality.sublist(quality.length - third));
    final drop = front - back; // positive = declined by end

    int? declineRack;
    if (drop > 10) {
      // Find the first rack after which the running average stays below the
      // front-third baseline by the margin — the onset of fatigue.
      const margin = 10.0;
      for (int i = third; i < quality.length; i++) {
        final windowAvg = _avg(quality.sublist(i));
        if (windowAvg < front - margin) {
          declineRack = racks[i].rackNumber;
          break;
        }
      }
    }

    return EnduranceInsight(
      hasEnoughData: true,
      rackCount: racks.length,
      frontQuality: front,
      backQuality: back,
      declineRack: declineRack,
    );
  }

  double _avg(List<double> xs) =>
      xs.isEmpty ? 0 : xs.reduce((a, b) => a + b) / xs.length;
}

/// Result of the endurance analysis (doc §4). [declines] is true only when a
/// real drop was detected on sufficient data — otherwise the UI shows a neutral
/// "steady" or "not enough data" message rather than inventing decay (doc §9).
class EnduranceInsight {
  final bool hasEnoughData;
  final int rackCount;
  final double frontQuality;
  final double backQuality;

  /// The rack number where form starts to drop, or null if it holds steady.
  final int? declineRack;

  const EnduranceInsight({
    required this.hasEnoughData,
    required this.rackCount,
    required this.frontQuality,
    required this.backQuality,
    this.declineRack,
  });

  factory EnduranceInsight.insufficient(int rackCount) => EnduranceInsight(
        hasEnoughData: false,
        rackCount: rackCount,
        frontQuality: 0,
        backQuality: 0,
        declineRack: null,
      );

  bool get declines => hasEnoughData && declineRack != null;
}

/// Result of the warm-up analysis (doc §3). When [hasEnoughData] is false the
/// UI must show "not enough data" rather than a fabricated number (doc §9).
class WarmUpInsight {
  final bool hasEnoughData;
  final int rackCount;

  /// Estimated number of leading racks the player needs to reach form.
  final int warmUpRacks;
  final double earlyQuality;
  final double settledQuality;

  /// settledQuality - earlyQuality. >0 means the player warms up into form;
  /// ~0 means they start at their level (fast starter).
  final double improvementSlope;

  const WarmUpInsight({
    required this.hasEnoughData,
    required this.rackCount,
    required this.warmUpRacks,
    required this.earlyQuality,
    required this.settledQuality,
    required this.improvementSlope,
  });

  factory WarmUpInsight.insufficient(int rackCount) => WarmUpInsight(
        hasEnoughData: false,
        rackCount: rackCount,
        warmUpRacks: 0,
        earlyQuality: 0,
        settledQuality: 0,
        improvementSlope: 0,
      );

  /// True when the player is a clear slow-starter worth advising to warm up.
  bool get isSlowStarter => hasEnoughData && warmUpRacks >= 2 && improvementSlope > 8;
}
