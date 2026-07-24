import 'package:flutter/material.dart';

import '../../domain/equipment_performance_projection.dart';

class EquipmentPerformanceSummary extends StatelessWidget {
  const EquipmentPerformanceSummary({
    super.key,
    required this.projection,
    required this.locale,
  });

  final EquipmentPerformanceProjection projection;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final vi = locale == 'vi';
    final duration = Duration(seconds: projection.recordedDurationSeconds);
    final hours = duration.inMinutes / 60;
    return Container(
      key: ValueKey('equipment-performance-${projection.equipmentId}'),
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Wrap(
        spacing: 20,
        runSpacing: 10,
        children: [
          _value(vi ? 'Tran' : 'Matches', '${projection.totalMatches}'),
          _value(
            vi ? 'Ty le thang' : 'Win rate',
            '${projection.matchWinRate.round()}%',
          ),
          _value(
            vi ? 'Buoi tap' : 'Training',
            '${projection.totalTrainingSessions}',
          ),
          _value(
            vi ? 'Thanh cong' : 'Success',
            '${projection.trainingSuccessRate.round()}%',
          ),
          _value(vi ? 'Da ghi' : 'Recorded', '${hours.toStringAsFixed(1)} h'),
          _value(
            vi ? 'Dung gan nhat' : 'Last used',
            projection.lastUsed == null
                ? (vi ? 'Chua co' : 'Never')
                : _date(projection.lastUsed!),
          ),
        ],
      ),
    );
  }

  Widget _value(String label, String value) => SizedBox(
        width: 92,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      );
}

String _date(DateTime value) {
  final local = value.toLocal();
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
}
