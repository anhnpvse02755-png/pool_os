import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/goal_center/domain/models/goal_center_models.dart';
import 'package:pool_os/features/goal_center/presentation/providers/goal_center_providers.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

/// Task 10 — create a custom goal (Phần 1 — "Có Goal tự tạo"). The player names
/// the goal, picks a [GoalMetric], and sets a target amount. For cumulative
/// metrics the amount means "how many more from now"; for rate metrics it is the
/// absolute percentage to reach. The controller computes baseline/target from
/// the current metrics snapshot so progress reads honestly.
class GoalEditorScreen extends ConsumerStatefulWidget {
  const GoalEditorScreen({super.key});

  @override
  ConsumerState<GoalEditorScreen> createState() => _GoalEditorScreenState();
}

class _GoalEditorScreenState extends ConsumerState<GoalEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController(text: '10');
  final _noteController = TextEditingController();
  GoalMetric _metric = GoalMetric.matchesWon;
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    try {
      await ref.read(goalCenterControllerProvider).createGoal(
            title: _titleController.text.trim(),
            metric: _metric,
            amount: amount,
            note: _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
          );
      if (mounted) Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isPercent = _metric.isPercent;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.get('gc_new_goal'))),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: l10n.get('gc_goal_title'),
                border: const OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? l10n.get('gc_title_required')
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.get('gc_metric'),
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<GoalMetric>(
              initialValue: _metric,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: GoalMetric.values
                  .map((m) => DropdownMenuItem(
                        value: m,
                        child: Text(l10n.get(m.labelKey)),
                      ))
                  .toList(),
              onChanged: (m) {
                if (m != null) setState(() => _metric = m);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: isPercent
                    ? l10n.get('gc_target_percent')
                    : l10n.get('gc_target_amount'),
                helperText: isPercent
                    ? l10n.get('gc_target_percent_help')
                    : l10n.get('gc_target_amount_help'),
                suffixText: isPercent ? '%' : null,
                border: const OutlineInputBorder(),
              ),
              validator: (v) {
                final n = double.tryParse(v?.trim() ?? '');
                if (n == null || n <= 0) return l10n.get('gc_amount_invalid');
                if (isPercent && n > 100) return l10n.get('gc_amount_invalid');
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: l10n.get('gc_note_optional'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: Text(l10n.get('save')),
            ),
          ],
        ),
      ),
    );
  }
}
