import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/session/data/repositories/session_repository.dart';
import 'package:pool_os/features/match/data/repositories/match_repository.dart';
import 'package:pool_os/features/rack/data/repositories/rack_repository.dart';
import 'package:pool_os/features/rack/domain/models/rack.dart';

final playerProfileServiceProvider = Provider<PlayerProfileService>((ref) {
  return PlayerProfileService(
    ref.watch(sessionRepositoryProvider),
    ref.watch(matchRepositoryProvider),
    ref.watch(rackRepositoryProvider),
  );
});

/// Task 05 §7/§8: READ-ONLY career achievements + development timeline.
///
/// Everything here is derived from real recorded rows (sessions, matches,
/// racks). It does not touch Coach, Statistics, or AI — it only reads what the
/// recording pipeline already persisted and shapes it for the profile screen.
class PlayerProfileService {
  final SessionRepository _sessionRepo;
  final MatchRepository _matchRepo;
  final RackRepository _rackRepo;

  PlayerProfileService(this._sessionRepo, this._matchRepo, this._rackRepo);

  /// A rack with largestRun >= this counts as a "big run" for Break & Run.
  static const int breakAndRunThreshold = 8;

  Future<ProfileAchievements> computeAchievements() async {
    final sessions = await _sessionRepo.getAllSessions();

    int totalMatches = 0;
    int bestRun = 0;
    int breakAndRun = 0;
    int currentWinStreak = 0;
    int longestWinStreak = 0;

    // Walk racks in play order (session -> match -> rack) to compute streaks and
    // per-rack achievements from real columns.
    final orderedRacks = <Rack>[];
    for (final session in sessions) {
      if (session.id == null) continue;
      final matches = await _matchRepo.getMatchesBySessionId(session.id!);
      totalMatches += matches.length;
      for (final match in matches) {
        if (match.id == null) continue;
        final racks = await _rackRepo.getRacksByMatchId(match.id!);
        orderedRacks.addAll(racks);
      }
    }
    orderedRacks.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    for (final rack in orderedRacks) {
      if (rack.largestRun > bestRun) bestRun = rack.largestRun;
      // Break & Run: won the rack off a successful break with a big run.
      if (rack.result && rack.breakSuccess && rack.largestRun >= breakAndRunThreshold) {
        breakAndRun++;
      }
      // Win streak over the ordered rack sequence.
      if (rack.result) {
        currentWinStreak++;
        if (currentWinStreak > longestWinStreak) longestWinStreak = currentWinStreak;
      } else {
        currentWinStreak = 0;
      }
    }

    return ProfileAchievements(
      totalMatches: totalMatches,
      totalRacks: orderedRacks.length,
      bestRun: bestRun,
      breakAndRun: breakAndRun,
      longestWinStreak: longestWinStreak,
    );
  }

  /// Build the development timeline (§8): first session + achievement milestones,
  /// ordered oldest-first. Returns an empty list when there is no history.
  Future<List<TimelineEntry>> buildTimeline() async {
    final sessions = await _sessionRepo.getAllSessions();
    if (sessions.isEmpty) return [];

    final entries = <TimelineEntry>[];

    // First recorded session = "started playing".
    final sorted = sessions.toList()
      ..sort((a, b) => a.startedAt.compareTo(b.startedAt));
    entries.add(TimelineEntry(
      date: sorted.first.startedAt,
      kind: TimelineKind.startedPlaying,
    ));

    // Walk racks oldest-first, emitting a milestone the first time a new best
    // run is reached and the first Break & Run.
    final orderedRacks = <Rack>[];
    for (final session in sorted) {
      if (session.id == null) continue;
      final matches = await _matchRepo.getMatchesBySessionId(session.id!);
      for (final match in matches) {
        if (match.id == null) continue;
        orderedRacks.addAll(await _rackRepo.getRacksByMatchId(match.id!));
      }
    }
    orderedRacks.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    int runningBest = 0;
    bool firstBreakAndRunLogged = false;
    for (final rack in orderedRacks) {
      if (rack.largestRun > runningBest && rack.largestRun > 0) {
        runningBest = rack.largestRun;
        entries.add(TimelineEntry(
          date: rack.createdAt,
          kind: TimelineKind.bestRun,
          value: runningBest,
        ));
      }
      if (!firstBreakAndRunLogged &&
          rack.result &&
          rack.breakSuccess &&
          rack.largestRun >= breakAndRunThreshold) {
        firstBreakAndRunLogged = true;
        entries.add(TimelineEntry(
          date: rack.createdAt,
          kind: TimelineKind.firstBreakAndRun,
        ));
      }
    }

    entries.sort((a, b) => a.date.compareTo(b.date));
    return entries;
  }
}

class ProfileAchievements {
  final int totalMatches;
  final int totalRacks;
  final int bestRun;
  final int breakAndRun;
  final int longestWinStreak;

  const ProfileAchievements({
    required this.totalMatches,
    required this.totalRacks,
    required this.bestRun,
    required this.breakAndRun,
    required this.longestWinStreak,
  });

  bool get isEmpty => totalRacks == 0;
}

enum TimelineKind { startedPlaying, bestRun, firstBreakAndRun }

class TimelineEntry {
  final DateTime date;
  final TimelineKind kind;
  final int? value;

  const TimelineEntry({required this.date, required this.kind, this.value});

  String label(String locale) {
    final vi = locale == 'vi';
    switch (kind) {
      case TimelineKind.startedPlaying:
        return vi ? 'Bắt đầu chơi' : 'Started playing';
      case TimelineKind.bestRun:
        return vi ? 'Best Run $value' : 'Best Run $value';
      case TimelineKind.firstBreakAndRun:
        return vi ? 'Break & Run đầu tiên' : 'First Break & Run';
    }
  }
}
