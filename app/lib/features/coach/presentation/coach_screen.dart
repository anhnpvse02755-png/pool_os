import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/coach/application/coach_conversation_service.dart';
import 'package:pool_os/features/coach/domain/brain/coach_output.dart';
import 'package:pool_os/features/coach/domain/context/coach_context.dart'
    show TrajectoryDirection;
import 'package:pool_os/features/coach/presentation/coach_action_navigation.dart';
import 'package:pool_os/features/coach/presentation/coach_conversation_provider.dart';
import 'package:pool_os/features/coach/presentation/coach_v2_provider.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

/// Task 15 — Coach Intelligence V2 screen: a single guided feed. Coach is the
/// center of Pool OS — this screen answers "what level am I / where am I weak /
/// why / what next" and routes the player to the right existing screen. The old
/// 3-tab layout is replaced by one scrollable feed (fewest taps). All content
/// comes from CoachBrain via coachOutputProvider; this widget only renders and
/// navigates — it makes no coaching decisions.
class CoachScreen extends ConsumerWidget {
  const CoachScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final outputAsync = ref.watch(coachOutputProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.get('coach')), centerTitle: true),
      body: outputAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.get('coach_v2_error'))),
        data: (output) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(coachContextProvider),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _playerLevelCard(context, l10n, output.level),
              const SizedBox(height: 12),
              _understandingMeter(context, l10n, output.understanding),
              const SizedBox(height: 16),
              _conversationPanel(context, ref, l10n, output),
              const SizedBox(height: 16),
              if (output.primaryAction != null)
                _primaryActionCard(context, ref, l10n, output.primaryAction!),
              const SizedBox(height: 16),
              ..._feedCards(context, ref, l10n, output),
            ],
          ),
        ),
      ),
    );
  }

  Widget _conversationPanel(BuildContext context, WidgetRef ref,
      AppLocalizations l10n, CoachOutput output) {
    final conversation = ref.watch(coachConversationProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.forum_outlined, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.get('ask'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (conversation.turns.isNotEmpty)
                  IconButton(
                    tooltip: l10n.get('delete_conversation'),
                    onPressed: conversation.isSubmitting
                        ? null
                        : ref.read(coachConversationProvider.notifier).clear,
                    icon: const Icon(Icons.delete_outline),
                  ),
              ],
            ),
            if (conversation.turns.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  l10n.get('no_messages'),
                  style: const TextStyle(color: Colors.grey),
                ),
              )
            else
              ...conversation.turns.map(
                (turn) => _conversationTurn(context, l10n, turn),
              ),
            if (conversation.errorCode != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l10n.get('coach_v2_error'),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _intentButton(
                  ref,
                  output,
                  conversation.isSubmitting,
                  CoachConversationIntent.nextAction,
                  Icons.flag_outlined,
                  l10n.get('coach_v2_do_next'),
                ),
                _intentButton(
                  ref,
                  output,
                  conversation.isSubmitting,
                  CoachConversationIntent.playerLevel,
                  Icons.emoji_events_outlined,
                  l10n.get('coach_v2_your_level'),
                ),
                _intentButton(
                  ref,
                  output,
                  conversation.isSubmitting,
                  CoachConversationIntent.dataCoverage,
                  Icons.data_usage_outlined,
                  l10n.get('coach_v2_understanding'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _intentButton(
    WidgetRef ref,
    CoachOutput output,
    bool disabled,
    CoachConversationIntent intent,
    IconData icon,
    String label,
  ) {
    return OutlinedButton.icon(
      onPressed: disabled
          ? null
          : () =>
              ref.read(coachConversationProvider.notifier).ask(intent, output),
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }

  Widget _conversationTurn(
      BuildContext context, AppLocalizations l10n, CoachConversationTurn turn) {
    final answer = <String>[
      l10n.get(turn.responseKey),
      if (turn.metric != null) turn.metric!,
    ].join(' ');
    return Padding(
      key: ValueKey('coach.conversation.turn.${turn.sequence}'),
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Text(l10n.get(turn.promptKey)),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(answer),
                    if (turn.detailKey != null)
                      Text(
                        l10n.get(turn.detailKey!),
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    if (turn.evidence != null)
                      Text(
                        turn.evidence!,
                        style: const TextStyle(fontSize: 12),
                      ),
                    if (turn.actionLabelKey != null && turn.knowledgeId != null)
                      TextButton.icon(
                        onPressed: () => navigateCoachAction(
                          context,
                          CoachAction(
                            labelKey: turn.actionLabelKey!,
                            knowledgeId: turn.knowledgeId!,
                          ),
                        ),
                        icon: const Icon(Icons.arrow_forward, size: 16),
                        label: Text(l10n.get(turn.actionLabelKey!)),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Player Level (how good the player is — SEPARATE from understanding) ---
  Widget _playerLevelCard(
      BuildContext context, AppLocalizations l10n, PlayerLevel level) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.emoji_events, size: 36, color: Colors.deepPurple),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.get('coach_v2_your_level'),
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  Row(
                    children: [
                      Text(l10n.get(level.levelKey),
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      _trajectoryIcon(level.trajectory),
                    ],
                  ),
                  if (level.isProvisional)
                    Text(l10n.get('coach_v2_provisional'),
                        style: const TextStyle(
                            color: Colors.orange, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _trajectoryIcon(TrajectoryDirection dir) {
    switch (dir) {
      case TrajectoryDirection.improving:
        return const Icon(Icons.trending_up, color: Colors.green, size: 20);
      case TrajectoryDirection.declining:
        return const Icon(Icons.trending_down, color: Colors.red, size: 20);
      case TrajectoryDirection.stable:
        return const Icon(Icons.trending_flat,
            color: Colors.blueGrey, size: 20);
      case TrajectoryDirection.unknown:
        return const SizedBox.shrink();
    }
  }

  // --- Coach Understanding (how complete the data is — SEPARATE from level) --
  Widget _understandingMeter(BuildContext context, AppLocalizations l10n,
      CoachUnderstanding understanding) {
    final pct = (understanding.dataCompleteness * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.data_usage, size: 14, color: Colors.grey),
            const SizedBox(width: 6),
            Text('${l10n.get('coach_v2_understanding')}: $pct%',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: understanding.dataCompleteness,
            minHeight: 6,
            backgroundColor: Colors.grey.withValues(alpha: 0.2),
          ),
        ),
      ],
    );
  }

  // --- The single hero Next Action ------------------------------------------
  Widget _primaryActionCard(BuildContext context, WidgetRef ref,
      AppLocalizations l10n, CoachAction action) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.flag, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.get('coach_v2_do_next'),
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(l10n.get(action.labelKey),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            FilledButton(
              onPressed: () => navigateCoachAction(context, action),
              child: Text(l10n.get('coach_v2_go')),
            ),
          ],
        ),
      ),
    );
  }

  // --- Feed cards (skip the primary action's insight to avoid duplication) ---
  List<Widget> _feedCards(BuildContext context, WidgetRef ref,
      AppLocalizations l10n, CoachOutput output) {
    final cards = <Widget>[];
    for (final insight in output.feed) {
      if (insight.lifecycle == CoachLifecycle.resolved) continue;
      cards.add(_insightCard(context, ref, l10n, insight));
      cards.add(const SizedBox(height: 10));
    }
    if (cards.isEmpty) {
      cards.add(Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Text(l10n.get('coach_v2_all_clear'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey)),
      ));
    }
    return cards;
  }

  Widget _insightCard(BuildContext context, WidgetRef ref,
      AppLocalizations l10n, CoachInsightV2 insight) {
    final color =
        insight.isPositive ? Colors.green : _priorityColor(insight.priority);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(insight.isPositive ? Icons.celebration : Icons.insights,
                    size: 18, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(l10n.get(insight.observationKey),
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                ),
                _confidenceChip(l10n, insight.confidence),
              ],
            ),
            if (insight.causeKey.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(l10n.get(insight.causeKey),
                  style: const TextStyle(fontSize: 13, color: Colors.grey)),
            ],
            if (insight.evidence.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.bar_chart, size: 14, color: Colors.blueGrey),
                  const SizedBox(width: 4),
                  Text(insight.evidence,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ],
            if (insight.action != null) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  onPressed: () =>
                      navigateCoachAction(context, insight.action!),
                  child: Text(l10n.get(insight.action!.labelKey)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _confidenceChip(AppLocalizations l10n, CoachConfidence confidence) {
    final (label, color) = switch (confidence) {
      CoachConfidence.high => (l10n.get('coach_v2_conf_high'), Colors.green),
      CoachConfidence.medium => (l10n.get('coach_v2_conf_medium'), Colors.blue),
      CoachConfidence.low => (l10n.get('coach_v2_conf_low'), Colors.orange),
      CoachConfidence.insufficient => (
          l10n.get('coach_v2_conf_insufficient'),
          Colors.grey
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label, style: TextStyle(fontSize: 10, color: color)),
    );
  }

  Color _priorityColor(CoachPriority priority) {
    switch (priority) {
      case CoachPriority.critical:
        return Colors.red;
      case CoachPriority.improve:
        return Colors.orange;
      case CoachPriority.missingData:
        return Colors.blue;
      case CoachPriority.knowledge:
        return Colors.teal;
      case CoachPriority.celebrate:
        return Colors.green;
    }
  }
}
