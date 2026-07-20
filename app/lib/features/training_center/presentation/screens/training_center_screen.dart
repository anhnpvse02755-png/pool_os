import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/drill/domain/models/drill.dart';
import 'package:pool_os/features/training_center/domain/models/training_center_models.dart';
import 'package:pool_os/features/training_center/presentation/providers/training_center_providers.dart';
import 'package:pool_os/features/training_center/presentation/screens/category_drills_screen.dart';
import 'package:pool_os/features/training_center/presentation/screens/custom_drill_editor_screen.dart';
import 'package:pool_os/features/training_center/presentation/screens/progress_screen.dart';
import 'package:pool_os/features/training_center/presentation/screens/training_session_screen.dart';
import 'package:pool_os/features/knowledge/presentation/screens/knowledge_detail_screen.dart';
import 'package:pool_os/features/knowledge/presentation/providers/knowledge_providers.dart';
import 'package:pool_os/features/knowledge/domain/models/knowledge_item.dart';
import 'package:pool_os/features/coach/presentation/stop_shot_providers.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';
import 'package:pool_os/features/training_center/presentation/screens/stop_shot_slice_screen.dart';

/// Task 09 — Training Center home (Phần 7). Entry to the whole training system:
/// a "start session" action, a Progress shortcut, Recent drills (Phần 6), and
/// the Category list (Phần 1). Every list has an explicit empty state.
class TrainingCenterScreen extends ConsumerStatefulWidget {
  /// Task 15: when the Coach deep-links with ?category=<code>, open that drill
  /// category directly on first build (so "practice this shot" is one tap, not a
  /// hunt). Null = normal home entry.
  final String? initialCategory;

  /// RFC-KB-002: when Coach deep-links with ?knowledgeId=<id>, open that
  /// knowledge article directly (with the "Coach recommends this" banner).
  final String? initialKnowledgeId;

  const TrainingCenterScreen(
      {super.key, this.initialCategory, this.initialKnowledgeId});

  @override
  ConsumerState<TrainingCenterScreen> createState() =>
      _TrainingCenterScreenState();
}

class _TrainingCenterScreenState extends ConsumerState<TrainingCenterScreen> {
  @override
  void initState() {
    super.initState();
    final cat = widget.initialCategory;
    final kid = widget.initialKnowledgeId;
    if (kid != null && kid.isNotEmpty) {
      // RFC-KB-002: Coach deep-linked a specific article → open it once, after
      // the first frame, with the "Coach recommends this" banner.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                KnowledgeDetailScreen(knowledgeId: kid, fromCoach: true),
          ),
        );
      });
    } else if (cat != null && cat.isNotEmpty) {
      // Open the requested category once, after the first frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (_) => CategoryDrillsScreen(category: cat)),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final byCategory = ref.watch(libraryByCategoryProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.get('training_center_title'))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _startSession(context),
        icon: const Icon(Icons.play_arrow),
        label: Text(l10n.get('tc_start_session')),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(customDrillsProvider);
          ref.invalidate(favoriteKeysProvider);
          ref.invalidate(recentDrillRunsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            _actionRow(context, l10n),
            _stopShotExecutableSlice(context),
            _recentSection(context, ref, l10n, locale),
            const Divider(height: 1),
            _knowledgeSection(context, ref, l10n),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                l10n.get('tc_categories'),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            byCategory.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l10n.get('tc_load_error')),
              ),
              data: (grouped) => _categoryList(context, grouped, locale, l10n),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stopShotExecutableSlice(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: [
          _techniqueRuntimeCard(
            context,
            knowledgeId: stopShotKnowledgeId,
            title: 'Stop Shot',
            cardKey: const Key('stop-shot-slice-card'),
          ),
          _techniqueRuntimeCard(
            context,
            knowledgeId: followShotKnowledgeId,
            title: 'Follow Shot',
            cardKey: const Key('follow-shot-slice-card'),
          ),
          _mistakeRuntimeCard(context),
        ],
      ),
    );
  }

  Widget _techniqueRuntimeCard(
    BuildContext context, {
    required String knowledgeId,
    required String title,
    required Key cardKey,
  }) {
    final provider = techniqueControllerProvider(knowledgeId);
    final snapshot = ref.watch(provider);
    return Card(
      child: ListTile(
        key: cardKey,
        leading: const Icon(Icons.track_changes),
        title: Text(title),
        subtitle: snapshot.when(
          loading: () => const Text('Đang tải Knowledge Runtime...'),
          error: (_, __) => const Text('Không thể tải Knowledge Runtime'),
          data: (value) => Text(
            '${value.decision.recommendations.selected.title} · '
            'Mastery ${value.mastery.score.round()}%',
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => StopShotSliceScreen(knowledgeId: knowledgeId),
            ),
          );
          ref.invalidate(provider);
        },
      ),
    );
  }

  Widget _mistakeRuntimeCard(BuildContext context) {
    final snapshot = ref.watch(poorSpeedControlControllerProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.build_circle_outlined),
              title: const Text('Kiểm soát tốc độ chưa ổn định'),
              subtitle: snapshot.when(
                loading: () => const Text('Đang tải Mistake Runtime...'),
                error: (_, __) => const Text('Không thể tải Mistake Runtime'),
                data: (value) => Text(
                  '${value.assessment.state.name} · '
                  '${value.assessment.observationCount} observations\n'
                  '${value.decision.recommendations.selected.title}',
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    key: const Key('mistake-detected'),
                    onPressed: snapshot.isLoading
                        ? null
                        : () => ref
                            .read(poorSpeedControlControllerProvider.notifier)
                            .observe(resolved: false),
                    icon: const Icon(Icons.visibility_outlined),
                    label: const Text('Ghi nhận lỗi'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    key: const Key('mistake-resolved'),
                    onPressed: snapshot.isLoading
                        ? null
                        : () => ref
                            .read(poorSpeedControlControllerProvider.notifier)
                            .observe(resolved: true),
                    icon: const Icon(Icons.check),
                    label: const Text('Đã khắc phục'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionRow(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProgressScreen()),
              ),
              icon: const Icon(Icons.trending_up),
              label: Text(l10n.get('tc_progress')),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const CustomDrillEditorScreen()),
              ),
              icon: const Icon(Icons.add),
              label: Text(l10n.get('tc_custom_drill')),
            ),
          ),
        ],
      ),
    );
  }

  /// RFC-KB-002: the Knowledge module inside the Learning Hub. Lists knowledge
  /// articles (techniques, mistakes, equipment, mental, strategy) with a status
  /// badge; tapping opens the KnowledgeDetailScreen. Drills stay in the category
  /// list below — Knowledge only references them.
  Widget _knowledgeSection(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final knowledgeAsync = ref.watch(knowledgeAllProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.get('kb_knowledge'),
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          knowledgeAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text(l10n.get('kb_load_error')),
            data: (items) {
              if (items.isEmpty) return Text(l10n.get('kb_empty'));
              return Column(
                children: [
                  for (final k in items) _knowledgeCard(context, l10n, k),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _knowledgeCard(
      BuildContext context, AppLocalizations l10n, KnowledgeItem k) {
    final statusColor = switch (k.status) {
      KnowledgeStatus.verified => Colors.green,
      KnowledgeStatus.beta => Colors.orange,
      KnowledgeStatus.draft => Colors.grey,
    };
    return Card(
      child: ListTile(
        leading: const Icon(Icons.menu_book),
        title: Text(k.titleVi),
        subtitle: Text(l10n.get(k.type.labelKey)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(l10n.get(k.status.labelKey),
              style: TextStyle(fontSize: 10, color: statusColor)),
        ),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => KnowledgeDetailScreen(knowledgeId: k.id),
          ),
        ),
      ),
    );
  }

  Widget _recentSection(BuildContext context, WidgetRef ref,
      AppLocalizations l10n, String locale) {
    final recent = ref.watch(recentDrillRunsProvider);
    return recent.maybeWhen(
      data: (runs) {
        if (runs.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                l10n.get('tc_recent'),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            ...runs.map((r) => _recentTile(context, r, locale)),
          ],
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _recentTile(BuildContext context, DrillRun run, String locale) {
    final pct = (run.successRate * 100).round();
    return ListTile(
      dense: true,
      leading: const Icon(Icons.history),
      title: Text(run.drillName),
      subtitle: Text(DrillCategory.getName(run.category, locale)),
      trailing: Text(
        '$pct%  (${run.successes}/${run.attempts})',
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _categoryList(
      BuildContext context,
      Map<String, List<TrainingDrill>> grouped,
      String locale,
      AppLocalizations l10n) {
    if (grouped.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Text(l10n.get('tc_no_drills')),
      );
    }
    // Keep DrillCategory's canonical order, then any leftover categories.
    final ordered = <String>[
      ...DrillCategory.all.where(grouped.containsKey),
      ...grouped.keys.where((k) => !DrillCategory.all.contains(k)),
    ];
    return Column(
      children: ordered.map((cat) {
        final drills = grouped[cat]!;
        return ListTile(
          leading: const Icon(Icons.sports_esports_outlined),
          title: Text(DrillCategory.getName(cat, locale)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${drills.length}'),
              const Icon(Icons.chevron_right),
            ],
          ),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CategoryDrillsScreen(category: cat),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _startSession(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TrainingSessionScreen()),
    );
  }
}
