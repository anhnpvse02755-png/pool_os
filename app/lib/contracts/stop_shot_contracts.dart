import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/evidence_upcaster.dart';

const evidenceBatchSchemaVersion = 1;
const drillAttemptCompletedSchemaVersion = 1;
const outcomeMeasuredSchemaVersion = 1;
const observationRecordedSchemaVersion = 1;

final _learningEvidenceUpcasters = EvidenceUpcasterChain(
  currentVersion: evidenceBatchSchemaVersion,
  steps: [
    const EvidenceUpcasterStep(
      fromVersion: 0,
      toVersion: 1,
      transform: _upcastLegacyEvidenceJson,
    ),
  ],
);

class EvidenceContractException implements Exception {
  const EvidenceContractException(this.message);

  final String message;

  @override
  String toString() => 'EvidenceContractException: $message';
}

class DrillAttemptCompleted {
  const DrillAttemptCompleted({
    required this.eventId,
    required this.commandId,
    required this.occurredAt,
    required this.knowledgeId,
    required this.drillId,
    required this.attempts,
    required this.successes,
    required this.knowledgeVersion,
  });

  static const eventType = 'DrillAttemptCompleted';

  final String eventId;
  final String commandId;
  final DateTime occurredAt;
  final String knowledgeId;
  final String drillId;
  final int attempts;
  final int successes;
  final String knowledgeVersion;

  Map<String, dynamic> toEnvelope() => {
        'type': eventType,
        'schemaVersion': drillAttemptCompletedSchemaVersion,
        'payload': _payload,
      };

  Map<String, dynamic> get _payload => {
        'eventId': eventId,
        'commandId': commandId,
        'occurredAt': occurredAt.toUtc().toIso8601String(),
        'knowledgeId': knowledgeId,
        'drillId': drillId,
        'attempts': attempts,
        'successes': successes,
        'knowledgeVersion': knowledgeVersion,
      };

  factory DrillAttemptCompleted.fromEnvelope(Map<String, dynamic> json) {
    _validateEventHeader(
      json,
      expectedType: eventType,
      expectedVersion: drillAttemptCompletedSchemaVersion,
    );
    return DrillAttemptCompleted._fromPayload(_requiredObject(json, 'payload'));
  }

  factory DrillAttemptCompleted.fromLegacy(Map<String, dynamic> json) =>
      DrillAttemptCompleted._fromPayload(json);

  factory DrillAttemptCompleted._fromPayload(Map<String, dynamic> json) =>
      DrillAttemptCompleted(
        eventId: json['eventId'] as String,
        commandId: json['commandId'] as String,
        occurredAt: DateTime.parse(json['occurredAt'] as String),
        knowledgeId: json['knowledgeId'] as String,
        drillId: json['drillId'] as String,
        attempts: json['attempts'] as int,
        successes: json['successes'] as int,
        knowledgeVersion: json['knowledgeVersion'] as String,
      );
}

class OutcomeMeasured {
  const OutcomeMeasured({
    required this.eventId,
    required this.commandId,
    required this.occurredAt,
    required this.outcomeId,
    required this.successes,
    required this.attempts,
    required this.achieved,
    required this.knowledgeVersion,
  });

  static const eventType = 'OutcomeMeasured';

  final String eventId;
  final String commandId;
  final DateTime occurredAt;
  final String outcomeId;
  final int successes;
  final int attempts;
  final bool achieved;
  final String knowledgeVersion;

  Map<String, dynamic> toEnvelope() => {
        'type': eventType,
        'schemaVersion': outcomeMeasuredSchemaVersion,
        'payload': _payload,
      };

  Map<String, dynamic> get _payload => {
        'eventId': eventId,
        'commandId': commandId,
        'occurredAt': occurredAt.toUtc().toIso8601String(),
        'outcomeId': outcomeId,
        'successes': successes,
        'attempts': attempts,
        'achieved': achieved,
        'knowledgeVersion': knowledgeVersion,
      };

  factory OutcomeMeasured.fromEnvelope(Map<String, dynamic> json) {
    _validateEventHeader(
      json,
      expectedType: eventType,
      expectedVersion: outcomeMeasuredSchemaVersion,
    );
    return OutcomeMeasured._fromPayload(_requiredObject(json, 'payload'));
  }

  factory OutcomeMeasured.fromLegacy(Map<String, dynamic> json) =>
      OutcomeMeasured._fromPayload(json);

  factory OutcomeMeasured._fromPayload(Map<String, dynamic> json) =>
      OutcomeMeasured(
        eventId: json['eventId'] as String,
        commandId: json['commandId'] as String,
        occurredAt: DateTime.parse(json['occurredAt'] as String),
        outcomeId: json['outcomeId'] as String,
        successes: json['successes'] as int,
        attempts: json['attempts'] as int,
        achieved: json['achieved'] as bool,
        knowledgeVersion: json['knowledgeVersion'] as String,
      );
}

class ObservationRecorded {
  const ObservationRecorded({
    required this.observationId,
    required this.commandId,
    required this.observationType,
    required this.source,
    required this.confidence,
    required this.capturedAt,
    required this.subjectId,
    required this.payload,
    required this.knowledgeVersion,
  });

  static const eventType = 'ObservationRecorded';

  final String observationId;
  final String commandId;
  final String observationType;
  final String source;
  final double confidence;
  final DateTime capturedAt;
  final String subjectId;
  final Map<String, Object?> payload;
  final String knowledgeVersion;

  Map<String, dynamic> toEnvelope() => {
        'type': eventType,
        'schemaVersion': observationRecordedSchemaVersion,
        'payload': {
          'observationId': observationId,
          'commandId': commandId,
          'observationType': observationType,
          'source': source,
          'confidence': confidence,
          'capturedAt': capturedAt.toUtc().toIso8601String(),
          'subjectId': subjectId,
          'payload': payload,
          'knowledgeVersion': knowledgeVersion,
        },
      };

  factory ObservationRecorded.fromEnvelope(Map<String, dynamic> json) {
    _validateEventHeader(
      json,
      expectedType: eventType,
      expectedVersion: observationRecordedSchemaVersion,
    );
    final payload = _requiredObject(json, 'payload');
    final confidence = payload['confidence'];
    if (confidence is! num || confidence < 0 || confidence > 1) {
      throw const EvidenceContractException(
        'Observation confidence must be between 0 and 1.',
      );
    }
    return ObservationRecorded(
      observationId: payload['observationId'] as String,
      commandId: payload['commandId'] as String,
      observationType: payload['observationType'] as String,
      source: payload['source'] as String,
      confidence: confidence.toDouble(),
      capturedAt: DateTime.parse(payload['capturedAt'] as String),
      subjectId: payload['subjectId'] as String,
      payload: Map<String, Object?>.from(payload['payload'] as Map),
      knowledgeVersion: payload['knowledgeVersion'] as String,
    );
  }
}

class LearningEvidenceBatch {
  LearningEvidenceBatch._({
    required this.batchSchemaVersion,
    required this.batchId,
    required this.commandId,
    required this.attempt,
    required this.measurement,
    required this.observation,
    required this.digest,
    required this.sourceSchemaVersion,
  });

  final int batchSchemaVersion;
  final String batchId;
  final String commandId;
  final DrillAttemptCompleted? attempt;
  final OutcomeMeasured? measurement;
  final ObservationRecorded? observation;
  final String digest;
  final int sourceSchemaVersion;
  bool get upcastFromLegacy => sourceSchemaVersion == 0;

  factory LearningEvidenceBatch.createTechnique({
    required String batchId,
    required String commandId,
    required DrillAttemptCompleted attempt,
    required OutcomeMeasured measurement,
    required ObservationRecorded observation,
  }) {
    final payload = _batchPayload(
      batchId: batchId,
      commandId: commandId,
      attempt: attempt,
      measurement: measurement,
      observation: observation,
    );
    return LearningEvidenceBatch._(
      batchSchemaVersion: evidenceBatchSchemaVersion,
      batchId: batchId,
      commandId: commandId,
      attempt: attempt,
      measurement: measurement,
      observation: observation,
      digest: _digest(payload),
      sourceSchemaVersion: evidenceBatchSchemaVersion,
    );
  }

  factory LearningEvidenceBatch.createObservation({
    required String batchId,
    required String commandId,
    required ObservationRecorded observation,
  }) {
    final payload = _batchPayload(
      batchId: batchId,
      commandId: commandId,
      observation: observation,
    );
    return LearningEvidenceBatch._(
      batchSchemaVersion: evidenceBatchSchemaVersion,
      batchId: batchId,
      commandId: commandId,
      attempt: null,
      measurement: null,
      observation: observation,
      digest: _digest(payload),
      sourceSchemaVersion: evidenceBatchSchemaVersion,
    );
  }

  Map<String, dynamic> toJson() => {
        ..._batchPayload(
          batchId: batchId,
          commandId: commandId,
          attempt: attempt,
          measurement: measurement,
          observation: observation,
        ),
        'digest': digest,
      };

  factory LearningEvidenceBatch.fromJson(Map<String, dynamic> json) {
    final rawVersion = json['batchSchemaVersion'];
    if (rawVersion != null && rawVersion is! int) {
      throw EvidenceContractException(
        'Unsupported evidence batch schema version: $rawVersion.',
      );
    }
    final sourceVersion = rawVersion as int? ?? 0;
    late final Map<String, dynamic> current;
    try {
      current = _learningEvidenceUpcasters.upcast(
        json,
        sourceVersion: sourceVersion,
      );
    } on EvidenceUpcastException catch (error) {
      throw EvidenceContractException(error.message);
    }
    return LearningEvidenceBatch._fromCurrentJson(
      current,
      sourceSchemaVersion: sourceVersion,
    );
  }

  factory LearningEvidenceBatch.fromSnapshotJson(
    Map<String, dynamic> json, {
    required int sourceSchemaVersion,
  }) {
    if (sourceSchemaVersion < 0 ||
        sourceSchemaVersion > evidenceBatchSchemaVersion) {
      throw EvidenceContractException(
        'Unsupported evidence source version: $sourceSchemaVersion.',
      );
    }
    return LearningEvidenceBatch._fromCurrentJson(
      json,
      sourceSchemaVersion: sourceSchemaVersion,
    );
  }

  factory LearningEvidenceBatch._fromCurrentJson(
    Map<String, dynamic> json, {
    required int sourceSchemaVersion,
  }) {
    final version = json['batchSchemaVersion'];
    if (version != evidenceBatchSchemaVersion) {
      throw EvidenceContractException(
        'Unsupported evidence batch schema version: $version.',
      );
    }
    final expectedDigest = json['digest'];
    final payload = Map<String, dynamic>.from(json)..remove('digest');
    if (expectedDigest is! String || _digest(payload) != expectedDigest) {
      throw const EvidenceContractException('Evidence batch digest mismatch.');
    }
    final events = _requiredEvents(json);
    _validateKnownEvents(events);
    final attempt = _optionalEventByType(
      events,
      DrillAttemptCompleted.eventType,
    );
    final measurement = _optionalEventByType(events, OutcomeMeasured.eventType);
    final observation = _optionalEventByType(
      events,
      ObservationRecorded.eventType,
    );
    if (events.isEmpty || (attempt == null) != (measurement == null)) {
      throw const EvidenceContractException(
        'Attempt and measurement must occur together.',
      );
    }
    return LearningEvidenceBatch._(
      batchSchemaVersion: version as int,
      batchId: json['batchId'] as String,
      commandId: json['commandId'] as String,
      attempt:
          attempt == null ? null : DrillAttemptCompleted.fromEnvelope(attempt),
      measurement: measurement == null
          ? null
          : OutcomeMeasured.fromEnvelope(measurement),
      observation: observation == null
          ? null
          : ObservationRecorded.fromEnvelope(observation),
      digest: expectedDigest,
      sourceSchemaVersion: sourceSchemaVersion,
    );
  }
}

Map<String, dynamic> _upcastLegacyEvidenceJson(Map<String, dynamic> json) {
  final events = _requiredEvents(json);
  if (events.length != 2) {
    throw const EvidenceContractException(
      'Legacy evidence batch must contain exactly two events.',
    );
  }
  final commandId = json['commandId'] as String;
  final attemptEvent = _optionalEventByType(
    events,
    DrillAttemptCompleted.eventType,
  );
  final measurementEvent = _optionalEventByType(
    events,
    OutcomeMeasured.eventType,
  );
  if (attemptEvent == null || measurementEvent == null) {
    throw const EvidenceContractException('Legacy evidence event missing.');
  }
  final attempt = DrillAttemptCompleted.fromLegacy(attemptEvent);
  final measurement = OutcomeMeasured.fromLegacy(measurementEvent);
  final payload = _batchPayload(
    batchId: 'legacy.$commandId',
    commandId: commandId,
    attempt: attempt,
    measurement: measurement,
  );
  return {...payload, 'digest': _digest(payload)};
}

typedef StopShotEvidenceBatch = LearningEvidenceBatch;

Map<String, dynamic> _batchPayload({
  required String batchId,
  required String commandId,
  DrillAttemptCompleted? attempt,
  OutcomeMeasured? measurement,
  ObservationRecorded? observation,
}) =>
    {
      'batchSchemaVersion': evidenceBatchSchemaVersion,
      'batchId': batchId,
      'commandId': commandId,
      'events': [
        if (observation != null) observation.toEnvelope(),
        if (attempt != null) attempt.toEnvelope(),
        if (measurement != null) measurement.toEnvelope(),
      ],
    };

List<Map<String, dynamic>> _requiredEvents(Map<String, dynamic> json) {
  final raw = json['events'];
  if (raw is! List) {
    throw const EvidenceContractException('Evidence events must be an array.');
  }
  return raw
      .map((event) => Map<String, dynamic>.from(event as Map))
      .toList(growable: false);
}

Map<String, dynamic>? _optionalEventByType(
  List<Map<String, dynamic>> events,
  String type,
) {
  final matches = events.where((event) => event['type'] == type).toList();
  if (matches.length > 1) {
    throw EvidenceContractException(
      'Evidence batch contains duplicate $type events.',
    );
  }
  return matches.isEmpty ? null : matches.single;
}

void _validateKnownEvents(List<Map<String, dynamic>> events) {
  const known = {
    DrillAttemptCompleted.eventType,
    OutcomeMeasured.eventType,
    ObservationRecorded.eventType,
  };
  final unknown = events.where((event) => !known.contains(event['type']));
  if (unknown.isNotEmpty) {
    throw EvidenceContractException(
      'Unknown evidence event type: ${unknown.first['type']}.',
    );
  }
}

void _validateEventHeader(
  Map<String, dynamic> json, {
  required String expectedType,
  required int expectedVersion,
}) {
  if (json['type'] != expectedType ||
      json['schemaVersion'] != expectedVersion) {
    throw EvidenceContractException(
      'Unsupported ${json['type']} event schema version: '
      '${json['schemaVersion']}.',
    );
  }
}

Map<String, dynamic> _requiredObject(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value is! Map<String, dynamic>) {
    throw EvidenceContractException('$field must be an object.');
  }
  return value;
}

String _digest(Map<String, dynamic> payload) =>
    sha256.convert(utf8.encode(jsonEncode(payload))).toString();

class MasteryAssessment {
  const MasteryAssessment({
    required this.knowledgeId,
    required this.successes,
    required this.attempts,
    required this.score,
    required this.mastered,
    required this.evidenceCount,
  });

  final String knowledgeId;
  final int successes;
  final int attempts;
  final double score;
  final bool mastered;
  final int evidenceCount;
}

class RecommendationCandidate {
  const RecommendationCandidate({
    required this.id,
    required this.title,
    required this.score,
    required this.available,
  });

  final String id;
  final String title;
  final int score;
  final bool available;
}

class RecommendationSet {
  const RecommendationSet({
    required this.selected,
    required this.alternatives,
  });

  final RecommendationCandidate selected;
  final List<RecommendationCandidate> alternatives;
}

class DecisionReason {
  const DecisionReason({
    required this.code,
    required this.parameters,
    required this.policyVersion,
  });

  final String code;
  final Map<String, Object?> parameters;
  final String policyVersion;
}

abstract final class DecisionReasonCodes {
  static const outcomeMeasured = 'OUTCOME_MEASURED';
  static const belowMasteryThreshold = 'BELOW_MASTERY_THRESHOLD';
  static const outcomeAchieved = 'OUTCOME_ACHIEVED';
  static const correctionCandidate = 'CORRECTION_CANDIDATE';
  static const recommendationSelected = 'RECOMMENDATION_SELECTED';
  static const mistakeObserved = 'MISTAKE_OBSERVED';
  static const mistakePersistent = 'MISTAKE_PERSISTENT';
  static const mistakeResolved = 'MISTAKE_RESOLVED';
  static const activeCorrectionBlocksUnlock = 'ACTIVE_CORRECTION_BLOCKS_UNLOCK';
  static const prerequisiteUnsatisfied = 'PREREQUISITE_UNSATISFIED';
  static const prerequisiteSatisfied = 'PREREQUISITE_SATISFIED';
}

class DecisionRecord {
  const DecisionRecord({
    required this.id,
    required this.createdAt,
    required this.recommendations,
    required this.trace,
    required this.knowledgeVersion,
    required this.knowledgeDigest,
    required this.policyVersion,
  });

  final String id;
  final DateTime createdAt;
  final RecommendationSet recommendations;
  final List<DecisionReason> trace;
  final String knowledgeVersion;
  final String knowledgeDigest;
  final String policyVersion;
}
