// EPIC 05 §2.7 — Video Metadata model (Beta scope).
//
// Spec §2.7 surface in Beta:
//   - Video Browser
//   - Video Metadata
//   - Video Category
//   - Video Duration
//   - External URL
//   - Bookmark              (hook only; integration in Wave 3)
//   - Watch Status
//
// Out of Beta scope (per PO Wave Model 2026-07-31):
//   - Video Streaming
//   - Embedded Player
//   - Download
//   - Online Sync
//   - Cloud Search

import 'package:flutter/foundation.dart';

/// Video metadata only. Beta never embeds a player — the user opens the
/// [externalUrl] in their browser. No streaming engine, no buffering.
@immutable
class VideoEntry {
  final String id;
  final String title;
  final String titleVi;
  final String category;
  final Duration duration;
  final String externalUrl;
  final String? thumbnailUri;
  final String channel;
  final DateTime publishedAt;
  final List<String> tags;

  const VideoEntry({
    required this.id,
    required this.title,
    required this.titleVi,
    required this.category,
    required this.duration,
    required this.externalUrl,
    required this.channel,
    required this.publishedAt,
    this.thumbnailUri,
    this.tags = const <String>[],
  });

  /// Look up the local title based on the device's language code.
  String localizedTitle(String languageCode) =>
      languageCode == 'vi' && titleVi.isNotEmpty ? titleVi : title;

  /// Human-readable duration `HH:MM:SS`. Pure projection.
  String formattedDuration() {
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60);
    final s = duration.inSeconds.remainder(60);
    return '${h.toString().padLeft(2, '0')}:'
        '${m.toString().padLeft(2, '0')}:'
        '${s.toString().padLeft(2, '0')}';
  }
}

/// Per-video watch-status. Beta stores this in-memory only; the bookmark
/// layer (Wave 3) is the persistent surface.
@immutable
class VideoWatchStatus {
  final String videoId;
  final bool watched;
  final DateTime? watchedAt;

  const VideoWatchStatus({
    required this.videoId,
    required this.watched,
    this.watchedAt,
  });
}