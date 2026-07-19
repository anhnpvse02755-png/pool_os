import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pool_os/features/dashboard/presentation/dashboard_provider.dart';
import 'package:pool_os/features/skill/presentation/widgets/skill_radar_chart_widget.dart';
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
                  onRefresh: () =>
                      ref.read(dashboardProvider.notifier).refresh(),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                    children: [
                      _todayFocus(context, state, l10n),
                      const SizedBox(height: 20),
                      _progress(context, state, l10n),
                      const SizedBox(height: 20),
                      _activeSession(context, state, l10n),
                      const SizedBox(height: 20),
                      _coach(context, state, l10n),
                    ],
                  ),
                ),
    );
  }

  Widget _todayFocus(
      BuildContext context, DashboardState state, AppLocalizations l10n) {
    final focus = state.todayFocus;
    return _section(
      context,
      title: l10n.get('today_focus'),
      child: Card(
        child: ListTile(
          leading: const Icon(Icons.gps_fixed),
          title: Text(
            focus ?? l10n.get('dashboard_focus_insufficient'),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: focus == null
              ? Text(l10n.get('dashboard_focus_insufficient_detail'))
              : null,
        ),
      ),
    );
  }

  Widget _progress(
      BuildContext context, DashboardState state, AppLocalizations l10n) {
    return _section(
      context,
      title: l10n.get('dashboard_progress_question'),
      action: TextButton(
        onPressed: () => context.push('/statistics'),
        child: Text(l10n.get('see_all')),
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: state.topSkills.isEmpty
              ? SizedBox(
                  height: 120,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.radar, size: 36),
                        const SizedBox(height: 8),
                        Text(l10n.get('no_skills')),
                      ],
                    ),
                  ),
                )
              : Center(
                  child: SkillRadarChartWidget(
                    currentSkills: state.topSkills,
                    size: 260,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _activeSession(
      BuildContext context, DashboardState state, AppLocalizations l10n) {
    final session = state.activeSession;
    return _section(
      context,
      title: l10n.get('dashboard_active_session_question'),
      child: Card(
        child: session == null
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle_outline),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(l10n.get('dashboard_no_active_session')),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => context.go('/session'),
                            icon: const Icon(Icons.emoji_events_outlined),
                            label: Text(l10n.get('competition')),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => context.go('/training-center'),
                            icon: const Icon(Icons.school_outlined),
                            label: Text(l10n.get('kb_learning_hub')),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            : ListTile(
                leading: const Icon(Icons.play_circle_outline),
                title: Text(l10n.get('dashboard_session_in_progress')),
                subtitle: Text(_sessionType(session.sessionType, l10n)),
                trailing: FilledButton.icon(
                  onPressed: () => context.go('/session'),
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(l10n.get('continue_session')),
                ),
              ),
      ),
    );
  }

  Widget _coach(
      BuildContext context, DashboardState state, AppLocalizations l10n) {
    final insight = state.coachInsight;
    final recommendations = insight?.recommendations
            .where((item) => item != state.todayFocus)
            .take(5)
            .toList(growable: false) ??
        const <String>[];

    return _section(
      context,
      title: l10n.get('dashboard_coach_question'),
      action: TextButton(
        onPressed: () => context.go('/coach'),
        child: Text(l10n.get('see_all')),
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: insight == null
              ? Text(l10n.get('coach_no_recommendations'))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.psychology_outlined),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            insight.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(insight.message),
                    for (final item in recommendations)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.arrow_right, size: 20),
                            Expanded(child: Text(item)),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }

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

  String _sessionType(String type, AppLocalizations l10n) {
    return type == 'practice' ? l10n.get('practice') : l10n.get('match');
  }

  Widget _errorState(
      BuildContext context, DashboardState state, AppLocalizations l10n) {
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
              onPressed: () => ref.read(dashboardProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh),
              label: Text(l10n.get('try_again')),
            ),
          ],
        ),
      ),
    );
  }
}
