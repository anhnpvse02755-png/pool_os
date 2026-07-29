// EPIC 02 — Statistics & Analytics — Phase 5: chart primitives.
//
// Chart widgets reuse the existing fl_chart dependency. No custom
// rendering engine is introduced. Each widget consumes a single
// `TrendSummary` or aggregated snapshot.

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../domain/models/analytics_period.dart';

class TrendLineChart extends StatelessWidget {
  const TrendLineChart({super.key, required this.summary, this.height = 180});

  final TrendSummary summary;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (summary.points.length < 2) {
      return SizedBox(
        height: height,
        child: const Center(child: Text('Not enough data for trend')),
      );
    }
    final spots = <FlSpot>[
      for (var i = 0; i < summary.points.length; i++)
        FlSpot(i.toDouble(), summary.points[i].value),
    ];
    return SizedBox(
      height: height,
      child: LineChart(LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 3,
            dotData: const FlDotData(show: false),
          ),
        ],
        titlesData: const FlTitlesData(show: false),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
      )),
    );
  }
}

class TrendBarChart extends StatelessWidget {
  const TrendBarChart({
    super.key,
    required this.summary,
    this.height = 180,
  });

  final TrendSummary summary;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (summary.points.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(child: Text('Not enough data for chart')),
      );
    }
    final groups = <BarChartGroupData>[
      for (var i = 0; i < summary.points.length; i++)
        BarChartGroupData(x: i, barRods: [
          BarChartRodData(
            toY: summary.points[i].value,
            width: 12,
            color: Theme.of(context).colorScheme.primary,
          ),
        ]),
    ];
    return SizedBox(
      height: height,
      child: BarChart(BarChartData(
        barGroups: groups,
        titlesData: const FlTitlesData(show: false),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
      )),
    );
  }
}

class TrendPieChart extends StatelessWidget {
  const TrendPieChart({
    super.key,
    required this.distribution,
    this.height = 180,
  });

  final Map<String, int> distribution;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (distribution.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(child: Text('Not enough data for chart')),
      );
    }
    final total = distribution.values.fold<int>(0, (a, b) => a + b);
    final colors = [
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.secondary,
      Theme.of(context).colorScheme.tertiary,
      Theme.of(context).colorScheme.error,
    ];
    final sections = <PieChartSectionData>[];
    var i = 0;
    distribution.forEach((key, value) {
      final pct = total == 0 ? 0.0 : (value / total) * 100;
      sections.add(PieChartSectionData(
        color: colors[i % colors.length],
        value: value.toDouble(),
        title: '${pct.toStringAsFixed(0)}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ));
      i++;
    });
    return SizedBox(
      height: height,
      child: PieChart(PieChartData(
        sections: sections,
        sectionsSpace: 2,
        centerSpaceRadius: 32,
      )),
    );
  }
}

class TrendDirectionChip extends StatelessWidget {
  const TrendDirectionChip({super.key, required this.summary});

  final TrendSummary summary;

  @override
  Widget build(BuildContext context) {
    final color = switch (summary.direction) {
      TrendDirection.up => Colors.green,
      TrendDirection.down => Colors.red,
      TrendDirection.flat => Colors.blueGrey,
      TrendDirection.unknown => Colors.grey,
    };
    return Chip(
      avatar: Icon(
        switch (summary.direction) {
          TrendDirection.up => Icons.trending_up,
          TrendDirection.down => Icons.trending_down,
          TrendDirection.flat => Icons.trending_flat,
          TrendDirection.unknown => Icons.help_outline,
        },
        color: color,
        size: 18,
      ),
      label: Text(summary.direction.label('en')),
    );
  }
}

class PeriodSelector extends StatelessWidget {
  const PeriodSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final AnalyticsPeriod value;
  final ValueChanged<AnalyticsPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<AnalyticsPeriod>(
      segments: const [
        ButtonSegment(value: AnalyticsPeriod.today, label: Text('Today')),
        ButtonSegment(value: AnalyticsPeriod.sevenDays, label: Text('7d')),
        ButtonSegment(value: AnalyticsPeriod.thirtyDays, label: Text('30d')),
        ButtonSegment(value: AnalyticsPeriod.allTime, label: Text('All')),
      ],
      selected: {value},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}

class PerformanceIndicatorCard extends StatelessWidget {
  const PerformanceIndicatorCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final String title;
  final double value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            LinearProgressIndicator(value: value.clamp(0.0, 1.0)),
            const SizedBox(height: 4),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class StatisticsMetricTile extends StatelessWidget {
  const StatisticsMetricTile({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ),
    );
  }
}
