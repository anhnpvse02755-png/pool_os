import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/drill/domain/models/drill.dart';
import 'package:pool_os/features/training_center/presentation/providers/training_center_providers.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

/// Task 09 — drill picker used by the Training Session screen to add a drill.
/// Lists the whole unified library (built-in + custom, favourites first) with a
/// search box, and pops the selected [TrainingDrill] back to the caller.
class DrillPickerScreen extends ConsumerStatefulWidget {
  const DrillPickerScreen({super.key});

  @override
  ConsumerState<DrillPickerScreen> createState() => _DrillPickerScreenState();
}

class _DrillPickerScreenState extends ConsumerState<DrillPickerScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final library = ref.watch(trainingLibraryProvider);
    final favorites = ref.watch(favoriteKeysProvider).valueOrNull ?? const {};

    return Scaffold(
      appBar: AppBar(title: Text(l10n.get('tc_pick_drill'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: l10n.get('tc_search_hint'),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
            ),
          ),
          Expanded(
            child: library.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(l10n.get('tc_load_error'))),
              data: (drills) {
                final filtered = _query.isEmpty
                    ? drills
                    : drills.where((d) {
                        final name = d.displayName(locale).toLowerCase();
                        final cat = DrillCategory.getName(d.category, locale)
                            .toLowerCase();
                        return name.contains(_query) || cat.contains(_query);
                      }).toList();
                if (filtered.isEmpty) {
                  return Center(child: Text(l10n.get('tc_no_drills')));
                }
                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final d = filtered[i];
                    final fav = favorites.contains(d.key);
                    return ListTile(
                      leading: Icon(
                        d.isCustom ? Icons.build_circle_outlined : Icons.circle_outlined,
                      ),
                      title: Text(d.displayName(locale)),
                      subtitle: Text(
                        '${DrillCategory.getName(d.category, locale)}'
                        ' · ${l10n.get('tc_target')} ${d.targetReps}',
                      ),
                      trailing: fav
                          ? const Icon(Icons.star, color: Colors.amber)
                          : null,
                      onTap: () => Navigator.of(context).pop(d),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
