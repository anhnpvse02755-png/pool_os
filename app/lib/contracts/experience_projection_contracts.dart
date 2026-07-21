import 'dart:convert';

import 'package:crypto/crypto.dart';

const experienceEventContractVersion = 1;
const experienceTimelineContractVersion = 1;
const sessionSummaryContractVersion = 1;
const experienceSnapshotContractVersion = 1;

enum ExperienceEventKind {
  techniqueProgress,
  mistakeState,
}

class ExperienceEventContract {
  ExperienceEventContract({
    required this.eventId,
    required this.playerId,
    required this.sessionId,
    required this.occurredAt,
    required this.kind,
    required this.knowledgeId,
    required this.state,
    required this.sourceDecisionReference,
  }) {
    _requireText(eventId, 'eventId');
    _requireText(playerId, 'playerId');
    _requireText(sessionId, 'sessionId');
    _requireText(knowledgeId, 'knowledgeId');
    _requireText(state, 'state');
    _requireText(sourceDecisionReference, 'sourceDecisionReference');
  }

  final String eventId;
  final String playerId;
  final String sessionId;
  final DateTime occurredAt;
  final ExperienceEventKind kind;
  final String knowledgeId;
  final String state;
  final String sourceDecisionReference;

  Map<String, dynamic> toJson() => {
        'schemaVersion': experienceEventContractVersion,
        'eventId': eventId,
        'playerId': playerId,
        'sessionId': sessionId,
        'occurredAt': occurredAt.toUtc().toIso8601String(),
        'kind': kind.name,
        'knowledgeId': knowledgeId,
        'state': state,
        'sourceDecisionReference': sourceDecisionReference,
      };
}

class ExperienceTimelineProjection {
  ExperienceTimelineProjection._({
    required this.events,
    required this.digest,
  });

  factory ExperienceTimelineProjection.create(
    List<ExperienceEventContract> source,
  ) {
    if (source.isEmpty) {
      throw ArgumentError('Experience timeline requires at least one event.');
    }
    final ids = <String>{};
    for (final event in source) {
      if (!ids.add(event.eventId)) {
        throw ArgumentError('Duplicate Experience event ${event.eventId}.');
      }
    }
    final events = [...source]..sort(_compareEvents);
    final payload = {
      'schemaVersion': experienceTimelineContractVersion,
      'events': events.map((event) => event.toJson()).toList(),
    };
    return ExperienceTimelineProjection._(
      events: List.unmodifiable(events),
      digest: _digest(payload),
    );
  }

  final List<ExperienceEventContract> events;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': experienceTimelineContractVersion,
        'events': events.map((event) => event.toJson()).toList(),
        'digest': digest,
      };
}

class SessionSummaryProjection {
  const SessionSummaryProjection._({
    required this.sessionId,
    required this.startedAt,
    required this.endedAt,
    required this.eventCount,
    required this.techniqueEventCount,
    required this.mistakeEventCount,
    required this.knowledgeIds,
    required this.sourceDecisionReferences,
    required this.digest,
  });

  factory SessionSummaryProjection.create({
    required String sessionId,
    required List<ExperienceEventContract> events,
  }) {
    _requireText(sessionId, 'sessionId');
    if (events.isEmpty || events.any((event) => event.sessionId != sessionId)) {
      throw ArgumentError('Session summary events must belong to $sessionId.');
    }
    final ordered = [...events]..sort(_compareEvents);
    final knowledgeIds =
        ordered.map((event) => event.knowledgeId).toSet().toList()..sort();
    final references = ordered
        .map((event) => event.sourceDecisionReference)
        .toSet()
        .toList()
      ..sort();
    final payload = {
      'schemaVersion': sessionSummaryContractVersion,
      'sessionId': sessionId,
      'startedAt': ordered.first.occurredAt.toUtc().toIso8601String(),
      'endedAt': ordered.last.occurredAt.toUtc().toIso8601String(),
      'eventCount': ordered.length,
      'techniqueEventCount': ordered
          .where((event) => event.kind == ExperienceEventKind.techniqueProgress)
          .length,
      'mistakeEventCount': ordered
          .where((event) => event.kind == ExperienceEventKind.mistakeState)
          .length,
      'knowledgeIds': knowledgeIds,
      'sourceDecisionReferences': references,
    };
    return SessionSummaryProjection._(
      sessionId: sessionId,
      startedAt: ordered.first.occurredAt.toUtc(),
      endedAt: ordered.last.occurredAt.toUtc(),
      eventCount: ordered.length,
      techniqueEventCount: payload['techniqueEventCount']! as int,
      mistakeEventCount: payload['mistakeEventCount']! as int,
      knowledgeIds: List.unmodifiable(knowledgeIds),
      sourceDecisionReferences: List.unmodifiable(references),
      digest: _digest(payload),
    );
  }

  final String sessionId;
  final DateTime startedAt;
  final DateTime endedAt;
  final int eventCount;
  final int techniqueEventCount;
  final int mistakeEventCount;
  final List<String> knowledgeIds;
  final List<String> sourceDecisionReferences;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': sessionSummaryContractVersion,
        'sessionId': sessionId,
        'startedAt': startedAt.toIso8601String(),
        'endedAt': endedAt.toIso8601String(),
        'eventCount': eventCount,
        'techniqueEventCount': techniqueEventCount,
        'mistakeEventCount': mistakeEventCount,
        'knowledgeIds': knowledgeIds,
        'sourceDecisionReferences': sourceDecisionReferences,
        'digest': digest,
      };
}

class ExperienceSnapshot {
  const ExperienceSnapshot._({
    required this.playerId,
    required this.playerProgressDigest,
    required this.knowledgeVersion,
    required this.knowledgeDigest,
    required this.timeline,
    required this.sessions,
    required this.digest,
  });

  factory ExperienceSnapshot.create({
    required String playerId,
    required String playerProgressDigest,
    required String knowledgeVersion,
    required String knowledgeDigest,
    required ExperienceTimelineProjection timeline,
    required List<SessionSummaryProjection> sessions,
  }) {
    _requireText(playerId, 'playerId');
    _requireText(playerProgressDigest, 'playerProgressDigest');
    _requireText(knowledgeVersion, 'knowledgeVersion');
    _requireText(knowledgeDigest, 'knowledgeDigest');
    if (timeline.events.any((event) => event.playerId != playerId)) {
      throw ArgumentError('Experience events belong to another player.');
    }
    final orderedSessions = [...sessions]
      ..sort((a, b) => a.sessionId.compareTo(b.sessionId));
    final timelineSessionIds =
        timeline.events.map((event) => event.sessionId).toSet();
    if (orderedSessions.map((session) => session.sessionId).toSet().length !=
            orderedSessions.length ||
        !timelineSessionIds.containsAll(
          orderedSessions.map((session) => session.sessionId),
        ) ||
        orderedSessions.length != timelineSessionIds.length) {
      throw ArgumentError('Session summaries must cover the timeline exactly.');
    }
    for (final summary in orderedSessions) {
      final expected = SessionSummaryProjection.create(
        sessionId: summary.sessionId,
        events: timeline.events
            .where((event) => event.sessionId == summary.sessionId)
            .toList(growable: false),
      );
      if (summary.digest != expected.digest) {
        throw ArgumentError(
          'Session summary ${summary.sessionId} does not match the timeline.',
        );
      }
    }
    final payload = {
      'schemaVersion': experienceSnapshotContractVersion,
      'playerId': playerId,
      'playerProgressDigest': playerProgressDigest,
      'knowledgeVersion': knowledgeVersion,
      'knowledgeDigest': knowledgeDigest,
      'timeline': timeline.toJson(),
      'sessions': orderedSessions.map((session) => session.toJson()).toList(),
    };
    return ExperienceSnapshot._(
      playerId: playerId,
      playerProgressDigest: playerProgressDigest,
      knowledgeVersion: knowledgeVersion,
      knowledgeDigest: knowledgeDigest,
      timeline: timeline,
      sessions: List.unmodifiable(orderedSessions),
      digest: _digest(payload),
    );
  }

  final String playerId;
  final String playerProgressDigest;
  final String knowledgeVersion;
  final String knowledgeDigest;
  final ExperienceTimelineProjection timeline;
  final List<SessionSummaryProjection> sessions;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': experienceSnapshotContractVersion,
        'playerId': playerId,
        'playerProgressDigest': playerProgressDigest,
        'knowledgeVersion': knowledgeVersion,
        'knowledgeDigest': knowledgeDigest,
        'timeline': timeline.toJson(),
        'sessions': sessions.map((session) => session.toJson()).toList(),
        'digest': digest,
      };
}

int _compareEvents(
  ExperienceEventContract a,
  ExperienceEventContract b,
) {
  final byTime = a.occurredAt.toUtc().compareTo(b.occurredAt.toUtc());
  return byTime != 0 ? byTime : a.eventId.compareTo(b.eventId);
}

void _requireText(String value, String field) {
  if (value.trim().isEmpty) throw ArgumentError('$field must not be empty.');
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
