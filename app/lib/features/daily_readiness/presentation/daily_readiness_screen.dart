import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pool_os/features/daily_readiness/presentation/daily_readiness_provider.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

class DailyReadinessScreen extends ConsumerStatefulWidget {
  const DailyReadinessScreen({super.key});

  @override
  ConsumerState<DailyReadinessScreen> createState() =>
      _DailyReadinessScreenState();
}

class _DailyReadinessScreenState extends ConsumerState<DailyReadinessScreen> {
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dailyReadinessProvider.notifier).loadToday();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(dailyReadinessProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _saveAndClose(l10n);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.get('daily_readiness')),
          centerTitle: true,
          leading: IconButton(
            onPressed: _saving ? null : () => _saveAndClose(l10n),
            icon: const Icon(Icons.close),
            tooltip: l10n.get('close'),
          ),
          actions: [
            IconButton(
              onPressed: _saving ? null : () => _save(l10n),
              icon: _saving
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              tooltip: l10n.get('save'),
            ),
          ],
        ),
        body: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(context, state, l10n),
      ),
    );
  }

  Future<void> _save(AppLocalizations l10n) async {
    setState(() => _saving = true);
    final saved = await ref.read(dailyReadinessProvider.notifier).saveNow();
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.get(
              saved ? 'daily_readiness_saved' : 'daily_readiness_save_failed'),
        ),
      ),
    );
  }

  Future<void> _saveAndClose(AppLocalizations l10n) async {
    if (_saving) return;
    setState(() => _saving = true);
    final saved = await ref.read(dailyReadinessProvider.notifier).saveNow();
    if (!mounted) return;
    setState(() => _saving = false);
    if (!saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.get('daily_readiness_save_failed'))),
      );
      return;
    }
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.go('/dashboard');
    }
  }

  Widget _buildContent(
      BuildContext context, DailyReadinessState state, AppLocalizations l10n) {
    final readiness = state.today;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReadinessScore(context, readiness, l10n),
          const SizedBox(height: 24),
          _buildSectionTitle(
              context, l10n.get('physical_condition'), Icons.fitness_center),
          const SizedBox(height: 12),
          _buildSliderField(
            context,
            label: l10n.get('sleep_hours'),
            value: readiness?.sleepHours ?? 7.0,
            min: 0,
            max: 12,
            divisions: 24,
            icon: Icons.bedtime,
            onChanged: (v) => _updateField('sleepHours', v),
          ),
          const SizedBox(height: 16),
          _buildRatingField(
            context,
            label: l10n.get('energy_level'),
            value: readiness?.energyLevel ?? 5,
            icon: Icons.bolt,
            color: Colors.amber,
            onChanged: (v) => _updateField('energyLevel', v),
          ),
          const SizedBox(height: 16),
          _buildRatingField(
            context,
            label: l10n.get('focus_level'),
            value: readiness?.focusLevel ?? 5,
            icon: Icons.center_focus_strong,
            color: Colors.blue,
            onChanged: (v) => _updateField('focusLevel', v),
          ),
          const SizedBox(height: 16),
          _buildRatingField(
            context,
            label: l10n.get('confidence_level'),
            value: readiness?.confidenceLevel ?? 5,
            icon: Icons.star,
            color: Colors.purple,
            onChanged: (v) => _updateField('confidenceLevel', v),
          ),
          const SizedBox(height: 16),
          _buildRatingField(
            context,
            label: l10n.get('stress_level'),
            value: readiness?.stressLevel ?? 5,
            icon: Icons.sentiment_neutral,
            color: Colors.red,
            inverted: true,
            onChanged: (v) => _updateField('stressLevel', v),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(context, l10n.get('mood'), Icons.mood),
          const SizedBox(height: 12),
          _buildMoodSelector(context, readiness?.mood, l10n),
          const SizedBox(height: 24),
          _buildSectionTitle(
              context, l10n.get('physical_check'), Icons.health_and_safety),
          const SizedBox(height: 12),
          _buildPhysicalConditionField(
            context,
            label: l10n.get('shoulder_condition'),
            value: readiness?.shoulderCondition ?? 5,
            icon: Icons.accessibility,
            color: Colors.blue,
            onChanged: (v) => _updateField('shoulderCondition', v),
          ),
          const SizedBox(height: 12),
          _buildPhysicalConditionField(
            context,
            label: l10n.get('wrist_condition'),
            value: readiness?.wristCondition ?? 5,
            icon: Icons.front_hand,
            color: Colors.green,
            onChanged: (v) => _updateField('wristCondition', v),
          ),
          const SizedBox(height: 12),
          _buildPhysicalConditionField(
            context,
            label: l10n.get('back_condition'),
            value: readiness?.backCondition ?? 5,
            icon: Icons.airline_seat_recline_normal,
            color: Colors.orange,
            onChanged: (v) => _updateField('backCondition', v),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(
              context, l10n.get('session_prep'), Icons.sports_bar),
          const SizedBox(height: 12),
          _buildLocationSelector(context, l10n),
          const SizedBox(height: 12),
          _buildTableSpeedSelector(context, l10n),
          const SizedBox(height: 24),
          _buildSectionTitle(context, l10n.get('today_goal'), Icons.flag),
          const SizedBox(height: 12),
          _buildGoalField(context, readiness?.todayGoal ?? '', l10n),
          const SizedBox(height: 24),
          _buildSectionTitle(context, l10n.get('notes'), Icons.notes),
          const SizedBox(height: 12),
          _buildNotesField(context, readiness?.notes ?? '', l10n),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildReadinessScore(
      BuildContext context, dynamic readiness, AppLocalizations l10n) {
    final score = readiness?.overallScore ?? 0;
    final readyScore = readiness?.readyScore ?? 0;
    final recoveryScore = readiness?.recoveryScore ?? 0;
    final color = _getScoreColor(score);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              l10n.get('today_readiness'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withAlpha(51),
                border: Border.all(color: color, width: 4),
              ),
              child: Center(
                child: Text(
                  '$score',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _getScoreLabel(score, l10n),
              style:
                  Theme.of(context).textTheme.bodyLarge?.copyWith(color: color),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMiniScore(
                  context,
                  l10n.get('ready_score'),
                  readyScore,
                  Icons.flash_on,
                  Colors.amber,
                ),
                _buildMiniScore(
                  context,
                  l10n.get('recovery_score'),
                  recoveryScore,
                  Icons.favorite,
                  Colors.red,
                ),
              ],
            ),
            if (readiness?.coachNote != null &&
                readiness!.coachNote.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withAlpha(13),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        readiness.coachNote,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.blue.shade800,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMiniScore(BuildContext context, String label, int score,
      IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          '$score',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: _getScoreColor(score),
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildPhysicalConditionField(
    BuildContext context, {
    required String label,
    required int value,
    required IconData icon,
    required Color color,
    required Function(int) onChanged,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 8),
                Text(label),
                const Spacer(),
                Text('$value/10',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getScoreColor(value))),
              ],
            ),
            const SizedBox(height: 8),
            Slider(
              value: value.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              activeColor: _getScoreColor(value),
              onChanged: (v) => onChanged(v.round()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderField(
    BuildContext context, {
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required IconData icon,
    required Function(double) onChanged,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Text(label),
                const Spacer(),
                Text('${value.toStringAsFixed(1)}h',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingField(
    BuildContext context, {
    required String label,
    required int value,
    required IconData icon,
    required Color color,
    required Function(int) onChanged,
    bool inverted = false,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 8),
                Text(label),
                const Spacer(),
                Text('$value/10',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, color: color)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(10, (i) {
                final score = i + 1;
                final isSelected = score == value;
                final displayColor = inverted
                    ? _getInvertedColor(score)
                    : _getRatingColor(score);
                return GestureDetector(
                  onTap: () => onChanged(score),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? displayColor : Colors.transparent,
                      border: Border.all(color: displayColor, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        '$score',
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white : displayColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodSelector(
      BuildContext context, String? currentMood, AppLocalizations l10n) {
    final moods = [
      ('great', Icons.sentiment_very_satisfied, Colors.green),
      ('good', Icons.sentiment_satisfied, Colors.lightGreen),
      ('okay', Icons.sentiment_neutral, Colors.amber),
      ('tired', Icons.sentiment_dissatisfied, Colors.orange),
      ('bad', Icons.sentiment_very_dissatisfied, Colors.red),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.get('how_feeling')),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: moods.map((mood) {
                final isSelected = currentMood == mood.$1;
                return GestureDetector(
                  onTap: () => _updateField('mood', mood.$1),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? mood.$3.withAlpha(51)
                              : Colors.transparent,
                          border: Border.all(
                              color: mood.$3, width: isSelected ? 2 : 1),
                        ),
                        child: Icon(mood.$2, color: mood.$3, size: 32),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.get('mood_${mood.$1}'),
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected ? mood.$3 : null,
                          fontWeight: isSelected ? FontWeight.bold : null,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSelector(BuildContext context, AppLocalizations l10n) {
    final locations = [
      ('club', Icons.location_city, l10n.get('location_club')),
      ('home', Icons.home, l10n.get('location_home')),
      ('academy', Icons.school, l10n.get('location_academy')),
      ('tournament', Icons.emoji_events, l10n.get('location_tournament')),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.get('playing_location')),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: locations.map((loc) {
                final isSelected =
                    ref.watch(dailyReadinessProvider).today?.playingLocation ==
                        loc.$1;
                return FilterChip(
                  avatar: Icon(loc.$2, size: 18),
                  label: Text(loc.$3),
                  selected: isSelected,
                  onSelected: (_) =>
                      _updateField('playingLocation', isSelected ? '' : loc.$1),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableSpeedSelector(BuildContext context, AppLocalizations l10n) {
    final speeds = [
      ('slow', Colors.brown, l10n.get('table_slow')),
      ('medium', Colors.blueGrey, l10n.get('table_medium')),
      ('fast', Colors.indigo, l10n.get('table_fast')),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.get('table_speed')),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: speeds.map((speed) {
                final isSelected =
                    ref.watch(dailyReadinessProvider).today?.tableSpeed ==
                        speed.$1;
                return FilterChip(
                  label: Text(speed.$3),
                  selected: isSelected,
                  selectedColor: speed.$2.withAlpha(51),
                  onSelected: (_) =>
                      _updateField('tableSpeed', isSelected ? '' : speed.$1),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalField(
      BuildContext context, String value, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: TextEditingController(text: value),
          decoration: InputDecoration(
            hintText: l10n.get('goal_hint'),
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.flag),
          ),
          maxLines: 2,
          onChanged: (v) => _updateField('todayGoal', v),
        ),
      ),
    );
  }

  Widget _buildNotesField(
      BuildContext context, String value, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: TextEditingController(text: value),
          decoration: InputDecoration(
            hintText: l10n.get('notes_hint'),
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.notes),
          ),
          maxLines: 3,
          onChanged: (v) => _updateField('notes', v),
        ),
      ),
    );
  }

  void _updateField(String field, dynamic value) {
    ref
        .read(dailyReadinessProvider.notifier)
        .updateFieldImmediate(field, value);
  }

  Color _getScoreColor(int score) {
    if (score >= 8) return Colors.green;
    if (score >= 6) return Colors.lightGreen;
    if (score >= 4) return Colors.amber;
    if (score >= 2) return Colors.orange;
    return Colors.red;
  }

  String _getScoreLabel(int score, AppLocalizations l10n) {
    if (score >= 8) return l10n.get('readiness_excellent');
    if (score >= 6) return l10n.get('readiness_good');
    if (score >= 4) return l10n.get('readiness_moderate');
    if (score >= 2) return l10n.get('readiness_low');
    return l10n.get('readiness_poor');
  }

  Color _getRatingColor(int score) {
    if (score >= 8) return Colors.green;
    if (score >= 6) return Colors.lightGreen;
    if (score >= 4) return Colors.amber;
    return Colors.red;
  }

  Color _getInvertedColor(int score) {
    if (score <= 3) return Colors.green;
    if (score <= 5) return Colors.lightGreen;
    if (score <= 7) return Colors.amber;
    return Colors.red;
  }
}
