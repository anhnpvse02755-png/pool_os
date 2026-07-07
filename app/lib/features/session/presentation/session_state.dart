import 'package:pool_os/features/session/domain/models/session.dart';
import 'package:pool_os/features/match/domain/models/match.dart';

class SessionState {
  final List<Session> sessions;
  final Session? activeSession;
  final List<Match> matches;
  final Match? activeMatch;
  final bool isLoading;
  final String? error;

  const SessionState({
    this.sessions = const [],
    this.activeSession,
    this.matches = const [],
    this.activeMatch,
    this.isLoading = false,
    this.error,
  });

  SessionState copyWith({
    List<Session>? sessions,
    Session? activeSession,
    List<Match>? matches,
    Match? activeMatch,
    bool? isLoading,
    String? error,
    bool clearActiveSession = false,
    bool clearActiveMatch = false,
  }) {
    return SessionState(
      sessions: sessions ?? this.sessions,
      activeSession: clearActiveSession ? null : (activeSession ?? this.activeSession),
      matches: matches ?? this.matches,
      activeMatch: clearActiveMatch ? null : (activeMatch ?? this.activeMatch),
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
