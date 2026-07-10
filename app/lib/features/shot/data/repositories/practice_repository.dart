import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/shot/domain/models/practice_shot.dart';
import 'package:pool_os/features/shot/domain/models/practice_session.dart';

// Provider for practice shot repository
@Deprecated(
  'RFC-301: Practice now uses the SAME Match → Rack → Shot → Event pipeline as '
  'a match (see RecordingCoordinator.ensurePracticeMatch). This stub never '
  'persisted anything (returned 0/[]). Do not wire it into new code; the '
  'practice_shots / practice_sessions tables are retained only for legacy data.',
)
final practiceShotRepositoryProvider = Provider<PracticeShotRepository>((ref) {
  return PracticeShotRepository();
});

/// FIX-003: Practice Shot Repository for Practice Mode
///
/// DEPRECATED (RFC-301): superseded by the unified recording pipeline. This was
/// a stub that never touched the database (createShot returned 0, getters
/// returned []). Practice shots are now real Shots under a practice Match.
@Deprecated('RFC-301: use the unified recording pipeline (RecordingCoordinator).')
class PracticeShotRepository {
  /// Create a new practice shot
  Future<int> createShot(PracticeShot shot) async {
    // TODO: Implement with Drift after build_runner
    return 0;
  }

  /// Get all shots for a session
  Future<List<PracticeShot>> getShotsBySessionId(int sessionId) async {
    // TODO: Implement with Drift after build_runner
    return [];
  }

  /// Delete all shots for a session
  Future<int> deleteShotsBySessionId(int sessionId) async {
    return 1;
  }
}

// Provider for practice session repository
final practiceSessionRepositoryProvider = Provider<PracticeSessionRepository>((ref) {
  return PracticeSessionRepository();
});

/// FIX-003: Practice Session Repository for Practice Mode
/// Handles CRUD operations for practice sessions with auto-generated summary
/// 
/// Note: This is a stub implementation. Full implementation requires:
/// 1. Running build_runner to regenerate database code
/// 2. The practice_sessions table will be created via migration V10
class PracticeSessionRepository {
  /// Create a new practice session
  Future<int> createSession(PracticeSession session) async {
    // TODO: Implement with Drift after build_runner
    return 0;
  }

  /// Update a practice session with summary data
  Future<bool> updateSession(PracticeSession session) async {
    return true;
  }

  /// Get sessions for a session
  Future<List<PracticeSession>> getSessionsBySessionId(int sessionId) async {
    // TODO: Implement with Drift after build_runner
    return [];
  }

  /// Get sessions for a player
  Future<List<PracticeSession>> getSessionsByPlayerId(int playerId) async {
    // TODO: Implement with Drift after build_runner
    return [];
  }

  /// Delete a practice session
  Future<int> deleteSession(int id) async {
    return 1;
  }
}
