import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/drill/domain/models/drill.dart';
import 'package:pool_os/features/training_center/domain/models/training_center_models.dart';
import 'package:pool_os/features/training_center/presentation/providers/training_center_providers.dart';
import 'package:pool_os/features/training_center/presentation/screens/category_drills_screen.dart';
import 'package:pool_os/features/training_center/presentation/screens/custom_drill_editor_screen.dart';
import 'package:pool_os/features/training_center/presentation/screens/progress_screen.dart';
import 'package:pool_os/features/training_center/presentation/screens/training_session_screen.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

/// Task 09 — Training Center home (Phần 7). Entry to the whole training system:
/// a "start session" action, a Progress shortcut, Recent drills (Phần 6), and
/// the Category list (Phần 1). Every list has an explicit empty state.
class TrainingCenterScreen extends ConsumerWidget {
  const TrainingCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            _recentSection(context, ref, l10n, locale),
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

  Widget _categoryList(BuildContext context,
      Map<String, List<TrainingDrill>> grouped, String locale, AppLocalizations l10n) {
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
