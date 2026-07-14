import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/drill/domain/models/drill.dart';
import 'package:pool_os/features/training_center/data/repositories/training_center_repository.dart';
import 'package:pool_os/features/training_center/domain/models/training_center_models.dart';
import 'package:pool_os/features/training_center/presentation/providers/training_center_providers.dart';
import 'package:pool_os/features/training_center/presentation/screens/drill_picker_screen.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

/// Task 09 — Phần 2 Training Session. A live buổi luyện tập: add one or more
/// drills, tap Đạt / Miss to count each attempt, then Save. Everything persists
/// through [TrainingCenterRepository] — no recording-pipeline involvement.
///
/// A DB session row is created lazily on the first Save so an abandoned,
/// empty session never litters the table.
class TrainingSessionScreen extends ConsumerStatefulWidget {
  const TrainingSessionScreen({super.key});

  @override
  ConsumerState<TrainingSessionScreen> createState() =>
      _TrainingSessionScreenState();
}

class _DraftRun {
  final TrainingDrill drill;
  int attempts = 0;
  int successes = 0;
  _DraftRun(this.drill);

  double get rate => attempts == 0 ? 0.0 : successes / attempts;
}

class _TrainingSessionScreenState
    extends ConsumerState<TrainingSessionScreen> {
  final List<_DraftRun> _runs = [];
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.get('tc_session_title')),
        actions: [
          TextButton(
            onPressed: _runs.isEmpty || _saving ? null : () => _save(l10n),
            child: Text(l10n.get('tc_save')),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saving ? null : _addDrill,
        icon: const Icon(Icons.add),
        label: Text(l10n.get('tc_add_drill')),
      ),
      body: _runs.isEmpty
          ? _emptyState(context, l10n)
          : ListView.separated(
              padding: const EdgeInsets.only(bottom: 96),
              itemCount: _runs.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) =>
                  _runTile(context, _runs[i], locale, l10n),
            ),
    );
  }

  Widget _emptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sports_esports_outlined, size: 48),
            const SizedBox(height: 12),
            Text(
              l10n.get('tc_session_empty'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _runTile(BuildContext context, _DraftRun run, String locale,
      AppLocalizations l10n) {
    final pct = (run.rate * 100).round();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      run.drill.displayName(locale),
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${DrillCategory.getName(run.drill.category, locale)}'
                      ' · ${l10n.get('tc_target')} ${run.drill.targetReps}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => setState(() => _runs.remove(run)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${run.successes}/${run.attempts}  ·  $pct%',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const Spacer(),
              // Miss
              OutlinedButton(
                onPressed: () => setState(() => run.attempts++),
                child: Text(l10n.get('tc_miss')),
              ),
              const SizedBox(width: 8),
              // Đạt
              FilledButton(
                onPressed: () => setState(() {
                  run.attempts++;
                  run.successes++;
                }),
                child: Text(l10n.get('tc_hit')),
              ),
            ],
          ),
          if (run.attempts > 0)
            TextButton(
              onPressed: () => setState(() {
                if (run.attempts > 0) run.attempts--;
                if (run.successes > run.attempts) run.successes = run.attempts;
              }),
              child: Text(l10n.get('tc_undo')),
            ),
        ],
      ),
    );
  }

  Future<void> _addDrill() async {
    final picked = await Navigator.of(context).push<TrainingDrill>(
      MaterialPageRoute(builder: (_) => const DrillPickerScreen()),
    );
    if (picked == null) return;
    setState(() => _runs.add(_DraftRun(picked)));
  }

  Future<void> _save(AppLocalizations l10n) async {
    setState(() => _saving = true);
    try {
      final repo = ref.read(trainingCenterRepositoryProvider);
      final now = DateTime.now();
      final sessionId = await repo.createSession(
        TrainingSession(startedAt: now, completedAt: now),
      );
      for (final run in _runs) {
        await repo.addDrillRun(DrillRun(
          sessionId: sessionId,
          drillCode: run.drill.drillCode,
          customDrillId: run.drill.customDrillId,
          drillName: run.drill.name,
          category: run.drill.category,
          targetReps: run.drill.targetReps,
          attempts: run.attempts,
          successes: run.successes,
          createdAt: DateTime.now(),
        ));
      }
      // Refresh downstream views.
      ref.invalidate(recentDrillRunsProvider);
      ref.invalidate(recentTrainingSessionsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.get('tc_saved'))),
      );
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
