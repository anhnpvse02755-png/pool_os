// EPIC 05 §2.9 — Reading Progress UI widgets.
//
// PO 2026-07-31 — read-only progress layer. Continue Reading + History
// surfaces the existing in-memory log; UI never mutates Knowledge content.

import 'package:flutter/material.dart';
import 'package:pool_os/features/knowledge/domain/reading_progress.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

/// Continue Reading list. Tapping an entry opens it (caller wires it).
class ContinueReadingList extends StatelessWidget {
  final List<ReadingProgress> items;
  final String Function(ReadingProgress) titleOf;
  final void Function(ReadingProgress) onOpen;

  const ContinueReadingList({
    super.key,
    required this.items,
    required this.titleOf,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          l10n.get('knowledge_no_continue'),
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final p = items[index];
        return ListTile(
          leading: const Icon(Icons.menu_book_outlined),
          title: Text(titleOf(p)),
          subtitle: Text('Started: ${_formatDate(p.startedAt)}'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => onOpen(p),
        );
      },
    );
  }

  String _formatDate(DateTime? d) =>
      d == null ? '—' : d.toIso8601String().split('T').first;
}

/// History list (read = completed). Same shape as Continue Reading but
/// uses the `completedAt` column.
class ReadingHistoryList extends StatelessWidget {
  final List<ReadingProgress> items;
  final String Function(ReadingProgress) titleOf;
  final void Function(ReadingProgress) onOpen;

  const ReadingHistoryList({
    super.key,
    required this.items,
    required this.titleOf,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          l10n.get('knowledge_no_history'),
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final p = items[index];
        return ListTile(
          leading: const Icon(Icons.history),
          title: Text(titleOf(p)),
          subtitle: Text('Read: ${_formatDate(p.completedAt)}'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => onOpen(p),
        );
      },
    );
  }

  String _formatDate(DateTime? d) =>
      d == null ? '—' : d.toIso8601String().split('T').first;
}