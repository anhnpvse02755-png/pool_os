// EPIC 02 — Statistics & Analytics — Phase G: extra chart primitives.
//
// Histogram and ScatterPlot over the existing fl_chart dependency.

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TrendHistogram extends StatelessWidget {
  const TrendHistogram({
    super.key,
    required this.values,
    this.bins = 12,
    this.height = 180,
  });

  final List<double> values;
  final int bins;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(child: Text('Not enough data for histogram')),
      );
    }
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final range = (max - min).abs();
    final binSize = range == 0 ? 1.0 : range / bins;
    final counts = List<int>.filled(bins, 0);
    for (final v in values) {
      if (binSize == 0) {
        counts[0]++;
        continue;
      }
      var idx = ((v - min) / binSize).floor();
      if (idx >= bins) idx = bins - 1;
      if (idx < 0) idx = 0;
      counts[idx]++;
    }
    final color = Theme.of(context).colorScheme.primary;
    final groups = <BarChartGroupData>[
      for (var i = 0; i < bins; i++)
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: counts[i].toDouble(),
              width: 12,
              color: color,
            ),
          ],
        ),
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

class TrendScatterPlot extends StatelessWidget {
  const TrendScatterPlot({
    super.key,
    required this.points,
    this.height = 180,
  });

  final List<({double x, double y})> points;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(child: Text('No points yet')),
      );
    }
    final color = Theme.of(context).colorScheme.primary;
    final spots = <FlSpot>[
      for (final p in points) FlSpot(p.x, p.y),
    ];
    return SizedBox(
      height: height,
      child: ScatterChart(ScatterChartData(
        scatterSpots: [
          for (final s in spots)
            ScatterSpot(
              s.x,
              s.y,
              dotPainter: FlDotCirclePainter(color: color, radius: 4),
            ),
        ],
        titlesData: const FlTitlesData(show: false),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
      )),
    );
  }
}
