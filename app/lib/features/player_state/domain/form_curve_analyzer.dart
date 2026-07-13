import 'dart:math' as math;
import 'package:pool_os/features/rack/domain/models/rack.dart';
import 'package:pool_os/features/shot/domain/models/shot.dart';
import 'package:pool_os/features/player_state/domain/player_state_analyzer.dart';

/// Task 07: Warm-up Intelligence & form-over-time.
///
/// A pure-Dart domain analyzer (no Flutter/DB imports; computed on demand,
/// nothing stored — doc §"AI KHÔNG PHÂN TÍCH NGAY"/real-data-only). It derives
/// Cold → Warm-up → Peak → Fatigue zones from REAL recorded racks/shots WITHOUT
/// hard-coded rack-number or accuracy thresholds: every boundary is expressed
/// as a multiple of the player's own noise (MAD) and their own percentile bands.
///
/// Per-rack "form" reuses the existing [PlayerStateAnalyzer.rackQuality] 0-100
/// signal (which already folds in win / largestRun / breakSuccess / errors) so
/// a soft rack of easy pots does not read as peak — blended with raw accuracy
/// for thin-rack robustness.
class FormCurveAnalyzer {
  const FormCurveAnalyzer();

  /// Below this many usable racks there is not enough signal to zone a curve.
  static const int minRacksForCurve = 6;

  /// Racks with fewer usable shots than this are dropped from zoning.
  static const int minShotsPerRack = 3;

  final PlayerStateAnalyzer _quality = const PlayerStateAnalyzer();

  /// Build the form curve for a single match. [racks] must be in play order.
  /// [shotsByRackId] provides the shots recorded for each rack. [matchStart] is
  /// used for the elapsed-minutes axis (falls back to each rack's createdAt).
  FormCurve buildCurve({
    required List<Rack> racks,
    required Map<int, List<Shot>> shotsByRackId,
    DateTime? matchStart,
  }) {
    final points = <RackPoint>[];
    var rackNo = 0;
    for (final rack in racks) {
      rackNo++;
      final shots = (rack.id == null ? null : shotsByRackId[rack.id!]) ?? const [];
      final usable = shots
          .where((s) =>
              s.result == ShotResult.made ||
              s.result == ShotResult.missed ||
              s.result == ShotResult.foul ||
              s.result == ShotResult.scratch)
          .toList();
      if (usable.length < minShotsPerRack) continue;

      final made = usable.where((s) => s.result == ShotResult.made).length;
      final rawAccuracy = made / usable.length;
      final wilson = _wilsonLower(made, usable.length);
      final qualityNorm = (_quality.rackQuality(rack) / 100).clamp(0.0, 1.0);
      // Blend: quality dominates (difficulty-aware), accuracy stabilizes thin racks.
      final formSignal = 0.6 * qualityNorm + 0.4 * wilson;

      final start = matchStart;
      final rackTime = _firstShotTime(usable) ?? rack.createdAt;
      final elapsedMin =
          start == null ? null : rackTime.difference(start).inSeconds / 60.0;

      points.add(RackPoint(
        rackNumber: rackNo,
        elapsedMinutes: elapsedMin,
        made: made,
        total: usable.length,
        rawAccuracy: rawAccuracy,
        formSignal: formSignal,
      ));
    }

    if (points.length < minRacksForCurve) {
      return FormCurve.insufficient(points.length);
    }

    final raw = points.map((p) => p.formSignal).toList();
    final smoothed = _zeroPhaseEwma(raw);
    final sigma = _madSigma(smoothed);

    // Personal bands from THIS session's smoothed distribution (self-calibrating,
    // no fixed cutoffs). A cross-match baseline can later replace these.
    final sorted = [...smoothed]..sort();
    final coldCeil = _percentile(sorted, 0.35);
    final peakFloor = _percentile(sorted, 0.75);

    // STEADY collapse: if the whole session barely moves relative to its own
    // noise, do not invent four zones (doc: honest, no fabrication).
    final span = smoothed.reduce(math.max) - smoothed.reduce(math.min);
    if (span < 1.5 * sigma) {
      return FormCurve(
        hasEnoughData: true,
        points: points,
        smoothed: smoothed,
        zones: [
          FormZone(
            kind: FormZoneKind.steady,
            startRack: points.first.rackNumber,
            endRack: points.last.rackNumber,
            startMinute: points.first.elapsedMinutes,
            endMinute: points.last.elapsedMinutes,
          ),
        ],
        peakRack: null,
        warmUpRacks: 0,
        fatigueOnsetRack: null,
      );
    }

    // Peak = argmax of the smoothed series.
    var peakIdx = 0;
    for (var i = 1; i < smoothed.length; i++) {
      if (smoothed[i] > smoothed[peakIdx]) peakIdx = i;
    }
    final peakLevel = smoothed[peakIdx];

    // Warm-up = leading run before the smoothed series first reaches peakFloor,
    // but only counts as warm-up if there is a real climb (> k*sigma).
    var warmUpEnd = 0;
    while (warmUpEnd < smoothed.length && smoothed[warmUpEnd] < peakFloor) {
      warmUpEnd++;
    }
    final climbed = (peakLevel - smoothed.first) > 1.0 * sigma;
    final warmUpRacks = climbed ? warmUpEnd.clamp(0, peakIdx) : 0;

    // Fatigue onset (CUSUM after the peak): accumulate sustained drops below
    // peak; fire only when the cumulative sum crosses a noise-scaled threshold.
    int? fatigueOnset;
    double cusum = 0;
    for (var i = peakIdx + 1; i < smoothed.length; i++) {
      cusum += math.max(0, peakLevel - smoothed[i] - 0.5 * sigma);
      if (cusum > 2.0 * sigma) {
        // Walk back to where the sustained decline began.
        var j = i;
        while (j > peakIdx && smoothed[j - 1] >= smoothed[j]) {
          j--;
        }
        fatigueOnset = j;
        break;
      }
    }

    final zones = _labelZones(points, warmUpRacks, peakIdx, fatigueOnset, coldCeil, smoothed);

    return FormCurve(
      hasEnoughData: true,
      points: points,
      smoothed: smoothed,
      zones: zones,
      peakRack: points[peakIdx].rackNumber,
      warmUpRacks: warmUpRacks,
      fatigueOnsetRack: fatigueOnset == null ? null : points[fatigueOnset].rackNumber,
    );
  }

  List<FormZone> _labelZones(
    List<RackPoint> points,
    int warmUpRacks,
    int peakIdx,
    int? fatigueOnset,
    double coldCeil,
    List<double> smoothed,
  ) {
    final zones = <FormZone>[];
    FormZone span(FormZoneKind kind, int startI, int endI) => FormZone(
          kind: kind,
          startRack: points[startI].rackNumber,
          endRack: points[endI].rackNumber,
          startMinute: points[startI].elapsedMinutes,
          endMinute: points[endI].elapsedMinutes,
        );

    var cursor = 0;
    if (warmUpRacks > 0) {
      // Cold = leading sub-run of warm-up below the player's own cold ceiling.
      var coldEnd = 0;
      while (coldEnd < warmUpRacks && smoothed[coldEnd] < coldCeil) {
        coldEnd++;
      }
      if (coldEnd > 0) {
        zones.add(span(FormZoneKind.cold, 0, coldEnd - 1));
        cursor = coldEnd;
      }
      if (warmUpRacks - 1 >= cursor) {
        zones.add(span(FormZoneKind.warmUp, cursor, warmUpRacks - 1));
      }
      cursor = warmUpRacks;
    }

    final peakEnd = fatigueOnset == null ? points.length - 1 : fatigueOnset - 1;
    if (peakEnd >= cursor) {
      zones.add(span(FormZoneKind.peak, cursor, peakEnd));
    }
    if (fatigueOnset != null && fatigueOnset <= points.length - 1) {
      zones.add(span(FormZoneKind.fatigue, fatigueOnset, points.length - 1));
    }
    return zones;
  }

  // ---- numeric helpers ----

  DateTime? _firstShotTime(List<Shot> shots) {
    DateTime? earliest;
    for (final s in shots) {
      if (earliest == null || s.createdAt.isBefore(earliest)) earliest = s.createdAt;
    }
    return earliest;
  }

  /// Wilson score lower bound (z=1.96) — pulls thin racks toward uncertainty.
  double _wilsonLower(int made, int n) {
    if (n == 0) return 0;
    const z = 1.96;
    final p = made / n;
    final denom = 1 + z * z / n;
    final centre = p + z * z / (2 * n);
    final margin = z * math.sqrt((p * (1 - p) + z * z / (4 * n)) / n);
    return ((centre - margin) / denom).clamp(0.0, 1.0);
  }

  /// Zero-phase EWMA: forward + backward pass averaged, so peak/onset positions
  /// are not shifted by smoothing lag. Span scales with series length (not a
  /// metric threshold).
  List<double> _zeroPhaseEwma(List<double> xs) {
    final n = xs.length;
    final span = (n / 4).clamp(2, 8).toDouble();
    final alpha = 2 / (span + 1);
    final fwd = List<double>.filled(n, 0);
    fwd[0] = xs[0];
    for (var i = 1; i < n; i++) {
      fwd[i] = alpha * xs[i] + (1 - alpha) * fwd[i - 1];
    }
    final bwd = List<double>.filled(n, 0);
    bwd[n - 1] = fwd[n - 1];
    for (var i = n - 2; i >= 0; i--) {
      bwd[i] = alpha * fwd[i] + (1 - alpha) * bwd[i + 1];
    }
    return bwd;
  }

  /// Robust noise estimate from lag-1 differences (MAD), with a small floor so a
  /// flat series does not yield zero.
  double _madSigma(List<double> xs) {
    if (xs.length < 2) return 0.05;
    final diffs = <double>[];
    for (var i = 1; i < xs.length; i++) {
      diffs.add((xs[i] - xs[i - 1]).abs());
    }
    diffs.sort();
    final median = diffs[diffs.length ~/ 2];
    return math.max(0.03, 1.4826 * median / math.sqrt2);
  }

  double _percentile(List<double> sorted, double q) {
    if (sorted.isEmpty) return 0;
    final idx = (q * (sorted.length - 1)).round().clamp(0, sorted.length - 1);
    return sorted[idx];
  }
}

enum FormZoneKind { cold, warmUp, peak, fatigue, steady }

/// One labelled segment of the session, reported in both rack index and
/// elapsed minutes.
class FormZone {
  final FormZoneKind kind;
  final int startRack;
  final int endRack;
  final double? startMinute;
  final double? endMinute;

  const FormZone({
    required this.kind,
    required this.startRack,
    required this.endRack,
    this.startMinute,
    this.endMinute,
  });
}

/// One rack's data point on the curve.
class RackPoint {
  final int rackNumber;
  final double? elapsedMinutes;
  final int made;
  final int total;
  final double rawAccuracy;
  final double formSignal;

  const RackPoint({
    required this.rackNumber,
    required this.elapsedMinutes,
    required this.made,
    required this.total,
    required this.rawAccuracy,
    required this.formSignal,
  });
}

/// Result of the per-match form analysis. When [hasEnoughData] is false the UI
/// must show "not enough data" rather than fabricated zones.
class FormCurve {
  final bool hasEnoughData;
  final List<RackPoint> points;
  final List<double> smoothed;
  final List<FormZone> zones;
  final int? peakRack;
  final int warmUpRacks;
  final int? fatigueOnsetRack;

  const FormCurve({
    required this.hasEnoughData,
    required this.points,
    required this.smoothed,
    required this.zones,
    required this.peakRack,
    required this.warmUpRacks,
    required this.fatigueOnsetRack,
  });

  factory FormCurve.insufficient(int rackCount) => FormCurve(
        hasEnoughData: false,
        points: const [],
        smoothed: const [],
        zones: const [],
        peakRack: null,
        warmUpRacks: 0,
        fatigueOnsetRack: null,
      );

  bool get isSlowStarter => hasEnoughData && warmUpRacks >= 2;
  bool get fatigues => hasEnoughData && fatigueOnsetRack != null;
}
