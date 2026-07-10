import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/session/data/repositories/session_repository.dart';
import 'package:pool_os/features/match/data/repositories/match_repository.dart';
import 'package:pool_os/features/match/domain/models/match.dart';
import 'package:pool_os/features/session/domain/models/session.dart';
import 'package:pool_os/features/session/presentation/session_state.dart';
import 'package:pool_os/features/session/data/recording_coordinator.dart';

final sessionNotifierProvider =
    StateNotifierProvider<SessionNotifier, SessionState>((ref) {
  final sessionRepo = ref.watch(sessionRepositoryProvider);
  final matchRepo = ref.watch(matchRepositoryProvider);
  final coordinator = ref.watch(recordingCoordinatorProvider);
  return SessionNotifier(
    sessionRepo,
    matchRepo,
    coordinator,
  );
});

class SessionNotifier extends StateNotifier<SessionState> {
  final SessionRepository _sessionRepository;
  final MatchRepository _matchRepository;
  final RecordingCoordinator _coordinator;

  SessionNotifier(
    this._sessionRepository,
    this._matchRepository,
    this._coordinator,
  ) : super(const SessionState()) {
    loadSessions();
  }

  Future<void> loadSessions() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final sessions = await _sessionRepository.getAllSessions();
      final activeSession = await _sessionRepository.getActiveSession();
      
      List<Match> matches = [];
      Match? activeMatch;
      if (activeSession != null) {
        matches = await _matchRepository.getMatchesBySessionId(activeSession.id!);
        activeMatch = await _matchRepository.getActiveMatchBySessionId(activeSession.id!);
      }
      
      state = state.copyWith(
        sessions: sessions,
        activeSession: activeSession,
        matches: matches,
        activeMatch: activeMatch,
        clearActiveMatch: activeMatch == null,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> startSession(String sessionType, {
    String? location,
    String? table,
    String? cloth,
    String? balls,
    String? trainingGoal,
    String? notes,
    String? weather,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final now = DateTime.now();
      final session = Session(
        sessionType: sessionType,
        location: location,
        table: table,
        cloth: cloth,
        balls: balls,
        trainingGoal: trainingGoal,
        notes: notes,
        weather: weather,
        startedAt: now,
        createdAt: now,
        updatedAt: now,
      );
      await _sessionRepository.createSession(session);
      await loadSessions();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createMatch(String gameType, {
    int? raceTo,
    String? opponent,
    String? partner,
    String? teamMode,
    String? matchObjective,
    String? notes,
  }) async {
    if (state.activeSession == null) return;
    
    state = state.copyWith(isLoading: true, error: null);
    try {
      final sessionId = state.activeSession!.id!;
      final matchNumber = await _matchRepository.getNextMatchNumber(sessionId);
      final now = DateTime.now();
      
      final match = Match(
        sessionId: sessionId,
        matchNumber: matchNumber,
        gameType: gameType,
        raceTo: raceTo,
        opponent: opponent,
        partner: partner,
        teamMode: teamMode,
        matchObjective: matchObjective,
        notes: notes,
        startTime: now,
        createdAt: now,
      );
      
      await _matchRepository.createMatch(match);
      await loadSessions();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> finishMatch(int matchId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _matchRepository.finishMatch(matchId);
      await loadSessions();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> finishSession(int id) async {
    state = state.copyWith(isLoading: true, error: null, clearActiveMatch: true);
    try {
      // RFC-301 Rule #6: finishing a session closes everything under it (finish
      // the open match, flush, stamp finishedAt) atomically via the coordinator
      // before clearing UI state.
      await _coordinator.finishSession(id);
      state = state.copyWith(
        activeSession: null,
        activeMatch: null,
        matches: [],
        clearActiveSession: true,
        clearActiveMatch: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateSession(Session session) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _sessionRepository.updateSession(session.copyWith(updatedAt: DateTime.now()));
      await loadSessions();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteSession(int id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _sessionRepository.deleteSession(id);
      await loadSessions();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteMatch(int matchId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _matchRepository.deleteMatch(matchId);
      if (state.activeSession != null) {
        final matches = await _matchRepository.getMatchesBySessionId(state.activeSession!.id!);
        state = state.copyWith(matches: matches, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> selectMatch(int matchId) async {
    final match = state.matches.firstWhere(
      (m) => m.id == matchId,
      orElse: () => throw Exception('Match not found'),
    );
    state = state.copyWith(activeMatch: match);
  }

  Future<void> createPracticeSession() async {
    await startSession(SessionTypes.practice);
  }

  Future<void> createMatchSession() async {
    await startSession(SessionTypes.match);
  }

  Future<void> continueSession(int sessionId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _sessionRepository.reactivateSession(sessionId);
      final session = await _sessionRepository.getSessionById(sessionId);
      if (session == null) {
        state = state.copyWith(isLoading: false, error: 'Session not found');
        return;
      }

      final matches = await _matchRepository.getMatchesBySessionId(sessionId);
      
      state = state.copyWith(
        sessions: state.sessions,
        activeSession: session,
        matches: matches,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
