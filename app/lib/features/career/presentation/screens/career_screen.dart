import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/career/data/repositories/career_repository.dart';
import 'package:pool_os/features/career/domain/models/career_models.dart';
import 'package:pool_os/features/career/domain/timeline_aggregator.dart';
import 'package:pool_os/features/career/presentation/providers/career_providers.dart';
import 'package:pool_os/features/career/presentation/widgets/career_summary_card.dart';
import 'package:pool_os/features/career/presentation/widgets/timeline_event_tile.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

/// Task 11 — Player Timeline & Career screen. A read-only "development journal":
/// a career summary roll-up (Phần 2) followed by the filterable, day-grouped
/// event timeline (Phần 1, 3-7). All data is aggregated from what other features
/// recorded; nothing is written and there is no AI.
class CareerScreen extends ConsumerWidget {
  const CareerScreen({super.key});

  /// Build the localized label bundle the repository needs to render events.
  CareerLabels _labels(AppLocalizations l10n) {
    return CareerLabels(
      resolve: l10n.get,
      matchWin: l10n.get('career_match_win'),
      matchLoss: l10n.get('career_match_loss'),
      race: l10n.get('career_race'),
      equipmentAdded: l10n.get('career_equipment_added'),
      trainingSession: l10n.get('career_training_session'),
      goalCompleted: l10n.get('career_goal_completed'),
      achievementUnlocked: l10n.get('career_achievement_unlocked'),
      sessionTitle: (type) {
        switch (type) {
          case 'practice':
            return l10n.get('career_session_practice');
          case 'match':
            return l10n.get('career_session_match');
          default:
            return l10n.get('career_session_started');
        }
      },
      cueType: (type) => type == 'break'
          ? l10n.get('break_cue')
          : l10n.get('cue'),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final labels = _labels(l10n);
    final summaryAsync = ref.watch(careerSummaryProvider);
    final eventsAsync = ref.watch(timelineEventsProvider(labels));
    final selected = ref.watch(timelineFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.get('career_title')),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(careerSummaryProvider);
          ref.invalidate(timelineEventsProvider);
          await ref.read(timelineEventsProvider(labels).future);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            summaryAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => _error(context, l10n),
              data: (summary) => CareerSummaryCard(summary: summary),
            ),
            const SizedBox(height: 20),
            _buildFilterChips(context, ref, l10n, selected),
            const SizedBox(height: 12),
            eventsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => _error(context, l10n),
              data: (events) => _buildTimeline(context, l10n, events, selected),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    Set<TimelineEventType> selected,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilterChip(
          label: Text(l10n.get('career_filter_all')),
          selected: selected.isEmpty,
          onSelected: (_) =>
              ref.read(timelineFilterProvider.notifier).state = {},
        ),
        ...TimelineEventType.values.map((type) {
          final isSel = selected.contains(type);
          return FilterChip(
            label: Text(l10n.get(type.labelKey)),
            selected: isSel,
            onSelected: (_) {
              final next = Set<TimelineEventType>.from(selected);
              if (isSel) {
                next.remove(type);
              } else {
                next.add(type);
              }
              ref.read(timelineFilterProvider.notifier).state = next;
            },
          );
        }),
      ],
    );
  }

  Widget _buildTimeline(
    BuildContext context,
    AppLocalizations l10n,
    List<TimelineEvent> events,
    Set<TimelineEventType> selected,
  ) {
    final days = TimelineAggregator.filterAndGroup(events, types: selected);
    if (days.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                const Icon(Icons.history, size: 48, color: Colors.grey),
                const SizedBox(height: 8),
                Text(
                  events.isEmpty
                      ? l10n.get('career_empty')
                      : l10n.get('career_no_filtered'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: days.map((day) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                _formatDay(day.day, l10n),
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            ...List.generate(day.events.length, (i) {
              return TimelineEventTile(
                event: day.events[i],
                isFirst: i == 0,
                isLast: i == day.events.length - 1,
              );
            }),
          ],
        );
      }).toList(),
    );
  }

  String _formatDay(DateTime day, AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (day == today) return l10n.get('today');
    if (day == today.subtract(const Duration(days: 1))) {
      return l10n.get('yesterday');
    }
    return '${day.day.toString().padLeft(2, '0')}/'
        '${day.month.toString().padLeft(2, '0')}/${day.year}';
  }

  Widget _error(BuildContext context, AppLocalizations l10n) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error_outline),
            const SizedBox(width: 12),
            Expanded(child: Text(l10n.get('error_loading_data'))),
          ],
        ),
      ),
    );
  }
}
