import 'dart:convert';

import 'package:crypto/crypto.dart';

const int careerTimelineProjectionVersion = 1;

enum CareerTimelineEventType {
  playerCreated,
  completedMatch,
  completedTraining,
  playerModelSnapshot,
  masteryEvidenceUpdated,
}

enum CareerEquipmentRole { playing, breakCue, jump }

final class CareerEquipmentUsageRef {
  const CareerEquipmentUsageRef({
    required this.matchId,
    required this.matchNumber,
    required this.snapshotReference,
    required this.role,
    required this.cueId,
  });

  final int matchId;
  final int matchNumber;
  final String snapshotReference;
  final CareerEquipmentRole role;
  final int cueId;

  Map<String, Object> toJson() => {
        'matchId': matchId,
        'matchNumber': matchNumber,
        'snapshotReference': snapshotReference,
        'role': role == CareerEquipmentRole.breakCue ? 'break' : role.name,
        'cueId': cueId,
      };

  factory CareerEquipmentUsageRef.fromJson(Map<String, Object?> json) {
    final role = json['role']! as String;
    return CareerEquipmentUsageRef(
      matchId: json['matchId']! as int,
      matchNumber: json['matchNumber']! as int,
      snapshotReference: json['snapshotReference']! as String,
      role: role == 'break'
          ? CareerEquipmentRole.breakCue
          : CareerEquipmentRole.values.byName(role),
      cueId: json['cueId']! as int,
    );
  }
}

final class CareerTimelineEvent {
  CareerTimelineEvent._({
    required this.eventId,
    required this.type,
    required this.timestamp,
    required this.title,
    required this.summary,
    required this.sourceReference,
    required this.equipmentUsage,
  });

  factory CareerTimelineEvent.create({
    required CareerTimelineEventType type,
    required DateTime timestamp,
    required String title,
    required String summary,
    required String sourceReference,
    List<CareerEquipmentUsageRef> equipmentUsage = const [],
    String? expectedEventId,
  }) {
    final canonicalTimestamp = timestamp.toUtc();
    final canonicalTitle = title.trim();
    final canonicalSummary = summary.trim();
    final canonicalReference = sourceReference.trim();
    if (canonicalTitle.isEmpty ||
        canonicalSummary.isEmpty ||
        canonicalReference.isEmpty) {
      throw ArgumentError('Timeline event content is incomplete.');
    }
    final canonicalEquipmentUsage = [...equipmentUsage]
      ..sort(compareCareerEquipmentUsage);
    for (final usage in canonicalEquipmentUsage) {
      if (usage.matchId <= 0 ||
          usage.matchNumber <= 0 ||
          usage.cueId <= 0 ||
          usage.snapshotReference !=
              'equipment-snapshot:match:${usage.matchId}') {
        throw ArgumentError('Timeline equipment usage is invalid.');
      }
    }
    final usageKeys = canonicalEquipmentUsage
        .map((usage) => '${usage.matchId}:${usage.role.name}')
        .toSet();
    if (usageKeys.length != canonicalEquipmentUsage.length) {
      throw ArgumentError('Timeline equipment roles must be unique per match.');
    }
    if (canonicalEquipmentUsage.isNotEmpty &&
        type != CareerTimelineEventType.completedMatch &&
        type != CareerTimelineEventType.completedTraining) {
      throw ArgumentError(
        'Only completed activity events may contain equipment usage.',
      );
    }
    final eventId = careerTimelineDigest({
      'type': type.name,
      'timestamp': canonicalTimestamp.toIso8601String(),
      'sourceReference': canonicalReference,
      'equipmentUsage':
          canonicalEquipmentUsage.map((usage) => usage.toJson()).toList(),
    });
    if (expectedEventId != null && expectedEventId != eventId) {
      throw StateError('career-timeline-event-id-mismatch');
    }
    return CareerTimelineEvent._(
      eventId: eventId,
      type: type,
      timestamp: canonicalTimestamp,
      title: canonicalTitle,
      summary: canonicalSummary,
      sourceReference: canonicalReference,
      equipmentUsage: List.unmodifiable(canonicalEquipmentUsage),
    );
  }

  factory CareerTimelineEvent.fromJson(Map<String, Object?> json) {
    return CareerTimelineEvent.create(
      type: CareerTimelineEventType.values.byName(json['type']! as String),
      timestamp: DateTime.parse(json['timestamp']! as String),
      title: json['title']! as String,
      summary: json['summary']! as String,
      sourceReference: json['sourceReference']! as String,
      equipmentUsage: ((json['equipmentUsage'] as List<Object?>?) ?? const [])
          .map(
            (value) => CareerEquipmentUsageRef.fromJson(
              (value! as Map).cast<String, Object?>(),
            ),
          )
          .toList(),
      expectedEventId: json['eventId']! as String,
    );
  }

  final String eventId;
  final CareerTimelineEventType type;
  final DateTime timestamp;
  final String title;
  final String summary;
  final String sourceReference;
  final List<CareerEquipmentUsageRef> equipmentUsage;

  Map<String, Object> toJson() => {
        'eventId': eventId,
        'type': type.name,
        'timestamp': timestamp.toIso8601String(),
        'title': title,
        'summary': summary,
        'sourceReference': sourceReference,
        'equipmentUsage':
            equipmentUsage.map((usage) => usage.toJson()).toList(),
      };
}

int compareCareerEquipmentUsage(
  CareerEquipmentUsageRef left,
  CareerEquipmentUsageRef right,
) {
  final matchNumberOrder = left.matchNumber.compareTo(right.matchNumber);
  if (matchNumberOrder != 0) return matchNumberOrder;
  final matchIdOrder = left.matchId.compareTo(right.matchId);
  if (matchIdOrder != 0) return matchIdOrder;
  return left.role.index.compareTo(right.role.index);
}

final class CareerTimelineProjection {
  CareerTimelineProjection._({
    required this.playerId,
    required this.sourceDigest,
    required this.digest,
    required List<CareerTimelineEvent> events,
  }) : events = List.unmodifiable(events);

  factory CareerTimelineProjection.create({
    required int playerId,
    required String sourceDigest,
    required List<CareerTimelineEvent> events,
  }) {
    if (playerId <= 0 || sourceDigest.trim().isEmpty) {
      throw ArgumentError('Career timeline identity is invalid.');
    }
    final orderedEvents = List<CareerTimelineEvent>.from(events)
      ..sort(compareCareerTimelineEvents);
    if (orderedEvents.map((event) => event.eventId).toSet().length !=
        orderedEvents.length) {
      throw ArgumentError('Career timeline event IDs must be unique.');
    }
    final payload = <String, Object>{
      'projectionVersion': careerTimelineProjectionVersion,
      'playerId': playerId,
      'sourceDigest': sourceDigest,
      'events': orderedEvents.map((event) => event.toJson()).toList(),
    };
    return CareerTimelineProjection._(
      playerId: playerId,
      sourceDigest: sourceDigest,
      digest: careerTimelineDigest(payload),
      events: orderedEvents,
    );
  }

  final int playerId;
  final String sourceDigest;
  final String digest;
  final List<CareerTimelineEvent> events;

  Map<String, Object> toJson() => {
        'projectionVersion': careerTimelineProjectionVersion,
        'playerId': playerId,
        'sourceDigest': sourceDigest,
        'projectionDigest': digest,
        'events': events.map((event) => event.toJson()).toList(),
      };
}

int compareCareerTimelineEvents(
  CareerTimelineEvent left,
  CareerTimelineEvent right,
) {
  final timestampOrder = right.timestamp.compareTo(left.timestamp);
  if (timestampOrder != 0) return timestampOrder;
  final typeOrder = left.type.index.compareTo(right.type.index);
  if (typeOrder != 0) return typeOrder;
  return left.sourceReference.compareTo(right.sourceReference);
}

String careerTimelineDigest(Object? value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
