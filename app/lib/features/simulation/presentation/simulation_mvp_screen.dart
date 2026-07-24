import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/simulation_mvp_service.dart';
import 'simulation_providers.dart';

class SimulationMvpScreen extends ConsumerWidget {
  const SimulationMvpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(simulationSessionProvider);
    final notifier = ref.read(simulationSessionProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Scenario Replay')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _selector(
            label: 'Scenario A',
            value: session.leftScenario,
            onChanged: notifier.selectLeft,
          ),
          const SizedBox(height: 12),
          _selector(
            label: 'Scenario B',
            value: session.rightScenario,
            onChanged: notifier.selectRight,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: session.isLoading ? null : notifier.compare,
            icon: const Icon(Icons.compare_arrows),
            label: const Text('Replay and compare'),
          ),
          if (session.isLoading) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
          ],
          if (session.errorCode != null) ...[
            const SizedBox(height: 12),
            Text(
              'Unable to replay scenarios.',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          if (session.comparison != null) ...[
            const SizedBox(height: 24),
            _comparison(context, session.comparison!),
          ],
          if (session.history.isNotEmpty) ...[
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text('Session history',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                IconButton(
                  tooltip: 'Clear session history',
                  onPressed: notifier.clearHistory,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            for (final preview in session.history.reversed.take(6))
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.history),
                title: Text(_scenarioName(preview.request.scenario)),
                subtitle: Text('${preview.samples.length} observed samples'),
                trailing: Text(_percent(preview.observedRate)),
              ),
          ],
        ],
      ),
    );
  }

  Widget _selector({
    required String label,
    required SimulationScenarioKind value,
    required ValueChanged<SimulationScenarioKind> onChanged,
  }) {
    return DropdownButtonFormField<SimulationScenarioKind>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: [
        for (final scenario in SimulationScenarioKind.values)
          DropdownMenuItem(
            value: scenario,
            child: Text(_scenarioName(scenario)),
          ),
      ],
      onChanged: (next) {
        if (next != null) onChanged(next);
      },
    );
  }

  Widget _comparison(BuildContext context, SimulationComparison comparison) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Observed comparison',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        SizedBox(
          height: 190,
          child: BarChart(BarChartData(
            maxY: 1,
            minY: 0,
            barGroups: [
              _bar(0, comparison.left.observedRate, Colors.green),
              _bar(1, comparison.right.observedRate, Colors.blue),
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
                    child: Text(value == 0 ? 'A' : 'B'),
                  ),
                ),
              ),
            ),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
          )),
        ),
        _previewTile('A', comparison.left),
        _previewTile('B', comparison.right),
        Text(
          'Observed delta: '
          '${comparison.observedRateDelta >= 0 ? '+' : ''}'
          '${_percent(comparison.observedRateDelta)}',
        ),
      ],
    );
  }

  Widget _previewTile(String label, SimulationPreview preview) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(child: Text(label)),
      title: Text(_scenarioName(preview.request.scenario)),
      subtitle: Text(
        '${preview.samples.length} observed samples · '
        '${_duration(preview.observedDuration)}',
      ),
      trailing: Text(_percent(preview.observedRate)),
    );
  }

  BarChartGroupData _bar(int index, double value, Color color) {
    return BarChartGroupData(x: index, barRods: [
      BarChartRodData(
        toY: value,
        color: color,
        width: 28,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      ),
    ]);
  }

  static String _scenarioName(SimulationScenarioKind value) => switch (value) {
        SimulationScenarioKind.matchReplay => 'Match replay',
        SimulationScenarioKind.trainingReplay => 'Training replay',
        SimulationScenarioKind.combinedReplay => 'Combined replay',
      };

  static String _percent(double value) => '${(value * 100).round()}%';

  static String _duration(Duration value) {
    final hours = value.inHours;
    final minutes = value.inMinutes.remainder(60);
    return hours == 0 ? '${value.inMinutes}m' : '${hours}h ${minutes}m';
  }
}
