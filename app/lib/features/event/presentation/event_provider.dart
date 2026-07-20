import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/event_record.dart';
import '../domain/models/event.dart' as domain;
import 'package:pool_os/features/session/data/recording_coordinator.dart';
import 'package:pool_os/features/session/domain/recording_errors.dart';
import 'dart:convert';

final eventRecorderProvider =
    StateNotifierProvider<EventRecorderNotifier, EventRecorderState>((ref) {
  return EventRecorderNotifier(ref.watch(recordingCoordinatorProvider));
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
      currentEvent:
          clearCurrentEvent ? null : (currentEvent ?? this.currentEvent),
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
  List<EventRecord> getGreatShots() =>
      getEventsByCategory(EventCategory.greatShot);
  List<EventRecord> getMistakes() => getEventsByCategory(EventCategory.mistake);
  List<EventRecord> getMentalEvents() =>
      getEventsByCategory(EventCategory.mental);

  int get foulCount => getFouls().length;
  int get greatShotCount => getGreatShots().length;
  int get mistakeCount => getMistakes().length;
}

class EventRecorderNotifier extends StateNotifier<EventRecorderState> {
  final RecordingCoordinator _coordinator;

  EventRecorderNotifier(this._coordinator) : super(const EventRecorderState());

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

  Future<void> createEvent({
    required EventCategory category,
    required EventType type,
    required EventSeverity severity,
    String? confidence,
    String? notes,
    Map<String, dynamic>? metadata,
  }) async {
    final eventRecord = EventRecord(
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

    // RFC-301 Rule #2/#5: an Event MUST reference a real, persisted Shot and is
    // persisted FIRST. If there is no shotId we reject with a clear error rather
    // than silently keeping a memory-only Event that never reaches the DB.
    final shotId = eventRecord.shotId;
    if (shotId == null || shotId <= 0) {
      state = state.copyWith(
        error: 'Cannot record event: no Shot selected. Record a shot first.',
      );
      return;
    }

    final event = domain.Event(
      shotId: shotId,
      category: eventRecord.category.name,
      type: eventRecord.type.name,
      severity: eventRecord.severity.name,
      confidence: eventRecord.confidence,
      metadataJson: eventRecord.metadata != null
          ? jsonEncode(eventRecord.metadata)
          : null,
      notes: eventRecord.notes,
      createdAt: eventRecord.createdAt,
    );

    try {
      await _coordinator.recordEvent(shotId: shotId, event: event);
      state = state.copyWith(
        events: [...state.events, eventRecord],
        clearCurrentEvent: true,
        error: null,
      );
    } on RecordingIntegrityException catch (e) {
      state = state.copyWith(error: e.message);
    }
  }

  Future<void> quickAddFoul(EventType type) async {
    await createEvent(
      category: EventCategory.foul,
      type: type,
      severity: EventSeverity.moderate,
    );
  }

  Future<void> quickAddGreatShot(EventType type) async {
    await createEvent(
      category: EventCategory.greatShot,
      type: type,
      severity: EventSeverity.significant,
    );
  }

  Future<void> quickAddMistake(EventType type) async {
    await createEvent(
      category: EventCategory.mistake,
      type: type,
      severity: EventSeverity.moderate,
    );
  }

  Future<void> quickAddMentalEvent(EventType type) async {
    await createEvent(
      category: EventCategory.mental,
      type: type,
      severity: EventSeverity.moderate,
    );
  }

  Future<void> quickAddSafetyEvent({required bool won}) async {
    await createEvent(
      category: EventCategory.safety,
      type: won ? EventType.safetyWin : EventType.safetyLost,
      severity: EventSeverity.significant,
    );
  }

  Future<void> quickAddBreakEvent({required bool dry}) async {
    await createEvent(
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
