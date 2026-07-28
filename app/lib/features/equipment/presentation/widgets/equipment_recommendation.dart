import 'package:flutter/material.dart';

import '../../domain/models/cue.dart';
import '../../domain/equipment_performance_projection.dart';

/// FEATURE_010 Equipment Recommendation — deterministic, no AI, no engine.
///
/// Reads only the existing [EquipmentPerformanceProjection] (which already
/// carries playerId, equipmentId, match win rate, training success rate,
/// last used, and the source facts). Does NOT touch schema, repository,
/// projection, or any new service.
///
/// Source spec: `architecture/product/features/FEATURE_010_EQUIPMENT_RECOMMENDATION.md`
class RecommendedCue {
  const RecommendedCue({
    required this.cue,
    required this.projection,
  });

  final Cue cue;
  final EquipmentPerformanceProjection projection;
}

/// Minimum sample required to surface any recommendation.
///
/// Spec rule 4: "Nếu dữ liệu chưa đủ (ví dụ dưới 5 trận và dưới 5 buổi tập)
/// → Hiển thị: Chưa đủ dữ liệu để khuyến nghị."
const int kRecommendationMinMatches = 5;
const int kRecommendationMinTraining = 5;

/// Maximum surfaced cues. Spec rule 6.
const int kRecommendationTopN = 3;

/// Pure deterministic computation. No I/O, no time source.
///
/// Inputs:
/// - [cues]: cue list already filtered to Active Player by the caller.
/// - [projections]: projections already filtered to Active Player.
/// - [now]: caller-supplied clock so tests stay deterministic.
///
/// Output: either an empty list (insufficient data — UI shows the spec's
/// "Chưa đủ dữ liệu" message) or a sorted top-[kRecommendationTopN] list,
/// never more, ties broken by `Equipment.ID` ascending.
List<RecommendedCue> recommendCues({
  required List<Cue> cues,
  required List<EquipmentPerformanceProjection> projections,
  required DateTime now,
}) {
  if (cues.isEmpty) return const <RecommendedCue>[];

  // Spec rule 2: only active cues.
  final activeCues = cues.where((cue) => cue.isActive).toList();
  if (activeCues.isEmpty) return const <RecommendedCue>[];

  // Spec rule 1: only cues that belong to the Active Player. The caller must
  // already have done this filter; if a cue's playerId is set and no
  // projection matches its id we still must drop it, because it has no
  // recorded performance.
  final projectedCues = <RecommendedCue>[];
  for (final cue in activeCues) {
    if (cue.id == null) continue;
    final projection =
        projections.where((item) => item.equipmentId == cue.id).firstOrNull;
    if (projection == null) continue;
    projectedCues.add(RecommendedCue(cue: cue, projection: projection));
  }
  if (projectedCues.isEmpty) return const <RecommendedCue>[];

  // Spec rule 4: insufficient data — sample guard.
  final totalMatches = projectedCues.fold<int>(
      0, (sum, item) => sum + item.projection.totalMatches);
  final totalTraining = projectedCues.fold<int>(
      0, (sum, item) => sum + item.projection.totalTrainingSessions);
  if (totalMatches < kRecommendationMinMatches ||
      totalTraining < kRecommendationMinTraining) {
    return const <RecommendedCue>[];
  }

  // Spec rule 3 + 7: deterministic sort by:
  //   1. Match Win Rate desc
  //   2. Training Success Rate desc
  //   3. Last Used (more recent first; null last)
  //   4. Equipment ID asc (tie-break)
  projectedCues.sort((a, b) {
    int cmp;
    cmp = b.projection.matchWinRate.compareTo(a.projection.matchWinRate);
    if (cmp != 0) return cmp;
    cmp = b.projection.trainingSuccessRate
        .compareTo(a.projection.trainingSuccessRate);
    if (cmp != 0) return cmp;
    // Last Used: more recent first. null last.
    final aLast = a.projection.lastUsed;
    final bLast = b.projection.lastUsed;
    if (aLast == null && bLast == null) {
      // Tie-break by Equipment ID asc.
      return a.cue.id!.compareTo(b.cue.id!);
    } else if (aLast == null) {
      return 1;
    } else if (bLast == null) {
      return -1;
    } else {
      cmp = bLast.compareTo(aLast);
      if (cmp != 0) return cmp;
      return a.cue.id!.compareTo(b.cue.id!);
    }
  });

  // Spec rule 6: top N only.
  final top = projectedCues.length <= kRecommendationTopN
      ? projectedCues
      : projectedCues.sublist(0, kRecommendationTopN);
  return List<RecommendedCue>.unmodifiable(top);
}

bool _dateIsSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String _formatLastUsed(DateTime now, DateTime? value, bool vi) {
  if (value == null) return vi ? 'Chưa có' : 'Never';
  final local = value.toLocal();
  if (_dateIsSameDay(local, now)) {
    return vi ? 'Hôm nay' : 'Today';
  }
  final yesterday = now.subtract(const Duration(days: 1));
  if (_dateIsSameDay(local, yesterday)) {
    return vi ? 'Hôm qua' : 'Yesterday';
  }
  final y = local.year.toString().padLeft(4, '0');
  final m = local.month.toString().padLeft(2, '0');
  final d = local.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

class RecommendedEquipmentSection extends StatelessWidget {
  const RecommendedEquipmentSection({
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
    final recommended = recommendCues(
      cues: cues,
      projections: projections,
      now: now,
    );

    final insufficient = recommended.isEmpty &&
        cues.where((c) => c.isActive && c.id != null).isNotEmpty;

    final titleKey = vi
        ? 'equipment_recommendation_title_vi'
        : 'equipment_recommendation_title';

    return Container(
      key: const ValueKey('equipment-recommendation-section'),
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
            vi ? 'Cơ khuyến nghị' : 'Recommended Equipment',
            key: ValueKey(titleKey),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          if (insufficient)
            Text(
              vi
                  ? 'Chưa đủ dữ liệu để khuyến nghị.'
                  : 'Insufficient data to recommend.',
              key: const ValueKey('equipment-recommendation-empty'),
            )
          else if (recommended.isEmpty)
            // No active cues; do not invent a message about insufficient data.
            const SizedBox.shrink()
          else
            Column(
              key: const ValueKey('equipment-recommendation-list'),
              children: [
                for (var i = 0; i < recommended.length; i++)
                  Padding(
                    padding: EdgeInsets.only(
                      top: i == 0 ? 0 : 8,
                    ),
                    child: _RecommendationRow(
                      rank: i + 1,
                      cue: recommended[i].cue,
                      projection: recommended[i].projection,
                      now: now,
                      vi: vi,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _RecommendationRow extends StatelessWidget {
  const _RecommendationRow({
    required this.rank,
    required this.cue,
    required this.projection,
    required this.now,
    required this.vi,
  });

  final int rank;
  final Cue cue;
  final EquipmentPerformanceProjection projection;
  final DateTime now;
  final bool vi;

  @override
  Widget build(BuildContext context) {
    final matchWinRate = projection.matchWinRate.round();
    final trainingSuccess = projection.trainingSuccessRate.round();
    final lastUsedLabel = _formatLastUsed(now, projection.lastUsed, vi);
    return Container(
      key: ValueKey('equipment-recommendation-row-${projection.equipmentId}'),
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor.withAlpha(40),
            width: rank == 1 ? 0 : 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '#$rank',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  cue.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Icon(
                Icons.star,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
                semanticLabel: vi ? 'Khuyến nghị' : 'Recommended',
              ),
            ],
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 16,
            runSpacing: 4,
            children: [
              _stat(vi ? 'Tỷ lệ thắng' : 'Win rate', '$matchWinRate%'),
              _stat(vi ? 'Tập thành công' : 'Success', '$trainingSuccess%'),
              _stat(vi ? 'Dùng gần nhất' : 'Last used', lastUsedLabel),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) => SizedBox(
        width: 120,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      );
}
