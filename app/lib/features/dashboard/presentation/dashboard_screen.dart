import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pool_os/features/coach/domain/brain/coach_output.dart';
import 'package:pool_os/features/coach/presentation/coach_action_navigation.dart';
import 'package:pool_os/features/coach/presentation/coach_v2_provider.dart';
import 'package:pool_os/features/dashboard/presentation/dashboard_provider.dart';
import 'package:pool_os/features/session/domain/models/session.dart';
import 'package:pool_os/features/statistics/application/statistics_analytics_service.dart';
import 'package:pool_os/features/statistics/presentation/widgets/trend_chart.dart';
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
    final coachOutput = ref.watch(coachOutputProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.get('dashboard')),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
            tooltip: l10n.get('player'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
            tooltip: l10n.get('settings'),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? _errorState(context, state, l10n)
              : RefreshIndicator(
                  onRefresh: () => _refresh(),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                    children: [
                      _coachDecision(context, l10n, coachOutput),
                      const SizedBox(height: 16),
                      _readiness(context, state, l10n),
                      if (state.activeSession != null) ...[
                        const SizedBox(height: 16),
                        _activeSession(context, state, l10n),
                      ],
                      const SizedBox(height: 16),
                      _weeklyProgress(context, state, l10n),
                      const SizedBox(height: 16),
                      _statisticsSummary(context, l10n),
                    ],
                  ),
                ),
    );
  }

  Future<void> _refresh() async {
    ref.invalidate(coachContextProvider);
    ref.invalidate(coachOutputProvider);
    await ref.read(dashboardProvider.notifier).refresh();
  }

  Widget _coachDecision(
    BuildContext context,
    AppLocalizations l10n,
    AsyncValue<CoachOutput> outputAsync,
  ) {
    return _section(
      context,
      title: l10n.get('coach_v2_do_next'),
      action: TextButton(
        onPressed: () => context.go('/coach'),
        child: Text(l10n.get('see_all')),
      ),
      child: Card(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: outputAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => Row(
              children: [
                const Icon(Icons.info_outline),
                const SizedBox(width: 12),
                Expanded(child: Text(l10n.get('coach_v2_error'))),
              ],
            ),
            data: (output) => _coachDecisionContent(context, l10n, output),
          ),
        ),
      ),
    );
  }

  Widget _coachDecisionContent(
    BuildContext context,
    AppLocalizations l10n,
    CoachOutput output,
  ) {
    final action = output.primaryAction;
    if (action == null) {
      final insight = _firstActiveInsight(output);
      return Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              insight == null
                  ? l10n.get('coach_v2_all_clear')
                  : l10n.get(insight.observationKey),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      );
    }

    final insight = _insightForAction(output, action);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.flag_outlined, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.get(action.labelKey),
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (insight != null) ...[
                    const SizedBox(height: 4),
                    Text(_confidenceLabel(l10n, insight.confidence)),
                    if (insight.evidence.isNotEmpty)
                      Text(
                        insight.evidence,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => navigateCoachAction(context, action),
            icon: const Icon(Icons.arrow_forward),
            label: Text(l10n.get('coach_v2_go')),
          ),
        ),
      ],
    );
  }

  Widget _readiness(
    BuildContext context,
    DashboardState state,
    AppLocalizations l10n,
  ) {
    final readiness = state.todayReadiness;
    return _section(
      context,
      title: l10n.get('today_readiness'),
      child: Card(
        child: ListTile(
          onTap: () => context.push('/readiness'),
          leading: CircleAvatar(
            child: readiness == null
                ? const Icon(Icons.add)
                : Text('${readiness.overallScore}/10'),
          ),
          title: Text(
            readiness == null
                ? l10n.get('log_readiness')
                : '${l10n.get('energy_level')}: ${readiness.energyLevel ?? '-'} · '
                    '${l10n.get('focus_level')}: ${readiness.focusLevel ?? '-'}',
          ),
          subtitle: readiness == null ? Text(l10n.get('tap_to_log')) : null,
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }

  Widget _activeSession(
    BuildContext context,
    DashboardState state,
    AppLocalizations l10n,
  ) {
    final session = state.activeSession!;
    final isTraining = session.sessionType == SessionTypes.practice ||
        session.sessionType == SessionTypes.training;
    return _section(
      context,
      title: l10n.get('dashboard_active_session_question'),
      child: Card(
        child: ListTile(
          leading: const Icon(Icons.play_circle_outline),
          title: Text(l10n.get('dashboard_session_in_progress')),
          subtitle: Text(
            isTraining ? l10n.get('training') : l10n.get('match'),
          ),
          trailing: FilledButton.icon(
            onPressed: () => context.go(
              isTraining ? '/training-center' : '/session/match',
            ),
            icon: const Icon(Icons.arrow_forward),
            label: Text(l10n.get('continue_session')),
          ),
        ),
      ),
    );
  }

  Widget _weeklyProgress(
    BuildContext context,
    DashboardState state,
    AppLocalizations l10n,
  ) {
    return _section(
      context,
      title: l10n.get('weekly_trend'),
      action: TextButton(
        key: const ValueKey('dashboard.weekly.view_all'),
        onPressed: () => context.push('/statistics'),
        child: Text(l10n.get('see_all')),
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  _metric(
                    context,
                    '${state.weeklySessionCount}',
                    l10n.get('sessions'),
                  ),
                  _metric(
                    context,
                    '${state.weeklyRackCount}',
                    l10n.get('rack_count'),
                  ),
                  _metric(
                    context,
                    _formatDuration(state.weeklyPlayTime),
                    l10n.get('session_duration'),
                  ),
                ],
              ),
              if (state.currentStreak > 0) ...[
                const Divider(height: 24),
                Row(
                  children: [
                    const Icon(Icons.local_fire_department_outlined, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${state.currentStreak} ${l10n.get('current_streak')}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
              if (state.weeklyRackCount > 0) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${l10n.get('win_rate')}: '
                    '${(state.weeklyWinRate * 100).round()}%',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _metric(
    BuildContext context,
    String value,
    String label,
  ) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  CoachInsightV2? _insightForAction(
    CoachOutput output,
    CoachAction action,
  ) {
    for (final insight in output.feed) {
      if (insight.lifecycle == CoachLifecycle.active &&
          insight.action?.knowledgeId == action.knowledgeId) {
        return insight;
      }
    }
    return null;
  }

  CoachInsightV2? _firstActiveInsight(CoachOutput output) {
    for (final insight in output.feed) {
      if (insight.lifecycle == CoachLifecycle.active) return insight;
    }
    return null;
  }

  String _confidenceLabel(
    AppLocalizations l10n,
    CoachConfidence confidence,
  ) {
    return switch (confidence) {
      CoachConfidence.high => l10n.get('coach_v2_conf_high'),
      CoachConfidence.medium => l10n.get('coach_v2_conf_medium'),
      CoachConfidence.low => l10n.get('coach_v2_conf_low'),
      CoachConfidence.insufficient => l10n.get('coach_v2_conf_insufficient'),
    };
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return hours == 0 ? '${minutes}m' : '${hours}h ${minutes}m';
  }

  String _hours(Duration duration) => _formatDuration(duration);

  Widget _section(
    BuildContext context, {
    required String title,
    required Widget child,
    Widget? action,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            if (action != null) action,
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _statisticsSummary(BuildContext context, AppLocalizations l10n) {
    final dashboard = ref.watch(dashboardSnapshotProvider);
    return _section(
      context,
      title: l10n.get('statistics'),
      action: TextButton(
        onPressed: () => context.push('/statistics'),
        child: Text(l10n.get('see_all')),
      ),
      child: dashboard.when(
        data: (snap) => Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: StatisticsMetricTile(
                        label: 'Matches',
                        value: snap.totalMatches.toString(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatisticsMetricTile(
                        label: 'Sessions',
                        value: snap.totalSessions.toString(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatisticsMetricTile(
                        label: 'Hours',
                        value: _hours(snap.totalHours),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatisticsMetricTile(
                        label: 'Players',
                        value: snap.totalPlayers.toString(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: StatisticsMetricTile(
                        label: 'Win rate',
                        value:
                            '${(snap.winRate * 100).toStringAsFixed(0)}%',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatisticsMetricTile(
                        label: 'Active equipment',
                        value: snap.activeEquipment.toString(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatisticsMetricTile(
                        label: 'Equipment used',
                        value: snap.totalEquipmentUsed.toString(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TrendDirectionChip(summary: snap.recentPerformance),
                const SizedBox(height: 8),
                TrendLineChart(summary: snap.recentPerformance, height: 120),
              ],
            ),
          ),
        ),
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: LinearProgressIndicator(),
        ),
        error: (e, _) => Text(l10n.get('error')),
      ),
    );
  }

  Widget _errorState(
    BuildContext context,
    DashboardState state,
    AppLocalizations l10n,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(state.error ?? l10n.get('error')),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => _refresh(),
              icon: const Icon(Icons.refresh),
              label: Text(l10n.get('try_again')),
            ),
          ],
        ),
      ),
    );
  }
}
