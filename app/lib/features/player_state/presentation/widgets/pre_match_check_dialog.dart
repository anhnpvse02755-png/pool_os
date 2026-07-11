import 'package:flutter/material.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

/// State §2 — a quick "ready to compete NOW?" check shown before entering a
/// match. Distinct from daily Readiness (start-of-day baseline): this captures
/// whether the player has warmed up and has their stroke, right now.
///
/// Deliberately lightweight (doc §2: "không cần quá nhiều câu hỏi") — three
/// 0-10 sliders. Mirrors RackSummaryDialog's contract: the [onSave] callback
/// owns dismissal; the dialog itself does not pop, avoiding the double-pop
/// class of bug. Users may skip entirely (Skip returns without saving).
class PreMatchCheckResult {
  final int readyToCompete;
  final int warmedUp;
  final int handFeel;

  const PreMatchCheckResult({
    required this.readyToCompete,
    required this.warmedUp,
    required this.handFeel,
  });
}

class PreMatchCheckDialog extends StatefulWidget {
  /// Called with the result when the user confirms. Owns dismissal. Null is
  /// never passed — Skip closes the dialog without invoking onSave.
  final void Function(PreMatchCheckResult result) onSave;

  const PreMatchCheckDialog({super.key, required this.onSave});

  @override
  State<PreMatchCheckDialog> createState() => _PreMatchCheckDialogState();
}

class _PreMatchCheckDialogState extends State<PreMatchCheckDialog> {
  double _readyToCompete = 5;
  double _warmedUp = 5;
  double _handFeel = 5;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.get('pre_match_title')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.get('pre_match_subtitle'),
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            _slider(l10n.get('pre_match_ready'), _readyToCompete,
                (v) => setState(() => _readyToCompete = v)),
            _slider(l10n.get('pre_match_warmed_up'), _warmedUp,
                (v) => setState(() => _warmedUp = v)),
            _slider(l10n.get('pre_match_hand_feel'), _handFeel,
                (v) => setState(() => _handFeel = v)),
          ],
        ),
      ),
      actions: [
        TextButton(
          // Skip: close without saving. onSave is not called.
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.get('skip')),
        ),
        FilledButton(
          onPressed: () {
            // onSave owns dismissal (mirrors RackSummaryDialog); do not pop here.
            widget.onSave(PreMatchCheckResult(
              readyToCompete: _readyToCompete.round(),
              warmedUp: _warmedUp.round(),
              handFeel: _handFeel.round(),
            ));
          },
          child: Text(l10n.get('confirm')),
        ),
      ],
    );
  }

  Widget _slider(String label, double value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: Text(label)),
            Text(value.round().toString(),
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(
          value: value,
          min: 0,
          max: 10,
          divisions: 10,
          label: value.round().toString(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
