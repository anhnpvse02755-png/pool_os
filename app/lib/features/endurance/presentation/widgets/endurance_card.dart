import 'package:flutter/material.dart';
import 'package:pool_os/features/endurance/domain/endurance_analyzer.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

/// Task 08 — a glanceable summary of the player's endurance profile.
///
/// Honesty rules (spec): never fabricate. When [profile] lacks enough data it
/// shows only "Chưa đủ dữ liệu để đánh giá". Otherwise it states, in plain
/// language: how well form is held, when it drops, the likely cause, and the
/// race length that suits the player now. A player should understand it in a
/// few seconds — this is not a statistics dump.
class EnduranceCard extends StatelessWidget {
  final EnduranceProfile profile;

  const EnduranceCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.battery_charging_full,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.get('endurance_title'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (!profile.hasEnoughData)
              _line(
                context,
                Icons.hourglass_empty,
                l10n.get('endurance_not_enough_data'),
                Colors.grey,
              )
            else ...[
              _scoreRow(context, l10n),
              const SizedBox(height: 10),
              _declineRow(context, l10n),
              if (profile.declines && profile.cause != DeclineCause.none) ...[
                const SizedBox(height: 10),
                _causeRow(context, l10n),
              ],
              if (profile.recommendedRaceTo != null) ...[
                const SizedBox(height: 10),
                _raceRow(context, l10n),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _scoreRow(BuildContext context, AppLocalizations l10n) {
    final score = profile.enduranceScore.round();
    final color = score >= 75
        ? Colors.green
        : score >= 50
            ? Colors.orange
            : Colors.redAccent;
    return _line(
      context,
      Icons.speed,
      '${l10n.get('endurance_score')}: $score/100',
      color,
    );
  }

  Widget _declineRow(BuildContext context, AppLocalizations l10n) {
    if (!profile.declines) {
      return _line(
        context,
        Icons.trending_flat,
        l10n.get('endurance_steady'),
        Colors.green,
      );
    }
    return _line(
      context,
      Icons.trending_down,
      l10n
          .get('endurance_declines')
          .replaceAll('{rack}', '${profile.averageDeclineRack}'),
      Colors.redAccent,
    );
  }

  Widget _causeRow(BuildContext context, AppLocalizations l10n) {
    final (icon, key) = switch (profile.cause) {
      DeclineCause.technical => (Icons.build, 'endurance_cause_technical'),
      DeclineCause.physical => (Icons.fitness_center, 'endurance_cause_physical'),
      DeclineCause.mixed => (Icons.sync_alt, 'endurance_cause_mixed'),
      _ => (Icons.help_outline, 'endurance_cause_unknown'),
    };
    return _line(context, icon, l10n.get(key), Colors.blueGrey);
  }

  Widget _raceRow(BuildContext context, AppLocalizations l10n) {
    return _line(
      context,
      Icons.emoji_events,
      l10n
          .get('endurance_recommended_race')
          .replaceAll('{race}', '${profile.recommendedRaceTo}'),
      Colors.indigo,
    );
  }

  Widget _line(
      BuildContext context, IconData icon, String body, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(body, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}
