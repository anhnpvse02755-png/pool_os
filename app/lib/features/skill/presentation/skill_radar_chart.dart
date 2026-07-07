import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pool_os/features/skill/domain/models/skill.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

class SkillRadarChart extends StatelessWidget {
  final List<PlayerSkill> skills;
  final List<PlayerSkill>? previousSkills;
  final double size;

  const SkillRadarChart({
    super.key,
    required this.skills,
    this.previousSkills,
    this.size = 300,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (skills.isEmpty) {
      return SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Text(
            AppLocalizations.of(context).get('no_skills_yet'),
            style: theme.textTheme.bodyMedium,
          ),
        ),
      );
    }

    return SizedBox(
      width: size,
      height: size,
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
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          titlePositionPercentageOffset: 0.18,
          getTitle: (index, angle) {
            return RadarChartTitle(
              text: _getCategoryShortName(skills[index].category),
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

    final currentValues = skills.map((s) => s.score.clamp(0.0, 100.0)).toList();

    dataSets.add(
      RadarDataSet(
        fillColor: colorScheme.primary.withOpacity(0.3),
        borderColor: colorScheme.primary,
        borderWidth: 2,
        entryRadius: 4,
        dataEntries: currentValues.map((v) => RadarEntry(value: v)).toList(),
      ),
    );

    if (previousSkills != null && previousSkills!.isNotEmpty) {
      final previousValues = previousSkills!.map((s) => s.score.clamp(0.0, 100.0)).toList();

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

  String _getCategoryShortName(String category) {
    switch (category) {
      case 'stroke':
        return 'STK';
      case 'position':
        return 'POS';
      case 'decision':
        return 'DEC';
      case 'pattern':
        return 'PAT';
      case 'breakShot':
        return 'BRK';
      case 'safety':
        return 'SFT';
      case 'mental':
        return 'MNT';
      case 'consistency':
        return 'CON';
      case 'equipment':
        return 'EQP';
      case 'recovery':
        return 'RCV';
      default:
        return category.substring(0, 3).toUpperCase();
    }
  }
}
