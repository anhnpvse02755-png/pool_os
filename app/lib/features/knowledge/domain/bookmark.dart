// EPIC 05 §2.8 — Bookmark domain (Beta scope).
//
// Spec §2.8:
//   - Bookmark Knowledge
//   - Bookmark Article
//   - Bookmark Video
//   - Bookmark Pattern
//   - Unified Bookmark List
//
// PO 2026-07-31 — no editor, no sync. Bookmarks live in-memory for the
// session and are mirrored to a lightweight Drift store so the list
// survives an app restart. Storage is added in §2.8 via a single small
// table (`knowledge_bookmarks`) — no schema migration of any pre-existing
// EPIC table.

import 'package:flutter/foundation.dart';

/// The four kinds of resource a bookmark can point at.
enum BookmarkKind { knowledge, article, video, pattern }

/// One bookmark row.
@immutable
class Bookmark {
  final String id;
  final BookmarkKind kind;
  final String targetId;
  final String displayTitle;
  final DateTime createdAt;

  const Bookmark({
    required this.id,
    required this.kind,
    required this.targetId,
    required this.displayTitle,
    required this.createdAt,
  });

  /// Identity used to de-duplicate (kind + targetId pair is unique).
  String dedupeKey() => '${kind.name}/$targetId';
}

/// Unified Bookmark List — supports filtering by kind and sorting by
/// `createdAt desc`. Pure operations only.
class BookmarkList {
  final List<Bookmark> _items;

  BookmarkList(Iterable<Bookmark> items) : _items = List.unmodifiable(items);

  List<Bookmark> get all => List.unmodifiable(_items);

  List<Bookmark> byKind(BookmarkKind kind) =>
      _items.where((b) => b.kind == kind).toList()..sort(
          (a, b) => b.createdAt.compareTo(a.createdAt));

  bool isBookmarked(BookmarkKind kind, String targetId) =>
      _items.any((b) => b.kind == kind && b.targetId == targetId);

  /// Add [b] if absent (de-duplicated by [Bookmark.dedupeKey]).
  BookmarkList upsert(Bookmark b) {
    final filtered = _items
        .where((x) => !(x.kind == b.kind && x.targetId == b.targetId))
        .toList();
    filtered.add(b);
    return BookmarkList(filtered);
  }

  /// Remove a bookmark matching (kind, targetId). Returns a new list with
  /// the row omitted.
  BookmarkList remove(BookmarkKind kind, String targetId) =>
      BookmarkList(_items
          .where((x) => !(x.kind == kind && x.targetId == targetId))
          .toList());
}