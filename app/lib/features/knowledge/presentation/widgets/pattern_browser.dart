// EPIC 05 §2.5 — Pattern Library UI shell.
//
// Spec §2.5:
//   - Pattern Browser
//   - Pattern Detail
//   - Pattern Categories
//   - Pattern Difficulty
//   - Pattern Tags
//   - Related Pattern
//   - Pattern Search
//   - Pattern Images (metadata only)
//
// PO 2026-07-31 — images are metadata-only (no decoding / streaming).
// Reuses pattern-domain entries sourced from the existing Billiard
// Knowledge Module under `Knowledge/pattern_domain_validation.md` and
// the package's pattern-aware JSON. No AI.

import 'package:flutter/material.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

/// Pattern metadata record. Sourced from existing Billiard Knowledge
/// pattern entries; image bytes are never decoded — only the metadata
/// (uri, mimeType, dimensions) is exposed.
class PatternEntry {
  final String id;
  final String title;
  final String category;
  final String difficulty;
  final List<String> tags;
  final List<String> relatedPatternIds;
  final List<PatternImageMetadata> images;
  final String? sourceUri;

  const PatternEntry({
    required this.id,
    required this.title,
    required this.category,
    required this.difficulty,
    required this.tags,
    required this.relatedPatternIds,
    required this.images,
    this.sourceUri,
  });
}

/// Image metadata only — no decoded pixels, no rendering in Beta.
class PatternImageMetadata {
  final String uri;
  final String mimeType;
  final int widthPx;
  final int heightPx;
  const PatternImageMetadata({
    required this.uri,
    required this.mimeType,
    required this.widthPx,
    required this.heightPx,
  });
}

/// Read-only Pattern Browser. Filtering is by category + difficulty + tags;
/// the search box uses the same [DeterministicSearchRanker] (pure).
class PatternBrowser extends StatelessWidget {
  final List<PatternEntry> patterns;
  final void Function(PatternEntry) onOpen;

  const PatternBrowser({
    super.key,
    required this.patterns,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (patterns.isEmpty) {
      return Center(child: Text(l10n.get('knowledge_no_patterns')));
    }
    return ListView.separated(
      itemCount: patterns.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final p = patterns[index];
        return ListTile(
          leading: const Icon(Icons.pattern),
          title: Text(p.title),
          subtitle: Text(
            '${p.category} · ${p.difficulty}'
            '${p.tags.isNotEmpty ? ' · ${p.tags.join(", ")}' : ''}',
            style: const TextStyle(fontSize: 12),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => onOpen(p),
        );
      },
    );
  }
}

/// Read-only Pattern Detail. Images are listed as metadata only.
class PatternDetail extends StatelessWidget {
  final PatternEntry pattern;
  const PatternDetail({super.key, required this.pattern});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(pattern.title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text('Category: ${pattern.category}'),
        Text('Difficulty: ${pattern.difficulty}'),
        const SizedBox(height: 12),
        if (pattern.tags.isNotEmpty) ...[
          const Text('Tags',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: pattern.tags.map((t) => Chip(label: Text(t))).toList(),
          ),
          const SizedBox(height: 12),
        ],
        if (pattern.relatedPatternIds.isNotEmpty) ...[
          const Text('Related Patterns',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ...pattern.relatedPatternIds.map(
            (id) => ListTile(
              dense: true,
              leading: const Icon(Icons.link),
              title: Text(id),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (pattern.images.isNotEmpty) ...[
          const Text('Images (metadata only)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ...pattern.images.map(
            (m) => ListTile(
              dense: true,
              leading: const Icon(Icons.image_outlined),
              title: Text(m.uri),
              subtitle: Text('${m.mimeType} · ${m.widthPx}×${m.heightPx}'),
            ),
          ),
        ],
      ],
    );
  }
}