// EPIC 05 §2.9 — Reading Progress (Beta scope).
//
// Spec §2.9:
//   - Read / Unread
//   - Completed
//   - Continue Reading
//   - History
//
// PO 2026-07-31 — read-only progress layer. State is per-session in
// memory; the Bookmark persistence layer (Wave 3 §2.8) is the durable
// surface. Progress never mutates Knowledge content.

import 'package:flutter/foundation.dart';

/// One reading-progress record. Stored in-memory for the session.
@immutable
class ReadingProgress {
  final String targetId;
  final ReadingStatus status;
  final DateTime? startedAt;
  final DateTime? completedAt;

  const ReadingProgress({
    required this.targetId,
    required this.status,
    this.startedAt,
    this.completedAt,
  });
}

enum ReadingStatus { unread, reading, completed }

/// Continue-Reading entry — used by the unified list to surface the
/// most-recent in-progress item. Pure projection.
class ContinueReadingEntry {
  final ReadingProgress progress;
  final String title;
  const ContinueReadingEntry({
    required this.progress,
    required this.title,
  });
}

/// History entry — surfaces the most-recent reads (completed only) in
/// reverse chronological order. Pure projection.
@immutable
class HistoryEntry {
  final String targetId;
  final String title;
  final DateTime readAt;
  const HistoryEntry({
    required this.targetId,
    required this.title,
    required this.readAt,
  });
}

/// Reading progress log. Pure operations; no IO.
class ReadingProgressLog {
  final Map<String, ReadingProgress> _byTarget;

  const ReadingProgressLog(Map<String, ReadingProgress> byTarget)
      : _byTarget = byTarget;

  factory ReadingProgressLog.empty() =>
      const ReadingProgressLog(<String, ReadingProgress>{});

  ReadingProgress? forTarget(String targetId) => _byTarget[targetId];

  bool isRead(String targetId) {
    final p = _byTarget[targetId];
    return p?.status == ReadingStatus.completed;
  }

  bool isReading(String targetId) {
    final p = _byTarget[targetId];
    return p?.status == ReadingStatus.reading;
  }

  /// Mark [targetId] as read at [at] (defaults to now). Returns a new
  /// log with the entry merged.
  ReadingProgressLog markRead(String targetId, {DateTime? at}) {
    final m = Map<String, ReadingProgress>.from(_byTarget);
    final stamp = at ?? DateTime.now();
    m[targetId] = ReadingProgress(
      targetId: targetId,
      status: ReadingStatus.completed,
      startedAt: m[targetId]?.startedAt ?? stamp,
      completedAt: stamp,
    );
    return ReadingProgressLog(m);
  }

  /// Mark [targetId] as currently reading. Returns a new log.
  ReadingProgressLog markReading(String targetId, {DateTime? at}) {
    final m = Map<String, ReadingProgress>.from(_byTarget);
    final stamp = at ?? DateTime.now();
    m[targetId] = ReadingProgress(
      targetId: targetId,
      status: ReadingStatus.reading,
      startedAt: m[targetId]?.startedAt ?? stamp,
    );
    return ReadingProgressLog(m);
  }

  /// Continue-Reading list — entries currently in the `reading` state,
  /// sorted by `startedAt desc` so the most-recent surfaces first.
  List<ReadingProgress> continueReading() {
    final out = _byTarget.values
        .where((p) => p.status == ReadingStatus.reading)
        .toList();
    out.sort((a, b) {
      final ad = a.startedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bd = b.startedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bd.compareTo(ad);
    });
    return out;
  }

  /// History list — completed reads, reverse chronological by
  /// `completedAt`. Pure projection.
  List<ReadingProgress> history({int? limit}) {
    final out = _byTarget.values
        .where((p) => p.status == ReadingStatus.completed)
        .toList();
    out.sort((a, b) {
      final ad = a.completedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bd = b.completedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bd.compareTo(ad);
    });
    if (limit != null && out.length > limit) {
      return out.sublist(0, limit);
    }
    return out;
  }
}