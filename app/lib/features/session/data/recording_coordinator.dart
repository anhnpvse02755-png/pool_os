import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/player/data/database/app_database.dart' as db;
import 'package:pool_os/features/player/data/providers/database_providers.dart';
import 'package:pool_os/features/match/data/repositories/match_repository.dart';
import 'package:pool_os/features/match/domain/match_lifecycle_policy.dart';
import 'package:pool_os/features/match/domain/models/match.dart';
import 'package:pool_os/features/rack/data/repositories/rack_repository.dart';
import 'package:pool_os/features/rack/domain/models/rack.dart';
import 'package:pool_os/features/shot/data/repositories/shot_repository.dart';
import 'package:pool_os/features/shot/domain/models/shot.dart';
import 'package:pool_os/features/event/data/repositories/event_repository.dart';
import 'package:pool_os/features/event/domain/models/event.dart';
import 'package:pool_os/features/session/data/repositories/session_repository.dart';
import 'package:pool_os/features/session/domain/recording_errors.dart';

/// RFC-301: single choke-point for the recording pipeline
/// (Session → Match → Rack → Shot → Event).
///
/// The coordinator is the ONLY place that writes across recording tables. It
/// guarantees the RFC business rules that individual repositories cannot see on
/// their own:
///  * every child has a valid, persisted parent (no orphan rows, no fake IDs),
///  * multi-row create chains run inside a single DB transaction (atomic —
///    a failure rolls the whole chain back),
///  * the real auto-increment id is returned so callers persist-first, then
///    update state with the true id (never memory-only objects).
///
/// Repositories keep their plain CRUD role; the coordinator orchestrates them.
class RecordingCoordinator {
  final db.AppDatabase _db;
  final SessionRepository _sessionRepo;
  final MatchRepository _matchRepo;
  final RackRepository _rackRepo;
  final ShotRepository _shotRepo;
  final EventRepository _eventRepo;
  final DateTime Function() _lifecycleClock;
  final MatchLifecyclePolicy _lifecyclePolicy;

  RecordingCoordinator({
    required db.AppDatabase database,
    required SessionRepository sessionRepo,
    required MatchRepository matchRepo,
    required RackRepository rackRepo,
    required ShotRepository shotRepo,
    required EventRepository eventRepo,
    DateTime Function()? lifecycleClock,
    MatchLifecyclePolicy lifecyclePolicy = const MatchLifecyclePolicy(),
  })  : _db = database,
        _sessionRepo = sessionRepo,
        _matchRepo = matchRepo,
        _rackRepo = rackRepo,
        _shotRepo = shotRepo,
        _eventRepo = eventRepo,
        _lifecycleClock = lifecycleClock ?? DateTime.now,
        _lifecyclePolicy = lifecyclePolicy;

  /// The gameType used for Practice sessions. Practice runs the EXACT same
  /// Match → Rack → Shot → Event pipeline as a real match (RFC Rule #4); it
  /// only differs in scoring (no race target, no win/lose).
  static const String practiceGameType = 'practice';

  /// RFC-302 Task E: the gameType for a drill run. A drill is the 3rd kind of
  /// Session activity (Compete / Ghost / Drill) and runs the SAME
  /// Match → Rack → Shot pipeline — it is not a separate in-memory system.
  /// One drill run = one Match(gameType='drill') whose single Rack carries the
  /// drill summary (target, attempts, successes); each attempt = one Shot.
  static const String drillGameType = 'drill';

  Future<int> createMatch(Match match) async {
    final now = _commandNowUtc();
    final start = _lifecyclePolicy.canonicalize(match.startTime) ?? now;
    return _db.transaction(() async {
      final matchNumber = await _matchRepo.getNextMatchNumber(match.sessionId);
      return _matchRepo.createMatch(
        match.copyWith(
          matchNumber: matchNumber,
          startTime: start,
          createdAt: now,
        ),
      );
    });
  }

  Future<int> recordRack(Rack rack) async {
    return _db.transaction(() async {
      if (!await _rackRepo.matchExists(rack.matchId)) {
        throw RecordingIntegrityException(
          'Cannot record a Rack: Match ${rack.matchId} does not exist.',
        );
      }
      final rackNumber = await _rackRepo.getNextRackNumber(rack.matchId);
      return _rackRepo.createRack(rack.copyWith(rackNumber: rackNumber));
    });
  }

  Future<void> startMatch(
    int matchId, {
    required DateTime startedAt,
  }) async {
    final canonicalStart = _lifecyclePolicy.requireStart(startedAt);
    await _db.transaction(
      () => _matchRepo.startMatchLifecycle(matchId, canonicalStart),
    );
  }

  Future<void> finishMatch(
    int matchId, {
    String? winner,
    DateTime? startedAt,
    DateTime? endedAt,
  }) async {
    final command = _lifecyclePolicy.requireFinish(
      startTime: startedAt,
      endTime: endedAt ?? _commandNowUtc(),
    );
    await _db.transaction(
      () => _finishMatchWithinTransaction(
        matchId,
        winner: winner,
        startedAt: command.startTime,
        endedAt: command.endTime,
      ),
    );
  }

  /// RFC-302 Task E: begin a drill run inside [sessionId]. Creates a
  /// Match(gameType='drill', notes=drillCode) and its first Rack, and returns
  /// both real ids so the caller records attempts against a valid Rack from the
  /// very first shot (RFC Rules #1/#4 — a Shot always has a Rack under a Match
  /// under a Session). Atomic: match+rack are created in one transaction.
  Future<({int matchId, int rackId})> startDrillMatch({
    required int sessionId,
    required String drillCode,
    required String drillName,
  }) async {
    final now = _commandNowUtc();
    return _db.transaction(() async {
      final matchNumber = await _matchRepo.getNextMatchNumber(sessionId);
      final matchId = await _matchRepo.createMatch(
        Match(
          sessionId: sessionId,
          matchNumber: matchNumber,
          gameType: drillGameType,
          matchObjective: drillName,
          notes: drillCode,
          startTime: now,
          createdAt: now,
        ),
      );
      final rackId = await _rackRepo.createRack(
        Rack(matchId: matchId, rackNumber: 1, result: false),
      );
      return (matchId: matchId, rackId: rackId);
    });
  }

  /// RFC-302 Task E: close a drill run. Writes the run summary onto its Rack
  /// (success/attempt counts, success rate as confidence 0–10, notes) and
  /// finishes the Match. All persisted, so it survives restart and is readable
  /// by Statistics (shots) and Coach (rack summary). Atomic.
  Future<void> finishDrillMatch({
    required int matchId,
    required int rackId,
    required int attempts,
    required int successfulAttempts,
    required int targetScore,
    List<String> notes = const [],
    String? rating,
  }) async {
    final endedAt = _commandNowUtc();
    await _db.transaction(() async {
      final rack = await _rackRepo.getRackById(rackId);
      if (rack == null) {
        throw RecordingIntegrityException(
          'Cannot finish drill: Rack $rackId does not exist.',
        );
      }
      final made = successfulAttempts;
      final missed = (attempts - successfulAttempts).clamp(0, attempts);
      final successRate = attempts == 0 ? 0.0 : made / attempts;
      await _rackRepo.updateRack(
        rack.copyWith(
          // Drill "win" = target reached. Kept as the rack result so history
          // and stats can tell a completed drill from an abandoned one.
          result: made >= targetScore && targetScore > 0,
          ballsPotted: made,
          easyMissCount: missed,
          confidence: (successRate * 10).round().clamp(0, 10),
          notes: notes.isEmpty ? rack.notes : notes.join('\n'),
        ),
      );
      await _finishMatchWithinTransaction(
        matchId,
        winner: null,
        startedAt: null,
        endedAt: endedAt,
      );
    });
  }

  /// Returns the id of the open Match for [sessionId], creating a practice
  /// Match if none exists. Used by the Practice flow so a Shot always has a
  /// Rack, which always has a Match (RFC Rule #4: Practice is not special).
  Future<int> ensurePracticeMatch({required int sessionId}) async {
    final now = _commandNowUtc();
    return _db.transaction(() async {
      final existing = await _matchRepo.getActiveMatchBySessionId(sessionId);
      if (existing?.id != null) return existing!.id!;

      final matchNumber = await _matchRepo.getNextMatchNumber(sessionId);
      final id = await _matchRepo.createMatch(
        Match(
          sessionId: sessionId,
          matchNumber: matchNumber,
          gameType: practiceGameType,
          startTime: now,
          createdAt: now,
        ),
      );
      return id;
    });
  }

  /// Returns the id of the current open Rack for [matchId], creating a new Rack
  /// if there is none yet. A Shot can never exist without a Rack (RFC Rule #1),
  /// so callers use this to obtain a real rackId before recording a Shot.
  Future<int> ensureCurrentRack({required int matchId}) async {
    return _db.transaction(() async {
      if (!await _rackRepo.matchExists(matchId)) {
        throw RecordingIntegrityException(
          'Cannot create a Rack: Match $matchId does not exist.',
        );
      }
      final racks = await _rackRepo.getRacksByMatchId(matchId);
      if (racks.isNotEmpty && racks.last.id != null) {
        return racks.last.id!;
      }
      final rackNumber = await _rackRepo.getNextRackNumber(matchId);
      final id = await _rackRepo.createRack(
        Rack(matchId: matchId, rackNumber: rackNumber, result: false),
      );
      return id;
    });
  }

  /// Creates a new Rack for [matchId] carrying its win/lose [result] and returns
  /// the real rack id. Unlike [ensureCurrentRack] (which reuses the open rack
  /// for shot recording), match scoring always appends a fresh rack per game.
  /// The parent Match is validated so no orphan rack is ever written.
  Future<int> ensureCurrentRackForResult({
    required int matchId,
    required bool result,
  }) async {
    return _db.transaction(() async {
      if (!await _rackRepo.matchExists(matchId)) {
        throw RecordingIntegrityException(
          'Cannot create a Rack: Match $matchId does not exist.',
        );
      }
      final rackNumber = await _rackRepo.getNextRackNumber(matchId);
      return _rackRepo.createRack(
        Rack(matchId: matchId, rackNumber: rackNumber, result: result),
      );
    });
  }

  /// Persists a Shot against a validated Rack and returns the real shot id.
  /// Throws [RecordingIntegrityException] rather than writing an orphan when
  /// the parent Rack does not exist (RFC Rules #1 and #4).
  Future<int> recordShot({required int rackId, required Shot shot}) async {
    if (rackId <= 0) {
      throw RecordingIntegrityException(
        'Shot requires a valid rackId (got: $rackId). A Shot cannot exist '
        'without a Rack.',
      );
    }
    return _db.transaction(() async {
      final rack = await _rackRepo.getRackById(rackId);
      if (rack == null) {
        throw RecordingIntegrityException(
          'Cannot record Shot: Rack $rackId does not exist.',
        );
      }
      final shotNumber = await _shotRepo.getNextShotNumber(rackId);
      return _shotRepo
          .createShot(shot.copyWith(rackId: rackId, shotNumber: shotNumber));
    });
  }

  /// Persists an Event against a validated Shot and returns the real event id.
  /// Throws [RecordingIntegrityException] rather than writing an orphan when
  /// the parent Shot does not exist (RFC Rules #2 and #4).
  Future<int> recordEvent({required int shotId, required Event event}) async {
    if (shotId <= 0) {
      throw RecordingIntegrityException(
        'Event requires a valid shotId (got: $shotId). An Event cannot exist '
        'without a Shot.',
      );
    }
    return _db.transaction(() async {
      if (!await _shotRepo.shotExists(shotId)) {
        throw RecordingIntegrityException(
          'Cannot record Event: Shot $shotId does not exist.',
        );
      }
      return _eventRepo.createEvent(event.copyWith(shotId: shotId));
    });
  }

  /// Closes a session and everything under it (RFC Rule #6): finish any open
  /// match, stamp the session finishedAt, and flush — all atomically. Because
  /// every Shot/Event is already persisted the moment it is recorded (RFC Rule
  /// #5), there is no in-memory data to lose here; this simply guarantees the
  /// session and its open match are consistently closed.
  Future<void> finishSession(int sessionId, {DateTime? endedAt}) async {
    final canonicalEnd =
        _lifecyclePolicy.canonicalize(endedAt) ?? _commandNowUtc();
    await _db.transaction(() async {
      final openMatch = await _matchRepo.getActiveMatchBySessionId(sessionId);
      if (openMatch?.id != null) {
        await _finishMatchWithinTransaction(
          openMatch!.id!,
          winner: null,
          startedAt: null,
          endedAt: canonicalEnd,
        );
      }
      await _sessionRepo.finishSession(sessionId);
    });
  }

  /// Repairs legacy state that contains several unfinished sessions. The most
  /// recently started session remains active and every older session is closed
  /// together with its open match.
  Future<void> reconcileOpenSessions() async {
    final endedAt = _commandNowUtc();
    await _db.transaction(() async {
      final openSessions = await _sessionRepo.getOpenSessions();
      for (final stale in openSessions.skip(1)) {
        final sessionId = stale.id;
        if (sessionId == null) continue;
        final openMatch = await _matchRepo.getActiveMatchBySessionId(sessionId);
        if (openMatch?.id != null) {
          await _finishMatchWithinTransaction(
            openMatch!.id!,
            winner: null,
            startedAt: null,
            endedAt: endedAt,
          );
        }
        await _sessionRepo.finishSession(sessionId);
      }
    });
  }

  /// Makes one historical session active without leaving another open session
  /// behind. Used by the Continue action.
  Future<void> activateOnly(int sessionId) async {
    final endedAt = _commandNowUtc();
    await _db.transaction(() async {
      final openSessions = await _sessionRepo.getOpenSessions();
      for (final session in openSessions) {
        if (session.id == null || session.id == sessionId) continue;
        final openMatch =
            await _matchRepo.getActiveMatchBySessionId(session.id!);
        if (openMatch?.id != null) {
          await _finishMatchWithinTransaction(
            openMatch!.id!,
            winner: null,
            startedAt: null,
            endedAt: endedAt,
          );
        }
        await _sessionRepo.finishSession(session.id!);
      }
      await _sessionRepo.reactivateSession(sessionId);
    });
  }

  Future<void> _finishMatchWithinTransaction(
    int matchId, {
    required String? winner,
    required DateTime? startedAt,
    required DateTime endedAt,
  }) async {
    await _matchRepo.finishMatchLifecycle(
      matchId,
      startedAt: startedAt,
      endedAt: endedAt,
    );
    await _matchRepo.updateWinnerMetadata(matchId, winner);
  }

  DateTime _commandNowUtc() =>
      _lifecyclePolicy.canonicalize(_lifecycleClock())!;
}

final recordingCoordinatorProvider = Provider<RecordingCoordinator>((ref) {
  return RecordingCoordinator(
    database: ref.watch(databaseProvider),
    sessionRepo: ref.watch(sessionRepositoryProvider),
    matchRepo: ref.watch(matchRepositoryProvider),
    rackRepo: ref.watch(rackRepositoryProvider),
    shotRepo: ref.watch(shotRepositoryProvider),
    eventRepo: ref.watch(eventRepositoryProvider),
  );
});
