import 'package:flutter/material.dart';
import 'package:pool_os/features/player_state/domain/models/player_state_log.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

/// State §5 — a quick "how tired are you?" note after a match or session.
/// Four buckets (doc §5): Không mệt / Hơi mệt / Mệt / Rất mệt, stored as the
/// 0-10 fatigueLevel. Mirrors the lightweight-dialog contract: [onPick] owns
/// dismissal; the dialog does not pop itself. Skipping is allowed.
class FatigueCheckDialog extends StatelessWidget {
  /// Called with the chosen 0-10 fatigue level. Owns dismissal.
  final void Function(int fatigueLevel) onPick;

  const FatigueCheckDialog({super.key, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final options = <(int, String, IconData)>[
      (FatigueLevel.none, l10n.get('fatigue_none'), Icons.sentiment_very_satisfied),
      (FatigueLevel.light, l10n.get('fatigue_light'), Icons.sentiment_satisfied),
      (FatigueLevel.tired, l10n.get('fatigue_tired'), Icons.sentiment_neutral),
      (FatigueLevel.exhausted, l10n.get('fatigue_exhausted'), Icons.sentiment_very_dissatisfied),
    ];

    return AlertDialog(
      title: Text(l10n.get('post_match_title')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.get('post_match_subtitle'),
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          for (final opt in options)
            ListTile(
              leading: Icon(opt.$3),
              title: Text(opt.$2),
              // onPick owns dismissal (mirrors RackSummaryDialog) — do not pop here.
              onTap: () => onPick(opt.$1),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.get('skip')),
        ),
      ],
    );
  }
}
