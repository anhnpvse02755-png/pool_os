import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/statistics/domain/models/statistics.dart';
import 'package:pool_os/features/statistics/data/repositories/statistics_repository.dart';
import 'package:pool_os/features/statistics/domain/statistics_engine.dart';

final statisticsNotifierProvider =
    StateNotifierProvider<StatisticsNotifier, StatisticsState>((ref) {
  final repository = ref.watch(statisticsRepositoryProvider);
  return StatisticsNotifier(repository);
});

// FIX-005: Provider for all PlayerStatistics
final allPlayerStatisticsProvider = FutureProvider<List<PlayerStatistic>>((ref) async {
  final repository = ref.watch(statisticsRepositoryProvider);
  return repository.getAllStatistics();
});

// FIX-005: Provider for skill radar data from statistics
final skillRadarProvider = FutureProvider<Map<String, double>>((ref) async {
  final stats = await ref.watch(allPlayerStatisticsProvider.future);
  return StatisticsEngine.toRuleEngineFormat(stats);
});

// FIX-009B: Win Rate Detail Provider
final winRateDetailProvider = FutureProvider<WinRateDetail>((ref) async {
  final repository = ref.watch(statisticsRepositoryProvider);
  return repository.getWinRateDetail();
});

// FIX-009B: Rack Detail Provider
final rackDetailProvider = FutureProvider<RackDetail>((ref) async {
  final repository = ref.watch(statisticsRepositoryProvider);
  return repository.getRackDetail();
});

// FIX-009B: Shot Statistics Provider
final shotStatisticsProvider = FutureProvider<ShotStatistics>((ref) async {
  final repository = ref.watch(statisticsRepositoryProvider);
  return repository.getShotStatistics();
});

// FIX-009B: Error Statistics Provider
final errorStatisticsProvider = FutureProvider<ErrorStatistics>((ref) async {
  final repository = ref.watch(statisticsRepositoryProvider);
  return repository.getErrorStatistics();
});

// FIX-009B: Break Statistics Provider
final breakStatisticsProvider = FutureProvider<BreakStatistics>((ref) async {
  final repository = ref.watch(statisticsRepositoryProvider);
  return repository.getBreakStatistics();
});

class StatisticsState {
  final int totalSessions;
  final int totalRacks;
  final int totalShots;
  final int totalWins;
  final int totalLosses;
  final double rackWinRate;
  final double careerAccuracy;
  final Map<String, int> sessionTypeBreakdown;
  final Map<String, int> shotTypeBreakdown;
  final Map<String, int> positionQualityBreakdown;
  final List<SkillStat> skillStats;
  final bool isLoading;
  final String? error;
  final int totalEvents;
  final Map<String, int> eventCategoryStats;
  final Map<String, int> eventTypeStats;

  const StatisticsState({
    this.totalSessions = 0,
    this.totalRacks = 0,
    this.totalShots = 0,
    this.totalWins = 0,
    this.totalLosses = 0,
    this.rackWinRate = 0.0,
    this.careerAccuracy = 0.0,
    this.sessionTypeBreakdown = const {},
    this.shotTypeBreakdown = const {},
    this.positionQualityBreakdown = const {},
    this.skillStats = const [],
    this.isLoading = false,
    this.error,
    this.totalEvents = 0,
    this.eventCategoryStats = const {},
    this.eventTypeStats = const {},
  });

  StatisticsState copyWith({
    int? totalSessions,
    int? totalRacks,
    int? totalShots,
    int? totalWins,
    int? totalLosses,
    double? rackWinRate,
    double? careerAccuracy,
    Map<String, int>? sessionTypeBreakdown,
    Map<String, int>? shotTypeBreakdown,
    Map<String, int>? positionQualityBreakdown,
    List<SkillStat>? skillStats,
    bool? isLoading,
    String? error,
    int? totalEvents,
    Map<String, int>? eventCategoryStats,
    Map<String, int>? eventTypeStats,
  }) {
    return StatisticsState(
      totalSessions: totalSessions ?? this.totalSessions,
      totalRacks: totalRacks ?? this.totalRacks,
      totalShots: totalShots ?? this.totalShots,
      totalWins: totalWins ?? this.totalWins,
      totalLosses: totalLosses ?? this.totalLosses,
      rackWinRate: rackWinRate ?? this.rackWinRate,
      careerAccuracy: careerAccuracy ?? this.careerAccuracy,
      sessionTypeBreakdown: sessionTypeBreakdown ?? this.sessionTypeBreakdown,
      shotTypeBreakdown: shotTypeBreakdown ?? this.shotTypeBreakdown,
      positionQualityBreakdown: positionQualityBreakdown ?? this.positionQualityBreakdown,
      skillStats: skillStats ?? this.skillStats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      totalEvents: totalEvents ?? this.totalEvents,
      eventCategoryStats: eventCategoryStats ?? this.eventCategoryStats,
      eventTypeStats: eventTypeStats ?? this.eventTypeStats,
    );
  }
}

class StatisticsNotifier extends StateNotifier<StatisticsState> {
  final StatisticsRepository _repository;

  StatisticsNotifier(this._repository) : super(const StatisticsState());

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setCareerStats({
    required int sessions,
    required int racks,
    required int shots,
    required int wins,
    required int losses,
    required double accuracy,
  }) {
    final winRate = racks > 0 ? wins / racks : 0.0;
    state = state.copyWith(
      totalSessions: sessions,
      totalRacks: racks,
      totalShots: shots,
      totalWins: wins,
      totalLosses: losses,
      rackWinRate: winRate,
      careerAccuracy: accuracy,
      isLoading: false,
    );
  }

  void setSessionTypeBreakdown(Map<String, int> breakdown) {
    state = state.copyWith(sessionTypeBreakdown: breakdown);
  }

  void setShotTypeBreakdown(Map<String, int> breakdown) {
    state = state.copyWith(shotTypeBreakdown: breakdown);
  }

  void setPositionQualityBreakdown(Map<String, int> breakdown) {
    state = state.copyWith(positionQualityBreakdown: breakdown);
  }

  void setEventStats({
    required int totalEvents,
    required Map<String, int> categoryStats,
    required Map<String, int> typeStats,
  }) {
    state = state.copyWith(
      totalEvents: totalEvents,
      eventCategoryStats: categoryStats,
      eventTypeStats: typeStats,
    );
  }

  Future<void> loadStats() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final skillStats = await _repository.getSkillStats();
      state = state.copyWith(skillStats: skillStats, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadCareerStats() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final careerStats = await _repository.getCareerStats();
      setCareerStats(
        sessions: careerStats.totalSessions,
        racks: careerStats.totalRacks,
        shots: careerStats.totalShots,
        wins: careerStats.totalWins,
        losses: careerStats.totalLosses,
        accuracy: careerStats.accuracy,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadEventStats() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final eventStats = await _repository.getEventBasedStats();
      setEventStats(
        totalEvents: eventStats.totalEvents,
        categoryStats: eventStats.categoryStats,
        typeStats: eventStats.typeStats,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refreshStatistics() async {
    await loadCareerStats();
    await loadStats();
    await loadEventStats();
  }
}
