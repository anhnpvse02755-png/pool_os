import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/goal/domain/models/daily_goal.dart';
import 'package:pool_os/features/goal/presentation/goal_provider.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

class GoalTrackingScreen extends ConsumerWidget {
  const GoalTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(goalTrackerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.get('today_goal')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddGoalDialog(context, ref, l10n),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildProgressHeader(context, state, l10n),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    tabs: [
                      Tab(text: 'Today\'s Goals'),
                      Tab(text: 'All Goals'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildTodayGoals(context, ref, state, l10n),
                        _buildAllGoals(context, ref, state, l10n),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressHeader(
    BuildContext context,
    GoalTrackerState state,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Today\'s Progress',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '${state.completedToday}/${state.totalToday}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: state.todayProgress,
                  minHeight: 12,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${(state.todayProgress * 100).toInt()}% complete',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayGoals(
    BuildContext context,
    WidgetRef ref,
    GoalTrackerState state,
    AppLocalizations l10n,
  ) {
    if (state.todayGoals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flag_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No goals for today',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () => _showAddGoalDialog(context, ref, l10n),
              icon: const Icon(Icons.add),
              label: const Text('Add Goal'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.todayGoals.length,
      itemBuilder: (context, index) {
        final goal = state.todayGoals[index];
        return _buildGoalCard(context, ref, goal, l10n);
      },
    );
  }

  Widget _buildAllGoals(
    BuildContext context,
    WidgetRef ref,
    GoalTrackerState state,
    AppLocalizations l10n,
  ) {
    if (state.goals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flag_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No goals yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    final groupedGoals = <GoalCategory, List<DailyGoal>>{};
    for (final goal in state.goals) {
      groupedGoals.putIfAbsent(goal.category, () => []).add(goal);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedGoals.length,
      itemBuilder: (context, index) {
        final category = groupedGoals.keys.elementAt(index);
        final categoryGoals = groupedGoals[category]!;
        final locale = Localizations.localeOf(context);
        final isVietnamese = locale.languageCode == 'vi';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                isVietnamese ? category.getDisplayNameVi() : category.getDisplayName(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            ...categoryGoals.map((goal) => _buildGoalCard(context, ref, goal, l10n)),
          ],
        );
      },
    );
  }

  Widget _buildGoalCard(
    BuildContext context,
    WidgetRef ref,
    DailyGoal goal,
    AppLocalizations l10n,
  ) {
    final locale = Localizations.localeOf(context);
    final isVietnamese = locale.languageCode == 'vi';
    final title = isVietnamese ? goal.titleVi : goal.title;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildPriorityIndicator(goal.priority),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          decoration: goal.isComplete
                              ? TextDecoration.lineThrough
                              : null,
                          color: goal.isComplete ? Colors.grey : null,
                        ),
                  ),
                ),
                Checkbox(
                  value: goal.isComplete,
                  onChanged: (value) {
                    if (value == true) {
                      ref.read(goalTrackerProvider.notifier).completeGoal(goal.id!);
                    } else {
                      ref.read(goalTrackerProvider.notifier).uncompleteGoal(goal.id!);
                    }
                  },
                ),
              ],
            ),
            if (goal.unit.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: goal.progress,
                        minHeight: 8,
                        backgroundColor: goal.isComplete
                            ? Colors.green.withAlpha(51)
                            : goal.priority.getColor().withAlpha(51),
                        valueColor: AlwaysStoppedAnimation(
                          goal.isComplete
                              ? Colors.green
                              : goal.priority.getColor(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${goal.currentValue}/${goal.targetValue} ${goal.unit}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                if (!goal.isComplete && goal.unit.isEmpty)
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, size: 20),
                        onPressed: () => ref
                            .read(goalTrackerProvider.notifier)
                            .decrementProgress(goal.id!),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, size: 20),
                        onPressed: () => ref
                            .read(goalTrackerProvider.notifier)
                            .incrementProgress(goal.id!),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                const Spacer(),
                if (goal.isRecurring)
                  Chip(
                    label: Text(
                      goal.recurrence?.getDisplayName() ?? 'Recurring',
                      style: const TextStyle(fontSize: 10),
                    ),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'abandon') {
                      ref.read(goalTrackerProvider.notifier).abandonGoal(goal.id!);
                    } else if (value == 'delete') {
                      ref.read(goalTrackerProvider.notifier).removeGoal(goal.id!);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'abandon',
                      child: Row(
                        children: [
                          Icon(Icons.pause_circle_outline, size: 20),
                          SizedBox(width: 8),
                          Text('Abandon'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityIndicator(GoalPriority priority) {
    return Container(
      width: 4,
      height: 40,
      decoration: BoxDecoration(
        color: priority.getColor(),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => AddGoalSheet(ref: ref, l10n: l10n),
    );
  }
}

class AddGoalSheet extends StatefulWidget {
  final WidgetRef ref;
  final AppLocalizations l10n;

  const AddGoalSheet({super.key, required this.ref, required this.l10n});

  @override
  State<AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends State<AddGoalSheet> {
  final _titleController = TextEditingController();
  final _titleViController = TextEditingController();
  GoalCategory _category = GoalCategory.practice;
  GoalPriority _priority = GoalPriority.medium;
  GoalRecurrencePattern _recurrence = GoalRecurrencePattern.daily;
  bool _isRecurring = true;
  int _targetValue = 1;
  String _unit = '';

  @override
  void dispose() {
    _titleController.dispose();
    _titleViController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add New Goal',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title (English)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleViController,
              decoration: const InputDecoration(
                labelText: 'Title (Vietnamese)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<GoalCategory>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: GoalCategory.values.map((c) {
                return DropdownMenuItem(
                  value: c,
                  child: Text(c.getDisplayName()),
                );
              }).toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<GoalPriority>(
              value: _priority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              items: GoalPriority.values.map((p) {
                return DropdownMenuItem(
                  value: p,
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: p.getColor(),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(p.getDisplayName()),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (v) => setState(() => _priority = v!),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Recurring Goal'),
              value: _isRecurring,
              onChanged: (v) => setState(() => _isRecurring = v),
            ),
            if (_isRecurring) ...[
              DropdownButtonFormField<GoalRecurrencePattern>(
                value: _recurrence,
                decoration: const InputDecoration(
                  labelText: 'Frequency',
                  border: OutlineInputBorder(),
                ),
                items: GoalRecurrencePattern.values.map((r) {
                  return DropdownMenuItem(
                    value: r,
                    child: Text(r.getDisplayName()),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _recurrence = v!),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _addGoal,
                child: const Text('Add Goal'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addGoal() {
    if (_titleController.text.isEmpty) return;

    final goal = DailyGoal(
      title: _titleController.text,
      titleVi: _titleViController.text.isNotEmpty
          ? _titleViController.text
          : _titleController.text,
      category: _category,
      priority: _priority,
      targetValue: _targetValue,
      currentValue: 0,
      unit: _unit,
      createdAt: DateTime.now(),
      isRecurring: _isRecurring,
      recurrence: _isRecurring ? _recurrence : null,
    );

    widget.ref.read(goalTrackerProvider.notifier).addGoal(goal);
    Navigator.pop(context);
  }
}

typedef GoalRecurrencePattern = RecurrencePattern;
