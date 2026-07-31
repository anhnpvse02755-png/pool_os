// EPIC 05 §2.8 — Unified Bookmark List UI.
//
// Pure presentation. Bookmark rows aggregate Knowledge / Article / Video /
// Pattern; tap navigates back to the source. Filtering and persistence
// happen in the service layer that backs this widget.

import 'package:flutter/material.dart';
import 'package:pool_os/features/knowledge/domain/bookmark.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

class UnifiedBookmarkList extends StatelessWidget {
  final BookmarkList bookmarks;
  final void Function(Bookmark) onOpen;

  const UnifiedBookmarkList({
    super.key,
    required this.bookmarks,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (bookmarks.all.isEmpty) {
      return Center(child: Text(l10n.get('knowledge_no_bookmarks')));
    }
    return ListView.separated(
      itemCount: bookmarks.all.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final b = bookmarks.all[index];
        return ListTile(
          leading: Icon(_iconFor(b.kind)),
          title: Text(b.displayTitle),
          subtitle: Text(_labelFor(b.kind)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => onOpen(b),
        );
      },
    );
  }

  IconData _iconFor(BookmarkKind kind) {
    switch (kind) {
      case BookmarkKind.knowledge:
        return Icons.menu_book;
      case BookmarkKind.article:
        return Icons.article;
      case BookmarkKind.video:
        return Icons.video_library;
      case BookmarkKind.pattern:
        return Icons.pattern;
    }
  }

  String _labelFor(BookmarkKind kind) {
    switch (kind) {
      case BookmarkKind.knowledge:
        return 'Knowledge';
      case BookmarkKind.article:
        return 'Article';
      case BookmarkKind.video:
        return 'Video';
      case BookmarkKind.pattern:
        return 'Pattern';
    }
  }
}