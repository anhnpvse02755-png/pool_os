import 'package:flutter/material.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';
import 'package:pool_os/shared/widgets/app_card.dart';

class SessionSummaryCard extends StatelessWidget {
  const SessionSummaryCard({
    super.key,
    required this.rackCount,
    required this.winCount,
    required this.duration,
  });

  final int rackCount;
  final int winCount;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final winRate = rackCount == 0 ? 0.0 : winCount / rackCount;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(loc.get('session_summary'), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${loc.get('rack_count')}: $rackCount'),
              Text('${loc.get('session_duration')}: ${duration.inMinutes} min'),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: winRate),
          const SizedBox(height: 8),
          Text('${loc.get('rack_win')}: $winCount (${(winRate * 100).toStringAsFixed(0)}%)'),
        ],
      ),
    );
  }
}
