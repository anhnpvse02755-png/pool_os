import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/club/domain/club_calculator.dart';
import 'package:pool_os/features/club/domain/models/club_models.dart';
import 'package:pool_os/features/player/data/database/app_database.dart' as db;
import 'package:pool_os/features/player/data/providers/database_providers.dart';

final clubRepositoryProvider = Provider<ClubRepository>((ref) {
  return ClubRepository(ref.watch(databaseProvider));
});

/// Task 14 — the only gateway between the Club presentation layer and Drift.
/// Maps the three club tables to/from the pure domain models, resolves the
/// club's linked Matches into [ClubMatchResult]s for the ranking calculator,
/// and sums linked training time. Never modifies the LOCKED RFC-301/302
/// recording pipeline, the Task 09 training tables or the Task 13 tournament
/// tables — it only reads them through soft-ref [ClubLink]s.
class ClubRepository {
  final db.AppDatabase _db;

  ClubRepository(this._db);

  // --- Clubs (Phần 1) ------------------------------------------------------

  Future<List<Club>> getClubs() async {
    final rows = await (_db.select(_db.clubs)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
    return rows.map(_mapClub).toList();
  }

  Future<Club?> getClubById(int id) async {
    final row = await (_db.select(_db.clubs)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _mapClub(row);
  }

  Future<int> createClub(Club c) {
    return _db.into(_db.clubs).insert(
          db.ClubsCompanion.insert(
            name: c.name,
            logoPath: Value(c.logoPath),
            location: Value(c.location),
            description: Value(c.description),
            managerName: Value(c.managerName),
            createdAt: c.createdAt,
          ),
        );
  }

  Future<bool> updateClub(Club c) async {
    final n = await (_db.update(_db.clubs)..where((t) => t.id.equals(c.id!)))
        .write(db.ClubsCompanion(
      name: Value(c.name),
      logoPath: Value(c.logoPath),
      location: Value(c.location),
      description: Value(c.description),
      managerName: Value(c.managerName),
    ));
    return n > 0;
  }

  Future<void> deleteClub(int id) async {
    // Manual cascade over soft-ref rows (no FKs). Linked Matches / trainings /
    // tournaments are left completely untouched — only the club and its own
    // rows are removed.
    await (_db.delete(_db.clubLinks)..where((t) => t.clubId.equals(id))).go();
    await (_db.delete(_db.clubMembers)..where((t) => t.clubId.equals(id))).go();
    await (_db.delete(_db.clubs)..where((t) => t.id.equals(id))).go();
  }

  // --- Members (Phần 2) ----------------------------------------------------

  Future<List<ClubMember>> getMembers(int clubId) async {
    final rows = await (_db.select(_db.clubMembers)
          ..where((t) => t.clubId.equals(clubId))
          ..orderBy([(t) => OrderingTerm.asc(t.joinedAt)]))
        .get();
    return rows.map(_mapMember).toList();
  }

  Future<int> addMember(ClubMember m) {
    return _db.into(_db.clubMembers).insert(
          db.ClubMembersCompanion.insert(
            clubId: m.clubId,
            playerId: Value(m.playerId),
            name: m.name,
            role: Value(m.role.code),
            invited: Value(m.invited),
            joinedAt: m.joinedAt,
          ),
        );
  }

  Future<void> removeMember(int id) {
    return (_db.delete(_db.clubMembers)..where((t) => t.id.equals(id))).go();
  }

  Future<void> setMemberRole(int id, ClubRole role) {
    return (_db.update(_db.clubMembers)..where((t) => t.id.equals(id)))
        .write(db.ClubMembersCompanion(role: Value(role.code)));
  }

  Future<void> confirmInvite(int id) {
    return (_db.update(_db.clubMembers)..where((t) => t.id.equals(id)))
        .write(const db.ClubMembersCompanion(invited: Value(false)));
  }

  // --- Links (Phần 4/5/6) --------------------------------------------------

  Future<List<ClubLink>> getLinks(int clubId, {ClubLinkKind? kind}) async {
    final query = _db.select(_db.clubLinks)
      ..where((t) => t.clubId.equals(clubId));
    if (kind != null) {
      query.where((t) => t.kind.equals(kind.code));
    }
    query.orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    final rows = await query.get();
    return rows.map(_mapLink).toList();
  }

  Future<int> addLink(ClubLink link) async {
    // Avoid duplicate links for the same (club, kind, refId).
    final existing = await (_db.select(_db.clubLinks)
          ..where((t) =>
              t.clubId.equals(link.clubId) &
              t.kind.equals(link.kind.code) &
              t.refId.equals(link.refId)))
        .getSingleOrNull();
    if (existing != null) return existing.id;
    return _db.into(_db.clubLinks).insert(
          db.ClubLinksCompanion.insert(
            clubId: link.clubId,
            kind: link.kind.code,
            refId: link.refId,
            createdAt: link.createdAt,
          ),
        );
  }

  Future<void> removeLink(int id) {
    return (_db.delete(_db.clubLinks)..where((t) => t.id.equals(id))).go();
  }

  // --- Derived data for ranking / stats (Phần 3/7/8) -----------------------

  /// Resolve the club's linked Matches into [ClubMatchResult]s the calculator
  /// can rank. A recorded Match stores its opponent as free text and its winner
  /// as a string ('me'/'opponent'/name), so we map the *club member who is the
  /// app's player* against the recorded opponent name where possible. To keep
  /// this honest and non-AI, a member is credited only when their name matches
  /// the match opponent or the match belongs to their linked player via the
  /// session. Racks are counted from the recorded racks table (read-only).
  Future<List<ClubMatchResult>> getClubMatchResults(int clubId) async {
    final links = await getLinks(clubId, kind: ClubLinkKind.match);
    if (links.isEmpty) return const [];
    final members = await getMembers(clubId);

    // Index members by lower-cased name for opponent matching.
    final memberByName = <String, ClubMember>{
      for (final m in members) m.name.toLowerCase(): m,
    };
    // The app's own player is represented by any member whose playerId is set;
    // for a single-player install this is the "me" side of every recorded match.
    final meMember = members.where((m) => m.playerId != null).isNotEmpty
        ? members.firstWhere((m) => m.playerId != null)
        : null;

    final results = <ClubMatchResult>[];
    for (final link in links) {
      final match = await (_db.select(_db.matches)
            ..where((t) => t.id.equals(link.refId)))
          .getSingleOrNull();
      if (match == null) continue; // recorded match was deleted — skip cleanly

      // Count racks won by each side from the read-only racks table.
      final racks = await (_db.select(_db.racks)
            ..where((t) => t.matchId.equals(match.id)))
          .get();
      final meRacks = racks.where((r) => r.result).length;
      final oppRacks = racks.where((r) => !r.result).length;

      final oppName = (match.opponent ?? '').toLowerCase();
      final oppMember = memberByName[oppName];

      // Determine winner member id from the recorded winner string.
      int? winnerMemberId;
      final winner = (match.winner ?? '').toLowerCase();
      if (winner == 'me' || winner == 'player') {
        winnerMemberId = meMember?.id;
      } else if (oppMember != null && winner == oppName) {
        winnerMemberId = oppMember.id;
      } else if (meRacks != oppRacks) {
        // Fall back to rack count when the winner string is not conclusive.
        winnerMemberId = meRacks > oppRacks ? meMember?.id : oppMember?.id;
      }

      results.add(ClubMatchResult(
        matchId: match.id,
        memberAId: meMember?.id,
        memberBId: oppMember?.id,
        winnerMemberId: winnerMemberId,
        racksA: meRacks,
        racksB: oppRacks,
        playedAt: match.createdAt,
      ));
    }
    return results;
  }

  /// Sum training-session seconds per member from the club's linked training
  /// sessions (Task 09 TrainingCenterSessions). Read-only. A session with no
  /// completedAt contributes 0 (not yet finished).
  Future<Map<int, int>> getTrainingSecondsByMember(int clubId) async {
    final links = await getLinks(clubId, kind: ClubLinkKind.training);
    if (links.isEmpty) return const {};
    final result = <int, int>{};
    for (final link in links) {
      final session = await (_db.select(_db.trainingCenterSessions)
            ..where((t) => t.id.equals(link.refId)))
          .getSingleOrNull();
      if (session == null || session.completedAt == null) continue;
      if (session.playerId == null) continue;
      final seconds =
          session.completedAt!.difference(session.startedAt).inSeconds;
      // Map the training session's playerId to the member who wraps that player.
      final members = await getMembers(clubId);
      final member = members
          .where((m) => m.playerId == session.playerId)
          .cast<ClubMember?>()
          .firstWhere((m) => true, orElse: () => null);
      if (member?.id == null) continue;
      result[member!.id!] = (result[member.id!] ?? 0) + (seconds > 0 ? seconds : 0);
    }
    return result;
  }

  // --- Mappers -------------------------------------------------------------

  Club _mapClub(db.Club r) => Club(
        id: r.id,
        name: r.name,
        logoPath: r.logoPath,
        location: r.location,
        description: r.description,
        managerName: r.managerName,
        createdAt: r.createdAt,
      );

  ClubMember _mapMember(db.ClubMember r) => ClubMember(
        id: r.id,
        clubId: r.clubId,
        playerId: r.playerId,
        name: r.name,
        role: ClubRole.fromCode(r.role),
        invited: r.invited,
        joinedAt: r.joinedAt,
      );

  ClubLink _mapLink(db.ClubLink r) => ClubLink(
        id: r.id,
        clubId: r.clubId,
        kind: ClubLinkKind.fromCode(r.kind),
        refId: r.refId,
        createdAt: r.createdAt,
      );
}
