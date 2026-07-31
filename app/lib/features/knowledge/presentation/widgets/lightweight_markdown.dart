// EPIC 05 §2.6 — Lightweight Markdown renderer (no extra dependency).
//
// PO 2026-07-31 — Beta scope: Markdown rendering only. Uses the in-repo
// Flutter SDK Text widget with a hand-rolled renderer that covers the
// headings, paragraphs, lists and inline code that the existing Article
// content uses. Avoids the extra `flutter_markdown` dependency for Beta.

import 'package:flutter/material.dart';

/// Renders the small subset of Markdown used by Articles: `# heading`,
/// `## subheading`, bullets (`-` or `*`), and inline code (backticks).
class LightweightMarkdown extends StatelessWidget {
  final String data;
  final bool selectable;
  const LightweightMarkdown({
    super.key,
    required this.data,
    this.selectable = true,
  });

  @override
  Widget build(BuildContext context) {
    final blocks = _parse(data);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final b in blocks) _renderBlock(context, b),
      ],
    );
  }

  Widget _renderBlock(BuildContext context, MarkdownBlock block) {
    switch (block.type) {
      case MarkdownBlockType.heading1:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            block.text,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        );
      case MarkdownBlockType.heading2:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            block.text,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        );
      case MarkdownBlockType.bullet:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Text('•'),
              ),
              Expanded(child: _inline(block.text, selectable)),
            ],
          ),
        );
      case MarkdownBlockType.paragraph:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: _inline(block.text, selectable),
        );
    }
  }

  Widget _inline(String text, bool selectable) {
    final spans = _inlineSpans(text);
    if (selectable) {
      return Text.rich(TextSpan(children: spans));
    }
    return Text.rich(TextSpan(children: spans));
  }

  /// Build inline spans — converts `code` between backticks to monospace.
  List<InlineSpan> _inlineSpans(String text) {
    final out = <InlineSpan>[];
    var i = 0;
    while (i < text.length) {
      final tick = text.indexOf('`', i);
      if (tick < 0) {
        out.add(TextSpan(text: text.substring(i)));
        return out;
      }
      final end = text.indexOf('`', tick + 1);
      if (end < 0) {
        out.add(TextSpan(text: text.substring(i)));
        return out;
      }
      out.add(TextSpan(text: text.substring(i, tick)));
      out.add(TextSpan(
        text: text.substring(tick + 1, end),
        style: const TextStyle(fontFamily: 'monospace'),
      ));
      i = end + 1;
    }
    return out;
  }

  List<MarkdownBlock> _parse(String src) {
    final out = <MarkdownBlock>[];
    final lines = src.split('\n');
    for (final raw in lines) {
      final line = raw.trimRight();
      if (line.trim().isEmpty) continue;
      if (line.startsWith('# ')) {
        out.add(MarkdownBlock(
          type: MarkdownBlockType.heading1,
          text: line.substring(2).trim(),
        ));
      } else if (line.startsWith('## ')) {
        out.add(MarkdownBlock(
          type: MarkdownBlockType.heading2,
          text: line.substring(3).trim(),
        ));
      } else if (line.startsWith('- ') || line.startsWith('* ')) {
        out.add(MarkdownBlock(
          type: MarkdownBlockType.bullet,
          text: line.substring(2).trim(),
        ));
      } else {
        out.add(MarkdownBlock(
          type: MarkdownBlockType.paragraph,
          text: line,
        ));
      }
    }
    return out;
  }
}

enum MarkdownBlockType { heading1, heading2, bullet, paragraph }

class MarkdownBlock {
  final MarkdownBlockType type;
  final String text;
  const MarkdownBlock({required this.type, required this.text});
}