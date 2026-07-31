// EPIC 05 §2.6 — Article Browser + Detail (Beta scope only).
//
// PO Wave Model 2026-07-31 — Beta scope is Browser + Detail + Markdown
// rendering + References + Related Knowledge + Bookmark hook. No
// editor, no streaming, no sync.

import 'package:flutter/material.dart';
import 'package:pool_os/features/knowledge/domain/article.dart';
import 'package:pool_os/features/knowledge/presentation/widgets/lightweight_markdown.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

/// Read-only Article Browser.
class ArticleBrowser extends StatelessWidget {
  final List<Article> articles;
  final void Function(Article) onOpen;
  const ArticleBrowser({super.key, required this.articles, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (articles.isEmpty) {
      return Center(child: Text(l10n.get('knowledge_no_articles')));
    }
    return ListView.separated(
      itemCount: articles.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final a = articles[index];
        return ListTile(
          leading: const Icon(Icons.article_outlined),
          title: Text(a.title),
          subtitle: Text(
            '${a.author} · ${a.publishedAt.toIso8601String().split('T').first}',
            style: const TextStyle(fontSize: 12),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => onOpen(a),
        );
      },
    );
  }
}

/// Read-only Article Detail. Renders markdown body, references, related
/// knowledge, bookmark hook, and read status. No editor affordances.
class ArticleDetail extends StatelessWidget {
  final Article article;
  final bool isBookmarked;
  final bool isRead;
  final void Function()? onToggleBookmark;

  const ArticleDetail({
    super.key,
    required this.article,
    required this.isBookmarked,
    required this.isRead,
    this.onToggleBookmark,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(article.title),
        actions: [
          IconButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
            ),
            // Bookmark hook — Wiring happens in Wave 3. The button is the
            // entry point only. Visible always so the affordance survives
            // Wave 2's read-only routing.
            onPressed: onToggleBookmark,
            tooltip: 'Bookmark',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '${article.author} · ${article.publishedAt.toIso8601String().split('T').first}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          if (isRead)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Read',
                style: TextStyle(color: Colors.green),
              ),
            ),
          LightweightMarkdown(
            data: article.markdownBody,
            selectable: true,
          ),
          if (article.references.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('References',
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...article.references.map(
              (r) => ListTile(
                dense: true,
                leading: const Icon(Icons.link),
                title: Text(r),
              ),
            ),
          ],
          if (article.relatedKnowledgeIds.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Related Knowledge',
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...article.relatedKnowledgeIds.map(
              (id) => ListTile(
                dense: true,
                leading: const Icon(Icons.menu_book_outlined),
                title: Text(id),
              ),
            ),
          ],
        ],
      ),
    );
  }
}