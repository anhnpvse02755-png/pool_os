import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/player/data/database/app_database.dart' as db;
import 'package:pool_os/features/player/data/providers/database_providers.dart';
import 'package:pool_os/features/tournament/domain/bracket_generator.dart';
import 'package:pool_os/features/tournament/domain/models/tournament_models.dart';

final tournamentRepositoryProvider = Provider<TournamentRepository>((ref) {
  return TournamentRepository(ref.watch(databaseProvider));
});

/// Task 13 — the only gateway between the Tournament presentation layer and
/// Drift. Maps the three tournament tables to/from the pure domain models,
/// generates brackets, and advances winners. Never touches the LOCKED RFC-301/
/// 302 recording pipeline: it only stores a soft-ref [matchId] pointing at a
/// Match that the existing pipeline recorded elsewhere.
class TournamentRepository {
  final db.AppDatabase _db;

  TournamentRepository(this._db);

  // --- Tournaments (Phần 1) -----------------------------------------------

  Future<List<Tournament>> getTournaments() async {
    final rows = await (_db.select(_db.tournaments)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
    return rows.map(_mapTournament).toList();
  }

  Future<Tournament?> getTournamentById(int id) async {
    final row = await (_db.select(_db.tournaments)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _mapTournament(row);
  }

  Future<int> createTournament(Tournament t) {
    return _db.into(_db.tournaments).insert(
          db.TournamentsCompanion.insert(
            name: t.name,
            type: t.type.code,
            status: Value(t.status.code),
            location: Value(t.location),
            notes: Value(t.notes),
            startDate: Value(t.startDate),
            endDate: Value(t.endDate),
            createdAt: t.createdAt,
          ),
        );
  }

  Future<bool> updateTournament(Tournament t) async {
    final n = await (_db.update(_db.tournaments)
          ..where((row) => row.id.equals(t.id!)))
        .write(
      db.TournamentsCompanion(
        name: Value(t.name),
        type: Value(t.type.code),
        status: Value(t.status.code),
        location: Value(t.location),
        notes: Value(t.notes),
        startDate: Value(t.startDate),
        endDate: Value(t.endDate),
      ),
    );
    return n > 0;
  }

  Future<void> setStatus(int tournamentId, TournamentStatus status) {
    return (_db.update(_db.tournaments)
          ..where((t) => t.id.equals(tournamentId)))
        .write(db.TournamentsCompanion(status: Value(status.code)));
  }

  Future<void> deleteTournament(int id) async {
    // Manual cascade over soft-ref rows (no FKs). The recorded Matches the
    // fixtures pointed at are left completely untouched.
    await (_db.delete(_db.tournamentMatches)
          ..where((t) => t.tournamentId.equals(id)))
        .go();
    await (_db.delete(_db.tournamentParticipants)
          ..where((t) => t.tournamentId.equals(id)))
        .go();
    await (_db.delete(_db.tournaments)..where((t) => t.id.equals(id))).go();
  }

  // --- Participants (Phần 3) ----------------------------------------------

  Future<List<TournamentParticipant>> getParticipants(int tournamentId) async {
    final rows = await (_db.select(_db.tournamentParticipants)
          ..where((t) => t.tournamentId.equals(tournamentId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
    return rows.map(_mapParticipant).toList();
  }

  Future<int> addParticipant(TournamentParticipant p) {
    return _db.into(_db.tournamentParticipants).insert(
          db.TournamentParticipantsCompanion.insert(
            tournamentId: p.tournamentId,
            playerId: Value(p.playerId),
            name: p.name,
            seed: Value(p.seed),
            createdAt: p.createdAt,
          ),
        );
  }

  Future<void> removeParticipant(int id) {
    return (_db.delete(_db.tournamentParticipants)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  Future<void> updateParticipantSeed(int id, int? seed) {
    return (_db.update(_db.tournamentParticipants)
          ..where((t) => t.id.equals(id)))
        .write(db.TournamentParticipantsCompanion(seed: Value(seed)));
  }

  // --- Bracket / matches (Phần 4/5) ---------------------------------------

  Future<List<TournamentMatch>> getMatches(int tournamentId) async {
    final rows = await (_db.select(_db.tournamentMatches)
          ..where((t) => t.tournamentId.equals(tournamentId))
          ..orderBy([
            (t) => OrderingTerm.asc(t.roundIndex),
            (t) => OrderingTerm.asc(t.slotIndex),
          ]))
        .get();
    return rows.map(_mapMatch).toList();
  }

  /// Generate (or regenerate) the bracket from the current participant list.
  /// Clears any existing fixtures first so re-seeding is idempotent — refuses
  /// only if a fixture already has a recorded [matchId] (would orphan real
  /// data). Returns the number of fixtures created.
  Future<int> generateBracket(int tournamentId) async {
    final tournament = await getTournamentById(tournamentId);
    if (tournament == null) return 0;

    final existing = await getMatches(tournamentId);
    if (existing.any((m) => m.matchId != null || m.isResolved)) {
      throw StateError(
          'Bracket already has recorded results; delete them before re-seeding.');
    }

    final participants = await getParticipants(tournamentId);
    if (participants.length < 2) {
      throw StateError('Need at least 2 participants to generate a bracket.');
    }

    await (_db.delete(_db.tournamentMatches)
          ..where((t) => t.tournamentId.equals(tournamentId)))
        .go();

    final layout = BracketGenerator.generate(
      type: tournament.type,
      participants: participants,
      tournamentId: tournamentId,
      now: DateTime.now(),
    );

    await _db.batch((batch) {
      batch.insertAll(
        _db.tournamentMatches,
        layout.matches.map(_toMatchCompanion).toList(),
      );
    });

    // Auto-advance any BYE winners decided at generation time into round 2.
    if (tournament.type == TournamentType.singleElimination ||
        tournament.type == TournamentType.doubleElimination) {
      final saved = await getMatches(tournamentId);
      final roundCount =
          saved.map((m) => m.roundIndex).fold(0, (a, b) => a > b ? a : b) + 1;
      for (final m in saved.where((m) => m.roundIndex == 0 && m.isResolved)) {
        await _propagateWinner(m, roundCount);
      }
    }

    return layout.matches.length;
  }

  /// Record the outcome of one fixture. [winnerParticipantId] must be one of the
  /// fixture's two participants. Optionally attach a recorded [matchId] and the
  /// racks won by each side. Advances the winner into the next round for
  /// elimination formats. Round robin / league just store the result.
  Future<void> recordResult({
    required int fixtureId,
    required int winnerParticipantId,
    int? matchId,
    int? scoreA,
    int? scoreB,
  }) async {
    final row = await (_db.select(_db.tournamentMatches)
          ..where((t) => t.id.equals(fixtureId)))
        .getSingleOrNull();
    if (row == null) return;
    final fixture = _mapMatch(row);

    if (winnerParticipantId != fixture.participantAId &&
        winnerParticipantId != fixture.participantBId) {
      throw ArgumentError('Winner must be one of the fixture participants.');
    }

    await (_db.update(_db.tournamentMatches)
          ..where((t) => t.id.equals(fixtureId)))
        .write(db.TournamentMatchesCompanion(
      winnerParticipantId: Value(winnerParticipantId),
      matchId: Value(matchId),
      scoreA: Value(scoreA),
      scoreB: Value(scoreB),
    ));

    final tournament = await getTournamentById(fixture.tournamentId);
    if (tournament != null &&
        (tournament.type == TournamentType.singleElimination ||
            tournament.type == TournamentType.doubleElimination)) {
      final all = await getMatches(fixture.tournamentId);
      final roundCount =
          all.map((m) => m.roundIndex).fold(0, (a, b) => a > b ? a : b) + 1;
      final resolved = fixture.copyWith(winnerParticipantId: winnerParticipantId);
      await _propagateWinner(resolved, roundCount);
    }
  }

  /// Feed a resolved fixture's winner into its parent slot in the next round.
  Future<void> _propagateWinner(TournamentMatch fixture, int roundCount) async {
    final parent = BracketGenerator.parentSlot(
      roundIndex: fixture.roundIndex,
      slotIndex: fixture.slotIndex,
      roundCount: roundCount,
    );
    if (parent == null) return; // this was the final

    final winnerId = fixture.winnerParticipantId;
    if (winnerId == null) return;

    final parentRow = await (_db.select(_db.tournamentMatches)
          ..where((t) =>
              t.tournamentId.equals(fixture.tournamentId) &
              t.roundIndex.equals(parent.roundIndex) &
              t.slotIndex.equals(parent.slotIndex) &
              t.bracketGroup.equals('M')))
        .getSingleOrNull();
    if (parentRow == null) return;

    await (_db.update(_db.tournamentMatches)
          ..where((t) => t.id.equals(parentRow.id)))
        .write(parent.isSideA
            ? db.TournamentMatchesCompanion(participantAId: Value(winnerId))
            : db.TournamentMatchesCompanion(participantBId: Value(winnerId)));
  }

  // --- Mappers -------------------------------------------------------------

  Tournament _mapTournament(db.Tournament r) => Tournament(
        id: r.id,
        name: r.name,
        type: TournamentType.fromCode(r.type),
        status: TournamentStatus.fromCode(r.status),
        location: r.location,
        notes: r.notes,
        startDate: r.startDate,
        endDate: r.endDate,
        createdAt: r.createdAt,
      );

  TournamentParticipant _mapParticipant(db.TournamentParticipant r) =>
      TournamentParticipant(
        id: r.id,
        tournamentId: r.tournamentId,
        playerId: r.playerId,
        name: r.name,
        seed: r.seed,
        createdAt: r.createdAt,
      );

  TournamentMatch _mapMatch(db.TournamentMatche r) => TournamentMatch(
        id: r.id,
        tournamentId: r.tournamentId,
        roundIndex: r.roundIndex,
        slotIndex: r.slotIndex,
        bracketGroup: r.bracketGroup,
        participantAId: r.participantAId,
        participantBId: r.participantBId,
        winnerParticipantId: r.winnerParticipantId,
        scoreA: r.scoreA,
        scoreB: r.scoreB,
        matchId: r.matchId,
        createdAt: r.createdAt,
      );

  db.TournamentMatchesCompanion _toMatchCompanion(TournamentMatch m) =>
      db.TournamentMatchesCompanion.insert(
        tournamentId: m.tournamentId,
        roundIndex: m.roundIndex,
        slotIndex: m.slotIndex,
        bracketGroup: Value(m.bracketGroup),
        participantAId: Value(m.participantAId),
        participantBId: Value(m.participantBId),
        winnerParticipantId: Value(m.winnerParticipantId),
        scoreA: Value(m.scoreA),
        scoreB: Value(m.scoreB),
        matchId: Value(m.matchId),
        createdAt: m.createdAt,
      );
}
