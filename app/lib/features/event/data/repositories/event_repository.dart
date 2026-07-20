import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/player/data/database/app_database.dart' as db;
import 'package:pool_os/features/event/domain/models/event.dart';
import 'package:pool_os/features/player/data/providers/database_providers.dart';
import 'package:pool_os/features/session/domain/recording_errors.dart';

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository(ref.watch(databaseProvider));
});

class EventRepository {
  final db.AppDatabase _db;

  EventRepository(this._db);

  Future<List<Event>> getEventsByShotId(int shotId) async {
    final results = await (_db.select(_db.events)
          ..where((e) => e.shotId.equals(shotId))
          ..orderBy([(e) => OrderingTerm.asc(e.createdAt)]))
        .get();
    return results.map(_mapToEvent).toList();
  }

  Future<Event?> getEventById(int id) async {
    final result = await (_db.select(_db.events)..where((e) => e.id.equals(id)))
        .getSingleOrNull();
    if (result == null) return null;
    return _mapToEvent(result);
  }

  Future<int> createEvent(Event event) async {
    // RFC-301 Rule #2/#4: Event MUST belong to a real, persisted Shot. No
    // fallback fake IDs — reject rather than orphan the row (rackId/shotId=0).
    final shotId = event.shotId;
    if (shotId == null || shotId <= 0) {
      throw RecordingIntegrityException(
        'Event requires a valid shotId (got: $shotId). '
        'An Event cannot be created without a persisted Shot.',
      );
    }
    return _db.into(_db.events).insert(
          db.EventsCompanion.insert(
            shotId: shotId,
            category: event.category,
            type: event.type,
            severity: Value(event.severity),
            confidence: Value(event.confidence),
            metadataJson: Value(event.metadataJson),
            notes: Value(event.notes),
            createdAt: Value(event.createdAt),
          ),
        );
  }

  Future<bool> updateEvent(Event event) async {
    if (event.id == null || event.shotId == null) return false;
    final shotId = event.shotId!;
    return _db.update(_db.events).replace(
          db.EventsCompanion(
            id: Value(event.id!),
            shotId: Value(shotId),
            category: Value(event.category),
            type: Value(event.type),
            severity: Value(event.severity),
            confidence: Value(event.confidence),
            metadataJson: Value(event.metadataJson),
            notes: Value(event.notes),
            createdAt: Value(event.createdAt),
          ),
        );
  }

  Future<int> deleteEvent(int id) async {
    return (_db.delete(_db.events)..where((e) => e.id.equals(id))).go();
  }

  Future<int> getEventCountByShotId(int shotId) async {
    final count = _db.events.id.count();
    final query = _db.selectOnly(_db.events)
      ..addColumns([count])
      ..where(_db.events.shotId.equals(shotId));
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  Future<List<Event>> getEventsByCategory(String category) async {
    final results = await (_db.select(_db.events)
          ..where((e) => e.category.equals(category))
          ..orderBy([(e) => OrderingTerm.desc(e.createdAt)]))
        .get();
    return results.map(_mapToEvent).toList();
  }

  Future<List<Event>> getEventsByType(String type) async {
    final results = await (_db.select(_db.events)
          ..where((e) => e.type.equals(type))
          ..orderBy([(e) => OrderingTerm.desc(e.createdAt)]))
        .get();
    return results.map(_mapToEvent).toList();
  }

  Future<Map<String, int>> getEventTypeStats() async {
    final results = await _db.select(_db.events).get();
    final stats = <String, int>{};
    for (final event in results) {
      stats[event.type] = (stats[event.type] ?? 0) + 1;
    }
    return stats;
  }

  Future<Map<String, int>> getEventCategoryStats() async {
    final results = await _db.select(_db.events).get();
    final stats = <String, int>{};
    for (final event in results) {
      stats[event.category] = (stats[event.category] ?? 0) + 1;
    }
    return stats;
  }

  Event _mapToEvent(db.Event data) {
    return Event(
      id: data.id,
      shotId: data.shotId,
      category: data.category,
      type: data.type,
      severity: data.severity,
      confidence: data.confidence,
      metadataJson: data.metadataJson,
      notes: data.notes,
      createdAt: data.createdAt,
    );
  }

  Future<List<Event>> getEventsByPlayerId(int playerId) async {
    final allShots = await _db.select(_db.shots).get();
    final shotIds = allShots.map((s) => s.id).toSet();
    final allEvents = await _db.select(_db.events).get();
    return allEvents
        .where((e) => shotIds.contains(e.shotId))
        .map(_mapToEvent)
        .toList();
  }
}
