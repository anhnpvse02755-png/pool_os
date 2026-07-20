import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/match/data/repositories/match_repository.dart';
import 'package:pool_os/features/session/data/repositories/session_repository.dart';
import 'package:pool_os/features/session/domain/models/session.dart';

class CompetitionHistoryItem {
  final Session session;
  final int matchCount;
  final String? opponent;

  const CompetitionHistoryItem({
    required this.session,
    required this.matchCount,
    this.opponent,
  });
}

final competitionHistoryProvider =
    FutureProvider.autoDispose<List<CompetitionHistoryItem>>((ref) async {
  final sessions = await ref.watch(sessionRepositoryProvider).getAllSessions();
  final matchRepository = ref.watch(matchRepositoryProvider);
  final items = <CompetitionHistoryItem>[];
  for (final session in sessions.where((item) =>
      item.finishedAt != null &&
      item.sessionType != SessionTypes.practice &&
      item.sessionType != SessionTypes.training)) {
    final id = session.id;
    if (id == null) continue;
    final matches = await matchRepository.getMatchesBySessionId(id);
    final opponents = matches
        .map((match) => match.opponent?.trim())
        .whereType<String>()
        .where((name) => name.isNotEmpty)
        .toList();
    items.add(CompetitionHistoryItem(
      session: session,
      matchCount: matches.length,
      opponent: opponents.isEmpty ? null : opponents.last,
    ));
  }
  return items;
});
