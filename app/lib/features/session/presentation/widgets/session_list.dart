import 'package:flutter/material.dart';
import 'package:pool_os/features/session/domain/models/session.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';
import 'package:pool_os/shared/widgets/app_card.dart';

class SessionList extends StatelessWidget {
  const SessionList({super.key, required this.sessions});

  final List<Session> sessions;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    if (sessions.isEmpty) {
      return AppCard(
        child: Center(
          child: Text(loc.get('empty_state')),
        ),
      );
    }
    return ListView.builder(
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return AppCard(
          child: ListTile(
            title: Text(session.sessionType.toUpperCase()),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (session.trainingGoal != null) Text(session.trainingGoal!),
                if (session.table != null) Text('Table: ${session.table}'),
                Text(_formatDate(session.startedAt)),
              ],
            ),
            trailing: Text(_formatDuration(session.duration)),
            isThreeLine: session.trainingGoal != null || session.table != null,
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }
}
