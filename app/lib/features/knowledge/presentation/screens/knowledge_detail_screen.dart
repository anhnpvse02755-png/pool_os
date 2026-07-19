import 'package:billiard_knowledge/billiard_knowledge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/knowledge/presentation/providers/knowledge_providers.dart';
import 'package:pool_os/features/training_center/presentation/providers/training_center_providers.dart';
import 'package:pool_os/features/training_center/presentation/screens/training_session_screen.dart';

class KnowledgeDetailScreen extends ConsumerStatefulWidget {
  final String knowledgeId;
  final bool fromCoach;

  const KnowledgeDetailScreen({
    super.key,
    required this.knowledgeId,
    this.fromCoach = false,
  });

  @override
  ConsumerState<KnowledgeDetailScreen> createState() =>
      _KnowledgeDetailScreenState();
}

class _KnowledgeDetailScreenState extends ConsumerState<KnowledgeDetailScreen> {
  ExplanationDepth _depth = ExplanationDepth.result;

  @override
  Widget build(BuildContext context) {
    final vi = Localizations.localeOf(context).languageCode == 'vi';
    final catalogAsync = ref.watch(knowledgeCatalogProvider);
    final trainingLibrary = ref.watch(trainingLibraryProvider).valueOrNull ??
        const <TrainingDrill>[];

    return Scaffold(
      appBar: AppBar(title: Text(vi ? 'Kiến thức' : 'Knowledge')),
      body: catalogAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Text(
            vi ? 'Không thể tải nội dung.' : 'Unable to load content.',
          ),
        ),
        data: (catalog) {
          final entry = catalog.entryById(widget.knowledgeId);
          if (entry == null) {
            return Center(
              child: Text(vi ? 'Không tìm thấy nội dung.' : 'Not found.'),
            );
          }
          return _content(context, catalog, entry, trainingLibrary, vi);
        },
      ),
    );
  }

  Widget _content(
    BuildContext context,
    KnowledgeCatalog catalog,
    KnowledgeEntry entry,
    List<TrainingDrill> trainingLibrary,
    bool vi,
  ) {
    final locale = vi ? 'vi' : 'en';
    final availableDepths = entry.layers.map((layer) => layer.depth).toSet();
    final selectedLayer = entry.layer(_depth) ?? entry.layers.first;
    final related = catalog.relatedTo(entry);
    final sources = catalog.sources
        .where((source) => entry.sourceIds.contains(source.id))
        .toList();
    final relatedDrills = _resolveDrills(
      [
        ...entry.drillRefs,
        ...entry.mistakes.expand((mistake) => mistake.drillRefs),
      ],
      trainingLibrary,
    );
    final nextStep = _findNextStep(catalog, entry.id);
    final nextEntry =
        nextStep == null ? null : catalog.entryById(nextStep.entryId);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (widget.fromCoach)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Row(
              children: [
                const Icon(Icons.psychology_outlined),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    vi
                        ? 'Coach đề xuất nội dung này.'
                        : 'Coach recommended this knowledge.',
                  ),
                ),
              ],
            ),
          ),
        Text(
          entry.title.resolve(locale),
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(label: Text(_levelName(entry.level, vi))),
            Chip(label: Text(_reviewName(entry.reviewState, vi))),
            Chip(label: Text(entry.topic)),
          ],
        ),
        const SizedBox(height: 12),
        Text(entry.summary.resolve(locale)),
        if (relatedDrills.isNotEmpty) ...[
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _startTraining(context, relatedDrills.first),
            icon: const Icon(Icons.play_arrow),
            label: Text(vi ? 'Bắt đầu luyện tập' : 'Start training'),
          ),
        ],
        const SizedBox(height: 20),
        Text(
          vi ? 'Mức giải thích' : 'Explanation depth',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final depth in ExplanationDepth.values)
              ChoiceChip(
                label: Text(_depthName(depth, vi)),
                selected: _depth == depth,
                onSelected: availableDepths.contains(depth)
                    ? (_) => setState(() => _depth = depth)
                    : null,
              ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          selectedLayer.heading.resolve(locale),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        for (final paragraph in selectedLayer.paragraphs)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              paragraph.resolve(locale),
              style: const TextStyle(height: 1.45),
            ),
          ),
        for (final point in selectedLayer.keyPoints)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.check_circle_outline, size: 20),
            title: Text(point.resolve(locale)),
          ),
        _localizedSection(
          context,
          vi ? 'Khi sử dụng' : 'When to use',
          entry.whenToUse,
          locale,
        ),
        _localizedSection(
          context,
          vi ? 'Khi không nên sử dụng' : 'When not to use',
          entry.whenNotToUse,
          locale,
        ),
        _localizedSection(
          context,
          vi ? 'Ưu điểm' : 'Advantages',
          entry.advantages,
          locale,
        ),
        _localizedSection(
          context,
          vi ? 'Nhược điểm' : 'Disadvantages',
          entry.disadvantages,
          locale,
        ),
        if (entry.examples.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            vi ? 'Ví dụ' : 'Examples',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          for (final example in entry.examples)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(example.situation.resolve(locale)),
              subtitle: Text(example.explanation.resolve(locale)),
            ),
        ],
        _localizedSection(
          context,
          vi ? 'Gợi ý chuyên môn' : 'Professional tips',
          entry.professionalTips,
          locale,
        ),
        if (entry.mistakes.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            vi ? 'Lỗi thường gặp' : 'Common mistakes',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          for (final mistake in entry.mistakes)
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text(mistake.symptom.resolve(locale)),
              childrenPadding: const EdgeInsets.only(bottom: 12),
              children: [
                ListTile(
                  dense: true,
                  title: Text(vi ? 'Nguyên nhân' : 'Cause'),
                  subtitle: Text(mistake.cause.resolve(locale)),
                ),
                ListTile(
                  dense: true,
                  title: Text(vi ? 'Cách sửa' : 'Correction'),
                  subtitle: Text(mistake.correction.resolve(locale)),
                ),
                for (final drill
                    in _resolveDrills(mistake.drillRefs, trainingLibrary))
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.play_circle_outline),
                    title: Text(
                      vi ? 'Luyện cách sửa lỗi' : 'Practice this correction',
                    ),
                    subtitle: Text(drill.displayName(locale)),
                    onTap: () => _startTraining(context, drill),
                  ),
              ],
            ),
        ],
        if (relatedDrills.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            vi ? 'Bài tập liên quan' : 'Related drills',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          for (final drill in relatedDrills)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.fitness_center),
              title: Text(drill.displayName(locale)),
              subtitle: Text(
                '${vi ? 'Mục tiêu' : 'Target'}: ${drill.targetReps}',
              ),
              trailing: const Icon(Icons.play_arrow),
              onTap: () => _startTraining(context, drill),
            ),
        ],
        if (nextEntry != null) ...[
          const SizedBox(height: 20),
          Text(
            vi ? 'Bước tiếp theo' : 'Next step',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.route_outlined),
            title: Text(nextEntry.title.resolve(locale)),
            subtitle: Text(nextEntry.summary.resolve(locale)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    KnowledgeDetailScreen(knowledgeId: nextEntry.id),
              ),
            ),
          ),
        ],
        if (related.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            vi ? 'Kiến thức liên quan' : 'Related knowledge',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          for (final item in related)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(item.title.resolve(locale)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => KnowledgeDetailScreen(knowledgeId: item.id),
                ),
              ),
            ),
        ],
        if (sources.isNotEmpty) ...[
          const Divider(height: 32),
          Text(
            vi ? 'Nguồn đối chiếu' : 'Sources',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          for (final source in sources)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.verified_outlined),
              title: Text(source.title),
              subtitle: Text(source.publisher),
            ),
        ],
        if (entry.media.isNotEmpty) ...[
          const Divider(height: 32),
          Text(
            vi ? 'Minh họa' : 'Media',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          for (final media in entry.media)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                media.type == 'video'
                    ? Icons.play_circle_outline
                    : Icons.image_outlined,
              ),
              title: Text(media.altText.resolve(locale)),
              subtitle: media.license == null ? null : Text(media.license!),
            ),
        ],
        const SizedBox(height: 16),
        Text(
          '${vi ? 'Phiên bản gói' : 'Pack version'} ${catalog.packVersion} · r${entry.revision}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  List<TrainingDrill> _resolveDrills(
    Iterable<String> references,
    List<TrainingDrill> library,
  ) {
    final result = <TrainingDrill>[];
    final seen = <String>{};
    for (final reference in references) {
      for (final drill in library.where(
        (item) =>
            item.key == reference ||
            item.drillCode == reference ||
            item.category == reference,
      )) {
        if (seen.add(drill.key)) result.add(drill);
      }
    }
    return result;
  }

  LearningStep? _findNextStep(KnowledgeCatalog catalog, String entryId) {
    for (final path in catalog.paths) {
      final index = path.steps.indexWhere((step) => step.entryId == entryId);
      if (index >= 0 && index + 1 < path.steps.length) {
        return path.steps[index + 1];
      }
    }
    return null;
  }

  void _startTraining(BuildContext context, TrainingDrill drill) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TrainingSessionScreen(initialDrill: drill),
      ),
    );
  }

  Widget _localizedSection(
    BuildContext context,
    String title,
    List<LocalizedText> items,
    String locale,
  ) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          for (final item in items)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.circle, size: 8),
              title: Text(item.resolve(locale)),
            ),
        ],
      ),
    );
  }

  String _depthName(ExplanationDepth depth, bool vi) => switch (depth) {
        ExplanationDepth.result => vi ? 'Level 1 · Làm theo' : 'Level 1 · Do',
        ExplanationDepth.cause => vi ? 'Level 2 · Vì sao' : 'Level 2 · Why',
        ExplanationDepth.principles =>
          vi ? 'Level 3 · Nguyên lý' : 'Level 3 · Principles',
        ExplanationDepth.physics =>
          vi ? 'Level 4 · Vật lý' : 'Level 4 · Physics',
        ExplanationDepth.engine => 'Level 5 · Engine',
      };

  String _levelName(AudienceLevel level, bool vi) => switch (level) {
        AudienceLevel.beginner => vi ? 'Người mới' : 'Beginner',
        AudienceLevel.fundamental => vi ? 'Nền tảng' : 'Fundamental',
        AudienceLevel.intermediate => vi ? 'Trung cấp' : 'Intermediate',
        AudienceLevel.advanced => vi ? 'Nâng cao' : 'Advanced',
        AudienceLevel.professional => vi ? 'Chuyên nghiệp' : 'Professional',
      };

  String _reviewName(ReviewState state, bool vi) => switch (state) {
        ReviewState.draft => vi ? 'Bản nháp' : 'Draft',
        ReviewState.reviewed => vi ? 'Đã đối chiếu' : 'Reviewed',
        ReviewState.verified => vi ? 'Đã xác minh' : 'Verified',
        ReviewState.deprecated => vi ? 'Ngừng dùng' : 'Deprecated',
      };
}
