import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pool_os/features/session/presentation/session_provider.dart';
import 'package:pool_os/features/session/domain/models/session.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

class CompetitionHubScreen extends ConsumerWidget {
  const CompetitionHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionNotifierProvider).activeSession;
    final hasActiveCompetition = session != null &&
        session.sessionType != SessionTypes.practice &&
        session.sessionType != SessionTypes.training;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.get('competition'))),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(sessionNotifierProvider.notifier).loadSessions(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            _destination(
              context,
              key: const ValueKey('competition.match'),
              icon: Icons.sports_score_outlined,
              label: l10n.get('match'),
              status: hasActiveCompetition ? l10n.get('active') : null,
              onTap: () => context.push('/session/match'),
            ),
            _destination(
              context,
              key: const ValueKey('competition.tournament'),
              icon: Icons.emoji_events_outlined,
              label: l10n.get('tnmt_title'),
              onTap: () => context.push('/tournaments'),
            ),
            _destination(
              context,
              key: const ValueKey('competition.history'),
              icon: Icons.history,
              label: l10n.get('session_history'),
              onTap: () => context.push('/session/history'),
            ),
            _destination(
              context,
              key: const ValueKey('competition.performance'),
              icon: Icons.monitor_heart_outlined,
              label: l10n.get('performance'),
              onTap: () => context.push('/session/performance'),
            ),
            _destination(
              context,
              key: const ValueKey('competition.review'),
              icon: Icons.psychology_outlined,
              label: l10n.get('coach_review'),
              onTap: () => context.push('/session/review'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _destination(
    BuildContext context, {
    required Key key,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    String? status,
  }) {
    return Column(
      children: [
        ListTile(
          key: key,
          minVerticalPadding: 16,
          leading: CircleAvatar(child: Icon(icon)),
          title: Text(label),
          subtitle: status == null ? null : Text(status),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
        const Divider(height: 1, indent: 72),
      ],
    );
  }
}
