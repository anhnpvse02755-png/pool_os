import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/match/domain/models/match_context.dart';
import 'package:pool_os/features/match/presentation/match_context_provider.dart';

/// Task 06 Part 1: pre-match context. Single-tap chips only — target is
/// ~15-20s to complete. Nothing here blocks Rack/Shot recording; it is opened
/// before a match and saved in one action.
class PreMatchContextScreen extends ConsumerStatefulWidget {
  final int matchId;
  const PreMatchContextScreen({super.key, required this.matchId});

  @override
  ConsumerState<PreMatchContextScreen> createState() => _PreMatchContextScreenState();
}

class _PreMatchContextScreenState extends ConsumerState<PreMatchContextScreen> {
  String? _purpose;
  String? _opponent;
  String? _table;
  String? _room;
  String? _lighting;
  String? _warmup;
  final Set<String> _goals = {};

  bool _initFromExisting = false;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final vi = locale == 'vi';
    final state = ref.watch(matchContextProvider(widget.matchId));

    // Prefill once if a pre-match context already exists (editing).
    if (!_initFromExisting && state.context != null) {
      final c = state.context!;
      _purpose = c.purpose;
      _opponent = c.opponent;
      _table = c.tableFamiliarity;
      _room = c.roomFamiliarity;
      _lighting = c.lighting;
      _warmup = c.warmupLevel;
      _goals.addAll(c.matchGoals);
      _initFromExisting = true;
    }

    return Scaffold(
      appBar: AppBar(title: Text(vi ? 'Trước trận đấu' : 'Before the match')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _single(vi ? 'Mục đích' : 'Purpose', MatchPurpose.all,
              (c) => MatchPurpose.label(c, locale), _purpose, (v) => setState(() => _purpose = v)),
          _single(vi ? 'Đối thủ' : 'Opponent', MatchOpponent.all,
              (c) => MatchOpponent.label(c, locale), _opponent, (v) => setState(() => _opponent = v)),
          _single(vi ? 'Bàn' : 'Table', Familiarity.all,
              (c) => Familiarity.label(c, locale), _table, (v) => setState(() => _table = v)),
          _single(vi ? 'Phòng' : 'Room', Familiarity.all,
              (c) => Familiarity.label(c, locale), _room, (v) => setState(() => _room = v)),
          _single(vi ? 'Ánh sáng' : 'Lighting', Lighting.all,
              (c) => Lighting.label(c, locale), _lighting, (v) => setState(() => _lighting = v)),
          _single(vi ? 'Khởi động' : 'Warm-up', WarmupLevel.all,
              (c) => WarmupLevel.label(c, locale), _warmup, (v) => setState(() => _warmup = v)),
          _multi(vi ? 'Mục tiêu trận đấu' : 'Match goals', MatchGoal.all,
              (c) => MatchGoal.label(c, locale), _goals),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: state.isSaving ? null : () => _save(vi),
            icon: const Icon(Icons.check),
            label: Text(vi ? 'Lưu & bắt đầu' : 'Save & start'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(vi ? 'Bỏ qua' : 'Skip'),
          ),
        ],
      ),
    );
  }

  Widget _single(String title, List<String> codes, String Function(String) label,
      String? selected, ValueChanged<String> onPick) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: codes.map((c) => ChoiceChip(
                  label: Text(label(c)),
                  selected: selected == c,
                  onSelected: (_) => onPick(c),
                )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _multi(String title, List<String> codes, String Function(String) label, Set<String> sel) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: codes.map((c) => FilterChip(
                  label: Text(label(c)),
                  selected: sel.contains(c),
                  onSelected: (v) => setState(() => v ? sel.add(c) : sel.remove(c)),
                )).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _save(bool vi) async {
    final ctx = MatchContext(
      matchId: widget.matchId,
      purpose: _purpose,
      opponent: _opponent,
      tableFamiliarity: _table,
      roomFamiliarity: _room,
      lighting: _lighting,
      warmupLevel: _warmup,
      matchGoals: _goals.toList(),
      preRecordedAt: DateTime.now(),
    );
    final ok = await ref.read(matchContextProvider(widget.matchId).notifier).savePre(ctx);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vi ? 'Lưu thất bại' : 'Save failed')),
      );
    }
  }
}
