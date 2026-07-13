import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pool_os/features/dashboard/presentation/dashboard_provider.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardProvider.notifier).loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.get('dashboard')),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
            tooltip: l10n.get('settings'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(dashboardProvider.notifier).refresh(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? _buildErrorState(context, state, l10n)
              : RefreshIndicator(
              onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildQuickActions(context, state, l10n),
                    const SizedBox(height: 24),
                    _buildTodayFocusSection(context, state, l10n),
                    const SizedBox(height: 24),
                    _buildStatsGrid(context, state, l10n),
                    const SizedBox(height: 24),
                    _buildReadinessSection(context, state, l10n),
                    const SizedBox(height: 24),
                    _buildEquipmentSection(context, state, l10n),
                    const SizedBox(height: 24),
                    _buildCoachSection(context, state, l10n),
                    const SizedBox(height: 24),
                    _buildSkillRadarSection(context, state, l10n),
                    const SizedBox(height: 24),
                    _buildWeeklyTrend(context, state, l10n),
                    const SizedBox(height: 24),
                    _buildMonthlyTrend(context, state, l10n),
                    const SizedBox(height: 24),
                    _buildLastMatchesSection(context, state, l10n),
                    const SizedBox(height: 24),
                    _buildRecentSessions(context, state, l10n),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildQuickActions(BuildContext context, DashboardState state, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.get('quick_actions'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            if (state.activeSession == null) ...[
              _buildQuickAction(
                context,
                Icons.sports_bar,
                l10n.get('start_practice'),
                Colors.blue,
                () => context.go('/session'),
              ),
              _buildQuickAction(
                context,
                Icons.emoji_events,
                l10n.get('start_match'),
                Colors.orange,
                () => context.go('/session'),
              ),
            ] else ...[
              _buildQuickAction(
                context,
                Icons.play_arrow,
                l10n.get('continue_session'),
                Colors.green,
                () => context.go('/session'),
              ),
              _buildQuickAction(
                context,
                Icons.stop,
                l10n.get('finish_session'),
                Colors.red,
                () => context.go('/session'),
              ),
            ],
            _buildQuickAction(
              context,
              Icons.person,
              l10n.get('daily_readiness'),
              Colors.purple,
              () => context.go('/readiness'),
            ),
            // Task 09: entry to the Training Center (drill library, sessions,
            // progress). Pushed as a top-level route outside the nav shell.
            _buildQuickAction(
              context,
              Icons.sports_esports,
              l10n.get('training_center_title'),
              Colors.teal,
              () => context.push('/training-center'),
            ),
            // Task 10: entry to the Goal & Progress Center (goals,
            // achievements, streaks, milestones). Top-level route.
            _buildQuickAction(
              context,
              Icons.flag,
              l10n.get('gc_title'),
              Colors.indigo,
              () => context.push('/goal-center'),
            ),
            // Task 11: entry to the Player Timeline & Career — read-only
            // development journal. Top-level route.
            _buildQuickAction(
              context,
              Icons.timeline,
              l10n.get('career_title'),
              Colors.brown,
              () => context.push('/career'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(51)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayFocusSection(BuildContext context, DashboardState state, AppLocalizations l10n) {
    final focus = state.todayFocus;
    if (focus == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.get('today_focus'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          color: Colors.purple.withAlpha(13),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.purple.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.gps_fixed, color: Colors.purple),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    focus,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.purple.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context, DashboardState state, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.get('quick_stats'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                Icons.local_fire_department,
                '${state.currentStreak}',
                l10n.get('current_streak'),
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                Icons.timer,
                _formatHours(state.weeklyPlayTime),
                l10n.get('weekly_hours'),
                Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                Icons.sports_bar,
                '${state.todaySessionCount}',
                l10n.get('sessions'),
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                Icons.emoji_events,
                '${(state.todayWinRate * 100).toInt()}%',
                l10n.get('rack_win'),
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, IconData icon, String value, String label, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  String _formatHours(Duration duration) {
    final hours = duration.inMinutes / 60;
    if (hours >= 1) {
      return '${hours.toStringAsFixed(1)}h';
    }
    return '${duration.inMinutes}m';
  }

  Widget _buildSkillRadarSection(BuildContext context, DashboardState state, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.get('skill_radar'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              // RFC-302 Task 7: no '/skills' route exists (Skill Radar screen
              // was never built) -> context.go('/skills') threw GoException
              // "no routes for location". Point at Statistics, the existing
              // read-only screen that surfaces skill data.
              onPressed: () => context.go('/statistics'),
              child: Text(l10n.get('see_all')),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: state.topSkills.isEmpty
                ? Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.radar,
                          size: 48,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.get('no_skills'),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey,
                              ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: state.topSkills.take(5).map((skill) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                skill.category,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: LinearProgressIndicator(
                                value: skill.score / 100,
                                backgroundColor: Colors.grey.withAlpha(51),
                                valueColor: AlwaysStoppedAnimation(_getScoreColor(skill.score.round())),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${skill.score}%',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildLastMatchesSection(BuildContext context, DashboardState state, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.get('last_matches'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => context.go('/session'),
              child: Text(l10n.get('see_all')),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (state.lastMatches.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.emoji_events_outlined,
                      size: 48,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.get('no_matches'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.lastMatches.take(5).length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final match = state.lastMatches[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: match.winner == 'Player' 
                        ? Colors.green.withAlpha(26) 
                        : Colors.red.withAlpha(26),
                    child: Icon(
                      match.winner == 'Player' ? Icons.emoji_events : Icons.close,
                      color: match.winner == 'Player' ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text(match.opponent ?? l10n.get('practice')),
                  subtitle: Text(match.startTime != null 
                      ? _formatDate(match.startTime!, l10n) 
                      : l10n.get('unknown_date')),
                  trailing: match.winner != null
                      ?                     Chip(
                          label: Text(
                            match.winner == 'Player' ? l10n.get('won') : l10n.get('lost'),
                            style: TextStyle(
                              color: match.winner == 'Player' ? Colors.green : Colors.red,
                            ),
                          ),
                          backgroundColor: match.winner == 'Player'
                              ? Colors.green.withAlpha(26)
                              : Colors.red.withAlpha(26),
                        )
                      : Chip(
                          label: Text(l10n.get('in_progress')),
                          backgroundColor: const Color(0x1A2196F3),
                        ),
                  onTap: () => context.go('/match/${match.id}'),
                );
              },
            ),
          ),
      ],
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 8) return Colors.green;
    if (score >= 6) return Colors.lightGreen;
    if (score >= 4) return Colors.amber;
    if (score >= 2) return Colors.orange;
    return Colors.red;
  }

  Widget _buildReadinessSection(BuildContext context, DashboardState state, AppLocalizations l10n) {
    final readiness = state.todayReadiness;
    final score = readiness?.overallScore ?? 0;
    final color = _getScoreColor(score);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.get('today_readiness'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: InkWell(
            onTap: () => context.go('/readiness'),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: readiness == null || !readiness.isComplete
                  ? _buildEmptyReadiness(context, l10n)
                  : _buildCompletedReadiness(context, readiness, score, color, l10n),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyReadiness(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.withAlpha(26),
          ),
          child: const Icon(Icons.add, color: Colors.grey),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.get('log_readiness'),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                l10n.get('tap_to_log'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right, color: Colors.grey),
      ],
    );
  }

  Widget _buildCompletedReadiness(
    BuildContext context,
    dynamic readiness,
    int score,
    Color color,
    AppLocalizations l10n,
  ) {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withAlpha(51),
            border: Border.all(color: color, width: 3),
          ),
          child: Center(
            child: Text(
              '$score',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getScoreLabel(score, l10n),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(color: color),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  if (readiness.energyLevel != null)
                    _buildMiniStat(Icons.bolt, '${readiness.energyLevel}/10', Colors.amber),
                  if (readiness.focusLevel != null) ...[
                    const SizedBox(width: 12),
                    _buildMiniStat(Icons.center_focus_strong, '${readiness.focusLevel}/10', Colors.blue),
                  ],
                ],
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right, color: Colors.grey),
      ],
    );
  }

  Widget _buildMiniStat(IconData icon, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 2),
        Text(
          value,
          style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildEquipmentSection(BuildContext context, DashboardState state, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.get('current_equipment'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: InkWell(
            onTap: () => context.go('/equipment'),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: state.activeCue == null
                  ? _buildEmptyEquipment(context, l10n)
                  : _buildEquipmentCard(context, state, l10n),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyEquipment(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.withAlpha(26),
          ),
          child: const Icon(Icons.sports_esports, color: Colors.grey),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            l10n.get('add_equipment'),
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        const Icon(Icons.chevron_right, color: Colors.grey),
      ],
    );
  }

  Widget _buildEquipmentCard(BuildContext context, DashboardState state, AppLocalizations l10n) {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.blue.withAlpha(26),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.straight, color: Colors.blue, size: 32),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  state.activeCue?.name ?? l10n.get('unknown_cue'),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '${l10n.get('weight')}: ${state.activeCue?.weight ?? 0} oz',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
              if (state.activeBreakCue != null) ...[
                const SizedBox(height: 2),
                Text(
                  '${l10n.get('break_cue')}: ${state.activeBreakCue!.name}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
        const Icon(Icons.chevron_right, color: Colors.grey),
      ],
    );
  }

  Widget _buildCoachSection(BuildContext context, DashboardState state, AppLocalizations l10n) {
    final insight = state.coachInsight;
    if (insight == null) return const SizedBox.shrink();

    final color = insight.type == 'success' ? Colors.green : (insight.type == 'warning' ? Colors.orange : Colors.blue);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.get('coach_insight'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          color: color.withAlpha(13),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      insight.type == 'success' ? Icons.check_circle : (insight.type == 'warning' ? Icons.warning : Icons.info),
                      color: color,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        insight.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  insight.message,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (insight.recommendations.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ...insight.recommendations.map(
                    (rec) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                          Expanded(child: Text(rec)),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyTrend(BuildContext context, DashboardState state, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.get('weekly_trend'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTrendItem(
                  context,
                  state.weeklySessionCount.toString(),
                  l10n.get('sessions'),
                  Colors.blue,
                ),
                _buildTrendItem(
                  context,
                  state.weeklyRackCount.toString(),
                  l10n.get('rack_count'),
                  Colors.green,
                ),
                _buildTrendItem(
                  context,
                  '${(state.weeklyWinRate * 100).toInt()}%',
                  l10n.get('rack_win'),
                  Colors.orange,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendItem(BuildContext context, String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildMonthlyTrend(BuildContext context, DashboardState state, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.get('monthly_trend'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTrendItem(
                  context,
                  state.monthlySessionCount.toString(),
                  l10n.get('sessions'),
                  Colors.blue,
                ),
                _buildTrendItem(
                  context,
                  state.monthlyRackCount.toString(),
                  l10n.get('rack_count'),
                  Colors.green,
                ),
                _buildTrendItem(
                  context,
                  '${(state.monthlyWinRate * 100).toInt()}%',
                  l10n.get('rack_win'),
                  Colors.orange,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentSessions(BuildContext context, DashboardState state, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.get('recent_sessions'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => context.go('/session'),
              child: Text(l10n.get('see_all')),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (state.recentSessions.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.sports_bar_outlined,
                      size: 48,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.get('no_sessions_yet'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...state.recentSessions.map(
            (session) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getSessionIcon(session.type),
                    color: Colors.blue,
                  ),
                ),
                title: Text(
                  _getSessionTypeLabel(session.type, l10n),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '${_formatDate(session.date, l10n)} • ${session.rackCount} ${l10n.get('rack_count').toLowerCase()}',
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${(session.accuracy * 100).toInt()}%',
                      style: TextStyle(
                        color: _getAccuracyColor(session.accuracy),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatDuration(session.duration),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
                onTap: () => context.go('/session'),
              ),
            ),
          ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }

  String _formatDate(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionDate = DateTime(date.year, date.month, date.day);

    if (sessionDate == today) {
      return l10n.get('today');
    } else if (sessionDate == today.subtract(const Duration(days: 1))) {
      return l10n.get('yesterday');
    } else {
      return '${date.day}/${date.month}';
    }
  }

  IconData _getSessionIcon(String type) {
    switch (type) {
      case 'practice':
        return Icons.fitness_center;
      case 'match':
        return Icons.emoji_events;
      default:
        return Icons.sports_bar;
    }
  }

  String _getSessionTypeLabel(String type, AppLocalizations l10n) {
    switch (type) {
      case 'practice':
        return l10n.get('practice');
      case 'match':
        return l10n.get('match');
      default:
        return type;
    }
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 0.8) return Colors.green;
    if (accuracy >= 0.6) return Colors.lightGreen;
    if (accuracy >= 0.4) return Colors.amber;
    return Colors.red;
  }

  String _getScoreLabel(int score, AppLocalizations l10n) {
    if (score >= 8) return l10n.get('readiness_excellent');
    if (score >= 6) return l10n.get('readiness_good');
    if (score >= 4) return l10n.get('readiness_moderate');
    if (score >= 2) return l10n.get('readiness_low');
    return l10n.get('readiness_poor');
  }

  Widget _buildErrorState(BuildContext context, DashboardState state, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.get('error_loading_data'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              state.error ?? l10n.get('unknown_error'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => ref.read(dashboardProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh),
              label: Text(l10n.get('retry')),
            ),
          ],
        ),
      ),
    );
  }
}
