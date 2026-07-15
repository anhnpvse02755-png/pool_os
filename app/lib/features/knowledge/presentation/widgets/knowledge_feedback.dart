import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pool_os/features/knowledge/domain/models/knowledge_item.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

/// RFC-KB-002 — community feedback for a knowledge article. No backend: each
/// action copies a structured, prefilled template to the clipboard and tells the
/// user where to paste it (email / Google Form / GitHub). Real mailto/URL
/// launching is deferred until the Knowledge backend/CMS exists (frozen
/// decision — no new dependency in Release 1.x).
class KnowledgeFeedback extends StatelessWidget {
  final KnowledgeItem item;
  const KnowledgeFeedback({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.get('kb_feedback_q'),
            style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _btn(context, l10n, Icons.thumb_up_outlined,
                l10n.get('kb_feedback_helpful'), 'helpful'),
            _btn(context, l10n, Icons.thumb_down_outlined,
                l10n.get('kb_feedback_not_helpful'), 'not_helpful'),
            _btn(context, l10n, Icons.edit_outlined,
                l10n.get('kb_feedback_suggest'), 'suggest'),
            _btn(context, l10n, Icons.flag_outlined,
                l10n.get('kb_feedback_report'), 'report'),
          ],
        ),
      ],
    );
  }

  Widget _btn(BuildContext context, AppLocalizations l10n, IconData icon,
      String label, String kind) {
    return OutlinedButton.icon(
      icon: Icon(icon, size: 16),
      label: Text(label),
      onPressed: () => _copyTemplate(context, l10n, kind),
    );
  }

  Future<void> _copyTemplate(
      BuildContext context, AppLocalizations l10n, String kind) async {
    // A structured, paste-anywhere template. Keeps the article id + version so
    // feedback is traceable to the exact content the user saw.
    final template = [
      '[Pool OS Knowledge Feedback]',
      'type: $kind',
      'id: ${item.id}',
      'title: ${item.titleVi}',
      'knowledgeVersion: ${item.knowledgeVersion}',
      'status: ${item.status.code}',
      '',
      '${l10n.get('kb_feedback_your_note')}:',
      '',
    ].join('\n');
    await Clipboard.setData(ClipboardData(text: template));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.get('kb_feedback_copied'))),
    );
  }
}
