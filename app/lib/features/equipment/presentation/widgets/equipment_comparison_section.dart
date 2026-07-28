import 'package:flutter/material.dart';

import '../../domain/models/cue.dart';
import '../../domain/equipment_performance_projection.dart';

/// FEATURE_012 — Equipment Comparison
///
/// Source spec: `architecture/product/features/FEATURE_012_EQUIPMENT_COMPARISON.md`.
///
/// Renders a side-by-side table of up to 2 cues' projection values.
/// No winner highlight, no aggregation, no AI. Pure projection render.
class EquipmentComparisonEntry {
  const EquipmentComparisonEntry({
    required this.cue,
    required this.projection,
  });

  final Cue cue;
  final EquipmentPerformanceProjection projection;
}

/// Returns the comparison rows that should be rendered, or `null` when
/// the comparison must be hidden.
///
/// Rule 8 (PO amendment 2026-07-28): the section only renders when
/// exactly 2 valid cues are selected. "Valid" means:
/// - the cue belongs to the Active Player (caller-supplied `activePlayerId`
///   must match `cue.playerId`),
/// - `cue.isActive == true`.
///
/// If `activePlayerId` is null (no active player), the comparison is
/// hidden regardless of selection count.
List<EquipmentComparisonEntry>? buildComparisonEntries({
  required List<EquipmentComparisonEntry> selected,
  int? activePlayerId,
}) {
  if (activePlayerId == null) return null;
  if (selected.length < 2) return null;
  // Rule 2: cap at 2 (defensive).
  final capped = selected.length > 2 ? selected.sublist(0, 2) : selected;
  // Rule 8: hide entirely if any selected cue is inactive OR belongs to
  // a different player.
  for (final entry in capped) {
    if (entry.cue.isActive != true) return null;
    if (entry.cue.playerId != activePlayerId) return null;
  }
  return List<EquipmentComparisonEntry>.unmodifiable(capped);
}

bool _dateIsSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String _formatLastUsed(DateTime value, DateTime now, bool vi) {
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

class EquipmentComparisonSection extends StatelessWidget {
  const EquipmentComparisonSection({
    super.key,
    required this.selected,
    required this.now,
    required this.locale,
    this.activePlayerId,
  });

  final List<EquipmentComparisonEntry> selected;
  final DateTime now;
  final String locale;

  /// Active Player ID. Required for Rule 8 visibility gate. If null, the
  /// section is hidden entirely.
  final int? activePlayerId;

  @override
  Widget build(BuildContext context) {
    final vi = locale == 'vi';
    final entries = buildComparisonEntries(
      selected: selected,
      activePlayerId: activePlayerId,
    );

    final title = vi ? 'So sánh' : 'Comparison';

    // Rule 8: hide the entire Comparison section when conditions fail.
    if (entries == null) {
      return const SizedBox.shrink(
        key: ValueKey('equipment-comparison-hidden'),
      );
    }

    return Container(
      key: const ValueKey('equipment-comparison-section'),
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            key: const ValueKey('equipment-comparison-title'),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          _buildTable(context, entries, vi),
        ],
      ),
    );
  }

  Widget _buildTable(
    BuildContext context,
    List<EquipmentComparisonEntry> entries,
    bool vi,
  ) {
    final labels = vi
        ? <String, String>{
            'match_win': 'Tỷ lệ thắng',
            'training': 'Tập thành công',
            'matches': 'Trận',
            'trainings': 'Buổi tập',
            'last_used': 'Dùng gần nhất',
          }
        : <String, String>{
            'match_win': 'Match Win',
            'training': 'Training',
            'matches': 'Matches',
            'trainings': 'Trainings',
            'last_used': 'Last Used',
          };
    final rows = <List<String>>[
      [
        labels['match_win']!,
        entries[0].projection.matchWinRate.round().toString() + '%',
        entries[1].projection.matchWinRate.round().toString() + '%'
      ],
      [
        labels['training']!,
        entries[0].projection.trainingSuccessRate.round().toString() + '%',
        entries[1].projection.trainingSuccessRate.round().toString() + '%'
      ],
      [
        labels['matches']!,
        entries[0].projection.totalMatches.toString(),
        entries[1].projection.totalMatches.toString()
      ],
      [
        labels['trainings']!,
        entries[0].projection.totalTrainingSessions.toString(),
        entries[1].projection.totalTrainingSessions.toString()
      ],
      [
        labels['last_used']!,
        _formatLastUsedCell(entries[0].projection.lastUsed, vi),
        _formatLastUsedCell(entries[1].projection.lastUsed, vi),
      ],
    ];

    final insufficientLeft = _isInsufficient(entries[0].projection);
    final insufficientRight = _isInsufficient(entries[1].projection);

    return Column(
      key: const ValueKey('equipment-comparison-table'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeaderRow(context, entries),
        const SizedBox(height: 8),
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) const SizedBox(height: 4),
          _buildDataRow(
              context, rows[i], insufficientLeft, insufficientRight, i),
        ],
        if (insufficientLeft || insufficientRight) ...[
          const SizedBox(height: 8),
          Text(
            vi ? 'Chưa đủ dữ liệu.' : 'Chưa đủ dữ liệu.',
            key: const ValueKey('equipment-comparison-insufficient'),
          ),
        ],
      ],
    );
  }

  bool _isInsufficient(EquipmentPerformanceProjection projection) {
    // Per Rule 7: insufficient if matches OR training data is too small.
    // Spec is silent on a specific threshold; use the same conservative
    // guard the projection's own minimum sample implies: < 5 in either axis.
    return projection.totalMatches < 5 || projection.totalTrainingSessions < 5;
  }

  String _formatLastUsedCell(DateTime? value, bool vi) {
    if (value == null) return vi ? 'Chưa có' : 'Never';
    return _formatLastUsed(value, now, vi);
  }

  Widget _buildHeaderRow(
    BuildContext context,
    List<EquipmentComparisonEntry> entries,
  ) {
    return Row(
      children: [
        const SizedBox(width: 110),
        Expanded(
          child: Text(
            entries[0].cue.name,
            key: const ValueKey('equipment-comparison-header-left'),
            style: const TextStyle(fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Text(
            entries[1].cue.name,
            key: const ValueKey('equipment-comparison-header-right'),
            style: const TextStyle(fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildDataRow(
    BuildContext context,
    List<String> cells,
    bool insufficientLeft,
    bool insufficientRight,
    int rowIndex,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(cells[0]),
        ),
        Expanded(
          child: Text(
            cells[1],
            key: ValueKey('equipment-comparison-cell-left-$rowIndex'),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Text(
            cells[2],
            key: ValueKey('equipment-comparison-cell-right-$rowIndex'),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
