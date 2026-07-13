import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/player/domain/models/player.dart';
import 'package:pool_os/features/player/presentation/player_profile_provider.dart';
import 'package:pool_os/shared/constants/app_constants.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

/// Task 05: edit the career profile. Creates the player row on first save or
/// updates the existing one. Only editable fields live here — achievements and
/// timeline are read-only and shown on the profile screen.
class PlayerProfileEditSheet extends ConsumerStatefulWidget {
  final Player? player;
  const PlayerProfileEditSheet({super.key, this.player});

  @override
  ConsumerState<PlayerProfileEditSheet> createState() => _PlayerProfileEditSheetState();
}

class _PlayerProfileEditSheetState extends ConsumerState<PlayerProfileEditSheet> {
  late final TextEditingController _name;
  late final TextEditingController _age;
  late final TextEditingController _gender;
  late final TextEditingController _club;
  late final TextEditingController _goal;
  late final TextEditingController _hours;

  late String _dominantHand;
  String? _rank;
  String? _mainGame;
  late Set<String> _styles;
  late Set<String> _goals;
  late bool _hasCompeted;
  DateTime? _startedPlayingAt;

  static const _ranks = ['H', 'G', 'F', 'E', 'D', 'C', 'B', 'A'];
  static const _games = ['9 Ball', '10 Ball', '8 Ball'];

  @override
  void initState() {
    super.initState();
    final p = widget.player;
    _name = TextEditingController(text: p?.name ?? '');
    _age = TextEditingController(text: p?.age?.toString() ?? '');
    _gender = TextEditingController(text: p?.gender ?? '');
    _club = TextEditingController(text: p?.clubRegion ?? '');
    _goal = TextEditingController(text: p?.goal ?? '');
    _hours = TextEditingController(text: p?.hoursPerWeek?.toString() ?? '');
    _dominantHand = p?.dominantHand ?? DominantHand.right.name;
    _rank = p?.rank;
    _mainGame = p?.mainGame;
    _styles = {...?p?.playStyles};
    _goals = {...?p?.trainingGoals};
    _hasCompeted = p?.hasCompeted ?? false;
    _startedPlayingAt = p?.startedPlayingAt;
  }

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _gender.dispose();
    _club.dispose();
    _goal.dispose();
    _hours.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final vi = locale == 'vi';

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(vi ? 'Chỉnh sửa hồ sơ' : 'Edit profile',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _text(_name, vi ? 'Tên' : 'Name', Icons.person),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _text(_age, vi ? 'Tuổi' : 'Age', Icons.cake, number: true)),
              const SizedBox(width: 12),
              Expanded(child: _text(_gender, vi ? 'Giới tính' : 'Gender', Icons.wc)),
            ]),
            const SizedBox(height: 12),
            _handDropdown(l10n, vi),
            const SizedBox(height: 12),
            _text(_club, vi ? 'CLB / Khu vực' : 'Club / Region', Icons.location_on),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _dropdown(vi ? 'Hạng' : 'Rank', _rank, _ranks, (v) => setState(() => _rank = v))),
              const SizedBox(width: 12),
              Expanded(child: _dropdown(vi ? 'Game chính' : 'Main game', _mainGame, _games, (v) => setState(() => _mainGame = v))),
            ]),
            const SizedBox(height: 12),
            _text(_goal, vi ? 'Mục tiêu' : 'Goal', Icons.flag),
            const SizedBox(height: 16),
            _multiSelect(vi ? 'Phong cách thi đấu' : 'Play style', PlayStyles.all,
                (c) => PlayStyles.label(c, locale), _styles),
            const SizedBox(height: 16),
            _multiSelect(vi ? 'Mục tiêu luyện tập' : 'Training goals', TrainingGoals.all,
                (c) => TrainingGoals.label(c, locale), _goals),
            const SizedBox(height: 16),
            _startedField(vi),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(vi ? 'Đã thi đấu giải' : 'Has competed'),
              value: _hasCompeted,
              onChanged: (v) => setState(() => _hasCompeted = v),
            ),
            _text(_hours, vi ? 'Giờ / tuần' : 'Hours / week', Icons.schedule, number: true),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.get('cancel')),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: () => _save(context, vi),
                  child: Text(l10n.get('save')),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _text(TextEditingController c, String label, IconData icon, {bool number = false}) {
    return TextField(
      controller: c,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }

  Widget _handDropdown(AppLocalizations l10n, bool vi) {
    return DropdownButtonFormField<String>(
      value: _dominantHand,
      decoration: InputDecoration(
        labelText: vi ? 'Tay thuận' : 'Dominant hand',
        prefixIcon: const Icon(Icons.pan_tool),
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      items: [
        DropdownMenuItem(value: DominantHand.left.name, child: Text(l10n.get('left'))),
        DropdownMenuItem(value: DominantHand.right.name, child: Text(l10n.get('right'))),
      ],
      onChanged: (v) => setState(() => _dominantHand = v ?? _dominantHand),
    );
  }

  Widget _dropdown(String label, String? value, List<String> options, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _multiSelect(String title, List<String> codes, String Function(String) label, Set<String> selected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: codes.map((code) {
            final isSel = selected.contains(code);
            return FilterChip(
              label: Text(label(code)),
              selected: isSel,
              onSelected: (v) => setState(() {
                if (v) {
                  selected.add(code);
                } else {
                  selected.remove(code);
                }
              }),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _startedField(bool vi) {
    final text = _startedPlayingAt == null
        ? (vi ? 'Chưa chọn' : 'Not set')
        : '${_startedPlayingAt!.month.toString().padLeft(2, '0')}/${_startedPlayingAt!.year}';
    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: _startedPlayingAt ?? DateTime(now.year - 1, now.month),
          firstDate: DateTime(1970),
          lastDate: now,
        );
        if (picked != null) setState(() => _startedPlayingAt = picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: vi ? 'Bắt đầu chơi' : 'Started playing',
          prefixIcon: const Icon(Icons.event),
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        child: Text(text),
      ),
    );
  }

  void _save(BuildContext context, bool vi) {
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vi ? 'Cần nhập tên' : 'Name is required')),
      );
      return;
    }
    final existing = widget.player;
    final player = Player(
      id: existing?.id,
      name: _name.text.trim(),
      dominantHand: _dominantHand,
      language: existing?.language ?? AppConstants.defaultLanguage.name,
      measurementSystem: existing?.measurementSystem ?? AppConstants.defaultMeasurementSystem.name,
      theme: existing?.theme ?? AppConstants.themeDark,
      isActive: existing?.isActive ?? true,
      avatarPath: existing?.avatarPath,
      age: int.tryParse(_age.text.trim()),
      gender: _gender.text.trim().isEmpty ? null : _gender.text.trim(),
      clubRegion: _club.text.trim().isEmpty ? null : _club.text.trim(),
      rank: _rank,
      mainGame: _mainGame,
      goal: _goal.text.trim().isEmpty ? null : _goal.text.trim(),
      playStyles: _styles.toList(),
      trainingGoals: _goals.toList(),
      startedPlayingAt: _startedPlayingAt,
      hasCompeted: _hasCompeted,
      hoursPerWeek: int.tryParse(_hours.text.trim()),
      createdAt: existing?.createdAt,
      updatedAt: DateTime.now(),
    );
    ref.read(playerProfileProvider.notifier).saveProfile(player);
    Navigator.of(context).pop();
  }
}
