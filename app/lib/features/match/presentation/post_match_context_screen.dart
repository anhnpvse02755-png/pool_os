import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/match/domain/models/match_context.dart';
import 'package:pool_os/features/match/presentation/match_context_provider.dart';

/// Task 06 Part 2: post-match context — the important half. Single-tap chips +
/// a star rating; target ~15-20s. Opened after a match finishes; never during
/// Rack/Shot recording.
class PostMatchContextScreen extends ConsumerStatefulWidget {
  final int matchId;
  const PostMatchContextScreen({super.key, required this.matchId});

  @override
  ConsumerState<PostMatchContextScreen> createState() => _PostMatchContextScreenState();
}

class _PostMatchContextScreenState extends ConsumerState<PostMatchContextScreen> {
  String? _fatigue;
  final Set<String> _fatigueAreas = {};
  String? _mental;
  int? _rating;
  String? _factor;

  bool _initFromExisting = false;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final vi = locale == 'vi';
    final state = ref.watch(matchContextProvider(widget.matchId));

    if (!_initFromExisting && state.context != null) {
      final c = state.context!;
      _fatigue = c.fatigueLevel;
      _fatigueAreas.addAll(c.fatigueAreas);
      _mental = c.mentalState;
      _rating = c.selfRating;
      _factor = c.biggestFactor;
      _initFromExisting = true;
    }

    return Scaffold(
      appBar: AppBar(title: Text(vi ? 'Sau trận đấu' : 'After the match')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _single(vi ? 'Mức độ mệt' : 'Fatigue', FatigueLevel.all,
              (c) => FatigueLevel.label(c, locale), _fatigue, (v) => setState(() => _fatigue = v)),
          _multi(vi ? 'Mệt ở đâu' : 'Where', FatigueArea.all,
              (c) => FatigueArea.label(c, locale), _fatigueAreas),
          _single(vi ? 'Tinh thần' : 'Mental', MentalState.all,
              (c) => MentalState.label(c, locale), _mental, (v) => setState(() => _mental = v)),
          _stars(vi),
          _single(vi ? 'Ảnh hưởng nhiều nhất' : 'Biggest factor', BiggestFactor.all,
              (c) => BiggestFactor.label(c, locale), _factor, (v) => setState(() => _factor = v)),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: state.isSaving ? null : () => _save(vi),
            icon: const Icon(Icons.check),
            label: Text(vi ? 'Lưu' : 'Save'),
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

  Widget _stars(bool vi) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(vi ? 'Đánh giá phong độ' : 'Self rating',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Row(
            children: List.generate(5, (i) {
              final v = i + 1;
              final filled = _rating != null && v <= _rating!;
              return IconButton(
                onPressed: () => setState(() => _rating = v),
                icon: Icon(filled ? Icons.star : Icons.star_border,
                    color: Colors.amber, size: 32),
              );
            }),
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
      fatigueLevel: _fatigue,
      fatigueAreas: _fatigueAreas.toList(),
      mentalState: _mental,
      selfRating: _rating,
      biggestFactor: _factor,
      postRecordedAt: DateTime.now(),
    );
    final ok = await ref.read(matchContextProvider(widget.matchId).notifier).savePost(ctx);
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
