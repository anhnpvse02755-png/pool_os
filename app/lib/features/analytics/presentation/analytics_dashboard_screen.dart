import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/analytics_mvp_service.dart';
import 'analytics_providers.dart';

class AnalyticsDashboardScreen extends ConsumerWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(analyticsDashboardProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: dashboard.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            const Center(child: Text('Unable to load analytics.')),
        data: (view) => RefreshIndicator(
          onRefresh: () async => ref.refresh(analyticsDashboardProvider.future),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _overview(view),
              const SizedBox(height: 20),
              _rateChart(context, view),
              const SizedBox(height: 20),
              _durationChart(context, view),
              const SizedBox(height: 20),
              Text('Recent activity',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (view.recentActivity.isEmpty)
                const Text('No completed Match or Training activity yet.')
              else
                for (final activity in view.recentActivity)
                  _activityTile(activity),
            ],
          ),
        ),
      ),
    );
  }

  Widget _overview(AnalyticsDashboardView view) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.7,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: [
        _Metric(label: 'Matches', value: '${view.matches.matchCount}'),
        _Metric(label: 'Training', value: '${view.training.sessionCount}'),
        _Metric(label: 'Racks', value: '${view.matches.rackCount}'),
        _Metric(label: 'Exercises', value: '${view.training.exerciseCount}'),
        _Metric(label: 'Win rate', value: _percent(view.matchWinRate)),
        _Metric(
          label: 'Success rate',
          value: _percent(view.trainingSuccessRate),
        ),
      ],
    );
  }

  Widget _rateChart(BuildContext context, AnalyticsDashboardView view) {
    return _ChartSection(
      title: 'Performance rates',
      height: 180,
      child: BarChart(BarChartData(
        maxY: 1,
        minY: 0,
        barGroups: [
          _bar(0, view.matchWinRate, Colors.green),
          _bar(1, view.trainingSuccessRate, Colors.blue),
        ],
        titlesData: FlTitlesData(
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 38,
              interval: 0.5,
              getTitlesWidget: (value, _) => Text(_percent(value)),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(value == 0 ? 'Match' : 'Training'),
              ),
            ),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
      )),
    );
  }

  Widget _durationChart(BuildContext context, AnalyticsDashboardView view) {
    final maximum = [
      view.matches.duration.inMinutes,
      view.training.duration.inMinutes,
    ].reduce((left, right) => left > right ? left : right);
    return _ChartSection(
      title: 'Recorded duration',
      height: 180,
      child: BarChart(BarChartData(
        maxY: maximum == 0 ? 1 : maximum.toDouble(),
        barGroups: [
          _bar(0, view.matches.duration.inMinutes.toDouble(), Colors.green),
          _bar(1, view.training.duration.inMinutes.toDouble(), Colors.blue),
        ],
        titlesData: FlTitlesData(
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 42),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(value == 0 ? 'Match' : 'Training'),
              ),
            ),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
      )),
    );
  }

  BarChartGroupData _bar(int index, num value, Color color) {
    return BarChartGroupData(x: index, barRods: [
      BarChartRodData(
        toY: value.toDouble(),
        color: color,
        width: 28,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      ),
    ]);
  }

  Widget _activityTile(AnalyticsActivity activity) {
    final match = activity.kind == AnalyticsActivityKind.match;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(match ? Icons.sports_score : Icons.fitness_center),
      title: Text('${match ? 'Match' : 'Training'} #${activity.id}'),
      subtitle: Text(
        '${activity.occurredAt.year}-'
        '${activity.occurredAt.month.toString().padLeft(2, '0')}-'
        '${activity.occurredAt.day.toString().padLeft(2, '0')}',
      ),
      trailing: Text(
        '${_percent(activity.rate)} · ${_duration(activity.duration)}',
      ),
    );
  }

  String _percent(double value) => '${(value * 100).round()}%';

  String _duration(Duration value) {
    final hours = value.inHours;
    final minutes = value.inMinutes.remainder(60);
    return hours == 0 ? '${value.inMinutes}m' : '${hours}h ${minutes}m';
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value, style: Theme.of(context).textTheme.titleLarge),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
}

class _ChartSection extends StatelessWidget {
  const _ChartSection({
    required this.title,
    required this.height,
    required this.child,
  });

  final String title;
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          SizedBox(height: height, child: child),
        ],
      );
}
