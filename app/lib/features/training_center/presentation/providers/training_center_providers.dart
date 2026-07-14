import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/drill/data/drill_library.dart';
import 'package:pool_os/features/drill/domain/models/drill.dart';
import 'package:pool_os/features/training_center/data/repositories/training_center_repository.dart';
import 'package:pool_os/features/training_center/domain/models/training_center_models.dart';

// Task 09 — Training Center providers. All read state comes from the repository
// (DB); nothing is fabricated. No AI, no recommendation — just data.

/// A library entry the Training Center can run: either a built-in [Drill] from
/// [DrillLibrary] or a player-made [CustomDrill]. Unifies the two so screens can
/// list, favourite and launch them the same way.
class TrainingDrill {
  final String key; // built-in drill code, or "custom:<id>"
  final String name;
  final String nameVi;
  final String category;
  final int targetReps;
  final String? successCriteria;
  final bool isCustom;
  final int? customDrillId;
  final String? drillCode;

  const TrainingDrill({
    required this.key,
    required this.name,
    required this.nameVi,
    required this.category,
    required this.targetReps,
    this.successCriteria,
    required this.isCustom,
    this.customDrillId,
    this.drillCode,
  });

  factory TrainingDrill.fromBuiltIn(Drill d) => TrainingDrill(
        key: d.code,
        name: d.name,
        nameVi: d.nameVi,
        category: d.category,
        targetReps: d.recommendedRepetitions ?? d.targetScore,
        isCustom: false,
        drillCode: d.code,
      );

  factory TrainingDrill.fromCustom(CustomDrill d) => TrainingDrill(
        key: d.drillKey,
        name: d.name,
        nameVi: d.name,
        category: d.category,
        targetReps: d.targetReps,
        successCriteria: d.successCriteria,
        isCustom: true,
        customDrillId: d.id,
      );

  String displayName(String locale) => locale == 'vi' ? nameVi : name;
}

/// Custom drills from the DB (Phần 3). Refreshable after create/delete.
final customDrillsProvider = FutureProvider<List<CustomDrill>>((ref) async {
  final repo = ref.watch(trainingCenterRepositoryProvider);
  return repo.getCustomDrills();
});

/// Set of favourite drill keys (Phần 5).
final favoriteKeysProvider = FutureProvider<Set<String>>((ref) async {
  final repo = ref.watch(trainingCenterRepositoryProvider);
  return repo.getFavoriteKeys();
});

/// The full unified library: built-in drills (from [DrillLibrary], which already
/// contains Stop Shot / Follow / Draw / Long Pot / Cut / Position / Break / Jump
/// / Safety / Kick … across 17 categories) plus the player's custom drills.
/// Favourites float to the top (Phần 5), then everything is grouped by category.
final trainingLibraryProvider = FutureProvider<List<TrainingDrill>>((ref) async {
  final customs = await ref.watch(customDrillsProvider.future);
  final favorites = await ref.watch(favoriteKeysProvider.future);

  final builtIns =
      DrillLibrary.getAllDrills().map(TrainingDrill.fromBuiltIn).toList();
  final customDrills = customs.map(TrainingDrill.fromCustom).toList();

  final all = [...customDrills, ...builtIns];
  // Stable sort: favourites first, otherwise keep source order.
  all.sort((a, b) {
    final af = favorites.contains(a.key) ? 0 : 1;
    final bf = favorites.contains(b.key) ? 0 : 1;
    return af.compareTo(bf);
  });
  return all;
});

/// Library entries grouped by category code (Phần 1 — Category list → Drill list).
final libraryByCategoryProvider =
    FutureProvider<Map<String, List<TrainingDrill>>>((ref) async {
  final drills = await ref.watch(trainingLibraryProvider.future);
  final grouped = <String, List<TrainingDrill>>{};
  for (final d in drills) {
    grouped.putIfAbsent(d.category, () => []).add(d);
  }
  return grouped;
});

/// The 5 most recent drill runs (Phần 6 — Recent Drill), newest first.
final recentDrillRunsProvider = FutureProvider<List<DrillRun>>((ref) async {
  final repo = ref.watch(trainingCenterRepositoryProvider);
  return repo.getAllRuns(limit: 5);
});

/// Recent training sessions (for history on the Training Center home).
final recentTrainingSessionsProvider =
    FutureProvider<List<TrainingSession>>((ref) async {
  final repo = ref.watch(trainingCenterRepositoryProvider);
  return repo.getRecentSessions(limit: 20);
});
