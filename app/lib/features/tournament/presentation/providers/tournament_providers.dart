import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/tournament/data/repositories/tournament_repository.dart';
import 'package:pool_os/features/tournament/domain/models/tournament_models.dart';
import 'package:pool_os/features/tournament/domain/ranking.dart';
import 'package:pool_os/features/tournament/domain/standing_calculator.dart';

// Task 13 — Tournament providers. Read paths are FutureProviders (family-keyed
// by tournament id where relevant); write paths go through the controller so
// the UI can await and refresh. No AI, no Coach.

/// All tournaments, newest-first (Phần 1 — list screen).
final tournamentListProvider = FutureProvider<List<Tournament>>((ref) async {
  return ref.watch(tournamentRepositoryProvider).getTournaments();
});

/// One tournament by id.
final tournamentProvider =
    FutureProvider.family<Tournament?, int>((ref, id) async {
  return ref.watch(tournamentRepositoryProvider).getTournamentById(id);
});

/// Participants for a tournament (Phần 3).
final participantsProvider =
    FutureProvider.family<List<TournamentParticipant>, int>((ref, id) async {
  return ref.watch(tournamentRepositoryProvider).getParticipants(id);
});

/// Fixtures/bracket for a tournament (Phần 4/5), ordered by round then slot.
final matchesProvider =
    FutureProvider.family<List<TournamentMatch>, int>((ref, id) async {
  return ref.watch(tournamentRepositoryProvider).getMatches(id);
});

/// Standings table (Phần 6), derived from participants + resolved fixtures.
final standingsProvider =
    FutureProvider.family<List<StandingRow>, int>((ref, id) async {
  final repo = ref.watch(tournamentRepositoryProvider);
  final participants = await repo.getParticipants(id);
  final matches = await repo.getMatches(id);
  return StandingCalculator.standings(
    participants: participants,
    matches: matches,
  );
});

/// EPIC 04 Phase 2.2 — Cross-tournament ranking (read-only). Aggregates
/// resolved fixtures across ALL completed-or-active tournaments to rank
/// individual participants by total wins. Teams excluded — PO 2026-07-31.
/// Renamed to [tournamentRankingProvider] (PO 2026-07-31) for namespace
/// safety vs future GlobalRanking / PlayerRating / LeagueRanking.
final tournamentRankingProvider =
    FutureProvider<List<TournamentRankingEntry>>((ref) async {
  final repo = ref.watch(tournamentRepositoryProvider);
  final tournaments = await repo.getTournaments();
  final allMatches = <TournamentMatch>[];
  final namesById = <int, String>{};
  for (final t in tournaments) {
    if (t.id == null) continue;
    if (t.competitionMode != TournamentCompetitionMode.individual) continue;
    final participants = await repo.getParticipants(t.id!);
    for (final p in participants) {
      if (p.id != null) namesById[p.id!] = p.name;
    }
    final matches = await repo.getMatches(t.id!);
    allMatches.addAll(matches);
  }
  return TournamentRankingCalculator.ranking(
    matches: allMatches,
    participantNameById: namesById,
  );
});

/// History (Phần 8): completed tournaments the player has played, with final
/// placement / champion flag when derivable. Kept simple — one entry per
/// tournament that has any resolved fixture.
final tournamentHistoryProvider =
    FutureProvider<List<TournamentHistoryEntry>>((ref) async {
  final repo = ref.watch(tournamentRepositoryProvider);
  final tournaments = await repo.getTournaments();
  final entries = <TournamentHistoryEntry>[];
  for (final t in tournaments) {
    if (t.id == null) continue;
    final participants = await repo.getParticipants(t.id!);
    final matches = await repo.getMatches(t.id!);
    if (matches.every((m) => !m.isResolved)) continue; // nothing played yet
    final championId = StandingCalculator.championId(matches);
    int? placement;
    if (t.type == TournamentType.roundRobin ||
        t.type == TournamentType.league) {
      final standings = StandingCalculator.standings(
        participants: participants,
        matches: matches,
      );
      // Placement is only meaningful for the field as a whole; expose the
      // leader's rank (1) so the UI can show "Vô địch" for round-robin winners.
      if (standings.isNotEmpty) placement = 1;
    }
    entries.add(TournamentHistoryEntry(
      tournament: t,
      participantCount: participants.length,
      placement: championId != null ? 1 : placement,
      isChampion: championId != null,
    ));
  }
  return entries;
});

/// Thin controller over the repository that invalidates the read providers
/// after a mutation so every tab reflects the source of truth.
class TournamentController {
  final Ref _ref;
  TournamentController(this._ref);

  TournamentRepository get _repo => _ref.read(tournamentRepositoryProvider);

  Future<int> create(Tournament t) async {
    final id = await _repo.createTournament(t);
    _ref.invalidate(tournamentListProvider);
    return id;
  }

  Future<void> update(Tournament t) async {
    await _repo.updateTournament(t);
    _invalidateFor(t.id!);
  }

  Future<void> setStatus(int id, TournamentStatus status) async {
    await _repo.setStatus(id, status);
    _invalidateFor(id);
  }

  Future<void> delete(int id) async {
    await _repo.deleteTournament(id);
    _ref.invalidate(tournamentListProvider);
    _ref.invalidate(tournamentHistoryProvider);
  }

  Future<int> addParticipant(TournamentParticipant p) async {
    final id = await _repo.addParticipant(p);
    _ref.invalidate(participantsProvider(p.tournamentId));
    return id;
  }

  Future<void> removeParticipant(int tournamentId, int participantId) async {
    await _repo.removeParticipant(participantId);
    _ref.invalidate(participantsProvider(tournamentId));
  }

  Future<void> updateSeed(int tournamentId, int participantId, int? seed) async {
    await _repo.updateParticipantSeed(participantId, seed);
    _ref.invalidate(participantsProvider(tournamentId));
  }

  /// Generate the bracket from the current participants. Returns fixture count.
  Future<int> generateBracket(int tournamentId) async {
    final n = await _repo.generateBracket(tournamentId);
    _invalidateFor(tournamentId);
    return n;
  }

  Future<void> recordResult({
    required int tournamentId,
    required int fixtureId,
    required int winnerParticipantId,
    int? matchId,
    int? scoreA,
    int? scoreB,
  }) async {
    await _repo.recordResult(
      fixtureId: fixtureId,
      winnerParticipantId: winnerParticipantId,
      matchId: matchId,
      scoreA: scoreA,
      scoreB: scoreB,
    );
    _invalidateFor(tournamentId);
  }

  void _invalidateFor(int tournamentId) {
    _ref.invalidate(tournamentProvider(tournamentId));
    _ref.invalidate(participantsProvider(tournamentId));
    _ref.invalidate(matchesProvider(tournamentId));
    _ref.invalidate(standingsProvider(tournamentId));
    _ref.invalidate(tournamentListProvider);
    _ref.invalidate(tournamentHistoryProvider);
  }
}

final tournamentControllerProvider = Provider<TournamentController>((ref) {
  return TournamentController(ref);
});
