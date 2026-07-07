import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pool_os/features/skill/domain/models/skill.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

class SkillRadarChartWidget extends StatefulWidget {
  final List<PlayerSkill> currentSkills;
  final List<PlayerSkill>? previousSkills;
  final double size;

  const SkillRadarChartWidget({
    super.key,
    required this.currentSkills,
    this.previousSkills,
    this.size = 300,
  });

  @override
  State<SkillRadarChartWidget> createState() => _SkillRadarChartWidgetState();
}

class _SkillRadarChartWidgetState extends State<SkillRadarChartWidget> {
  static const List<String> _skillCategories = [
    'stroke',
    'position',
    'decision',
    'pattern',
    'breakShot',
    'safety',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (widget.currentSkills.isEmpty) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: Center(
          child: Text(
            AppLocalizations.of(context).get('no_skills_yet'),
            style: theme.textTheme.bodyMedium,
          ),
        ),
      );
    }

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: RadarChart(
        RadarChartData(
          radarShape: RadarShape.polygon,
          radarBorderData: const BorderSide(color: Colors.transparent),
          gridBorderData: BorderSide(
            color: colorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
          tickBorderData: const BorderSide(color: Colors.transparent),
          tickCount: 4,
          ticksTextStyle: const TextStyle(fontSize: 0),
          titleTextStyle: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          titlePositionPercentageOffset: 0.2,
          getTitle: (index, angle) {
            return RadarChartTitle(
              text: _getSkillTitle(index),
              angle: 0,
            );
          },
          dataSets: _buildDataSets(colorScheme),
          borderData: FlBorderData(show: false),
          radarBackgroundColor: Colors.transparent,
        ),
      ),
    );
  }

  List<RadarDataSet> _buildDataSets(ColorScheme colorScheme) {
    final dataSets = <RadarDataSet>[];

    final currentValues = _getSkillValues(widget.currentSkills);

    dataSets.add(
      RadarDataSet(
        fillColor: colorScheme.primary.withOpacity(0.3),
        borderColor: colorScheme.primary,
        borderWidth: 2,
        entryRadius: 4,
        dataEntries: currentValues.map((v) => RadarEntry(value: v)).toList(),
      ),
    );

    if (widget.previousSkills != null && widget.previousSkills!.isNotEmpty) {
      final previousValues = _getSkillValues(widget.previousSkills!);

      dataSets.add(
        RadarDataSet(
          fillColor: colorScheme.secondary.withOpacity(0.2),
        borderColor: colorScheme.secondary,
        borderWidth: 2,
        entryRadius: 3,
        dataEntries: previousValues.map((v) => RadarEntry(value: v)).toList(),
        ),
      );
    }

    return dataSets;
  }

  List<double> _getSkillValues(List<PlayerSkill> skills) {
    return _skillCategories.map((category) {
      final skill = skills.firstWhere(
        (s) => s.category == category,
        orElse: () => PlayerSkill(
          playerId: 0,
          category: category,
          score: 0,
          confidence: 0,
          trend: 'stable',
        ),
      );
      return skill.score.clamp(0.0, 100.0);
    }).toList();
  }

  String _getSkillTitle(int index) {
    if (index < 0 || index >= _skillCategories.length) return '';
    return _skillCategories[index].substring(0, 3).toUpperCase();
  }
}

class SkillComparisonChart extends StatelessWidget {
  final List<PlayerSkill> session1Skills;
  final List<PlayerSkill> session2Skills;
  final String session1Label;
  final String session2Label;
  final double size;

  const SkillComparisonChart({
    super.key,
    required this.session1Skills,
    required this.session2Skills,
    this.session1Label = 'Current',
    this.session2Label = 'Previous',
    this.size = 300,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: SkillRadarChartWidget(
            currentSkills: session1Skills,
            previousSkills: session2Skills,
            size: size,
          ),
        ),
        const SizedBox(height: 16),
        _buildLegend(context),
      ],
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(
          context,
          session1Label,
          Theme.of(context).colorScheme.primary,
          isDashed: false,
        ),
        const SizedBox(width: 24),
        if (session2Skills.isNotEmpty)
          _buildLegendItem(
            context,
            session2Label,
            Theme.of(context).colorScheme.secondary,
            isDashed: true,
          ),
      ],
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    String label,
    Color color, {
    bool isDashed = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: isDashed ? Colors.transparent : color,
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class SkillProgressChart extends StatelessWidget {
  final List<SkillDataPoint> dataPoints;
  final String skillCategory;

  const SkillProgressChart({
    super.key,
    required this.dataPoints,
    required this.skillCategory,
  });

  @override
  Widget build(BuildContext context) {
    if (dataPoints.isEmpty) {
      return const SizedBox(
        height: 150,
        child: Center(child: Text('No data available')),
      );
    }

    final sortedPoints = List<SkillDataPoint>.from(dataPoints)
      ..sort((a, b) => a.date.compareTo(b.date));

    return SizedBox(
      height: 150,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 25,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.2),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 35,
                interval: 25,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= sortedPoints.length) {
                    return const SizedBox.shrink();
                  }
                  final date = sortedPoints[index].date;
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${date.month}/${date.day}',
                      style: const TextStyle(fontSize: 9, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (sortedPoints.length - 1).toDouble(),
          minY: 0,
          maxY: 100,
          lineBarsData: [
            LineChartBarData(
              spots: sortedPoints.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value.value);
              }).toList(),
              isCurved: true,
              color: Theme.of(context).colorScheme.primary,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Theme.of(context).colorScheme.primary,
                    strokeWidth: 2,
                    strokeColor: Theme.of(context).colorScheme.surface,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final index = spot.x.toInt();
                  final point = sortedPoints[index];
                  return LineTooltipItem(
                    '${point.value.toInt()}%\n${point.date.month}/${point.date.day}',
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }
}

class SkillDataPoint {
  final DateTime date;
  final double value;
  final double? confidence;

  SkillDataPoint({
    required this.date,
    required this.value,
    this.confidence,
  });
}
