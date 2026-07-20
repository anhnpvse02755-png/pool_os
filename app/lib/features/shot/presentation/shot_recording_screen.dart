import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/shot/domain/models/shot_record.dart';
import 'package:pool_os/features/shot/presentation/shot_provider.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

/// Task 02: Shot recording redesigned as a single-screen wizard so each shot is
/// a complete data unit — Intent -> Type -> Result -> (Reason if it failed) —
/// recorded through the RFC-301 pipeline (RecordingCoordinator). This replaces
/// the separate Event screen for shot causes: a miss reason lives on the Shot.
///
/// UX goals: fewest taps, competition-friendly. A made shot is 3 taps
/// (intent, type, "Made") and saves instantly; a miss adds one reason tap.
class ShotRecordingScreen extends ConsumerStatefulWidget {
  // RFC-301 Rule #3: a Shot can never exist without a Rack, so rackId is
  // required — there is no valid way to open this screen without one.
  final int rackId;
  final int? sessionId;
  final int? matchId;

  const ShotRecordingScreen({
    super.key,
    required this.rackId,
    this.sessionId,
    this.matchId,
  });

  @override
  ConsumerState<ShotRecordingScreen> createState() =>
      _ShotRecordingScreenState();
}

class _ShotRecordingScreenState extends ConsumerState<ShotRecordingScreen> {
  // Wizard selection state for the shot being built.
  ShotIntent _intent = ShotIntent.pot;
  ShotType _type = ShotType.straight;
  ShotDifficulty _difficulty = ShotDifficulty.medium;
  ShotResult? _result;
  MissReason? _missReason;
  // Guards against a double-tap persisting two shots (same class of bug fixed
  // in the drill flow).
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(shotRecorderProvider.notifier).startRecording(
            rackId: widget.rackId,
            sessionId: widget.sessionId,
            matchId: widget.matchId,
          );
    });
  }

  bool get _needsReason =>
      _result != null && _result != ShotResult.made;

  bool get _canSave {
    if (_result == null) return false;
    if (_needsReason) return _missReason != null;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(shotRecorderProvider);
    final locale = Localizations.localeOf(context).languageCode;
    final vi = locale == 'vi';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.get('add_shot')),
        actions: [
          if (state.shots.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.undo),
              tooltip: l10n.get('undo') == 'undo' ? 'Undo' : l10n.get('undo'),
              onPressed: () =>
                  ref.read(shotRecorderProvider.notifier).removeLastShot(),
            ),
        ],
      ),
      body: Column(
        children: [
          if (state.error != null) _buildError(state.error!),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step 1: Intent — what the player meant to do.
                  _stepLabel(context, 1, l10n.get('shot_intent')),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ShotIntent.values.map((i) {
                      return ChoiceChip(
                        label: Text(l10n.get(i.l10nKey)),
                        selected: _intent == i,
                        onSelected: (_) => setState(() => _intent = i),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Step 2: Type.
                  _stepLabel(context, 2, l10n.get('shot_type_label')),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ShotType.values.map((t) {
                      return ChoiceChip(
                        label: Text(vi ? t.getDisplayNameVi() : t.getDisplayName()),
                        selected: _type == t,
                        onSelected: (_) => setState(() => _type = t),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  // Difficulty is secondary; kept compact on the same step.
                  Text(l10n.get('difficulty'),
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: ShotDifficulty.values.map((d) {
                      return ChoiceChip(
                        label: Text(vi ? d.getDisplayNameVi() : d.getDisplayName()),
                        selected: _difficulty == d,
                        onSelected: (_) => setState(() => _difficulty = d),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Step 3: Result.
                  _stepLabel(context, 3, l10n.get('result')),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ShotResult.values.map((r) {
                      final color = _resultColor(r);
                      return ChoiceChip(
                        label: Text(vi ? r.getDisplayNameVi() : r.getDisplayName()),
                        selected: _result == r,
                        selectedColor: color.withAlpha(60),
                        onSelected: (_) => setState(() {
                          _result = r;
                          // Made needs no reason; clear any stale one.
                          if (r == ShotResult.made) _missReason = null;
                        }),
                      );
                    }).toList(),
                  ),

                  // Step 4: Reason — only when the shot did not go in.
                  if (_needsReason) ...[
                    const SizedBox(height: 20),
                    _stepLabel(context, 4, l10n.get('miss_reason_label')),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: MissReason.values.map((m) {
                        return ChoiceChip(
                          label: Text(l10n.get(m.l10nKey)),
                          selected: _missReason == m,
                          onSelected: (_) => setState(() => _missReason = m),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          _buildHistory(context, state, l10n),
          _buildSaveButton(context, l10n),
        ],
      ),
    );
  }

  Widget _stepLabel(BuildContext context, int step, String label) {
    return Row(
      children: [
        CircleAvatar(
          radius: 11,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text('$step',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              )),
        ),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.titleSmall),
      ],
    );
  }

  Widget _buildError(String message) {
    return Container(
      width: double.infinity,
      color: Colors.red.withAlpha(26),
      padding: const EdgeInsets.all(12),
      child: Text(message, style: const TextStyle(color: Colors.red)),
    );
  }

  Widget _buildHistory(
      BuildContext context, ShotRecorderState state, AppLocalizations l10n) {
    if (state.shots.isEmpty) return const SizedBox.shrink();
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${state.madeShots}/${state.totalShots} (${(state.accuracy * 100).toInt()}%)',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 6),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: state.shots.length,
              itemBuilder: (context, i) {
                final shot = state.shots[i];
                final color = _resultColor(shot.result);
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: 40,
                  decoration: BoxDecoration(
                    color: color.withAlpha(26),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: color.withAlpha(77)),
                  ),
                  child: Icon(
                    shot.isMade ? Icons.check : Icons.close,
                    size: 16,
                    color: color,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, AppLocalizations l10n) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _canSave && !_saving ? _save : null,
            icon: const Icon(Icons.check),
            label: Text(l10n.get('add_shot')),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_canSave || _saving) return;
    setState(() => _saving = true);

    final notifier = ref.read(shotRecorderProvider.notifier);
    final shots = ref.read(shotRecorderProvider).shots;

    notifier.setCurrentShot(
      ShotRecord(
        rackId: widget.rackId,
        sessionId: widget.sessionId,
        matchId: widget.matchId,
        shotNumber: shots.length + 1,
        shotType: _type,
        difficulty: _difficulty,
        result: _result!,
        intent: _intent.code,
        // Reason only when the shot failed; a made shot carries none.
        missReason: _needsReason ? _missReason?.code : null,
        isBreakShot: _intent == ShotIntent.breakShot,
        isSafety: _intent == ShotIntent.safety,
      ),
    );

    await notifier.recordShot();

    if (!mounted) return;
    final error = ref.read(shotRecorderProvider).error;
    if (error == null) {
      // Reset for the next shot, but keep the save control locked briefly so a
      // competition-speed double tap cannot create a duplicate record.
      setState(() {
        _result = null;
        _missReason = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).get('shot_saved')),
          duration: const Duration(milliseconds: 900),
        ),
      );
      await Future<void>.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => _saving = false);
    } else {
      setState(() => _saving = false);
    }
  }

  Color _resultColor(ShotResult result) {
    return switch (result) {
      ShotResult.made => Colors.green,
      ShotResult.missed => Colors.red,
      ShotResult.foul => Colors.orange,
      ShotResult.scratch => Colors.purple,
    };
  }
}
