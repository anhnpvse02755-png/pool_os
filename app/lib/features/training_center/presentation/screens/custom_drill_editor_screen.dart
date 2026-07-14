import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/drill/domain/models/drill.dart';
import 'package:pool_os/features/training_center/data/repositories/training_center_repository.dart';
import 'package:pool_os/features/training_center/domain/models/training_center_models.dart';
import 'package:pool_os/features/training_center/presentation/providers/training_center_providers.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

/// Task 09 — Phần 3 Custom Drill. The player defines a name, category, rep
/// target, and a free-text success condition. Saved to the DB and immediately
/// available in the library.
class CustomDrillEditorScreen extends ConsumerStatefulWidget {
  const CustomDrillEditorScreen({super.key});

  @override
  ConsumerState<CustomDrillEditorScreen> createState() =>
      _CustomDrillEditorScreenState();
}

class _CustomDrillEditorScreenState
    extends ConsumerState<CustomDrillEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _repsController = TextEditingController(text: '100');
  final _criteriaController = TextEditingController();
  String _category = DrillCategory.all.first;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _repsController.dispose();
    _criteriaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.get('tc_custom_drill_title'))),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.get('tc_drill_name'),
                hintText: l10n.get('tc_drill_name_hint'),
                border: const OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? l10n.get('tc_name_required')
                  : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: InputDecoration(
                labelText: l10n.get('tc_category'),
                border: const OutlineInputBorder(),
              ),
              items: DrillCategory.all
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(DrillCategory.getName(c, locale)),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _category = v ?? _category),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _repsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.get('tc_target_reps'),
                border: const OutlineInputBorder(),
              ),
              validator: (v) {
                final n = int.tryParse(v?.trim() ?? '');
                if (n == null || n <= 0) return l10n.get('tc_reps_invalid');
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _criteriaController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10n.get('tc_success_criteria'),
                hintText: l10n.get('tc_success_criteria_hint'),
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : () => _save(l10n),
              child: Text(l10n.get('tc_save')),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final criteria = _criteriaController.text.trim();
      await ref.read(trainingCenterRepositoryProvider).createCustomDrill(
            CustomDrill(
              name: _nameController.text.trim(),
              category: _category,
              targetReps: int.parse(_repsController.text.trim()),
              successCriteria: criteria.isEmpty ? null : criteria,
              createdAt: DateTime.now(),
            ),
          );
      ref.invalidate(customDrillsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.get('tc_saved'))),
      );
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
