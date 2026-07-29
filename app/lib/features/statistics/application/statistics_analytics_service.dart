// EPIC 02 — Statistics & Analytics — Phase 4: service + provider.
//
// The analytics service consumes the existing repositories (read
// only) and forwards the loaded records to the Phase 3
// aggregators. No new persistence layer is introduced; the
// service is a thin Riverpod-glue layer between repositories and
// the dashboard / statistics screens.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../equipment/data/repositories/equipment_repository.dart';
import '../../equipment/domain/equipment_performance_projection.dart';
import '../../match/data/repositories/match_repository.dart';
import '../../player/presentation/player_provider.dart';
import '../../session/data/repositories/session_repository.dart';
import '../domain/aggregators/match_statistics_aggregator.dart';
import '../domain/models/analytics_period.dart';
import '../domain/models/analytics_snapshots.dart';
import '../domain/models/performance_snapshots.dart';
import '../domain/performance/performance_calculator.dart';

class StatisticsAnalyticsService {
  StatisticsAnalyticsService({
    required this.matchRepository,
    required this.sessionRepository,
    required this.equipmentRepository,
  });

  final MatchRepository matchRepository;
  final SessionRepository sessionRepository;
  final EquipmentRepository equipmentRepository;

  Future<MatchStatisticsSnapshot> matchSnapshot({
    required AnalyticsPeriod period,
    required DateTime now,
    required String activePlayerName,
  }) async {
    final matches = await matchRepository.getAllMatches();
    return const MatchStatisticsAggregator().aggregate(
      matches: matches,
      period: period,
      now: now,
      activePlayerName: activePlayerName,
    );
  }

  Future<SessionStatisticsSnapshot> sessionSnapshot({
    required AnalyticsPeriod period,
    required DateTime now,
  }) async {
    final sessions = await sessionRepository.getAllSessions();
    return const SessionStatisticsAggregator().aggregate(
      sessions: sessions,
      period: period,
      now: now,
    );
  }

  Future<EquipmentStatisticsSnapshot> equipmentSnapshot({
    required AnalyticsPeriod period,
    required DateTime now,
    required List<EquipmentPerformanceProjection> projections,
  }) async {
    final cues = await equipmentRepository.getAllCues();
    return const EquipmentStatisticsAggregator().aggregate(
      cues: cues,
      projections: projections,
      period: period,
      now: now,
    );
  }

  Future<PlayerStatisticsSnapshot> playerSnapshot({
    required AnalyticsPeriod period,
    required DateTime now,
    required String activePlayerName,
  }) async {
    final matches = await matchRepository.getAllMatches();
    return const PlayerStatisticsAggregator().aggregate(
      matches: matches,
      period: period,
      now: now,
      activePlayerName: activePlayerName,
    );
  }

  Future<DashboardSnapshot> dashboardSnapshot({
    required AnalyticsPeriod period,
    required DateTime now,
    required String activePlayerName,
    required List<EquipmentPerformanceProjection> projections,
  }) async {
    final matches = await matchRepository.getAllMatches();
    final sessions = await sessionRepository.getAllSessions();
    final cues = await equipmentRepository.getAllCues();
    return const DashboardAggregator(
      match: MatchStatisticsAggregator(),
      session: SessionStatisticsAggregator(),
      equipment: EquipmentStatisticsAggregator(),
    ).aggregate(
      matches: matches,
      sessions: sessions,
      cues: cues,
      projections: projections,
      period: period,
      now: now,
      activePlayerName: activePlayerName,
    );
  }

  Future<PerformanceSnapshot> performanceSnapshot({
    required AnalyticsPeriod period,
    required DateTime now,
    required String activePlayerName,
    required List<EquipmentPerformanceProjection> projections,
  }) async {
    final matches = await matchRepository.getAllMatches();
    final sessions = await sessionRepository.getAllSessions();
    final cues = await equipmentRepository.getAllCues();
    return const PerformanceCalculator().calculate(
      matches: matches,
      sessions: sessions,
      cues: cues,
      projections: projections,
      period: period,
      now: now,
      activePlayerName: activePlayerName,
    );
  }
}

final statisticsAnalyticsServiceProvider = Provider<StatisticsAnalyticsService>((ref) {
  return StatisticsAnalyticsService(
    matchRepository: ref.watch(matchRepositoryProvider),
    sessionRepository: ref.watch(sessionRepositoryProvider),
    equipmentRepository: ref.watch(equipmentRepositoryProvider),
  );
});

final analyticsPeriodProvider = StateProvider<AnalyticsPeriod>(
  (ref) => AnalyticsPeriod.sevenDays,
);

final activePlayerNameProvider = Provider<String>((ref) {
  final state = ref.watch(playerNotifierProvider);
  return state.activePlayer?.name ?? '';
});

final dashboardSnapshotProvider = FutureProvider.autoDispose<DashboardSnapshot>((ref) async {
  final service = ref.watch(statisticsAnalyticsServiceProvider);
  final period = ref.watch(analyticsPeriodProvider);
  final activePlayerName = ref.watch(activePlayerNameProvider);
  return service.dashboardSnapshot(
    period: period,
    now: DateTime.now(),
    activePlayerName: activePlayerName,
    projections: const [],
  );
});

final matchStatisticsSnapshotProvider =
    FutureProvider.autoDispose<MatchStatisticsSnapshot>((ref) async {
  final service = ref.watch(statisticsAnalyticsServiceProvider);
  final period = ref.watch(analyticsPeriodProvider);
  final activePlayerName = ref.watch(activePlayerNameProvider);
  return service.matchSnapshot(
    period: period,
    now: DateTime.now(),
    activePlayerName: activePlayerName,
  );
});

final sessionStatisticsSnapshotProvider =
    FutureProvider.autoDispose<SessionStatisticsSnapshot>((ref) async {
  final service = ref.watch(statisticsAnalyticsServiceProvider);
  final period = ref.watch(analyticsPeriodProvider);
  return service.sessionSnapshot(
    period: period,
    now: DateTime.now(),
  );
});

final equipmentStatisticsSnapshotProvider =
    FutureProvider.autoDispose<EquipmentStatisticsSnapshot>((ref) async {
  final service = ref.watch(statisticsAnalyticsServiceProvider);
  final period = ref.watch(analyticsPeriodProvider);
  return service.equipmentSnapshot(
    period: period,
    now: DateTime.now(),
    projections: const [],
  );
});

final playerStatisticsSnapshotProvider =
    FutureProvider.autoDispose<PlayerStatisticsSnapshot>((ref) async {
  final service = ref.watch(statisticsAnalyticsServiceProvider);
  final period = ref.watch(analyticsPeriodProvider);
  final activePlayerName = ref.watch(activePlayerNameProvider);
  return service.playerSnapshot(
    period: period,
    now: DateTime.now(),
    activePlayerName: activePlayerName,
  );
});

final performanceSnapshotProvider =
    FutureProvider.autoDispose<PerformanceSnapshot>((ref) async {
  final service = ref.watch(statisticsAnalyticsServiceProvider);
  final period = ref.watch(analyticsPeriodProvider);
  final activePlayerName = ref.watch(activePlayerNameProvider);
  return service.performanceSnapshot(
    period: period,
    now: DateTime.now(),
    activePlayerName: activePlayerName,
    projections: const [],
  );
});
