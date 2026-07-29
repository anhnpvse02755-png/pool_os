import 'package:flutter/material.dart';

import '../domain/equipment_performance_projection.dart';
import '../domain/models/cue.dart';
import 'widgets/equipment_comparison_section.dart'
    show EquipmentComparisonEntry;

/// FEATURE_012 v2 — Equipment Comparison Screen.
///
/// Dedicated screen reached via `Navigator.push` from the Equipment
/// Screen when the user taps the `Compare (N)` button. Renders a
/// multi-column comparison table that reads **only** from the existing
/// [EquipmentPerformanceProjection].
///
/// Source spec: `architecture/product/features/FEATURE_012_EQUIPMENT_COMPARISON.md`
class EquipmentComparisonScreen extends StatelessWidget {
  const EquipmentComparisonScreen({
    super.key,
    required this.cues,
    required this.projections,
    required this.now,
    required this.locale,
  });

  final List<Cue> cues;
  final List<EquipmentPerformanceProjection> projections;
  final DateTime now;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final vi = locale == 'vi';
    final entries = _buildEntries();
    final title = vi ? 'So sánh' : 'Comparison';

    return Scaffold(
      key: const ValueKey('equipment-comparison-screen'),
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: entries.isEmpty
          ? Center(
              key: const ValueKey('equipment-comparison-empty'),
              child: Text(vi ? 'Chưa có dữ liệu' : 'No data'),
            )
          : _buildComparisonView(context, entries, vi),
    );
  }

  // Build (cue, projection) pairs preserving the order of [cues]. Drops
  // cues that do not have a matching projection. Defensive — the caller
  // is expected to pass a filtered list.
  List<EquipmentComparisonEntry> _buildEntries() {
    final result = <EquipmentComparisonEntry>[];
    for (final cue in cues) {
      if (cue.id == null) continue;
      final projection =
          projections.where((p) => p.equipmentId == cue.id).firstOrNull;
      if (projection == null) continue;
      result.add(EquipmentComparisonEntry(cue: cue, projection: projection));
    }
    return List<EquipmentComparisonEntry>.unmodifiable(result);
  }

  Widget _buildComparisonView(
    BuildContext context,
    List<EquipmentComparisonEntry> entries,
    bool vi,
  ) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      key: const ValueKey('equipment-comparison-vertical-scroll'),
      child: SingleChildScrollView(
        key: const ValueKey('equipment-comparison-horizontal-scroll'),
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: _preferredTableWidth(entries.length),
          ),
          child: DataTable(
            key: const ValueKey('equipment-comparison-data-table'),
            headingRowHeight: 56,
            dataRowMinHeight: 44,
            dataRowMaxHeight: 56,
            columnSpacing: 24,
            headingTextStyle: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.bold),
            columns: _buildColumns(entries, vi),
            rows: _buildRows(entries, vi),
          ),
        ),
      ),
    );
  }

  double _preferredTableWidth(int cueCount) {
    // First column (metric label) is 160; each cue column is 120.
    return 160 + cueCount * 120.0;
  }

  List<DataColumn> _buildColumns(
      List<EquipmentComparisonEntry> entries, bool vi) {
    return <DataColumn>[
      const DataColumn(
        label: SizedBox.shrink(),
      ),
      for (var i = 0; i < entries.length; i++)
        DataColumn(
          label: SizedBox(
            key: ValueKey('equipment-comparison-col-header-$i'),
            width: 120,
            child: Text(
              entries[i].cue.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
    ];
  }

  List<DataRow> _buildRows(List<EquipmentComparisonEntry> entries, bool vi) {
    const insufficientLabel = 'Chưa đủ dữ liệu.';
    return <DataRow>[
      DataRow(
        key: const ValueKey('equipment-comparison-row-match-win'),
        cells: <DataCell>[
          _labelCell(vi ? 'Tỷ lệ thắng' : 'Win Rate', 0),
          for (var i = 0; i < entries.length; i++)
            _valueCell(
              i,
              0,
              _isInsufficient(entries[i].projection)
                  ? insufficientLabel
                  : '${entries[i].projection.matchWinRate.round()}%',
            ),
        ],
      ),
      DataRow(
        key: const ValueKey('equipment-comparison-row-training-success'),
        cells: <DataCell>[
          _labelCell(vi ? 'Tập thành công' : 'Training Success', 1),
          for (var i = 0; i < entries.length; i++)
            _valueCell(
              i,
              1,
              _isInsufficient(entries[i].projection)
                  ? insufficientLabel
                  : '${entries[i].projection.trainingSuccessRate.round()}%',
            ),
        ],
      ),
      DataRow(
        key: const ValueKey('equipment-comparison-row-matches'),
        cells: <DataCell>[
          _labelCell(vi ? 'Trận' : 'Matches', 2),
          for (var i = 0; i < entries.length; i++)
            _valueCell(
              i,
              2,
              _isInsufficient(entries[i].projection)
                  ? insufficientLabel
                  : entries[i].projection.totalMatches.toString(),
            ),
        ],
      ),
      DataRow(
        key: const ValueKey('equipment-comparison-row-trainings'),
        cells: <DataCell>[
          _labelCell(vi ? 'Buổi tập' : 'Trainings', 3),
          for (var i = 0; i < entries.length; i++)
            _valueCell(
              i,
              3,
              _isInsufficient(entries[i].projection)
                  ? insufficientLabel
                  : entries[i].projection.totalTrainingSessions.toString(),
            ),
        ],
      ),
      DataRow(
        key: const ValueKey('equipment-comparison-row-last-used'),
        cells: <DataCell>[
          _labelCell(vi ? 'Dùng gần nhất' : 'Last Used', 4),
          for (var i = 0; i < entries.length; i++)
            _valueCell(
              i,
              4,
              _isInsufficient(entries[i].projection)
                  ? insufficientLabel
                  : _formatLastUsed(entries[i].projection.lastUsed, vi),
            ),
        ],
      ),
    ];
  }

  DataCell _labelCell(String label, int rowIndex) {
    return DataCell(
      SizedBox(
        width: 160,
        child: Text(
          label,
          key: ValueKey('equipment-comparison-row-$rowIndex-label'),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  DataCell _valueCell(int cueIndex, int rowIndex, String value) {
    return DataCell(
      SizedBox(
        width: 120,
        child: Text(
          value,
          key: ValueKey('equipment-comparison-cell-$cueIndex-$rowIndex'),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  bool _isInsufficient(EquipmentPerformanceProjection projection) {
    return projection.totalMatches < 5 || projection.totalTrainingSessions < 5;
  }

  bool _dateIsSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatLastUsed(DateTime? value, bool vi) {
    if (value == null) return vi ? 'Chưa có' : 'Never';
    final local = value.toLocal();
    if (_dateIsSameDay(local, now)) {
      return vi ? 'Hôm nay' : 'Today';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (_dateIsSameDay(local, yesterday)) {
      return vi ? 'Hôm qua' : 'Yesterday';
    }
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final m = months[local.month - 1];
    final d = local.day.toString().padLeft(2, '0');
    return '$m $d';
  }
}
