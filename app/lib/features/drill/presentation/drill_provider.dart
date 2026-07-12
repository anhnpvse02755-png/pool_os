import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/drill_library.dart';
import '../domain/models/drill.dart';
// RFC-302 Task E: drill runs now flow through the recording pipeline.
import 'package:pool_os/features/session/data/recording_coordinator.dart';
import 'package:pool_os/features/equipment/data/repositories/match_equipment_snapshot_repository.dart';
import 'package:pool_os/features/session/data/repositories/session_repository.dart';
import 'package:pool_os/features/session/domain/models/session.dart';
import 'package:pool_os/features/shot/domain/models/shot.dart';

final drillLibraryProvider = Provider<List<Drill>>((ref) {
  return DrillLibrary.getAllDrills();
});

// ===== FILTER STATE PROVIDERS =====

final drillSkillLevelFilterProvider = StateProvider<String?>((ref) => null);

final drillCategoryFilterProvider = StateProvider<String?>((ref) => null);

final drillDifficultyFilterProvider = StateProvider<String?>((ref) => null);

final drillTimeFilterProvider = StateProvider<String?>((ref) => null);

final drillSkillFilterProvider = StateProvider<String?>((ref) => null);

final drillSearchQueryProvider = StateProvider<String>((ref) => '');

final drillSortProvider = StateProvider<DrillSortOption>((ref) => DrillSortOption.alphabetical);

final drillViewModeProvider = StateProvider<DrillViewMode>((ref) => DrillViewMode.bySkillLevel);

// ===== ENUMS =====

enum DrillSortOption {
  newest,
  alphabetical,
  difficulty,
  coachRecommended,
  recentlyUsed,
  mostPracticed,
}

extension DrillSortOptionExtension on DrillSortOption {
  String get key {
    switch (this) {
      case DrillSortOption.newest:
        return 'newest';
      case DrillSortOption.alphabetical:
        return 'alphabetical';
      case DrillSortOption.difficulty:
        return 'difficulty';
      case DrillSortOption.coachRecommended:
        return 'coachRecommended';
      case DrillSortOption.recentlyUsed:
        return 'recentlyUsed';
      case DrillSortOption.mostPracticed:
        return 'mostPracticed';
    }
  }

  String getName(String locale) {
    final isVietnamese = locale == 'vi';
    switch (this) {
      case DrillSortOption.newest:
        return isVietnamese ? 'Mới nhất' : 'Newest';
      case DrillSortOption.alphabetical:
        return isVietnamese ? 'A-Z' : 'Alphabetical';
      case DrillSortOption.difficulty:
        return isVietnamese ? 'Độ khó' : 'Difficulty';
      case DrillSortOption.coachRecommended:
        return isVietnamese ? 'Coach đề xuất' : 'Coach Recommended';
      case DrillSortOption.recentlyUsed:
        return isVietnamese ? 'Gần đây' : 'Recently Used';
      case DrillSortOption.mostPracticed:
        return isVietnamese ? 'Nhiều luyện nhất' : 'Most Practiced';
    }
  }
}

enum DrillViewMode {
  bySkillLevel,
  byCategory,
  favorites,
  recent,
  mostUsed,
}

extension DrillViewModeExtension on DrillViewMode {
  String getName(String locale) {
    final isVietnamese = locale == 'vi';
    switch (this) {
      case DrillViewMode.bySkillLevel:
        return isVietnamese ? 'Theo cấp độ' : 'By Skill Level';
      case DrillViewMode.byCategory:
        return isVietnamese ? 'Theo danh mục' : 'By Category';
      case DrillViewMode.favorites:
        return isVietnamese ? 'Yêu thích' : 'Favorites';
      case DrillViewMode.recent:
        return isVietnamese ? 'Gần đây' : 'Recent';
      case DrillViewMode.mostUsed:
        return isVietnamese ? 'Nhiều luyện nhất' : 'Most Used';
    }
  }
}

// ===== FILTERED DRILLS PROVIDER =====

final filteredDrillsProvider = Provider<List<Drill>>((ref) {
  final allDrills = ref.watch(drillLibraryProvider);
  final skillLevel = ref.watch(drillSkillLevelFilterProvider);
  final category = ref.watch(drillCategoryFilterProvider);
  final difficulty = ref.watch(drillDifficultyFilterProvider);
  final timeFilter = ref.watch(drillTimeFilterProvider);
  final skillFilter = ref.watch(drillSkillFilterProvider);
  final searchQuery = ref.watch(drillSearchQueryProvider).toLowerCase();
  final sortOption = ref.watch(drillSortProvider);

  var drills = allDrills.where((drill) {
    // Search filter
    if (searchQuery.isNotEmpty) {
      final nameMatch = drill.name.toLowerCase().contains(searchQuery) ||
          drill.nameVi.toLowerCase().contains(searchQuery);
      final categoryMatch = drill.category.toLowerCase().contains(searchQuery);
      final skillMatch = drill.focusSkills.any((s) => s.toLowerCase().contains(searchQuery));
      final difficultyMatch = drill.difficulty.toLowerCase().contains(searchQuery);
      
      if (!nameMatch && !categoryMatch && !skillMatch && !difficultyMatch) {
        return false;
      }
    }

    // Skill level filter
    if (skillLevel != null && drill.skillLevel != skillLevel) {
      return false;
    }

    // Category filter
    if (category != null && drill.category != category) {
      return false;
    }

    // Difficulty filter
    if (difficulty != null && drill.difficulty != difficulty) {
      return false;
    }

    // Time filter
    if (timeFilter != null) {
      switch (timeFilter) {
        case 'short':
          if (drill.timeLimitMinutes >= 10) return false;
          break;
        case 'medium':
          if (drill.timeLimitMinutes < 10 || drill.timeLimitMinutes > 20) return false;
          break;
        case 'long':
          if (drill.timeLimitMinutes <= 20) return false;
          break;
      }
    }

    // Skill filter
    if (skillFilter != null && !drill.focusSkills.contains(skillFilter)) {
      return false;
    }

    return true;
  }).toList();

  // Sort
  switch (sortOption) {
    case DrillSortOption.alphabetical:
      drills.sort((a, b) => a.nameVi.compareTo(b.nameVi));
      break;
    case DrillSortOption.difficulty:
      drills.sort((a, b) => a.difficultyStars.compareTo(b.difficultyStars));
      break;
    case DrillSortOption.newest:
      drills.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
      break;
    case DrillSortOption.coachRecommended:
      drills.sort((a, b) {
        if (a.skillLevel == DrillSkillLevel.coachCustom) return -1;
        if (b.skillLevel == DrillSkillLevel.coachCustom) return 1;
        return 0;
      });
      break;
    case DrillSortOption.recentlyUsed:
      final recentDrills = ref.watch(recentDrillsProvider);
      drills.sort((a, b) {
        final aIndex = recentDrills.indexWhere((d) => d.id == a.id);
        final bIndex = recentDrills.indexWhere((d) => d.id == b.id);
        if (aIndex == -1 && bIndex == -1) return 0;
        if (aIndex == -1) return 1;
        if (bIndex == -1) return -1;
        return aIndex.compareTo(bIndex);
      });
      break;
    case DrillSortOption.mostPracticed:
      final practiceCounts = ref.watch(drillPracticeCountProvider);
      drills.sort((a, b) {
        final aCount = practiceCounts[a.id] ?? 0;
        final bCount = practiceCounts[b.id] ?? 0;
        return bCount.compareTo(aCount);
      });
      break;
  }

  return drills;
});

// ===== DRILL GROUPS PROVIDERS =====

final drillsBySkillLevelProvider = Provider<Map<String, List<Drill>>>((ref) {
  final allDrills = ref.watch(drillLibraryProvider);
  final grouped = <String, List<Drill>>{};
  
  for (final level in DrillSkillLevel.all) {
    grouped[level] = allDrills.where((d) => d.skillLevel == level).toList();
  }
  
  return grouped;
});

final drillsByCategoryProvider = Provider<Map<String, List<Drill>>>((ref) {
  final allDrills = ref.watch(drillLibraryProvider);
  final grouped = <String, List<Drill>>{};
  
  for (final category in DrillCategory.all) {
    final categoryDrills = allDrills.where((d) => d.category == category).toList();
    if (categoryDrills.isNotEmpty) {
      grouped[category] = categoryDrills;
    }
  }
  
  return grouped;
});

// ===== FAVORITE DRILLS =====

final favoriteDrillsProvider = StateNotifierProvider<FavoriteDrillsNotifier, Set<int>>((ref) {
  return FavoriteDrillsNotifier();
});

class FavoriteDrillsNotifier extends StateNotifier<Set<int>> {
  FavoriteDrillsNotifier() : super({});

  void toggleFavorite(int drillId) {
    if (state.contains(drillId)) {
      state = Set.from(state)..remove(drillId);
    } else {
      state = Set.from(state)..add(drillId);
    }
  }

  bool isFavorite(int drillId) => state.contains(drillId);
}

// ===== RECENT DRILLS =====

final recentDrillsProvider = StateNotifierProvider<RecentDrillsNotifier, List<Drill>>((ref) {
  return RecentDrillsNotifier();
});

class RecentDrillsNotifier extends StateNotifier<List<Drill>> {
  RecentDrillsNotifier() : super([]);

  void addRecentDrill(Drill drill) {
    final updated = [drill, ...state.where((d) => d.id != drill.id)];
    if (updated.length > 10) {
      updated.removeLast();
    }
    state = updated;
  }
}

// ===== PRACTICE COUNT =====

final drillPracticeCountProvider = StateNotifierProvider<DrillPracticeCountNotifier, Map<int, int>>((ref) {
  return DrillPracticeCountNotifier();
});

class DrillPracticeCountNotifier extends StateNotifier<Map<int, int>> {
  DrillPracticeCountNotifier() : super({});

  void incrementPractice(int drillId) {
    final current = state[drillId] ?? 0;
    state = Map.from(state)..[drillId] = current + 1;
  }
}

// ===== ACTIVE DRILL =====

final activeDrillProvider = StateNotifierProvider<ActiveDrillNotifier, ActiveDrillState>((ref) {
  return ActiveDrillNotifier(ref);
});

class ActiveDrillState {
  final Drill? drill;
  final DrillSession? session;
  final bool isRunning;
  final String? error;

  const ActiveDrillState({
    this.drill,
    this.session,
    this.isRunning = false,
    this.error,
  });

  ActiveDrillState copyWith({
    Drill? drill,
    DrillSession? session,
    bool? isRunning,
    String? error,
    bool clearDrill = false,
    bool clearSession = false,
  }) {
    return ActiveDrillState(
      drill: clearDrill ? null : (drill ?? this.drill),
      session: clearSession ? null : (session ?? this.session),
      isRunning: isRunning ?? this.isRunning,
      error: error,
    );
  }

  bool get hasActiveSession => session != null && isRunning;
}

/// RFC-302 Task E: a drill run is the 3rd kind of Session activity
/// (Compete / Ghost / Drill) and now flows through the SAME
/// Session → Match(gameType='drill') → Rack → Shot pipeline as a match, via
/// [RecordingCoordinator]. It is no longer an in-memory-only island: every
/// attempt is persisted as a Shot the moment it happens (RFC Rule #5), so drill
/// data survives restart and is readable by Statistics (shots) and Coach (the
/// rack summary written on finish). [DrillSession] is kept only as the live UI
/// counter; the durable record lives in the recording tables.
class ActiveDrillNotifier extends StateNotifier<ActiveDrillState> {
  final Ref _ref;

  ActiveDrillNotifier(this._ref) : super(const ActiveDrillState());

  // Real recording-pipeline ids for the drill run currently in progress.
  int? _matchId;
  int? _rackId;
  // Set only when startDrill had to create a parent Session itself (drill
  // launched from Coach/Library with no session open). That auto-created
  // session is finished when the drill ends so it does not linger as the
  // active session and swallow later activity. A pre-existing session the user
  // started (Compete/Ghost) is left open — we did not own it.
  int? _ownedSessionId;

  RecordingCoordinator get _coordinator =>
      _ref.read(recordingCoordinatorProvider);

  /// Begins a drill run inside the active Session. A drill cannot exist outside
  /// a Session (RFC Rule #1), so if none is open we start one automatically —
  /// drills launched from Coach/Library still get a real parent Session.
  Future<void> startDrill(Drill drill) async {
    state = state.copyWith(isRunning: false, error: null);

    // Recent + practice-count are UI conveniences, keep them.
    _ref.read(recentDrillsProvider.notifier).addRecentDrill(drill);
    if (drill.id != null) {
      _ref.read(drillPracticeCountProvider.notifier).incrementPractice(drill.id!);
    }

    try {
      final sessionRepo = _ref.read(sessionRepositoryProvider);
      var activeSession = await sessionRepo.getActiveSession();
      if (activeSession == null) {
        activeSession = await _startSessionForDrill(sessionRepo);
        // We created this session; remember to close it when the drill ends so
        // it does not linger as the active session.
        _ownedSessionId = activeSession.id;
      } else {
        _ownedSessionId = null;
      }

      final ids = await _coordinator.startDrillMatch(
        sessionId: activeSession.id!,
        drillCode: drill.code,
        drillName: drill.name,
      );
      _matchId = ids.matchId;
      _rackId = ids.rackId;

      // Task 04: capture the equipment snapshot for this drill match.
      await _ref
          .read(matchEquipmentSnapshotRepositoryProvider)
          .captureForMatch(ids.matchId);

      state = state.copyWith(
        drill: drill,
        session: DrillSession(
          drillCode: drill.code,
          drillName: drill.name,
          startedAt: DateTime.now(),
          targetScore: drill.targetScore,
        ),
        isRunning: true,
      );
    } catch (e) {
      _matchId = null;
      _rackId = null;
      state = state.copyWith(error: e.toString(), isRunning: false);
    }
  }

  Future<Session> _startSessionForDrill(SessionRepository sessionRepo) async {
    final now = DateTime.now();
    final id = await sessionRepo.createSession(
      Session(sessionType: 'training', startedAt: now, createdAt: now),
    );
    final created = await sessionRepo.getSessionById(id);
    // getSessionById round-trips the row we just inserted; non-null in practice.
    return created!;
  }

  /// Records one attempt. Persists a real Shot FIRST (RFC Rule #5), then updates
  /// the live UI counter. On persistence failure the counter is NOT advanced and
  /// the error is surfaced, so the UI never shows a save that did not happen.
  Future<void> recordAttempt({required bool success, String? note}) async {
    final session = state.session;
    final rackId = _rackId;
    if (session == null || rackId == null) return;

    try {
      await _coordinator.recordShot(
        rackId: rackId,
        shot: Shot(
          rackId: rackId,
          shotNumber: 0, // coordinator assigns the real shotNumber
          shotType: ShotTypes.normalShot,
          difficulty: ShotDifficulty.medium,
          result: success ? ShotResult.made : ShotResult.missed,
          playerNote: note,
        ),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return;
    }

    final newScore = success ? session.currentScore + 1 : session.currentScore;
    final updatedSession = session.copyWith(
      currentScore: newScore,
      attempts: session.attempts + 1,
      successfulAttempts:
          success ? session.successfulAttempts + 1 : session.successfulAttempts,
      completedAt: newScore >= session.targetScore ? DateTime.now() : null,
      notes: note != null ? [...session.notes, note] : null,
    );

    state = state.copyWith(
      session: updatedSession,
      isRunning: updatedSession.completedAt == null,
      error: null,
    );

    // Auto-finish the recording match when the target is reached.
    if (updatedSession.completedAt != null) {
      await _finishDrillMatch(updatedSession);
    }
  }

  void addNote(String note) {
    if (state.session == null) return;

    state = state.copyWith(
      session: state.session!.copyWith(
        notes: [...state.session!.notes, note],
      ),
    );
  }

  void rateDrill(String rating) {
    if (state.session == null) return;

    state = state.copyWith(
      session: state.session!.copyWith(rating: rating),
    );
  }

  void pauseDrill() {
    state = state.copyWith(isRunning: false);
  }

  void resumeDrill() {
    if (state.session == null) return;
    state = state.copyWith(isRunning: true);
  }

  /// Ends the drill early (user tapped "finish"). Flushes the rack summary and
  /// finishes the match so partial runs are still fully recorded.
  Future<void> completeDrill({String? rating, List<String>? notes}) async {
    final session = state.session;
    if (session == null) return;

    final completedSession = session.copyWith(
      completedAt: session.completedAt ?? DateTime.now(),
      rating: rating,
      notes: notes ?? session.notes,
    );

    state = state.copyWith(session: completedSession, isRunning: false);
    await _finishDrillMatch(completedSession);
  }

  Future<void> _finishDrillMatch(DrillSession session) async {
    final matchId = _matchId;
    final rackId = _rackId;
    if (matchId == null || rackId == null) return;
    final ownedSessionId = _ownedSessionId;
    try {
      await _coordinator.finishDrillMatch(
        matchId: matchId,
        rackId: rackId,
        attempts: session.attempts,
        successfulAttempts: session.successfulAttempts,
        targetScore: session.targetScore,
        notes: session.notes,
        rating: session.rating,
      );
      // Close the parent Session only if this drill created it (launched from
      // Coach/Library). A session the user already had open (Compete/Ghost) is
      // left running — finishing it here would kill their in-progress activity.
      if (ownedSessionId != null) {
        await _ref.read(sessionRepositoryProvider).finishSession(ownedSessionId);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      _matchId = null;
      _rackId = null;
      _ownedSessionId = null;
    }
  }

  /// Cancels the drill. The recording match is finished (not deleted) so the
  /// shots already recorded remain valid history rather than becoming orphans.
  Future<void> cancelDrill() async {
    final session = state.session;
    if (session != null) {
      await _finishDrillMatch(session);
    }
    _matchId = null;
    _rackId = null;
    state = const ActiveDrillState();
  }

  /// Restarts the same drill: closes the current recording match and opens a
  /// fresh one, so each run is its own Match/Rack with its own shots.
  Future<void> resetDrill() async {
    final drill = state.drill;
    if (drill == null) return;
    final prev = state.session;
    if (prev != null) {
      await _finishDrillMatch(prev);
    }
    await startDrill(drill);
  }
}

// ===== DRILL HISTORY =====

final drillHistoryProvider = StateNotifierProvider<DrillHistoryNotifier, DrillHistoryState>((ref) {
  return DrillHistoryNotifier();
});

class DrillHistoryState {
  final List<DrillSession> sessions;
  final bool isLoading;
  final String? error;

  const DrillHistoryState({
    this.sessions = const [],
    this.isLoading = false,
    this.error,
  });

  DrillHistoryState copyWith({
    List<DrillSession>? sessions,
    bool? isLoading,
    String? error,
  }) {
    return DrillHistoryState(
      sessions: sessions ?? this.sessions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  List<DrillSession> get completedSessions =>
      sessions.where((s) => s.completedAt != null).toList();

  int get totalSessions => sessions.length;

  double get averageSuccessRate {
    final completed = completedSessions;
    if (completed.isEmpty) return 0.0;
    return completed.map((s) => s.successRate).reduce((a, b) => a + b) /
        completed.length;
  }

  List<DrillSession> getSessionsForDrill(String drillCode) {
    return sessions.where((s) => s.drillCode == drillCode).toList();
  }
}

class DrillHistoryNotifier extends StateNotifier<DrillHistoryState> {
  DrillHistoryNotifier() : super(const DrillHistoryState());

  void addSession(DrillSession session) {
    state = state.copyWith(
      sessions: [session, ...state.sessions],
    );
  }

  void removeSession(int sessionId) {
    state = state.copyWith(
      sessions: state.sessions.where((s) => s.id != sessionId).toList(),
    );
  }

  void clearHistory() {
    state = const DrillHistoryState();
  }

  DrillSession? getPersonalBest(String drillCode) {
    final drillSessions = state.getSessionsForDrill(drillCode);
    if (drillSessions.isEmpty) return null;

    return drillSessions.reduce((a, b) =>
        a.successfulAttempts > b.successfulAttempts ? a : b);
  }
}

// ===== DRILL STATUS =====

final drillStatusProvider = StateNotifierProvider<DrillStatusNotifier, Map<int, String>>((ref) {
  return DrillStatusNotifier();
});

class DrillStatusNotifier extends StateNotifier<Map<int, String>> {
  DrillStatusNotifier() : super({});

  void updateStatus(int drillId, String status) {
    state = Map.from(state)..[drillId] = status;
  }

  String getStatus(int drillId) {
    return state[drillId] ?? DrillStatus.notStarted;
  }
}
