import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/endurance/domain/endurance_analyzer.dart';
import 'package:pool_os/features/endurance/presentation/endurance_provider.dart';
import 'package:pool_os/features/endurance/presentation/widgets/endurance_card.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

/// Task 08 — full Endurance view: the summary card plus a plain performance
/// curve (rack quality across the most recent analyzable match) so the player
/// can literally see where their form drops. Chart shows only when there is
/// enough data; otherwise the card's "not enough data" message stands alone.
class EnduranceScreen extends ConsumerWidget {
  const EnduranceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(enduranceProfileProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.get('endurance_title'))),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(l10n.get('endurance_error')),
          ),
        ),
        data: (profile) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(enduranceProfileProvider),
          child: ListView(
            children: [
              EnduranceCard(profile: profile),
              if (profile.hasEnoughData) ...[
                _curveSection(context, ref, l10n),
                _footer(context, profile, l10n),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _curveSection(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final async = ref.watch(enduranceRecentCurveProvider);
    return async.maybeWhen(
      data: (curve) {
        if (curve.length < 2) return const SizedBox.shrink();
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.get('endurance_curve_title'),
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.get('endurance_curve_subtitle'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: _EnduranceLineChart(curve: curve),
                ),
              ],
            ),
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _footer(
      BuildContext context, EnduranceProfile profile, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: Text(
        l10n
            .get('endurance_based_on')
            .replaceAll('{matches}', '${profile.analyzedMatches}')
            .replaceAll('{racks}', '${profile.analyzedRacks}'),
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: Colors.grey),
      ),
    );
  }
}

/// A minimal line chart of per-rack quality (0-100). No fixed gridlines beyond
/// the 0/50/100 guides; the point is the SHAPE of the curve, not exact values.
class _EnduranceLineChart extends StatelessWidget {
  final List<double> curve;
  const _EnduranceLineChart({required this.curve});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 100,
        minX: 1,
        maxX: curve.length.toDouble(),
        gridData: const FlGridData(show: true, horizontalInterval: 25),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 32, interval: 25),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval: 1,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (int i = 0; i < curve.length; i++)
                FlSpot((i + 1).toDouble(), curve[i]),
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
