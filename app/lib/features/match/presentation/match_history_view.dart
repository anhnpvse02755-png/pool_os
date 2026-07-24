import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../rack/domain/models/rack.dart';
import '../../session/application/session_match_gateway.dart';
import '../../session/domain/models/session.dart';
import '../domain/models/match.dart';
import 'match_detail_screen.dart';
import 'match_statistics_panel.dart';

class MatchHistoryView extends ConsumerWidget {
  const MatchHistoryView({super.key});

  Future<List<(Match, Session, List<Rack>)>> _load(WidgetRef ref) async {
    final sessions =
        await ref.read(sessionHistoryRepositoryProvider).getAllSessions();
    final matches =
        await ref.read(sessionMatchRepositoryProvider).getAllMatches();
    final completed = matches.where((match) => match.endTime != null).toList()
      ..sort((left, right) => right.endTime!.compareTo(left.endTime!));
    final sessionsById = {
      for (final session in sessions)
        if (session.id != null) session.id!: session,
    };
    final history = <(Match, Session, List<Rack>)>[];
    for (final match in completed) {
      final session = sessionsById[match.sessionId];
      if (session == null) continue;
      final racks = await ref
          .read(sessionRackHistoryRepositoryProvider)
          .getRacksByMatchId(match.id!);
      history.add((match, session, racks));
    }
    return history;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<(Match, Session, List<Rack>)>>(
      future: _load(ref),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        final history = snapshot.data ?? const [];
        if (history.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MatchStatisticsPanel(),
            const SizedBox(height: 24),
            Text(
              'Match history',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...history.map((entry) {
              final (match, session, racks) = entry;
              final playerScore = racks.where((rack) => rack.result).length;
              final opponentScore = racks.length - playerScore;
              final opponent = match.opponent?.trim();
              return Card(
                child: ListTile(
                  key: ValueKey('match-history-${match.id}'),
                  leading: CircleAvatar(
                    child: Text('$playerScore-$opponentScore'),
                  ),
                  title: Text(
                    opponent == null || opponent.isEmpty
                        ? 'Match #${match.matchNumber}'
                        : opponent,
                  ),
                  subtitle: Text(
                    'Session #${session.id} - ${_formatDate(session.startedAt)}\n'
                    '${racks.length} racks - ${match.gameType}',
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MatchDetailScreen(matchId: match.id!),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime value) =>
      '${value.day}/${value.month}/${value.year}';
}
