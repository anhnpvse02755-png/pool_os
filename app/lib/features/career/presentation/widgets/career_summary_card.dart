import 'package:flutter/material.dart';
import 'package:pool_os/features/career/domain/models/career_models.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

/// Task 11 — the Career Summary roll-up (Phần 2). A read-only grid of the whole
/// journey: since-date, matches, racks, shots, hours, goals, achievements,
/// equipment. Pure display from [CareerSummary]; zeros when there is no history.
class CareerSummaryCard extends StatelessWidget {
  final CareerSummary summary;

  const CareerSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();

    final stats = <(IconData, String, String, Color)>[
      (
        Icons.calendar_today,
        summary.startedAt == null
            ? '—'
            : '${summary.daysSinceStart(now)} ${l10n.get('career_days')}',
        l10n.get('career_since'),
        Colors.blueGrey,
      ),
      (
        Icons.emoji_events,
        '${summary.matchesWon}/${summary.totalMatches}',
        l10n.get('career_matches_won'),
        Colors.orange,
      ),
      (
        Icons.grid_on,
        '${summary.totalRacks}',
        l10n.get('gc_metric_total_racks'),
        Colors.green,
      ),
      (
        Icons.sports_cricket,
        '${summary.totalShots}',
        l10n.get('gc_metric_total_shots'),
        Colors.blue,
      ),
      (
        Icons.timer,
        '${summary.totalHours.toStringAsFixed(1)}h',
        l10n.get('gc_metric_practice_hours'),
        Colors.teal,
      ),
      (
        Icons.flag,
        '${summary.goalsCompleted}',
        l10n.get('career_goals_done'),
        Colors.indigo,
      ),
      (
        Icons.military_tech,
        '${summary.achievementsUnlocked}',
        l10n.get('gc_section_achievements'),
        Colors.amber,
      ),
      (
        Icons.sports_esports,
        '${summary.equipmentUsed}',
        l10n.get('career_equipment_used'),
        Colors.deepPurple,
      ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insights,
                    size: 20, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.get('career_summary_title'),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.6,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: stats.map((s) {
                return Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: s.$4.withAlpha(30),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(s.$1, color: s.$4, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            s.$2,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            s.$3,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
