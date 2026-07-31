// EPIC 05 §2.6 — Article metadata model (Beta scope).
//
// Spec §2.6 surface in Beta:
//   - Article Browser
//   - Article Detail
//   - Markdown Rendering
//   - References
//   - Related Knowledge
//   - Bookmark              (hook only; integration in Wave 3)
//   - Read Status
//
// Out of Beta scope (per PO Wave Model 2026-07-31):
//   - Article Editor, Authoring, Approval Workflow, Versioning,
//     Collaborative Editing, Community Upload, Comment, Rating, Reaction.

import 'package:flutter/foundation.dart';

/// Read-only Article metadata. Markdown body lives inside [markdownBody];
/// rendering is done in the UI via `flutter_markdown` (existing Flutter
/// dependency) — no separate model needed.
@immutable
class Article {
  final String id;
  final String title;
  final String titleVi;
  final String author;
  final DateTime publishedAt;
  final String localeCode;
  final String markdownBody;
  final List<String> references;
  final List<String> relatedKnowledgeIds;
  final List<String> tags;

  const Article({
    required this.id,
    required this.title,
    required this.titleVi,
    required this.author,
    required this.publishedAt,
    required this.localeCode,
    required this.markdownBody,
    required this.references,
    required this.relatedKnowledgeIds,
    required this.tags,
  });

  /// Look up the local title based on the device's language code.
  String localizedTitle(String languageCode) =>
      languageCode == 'vi' && titleVi.isNotEmpty ? titleVi : title;
}

/// Per-article read-status. Beta stores this in-memory only; bookmark is
/// the persistent layer (Wave 3).
@immutable
class ArticleReadStatus {
  final String articleId;
  final bool read;
  final DateTime? readAt;

  const ArticleReadStatus({
    required this.articleId,
    required this.read,
    this.readAt,
  });
}