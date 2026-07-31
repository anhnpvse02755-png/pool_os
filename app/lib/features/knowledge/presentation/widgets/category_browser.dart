// EPIC 05 §2.2 — Categories UI shell.
//
// Spec §2.2:
//   - Hierarchical Categories
//   - Category Navigation
//   - Category Statistics
//   - Category Filter
//
// PO 2026-07-31 — no AI, deterministic only. Hierarchical structure is
// derived from the existing `Knowledge/categories.json` and the parent
// pointer in each category.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/knowledge/domain/services/category_browser_service.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

/// Hierarchical Category node. Built from existing
/// [CategoryInfo] entries; parent link is the leading path segment.
class CategoryNode {
  final String id;
  final String displayName;
  final CategoryInfo info;
  final List<CategoryNode> children;

  const CategoryNode({
    required this.id,
    required this.displayName,
    required this.info,
    required this.children,
  });

  bool get hasChildren => children.isNotEmpty;
}

/// Read-only categories browser. Tapping a category emits [onSelected] and
/// the parent screen surfaces the filter. No mutation, no AI ranking.
class CategoryBrowser extends ConsumerWidget {
  final void Function(CategoryNode node) onSelected;
  const CategoryBrowser({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return FutureBuilder<List<CategoryInfo>>(
      future:
          ref.watch(categoryBrowserServiceProvider).getAllCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text(l10n.get('knowledge_load_error')));
        }
        final categories = snapshot.data ?? const <CategoryInfo>[];
        if (categories.isEmpty) {
          return Center(
            child: Text(
              l10n.get('knowledge_no_categories'),
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }
        final roots = _buildTree(categories);
        return ListView(
          children: roots
              .map((root) => _CategoryTile(node: root, onSelected: onSelected))
              .toList(),
        );
      },
    );
  }

  /// Build a flat-then-grouped tree. Top-level categories are those whose
  /// name contains no "/" parent pointer. This is a deterministic projection
  /// — no heuristic grouping.
  List<CategoryNode> _buildTree(List<CategoryInfo> flat) {
    final childrenByParent = <String, List<CategoryInfo>>{};
    for (final c in flat) {
      final parts = c.name.split('/');
      final parent = parts.length > 1 ? parts.first : '__root__';
      childrenByParent.putIfAbsent(parent, () => []).add(c);
    }
    final roots = childrenByParent['__root__'] ?? flat;
    return [
      for (final r in roots)
        CategoryNode(
          id: r.name,
          displayName: r.name,
          info: r,
          children: [
            for (final c in childrenByParent[r.name] ?? const <CategoryInfo>[])
              CategoryNode(
                id: c.name,
                displayName: c.name.split('/').last,
                info: c,
                children: const [],
              ),
          ],
        ),
    ];
  }
}

class _CategoryTile extends StatelessWidget {
  final CategoryNode node;
  final void Function(CategoryNode) onSelected;

  const _CategoryTile({required this.node, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: const Icon(Icons.category_outlined),
      title: Text(node.displayName),
      subtitle: Text(
        '${node.info.itemCount} items'
        '${node.info.techniqueCount > 0 ? ' · ${node.info.techniqueCount} techniques' : ''}',
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.filter_alt_outlined),
        tooltip: 'Filter',
        onPressed: () => onSelected(node),
      ),
      onExpansionChanged: (expanded) {
        if (!expanded) return;
        onSelected(node);
      },
      children: node.children
          .map(
            (c) => ListTile(
              leading: const Icon(Icons.subdirectory_arrow_right),
              title: Text(c.displayName),
              subtitle: Text('${c.info.itemCount} items'),
              trailing: IconButton(
                icon: const Icon(Icons.filter_alt_outlined),
                onPressed: () => onSelected(c),
              ),
              onTap: () => onSelected(c),
            ),
          )
          .toList(),
    );
  }
}