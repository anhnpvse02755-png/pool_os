import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/club/domain/models/club_models.dart';
import 'package:pool_os/features/club/presentation/providers/club_providers.dart';
import 'package:pool_os/features/club/presentation/screens/club_detail_screen.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

/// Task 14 — create a club (Phần 1). Name is required; location, description
/// and manager are optional. On save, opens the detail screen so the user can
/// add members and link matches/trainings/tournaments.
class ClubCreateScreen extends ConsumerStatefulWidget {
  const ClubCreateScreen({super.key});

  @override
  ConsumerState<ClubCreateScreen> createState() => _ClubCreateScreenState();
}

class _ClubCreateScreenState extends ConsumerState<ClubCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _managerCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _descCtrl.dispose();
    _managerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.get('club_new')), centerTitle: true),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: l10n.get('club_name'),
                border: const OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? l10n.get('club_name_required')
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationCtrl,
              decoration: InputDecoration(
                labelText: l10n.get('club_location'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _managerCtrl,
              decoration: InputDecoration(
                labelText: l10n.get('club_manager'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descCtrl,
              decoration: InputDecoration(
                labelText: l10n.get('club_description'),
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
              label: Text(l10n.get('club_create')),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final id = await ref.read(clubControllerProvider).create(
          Club(
            name: _nameCtrl.text.trim(),
            location: _locationCtrl.text.trim().isEmpty
                ? null
                : _locationCtrl.text.trim(),
            managerName: _managerCtrl.text.trim().isEmpty
                ? null
                : _managerCtrl.text.trim(),
            description:
                _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
            createdAt: DateTime.now(),
          ),
        );
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ClubDetailScreen(clubId: id)),
    );
  }
}
