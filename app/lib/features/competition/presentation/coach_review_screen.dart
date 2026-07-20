import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pool_os/features/coach/domain/brain/coach_output.dart';
import 'package:pool_os/features/coach/presentation/coach_action_navigation.dart';
import 'package:pool_os/features/coach/presentation/coach_v2_provider.dart';
import 'package:pool_os/features/competition/application/competition_history_query.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

class CoachReviewScreen extends ConsumerWidget {
  const CoachReviewScreen({super.key});

  static const _competitionTopics = {
    CoachTopic.performance,
    CoachTopic.underPressure,
    CoachTopic.consistency,
    CoachTopic.shotSkill,
    CoachTopic.progress,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final output = ref.watch(coachOutputProvider);
    final history = ref.watch(competitionHistoryProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.get('coach_review'))),
      body: output.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(l10n.get('coach_v2_error'))),
        data: (data) {
          final insights = data.feed
              .where((item) =>
                  item.lifecycle == CoachLifecycle.active &&
                  _competitionTopics.contains(item.topic))
              .toList();
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(coachContextProvider);
              ref.invalidate(coachOutputProvider);
              ref.invalidate(competitionHistoryProvider);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                if (insights.isEmpty)
                  _empty(context, l10n)
                else
                  for (final insight in insights) ...[
                    _insight(context, l10n, insight),
                    const Divider(height: 28),
                  ],
                history.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (items) => items.isEmpty
                      ? const SizedBox.shrink()
                      : OutlinedButton.icon(
                          onPressed: () => context.push(
                            '/session/history/${items.first.session.id}',
                          ),
                          icon: const Icon(Icons.receipt_long_outlined),
                          label: Text(l10n.get('view_latest_summary')),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _empty(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 72),
      child: Column(
        children: [
          Icon(Icons.psychology_outlined,
              size: 48, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 12),
          Text(l10n.get('coach_review_empty'), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _insight(
    BuildContext context,
    AppLocalizations l10n,
    CoachInsightV2 insight,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.get(insight.observationKey),
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        if (insight.causeKey.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(l10n.get(insight.causeKey)),
        ],
        if (insight.evidence.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            insight.evidence,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        if (insight.action != null) ...[
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => navigateCoachAction(context, insight.action!),
            child: Text(l10n.get(insight.action!.labelKey)),
          ),
        ],
      ],
    );
  }
}
