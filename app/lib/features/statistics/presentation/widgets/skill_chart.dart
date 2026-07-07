import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pool_os/features/statistics/domain/models/statistics.dart';

class SkillChart extends StatelessWidget {
  const SkillChart({super.key, required this.skills});

  final List<SkillStat> skills;

  @override
  Widget build(BuildContext context) {
    if (skills.isEmpty) {
      return const Center(child: Text('No skill data yet'));
    }
    return BarChart(
      BarChartData(
        barGroups: skills.asMap().entries.map((entry) {
          final index = entry.key;
          final skill = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: skill.value * 100,
                color: Theme.of(context).colorScheme.primary,
                width: 16,
              ),
            ],
          );
        }).toList(),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}
