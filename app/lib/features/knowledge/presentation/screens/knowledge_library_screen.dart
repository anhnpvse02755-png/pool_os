import 'package:billiard_knowledge/billiard_knowledge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/knowledge/presentation/providers/knowledge_providers.dart';
import 'package:pool_os/features/knowledge/presentation/screens/knowledge_detail_screen.dart';

class KnowledgeLibraryScreen extends ConsumerStatefulWidget {
  const KnowledgeLibraryScreen({super.key});

  @override
  ConsumerState<KnowledgeLibraryScreen> createState() =>
      _KnowledgeLibraryScreenState();
}

class _KnowledgeLibraryScreenState
    extends ConsumerState<KnowledgeLibraryScreen> {
  String _query = '';
  AudienceLevel? _level;

  @override
  Widget build(BuildContext context) {
    final vi = Localizations.localeOf(context).languageCode == 'vi';
    final catalogAsync = ref.watch(knowledgeCatalogProvider);

    return Scaffold(
      appBar: AppBar(title: Text(vi ? 'Từ điển bi-a' : 'Billiard Knowledge')),
      body: catalogAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              vi
                  ? 'Không thể tải kho kiến thức.'
                  : 'Unable to load the knowledge catalog.',
            ),
          ),
        ),
        data: (catalog) => _content(context, catalog, vi),
      ),
    );
  }

  Widget _content(BuildContext context, KnowledgeCatalog catalog, bool vi) {
    final results = catalog.search(
      KnowledgeQuery(
        text: _query,
        locale: vi ? 'vi' : 'en',
        levels: _level == null ? const {} : {_level!},
      ),
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: SearchBar(
            hintText: vi
                ? 'Tìm kỹ thuật, lỗi, thuật ngữ...'
                : 'Search knowledge...',
            leading: const Icon(Icons.search),
            onChanged: (value) => setState(() => _query = value),
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              ChoiceChip(
                label: Text(vi ? 'Tất cả' : 'All'),
                selected: _level == null,
                onSelected: (_) => setState(() => _level = null),
              ),
              const SizedBox(width: 8),
              ...AudienceLevel.values.map(
                (level) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(_levelName(level, vi)),
                    selected: _level == level,
                    onSelected: (_) => setState(() => _level = level),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              if (_query.isEmpty && _level == null) ...[
                for (final path in catalog.paths)
                  _pathSection(context, catalog, path, vi),
                const SizedBox(height: 16),
                Text(
                  vi ? 'Toàn bộ kiến thức' : 'All knowledge',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
              ],
              if (results.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      vi ? 'Không tìm thấy nội dung.' : 'No results.',
                    ),
                  ),
                )
              else
                for (final result in results)
                  _entryTile(context, result.entry, vi),
            ],
          ),
        ),
      ],
    );
  }

  Widget _pathSection(
    BuildContext context,
    KnowledgeCatalog catalog,
    LearningPath path,
    bool vi,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          path.title.resolve(vi ? 'vi' : 'en'),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(path.description.resolve(vi ? 'vi' : 'en')),
        const SizedBox(height: 8),
        SizedBox(
          height: 76,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: path.steps.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final entry = catalog.entryById(path.steps[index].entryId)!;
              return ActionChip(
                avatar: CircleAvatar(child: Text('${index + 1}')),
                label: SizedBox(
                  width: 132,
                  child: Text(
                    entry.title.resolve(vi ? 'vi' : 'en'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                onPressed: () => _open(context, entry.id),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _entryTile(BuildContext context, KnowledgeEntry entry, bool vi) {
    final locale = vi ? 'vi' : 'en';
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      leading: CircleAvatar(child: Icon(_kindIcon(entry.kind))),
      title: Text(entry.title.resolve(locale)),
      subtitle: Text(
        entry.summary.resolve(locale),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _open(context, entry.id),
    );
  }

  void _open(BuildContext context, String id) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => KnowledgeDetailScreen(knowledgeId: id)),
    );
  }

  IconData _kindIcon(KnowledgeKind kind) => switch (kind) {
    KnowledgeKind.commonMistake => Icons.warning_amber,
    KnowledgeKind.terminology => Icons.translate,
    KnowledgeKind.rule => Icons.gavel,
    KnowledgeKind.equipment => Icons.build_outlined,
    KnowledgeKind.mental => Icons.psychology_outlined,
    KnowledgeKind.strategy => Icons.account_tree_outlined,
    KnowledgeKind.technique => Icons.sports_bar,
    KnowledgeKind.concept => Icons.lightbulb_outline,
  };

  String _levelName(AudienceLevel level, bool vi) => switch (level) {
    AudienceLevel.beginner => vi ? 'Người mới' : 'Beginner',
    AudienceLevel.fundamental => vi ? 'Nền tảng' : 'Fundamental',
    AudienceLevel.intermediate => vi ? 'Trung cấp' : 'Intermediate',
    AudienceLevel.advanced => vi ? 'Nâng cao' : 'Advanced',
    AudienceLevel.professional => vi ? 'Chuyên nghiệp' : 'Professional',
  };
}
