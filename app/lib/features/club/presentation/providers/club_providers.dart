import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/club/data/repositories/club_repository.dart';
import 'package:pool_os/features/club/domain/club_calculator.dart';
import 'package:pool_os/features/club/domain/models/club_models.dart';

// Task 14 — Club providers. Read paths are FutureProviders (family-keyed by
// club id); write paths go through the controller so the UI can await and
// refresh. No AI, no chat, no online sync.

/// All clubs, newest-first (Phần 1 — list screen).
final clubListProvider = FutureProvider<List<Club>>((ref) async {
  return ref.watch(clubRepositoryProvider).getClubs();
});

/// One club by id.
final clubProvider = FutureProvider.family<Club?, int>((ref, id) async {
  return ref.watch(clubRepositoryProvider).getClubById(id);
});

/// Members of a club (Phần 2).
final clubMembersProvider =
    FutureProvider.family<List<ClubMember>, int>((ref, id) async {
  return ref.watch(clubRepositoryProvider).getMembers(id);
});

/// Internal ranking (Phần 3), derived from the club's linked matches.
final clubRankingProvider =
    FutureProvider.family<List<ClubRankingRow>, int>((ref, id) async {
  final repo = ref.watch(clubRepositoryProvider);
  final members = await repo.getMembers(id);
  final results = await repo.getClubMatchResults(id);
  return ClubCalculator.ranking(members: members, results: results);
});

/// Leaderboard input keyed by (clubId, period) — the UI toggles the period.
class LeaderboardArgs {
  final int clubId;
  final LeaderboardPeriod period;
  const LeaderboardArgs(this.clubId, this.period);

  @override
  bool operator ==(Object other) =>
      other is LeaderboardArgs &&
      other.clubId == clubId &&
      other.period == period;

  @override
  int get hashCode => Object.hash(clubId, period);
}

/// Leaderboard (Phần 8) for a period.
final clubLeaderboardProvider =
    FutureProvider.family<List<ClubRankingRow>, LeaderboardArgs>(
        (ref, args) async {
  final repo = ref.watch(clubRepositoryProvider);
  final members = await repo.getMembers(args.clubId);
  final results = await repo.getClubMatchResults(args.clubId);
  return ClubCalculator.leaderboard(
    members: members,
    results: results,
    period: args.period,
    now: DateTime.now(),
  );
});

/// Club-wide statistics (Phần 7).
final clubStatisticsProvider =
    FutureProvider.family<ClubStatistics, int>((ref, id) async {
  final repo = ref.watch(clubRepositoryProvider);
  final members = await repo.getMembers(id);
  final results = await repo.getClubMatchResults(id);
  final trainingSeconds = await repo.getTrainingSecondsByMember(id);
  return ClubCalculator.statistics(
    members: members,
    results: results,
    trainingSecondsByMember: trainingSeconds,
  );
});

/// Links of a given kind (Phần 4/5/6 — history lists).
class LinksArgs {
  final int clubId;
  final ClubLinkKind kind;
  const LinksArgs(this.clubId, this.kind);

  @override
  bool operator ==(Object other) =>
      other is LinksArgs && other.clubId == clubId && other.kind == kind;

  @override
  int get hashCode => Object.hash(clubId, kind);
}

final clubLinksProvider =
    FutureProvider.family<List<ClubLink>, LinksArgs>((ref, args) async {
  return ref
      .watch(clubRepositoryProvider)
      .getLinks(args.clubId, kind: args.kind);
});

/// Thin controller over the repository that invalidates the read providers
/// after a mutation so every tab reflects the source of truth.
class ClubController {
  final Ref _ref;
  ClubController(this._ref);

  ClubRepository get _repo => _ref.read(clubRepositoryProvider);

  Future<int> create(Club c) async {
    final id = await _repo.createClub(c);
    _ref.invalidate(clubListProvider);
    return id;
  }

  Future<void> update(Club c) async {
    await _repo.updateClub(c);
    _ref.invalidate(clubProvider(c.id!));
    _ref.invalidate(clubListProvider);
  }

  Future<void> delete(int id) async {
    await _repo.deleteClub(id);
    _ref.invalidate(clubListProvider);
  }

  Future<void> addMember(ClubMember m) async {
    await _repo.addMember(m);
    _invalidateFor(m.clubId);
  }

  Future<void> removeMember(int clubId, int memberId) async {
    await _repo.removeMember(memberId);
    _invalidateFor(clubId);
  }

  Future<void> setRole(int clubId, int memberId, ClubRole role) async {
    await _repo.setMemberRole(memberId, role);
    _ref.invalidate(clubMembersProvider(clubId));
  }

  Future<void> confirmInvite(int clubId, int memberId) async {
    await _repo.confirmInvite(memberId);
    _ref.invalidate(clubMembersProvider(clubId));
  }

  Future<void> addLink(ClubLink link) async {
    await _repo.addLink(link);
    _invalidateFor(link.clubId);
  }

  Future<void> removeLink(int clubId, int linkId) async {
    await _repo.removeLink(linkId);
    _invalidateFor(clubId);
  }

  void _invalidateFor(int clubId) {
    _ref.invalidate(clubMembersProvider(clubId));
    _ref.invalidate(clubRankingProvider(clubId));
    _ref.invalidate(clubStatisticsProvider(clubId));
    // Period-keyed and kind-keyed families: invalidate the whole family.
    _ref.invalidate(clubLeaderboardProvider);
    _ref.invalidate(clubLinksProvider);
  }
}

final clubControllerProvider = Provider<ClubController>((ref) {
  return ClubController(ref);
});
