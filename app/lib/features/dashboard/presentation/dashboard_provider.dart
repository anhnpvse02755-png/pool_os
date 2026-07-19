import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/daily_readiness/data/repositories/daily_readiness_repository.dart';
import 'package:pool_os/features/daily_readiness/domain/models/daily_readiness.dart';
import 'package:pool_os/features/match/data/repositories/match_repository.dart';
import 'package:pool_os/features/rack/data/repositories/rack_repository.dart';
import 'package:pool_os/features/session/data/repositories/session_repository.dart';
import 'package:pool_os/features/session/domain/models/session.dart';

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier(
    sessionRepo: ref.watch(sessionRepositoryProvider),
    matchRepo: ref.watch(matchRepositoryProvider),
    rackRepo: ref.watch(rackRepositoryProvider),
    readinessRepo: ref.watch(dailyReadinessRepositoryProvider),
  );
});

/// Dashboard owns factual summary data only. Coaching priority, confidence, and
/// next action come exclusively from CoachBrain through coachOutputProvider.
class DashboardState {
  final DailyReadinessModel? todayReadiness;
  final Session? activeSession;
  final int currentStreak;
  final Duration weeklyPlayTime;
  final int weeklySessionCount;
  final int weeklyRackCount;
  final double weeklyWinRate;
  final bool isLoading;
  final String? error;

  const DashboardState({
    this.todayReadiness,
    this.activeSession,
    this.currentStreak = 0,
    this.weeklyPlayTime = Duration.zero,
    this.weeklySessionCount = 0,
    this.weeklyRackCount = 0,
    this.weeklyWinRate = 0,
    this.isLoading = false,
    this.error,
  });

  DashboardState copyWith({
    DailyReadinessModel? todayReadiness,
    Session? activeSession,
    int? currentStreak,
    Duration? weeklyPlayTime,
    int? weeklySessionCount,
    int? weeklyRackCount,
    double? weeklyWinRate,
    bool? isLoading,
    String? error,
    bool clearTodayReadiness = false,
    bool clearActiveSession = false,
  }) {
    return DashboardState(
      todayReadiness:
          clearTodayReadiness ? null : (todayReadiness ?? this.todayReadiness),
      activeSession:
          clearActiveSession ? null : (activeSession ?? this.activeSession),
      currentStreak: currentStreak ?? this.currentStreak,
      weeklyPlayTime: weeklyPlayTime ?? this.weeklyPlayTime,
      weeklySessionCount: weeklySessionCount ?? this.weeklySessionCount,
      weeklyRackCount: weeklyRackCount ?? this.weeklyRackCount,
      weeklyWinRate: weeklyWinRate ?? this.weeklyWinRate,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final SessionRepository _sessionRepo;
  final MatchRepository _matchRepo;
  final RackRepository _rackRepo;
  final DailyReadinessRepository _readinessRepo;

  DashboardNotifier({
    required SessionRepository sessionRepo,
    required MatchRepository matchRepo,
    required RackRepository rackRepo,
    required DailyReadinessRepository readinessRepo,
  })  : _sessionRepo = sessionRepo,
        _matchRepo = matchRepo,
        _rackRepo = rackRepo,
        _readinessRepo = readinessRepo,
        super(const DashboardState()) {
    loadDashboard();
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await Future.wait([
        _loadToday(),
        _loadWeeklyProgress(),
      ]);
      state = state.copyWith(isLoading: false);
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  Future<void> _loadToday() async {
    final readiness = await _readinessRepo.getByDate(_todayKey());
    final activeSession = await _sessionRepo.getActiveSession();
    state = state.copyWith(
      todayReadiness: readiness,
      activeSession: activeSession,
      clearTodayReadiness: readiness == null,
      clearActiveSession: activeSession == null,
    );
  }

  Future<void> _loadWeeklyProgress() async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDate =
        DateTime(weekStart.year, weekStart.month, weekStart.day);
    final weekSessions =
        await _sessionRepo.getSessionsByDateRange(weekStartDate, now);
    final allSessions = await _sessionRepo.getAllSessions();

    var weeklyRacks = 0;
    var weeklyWins = 0;
    var weeklyPlayTime = Duration.zero;
    for (final session in weekSessions) {
      weeklyPlayTime += session.duration;
      final matches = await _matchRepo.getMatchesBySessionId(session.id!);
      for (final match in matches) {
        final racks = await _rackRepo.getRacksByMatchId(match.id!);
        weeklyRacks += racks.length;
        weeklyWins += racks.where((rack) => rack.result).length;
      }
    }

    state = state.copyWith(
      currentStreak: _calculateStreak(allSessions),
      weeklyPlayTime: weeklyPlayTime,
      weeklySessionCount: weekSessions.length,
      weeklyRackCount: weeklyRacks,
      weeklyWinRate: weeklyRacks == 0 ? 0 : weeklyWins / weeklyRacks,
    );
  }

  int _calculateStreak(List<Session> sessions) {
    if (sessions.isEmpty) return 0;
    final sorted = sessions.toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    DateTime? lastDate;
    var streak = 0;

    for (final session in sorted) {
      final date = DateTime(
        session.startedAt.year,
        session.startedAt.month,
        session.startedAt.day,
      );
      if (lastDate == null) {
        if (date != today && date != yesterday) return 0;
        lastDate = date;
        streak = 1;
        continue;
      }
      if (date == lastDate) continue;
      if (date == lastDate.subtract(const Duration(days: 1))) {
        lastDate = date;
        streak++;
        continue;
      }
      break;
    }
    return streak;
  }

  Future<void> refresh() => loadDashboard();
}
