import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/tournament/domain/models/tournament_models.dart';
import 'package:pool_os/features/tournament/presentation/providers/tournament_providers.dart';
import 'package:pool_os/features/tournament/presentation/screens/tournament_detail_screen.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

/// Task 13 — create a tournament (Phần 1/2). Name + type are required; location,
/// notes and dates are optional. On save, opens the detail screen for the new
/// tournament so the player can add participants and generate the bracket.
class TournamentCreateScreen extends ConsumerStatefulWidget {
  const TournamentCreateScreen({super.key});

  @override
  ConsumerState<TournamentCreateScreen> createState() =>
      _TournamentCreateScreenState();
}

class _TournamentCreateScreenState
    extends ConsumerState<TournamentCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  TournamentType _type = TournamentType.singleElimination;
  TournamentCompetitionMode _competitionMode =
      TournamentCompetitionMode.individual;
  bool _hasThirdPlaceMatch = false;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.get('tnmt_new')), centerTitle: true),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: l10n.get('tnmt_name'),
                border: const OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? l10n.get('tnmt_name_required')
                  : null,
            ),
            const SizedBox(height: 16),
            Text(l10n.get('tnmt_competition_mode'),
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            SegmentedButton<TournamentCompetitionMode>(
              segments: [
                for (final mode in TournamentCompetitionMode.values)
                  ButtonSegment(
                    value: mode,
                    icon: Icon(mode == TournamentCompetitionMode.individual
                        ? Icons.person_outline
                        : Icons.groups_outlined),
                    label: Text(l10n.get(mode.labelKey)),
                  ),
              ],
              selected: {_competitionMode},
              onSelectionChanged: (selection) =>
                  setState(() => _competitionMode = selection.single),
            ),
            const SizedBox(height: 16),
            Text(l10n.get('tnmt_type'),
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            ...TournamentType.values.map(
              (t) => RadioListTile<TournamentType>(
                value: t,
                groupValue: _type,
                onChanged: (v) => setState(() => _type = v!),
                title: Text(l10n.get(t.labelKey)),
                subtitle: Text(l10n.get('${t.labelKey}_desc')),
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            ),
            if (_type == TournamentType.singleElimination ||
                _type == TournamentType.doubleElimination)
              SwitchListTile(
                value: _hasThirdPlaceMatch,
                onChanged: (value) =>
                    setState(() => _hasThirdPlaceMatch = value),
                title: Text(l10n.get('tnmt_third_place_option')),
                subtitle: Text(l10n.get('tnmt_third_place_option_desc')),
                contentPadding: EdgeInsets.zero,
              ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _locationCtrl,
              decoration: InputDecoration(
                labelText: l10n.get('tnmt_location'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _dateField(
                    context,
                    l10n.get('tnmt_start_date'),
                    _startDate,
                    (d) => setState(() => _startDate = d),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _dateField(
                    context,
                    l10n.get('tnmt_end_date'),
                    _endDate,
                    (d) => setState(() => _endDate = d),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesCtrl,
              decoration: InputDecoration(
                labelText: l10n.get('tnmt_notes'),
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.check),
              label: Text(l10n.get('tnmt_create')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateField(
    BuildContext context,
    String label,
    DateTime? value,
    ValueChanged<DateTime?> onPick,
  ) {
    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? now,
          firstDate: DateTime(now.year - 2),
          lastDate: DateTime(now.year + 5),
        );
        if (picked != null) onPick(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Text(
          value == null
              ? '—'
              : '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}',
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final controller = ref.read(tournamentControllerProvider);
    final id = await controller.create(
      Tournament(
        name: _nameCtrl.text.trim(),
        type: _type,
        competitionMode: _competitionMode,
        hasThirdPlaceMatch: (_type == TournamentType.singleElimination ||
                _type == TournamentType.doubleElimination) &&
            _hasThirdPlaceMatch,
        location: _locationCtrl.text.trim().isEmpty
            ? null
            : _locationCtrl.text.trim(),
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        createdAt: DateTime.now(),
      ),
    );
    if (!mounted) return;
    // Replace this screen with the detail screen for the new tournament.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (_) => TournamentDetailScreen(tournamentId: id)),
    );
  }
}
