import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/shot/domain/models/shot_record.dart';
import 'package:pool_os/features/shot/presentation/shot_provider.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

class ShotRecordingScreen extends ConsumerStatefulWidget {
  final int? rackId;
  final int? sessionId;
  final int? matchId;

  const ShotRecordingScreen({
    super.key,
    this.rackId,
    this.sessionId,
    this.matchId,
  });

  @override
  ConsumerState<ShotRecordingScreen> createState() => _ShotRecordingScreenState();
}

class _ShotRecordingScreenState extends ConsumerState<ShotRecordingScreen> {
  ShotType _selectedType = ShotType.straight;
  ShotDifficulty _selectedDifficulty = ShotDifficulty.medium;
  ShotResult? _selectedResult;
  PositionQuality? _selectedPosition;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(shotRecorderProvider.notifier).startRecording(
            rackId: widget.rackId ?? 0,
            sessionId: widget.sessionId,
            matchId: widget.matchId,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(shotRecorderProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.get('add_shot')),
        actions: [
          if (state.shots.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.undo),
              onPressed: () => ref.read(shotRecorderProvider.notifier).removeLastShot(),
              tooltip: 'Undo Last Shot',
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmClear(context, l10n),
            tooltip: 'Clear All',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildQuickActions(context, l10n),
          const Divider(),
          Expanded(child: _buildShotDetails(context, l10n)),
          _buildShotHistory(context, state, l10n),
          _buildRecordButton(context, state, l10n),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickButton(
                  context,
                  Icons.check_circle,
                  'Made',
                  Colors.green,
                  () => ref.read(shotRecorderProvider.notifier).quickAddMadeShot(
                        type: _selectedType,
                        difficulty: _selectedDifficulty,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQuickButton(
                  context,
                  Icons.cancel,
                  'Missed',
                  Colors.red,
                  () => ref.read(shotRecorderProvider.notifier).quickAddMissedShot(
                        type: _selectedType,
                        difficulty: _selectedDifficulty,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQuickButton(
                  context,
                  Icons.warning,
                  'Foul',
                  Colors.orange,
                  () => ref.read(shotRecorderProvider.notifier).quickAddFoul(
                        difficulty: _selectedDifficulty,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQuickButton(
                  context,
                  Icons.flash_on,
                  'Break',
                  Colors.blue,
                  () => ref.read(shotRecorderProvider.notifier).quickAddMadeShot(
                        type: ShotType.straight,
                        difficulty: _selectedDifficulty,
                        isBreak: true,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(77)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShotDetails(BuildContext context, AppLocalizations l10n) {
    final locale = Localizations.localeOf(context);
    final isVietnamese = locale.languageCode == 'vi';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shot Type',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ShotType.values.map((type) {
              final isSelected = _selectedType == type;
              return ChoiceChip(
                label: Text(isVietnamese ? type.getDisplayNameVi() : type.getDisplayName()),
                selected: isSelected,
                onSelected: (_) => setState(() => _selectedType = type),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text(
            'Difficulty',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ShotDifficulty.values.map((diff) {
              final isSelected = _selectedDifficulty == diff;
              final color = _getDifficultyColor(diff);
              return ChoiceChip(
                label: Text(isVietnamese ? diff.getDisplayNameVi() : diff.getDisplayName()),
                selected: isSelected,
                selectedColor: color.withAlpha(77),
                onSelected: (_) => setState(() => _selectedDifficulty = diff),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text(
            'Result',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ShotResult.values.map((result) {
              final isSelected = _selectedResult == result;
              final color = _getResultColor(result);
              return ChoiceChip(
                label: Text(isVietnamese ? result.getDisplayNameVi() : result.getDisplayName()),
                selected: isSelected,
                selectedColor: color.withAlpha(77),
                onSelected: (_) => setState(() => _selectedResult = result),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text(
            'Position Quality',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: PositionQuality.values.map((quality) {
              final isSelected = _selectedPosition == quality;
              final color = _getPositionColor(quality);
              return ChoiceChip(
                label: Text(isVietnamese ? quality.getDisplayNameVi() : quality.getDisplayName()),
                selected: isSelected,
                selectedColor: color.withAlpha(77),
                onSelected: (_) => setState(() => _selectedPosition = quality),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildShotHistory(
    BuildContext context,
    ShotRecorderState state,
    AppLocalizations l10n,
  ) {
    if (state.shots.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shot History',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                '${state.madeShots}/${state.totalShots} (${(state.accuracy * 100).toInt()}%)',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: state.shots.length,
              itemBuilder: (context, index) {
                final shot = state.shots[index];
                return _buildShotChip(context, shot, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShotChip(BuildContext context, ShotRecord shot, int index) {
    final color = _getResultColor(shot.result);
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            shot.isMade ? Icons.check : Icons.close,
            size: 16,
            color: color,
          ),
          const SizedBox(height: 4),
          Text(
            '#$index',
            style: TextStyle(fontSize: 10, color: color),
          ),
          if (shot.isBreakShot)
            const Icon(Icons.flash_on, size: 10, color: Colors.blue),
        ],
      ),
    );
  }

  Widget _buildRecordButton(
    BuildContext context,
    ShotRecorderState state,
    AppLocalizations l10n,
  ) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _selectedResult != null ? _recordShot : null,
            icon: const Icon(Icons.add),
            label: Text(l10n.get('add_shot')),
          ),
        ),
      ),
    );
  }

  void _recordShot() {
    if (_selectedResult == null) return;

    ref.read(shotRecorderProvider.notifier).setCurrentShot(
          ShotRecord(
            rackId: widget.rackId,
            sessionId: widget.sessionId,
            matchId: widget.matchId,
            shotNumber: ref.read(shotRecorderProvider).shots.length + 1,
            shotType: _selectedType,
            difficulty: _selectedDifficulty,
            result: _selectedResult!,
            positionQuality: _selectedPosition,
          ),
        );

    ref.read(shotRecorderProvider.notifier).recordShot();

    setState(() {
      _selectedResult = null;
      _selectedPosition = null;
    });
  }

  void _confirmClear(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.get('are_you_sure')),
        content: const Text('Clear all recorded shots?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.get('cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(shotRecorderProvider.notifier).clearShots();
              Navigator.pop(ctx);
            },
            child: Text(l10n.get('confirm')),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(ShotDifficulty difficulty) {
    return switch (difficulty) {
      ShotDifficulty.easy => Colors.green,
      ShotDifficulty.medium => Colors.blue,
      ShotDifficulty.hard => Colors.orange,
      ShotDifficulty.expert => Colors.red,
    };
  }

  Color _getResultColor(ShotResult result) {
    return switch (result) {
      ShotResult.made => Colors.green,
      ShotResult.missed => Colors.red,
      ShotResult.foul => Colors.orange,
      ShotResult.scratch => Colors.purple,
    };
  }

  Color _getPositionColor(PositionQuality quality) {
    return switch (quality) {
      PositionQuality.perfect => Colors.green,
      PositionQuality.good => Colors.lightGreen,
      PositionQuality.playable => Colors.blue,
      PositionQuality.recovery => Colors.orange,
      PositionQuality.bad => Colors.red,
    };
  }
}
