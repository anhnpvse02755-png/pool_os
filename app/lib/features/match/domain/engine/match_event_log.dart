// EPIC 01 — Match Engine — Phase 5: persistence boundary.
//
// Defines the persistence boundary as a pure-Dart abstract interface.
// The concrete Drift-backed implementation lives in
// `app/lib/features/match/data/persistence/match_event_log_drift.dart`.
// This split keeps the domain engine free of Drift imports so that
// unit tests can construct in-memory implementations cheaply.

import 'event.dart';
import 'value_objects.dart';

/// Snapshot entry persisted alongside the event log. Persistence may
/// store this for fast cold-start; on recovery the engine may choose
/// to discard the snapshot and replay the event log instead.
class MatchSnapshot {
  const MatchSnapshot({
    required this.matchId,
    required this.payload,
    required this.writtenAt,
  });

  final MatchId matchId;

  /// Serialized form of the Match aggregate. The persistence layer
  /// encodes this as JSON; the engine treats it as opaque.
  final String payload;

  final DateTime writtenAt;
}

/// Abstract event log. Implementations are responsible for atomic
/// appends and ordered reads.
abstract class MatchEventLog {
  Future<void> append({
    required MatchId matchId,
    required List<MatchEvent> events,
  });

  Future<List<MatchEvent>> read({required MatchId matchId});

  Future<void> saveSnapshot(MatchSnapshot snapshot);

  Future<MatchSnapshot?> loadSnapshot({required MatchId matchId});
}

/// In-memory implementation used by tests and engine construction.
class InMemoryMatchEventLog implements MatchEventLog {
  final Map<MatchId, List<MatchEvent>> _events = {};
  final Map<MatchId, MatchSnapshot> _snapshots = {};

  @override
  Future<List<MatchEvent>> read({required MatchId matchId}) async {
    return List.unmodifiable(_events[matchId] ?? const <MatchEvent>[]);
  }

  @override
  Future<void> append({
    required MatchId matchId,
    required List<MatchEvent> events,
  }) async {
    _events.putIfAbsent(matchId, () => <MatchEvent>[]);
    _events[matchId]!.addAll(events);
  }

  @override
  Future<void> saveSnapshot(MatchSnapshot snapshot) async {
    _snapshots[snapshot.matchId] = snapshot;
  }

  @override
  Future<MatchSnapshot?> loadSnapshot({required MatchId matchId}) async {
    return _snapshots[matchId];
  }
}
