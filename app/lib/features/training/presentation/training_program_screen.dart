import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/training/domain/models/training_program.dart';
import 'package:pool_os/features/training/presentation/training_provider.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

class TrainingProgramScreen extends ConsumerWidget {
  const TrainingProgramScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final programs = ref.watch(trainingProgramLibraryProvider);
    final activeState = ref.watch(activeProgramProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.get('training_program')),
      ),
      body: activeState.hasActiveProgram
          ? _buildActiveProgramView(context, ref, activeState, l10n)
          : _buildProgramList(context, ref, programs, l10n),
    );
  }

  Widget _buildActiveProgramView(
    BuildContext context,
    WidgetRef ref,
    ActiveProgramState state,
    AppLocalizations l10n,
  ) {
    final program = state.program!;
    final progress = state.progress!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressHeader(context, program, progress, l10n),
          const SizedBox(height: 16),
          _buildCurrentSession(context, ref, state, l10n),
          const SizedBox(height: 16),
          _buildUpcomingSessions(context, ref, l10n),
          const SizedBox(height: 16),
          _buildProgramOverview(context, program, l10n),
          const SizedBox(height: 24),
          _buildWithdrawButton(context, ref, l10n),
        ],
      ),
    );
  }

  Widget _buildProgressHeader(
    BuildContext context,
    TrainingProgram program,
    ProgramProgress progress,
    AppLocalizations l10n,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    program.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Week ${progress.currentWeek}/${program.durationWeeks}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress.overallProgress,
                minHeight: 12,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(progress.overallProgress * 100).toInt()}% Complete',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  '${progress.completedSessions}/${progress.totalSessions} sessions',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentSession(
    BuildContext context,
    WidgetRef ref,
    ActiveProgramState state,
    AppLocalizations l10n,
  ) {
    final session = state.currentSession;
    if (session == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(Icons.celebration, size: 48, color: Colors.green),
              const SizedBox(height: 16),
              Text(
                'Program Complete!',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    final locale = Localizations.localeOf(context);
    final isVietnamese = locale.languageCode == 'vi';
    final title = isVietnamese ? session.titleVi : session.title;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Next Session',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildSessionChip(Icons.calendar_today, 'Week ${session.weekNumber}'),
                const SizedBox(width: 8),
                _buildSessionChip(Icons.timer, '${session.durationMinutes} min'),
                const SizedBox(width: 8),
                _buildSessionChip(Icons.fitness_center, _getSessionTypeLabel(session.type, l10n)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _startSession(context, ref, session),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Session'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildUpcomingSessions(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final upcoming = ref.watch(upcomingSessionsProvider);

    if (upcoming.isEmpty) return const SizedBox.shrink();

    final locale = Localizations.localeOf(context);
    final isVietnamese = locale.languageCode == 'vi';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upcoming Sessions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        ...upcoming.take(5).map(
              (session) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text('W${session.weekNumber}'),
                  ),
                  title: Text(isVietnamese ? session.titleVi : session.title),
                  subtitle: Text('${session.durationMinutes} min'),
                  trailing: Icon(
                    _getSessionTypeIcon(session.type),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
      ],
    );
  }

  Widget _buildProgramOverview(
    BuildContext context,
    TrainingProgram program,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Program Overview',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildOverviewRow(context, 'Duration', '${program.durationWeeks} weeks'),
                const Divider(),
                _buildOverviewRow(context, 'Sessions/Week', '${program.sessionsPerWeek}'),
                const Divider(),
                _buildOverviewRow(context, 'Session Length', '${program.minutesPerSession} min'),
                const Divider(),
                _buildOverviewRow(context, 'Total Sessions', '${program.totalSessions}'),
                const Divider(),
                _buildOverviewRow(context, 'Focus Areas', program.focusAreas.join(', ')),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawButton(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    return Center(
      child: TextButton.icon(
        onPressed: () => _confirmWithdraw(context, ref, l10n),
        icon: const Icon(Icons.exit_to_app, color: Colors.red),
        label: const Text('Withdraw from Program', style: TextStyle(color: Colors.red)),
      ),
    );
  }

  Widget _buildProgramList(
    BuildContext context,
    WidgetRef ref,
    List<TrainingProgram> programs,
    AppLocalizations l10n,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: programs.length,
      itemBuilder: (context, index) {
        final program = programs[index];
        return _buildProgramCard(context, ref, program, l10n);
      },
    );
  }

  Widget _buildProgramCard(
    BuildContext context,
    WidgetRef ref,
    TrainingProgram program,
    AppLocalizations l10n,
  ) {
    final locale = Localizations.localeOf(context);
    final isVietnamese = locale.languageCode == 'vi';
    final name = isVietnamese ? program.nameVi : program.name;
    final description = isVietnamese ? program.descriptionVi : program.description;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showProgramDetails(context, ref, program, l10n),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  _buildDifficultyBadge(context, program.difficulty),
                ],
              ),
              const SizedBox(height: 8),
              Text(description),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildProgramStat(Icons.calendar_today, '${program.durationWeeks} weeks'),
                  const SizedBox(width: 16),
                  _buildProgramStat(Icons.fitness_center, '${program.sessionsPerWeek}/week'),
                  const SizedBox(width: 16),
                  _buildProgramStat(Icons.timer, '${program.minutesPerSession} min'),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => _enrollInProgram(context, ref, program),
                  child: const Text('Start Program'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgramStat(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildDifficultyBadge(BuildContext context, int difficulty) {
    final color = switch (difficulty) {
      1 => Colors.green,
      2 => Colors.blue,
      3 => Colors.orange,
      _ => Colors.grey,
    };
    final label = switch (difficulty) {
      1 => 'Beginner',
      2 => 'Intermediate',
      3 => 'Advanced',
      _ => 'All Levels',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showProgramDetails(
    BuildContext context,
    WidgetRef ref,
    TrainingProgram program,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          final locale = Localizations.localeOf(context);
          final isVietnamese = locale.languageCode == 'vi';

          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  isVietnamese ? program.nameVi : program.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(isVietnamese ? program.descriptionVi : program.description),
                const SizedBox(height: 24),
                Text(
                  'Phases',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                ...program.phases.map(
                  (phase) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text('${phase.weekStart}-${phase.weekEnd}'),
                      ),
                      title: Text(isVietnamese ? phase.nameVi : phase.name),
                      subtitle: Text(isVietnamese ? phase.descriptionVi : phase.description),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _enrollInProgram(context, ref, program);
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Enroll in Program'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _enrollInProgram(BuildContext context, WidgetRef ref, TrainingProgram program) {
    ref.read(activeProgramProvider.notifier).enrollInProgram(program);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Enrolled in ${program.name}'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {},
        ),
      ),
    );
  }

  void _confirmWithdraw(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Withdraw from Program?'),
        content: const Text('Your progress will be saved but you will need to restart.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.get('cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(activeProgramProvider.notifier).withdrawFromProgram();
              Navigator.pop(ctx);
            },
            child: Text(l10n.get('confirm')),
          ),
        ],
      ),
    );
  }

  void _startSession(BuildContext context, WidgetRef ref, TrainingSession session) {
    ref.read(activeProgramProvider.notifier).startSession(session);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting ${session.title}'),
        action: SnackBarAction(
          label: 'Complete',
          onPressed: () {
            ref.read(activeProgramProvider.notifier).completeCurrentSession();
          },
        ),
      ),
    );
  }

  String _getSessionTypeLabel(SessionType type, AppLocalizations l10n) {
    return switch (type) {
      SessionType.warmUp => l10n.get('warm_up'),
      SessionType.drill => l10n.get('drill'),
      SessionType.practice => l10n.get('practice'),
      SessionType.match => l10n.get('match'),
      SessionType.review => 'Review',
      SessionType.rest => 'Rest',
    };
  }

  IconData _getSessionTypeIcon(SessionType type) {
    return switch (type) {
      SessionType.warmUp => Icons.wb_sunny,
      SessionType.drill => Icons.fitness_center,
      SessionType.practice => Icons.sports_bar,
      SessionType.match => Icons.emoji_events,
      SessionType.review => Icons.rate_review,
      SessionType.rest => Icons.self_improvement,
    };
  }
}
