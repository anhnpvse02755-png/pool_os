import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/event_record.dart';

final eventRecorderProvider = StateNotifierProvider<EventRecorderNotifier, EventRecorderState>((ref) {
  return EventRecorderNotifier();
});

class EventRecorderState {
  final List<EventRecord> events;
  final EventRecord? currentEvent;
  final int? rackId;
  final int? sessionId;
  final int? matchId;
  final int? shotId;
  final bool isRecording;
  final String? error;

  const EventRecorderState({
    this.events = const [],
    this.currentEvent,
    this.rackId,
    this.sessionId,
    this.matchId,
    this.shotId,
    this.isRecording = false,
    this.error,
  });

  EventRecorderState copyWith({
    List<EventRecord>? events,
    EventRecord? currentEvent,
    int? rackId,
    int? sessionId,
    int? matchId,
    int? shotId,
    bool? isRecording,
    String? error,
    bool clearCurrentEvent = false,
  }) {
    return EventRecorderState(
      events: events ?? this.events,
      currentEvent: clearCurrentEvent ? null : (currentEvent ?? this.currentEvent),
      rackId: rackId ?? this.rackId,
      sessionId: sessionId ?? this.sessionId,
      matchId: matchId ?? this.matchId,
      shotId: shotId ?? this.shotId,
      isRecording: isRecording ?? this.isRecording,
      error: error,
    );
  }

  int get totalEvents => events.length;

  List<EventRecord> getEventsByCategory(EventCategory category) {
    return events.where((e) => e.category == category).toList();
  }

  Map<EventCategory, int> get categoryBreakdown {
    final breakdown = <EventCategory, int>{};
    for (final event in events) {
      breakdown[event.category] = (breakdown[event.category] ?? 0) + 1;
    }
    return breakdown;
  }

  List<EventRecord> getFouls() => getEventsByCategory(EventCategory.foul);
  List<EventRecord> getGreatShots() => getEventsByCategory(EventCategory.greatShot);
  List<EventRecord> getMistakes() => getEventsByCategory(EventCategory.mistake);
  List<EventRecord> getMentalEvents() => getEventsByCategory(EventCategory.mental);

  int get foulCount => getFouls().length;
  int get greatShotCount => getGreatShots().length;
  int get mistakeCount => getMistakes().length;
}

class EventRecorderNotifier extends StateNotifier<EventRecorderState> {
  EventRecorderNotifier() : super(const EventRecorderState());

  void startRecording({
    int? rackId,
    int? sessionId,
    int? matchId,
    int? shotId,
  }) {
    state = EventRecorderState(
      rackId: rackId,
      sessionId: sessionId,
      matchId: matchId,
      shotId: shotId,
      isRecording: true,
    );
  }

  void createEvent({
    required EventCategory category,
    required EventType type,
    required EventSeverity severity,
    String? confidence,
    String? notes,
    Map<String, dynamic>? metadata,
  }) {
    final event = EventRecord(
      rackId: state.rackId,
      sessionId: state.sessionId,
      matchId: state.matchId,
      shotId: state.shotId,
      category: category,
      type: type,
      severity: severity,
      confidence: confidence,
      notes: notes,
      metadata: metadata,
    );

    state = state.copyWith(
      events: [...state.events, event],
      clearCurrentEvent: true,
    );
  }

  void quickAddFoul(EventType type) {
    createEvent(
      category: EventCategory.foul,
      type: type,
      severity: EventSeverity.moderate,
    );
  }

  void quickAddGreatShot(EventType type) {
    createEvent(
      category: EventCategory.greatShot,
      type: type,
      severity: EventSeverity.significant,
    );
  }

  void quickAddMistake(EventType type) {
    createEvent(
      category: EventCategory.mistake,
      type: type,
      severity: EventSeverity.moderate,
    );
  }

  void quickAddMentalEvent(EventType type) {
    createEvent(
      category: EventCategory.mental,
      type: type,
      severity: EventSeverity.moderate,
    );
  }

  void quickAddSafetyEvent({required bool won}) {
    createEvent(
      category: EventCategory.safety,
      type: won ? EventType.safetyWin : EventType.safetyLost,
      severity: EventSeverity.significant,
    );
  }

  void quickAddBreakEvent({required bool dry}) {
    createEvent(
      category: EventCategory.breakEvent,
      type: dry ? EventType.dryBreak : EventType.poorScatter,
      severity: EventSeverity.moderate,
    );
  }

  void updateNotes(int index, String notes) {
    if (index < 0 || index >= state.events.length) return;
    final updatedEvents = [...state.events];
    updatedEvents[index] = updatedEvents[index].copyWith(notes: notes);
    state = state.copyWith(events: updatedEvents);
  }

  void removeEvent(int index) {
    if (index < 0 || index >= state.events.length) return;
    final updatedEvents = [...state.events];
    updatedEvents.removeAt(index);
    state = state.copyWith(events: updatedEvents);
  }

  void removeLastEvent() {
    if (state.events.isEmpty) return;
    state = state.copyWith(
      events: state.events.sublist(0, state.events.length - 1),
    );
  }

  void clearEvents() {
    state = state.copyWith(events: [], clearCurrentEvent: true);
  }

  void stopRecording() {
    state = state.copyWith(isRecording: false);
  }

  List<EventRecord> getEventsForRack(int rackId) {
    return state.events.where((e) => e.rackId == rackId).toList();
  }

  List<EventRecord> getEventsForSession(int sessionId) {
    return state.events.where((e) => e.sessionId == sessionId).toList();
  }
}
