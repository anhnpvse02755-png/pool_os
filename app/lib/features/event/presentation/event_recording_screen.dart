import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/event/domain/models/event_record.dart';
import 'package:pool_os/features/event/presentation/event_provider.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

class EventRecordingScreen extends ConsumerStatefulWidget {
  // RFC-301 Rule #3: an Event MUST reference a real, persisted Shot, so shotId
  // is required — this screen cannot be opened without a shot to attach to.
  final int shotId;
  final int? rackId;
  final int? sessionId;
  final int? matchId;

  const EventRecordingScreen({
    super.key,
    required this.shotId,
    this.rackId,
    this.sessionId,
    this.matchId,
  });

  @override
  ConsumerState<EventRecordingScreen> createState() =>
      _EventRecordingScreenState();
}

class _EventRecordingScreenState extends ConsumerState<EventRecordingScreen> {
  EventCategory? _selectedCategory;
  EventType? _selectedType;
  EventSeverity _selectedSeverity = EventSeverity.moderate;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(eventRecorderProvider.notifier).startRecording(
            rackId: widget.rackId,
            sessionId: widget.sessionId,
            matchId: widget.matchId,
            shotId: widget.shotId,
          );
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(eventRecorderProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.get('add_event')),
        actions: [
          if (state.events.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.undo),
              onPressed: () =>
                  ref.read(eventRecorderProvider.notifier).removeLastEvent(),
              tooltip: 'Undo',
            ),
        ],
      ),
      body: Column(
        children: [
          _buildQuickActions(context, l10n),
          const Divider(),
          Expanded(child: _buildEventForm(context, l10n)),
          _buildEventHistory(context, state, l10n),
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
            'Quick Add',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildQuickChip(
                  context,
                  'Foul',
                  Icons.warning,
                  Colors.orange,
                  () => ref
                      .read(eventRecorderProvider.notifier)
                      .quickAddFoul(EventType.scratch),
                ),
                const SizedBox(width: 8),
                _buildQuickChip(
                  context,
                  'Great Shot',
                  Icons.star,
                  Colors.green,
                  () => ref
                      .read(eventRecorderProvider.notifier)
                      .quickAddGreatShot(EventType.difficultShotMade),
                ),
                const SizedBox(width: 8),
                _buildQuickChip(
                  context,
                  'Mistake',
                  Icons.error,
                  Colors.red,
                  () => ref
                      .read(eventRecorderProvider.notifier)
                      .quickAddMistake(EventType.easyShotMissed),
                ),
                const SizedBox(width: 8),
                _buildQuickChip(
                  context,
                  'Safety Won',
                  Icons.shield,
                  Colors.blue,
                  () => ref
                      .read(eventRecorderProvider.notifier)
                      .quickAddSafetyEvent(won: true),
                ),
                const SizedBox(width: 8),
                _buildQuickChip(
                  context,
                  'Safety Lost',
                  Icons.shield_outlined,
                  Colors.grey,
                  () => ref
                      .read(eventRecorderProvider.notifier)
                      .quickAddSafetyEvent(won: false),
                ),
                const SizedBox(width: 8),
                _buildQuickChip(
                  context,
                  'Dry Break',
                  Icons.flash_off,
                  Colors.purple,
                  () => ref
                      .read(eventRecorderProvider.notifier)
                      .quickAddBreakEvent(dry: true),
                ),
                const SizedBox(width: 8),
                _buildQuickChip(
                  context,
                  'Mental',
                  Icons.psychology,
                  Colors.teal,
                  () => ref
                      .read(eventRecorderProvider.notifier)
                      .quickAddMentalEvent(EventType.nerves),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChip(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withAlpha(77)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildEventForm(BuildContext context, AppLocalizations l10n) {
    final locale = Localizations.localeOf(context);
    final isVietnamese = locale.languageCode == 'vi';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: EventCategory.values.map((category) {
              final isSelected = _selectedCategory == category;
              return ChoiceChip(
                label: Text(isVietnamese
                    ? category.getDisplayNameVi()
                    : category.getDisplayName()),
                selected: isSelected,
                onSelected: (_) => setState(() {
                  _selectedCategory = category;
                  _selectedType = null;
                }),
              );
            }).toList(),
          ),
          if (_selectedCategory != null) ...[
            const SizedBox(height: 16),
            Text(
              'Type',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _getEventTypesForCategory(_selectedCategory!).map((type) {
                final isSelected = _selectedType == type;
                return ChoiceChip(
                  label: Text(isVietnamese
                      ? type.getDisplayNameVi()
                      : type.getDisplayName()),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedType = type),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            'Severity',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: EventSeverity.values.map((severity) {
              final isSelected = _selectedSeverity == severity;
              return ChoiceChip(
                label: Text(isVietnamese
                    ? severity.getDisplayNameVi()
                    : severity.getDisplayName()),
                selected: isSelected,
                selectedColor: severity.getColor().withAlpha(77),
                onSelected: (_) => setState(() => _selectedSeverity = severity),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.get('notes'),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: l10n.get('notes_placeholder'),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _selectedCategory != null && _selectedType != null
                  ? _recordEvent
                  : null,
              icon: const Icon(Icons.add),
              label: Text(l10n.get('add_event')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventHistory(
    BuildContext context,
    EventRecorderState state,
    AppLocalizations l10n,
  ) {
    if (state.events.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Event History',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                '${state.totalEvents} events',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: state.events.length,
              itemBuilder: (context, index) {
                final event = state.events[index];
                return _buildEventChip(context, event, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventChip(BuildContext context, EventRecord event, int index) {
    final color = _getCategoryColor(event.category);
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
          Icon(_getCategoryIcon(event.category), size: 16, color: color),
          const SizedBox(height: 4),
          Text(
            event.type.name.substring(0, event.type.name.length.clamp(0, 6)),
            style: TextStyle(fontSize: 10, color: color),
          ),
        ],
      ),
    );
  }

  List<EventType> _getEventTypesForCategory(EventCategory category) {
    return EventType.values.where((t) => t.getCategory() == category).toList();
  }

  void _recordEvent() {
    if (_selectedCategory == null || _selectedType == null) return;

    ref.read(eventRecorderProvider.notifier).createEvent(
          category: _selectedCategory!,
          type: _selectedType!,
          severity: _selectedSeverity,
          notes:
              _notesController.text.isNotEmpty ? _notesController.text : null,
        );

    setState(() {
      _selectedCategory = null;
      _selectedType = null;
      _selectedSeverity = EventSeverity.moderate;
    });
    _notesController.clear();
  }

  Color _getCategoryColor(EventCategory category) {
    return switch (category) {
      EventCategory.foul => Colors.orange,
      EventCategory.breakEvent => Colors.purple,
      EventCategory.safety => Colors.blue,
      EventCategory.greatShot => Colors.green,
      EventCategory.mistake => Colors.red,
      EventCategory.mental => Colors.teal,
      EventCategory.equipment => Colors.brown,
      EventCategory.other => Colors.grey,
    };
  }

  IconData _getCategoryIcon(EventCategory category) {
    return switch (category) {
      EventCategory.foul => Icons.warning,
      EventCategory.breakEvent => Icons.flash_on,
      EventCategory.safety => Icons.shield,
      EventCategory.greatShot => Icons.star,
      EventCategory.mistake => Icons.error,
      EventCategory.mental => Icons.psychology,
      EventCategory.equipment => Icons.build,
      EventCategory.other => Icons.more_horiz,
    };
  }
}
