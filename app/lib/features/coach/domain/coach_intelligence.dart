import 'package:pool_os/features/session/domain/models/session.dart';
import 'package:pool_os/features/match/domain/models/match.dart';
import 'package:pool_os/features/rack/domain/models/rack.dart';
import 'package:pool_os/features/shot/domain/models/shot.dart';
import 'package:pool_os/features/drill/data/drill_library.dart';
import 'package:pool_os/features/drill/domain/models/drill.dart';

/// TASK 03 — Coach Intelligence v1.
///
/// A READ-SIDE analyzer that turns a single real session (its matches, racks,
/// shots and events) into a [DailyCoachReport] answering the four Coach
/// questions:
///   Q1 How did you play today?
///   Q2 Why? (cite the data)
///   Q3 What should you do? (<=3 recommendations)
///   Q4 Why that advice? (each rec carries reason + data + expected gain)
///
/// It touches NOTHING in the RFC-301 recording pipeline (LOCKED) — it only
/// consumes what the pipeline already persisted. It uses ONLY real, recorded
/// numbers: per-shot-type success rates, categorized miss reasons, the ordered
/// rack sequence with real timestamps, and session duration. It never invents
/// values (no hardcoded skill rates, no fabricated trends). When a signal has
/// too small a sample it is simply omitted rather than guessed.
class CoachIntelligence {
  /// Minimum shots of a given shot-type before we will name it as a weakness.
  static const int minShotSampleForWeakness = 5;

  /// Minimum racks before we attempt a within-session (warm-up / fade) trend.
  static const int minRacksForTrend = 4;

  /// A shot type is "weak" below this success rate...
  static const double weakSuccessThreshold = 0.55;

  /// Build the report for one session. All inputs are the REAL persisted rows
  /// for that session, already loaded by the caller (provider or test).
  ///
  /// [racksByMatch] maps each match id to its racks in play order.
  /// [shotsByRack] maps each rack id to its shots in play order.
  /// [missReasonCounts] is the categorized miss-reason tally for the session
  ///   (from Shot.missReason on missed shots + error Events), keyed by code.
  static DailyCoachReport analyzeSession({
    required Session session,
    required List<Match> matches,
    required Map<int, List<Rack>> racksByMatch,
    required Map<int, List<Shot>> shotsByRack,
    required Map<String, int> missReasonCounts,
    String locale = 'vi',
  }) {
    // ---- Flatten the session into ordered racks + shots (real timestamps) ----
    final orderedRacks = <Rack>[];
    for (final match in matches) {
      if (match.id == null) continue;
      final racks = racksByMatch[match.id!] ?? const [];
      orderedRacks.addAll(racks);
    }
    orderedRacks.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final allShots = <Shot>[];
    for (final rack in orderedRacks) {
      if (rack.id == null) continue;
      allShots.addAll(shotsByRack[rack.id!] ?? const []);
    }

    final totalShots = allShots.length;
    final madeShots = allShots.where((s) => s.result == ShotResult.made).length;
    final rackCount = orderedRacks.length;
    final rackWins = orderedRacks.where((r) => r.result).length;

    // Not enough recorded data to say anything honest.
    if (totalShots < minShotSampleForWeakness) {
      return DailyCoachReport.insufficient(
        sessionId: session.id,
        totalShots: totalShots,
        rackCount: rackCount,
        locale: locale,
      );
    }

    final accuracy = totalShots > 0 ? madeShots / totalShots : 0.0;

    // ---- Per-shot-type success (real: attempts + made) ----
    final byType = <String, _TypeTally>{};
    for (final shot in allShots) {
      final t = byType.putIfAbsent(shot.shotType, () => _TypeTally());
      t.attempts++;
      if (shot.result == ShotResult.made) t.made++;
    }

    // ---- Q2 signal A: worst shot type with a real sample ----
    _TypeWeakness? worstType;
    for (final entry in byType.entries) {
      final tally = entry.value;
      if (tally.attempts < minShotSampleForWeakness) continue;
      if (tally.successRate >= weakSuccessThreshold) continue;
      if (worstType == null || tally.successRate < worstType.successRate) {
        worstType = _TypeWeakness(
          shotType: entry.key,
          attempts: tally.attempts,
          made: tally.made,
          successRate: tally.successRate,
        );
      }
    }

    // ---- Q2 signal B: dominant miss reason (real categorized counts) ----
    // Denominator is the TRUE number of missed shots (totalShots - madeShots),
    // not just the categorized ones — otherwise a single tagged miss among many
    // untagged ones would read as "100% of misses", overstating the cause.
    String? topMissReason;
    int topMissCount = 0;
    missReasonCounts.forEach((reason, count) {
      if (count > topMissCount) {
        topMissCount = count;
        topMissReason = reason;
      }
    });
    // True miss count as the denominator so an untagged-heavy session can't make
    // one categorized reason read as "100% of misses".
    final totalMisses = totalShots - madeShots;

    // ---- Q1/Q2 signal C: within-session trend (warm-up vs fade) ----
    final trend = _computeTrend(orderedRacks, shotsByRack, session.startedAt);

    // ---- Build the four answers ----
    final q1 = _buildHeadline(
      locale: locale,
      accuracy: accuracy,
      rackCount: rackCount,
      rackWins: rackWins,
      trend: trend,
    );

    final q2 = _buildWhy(
      locale: locale,
      worstType: worstType,
      topMissReason: topMissReason,
      topMissCount: topMissCount,
      totalMisses: totalMisses,
      trend: trend,
    );

    final recs = _buildRecommendations(
      locale: locale,
      worstType: worstType,
      topMissReason: topMissReason,
      topMissCount: topMissCount,
      totalMisses: totalMisses,
      trend: trend,
      accuracy: accuracy,
    );

    return DailyCoachReport(
      sessionId: session.id,
      hasData: true,
      totalShots: totalShots,
      madeShots: madeShots,
      rackCount: rackCount,
      rackWins: rackWins,
      accuracy: accuracy,
      headline: q1,
      whyPoints: q2,
      recommendations: recs,
      trend: trend,
      locale: locale,
    );
  }

  // ------------------------------------------------------------------ trend --

  /// Split the ordered racks into first-half vs second-half by shot accuracy to
  /// detect warm-up (improving) or fatigue/fade (declining). Uses only real
  /// per-rack shot results + real elapsed minutes from Rack.createdAt.
  static SessionTrend _computeTrend(
    List<Rack> orderedRacks,
    Map<int, List<Shot>> shotsByRack,
    DateTime sessionStart,
  ) {
    final racksWithShots = orderedRacks
        .where((r) => r.id != null && (shotsByRack[r.id!]?.isNotEmpty ?? false))
        .toList();
    if (racksWithShots.length < minRacksForTrend) {
      return const SessionTrend(direction: TrendDirection.stable, hasData: false);
    }

    double rackAccuracy(Rack r) {
      final shots = shotsByRack[r.id!]!;
      final made = shots.where((s) => s.result == ShotResult.made).length;
      return shots.isEmpty ? 0.0 : made / shots.length;
    }

    final mid = racksWithShots.length ~/ 2;
    final firstHalf = racksWithShots.sublist(0, mid);
    final secondHalf = racksWithShots.sublist(mid);

    double avg(List<Rack> rs) =>
        rs.isEmpty ? 0.0 : rs.map(rackAccuracy).reduce((a, b) => a + b) / rs.length;

    final firstAcc = avg(firstHalf);
    final secondAcc = avg(secondHalf);
    final delta = secondAcc - firstAcc;

    // Elapsed minutes to the first rack of the declining/second half — the
    // "after N minutes" hook. Real timestamps; approximate (row-insert time).
    final pivotRack = secondHalf.first;
    final elapsedMinutes =
        pivotRack.createdAt.difference(sessionStart).inMinutes;

    TrendDirection dir;
    if (delta <= -0.12) {
      dir = TrendDirection.declining;
    } else if (delta >= 0.12) {
      dir = TrendDirection.improving;
    } else {
      dir = TrendDirection.stable;
    }

    return SessionTrend(
      direction: dir,
      hasData: true,
      firstHalfAccuracy: firstAcc,
      secondHalfAccuracy: secondAcc,
      pivotRackNumber: mid + 1,
      elapsedMinutesAtPivot: elapsedMinutes < 0 ? 0 : elapsedMinutes,
    );
  }

  // --------------------------------------------------------------- Q1 headline

  static String _buildHeadline({
    required String locale,
    required double accuracy,
    required int rackCount,
    required int rackWins,
    required SessionTrend trend,
  }) {
    final vi = locale == 'vi';
    final accPct = (accuracy * 100).round();

    if (trend.hasData && trend.direction == TrendDirection.declining) {
      return vi
          ? 'Phong độ giảm sau rack ${trend.pivotRackNumber}. Tỷ lệ vào bi tổng $accPct%.'
          : 'Form dropped after rack ${trend.pivotRackNumber}. Overall pot rate $accPct%.';
    }
    if (trend.hasData && trend.direction == TrendDirection.improving) {
      return vi
          ? 'Bạn vào form dần — nửa sau đánh tốt hơn. Tỷ lệ vào bi tổng $accPct%.'
          : 'You warmed up — the second half was stronger. Overall pot rate $accPct%.';
    }
    if (accPct >= 70) {
      return vi
          ? 'Buổi chơi tốt: giữ phong độ ổn định, tỷ lệ vào bi $accPct%.'
          : 'Good session: steady form, pot rate $accPct%.';
    }
    return vi
        ? 'Phong độ ổn định nhưng còn chỗ cải thiện. Tỷ lệ vào bi $accPct%.'
        : 'Steady form with room to improve. Pot rate $accPct%.';
  }

  // -------------------------------------------------------------------- Q2 why

  static List<String> _buildWhy({
    required String locale,
    required _TypeWeakness? worstType,
    required String? topMissReason,
    required int topMissCount,
    required int totalMisses,
    required SessionTrend trend,
  }) {
    final vi = locale == 'vi';
    final points = <String>[];

    if (worstType != null) {
      final pct = (worstType.successRate * 100).round();
      final name = _shotTypeName(worstType.shotType, locale);
      points.add(vi
          ? 'Cú $name chỉ vào $pct% (${worstType.made}/${worstType.attempts}) — loại cú yếu nhất trong nhóm đủ mẫu.'
          : '$name shots only landed $pct% (${worstType.made}/${worstType.attempts}) — weakest among shot types with enough attempts.');
    }

    if (topMissReason != null && totalMisses > 0) {
      final share = (topMissCount / totalMisses * 100).round();
      final reason = _missReasonName(topMissReason, locale);
      points.add(vi
          ? 'Lỗi chủ yếu do $reason ($share% số cú trượt).'
          : 'Most misses came from $reason ($share% of missed shots).');
    }

    if (trend.hasData && trend.direction == TrendDirection.declining) {
      final firstPct = (trend.firstHalfAccuracy * 100).round();
      final secondPct = (trend.secondHalfAccuracy * 100).round();
      points.add(vi
          ? 'Tỷ lệ vào bi tụt từ $firstPct% xuống $secondPct% sau khoảng ${trend.elapsedMinutesAtPivot} phút.'
          : 'Pot rate slid from $firstPct% to $secondPct% after ~${trend.elapsedMinutesAtPivot} min.');
    } else if (trend.hasData && trend.direction == TrendDirection.improving) {
      final firstPct = (trend.firstHalfAccuracy * 100).round();
      final secondPct = (trend.secondHalfAccuracy * 100).round();
      points.add(vi
          ? 'Tỷ lệ vào bi tăng từ $firstPct% lên $secondPct% khi đã nóng máy.'
          : 'Pot rate rose from $firstPct% to $secondPct% once you got going.');
    }

    return points;
  }

  // --------------------------------------------------------- Q3 + Q4 in one DTO

  static List<CoachAdvice> _buildRecommendations({
    required String locale,
    required _TypeWeakness? worstType,
    required String? topMissReason,
    required int topMissCount,
    required int totalMisses,
    required SessionTrend trend,
    required double accuracy,
  }) {
    final vi = locale == 'vi';
    final advice = <CoachAdvice>[];

    // Rec 1: the weakest shot type → a real drill in that category.
    if (worstType != null) {
      final pct = (worstType.successRate * 100).round();
      final name = _shotTypeName(worstType.shotType, locale);
      final category = _shotTypeToDrillCategory(worstType.shotType);
      final drill = _pickDrill(category);
      advice.add(CoachAdvice(
        title: vi ? 'Tập cú $name' : 'Drill $name shots',
        reason: vi
            ? 'Đây là loại cú yếu nhất buổi nay.'
            : 'This was your weakest shot type today.',
        data: vi
            ? 'Chỉ vào $pct% (${worstType.made}/${worstType.attempts} cú).'
            : 'Only $pct% success (${worstType.made}/${worstType.attempts} shots).',
        expected: vi
            ? 'Kéo loại cú này lên ~70% có thể tăng vài % tỷ lệ thắng.'
            : 'Getting this to ~70% can lift your win rate a few points.',
        drillCode: drill?.code,
        drillName: drill == null ? null : (vi ? drill.nameVi : drill.name),
      ));
    }

    // Rec 2: the dominant miss reason → control/technique work.
    if (topMissReason != null && totalMisses > 0 && advice.length < 3) {
      final share = (topMissCount / totalMisses * 100).round();
      final reason = _missReasonName(topMissReason, locale);
      final category = _missReasonToDrillCategory(topMissReason);
      final drill = _pickDrill(category);
      advice.add(CoachAdvice(
        title: vi ? 'Sửa lỗi $reason' : 'Fix $reason errors',
        reason: vi
            ? 'Đây là nguyên nhân trượt phổ biến nhất của bạn.'
            : 'This is your most common cause of misses.',
        data: vi
            ? '$share% số cú trượt đến từ $reason.'
            : '$share% of your misses came from $reason.',
        expected: vi
            ? 'Giảm nhóm lỗi này giúp ổn định tỷ lệ vào bi.'
            : 'Cutting this error group stabilizes your pot rate.',
        drillCode: drill?.code,
        drillName: drill == null ? null : (vi ? drill.nameVi : drill.name),
      ));
    }

    // Rec 3: endurance/warm-up advice from the real within-session trend.
    if (trend.hasData && advice.length < 3) {
      if (trend.direction == TrendDirection.declining) {
        advice.add(CoachAdvice(
          title: vi ? 'Nghỉ giữa các set' : 'Rest between sets',
          reason: vi
              ? 'Bạn xuống sức về cuối buổi.'
              : 'Your form faded late in the session.',
          data: vi
              ? 'Vào bi giảm ${((trend.firstHalfAccuracy - trend.secondHalfAccuracy) * 100).round()}% sau ~${trend.elapsedMinutesAtPivot} phút.'
              : 'Pot rate fell ${((trend.firstHalfAccuracy - trend.secondHalfAccuracy) * 100).round()}% after ~${trend.elapsedMinutesAtPivot} min.',
          expected: vi
              ? 'Nghỉ ngắn giữ tập trung, giảm tụt phong độ cuối buổi.'
              : 'Short breaks keep focus and reduce the late drop.',
        ));
      } else if (trend.direction == TrendDirection.improving) {
        advice.add(CoachAdvice(
          title: vi ? 'Khởi động trước trận' : 'Warm up before matches',
          reason: vi
              ? 'Bạn cần vài rack để vào form.'
              : 'You need a few racks to reach top form.',
          data: vi
              ? 'Nửa đầu ${(trend.firstHalfAccuracy * 100).round()}% so với nửa sau ${(trend.secondHalfAccuracy * 100).round()}%.'
              : 'First half ${(trend.firstHalfAccuracy * 100).round()}% vs second half ${(trend.secondHalfAccuracy * 100).round()}%.',
          expected: vi
              ? 'Khởi động 15 phút giúp vào trận chính đúng phong độ.'
              : '15 min of warm-up starts real matches at full form.',
          drillCode: _pickDrill(DrillCategory.warmup)?.code,
        ));
      }
    }

    return advice.take(3).toList();
  }

  // ------------------------------------------------------------------ mapping --

  static Drill? _pickDrill(String category) {
    final drills = DrillLibrary.getDrillsByCategory(category);
    return drills.isNotEmpty ? drills.first : null;
  }

  /// Map a recorded [ShotTypes] value to the closest [DrillCategory].
  static String _shotTypeToDrillCategory(String shotType) {
    switch (shotType) {
      case ShotTypes.breakShot:
        return DrillCategory.breakShot;
      case ShotTypes.safetyShot:
        return DrillCategory.safety;
      case ShotTypes.jumpShot:
        return DrillCategory.jump;
      case ShotTypes.bankShot:
        return DrillCategory.bank;
      case ShotTypes.masse:
        return DrillCategory.cueBallControl;
      case ShotTypes.openingShot:
        return DrillCategory.breakShot;
      case ShotTypes.normalShot:
      default:
        return DrillCategory.straightShot;
    }
  }

  /// Map a miss-reason code (Shot.missReason / MissReason enum) to a drill area.
  static String _missReasonToDrillCategory(String reason) {
    switch (reason) {
      case 'aim':
        return DrillCategory.straightShot;
      case 'speed':
        return DrillCategory.position;
      case 'position':
        return DrillCategory.position;
      case 'english':
        return DrillCategory.cueBallControl;
      case 'kick':
        return DrillCategory.kick;
      case 'rush':
      case 'nerves':
        return DrillCategory.mental;
      case 'bad_decision':
        return DrillCategory.patternPlay;
      default:
        return DrillCategory.straightShot;
    }
  }

  static String _shotTypeName(String shotType, String locale) {
    final vi = locale == 'vi';
    switch (shotType) {
      case ShotTypes.breakShot:
        return vi ? 'phá bàn' : 'break';
      case ShotTypes.openingShot:
        return vi ? 'mở bàn' : 'opening';
      case ShotTypes.safetyShot:
        return vi ? 'an toàn' : 'safety';
      case ShotTypes.jumpShot:
        return vi ? 'nhảy' : 'jump';
      case ShotTypes.bankShot:
        return vi ? 'gien' : 'bank';
      case ShotTypes.masse:
        return vi ? 'xoáy' : 'masse';
      case ShotTypes.normalShot:
      default:
        return vi ? 'đánh thẳng' : 'straight';
    }
  }

  static String _missReasonName(String reason, String locale) {
    final vi = locale == 'vi';
    switch (reason) {
      case 'aim':
        return vi ? 'ngắm sai' : 'aim';
      case 'speed':
        return vi ? 'lực' : 'speed/force';
      case 'position':
        return vi ? 'điều bi' : 'position';
      case 'english':
        return vi ? 'ép phê' : 'english';
      case 'kick':
        return vi ? 'đá bi' : 'kicking';
      case 'rush':
        return vi ? 'vội' : 'rushing';
      case 'nerves':
        return vi ? 'căng thẳng' : 'nerves';
      case 'bad_decision':
        return vi ? 'chọn cú sai' : 'shot choice';
      default:
        return reason;
    }
  }
}

// ---------------------------------------------------------------- value types

enum TrendDirection { improving, stable, declining }

class SessionTrend {
  final TrendDirection direction;
  final bool hasData;
  final double firstHalfAccuracy;
  final double secondHalfAccuracy;
  final int pivotRackNumber;
  final int elapsedMinutesAtPivot;

  const SessionTrend({
    required this.direction,
    required this.hasData,
    this.firstHalfAccuracy = 0.0,
    this.secondHalfAccuracy = 0.0,
    this.pivotRackNumber = 0,
    this.elapsedMinutesAtPivot = 0,
  });
}

/// One recommendation carrying Q3 (title/action) + Q4 (reason + data + expected
/// improvement), optionally linked to a real drill from the catalog.
class CoachAdvice {
  final String title;
  final String reason;
  final String data;
  final String expected;
  final String? drillCode;
  final String? drillName;

  const CoachAdvice({
    required this.title,
    required this.reason,
    required this.data,
    required this.expected,
    this.drillCode,
    this.drillName,
  });
}

class DailyCoachReport {
  final int? sessionId;
  final bool hasData;
  final int totalShots;
  final int madeShots;
  final int rackCount;
  final int rackWins;
  final double accuracy;

  /// Q1
  final String headline;

  /// Q2 — cited data points
  final List<String> whyPoints;

  /// Q3 + Q4
  final List<CoachAdvice> recommendations;

  final SessionTrend trend;
  final String locale;

  const DailyCoachReport({
    required this.sessionId,
    required this.hasData,
    required this.totalShots,
    required this.madeShots,
    required this.rackCount,
    required this.rackWins,
    required this.accuracy,
    required this.headline,
    required this.whyPoints,
    required this.recommendations,
    required this.trend,
    required this.locale,
  });

  factory DailyCoachReport.insufficient({
    required int? sessionId,
    required int totalShots,
    required int rackCount,
    required String locale,
  }) {
    final vi = locale == 'vi';
    return DailyCoachReport(
      sessionId: sessionId,
      hasData: false,
      totalShots: totalShots,
      madeShots: 0,
      rackCount: rackCount,
      rackWins: 0,
      accuracy: 0.0,
      headline: vi
          ? 'Chưa đủ dữ liệu để phân tích buổi chơi này.'
          : 'Not enough data to analyze this session yet.',
      whyPoints: [
        vi
            ? 'Cần ghi thêm cú đánh (tối thiểu ${CoachIntelligence.minShotSampleForWeakness}) để Coach nhận xét chính xác.'
            : 'Record more shots (at least ${CoachIntelligence.minShotSampleForWeakness}) so Coach can analyze accurately.',
      ],
      recommendations: const [],
      trend: const SessionTrend(direction: TrendDirection.stable, hasData: false),
      locale: locale,
    );
  }
}

class _TypeTally {
  int attempts = 0;
  int made = 0;
  double get successRate => attempts > 0 ? made / attempts : 0.0;
}

class _TypeWeakness {
  final String shotType;
  final int attempts;
  final int made;
  final double successRate;
  const _TypeWeakness({
    required this.shotType,
    required this.attempts,
    required this.made,
    required this.successRate,
  });
}
