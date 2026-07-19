import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/drill/domain/models/drill.dart';
import 'package:pool_os/features/coach/presentation/coach_v2_provider.dart';
import 'package:pool_os/features/mastery/presentation/mastery_providers.dart';
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
  final TrainingDrill? initialDrill;
  final String? knowledgeEntryId;

  const TrainingSessionScreen({
    super.key,
    this.initialDrill,
    this.knowledgeEntryId,
  });

  @override
  ConsumerState<TrainingSessionScreen> createState() =>
      _TrainingSessionScreenState();
}

class _DraftRun {
  final TrainingDrill drill;
  final String? knowledgeEntryId;
  int attempts = 0;
  int successes = 0;
  final Map<String, int> missReasons = {};
  final List<String?> attemptReasons = [];
  final List<bool> attemptSuccesses = [];
  _DraftRun(this.drill, {this.knowledgeEntryId});

  double get rate => attempts == 0 ? 0.0 : successes / attempts;
}

class _TrainingSessionScreenState extends ConsumerState<TrainingSessionScreen> {
  final List<_DraftRun> _runs = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final initialDrill = widget.initialDrill;
    if (initialDrill != null) {
      _runs.add(_DraftRun(
        initialDrill,
        knowledgeEntryId: widget.knowledgeEntryId,
      ));
    }
  }

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
    final targetReached = run.attempts >= run.drill.targetReps;
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
                onPressed: targetReached ? null : () => _recordMiss(run, l10n),
                child: Text(l10n.get('tc_miss')),
              ),
              const SizedBox(width: 8),
              // Đạt
              FilledButton(
                onPressed: targetReached
                    ? null
                    : () => setState(() {
                          run.attempts++;
                          run.successes++;
                          run.attemptReasons.add(null);
                          run.attemptSuccesses.add(true);
                        }),
                child: Text(l10n.get('tc_hit')),
              ),
            ],
          ),
          if (run.attempts > 0)
            TextButton(
              onPressed: () => setState(() {
                if (run.attempts > 0) {
                  run.attempts--;
                  final reason = run.attemptReasons.removeLast();
                  final wasSuccessful = run.attemptSuccesses.removeLast();
                  if (wasSuccessful) run.successes--;
                  if (reason != null) {
                    final next = (run.missReasons[reason] ?? 1) - 1;
                    if (next == 0) {
                      run.missReasons.remove(reason);
                    } else {
                      run.missReasons[reason] = next;
                    }
                  }
                }
              }),
              child: Text(l10n.get('tc_undo')),
            ),
          if (targetReached)
            Text(
              '${l10n.get('tc_target')}: ${run.drill.targetReps}/${run.drill.targetReps}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          if (run.missReasons.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: run.missReasons.entries
                    .map((entry) => Chip(
                          label: Text('${entry.key}: ${entry.value}'),
                          visualDensity: VisualDensity.compact,
                        ))
                    .toList(),
              ),
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

  Future<void> _recordMiss(_DraftRun run, AppLocalizations l10n) async {
    final unknown = Localizations.localeOf(context).languageCode == 'vi'
        ? 'Không rõ'
        : 'Unknown';
    final reasons = [...run.drill.commonMistakes, unknown];
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final reason in reasons)
              ListTile(
                title: Text(reason),
                onTap: () => Navigator.pop(sheetContext, reason),
              ),
          ],
        ),
      ),
    );
    if (selected == null || !mounted) return;
    setState(() {
      run.attempts++;
      run.attemptReasons.add(selected);
      run.attemptSuccesses.add(false);
      run.missReasons.update(selected, (count) => count + 1, ifAbsent: () => 1);
    });
  }

  Future<void> _save(AppLocalizations l10n) async {
    setState(() => _saving = true);
    try {
      final repo = ref.read(trainingCenterRepositoryProvider);
      final now = DateTime.now();
      final sessionId = await repo.createSession(
        TrainingSession(startedAt: now, completedAt: now),
      );
      final savedRuns = <DrillRun>[];
      for (final run in _runs) {
        final saved = DrillRun(
          sessionId: sessionId,
          drillCode: run.drill.drillCode,
          customDrillId: run.drill.customDrillId,
          knowledgeEntryId: run.knowledgeEntryId,
          drillName: run.drill.name,
          category: run.drill.category,
          targetReps: run.drill.targetReps,
          attempts: run.attempts,
          successes: run.successes,
          createdAt: DateTime.now(),
        );
        final id = await repo.addDrillRun(saved);
        savedRuns.add(saved.copyWith(id: id));
      }
      // Refresh downstream views.
      ref.invalidate(recentDrillRunsProvider);
      ref.invalidate(recentTrainingSessionsProvider);
      ref.invalidate(masterySnapshotProvider);
      ref.invalidate(coachContextProvider);
      ref.invalidate(coachOutputProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.get('tc_saved'))),
      );
      Navigator.of(context).pop(TrainingCompletion(
        sessionId: sessionId,
        runs: List.unmodifiable(savedRuns),
      ));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
