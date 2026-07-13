import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/career/data/repositories/career_repository.dart';
import 'package:pool_os/features/career/domain/models/career_models.dart';

// Task 11 — Player Timeline & Career providers. Everything is READ-ONLY over the
// data already recorded by other features; nothing is written and no new tables
// exist. No AI, no coach, no recommendation — just the player's journey.

/// The selected timeline filter (Phần 7). Empty set = show all types.
final timelineFilterProvider =
    StateProvider<Set<TimelineEventType>>((ref) => <TimelineEventType>{});

/// The career summary roll-up (Phần 2). Recomputed on refresh.
final careerSummaryProvider = FutureProvider<CareerSummary>((ref) async {
  final repo = ref.watch(careerRepositoryProvider);
  return repo.buildSummary();
});

/// The full, unfiltered list of timeline events. The screen passes a localized
/// [CareerLabels] bundle via [timelineEventsProvider] (family) so display strings
/// resolve without the repository needing a BuildContext.
final timelineEventsProvider =
    FutureProvider.family<List<TimelineEvent>, CareerLabels>(
        (ref, labels) async {
  final repo = ref.watch(careerRepositoryProvider);
  return repo.buildTimeline(labels);
});
