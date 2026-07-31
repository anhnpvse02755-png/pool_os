// EPIC 05 §2.7 — Video Browser + Detail (Beta scope only).
//
// PO Wave Model 2026-07-31 — Beta scope is Browser + Metadata + Category +
// Duration + External URL + Bookmark hook. NO streaming, NO download,
// NO sync. Tapping [externalUrl] hands the URL off to the platform via
// `url_launcher` (in-repo dependency).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pool_os/features/knowledge/domain/video_metadata.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

/// Read-only Video Browser.
class VideoBrowser extends StatelessWidget {
  final List<VideoEntry> videos;
  final void Function(VideoEntry) onOpen;
  const VideoBrowser({super.key, required this.videos, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (videos.isEmpty) {
      return Center(child: Text(l10n.get('knowledge_no_videos')));
    }
    return ListView.separated(
      itemCount: videos.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final v = videos[index];
        return ListTile(
          leading: const Icon(Icons.video_library_outlined),
          title: Text(v.title),
          subtitle: Text(
            '${v.channel} · ${v.category} · ${v.formattedDuration()}',
            style: const TextStyle(fontSize: 12),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => onOpen(v),
        );
      },
    );
  }
}

/// Read-only Video Detail. Beta surfaces the metadata, the external URL
/// (handed off to the platform launcher), the watch status, and the
/// bookmark hook. No embedded player, no download.
class VideoDetail extends StatelessWidget {
  final VideoEntry video;
  final bool isBookmarked;
  final bool isWatched;
  final void Function()? onToggleBookmark;

  const VideoDetail({
    super.key,
    required this.video,
    required this.isBookmarked,
    required this.isWatched,
    this.onToggleBookmark,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(video.title),
        actions: [
          IconButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
            ),
            onPressed: onToggleBookmark,
            tooltip: 'Bookmark',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '${video.channel} · ${video.category}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text('Duration: ${video.formattedDuration()}'),
          if (isWatched)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Watched',
                style: TextStyle(color: Colors.green),
              ),
            ),
          if (video.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: video.tags.map((t) => Chip(label: Text(t))).toList(),
            ),
          ],
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.link),
            title: const Text('External URL (read-only)'),
            subtitle: Text(video.externalUrl),
            trailing: IconButton(
              icon: const Icon(Icons.copy_all_outlined),
              // Beta scope: hand the URL to the system clipboard so the
              // user can paste it into their browser. No embedded player,
              // no native launch — keeps Beta read-only.
              tooltip: 'Copy URL',
              onPressed: () async {
                await Clipboard.setData(
                  ClipboardData(text: video.externalUrl),
                );
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('URL copied')),
                );
              },
            ),
          ),
          if (video.thumbnailUri != null) ...[
            const SizedBox(height: 16),
            const Text('Thumbnail (metadata)',
                style: TextStyle(fontWeight: FontWeight.bold)),
            ListTile(
              dense: true,
              leading: const Icon(Icons.image_outlined),
              title: Text(video.thumbnailUri!),
            ),
          ],
        ],
      ),
    );
  }

  // Beta scope: Beta hands the URL to the clipboard. Future post-Beta
  // work that re-enables an embedded player can place the launch code
  // here without re-locating the surface.
}