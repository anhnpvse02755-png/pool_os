import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/session/data/repositories/session_repository.dart';
import 'package:pool_os/features/session/domain/models/session.dart';
import 'package:pool_os/features/match/data/repositories/match_repository.dart';
import 'package:pool_os/features/match/domain/models/match.dart';
import 'package:pool_os/features/rack/data/repositories/rack_repository.dart';
import 'package:pool_os/features/shot/data/repositories/shot_repository.dart';
import 'package:pool_os/features/daily_readiness/data/repositories/daily_readiness_repository.dart';
import 'package:pool_os/features/daily_readiness/domain/models/daily_readiness.dart';
import 'package:pool_os/features/equipment/data/repositories/equipment_repository.dart';
import 'package:pool_os/features/equipment/domain/models/cue.dart';
import 'package:pool_os/features/skill/data/skill_repository.dart';
import 'package:pool_os/features/skill/domain/models/skill.dart';
import 'package:pool_os/features/statistics/data/repositories/statistics_repository.dart';
import 'package:pool_os/features/statistics/domain/statistics_engine.dart';

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier(
    sessionRepo: ref.watch(sessionRepositoryProvider),
    matchRepo: ref.watch(matchRepositoryProvider),
    rackRepo: ref.watch(rackRepositoryProvider),
    shotRepo: ref.watch(shotRepositoryProvider),
    readinessRepo: ref.watch(dailyReadinessRepositoryProvider),
    equipmentRepo: ref.watch(equipmentRepositoryProvider),
    skillRepo: ref.watch(skillRepositoryProvider),
    statsRepo: ref.watch(statisticsRepositoryProvider),
  );
});

class DashboardState {
  final DailyReadinessModel? todayReadiness;
  final int todaySessionCount;
  final int todayMatchCount;
  final int todayRackCount;
  final int todayWinCount;
  final int todayShotCount;
  final int todayMadeCount;
  final Duration todayPlayTime;
  final int currentStreak; // consecutive practice days
  final Duration weeklyPlayTime; // total hours this week
  final List<Match> lastMatches; // last 10 matches
  final String? todayFocus; // derived from readiness/coach
  final Cue? activeCue;
  final Cue? activeBreakCue;
  final Cue? activeJumpCue;
  final List<PlayerSkill> topSkills;
  final List<RecentSession> recentSessions;
  final Session? activeSession;
  final int weeklySessionCount;
  final int weeklyRackCount;
  final double weeklyWinRate;
  final int monthlySessionCount;
  final int monthlyRackCount;
  final double monthlyWinRate;
  final CoachInsight? coachInsight;
  final bool isLoading;
  final String? error;

  const DashboardState({
    this.todayReadiness,
    this.todaySessionCount = 0,
    this.todayMatchCount = 0,
    this.todayRackCount = 0,
    this.todayWinCount = 0,
    this.todayShotCount = 0,
    this.todayMadeCount = 0,
    this.todayPlayTime = Duration.zero,
    this.currentStreak = 0,
    this.weeklyPlayTime = Duration.zero,
    this.lastMatches = const [],
    this.todayFocus,
    this.activeCue,
    this.activeBreakCue,
    this.activeJumpCue,
    this.topSkills = const [],
    this.recentSessions = const [],
    this.activeSession,
    this.weeklySessionCount = 0,
    this.weeklyRackCount = 0,
    this.weeklyWinRate = 0.0,
    this.monthlySessionCount = 0,
    this.monthlyRackCount = 0,
    this.monthlyWinRate = 0.0,
    this.coachInsight,
    this.isLoading = false,
    this.error,
  });

  DashboardState copyWith({
    DailyReadinessModel? todayReadiness,
    int? todaySessionCount,
    int? todayMatchCount,
    int? todayRackCount,
    int? todayWinCount,
    int? todayShotCount,
    int? todayMadeCount,
    Duration? todayPlayTime,
    int? currentStreak,
    Duration? weeklyPlayTime,
    List<Match>? lastMatches,
    String? todayFocus,
    Cue? activeCue,
    Cue? activeBreakCue,
    Cue? activeJumpCue,
    List<PlayerSkill>? topSkills,
    List<RecentSession>? recentSessions,
    Session? activeSession,
    int? weeklySessionCount,
    int? weeklyRackCount,
    double? weeklyWinRate,
    int? monthlySessionCount,
    int? monthlyRackCount,
    double? monthlyWinRate,
    CoachInsight? coachInsight,
    bool? isLoading,
    String? error,
    bool clearActiveSession = false,
    bool clearTodayFocus = false,
    bool clearActiveCue = false,
    bool clearActiveBreakCue = false,
    bool clearActiveJumpCue = false,
  }) {
    return DashboardState(
      todayReadiness: todayReadiness ?? this.todayReadiness,
      todaySessionCount: todaySessionCount ?? this.todaySessionCount,
      todayMatchCount: todayMatchCount ?? this.todayMatchCount,
      todayRackCount: todayRackCount ?? this.todayRackCount,
      todayWinCount: todayWinCount ?? this.todayWinCount,
      todayShotCount: todayShotCount ?? this.todayShotCount,
      todayMadeCount: todayMadeCount ?? this.todayMadeCount,
      todayPlayTime: todayPlayTime ?? this.todayPlayTime,
      currentStreak: currentStreak ?? this.currentStreak,
      weeklyPlayTime: weeklyPlayTime ?? this.weeklyPlayTime,
      lastMatches: lastMatches ?? this.lastMatches,
      todayFocus: clearTodayFocus ? null : (todayFocus ?? this.todayFocus),
      activeCue: clearActiveCue ? null : (activeCue ?? this.activeCue),
      activeBreakCue:
          clearActiveBreakCue ? null : (activeBreakCue ?? this.activeBreakCue),
      activeJumpCue:
          clearActiveJumpCue ? null : (activeJumpCue ?? this.activeJumpCue),
      topSkills: topSkills ?? this.topSkills,
      recentSessions: recentSessions ?? this.recentSessions,
      activeSession:
          clearActiveSession ? null : (activeSession ?? this.activeSession),
      weeklySessionCount: weeklySessionCount ?? this.weeklySessionCount,
      weeklyRackCount: weeklyRackCount ?? this.weeklyRackCount,
      weeklyWinRate: weeklyWinRate ?? this.weeklyWinRate,
      monthlySessionCount: monthlySessionCount ?? this.monthlySessionCount,
      monthlyRackCount: monthlyRackCount ?? this.monthlyRackCount,
      monthlyWinRate: monthlyWinRate ?? this.monthlyWinRate,
      coachInsight: coachInsight ?? this.coachInsight,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  double get todayAccuracy =>
      todayShotCount == 0 ? 0.0 : todayMadeCount / todayShotCount;
  double get todayWinRate =>
      todayRackCount == 0 ? 0.0 : todayWinCount / todayRackCount;
}

class RecentSession {
  final int id;
  final String type;
  final DateTime date;
  final int rackCount;
  final int winCount;
  final double accuracy;
  final Duration duration;

  const RecentSession({
    required this.id,
    required this.type,
    required this.date,
    required this.rackCount,
    required this.winCount,
    required this.accuracy,
    required this.duration,
  });

  double get winRate => rackCount == 0 ? 0.0 : winCount / rackCount;
}

class CoachInsight {
  final String title;
  final String message;
  final String type;
  final List<String> recommendations;

  const CoachInsight({
    required this.title,
    required this.message,
    required this.type,
    this.recommendations = const [],
  });
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final SessionRepository _sessionRepo;
  final MatchRepository _matchRepo;
  final RackRepository _rackRepo;
  final ShotRepository _shotRepo;
  final DailyReadinessRepository _readinessRepo;
  final EquipmentRepository _equipmentRepo;
  final SkillRepository _skillRepo;
  final StatisticsRepository _statsRepo;

  DashboardNotifier({
    required SessionRepository sessionRepo,
    required MatchRepository matchRepo,
    required RackRepository rackRepo,
    required ShotRepository shotRepo,
    required DailyReadinessRepository readinessRepo,
    required EquipmentRepository equipmentRepo,
    required SkillRepository skillRepo,
    required StatisticsRepository statsRepo,
  })  : _sessionRepo = sessionRepo,
        _matchRepo = matchRepo,
        _rackRepo = rackRepo,
        _shotRepo = shotRepo,
        _readinessRepo = readinessRepo,
        _equipmentRepo = equipmentRepo,
        _skillRepo = skillRepo,
        _statsRepo = statsRepo,
        super(const DashboardState()) {
    loadDashboard();
  }

  String _getTodayDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await Future.wait([
        _loadTodayStats(),
        _loadEquipment(),
        _loadRecentSessions(),
        _loadTrends(),
        _loadStreakAndHours(),
        _loadLastMatches(),
      ]);
      // These depend on readiness and today's statistics loaded above.
      await _loadCoachInsight();
      await _loadTodayFocus();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> _loadStreakAndHours() async {
    final sessions = await _sessionRepo.getAllSessions();

    // Calculate current streak (consecutive practice days)
    int streak = 0;
    if (sessions.isNotEmpty) {
      final sortedSessions = sessions.toList()
        ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

      DateTime? lastDate;
      for (final session in sortedSessions) {
        final sessionDate = DateTime(
          session.startedAt.year,
          session.startedAt.month,
          session.startedAt.day,
        );

        if (lastDate == null) {
          // First session - check if it's today or yesterday
          final today = DateTime.now();
          final todayDate = DateTime(today.year, today.month, today.day);
          final yesterday = todayDate.subtract(const Duration(days: 1));

          if (sessionDate == todayDate || sessionDate == yesterday) {
            streak = 1;
            lastDate = sessionDate;
          } else {
            break;
          }
        } else {
          final expectedDate = lastDate.subtract(const Duration(days: 1));
          if (sessionDate == expectedDate) {
            streak++;
            lastDate = sessionDate;
          } else if (sessionDate == lastDate) {
            // Same day, continue checking
          } else {
            break;
          }
        }
      }
    }

    // Calculate weekly play time
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDate =
        DateTime(weekStart.year, weekStart.month, weekStart.day);

    Duration weeklyPlayTime = Duration.zero;
    for (final session in sessions) {
      if (session.startedAt.isAfter(weekStartDate)) {
        weeklyPlayTime += session.duration;
      }
    }

    state = state.copyWith(
      currentStreak: streak,
      weeklyPlayTime: weeklyPlayTime,
    );
  }

  Future<void> _loadLastMatches() async {
    final matches = await _matchRepo.getAllMatches();
    matches.sort((a, b) => (b.startTime ?? DateTime(2000))
        .compareTo(a.startTime ?? DateTime(2000)));

    state = state.copyWith(lastMatches: matches.take(10).toList());
  }

  Future<void> _loadTodayFocus() async {
    String? focus;

    // Derive from readiness
    if (state.todayReadiness != null) {
      final readiness = state.todayReadiness!;

      if (readiness.recoveryScore < 4) {
        focus = 'Nghỉ ngơi - ưu tiên hồi phục';
      } else if (readiness.energyLevel != null && readiness.energyLevel! >= 8) {
        focus = 'Năng lượng cao - hãy phá kỷ lục!';
      } else if (readiness.energyLevel != null && readiness.energyLevel! < 5) {
        focus = 'Tập nhẹ - tập trung cơ bản';
      } else if (readiness.stressLevel != null && readiness.stressLevel! > 7) {
        focus = 'Kiểm soát stress - thử bài tập thở';
      } else if (readiness.coachNote.isNotEmpty) {
        focus = readiness.coachNote;
      }
    }

    // If no readiness data, check coach insight
    if (focus == null && state.coachInsight != null) {
      focus = state.coachInsight!.recommendations.isNotEmpty
          ? state.coachInsight!.recommendations.first
          : null;
    }

    state = state.copyWith(
      todayFocus: focus,
      clearTodayFocus: focus == null,
    );
  }

  Future<void> _loadTodayStats() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final readiness = await _readinessRepo.getByDate(_getTodayDate());
    final sessions =
        await _sessionRepo.getSessionsByDateRange(startOfDay, endOfDay);
    final activeSession = await _sessionRepo.getActiveSession();
    final skills = await _skillRepo.getAllSkills();

    int matchCount = 0;
    int rackCount = 0;
    int winCount = 0;
    int shotCount = 0;
    int madeCount = 0;
    Duration totalPlayTime = Duration.zero;

    for (final session in sessions) {
      final matches = await _matchRepo.getMatchesBySessionId(session.id!);
      matchCount += matches.length;

      for (final match in matches) {
        final racks = await _rackRepo.getRacksByMatchId(match.id!);
        rackCount += racks.length;
        winCount += racks.where((r) => r.result).length;

        for (final rack in racks) {
          final shots = await _shotRepo.getShotsByRackId(rack.id!);
          shotCount += shots.length;
          madeCount += shots.where((s) => s.isMade).length;
        }
      }

      totalPlayTime += session.duration;
    }

    // Sort skills by score for top skills display
    skills.sort((a, b) => b.score.compareTo(a.score));

    state = state.copyWith(
      todayReadiness: readiness,
      todaySessionCount: sessions.length,
      todayMatchCount: matchCount,
      todayRackCount: rackCount,
      todayWinCount: winCount,
      todayShotCount: shotCount,
      todayMadeCount: madeCount,
      todayPlayTime: totalPlayTime,
      activeSession: activeSession,
      clearActiveSession: activeSession == null,
      topSkills: skills,
    );
  }

  Future<void> _loadEquipment() async {
    // RFC-302 Task F: resolve by role. The legacy getActiveCue(isBreakCue:)
    // path relied on an isBreakCue flag that is never set, so the break row was
    // always empty and the playing row picked an arbitrary active cue.
    final activeCue = await _equipmentRepo.getActiveCueByType('playing');
    final activeBreakCue = await _equipmentRepo.getActiveCueByType('break');
    final activeJumpCue = await _equipmentRepo.getActiveCueByType('jump');

    state = state.copyWith(
      activeCue: activeCue,
      activeBreakCue: activeBreakCue,
      activeJumpCue: activeJumpCue,
      clearActiveCue: activeCue == null,
      clearActiveBreakCue: activeBreakCue == null,
      clearActiveJumpCue: activeJumpCue == null,
    );
  }

  Future<void> _loadRecentSessions() async {
    final sessions = await _sessionRepo.getAllSessions();
    sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));

    final recent = <RecentSession>[];
    for (final session in sessions.take(5)) {
      final matches = await _matchRepo.getMatchesBySessionId(session.id!);
      int rackCount = 0;
      int winCount = 0;
      int shotCount = 0;
      int madeCount = 0;

      for (final match in matches) {
        final racks = await _rackRepo.getRacksByMatchId(match.id!);
        rackCount += racks.length;
        winCount += racks.where((r) => r.result).length;

        for (final rack in racks) {
          final shots = await _shotRepo.getShotsByRackId(rack.id!);
          shotCount += shots.length;
          madeCount += shots.where((s) => s.isMade).length;
        }
      }

      recent.add(RecentSession(
        id: session.id!,
        type: session.sessionType,
        date: session.startedAt,
        rackCount: rackCount,
        winCount: winCount,
        accuracy: shotCount == 0 ? 0.0 : madeCount / shotCount,
        duration: session.duration,
      ));
    }

    state = state.copyWith(recentSessions: recent);
  }

  Future<void> _loadTrends() async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);

    final weekSessions = await _sessionRepo.getSessionsByDateRange(
      DateTime(weekStart.year, weekStart.month, weekStart.day),
      now,
    );
    final monthSessions = await _sessionRepo.getSessionsByDateRange(
      monthStart,
      now,
    );

    int weekRacks = 0, weekWins = 0;
    int monthRacks = 0, monthWins = 0;

    for (final session in weekSessions) {
      final matches = await _matchRepo.getMatchesBySessionId(session.id!);
      for (final match in matches) {
        final racks = await _rackRepo.getRacksByMatchId(match.id!);
        weekRacks += racks.length;
        weekWins += racks.where((r) => r.result).length;
      }
    }

    for (final session in monthSessions) {
      final matches = await _matchRepo.getMatchesBySessionId(session.id!);
      for (final match in matches) {
        final racks = await _rackRepo.getRacksByMatchId(match.id!);
        monthRacks += racks.length;
        monthWins += racks.where((r) => r.result).length;
      }
    }

    state = state.copyWith(
      weeklySessionCount: weekSessions.length,
      weeklyRackCount: weekRacks,
      weeklyWinRate: weekRacks == 0 ? 0.0 : weekWins / weekRacks,
      monthlySessionCount: monthSessions.length,
      monthlyRackCount: monthRacks,
      monthlyWinRate: monthRacks == 0 ? 0.0 : monthWins / monthRacks,
    );
  }

  Future<void> _loadCoachInsight() async {
    // FIX-005: Get coach insight from Statistics Engine
    try {
      final allStats = await _statsRepo.getAllStatistics();
      // A single attempt is not enough evidence for a coaching priority. This
      // also prevents unobserved metrics with a zero score becoming "weakest".
      final reliableStats =
          allStats.where((stat) => stat.sampleSize >= 5).toList();
      final skillScores = StatisticsEngine.toRuleEngineFormat(reliableStats);

      if (skillScores.isEmpty) {
        state = state.copyWith(
            coachInsight: const CoachInsight(
          title: 'Chào Mừng',
          message: 'Bắt đầu chơi để nhận lời khuyên cá nhân!',
          type: 'info',
          recommendations: [
            'Bắt đầu buổi tập đầu tiên',
            'Ghi log readiness hàng ngày'
          ],
        ));
        return;
      }

      // Find weakest skills
      final sortedEntries = skillScores.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value));
      final weakest = sortedEntries.take(2).toList();

      final recommendations = <String>[];
      if (weakest.isNotEmpty) {
        final skillName = _getVietnameseSkillName(weakest.first.key);
        recommendations.add('Tập trung cải thiện $skillName');
      }
      if (state.todayShotCount >= 5 && state.todayAccuracy < 0.7) {
        recommendations.add('Luyện độ chính xác trong tập luyện');
      }
      if (state.todayReadiness?.energyLevel != null &&
          state.todayReadiness!.energyLevel! < 5) {
        recommendations.add('Nên tập nhẹ hơn hôm nay do mức năng lượng');
      }

      state = state.copyWith(
          coachInsight: CoachInsight(
        title: 'Gợi Ý Huấn Luyện',
        message: weakest.isNotEmpty
            ? '${_getVietnameseSkillName(weakest.first.key)} cần được chú ý'
            : 'Tiếp tục phong độ tốt!',
        type: weakest.isNotEmpty ? 'warning' : 'success',
        recommendations: recommendations,
      ));
    } catch (e) {
      // A failed statistics read has no sample-size evidence. Cached skill
      // scores must not be promoted into a confident recommendation here.
      state = state.copyWith(
        coachInsight: const CoachInsight(
          title: 'Chưa đủ dữ liệu',
          message: 'Chưa thể tạo gợi ý có độ tin cậy.',
          type: 'info',
          recommendations: [],
        ),
      );
    }
  }

  String _getVietnameseSkillName(String key) {
    const Map<String, String> skillNames = {
      'winRate': 'Tỷ Lệ Thắng',
      'breakSuccess': 'Tỷ Lệ Phá',
      'potting': 'Đánh Trúng',
      'longPot': 'Đánh Bi Xa',
      'thinCut': 'Cắt Mỏng',
      'position': 'Điều Bi',
      'safetySuccess': 'An Toàn',
      'bankSuccess': 'Ghiên',
      'kickSuccess': 'Đá Bi',
      'scratchRate': 'Kiểm Soát Bi Cái',
      'hillHillWin': 'Hill-Hill',
    };
    return skillNames[key] ?? key;
  }

  Future<void> refresh() async {
    await loadDashboard();
  }
}
