import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/player_progress_projection.dart';
import 'player_progress_provider.dart';

class PlayerProgressSection extends ConsumerWidget {
  const PlayerProgressSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(playerProgressProvider);
    return Card(
      key: const ValueKey('player-model-section'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: progress.when(
          loading: () => const SizedBox(
            height: 180,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => const SizedBox(
            height: 96,
            child: Center(child: Text('Player Model is unavailable.')),
          ),
          data: (value) => value == null
              ? const SizedBox(
                  height: 96,
                  child: Center(
                    child: Text('Complete a Match or Training to begin.'),
                  ),
                )
              : _ProgressContent(progress: value),
        ),
      ),
    );
  }
}

class _ProgressContent extends StatelessWidget {
  const _ProgressContent({required this.progress});

  final PlayerProgressProjection progress;

  @override
  Widget build(BuildContext context) {
    final vi = Localizations.localeOf(context).languageCode == 'vi';
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Player Model',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vi
                        ? '${progress.sourceMatchCount} tran dau / ${progress.sourceTrainingCount} buoi tap'
                        : '${progress.sourceMatchCount} matches / ${progress.sourceTrainingCount} training sessions',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Semantics(
              label: vi
                  ? 'Diem tong ${progress.overall.round()} tren 100'
                  : 'Overall ${progress.overall.round()} out of 100',
              child: Text(
                '${progress.overall.round()}',
                key: const ValueKey('player-model-overall'),
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          key: const ValueKey('player-model-radar'),
          height: 260,
          child: RadarChart(
            RadarChartData(
              radarShape: RadarShape.polygon,
              tickCount: 4,
              ticksTextStyle: const TextStyle(fontSize: 0),
              tickBorderData: const BorderSide(color: Colors.transparent),
              radarBorderData: BorderSide(
                color: theme.colorScheme.outlineVariant,
              ),
              gridBorderData: BorderSide(
                color: theme.colorScheme.outlineVariant,
              ),
              titleTextStyle: theme.textTheme.labelSmall,
              getTitle: (index, angle) => RadarChartTitle(
                text: _shortLabel(
                  progress.skills[index].dimension,
                  vi,
                ),
                angle: 0,
              ),
              dataSets: [
                RadarDataSet(
                  fillColor: theme.colorScheme.primary.withValues(alpha: 0.22),
                  borderColor: theme.colorScheme.primary,
                  borderWidth: 2,
                  entryRadius: 3,
                  dataEntries: progress.skills
                      .map((item) => RadarEntry(value: item.value))
                      .toList(),
                ),
              ],
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _MetricRow(progress: progress, vi: vi),
        const SizedBox(height: 20),
        Text(vi ? 'Xu huong' : 'Trend', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        SizedBox(
          key: const ValueKey('player-model-trend'),
          height: 150,
          child: progress.trendPoints.length < 2
              ? Center(
                  child: Text(
                    vi
                        ? 'Can them du lieu hoan thanh.'
                        : 'More completed data is needed.',
                  ),
                )
              : _TrendChart(points: progress.trendPoints),
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _VectorList(
                title: vi ? 'Diem manh' : 'Strengths',
                values: progress.strengths,
                progress: progress,
                vi: vi,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _VectorList(
                title: vi ? 'Diem yeu' : 'Weaknesses',
                values: progress.weaknesses,
                progress: progress,
                vi: vi,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.progress, required this.vi});

  final PlayerProgressProjection progress;
  final bool vi;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: _Metric(
              label: vi ? 'Thanh thao' : 'Mastery',
              value: progress.mastery,
            ),
          ),
          Expanded(
            child: _Metric(
              label: vi ? 'Do tin cay' : 'Confidence',
              value: progress.confidence,
            ),
          ),
          Expanded(
            child: _Metric(
              label: vi ? 'Xu huong' : 'Trend',
              value: progress.trend,
            ),
          ),
        ],
      );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(
            '${value.round()}%',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      );
}

class _VectorList extends StatelessWidget {
  const _VectorList({
    required this.title,
    required this.values,
    required this.progress,
    required this.vi,
  });

  final String title;
  final List<PlayerSkillDimension> values;
  final PlayerProgressProjection progress;
  final bool vi;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          for (final value in values)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _label(value, vi),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text('${progress.score(value).round()}'),
                ],
              ),
            ),
        ],
      );
}

class _TrendChart extends StatelessWidget {
  const _TrendChart({required this.points});

  final List<double> points;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (points.length - 1).toDouble(),
        minY: 0,
        maxY: 100,
        gridData: const FlGridData(show: true, horizontalInterval: 25),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: 25,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var index = 0; index < points.length; index++)
                FlSpot(index.toDouble(), points[index]),
            ],
            isCurved: true,
            color: primary,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: primary.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }
}

String _shortLabel(PlayerSkillDimension value, bool vi) => switch (value) {
      PlayerSkillDimension.breakSkill => 'BRK',
      PlayerSkillDimension.potting => 'POT',
      PlayerSkillDimension.position => 'POS',
      PlayerSkillDimension.safety => 'SFT',
      PlayerSkillDimension.cueBallControl => 'CUE',
      PlayerSkillDimension.kickJump => 'K/J',
      PlayerSkillDimension.mental => 'MNT',
      PlayerSkillDimension.consistency => 'CON',
    };

String _label(PlayerSkillDimension value, bool vi) => switch (value) {
      PlayerSkillDimension.breakSkill => vi ? 'Pha bi' : 'Break',
      PlayerSkillDimension.potting => vi ? 'Danh lo' : 'Potting',
      PlayerSkillDimension.position => vi ? 'Dieu bi' : 'Position',
      PlayerSkillDimension.safety => 'Safety',
      PlayerSkillDimension.cueBallControl =>
        vi ? 'Kiem soat bi cai' : 'Cue-ball control',
      PlayerSkillDimension.kickJump => 'Kick / Jump',
      PlayerSkillDimension.mental => vi ? 'Tam ly' : 'Mental',
      PlayerSkillDimension.consistency => vi ? 'On dinh' : 'Consistency',
    };
