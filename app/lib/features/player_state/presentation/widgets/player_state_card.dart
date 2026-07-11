import 'package:flutter/material.dart';
import 'package:pool_os/features/player_state/domain/player_state_analyzer.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

/// Presents the computed Player State insights (doc §3 warm-up, §4 endurance).
///
/// Follows the doc's analysis rules: it never says "you play badly" and never
/// invents a number. When [warmUp] lacks enough data it shows a neutral
/// "not enough data" message (doc §9); when the player is a clear slow-starter
/// it gives PROCESS advice (warm up more), not a technique drill (doc §7).
class PlayerStateCard extends StatelessWidget {
  final WarmUpInsight? warmUp;
  final EnduranceInsight? endurance;

  const PlayerStateCard({super.key, this.warmUp, this.endurance});

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
                Icon(Icons.insights, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.get('player_state_title'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _warmUpSection(context, l10n),
            if (endurance != null) ...[
              const Divider(height: 20),
              _enduranceSection(context, l10n),
            ],
          ],
        ),
      ),
    );
  }

  Widget _warmUpSection(BuildContext context, AppLocalizations l10n) {
    final w = warmUp;
    if (w == null || !w.hasEnoughData) {
      return _line(
        context,
        Icons.hourglass_empty,
        l10n.get('player_state_warmup'),
        l10n.get('player_state_not_enough_data'),
        Colors.grey,
      );
    }
    // Slow starter → process advice, never a technique drill (doc §7).
    if (w.isSlowStarter) {
      return _line(
        context,
        Icons.local_fire_department,
        l10n.get('player_state_warmup'),
        l10n
            .get('player_state_slow_starter')
            .replaceAll('{racks}', '${w.warmUpRacks}'),
        Colors.orange,
      );
    }
    return _line(
      context,
      Icons.bolt,
      l10n.get('player_state_warmup'),
      l10n.get('player_state_fast_starter'),
      Colors.green,
    );
  }

  Widget _enduranceSection(BuildContext context, AppLocalizations l10n) {
    final e = endurance!;
    if (!e.hasEnoughData) {
      return _line(
        context,
        Icons.battery_unknown,
        l10n.get('player_state_endurance'),
        l10n.get('player_state_not_enough_data'),
        Colors.grey,
      );
    }
    if (e.declines) {
      return _line(
        context,
        Icons.trending_down,
        l10n.get('player_state_endurance'),
        l10n
            .get('player_state_declines')
            .replaceAll('{rack}', '${e.declineRack}'),
        Colors.redAccent,
      );
    }
    return _line(
      context,
      Icons.trending_flat,
      l10n.get('player_state_endurance'),
      l10n.get('player_state_steady'),
      Colors.green,
    );
  }

  Widget _line(BuildContext context, IconData icon, String label, String body,
      Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 2),
              Text(body, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
