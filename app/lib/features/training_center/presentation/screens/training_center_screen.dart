import 'package:billiard_knowledge/billiard_knowledge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/coach/domain/brain/coach_output.dart';
import 'package:pool_os/features/coach/domain/brain/knowledge_registry.dart';
import 'package:pool_os/features/coach/presentation/coach_v2_provider.dart';
import 'package:pool_os/features/drill/domain/models/drill.dart';
import 'package:pool_os/features/training_center/domain/models/training_center_models.dart';
import 'package:pool_os/features/training_center/presentation/providers/training_center_providers.dart';
import 'package:pool_os/features/training_center/presentation/screens/category_drills_screen.dart';
import 'package:pool_os/features/training_center/presentation/screens/custom_drill_editor_screen.dart';
import 'package:pool_os/features/training_center/presentation/screens/progress_screen.dart';
import 'package:pool_os/features/training_center/presentation/screens/training_session_screen.dart';
import 'package:pool_os/features/knowledge/presentation/screens/knowledge_detail_screen.dart';
import 'package:pool_os/features/knowledge/presentation/providers/knowledge_providers.dart';
import 'package:pool_os/features/knowledge/presentation/screens/knowledge_library_screen.dart';
import 'package:pool_os/features/ghost_challenge/presentation/ghost_challenge_screen.dart';
import 'package:pool_os/features/match/domain/models/match.dart';
import 'package:pool_os/features/mastery/domain/models/mastery_models.dart';
import 'package:pool_os/features/mastery/presentation/mastery_providers.dart';
import 'package:pool_os/features/session/presentation/session_provider.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

/// Task 09 — Training Center home (Phần 7). Entry to the whole training system:
/// a "start session" action, a Progress shortcut, Recent drills (Phần 6), and
/// the Category list (Phần 1). Every list has an explicit empty state.
class TrainingCenterScreen extends ConsumerStatefulWidget {
  /// Task 15: when the Coach deep-links with ?category=<code>, open that drill
  /// category directly on first build (so "practice this shot" is one tap, not a
  /// hunt). Null = normal home entry.
  final String? initialCategory;

  /// Coach may deep-link to an entry in the Billiard Knowledge package.
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
      // Open the Coach recommendation after the first frame.
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
    final coachOutput = ref.watch(coachOutputProvider);
    final catalog = ref.watch(knowledgeCatalogProvider);
    final mastery = ref.watch(masterySnapshotProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.get('kb_learning_hub'))),
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
          ref.invalidate(masterySnapshotProvider);
          ref.invalidate(coachContextProvider);
          ref.invalidate(coachOutputProvider);
        },
        child: ListView(
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            _guidedLessonSection(
              context,
              coachOutput,
              catalog,
              mastery,
              locale,
            ),
            _actionRow(context, l10n),
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

  Widget _guidedLessonSection(
    BuildContext context,
    AsyncValue<CoachOutput> outputAsync,
    AsyncValue<KnowledgeCatalog> catalogAsync,
    AsyncValue<MasterySnapshot> masteryAsync,
    String locale,
  ) {
    final output = outputAsync.valueOrNull;
    final catalog = catalogAsync.valueOrNull;
    if (outputAsync.isLoading || catalogAsync.isLoading) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: LinearProgressIndicator(),
      );
    }
    if (output == null || catalog == null) return const SizedBox.shrink();

    final actions = <CoachAction>[
      if (output.primaryAction != null) output.primaryAction!,
      ...output.feed.map((item) => item.action).whereType<CoachAction>(),
    ];
    String? entryId;
    for (final action in actions) {
      final candidate = KnowledgeRegistry.articleFor(action.knowledgeId);
      if (candidate != null && catalog.entryById(candidate) != null) {
        entryId = candidate;
        break;
      }
    }
    if (entryId == null) return const SizedBox.shrink();

    final entry = catalog.entryById(entryId)!;
    final mastery = masteryAsync.valueOrNull?.entry(entryId);
    final lessonInsight = output.feed
        .where((item) =>
            item.action != null &&
            KnowledgeRegistry.articleFor(item.action!.knowledgeId) == entryId)
        .firstOrNull;
    final measuredScore = lessonInsight?.evidenceData['score'];
    final lessonScore =
        measuredScore is num ? measuredScore.toDouble() : mastery?.score;
    final vi = locale == 'vi';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            vi ? 'Bài học tiếp theo' : 'Next lesson',
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            entry.title.resolve(locale),
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(entry.summary.resolve(locale)),
          if (lessonScore != null) ...[
            const SizedBox(height: 10),
            LinearProgressIndicator(value: lessonScore / 100),
            const SizedBox(height: 4),
            Text('Mastery ${lessonScore.round()}%'),
          ],
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => KnowledgeDetailScreen(
                  knowledgeId: entryId!,
                  fromCoach: true,
                ),
              ),
            ),
            icon: const Icon(Icons.menu_book_outlined),
            label: Text(vi ? 'Học ngay' : 'Start lesson'),
          ),
        ],
      ),
    );
  }

  Widget _actionRow(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          Row(
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
                      builder: (_) => const CustomDrillEditorScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.get('tc_custom_drill')),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _startGhostChallenge(context),
              icon: const Icon(Icons.person_outline),
              label: Text(l10n.get('ghost_challenge')),
            ),
          ),
        ],
      ),
    );
  }

  /// Entry point to the standalone Billiard Knowledge package.
  Widget _knowledgeSection(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final vi = Localizations.localeOf(context).languageCode == 'vi';
    final catalogAsync = ref.watch(knowledgeCatalogProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            vi ? 'Từ điển bi-a' : 'Billiard Knowledge',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          catalogAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text(
              vi ? 'Không thể tải kho kiến thức.' : 'Unable to load knowledge.',
            ),
            data: (catalog) => Card(
              child: ListTile(
                leading: const Icon(Icons.menu_book_outlined),
                title: Text(
                    vi ? 'Nền tảng cho người mới' : 'Beginner fundamentals'),
                subtitle: Text(vi
                    ? '${catalog.entries.length} bài · ${catalog.paths.length} lộ trình'
                    : '${catalog.entries.length} entries · ${catalog.paths.length} path'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const KnowledgeLibraryScreen(),
                  ),
                ),
              ),
            ),
          ),
        ],
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

  Future<void> _startGhostChallenge(BuildContext context) async {
    final notifier = ref.read(sessionNotifierProvider.notifier);
    if (ref.read(sessionNotifierProvider).activeSession == null) {
      await notifier.createTrainingSession();
    }
    await notifier.createMatch(GameTypes.ghostChallenge);
    final match = ref.read(sessionNotifierProvider).activeMatch;
    if (!context.mounted || match?.id == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GhostChallengeScreen(matchId: match!.id!),
      ),
    );
  }
}
