import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/training_center/domain/models/training_center_models.dart';
import 'package:pool_os/features/training_center/domain/progress_calculator.dart';
import 'package:pool_os/features/training_center/data/repositories/training_center_repository.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

/// Phần 4 — Progress. Compares each drill's success rate in the previous window
/// (≈ last month) to the current window (≈ this month), e.g. Long Pot 58% →
/// 71%. Pure display of recorded data — no AI, no recommendation. Rebuilt from
/// [DrillRun] history via [ProgressCalculator].
final _progressByDrillProvider =
    FutureProvider<List<DrillProgress>>((ref) async {
  final repo = ref.watch(trainingCenterRepositoryProvider);
  final runs = await repo.getAllRuns();
  return const ProgressCalculator().byDrill(runs);
});

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(_progressByDrillProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.get('tc_progress_title'))),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.get('tc_load_error'))),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.get('tc_progress_empty'),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(_progressByDrillProvider),
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) =>
                  _progressTile(context, items[i], l10n),
            ),
          );
        },
      ),
    );
  }

  Widget _progressTile(
      BuildContext context, DrillProgress p, AppLocalizations l10n) {
    final prev = (p.previousRate * 100).round();
    final curr = (p.currentRate * 100).round();

    Widget trailing;
    if (!p.hasComparison) {
      // Only one window has data — show the single rate, no misleading arrow.
      final only = p.currentAttempts > 0 ? curr : prev;
      trailing = Text(
        '$only%',
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.bold),
      );
    } else {
      final delta = p.deltaPoints.round();
      final up = delta > 0;
      final flat = delta == 0;
      final color = flat
          ? Theme.of(context).colorScheme.onSurfaceVariant
          : (up ? Colors.green : Colors.red);
      trailing = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$prev%  →  ',
              style: Theme.of(context).textTheme.bodyMedium),
          Text(
            '$curr%',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(width: 4),
          Icon(
            flat
                ? Icons.remove
                : (up ? Icons.arrow_upward : Icons.arrow_downward),
            size: 16,
            color: color,
          ),
        ],
      );
    }

    return ListTile(
      title: Text(p.label),
      subtitle: Text(
        p.hasComparison
            ? '${l10n.get('tc_prev')} · ${l10n.get('tc_current')}'
            : l10n.get('tc_progress_need_more'),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: trailing,
    );
  }
}
