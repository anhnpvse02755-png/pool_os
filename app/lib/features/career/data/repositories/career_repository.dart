import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/player/data/database/app_database.dart' as db;
import 'package:pool_os/features/player/data/providers/database_providers.dart';
import 'package:pool_os/features/career/domain/models/career_models.dart';
import 'package:pool_os/features/goal_center/domain/achievement_catalog.dart';
import 'package:pool_os/features/shot/domain/models/shot.dart' show ShotResult;

final careerRepositoryProvider = Provider<CareerRepository>((ref) {
  return CareerRepository(ref.watch(databaseProvider));
});

/// Task 11 — the gateway for the Player Timeline & Career feature. It is
/// entirely READ-ONLY: it aggregates a flat list of [TimelineEvent]s and a
/// [CareerSummary] from rows other features already recorded (sessions,
/// matches, racks, shots, cues/equipment, Task 09 training, Task 10 goals +
/// achievement unlocks). It creates no tables and writes nothing — the recording
/// pipeline (RFC-301/302) and every other feature are untouched. No AI.
///
/// Localization: the aggregator can't reach a BuildContext, so display strings
/// are built from a small [CareerLabels] bundle the presentation layer passes in
/// (resolved from AppLocalizations). This keeps the domain pure and testable.
class CareerRepository {
  final db.AppDatabase _db;

  CareerRepository(this._db);

  /// Build the full timeline (Phần 1–6), newest-first is applied later by the
  /// aggregator. Every event is derived from a real recorded row.
  Future<List<TimelineEvent>> buildTimeline(CareerLabels labels) async {
    final events = <TimelineEvent>[];

    // --- Sessions (Phần 1) ---------------------------------------------------
    final sessions = await _db.select(_db.sessions).get();
    for (final s in sessions) {
      events.add(TimelineEvent(
        date: s.startedAt,
        type: TimelineEventType.session,
        title: labels.sessionTitle(s.sessionType),
        subtitle: s.location,
      ));
    }

    // --- Matches (Phần 6) — only decided matches carry a win/loss -----------
    final matches = await _db.select(_db.matches).get();
    for (final m in matches) {
      if (m.winner == null) continue;
      final win = m.winner == 'Player';
      events.add(TimelineEvent(
        date: m.startTime ?? m.createdAt,
        type: TimelineEventType.match,
        title: win ? labels.matchWin : labels.matchLoss,
        subtitle: m.opponent,
        detail: m.raceTo != null ? '${labels.race} ${m.raceTo}' : m.gameType,
        win: win,
      ));
    }

    // --- Equipment (Phần 3) — a cue was added -------------------------------
    final cues = await _db.select(_db.cues).get();
    for (final c in cues) {
      events.add(TimelineEvent(
        date: c.createdAt,
        type: TimelineEventType.equipment,
        title: labels.equipmentAdded,
        subtitle: c.name,
        detail: labels.cueType(c.cueType),
      ));
    }

    // --- Training (Phần 5) — Task 09 training sessions ----------------------
    final training = await _db.select(_db.trainingCenterSessions).get();
    for (final t in training) {
      events.add(TimelineEvent(
        date: t.startedAt,
        type: TimelineEventType.training,
        title: labels.trainingSession,
        subtitle: t.notes,
      ));
    }

    // --- Goals completed (Phần 4) — Task 10 --------------------------------
    final goals = await (_db.select(_db.goals)
          ..where((t) => t.completedAt.isNotNull()))
        .get();
    for (final g in goals) {
      events.add(TimelineEvent(
        date: g.completedAt!,
        type: TimelineEventType.goal,
        title: labels.goalCompleted,
        subtitle: g.isDefault ? labels.resolve(g.title) : g.title,
      ));
    }

    // --- Achievements unlocked (Phần 1) — Task 10 --------------------------
    final unlocks = await _db.select(_db.achievementUnlocks).get();
    for (final u in unlocks) {
      final badge = AchievementCatalog.byKey(u.badgeKey);
      events.add(TimelineEvent(
        date: u.unlockedAt,
        type: TimelineEventType.achievement,
        title: labels.achievementUnlocked,
        subtitle: badge != null ? labels.resolve(badge.titleKey) : u.badgeKey,
      ));
    }

    return events;
  }

  /// Build the career summary (Phần 2) — a read-only roll-up of the journey.
  Future<CareerSummary> buildSummary() async {
    final sessions = await _db.select(_db.sessions).get();
    final matches = await _db.select(_db.matches).get();
    final racks = await _db.select(_db.racks).get();
    final shots = await _db.select(_db.shots).get();
    final cues = await _db.select(_db.cues).get();
    final training = await _db.select(_db.trainingCenterSessions).get();
    final goals = await (_db.select(_db.goals)
          ..where((t) => t.completedAt.isNotNull()))
        .get();
    final unlocks = await _db.select(_db.achievementUnlocks).get();

    // Earliest recorded activity across sessions + training (journey start).
    DateTime? startedAt;
    for (final s in sessions) {
      if (startedAt == null || s.startedAt.isBefore(startedAt)) {
        startedAt = s.startedAt;
      }
    }
    for (final t in training) {
      if (startedAt == null || t.startedAt.isBefore(startedAt)) {
        startedAt = t.startedAt;
      }
    }

    // Total hours: finished recording sessions + completed training sessions.
    var minutes = 0.0;
    for (final s in sessions) {
      if (s.finishedAt != null) {
        minutes += s.finishedAt!.difference(s.startedAt).inMinutes.toDouble();
      }
    }
    for (final t in training) {
      if (t.completedAt != null) {
        minutes += t.completedAt!.difference(t.startedAt).inMinutes.toDouble();
      }
    }

    return CareerSummary(
      startedAt: startedAt,
      totalMatches: matches.length,
      totalRacks: racks.length,
      totalShots: shots.length,
      totalHours: minutes / 60.0,
      goalsCompleted: goals.length,
      achievementsUnlocked: unlocks.length,
      equipmentUsed: cues.length,
      matchesWon: matches.where((m) => m.winner == 'Player').length,
      trainingSessions: training.length,
    );
  }
}

/// Localized display strings the [CareerRepository] uses to build timeline
/// events, resolved once by the presentation layer from AppLocalizations. Keeps
/// the aggregation logic free of BuildContext so it stays unit-testable.
class CareerLabels {
  final String Function(String key) resolve;
  final String matchWin;
  final String matchLoss;
  final String race;
  final String equipmentAdded;
  final String trainingSession;
  final String goalCompleted;
  final String achievementUnlocked;
  final String Function(String sessionType) sessionTitle;
  final String Function(String cueType) cueType;

  const CareerLabels({
    required this.resolve,
    required this.matchWin,
    required this.matchLoss,
    required this.race,
    required this.equipmentAdded,
    required this.trainingSession,
    required this.goalCompleted,
    required this.achievementUnlocked,
    required this.sessionTitle,
    required this.cueType,
  });
}
