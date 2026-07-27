import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/player/data/database/app_database.dart' as db;
import 'package:pool_os/features/match/domain/models/match.dart';
import 'package:pool_os/features/player/data/providers/database_providers.dart';
import 'package:pool_os/features/match/domain/match_identity_compatibility.dart';
import 'package:pool_os/features/match/domain/match_lifecycle_policy.dart';
import 'package:pool_os/features/session/domain/recording_errors.dart';

const _rawMatchIdentitySelect = '''
SELECT id, session_id, match_number, game_type, race_to, opponent, partner,
       team_mode, winner, result, match_objective, notes, start_time, end_time,
       created_at
FROM matches
''';

const _rawMatchLifecycleSelect = '''
SELECT start_time, end_time
FROM matches
WHERE id = ?
''';

final matchRepositoryProvider = Provider<MatchRepository>((ref) {
  return MatchRepository(ref.watch(databaseProvider));
});

class MatchRepository implements MatchIdentityRawSourceReader {
  final db.AppDatabase _db;

  MatchRepository(this._db);

  @override
  Future<MatchIdentityRawSource?> readMatchIdentityRawSource(
    int legacyMatchId,
  ) async {
    final rows = await _readRawRows(
      '$_rawMatchIdentitySelect WHERE id = ?',
      variables: [Variable<int>(legacyMatchId)],
    );
    if (rows.isEmpty) return null;
    if (rows.length != 1) {
      throw const MatchIdentitySourceException(
        MatchIdentitySourceFailureKind.sourceRead,
      );
    }
    return _materializeRawSource(rows.single.data);
  }

  Future<List<QueryRow>> _readRawRows(
    String sql, {
    List<Variable<Object>> variables = const [],
  }) async {
    try {
      return await _db.customSelect(
        sql,
        variables: variables,
        readsFrom: {_db.matches},
      ).get();
    } catch (error) {
      throw MatchIdentitySourceException(
        MatchIdentitySourceFailureKind.database,
        cause: error,
      );
    }
  }

  MatchIdentityRawSource _materializeRawSource(Map<String, Object?> data) {
    try {
      return MatchIdentityRawSource(
        sourceSchemaVersion: _db.schemaVersion,
        legacyMatchId: data['id']! as int,
        legacySessionId: data['session_id'] as int?,
        matchNumber: data['match_number']! as int,
        gameTypeRaw: data['game_type']! as String,
        raceToRaw: data['race_to'] as int?,
        opponentRaw: data['opponent'] as String?,
        partnerRaw: data['partner'] as String?,
        teamModeRaw: data['team_mode'] as String?,
        winnerRaw: data['winner'] as String?,
        resultRaw: data['result'] as String?,
        matchObjectiveRaw: data['match_objective'] as String?,
        notesRaw: data['notes'] as String?,
        startTimeStorageValue: data['start_time'] as int?,
        endTimeStorageValue: data['end_time'] as int?,
        createdAtStorageValue: data['created_at']! as int,
      );
    } catch (error) {
      throw MatchIdentitySourceException(
        MatchIdentitySourceFailureKind.sourceRead,
        cause: error,
      );
    }
  }

  Future<List<Match>> getMatchesBySessionId(int sessionId) async {
    final results = await (_db.select(_db.matches)
          ..where((m) => m.sessionId.equals(sessionId))
          ..orderBy([(m) => OrderingTerm.asc(m.matchNumber)]))
        .get();
    return results.map(_mapToMatch).toList();
  }

  Future<Match?> getMatchById(int id) async {
    final result = await (_db.select(_db.matches)
          ..where((m) => m.id.equals(id)))
        .getSingleOrNull();
    if (result == null) return null;
    return _mapToMatch(result);
  }

  Future<Match?> getActiveMatchBySessionId(int sessionId) async {
    // RFC-301: tolerate >1 open match (getSingleOrNull would throw). The most
    // recently created open match is treated as the active one.
    final result = await (_db.select(_db.matches)
          ..where((m) => m.sessionId.equals(sessionId) & m.endTime.isNull())
          ..orderBy([(m) => OrderingTerm.desc(m.matchNumber)])
          ..limit(1))
        .getSingleOrNull();
    if (result == null) return null;
    return _mapToMatch(result);
  }

  Future<int> createMatch(Match match) async {
    return _db.into(_db.matches).insert(
          db.MatchesCompanion.insert(
            sessionId: match.sessionId,
            matchNumber: match.matchNumber,
            gameType: match.gameType,
            raceTo: Value(match.raceTo),
            opponent: Value(match.opponent),
            partner: Value(match.partner),
            teamMode: Value(match.teamMode),
            winner: Value(match.winner),
            result: Value(match.result),
            startTime: Value(match.startTime),
            endTime: Value(match.endTime),
            matchObjective: Value(match.matchObjective),
            notes: Value(match.notes),
            createdAt: Value(match.createdAt),
          ),
        );
  }

  Future<bool> updateMatch(Match match) async {
    final updatedRows = await (_db.update(_db.matches)
          ..where((m) => m.id.equals(match.id!)))
        .write(
      db.MatchesCompanion(
        sessionId: Value(match.sessionId),
        matchNumber: Value(match.matchNumber),
        gameType: Value(match.gameType),
        raceTo: Value(match.raceTo),
        opponent: Value(match.opponent),
        partner: Value(match.partner),
        teamMode: Value(match.teamMode),
        winner: Value(match.winner),
        result: Value(match.result),
        matchObjective: Value(match.matchObjective),
        notes: Value(match.notes),
      ),
    );
    return updatedRows > 0;
  }

  Future<void> startMatchLifecycle(int id, DateTime? startedAt) async {
    const policy = MatchLifecyclePolicy();
    final canonicalStart = policy.requireStart(startedAt);
    final affected = await _runLifecycleUpdate(
      '''
UPDATE matches
SET start_time = ?
WHERE id = ?
  AND typeof(start_time) = 'null'
  AND typeof(end_time) = 'null'
''',
      variables: [
        Variable<int>(_unixSeconds(canonicalStart)),
        Variable<int>(id),
      ],
    );
    if (affected == 1) return;
    if (affected != 0) {
      throw const MatchLifecycleException(
        MatchLifecycleFailureCode.databaseFailure,
      );
    }
    final source = await _readLifecycleSource(id);
    if (source == null) {
      throw const MatchLifecycleException(
        MatchLifecycleFailureCode.targetNotFound,
      );
    }
    final assessment = policy.assess(source);
    if (!assessment.isValid) {
      throw const MatchLifecycleException(
        MatchLifecycleFailureCode.invalidSourceState,
      );
    }
    if (assessment.state == MatchLifecycleState.completed) {
      throw const MatchLifecycleException(
        MatchLifecycleFailureCode.invalidTransition,
      );
    }
    if (assessment.startTime == canonicalStart) return;
    throw const MatchLifecycleException(
      MatchLifecycleFailureCode.idempotencyConflict,
    );
  }

  Future<void> finishMatchLifecycle(
    int id, {
    required DateTime? startedAt,
    required DateTime? endedAt,
  }) async {
    const policy = MatchLifecyclePolicy();
    final command = policy.requireFinish(
      startTime: startedAt,
      endTime: endedAt,
    );
    final affected = command.startTime == null
        ? await _runLifecycleUpdate(
            '''
UPDATE matches
SET end_time = ?
WHERE id = ?
  AND typeof(start_time) = 'integer'
  AND typeof(end_time) = 'null'
  AND start_time <= ?
''',
            variables: [
              Variable<int>(_unixSeconds(command.endTime)),
              Variable<int>(id),
              Variable<int>(_unixSeconds(command.endTime)),
            ],
          )
        : await _runLifecycleUpdate(
            '''
UPDATE matches
SET start_time = ?, end_time = ?
WHERE id = ?
  AND typeof(start_time) = 'null'
  AND typeof(end_time) = 'null'
''',
            variables: [
              Variable<int>(_unixSeconds(command.startTime!)),
              Variable<int>(_unixSeconds(command.endTime)),
              Variable<int>(id),
            ],
          );
    if (affected == 1) return;
    if (affected != 0) {
      throw const MatchLifecycleException(
        MatchLifecycleFailureCode.databaseFailure,
      );
    }
    final source = await _readLifecycleSource(id);
    if (source == null) {
      throw const MatchLifecycleException(
        MatchLifecycleFailureCode.targetNotFound,
      );
    }
    final assessment = policy.assess(source);
    if (!assessment.isValid) {
      throw const MatchLifecycleException(
        MatchLifecycleFailureCode.invalidSourceState,
      );
    }
    if (assessment.state == MatchLifecycleState.completed) {
      final startMatches = command.startTime == null ||
          assessment.startTime == command.startTime;
      if (startMatches && assessment.endTime == command.endTime) return;
      throw const MatchLifecycleException(
        MatchLifecycleFailureCode.idempotencyConflict,
      );
    }
    if (assessment.startTime == null && command.startTime == null) {
      throw const MatchLifecycleException(
        MatchLifecycleFailureCode.timestampMissing,
      );
    }
    if (assessment.startTime != null && command.startTime != null) {
      throw const MatchLifecycleException(
        MatchLifecycleFailureCode.invalidTransition,
      );
    }
    if (assessment.startTime != null &&
        command.endTime.isBefore(assessment.startTime!)) {
      throw const MatchLifecycleException(
        MatchLifecycleFailureCode.timestampOrderInvalid,
      );
    }
    throw const MatchLifecycleException(
      MatchLifecycleFailureCode.idempotencyConflict,
    );
  }

  Future<void> updateWinnerMetadata(int id, String? winner) async {
    try {
      final affected = await (_db.update(_db.matches)
            ..where((match) => match.id.equals(id)))
          .write(db.MatchesCompanion(winner: Value(winner)));
      if (affected != 1) {
        throw const MatchLifecycleException(
          MatchLifecycleFailureCode.targetNotFound,
        );
      }
    } on MatchLifecycleException {
      rethrow;
    } catch (error) {
      throw MatchLifecycleException(
        MatchLifecycleFailureCode.databaseFailure,
        cause: error,
      );
    }
  }

  Future<int> _runLifecycleUpdate(
    String sql, {
    required List<Variable<Object>> variables,
  }) async {
    try {
      return await _db.customUpdate(
        sql,
        variables: variables,
        updates: {_db.matches},
      );
    } catch (error) {
      throw MatchLifecycleException(
        MatchLifecycleFailureCode.databaseFailure,
        cause: error,
      );
    }
  }

  Future<MatchLifecycleSource?> _readLifecycleSource(int id) async {
    late final List<QueryRow> rows;
    try {
      rows = await _db.customSelect(
        _rawMatchLifecycleSelect,
        variables: [Variable<int>(id)],
        readsFrom: {_db.matches},
      ).get();
    } catch (error) {
      throw MatchLifecycleException(
        MatchLifecycleFailureCode.databaseFailure,
        cause: error,
      );
    }
    if (rows.isEmpty) return null;
    try {
      if (rows.length != 1) throw const FormatException();
      final data = rows.single.data;
      final start = data['start_time'];
      final end = data['end_time'];
      if (start != null && start is! int) throw const FormatException();
      if (end != null && end is! int) throw const FormatException();
      return MatchLifecycleSource(
        startTime: _dateTimeFromStorage(start as int?),
        endTime: _dateTimeFromStorage(end as int?),
      );
    } catch (error) {
      throw MatchLifecycleException(
        MatchLifecycleFailureCode.sourceReadFailure,
        cause: error,
      );
    }
  }

  Future<int> deleteMatch(int id) async {
    return (_db.delete(_db.matches)..where((m) => m.id.equals(id))).go();
  }

  Future<int> getMatchCountBySessionId(int sessionId) async {
    final count = _db.matches.id.count();
    final query = _db.selectOnly(_db.matches)
      ..addColumns([count])
      ..where(_db.matches.sessionId.equals(sessionId));
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  Future<int> getNextMatchNumber(int sessionId) async {
    final count = await getMatchCountBySessionId(sessionId);
    return count + 1;
  }

  // -----------------------------------------------------------------
  // FEATURE_008 — Match Recording Transaction Integrity primitives.
  //
  // Every method below is part of the Session-owned allocation path. They
  // are designed to be called inside the recording coordinator's transaction
  // and they raise [MatchRecordingException] (FEATURE_008 typed failure) on
  // any unexpected state so the coordinator can re-classify per the spec
  // precedence. Direct use outside the coordinator is not supported.
  // -----------------------------------------------------------------

  /// Acquires a write lock on the parent Session row. This must be the very
  /// first SQL statement of any create-Match transaction, before any source
  /// read, so concurrent attempts serialize on the parent row.
  ///
  /// Returns the affected-row count. Caller classifies `0` as
  /// `sessionTargetNotFound`, `>1` as `databaseFailure`.
  Future<int> lockSessionRow(int sessionId) async {
    try {
      return await _db.customUpdate(
        'UPDATE sessions SET updated_at = updated_at WHERE id = ?',
        variables: [Variable<int>(sessionId)],
        updates: {_db.sessions},
      );
    } catch (error) {
      throw MatchRecordingException(
        MatchRecordingFailureCode.databaseFailure,
        cause: error,
      );
    }
  }

  /// Reads the persisted per-Session allocation. Returns `null` when no row
  /// exists yet — caller must treat that as `invalidSourceState`.
  Future<int?> readMatchNumberAllocation(int sessionId) async {
    try {
      final rows = await _db
          .customSelect(
            'SELECT last_allocated FROM match_number_allocations '
            'WHERE session_id = ?',
            variables: [Variable<int>(sessionId)],
          )
          .get();
      if (rows.isEmpty) return null;
      final value = rows.single.data['last_allocated'];
      if (value is! int) return null;
      return value;
    } catch (error) {
      throw MatchRecordingException(
        MatchRecordingFailureCode.sourceReadFailure,
        cause: error,
      );
    }
  }

  /// Idempotent allocation backfill. The v30 migration already seeds every
  /// Session; this is the safety net used at runtime by the coordinator so a
  /// Session created out-of-band still gets a row before CAS.
  Future<void> ensureAllocationExists(int sessionId) async {
    try {
      await _db.customUpdate(
        'INSERT OR IGNORE INTO match_number_allocations '
        '(session_id, last_allocated) VALUES (?, '
        'COALESCE((SELECT MAX(match_number) FROM matches '
        'WHERE session_id = ? AND typeof(match_number) = \'integer\' '
        'AND match_number > 0), 0))',
        variables: [Variable<int>(sessionId), Variable<int>(sessionId)],
        updates: {_db.sessions},
      );
    } catch (error) {
      throw MatchRecordingException(
        MatchRecordingFailureCode.databaseFailure,
        cause: error,
      );
    }
  }

  /// Returns the id of the open Match for [sessionId] if exactly one exists,
  /// otherwise `null`. Used by `RecordingCoordinator.ensurePracticeMatch`
  /// for find-or-create idempotency.
  Future<int?> getOpenMatchIdBySessionId(int sessionId) async {
    try {
      final rows = await _db
          .customSelect(
            'SELECT id FROM matches WHERE session_id = ? AND end_time IS NULL '
            'ORDER BY match_number DESC LIMIT 1',
            variables: [Variable<int>(sessionId)],
          )
          .get();
      if (rows.isEmpty) return null;
      final id = rows.single.data['id'];
      return id is int ? id : null;
    } catch (error) {
      throw MatchRecordingException(
        MatchRecordingFailureCode.sourceReadFailure,
        cause: error,
      );
    }
  }

  /// Conditional advance of the per-Session high-water mark.
  ///
  /// Returns the affected-row count: `1` → success; `0` → caller must re-read
  /// and classify as `allocationConflict` (clean collision or exhausted
  /// signed SQLite integer); `>1` → `databaseFailure`.
  Future<int> casMatchNumberAllocation({
    required int sessionId,
    required int expectedLastAllocated,
    required int candidateLastAllocated,
  }) async {
    try {
      return await _db.customUpdate(
        'UPDATE match_number_allocations SET last_allocated = ? '
        'WHERE session_id = ? AND last_allocated = ? '
        'AND last_allocated < 9223372036854775807',
        variables: [
          Variable<int>(candidateLastAllocated),
          Variable<int>(sessionId),
          Variable<int>(expectedLastAllocated),
        ],
      );
    } catch (error) {
      throw MatchRecordingException(
        MatchRecordingFailureCode.databaseFailure,
        cause: error,
      );
    }
  }

  /// Single-shot read of the Session's Match source state. Used by the
  /// coordinator to fail closed on legacy duplicate / non-positive numbers
  /// and on multiple-open Matches.
  Future<MatchSourceState> readSessionSourceState(int sessionId) async {
    try {
      final rows = await _db
          .customSelect(
            'SELECT match_number, end_time IS NULL AS open '
            'FROM matches WHERE session_id = ?',
            variables: [Variable<int>(sessionId)],
          )
          .get();
      var hasNonPositive = false;
      var hasDuplicate = false;
      final seenNumbers = <int>{};
      var openCount = 0;
      for (final row in rows) {
        final raw = row.data['match_number'];
        final isOpen = (row.data['open'] as int? ?? 0) != 0;
        if (raw is! int || raw <= 0) {
          hasNonPositive = true;
        } else {
          if (!seenNumbers.add(raw)) {
            hasDuplicate = true;
          }
        }
        if (isOpen) openCount += 1;
      }
      return MatchSourceState(
        hasNonPositive: hasNonPositive,
        hasDuplicate: hasDuplicate,
        openCount: openCount,
      );
    } catch (error) {
      throw MatchRecordingException(
        MatchRecordingFailureCode.sourceReadFailure,
        cause: error,
      );
    }
  }

  /// Conditional insert of a new Match row. The (session_id, match_number)
  /// pair must not already exist; the v30 triggers enforce this even on
  /// direct writes outside the coordinator.
  ///
  /// Returns the inserted row id on success; `0` → caller re-reads and
  /// classifies (open-match-exists wins before allocation-conflict);
  /// `>1` is treated as `databaseFailure`.
  ///
  /// Nullable columns are encoded using the SQLite `NULL` token built from
  /// a single placeholder list. Empty strings are stored as `NULL` for
  /// caller-supplied optional metadata to keep the wire format stable.
  Future<int> insertMatchConditionally({
    required int sessionId,
    required int matchNumber,
    required String gameType,
    int? raceTo,
    String? opponent,
    String? partner,
    String? teamMode,
    String? matchObjective,
    String? notes,
    required DateTime startTime,
    required DateTime createdAt,
  }) async {
    try {
      final raceToSql = raceTo == null ? 'NULL' : '?';
      final opponentSql = opponent == null || opponent.isEmpty ? 'NULL' : '?';
      final partnerSql = partner == null || partner.isEmpty ? 'NULL' : '?';
      final teamModeSql = teamMode == null || teamMode.isEmpty ? 'NULL' : '?';
      final objectiveSql =
          matchObjective == null || matchObjective.isEmpty ? 'NULL' : '?';
      final notesSql = notes == null || notes.isEmpty ? 'NULL' : '?';

      final sql = 'INSERT INTO matches '
          '(session_id, match_number, game_type, race_to, opponent, partner, '
          'team_mode, match_objective, notes, start_time, end_time, created_at) '
          'SELECT ?, ?, ?, $raceToSql, $opponentSql, $partnerSql, '
          '$teamModeSql, $objectiveSql, $notesSql, ?, NULL, ? '
          'WHERE NOT EXISTS (SELECT 1 FROM matches '
          'WHERE session_id = ? AND match_number = ?)';

      final variables = <Variable<Object>>[
        Variable<int>(sessionId),
        Variable<int>(matchNumber),
        Variable<String>(gameType),
        if (raceTo != null) Variable<int>(raceTo),
        if (opponent != null && opponent.isNotEmpty)
          Variable<String>(opponent),
        if (partner != null && partner.isNotEmpty) Variable<String>(partner),
        if (teamMode != null && teamMode.isNotEmpty)
          Variable<String>(teamMode),
        if (matchObjective != null && matchObjective.isNotEmpty)
          Variable<String>(matchObjective),
        if (notes != null && notes.isNotEmpty) Variable<String>(notes),
        Variable<int>(_unixSeconds(startTime)),
        Variable<int>(_unixSeconds(createdAt)),
        Variable<int>(sessionId),
        Variable<int>(matchNumber),
      ];

      final id = await _db.customInsert(
        sql,
        variables: variables,
        updates: {_db.matches},
      );
      return id;
    } catch (error) {
      throw MatchRecordingException(
        MatchRecordingFailureCode.databaseFailure,
        cause: error,
      );
    }
  }

  Future<List<Match>> getAllMatches() async {
    final results = await (_db.select(_db.matches)
          ..orderBy([(m) => OrderingTerm.desc(m.startTime)]))
        .get();
    return results.map(_mapToMatch).toList();
  }

  Future<List<Match>> getRecentMatches({int limit = 10}) async {
    final results = await (_db.select(_db.matches)
          ..orderBy([(m) => OrderingTerm.desc(m.startTime)])
          ..limit(limit))
        .get();
    return results.map(_mapToMatch).toList();
  }

  Match _mapToMatch(db.Matche data) {
    return Match(
      id: data.id,
      sessionId: data.sessionId,
      matchNumber: data.matchNumber,
      gameType: data.gameType,
      raceTo: data.raceTo,
      opponent: data.opponent,
      partner: data.partner,
      teamMode: data.teamMode,
      winner: data.winner,
      result: data.result,
      startTime: data.startTime,
      endTime: data.endTime,
      matchObjective: data.matchObjective,
      notes: data.notes,
      createdAt: data.createdAt,
    );
  }
}

int _unixSeconds(DateTime value) =>
    value.toUtc().millisecondsSinceEpoch ~/ 1000;

DateTime? _dateTimeFromStorage(int? value) => value == null
    ? null
    : DateTime.fromMillisecondsSinceEpoch(value * 1000, isUtc: true);

/// FEATURE_008 — summary of the per-Session Match source state. The
/// coordinator fails closed on any non-positive or duplicate `(session_id,
/// match_number)` pair and on any Session that has more than one open Match.
class MatchSourceState {
  const MatchSourceState({
    required this.hasNonPositive,
    required this.hasDuplicate,
    required this.openCount,
  });

  final bool hasNonPositive;
  final bool hasDuplicate;
  final int openCount;
}
