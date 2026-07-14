import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/drill/domain/models/drill.dart';
import 'package:pool_os/features/training_center/data/repositories/training_center_repository.dart';
import 'package:pool_os/features/training_center/presentation/providers/training_center_providers.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

/// Task 09 — Phần 1: drills within one category. Each drill can be favourited
/// (Phần 5 — star toggles persistence and re-sorts the library).
class CategoryDrillsScreen extends ConsumerWidget {
  const CategoryDrillsScreen({super.key, required this.category});

  final String category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final byCategory = ref.watch(libraryByCategoryProvider);
    final favorites = ref.watch(favoriteKeysProvider).valueOrNull ?? const {};

    return Scaffold(
      appBar: AppBar(title: Text(DrillCategory.getName(category, locale))),
      body: byCategory.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.get('tc_load_error'))),
        data: (grouped) {
          final drills = grouped[category] ?? const [];
          if (drills.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l10n.get('tc_no_drills')),
              ),
            );
          }
          return ListView.separated(
            itemCount: drills.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final d = drills[i];
              final fav = favorites.contains(d.key);
              return ListTile(
                leading: Icon(d.isCustom
                    ? Icons.build_circle_outlined
                    : Icons.circle_outlined),
                title: Text(d.displayName(locale)),
                subtitle: Text(
                  '${l10n.get('tc_target')} ${d.targetReps}'
                  '${d.successCriteria != null ? ' · ${d.successCriteria}' : ''}',
                ),
                trailing: IconButton(
                  icon: Icon(
                    fav ? Icons.star : Icons.star_border,
                    color: fav ? Colors.amber : null,
                  ),
                  onPressed: () async {
                    await ref
                        .read(trainingCenterRepositoryProvider)
                        .setFavorite(d.key, !fav);
                    ref.invalidate(favoriteKeysProvider);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
