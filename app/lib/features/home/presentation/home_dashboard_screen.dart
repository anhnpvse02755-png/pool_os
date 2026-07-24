import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../analytics/application/analytics_mvp_service.dart';
import '../../analytics/presentation/analytics_dashboard_screen.dart';
import '../../coach/presentation/coach_screen.dart';
import '../../knowledge/presentation/screens/knowledge_library_screen.dart';
import '../../match/presentation/match_history_view.dart';
import '../../simulation/presentation/simulation_mvp_screen.dart';
import '../../training/presentation/training_history_view.dart';
import '../application/home_dashboard_service.dart';
import 'home_dashboard_provider.dart';

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(homeDashboardProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Pool OS')),
      body: dashboard.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Unable to load Home.')),
        data: (view) => RefreshIndicator(
          onRefresh: () async => ref.refresh(homeDashboardProvider.future),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Your game', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.25,
                children: [
                  for (final destination in HomeDestination.values)
                    _destinationCard(context, destination, view),
                ],
              ),
              const SizedBox(height: 24),
              Text('Recent activity',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (view.recentActivity.isEmpty)
                const Text('No completed Match or Training activity yet.')
              else
                for (final activity in view.recentActivity.take(6))
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(activity.kind == AnalyticsActivityKind.match
                        ? Icons.emoji_events_outlined
                        : Icons.fitness_center),
                    title: Text(activity.kind == AnalyticsActivityKind.match
                        ? 'Match #${activity.id}'
                        : 'Training #${activity.id}'),
                    subtitle: Text(_date(activity.occurredAt)),
                    trailing: Text(_percent(activity.rate)),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _destinationCard(
    BuildContext context,
    HomeDestination destination,
    HomeDashboardView view,
  ) {
    final summary = view.summaries[destination]!;
    return Card(
      child: InkWell(
        key: ValueKey('home-${destination.name}'),
        onTap: () => _open(context, destination),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(_icon(destination)),
              const Spacer(),
              Text(_title(destination),
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(summary.primary,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(summary.secondary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }

  void _open(BuildContext context, HomeDestination destination) {
    final page = switch (destination) {
      HomeDestination.match =>
        const _HistoryScreen(title: 'Match', child: MatchHistoryView()),
      HomeDestination.training =>
        const _HistoryScreen(title: 'Training', child: TrainingHistoryView()),
      HomeDestination.coach => const CoachScreen(),
      HomeDestination.knowledge => const KnowledgeLibraryScreen(),
      HomeDestination.analytics => const AnalyticsDashboardScreen(),
      HomeDestination.simulation => const SimulationMvpScreen(),
    };
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }
}

class _HistoryScreen extends StatelessWidget {
  const _HistoryScreen({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      );
}

String _title(HomeDestination value) => switch (value) {
      HomeDestination.match => 'Match',
      HomeDestination.training => 'Training',
      HomeDestination.coach => 'Coach',
      HomeDestination.knowledge => 'Knowledge',
      HomeDestination.analytics => 'Analytics',
      HomeDestination.simulation => 'Simulation',
    };

IconData _icon(HomeDestination value) => switch (value) {
      HomeDestination.match => Icons.emoji_events_outlined,
      HomeDestination.training => Icons.fitness_center,
      HomeDestination.coach => Icons.psychology_outlined,
      HomeDestination.knowledge => Icons.menu_book_outlined,
      HomeDestination.analytics => Icons.bar_chart,
      HomeDestination.simulation => Icons.compare_arrows,
    };

String _percent(double value) => '${(value * 100).round()}%';
String _date(DateTime value) => '${value.day}/${value.month}/${value.year}';
