import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/goal_center/domain/models/goal_center_models.dart';
import 'package:pool_os/features/goal_center/presentation/providers/goal_center_providers.dart';
import 'package:pool_os/features/goal_center/presentation/screens/goal_editor_screen.dart';
import 'package:pool_os/features/goal_center/presentation/widgets/badge_tile.dart';
import 'package:pool_os/features/goal_center/presentation/widgets/goal_progress_card.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

/// Task 10 — Goal & Progress Center home (Phần 6 — Dashboard). Shows goals in
/// pursuit with live progress, plus achievements / streaks / milestones. All
/// data is computed read-only from recorded play; no AI, no recommendation.
class GoalCenterScreen extends ConsumerStatefulWidget {
  const GoalCenterScreen({super.key});

  @override
  ConsumerState<GoalCenterScreen> createState() => _GoalCenterScreenState();
}

class _GoalCenterScreenState extends ConsumerState<GoalCenterScreen> {
  @override
  void initState() {
    super.initState();
    // Seed default goals once, then let the providers load. Runs post-frame so
    // it never blocks the first paint.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final seeded = await ref.read(seedDefaultGoalsProvider.future);
      if (seeded && mounted) {
        ref.invalidate(goalsProvider);
        ref.invalidate(goalProgressProvider);
      }
    });
  }

  Future<void> _refresh() async {
    ref.invalidate(playerMetricsProvider);
    ref.invalidate(goalsProvider);
    ref.invalidate(goalProgressProvider);
    ref.invalidate(goalNoticesProvider);
    ref.invalidate(badgeBoardProvider);
    await ref.read(goalProgressProvider.future);
  }

  Future<void> _openEditor() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const GoalEditorScreen()),
    );
    if (created == true) await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final progressAsync = ref.watch(goalProgressProvider);
    final badgeAsync = ref.watch(badgeBoardProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.get('gc_title')),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openEditor,
        icon: const Icon(Icons.add),
        label: Text(l10n.get('gc_new_goal')),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            _buildGoalNotices(l10n),
            _sectionHeader(context, l10n.get('gc_section_goals'), Icons.flag),
            const SizedBox(height: 8),
            progressAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => _errorCard(l10n, e),
              data: (progresses) => _buildGoals(l10n, progresses),
            ),
            const SizedBox(height: 24),
            badgeAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (e, _) => _errorCard(l10n, e),
              data: (board) => _buildBadges(context, l10n, board),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalNotices(AppLocalizations l10n) {
    final noticesAsync = ref.watch(goalNoticesProvider);
    return noticesAsync.maybeWhen(
      data: (notices) {
        if (notices.isEmpty) return const SizedBox.shrink();
        return Column(
          children: notices.map((n) {
            final done = n.threshold >= 1.0;
            final title = n.goal.isDefault
                ? l10n.get(n.goal.title)
                : n.goal.title;
            return Card(
              color: (done ? Colors.green : Colors.blue).withAlpha(20),
              child: ListTile(
                leading: Icon(
                  done ? Icons.celebration : Icons.notifications_active,
                  color: done ? Colors.green : Colors.blue,
                ),
                title: Text(
                  done
                      ? l10n.get('gc_notice_done').replaceAll('{goal}', title)
                      : l10n
                          .get('gc_notice_progress')
                          .replaceAll('{goal}', title)
                          .replaceAll('{percent}', '${(n.threshold * 100).round()}'),
                ),
              ),
            );
          }).toList(),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildGoals(AppLocalizations l10n, List<GoalProgress> progresses) {
    if (progresses.isEmpty) {
      return _emptyCard(
        l10n,
        Icons.flag_outlined,
        l10n.get('gc_no_goals'),
      );
    }
    return Column(
      children: progresses.map((p) {
        return GoalProgressCard(
          progress: p,
          onDelete: p.goal.id == null
              ? null
              : () => _confirmDelete(l10n, p.goal),
        );
      }).toList(),
    );
  }

  Future<void> _confirmDelete(AppLocalizations l10n, Goal goal) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.get('gc_delete_goal')),
        content: Text(l10n.get('gc_delete_goal_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.get('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.get('delete')),
          ),
        ],
      ),
    );
    if (ok == true && goal.id != null) {
      await ref.read(goalCenterControllerProvider).deleteGoal(goal.id!);
      await _refresh();
    }
  }

  Widget _buildBadges(
    BuildContext context,
    AppLocalizations l10n,
    BadgeBoard board,
  ) {
    // Acknowledge new badges after showing them (clears the "mới" flag next open).
    if (board.newlyUnlocked.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(goalCenterControllerProvider).acknowledgeBadges(
              board.newlyUnlocked.map((b) => b.badge.key),
            );
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          context,
          l10n.get('gc_section_achievements'),
          Icons.emoji_events,
        ),
        const SizedBox(height: 8),
        ...board.achievements.map((s) => BadgeTile(status: s)),
        const SizedBox(height: 24),
        _sectionHeader(
          context,
          l10n.get('gc_section_streaks'),
          Icons.local_fire_department,
        ),
        const SizedBox(height: 8),
        ...board.streaks.map((s) => BadgeTile(status: s)),
        const SizedBox(height: 24),
        _sectionHeader(
          context,
          l10n.get('gc_section_milestones'),
          Icons.flag,
        ),
        const SizedBox(height: 8),
        ...board.milestones.map((s) => BadgeTile(status: s)),
      ],
    );
  }

  Widget _sectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _emptyCard(AppLocalizations l10n, IconData icon, String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(icon, size: 48, color: Colors.grey),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _errorCard(AppLocalizations l10n, Object error) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error_outline),
            const SizedBox(width: 12),
            Expanded(child: Text(l10n.get('error_loading_data'))),
          ],
        ),
      ),
    );
  }
}
