import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../../domain/aggregates/match_aggregate.dart';
import '../../../domain/entities/match_entity.dart';
import '../../../domain/shared/entity_ids.dart';
import '../../../domain/shared/scalar_values.dart';
import '../../../domain/shared/temporal_values.dart';

const matchIdentityCompatibilitySchemaVersion = 1;
const matchIdentityAdapterPolicyVersion = 1;
const matchIdentitySourceKind = 'legacy-match-row';
const matchIdentitySqliteMaximumInteger = 9223372036854775807;
const _maximumDateTimeStorageSeconds = 8640000000000;

enum MatchIdentityFailureCode {
  targetNotFound('match-identity-target-not-found'),
  databaseFailure('match-identity-database-failure'),
  sourceReadFailure('match-identity-source-read-failure'),
  snapshotJsonInvalid('match-identity-snapshot-json-invalid'),
  snapshotShapeInvalid('match-identity-snapshot-shape-invalid'),
  snapshotVersionUnsupported('match-identity-snapshot-version-unsupported'),
  snapshotIdentityInvalid('match-identity-snapshot-identity-invalid'),
  snapshotProvenanceMismatch('match-identity-snapshot-provenance-mismatch'),
  snapshotDigestMismatch('match-identity-snapshot-digest-mismatch');

  const MatchIdentityFailureCode(this.value);

  final String value;
}

final class MatchIdentityException implements Exception {
  const MatchIdentityException(this.code, {this.cause});

  final MatchIdentityFailureCode code;
  final Object? cause;

  @override
  String toString() => code.value;
}

enum MatchIdentitySourceFailureKind { database, sourceRead }

final class MatchIdentitySourceException implements Exception {
  const MatchIdentitySourceException(this.kind, {this.cause});

  final MatchIdentitySourceFailureKind kind;
  final Object? cause;
}

enum MatchIdentityDiagnosticCode {
  invalidMatchId('invalid-match-id'),
  invalidSessionId('invalid-session-id'),
  invalidMatchNumber('invalid-match-number'),
  requiredEmpty('required-empty'),
  nullByte('null-byte'),
  codeUnsupported('code-unsupported'),
  integerOutOfRange('integer-out-of-range'),
  timestampInvalid('timestamp-invalid'),
  timestampOrderInvalid('timestamp-order-invalid');

  const MatchIdentityDiagnosticCode(this.value);

  final String value;
}

final class MatchIdentityDiagnostic {
  const MatchIdentityDiagnostic({required this.field, required this.code});

  final String field;
  final MatchIdentityDiagnosticCode code;

  Map<String, Object?> toJson() => <String, Object?>{
        'field': field,
        'code': code.value,
      };
}

abstract interface class MatchIdentityRawSourceReader {
  Future<MatchIdentityRawSource?> readMatchIdentityRawSource(
    int legacyMatchId,
  );
}

abstract interface class MatchIdentityCompatibilityReadPort {
  Future<MatchIdentityCompatibilityResult> readByLegacyMatchId(
    int legacyMatchId,
  );

  CanonicalMatchIdentitySnapshot decodeSnapshot(String rawJson);

  MatchIdentityRepresentations adaptSnapshot(
    CanonicalMatchIdentitySnapshot snapshot,
  );
}

final class MatchIdentityRawSource {
  const MatchIdentityRawSource({
    required this.sourceSchemaVersion,
    required this.legacyMatchId,
    required this.legacySessionId,
    required this.matchNumber,
    required this.gameTypeRaw,
    required this.raceToRaw,
    required this.opponentRaw,
    required this.partnerRaw,
    required this.teamModeRaw,
    required this.winnerRaw,
    required this.resultRaw,
    required this.matchObjectiveRaw,
    required this.notesRaw,
    required this.startTimeStorageValue,
    required this.endTimeStorageValue,
    required this.createdAtStorageValue,
  });

  final int sourceSchemaVersion;
  final int legacyMatchId;
  final int? legacySessionId;
  final int matchNumber;
  final String gameTypeRaw;
  final int? raceToRaw;
  final String? opponentRaw;
  final String? partnerRaw;
  final String? teamModeRaw;
  final String? winnerRaw;
  final String? resultRaw;
  final String? matchObjectiveRaw;
  final String? notesRaw;
  final int? startTimeStorageValue;
  final int? endTimeStorageValue;
  final int createdAtStorageValue;

  String get sourceReference => 'match:$legacyMatchId';

  Map<String, Object?> toDigestPayload() => <String, Object?>{
        'schemaVersion': matchIdentityCompatibilitySchemaVersion,
        'sourceKind': matchIdentitySourceKind,
        'sourceSchemaVersion': sourceSchemaVersion,
        'legacyMatchId': legacyMatchId,
        'sourceReference': sourceReference,
        'legacySessionId': legacySessionId,
        'matchNumber': matchNumber,
        'gameTypeRaw': gameTypeRaw,
        'raceToRaw': raceToRaw,
        'opponentRaw': opponentRaw,
        'partnerRaw': partnerRaw,
        'teamModeRaw': teamModeRaw,
        'winnerRaw': winnerRaw,
        'resultRaw': resultRaw,
        'matchObjectiveRaw': matchObjectiveRaw,
        'notesRaw': notesRaw,
        'startTimeStorageValue': startTimeStorageValue,
        'endTimeStorageValue': endTimeStorageValue,
        'createdAtStorageValue': createdAtStorageValue,
      };
}

final class MatchIdentitySourceAssessment {
  MatchIdentitySourceAssessment._({
    required this.source,
    required List<MatchIdentityDiagnostic> diagnostics,
  })  : rawAssessmentDigest = _digest(source.toDigestPayload()),
        diagnostics = List.unmodifiable(diagnostics);

  final MatchIdentityRawSource source;
  final String rawAssessmentDigest;
  final List<MatchIdentityDiagnostic> diagnostics;

  bool get isCompatible => diagnostics.isEmpty;

  Map<String, Object?> toJson() => <String, Object?>{
        ...source.toDigestPayload(),
        'rawAssessmentDigest': rawAssessmentDigest,
        'diagnostics': diagnostics.map((item) => item.toJson()).toList(),
      };

  String toJsonString() => jsonEncode(toJson());
}

final class CanonicalMatchIdentitySnapshot {
  CanonicalMatchIdentitySnapshot._({
    required this.canonicalMatchId,
    required this.legacyMatchId,
    required this.canonicalSessionId,
    required this.legacySessionId,
    required this.matchNumber,
    required this.gameType,
    required this.raceTo,
    required this.opponent,
    required this.partner,
    required this.teamMode,
    required this.winner,
    required this.result,
    required this.matchObjective,
    required this.notes,
    required this.startTime,
    required this.endTime,
    required this.createdAt,
    required this.lifecycleLabel,
    required this.sourceReference,
    required this.sourceSchemaVersion,
    String? expectedSourceDigest,
    String? expectedDigest,
  }) {
    sourceDigest = _digest(_sourcePayload());
    if (expectedSourceDigest != null && sourceDigest != expectedSourceDigest) {
      throw const MatchIdentityException(
        MatchIdentityFailureCode.snapshotProvenanceMismatch,
      );
    }
    digest = _digest(_snapshotPayload());
    if (expectedDigest != null && digest != expectedDigest) {
      throw const MatchIdentityException(
        MatchIdentityFailureCode.snapshotDigestMismatch,
      );
    }
  }

  final String canonicalMatchId;
  final int legacyMatchId;
  final String canonicalSessionId;
  final int legacySessionId;
  final int matchNumber;
  final String gameType;
  final int? raceTo;
  final String? opponent;
  final String? partner;
  final String? teamMode;
  final String? winner;
  final String? result;
  final String? matchObjective;
  final String? notes;
  final String? startTime;
  final String? endTime;
  final String createdAt;
  final String lifecycleLabel;
  final String sourceReference;
  final int sourceSchemaVersion;
  late final String sourceDigest;
  late final String digest;

  Map<String, Object?> _sourcePayload() => <String, Object?>{
        'adapterPolicyVersion': matchIdentityAdapterPolicyVersion,
        'canonicalMatchId': canonicalMatchId,
        'legacyMatchId': legacyMatchId,
        'canonicalSessionId': canonicalSessionId,
        'legacySessionId': legacySessionId,
        'matchNumber': matchNumber,
        'gameType': gameType,
        'raceTo': raceTo,
        'opponent': opponent,
        'partner': partner,
        'teamMode': teamMode,
        'winner': winner,
        'result': result,
        'matchObjective': matchObjective,
        'notes': notes,
        'startTime': startTime,
        'endTime': endTime,
        'createdAt': createdAt,
        'lifecycleLabel': lifecycleLabel,
        'sourceKind': matchIdentitySourceKind,
        'sourceReference': sourceReference,
        'sourceSchemaVersion': sourceSchemaVersion,
      };

  Map<String, Object?> _snapshotPayload() => <String, Object?>{
        'schemaVersion': matchIdentityCompatibilitySchemaVersion,
        ..._sourcePayload(),
        'diagnostics': const <Object?>[],
        'sourceDigest': sourceDigest,
      };

  Map<String, Object?> toJson() => <String, Object?>{
        ..._snapshotPayload(),
        'digest': digest,
      };

  String toJsonString() => jsonEncode(toJson());
}

final class MatchIdentityCompatibilityResult {
  const MatchIdentityCompatibilityResult({
    required this.assessment,
    required this.snapshot,
    required this.foundationMatch,
    required this.aggregate,
  });

  final MatchIdentitySourceAssessment assessment;
  final CanonicalMatchIdentitySnapshot? snapshot;
  final ProductMatch? foundationMatch;
  final MatchAggregate? aggregate;

  bool get isCompatible => snapshot != null;
}

final class MatchIdentityRepresentations {
  const MatchIdentityRepresentations({
    required this.foundationMatch,
    required this.aggregate,
  });

  final ProductMatch foundationMatch;
  final MatchAggregate aggregate;
}

final class MatchIdentityCompatibilityAdapter {
  const MatchIdentityCompatibilityAdapter();

  MatchIdentityCompatibilityResult adapt(MatchIdentityRawSource source) {
    final diagnostics = <_SortableDiagnostic>[];

    if (!_isPositiveSqliteInteger(source.legacyMatchId)) {
      _add(
        diagnostics,
        'legacyMatchId',
        MatchIdentityDiagnosticCode.invalidMatchId,
      );
    }
    if (source.legacySessionId == null ||
        !_isPositiveSqliteInteger(source.legacySessionId!)) {
      _add(
        diagnostics,
        'legacySessionId',
        MatchIdentityDiagnosticCode.invalidSessionId,
      );
    }
    if (!_isPositiveSqliteInteger(source.matchNumber)) {
      _add(
        diagnostics,
        'matchNumber',
        MatchIdentityDiagnosticCode.invalidMatchNumber,
      );
    }
    _validateRequiredCode(
      field: 'gameTypeRaw',
      value: source.gameTypeRaw,
      accepted: _acceptedGameTypes,
      diagnostics: diagnostics,
    );
    if (source.raceToRaw != null &&
        !_isPositiveSqliteInteger(source.raceToRaw!)) {
      _add(
        diagnostics,
        'raceToRaw',
        MatchIdentityDiagnosticCode.integerOutOfRange,
      );
    }
    _validateOptionalString('opponentRaw', source.opponentRaw, diagnostics);
    _validateOptionalString('partnerRaw', source.partnerRaw, diagnostics);
    _validateOptionalCode(
      field: 'teamModeRaw',
      value: source.teamModeRaw,
      accepted: _acceptedTeamModes,
      diagnostics: diagnostics,
    );
    _validateOptionalString('winnerRaw', source.winnerRaw, diagnostics);
    _validateOptionalString('resultRaw', source.resultRaw, diagnostics);
    _validateOptionalString(
      'matchObjectiveRaw',
      source.matchObjectiveRaw,
      diagnostics,
    );
    _validateOptionalString('notesRaw', source.notesRaw, diagnostics);

    final startTime = _decodeStorageDate(
      field: 'startTimeStorageValue',
      value: source.startTimeStorageValue,
      diagnostics: diagnostics,
      nullable: true,
    );
    final endTime = _decodeStorageDate(
      field: 'endTimeStorageValue',
      value: source.endTimeStorageValue,
      diagnostics: diagnostics,
      nullable: true,
    );
    final createdAt = _decodeStorageDate(
      field: 'createdAtStorageValue',
      value: source.createdAtStorageValue,
      diagnostics: diagnostics,
    );
    if (startTime != null && endTime != null && endTime.isBefore(startTime)) {
      _add(
        diagnostics,
        'endTimeStorageValue',
        MatchIdentityDiagnosticCode.timestampOrderInvalid,
      );
    }
    if (source.sourceSchemaVersion <= 0) {
      _add(
        diagnostics,
        'sourceSchemaVersion',
        MatchIdentityDiagnosticCode.codeUnsupported,
      );
    }

    diagnostics.sort();
    final assessment = MatchIdentitySourceAssessment._(
      source: source,
      diagnostics: diagnostics.map((item) => item.value).toList(),
    );
    if (!assessment.isCompatible) {
      return MatchIdentityCompatibilityResult(
        assessment: assessment,
        snapshot: null,
        foundationMatch: null,
        aggregate: null,
      );
    }

    final snapshot = CanonicalMatchIdentitySnapshot._(
      canonicalMatchId: 'entity.match:${source.legacyMatchId}',
      legacyMatchId: source.legacyMatchId,
      canonicalSessionId: 'entity.session:${source.legacySessionId}',
      legacySessionId: source.legacySessionId!,
      matchNumber: source.matchNumber,
      gameType: source.gameTypeRaw,
      raceTo: source.raceToRaw,
      opponent: source.opponentRaw,
      partner: source.partnerRaw,
      teamMode: source.teamModeRaw,
      winner: source.winnerRaw,
      result: source.resultRaw,
      matchObjective: source.matchObjectiveRaw,
      notes: source.notesRaw,
      startTime: startTime == null ? null : _canonicalInstant(startTime),
      endTime: endTime == null ? null : _canonicalInstant(endTime),
      createdAt: _canonicalInstant(createdAt!),
      lifecycleLabel: endTime == null ? 'recording' : 'completed',
      sourceReference: source.sourceReference,
      sourceSchemaVersion: source.sourceSchemaVersion,
    );
    final representations = adaptSnapshot(snapshot);
    return MatchIdentityCompatibilityResult(
      assessment: assessment,
      snapshot: snapshot,
      foundationMatch: representations.foundationMatch,
      aggregate: representations.aggregate,
    );
  }

  MatchIdentityRepresentations adaptSnapshot(
    CanonicalMatchIdentitySnapshot snapshot,
  ) {
    final foundation = ProductMatch(
      id: MatchId(snapshot.legacyMatchId.toString()),
      version: VersionNumber(matchIdentityAdapterPolicyVersion),
      createdAt: UtcTimestamp(DateTime.parse(snapshot.createdAt)),
      lifecycleState: NonEmptyString(snapshot.lifecycleLabel),
      participantIds: const [],
      sessionIds: [SessionId(snapshot.legacySessionId.toString())],
    );
    final aggregate = MatchAggregate(
      root: foundation,
      rackSessionIds: const [],
    );
    if (foundation.id.canonical != snapshot.canonicalMatchId ||
        foundation.sessionIds.single.canonical != snapshot.canonicalSessionId ||
        aggregate.id != foundation.id) {
      throw const MatchIdentityException(
        MatchIdentityFailureCode.snapshotIdentityInvalid,
      );
    }
    return MatchIdentityRepresentations(
      foundationMatch: foundation,
      aggregate: aggregate,
    );
  }

  int parseCanonicalMatchId(String value) => _parseCanonicalId(
        value,
        namespace: 'entity.match',
      );

  int parseCanonicalSessionId(String value) => _parseCanonicalId(
        value,
        namespace: 'entity.session',
      );

  CanonicalMatchIdentitySnapshot decodeSnapshot(String rawJson) {
    Object? decoded;
    try {
      decoded = jsonDecode(rawJson);
    } on FormatException catch (error) {
      throw MatchIdentityException(
        MatchIdentityFailureCode.snapshotJsonInvalid,
        cause: error,
      );
    }
    if (decoded is! Map<String, dynamic>) {
      throw const MatchIdentityException(
        MatchIdentityFailureCode.snapshotShapeInvalid,
      );
    }
    final map = decoded;
    if (!_hasExactSnapshotShape(map)) {
      throw const MatchIdentityException(
        MatchIdentityFailureCode.snapshotShapeInvalid,
      );
    }
    if (map['schemaVersion'] != matchIdentityCompatibilitySchemaVersion ||
        map['adapterPolicyVersion'] != matchIdentityAdapterPolicyVersion) {
      throw const MatchIdentityException(
        MatchIdentityFailureCode.snapshotVersionUnsupported,
      );
    }

    final legacyMatchId = map['legacyMatchId']! as int;
    final legacySessionId = map['legacySessionId']! as int;
    final canonicalMatchId = map['canonicalMatchId']! as String;
    final canonicalSessionId = map['canonicalSessionId']! as String;
    if (parseCanonicalMatchId(canonicalMatchId) != legacyMatchId ||
        parseCanonicalSessionId(canonicalSessionId) != legacySessionId ||
        map['sourceReference'] != 'match:$legacyMatchId') {
      throw const MatchIdentityException(
        MatchIdentityFailureCode.snapshotIdentityInvalid,
      );
    }

    if (!_hasValidCanonicalProvenance(map)) {
      throw const MatchIdentityException(
        MatchIdentityFailureCode.snapshotProvenanceMismatch,
      );
    }

    return CanonicalMatchIdentitySnapshot._(
      canonicalMatchId: canonicalMatchId,
      legacyMatchId: legacyMatchId,
      canonicalSessionId: canonicalSessionId,
      legacySessionId: legacySessionId,
      matchNumber: map['matchNumber']! as int,
      gameType: map['gameType']! as String,
      raceTo: map['raceTo'] as int?,
      opponent: map['opponent'] as String?,
      partner: map['partner'] as String?,
      teamMode: map['teamMode'] as String?,
      winner: map['winner'] as String?,
      result: map['result'] as String?,
      matchObjective: map['matchObjective'] as String?,
      notes: map['notes'] as String?,
      startTime: map['startTime'] as String?,
      endTime: map['endTime'] as String?,
      createdAt: map['createdAt']! as String,
      lifecycleLabel: map['lifecycleLabel']! as String,
      sourceReference: map['sourceReference']! as String,
      sourceSchemaVersion: map['sourceSchemaVersion']! as int,
      expectedSourceDigest: map['sourceDigest']! as String,
      expectedDigest: map['digest']! as String,
    );
  }

  bool _hasExactSnapshotShape(Map<String, dynamic> map) {
    if (!_sameKeysInOrder(map.keys, _snapshotKeys)) return false;
    return map['schemaVersion'] is int &&
        map['adapterPolicyVersion'] is int &&
        map['canonicalMatchId'] is String &&
        map['legacyMatchId'] is int &&
        map['canonicalSessionId'] is String &&
        map['legacySessionId'] is int &&
        map['matchNumber'] is int &&
        map['gameType'] is String &&
        _isNullable<int>(map['raceTo']) &&
        _isNullable<String>(map['opponent']) &&
        _isNullable<String>(map['partner']) &&
        _isNullable<String>(map['teamMode']) &&
        _isNullable<String>(map['winner']) &&
        _isNullable<String>(map['result']) &&
        _isNullable<String>(map['matchObjective']) &&
        _isNullable<String>(map['notes']) &&
        _isNullable<String>(map['startTime']) &&
        _isNullable<String>(map['endTime']) &&
        map['createdAt'] is String &&
        map['lifecycleLabel'] is String &&
        map['sourceKind'] is String &&
        map['sourceReference'] is String &&
        map['sourceSchemaVersion'] is int &&
        map['diagnostics'] is List &&
        map['sourceDigest'] is String &&
        map['digest'] is String;
  }
}

final class _SortableDiagnostic implements Comparable<_SortableDiagnostic> {
  const _SortableDiagnostic(this.fieldOrder, this.value);

  final int fieldOrder;
  final MatchIdentityDiagnostic value;

  @override
  int compareTo(_SortableDiagnostic other) {
    final fieldComparison = fieldOrder.compareTo(other.fieldOrder);
    if (fieldComparison != 0) return fieldComparison;
    return value.code.index.compareTo(other.value.code.index);
  }
}

const _fieldOrder = <String>[
  'legacyMatchId',
  'legacySessionId',
  'matchNumber',
  'gameTypeRaw',
  'raceToRaw',
  'opponentRaw',
  'partnerRaw',
  'teamModeRaw',
  'winnerRaw',
  'resultRaw',
  'matchObjectiveRaw',
  'notesRaw',
  'startTimeStorageValue',
  'endTimeStorageValue',
  'createdAtStorageValue',
  'sourceSchemaVersion',
];

const _snapshotKeys = <String>[
  'schemaVersion',
  'adapterPolicyVersion',
  'canonicalMatchId',
  'legacyMatchId',
  'canonicalSessionId',
  'legacySessionId',
  'matchNumber',
  'gameType',
  'raceTo',
  'opponent',
  'partner',
  'teamMode',
  'winner',
  'result',
  'matchObjective',
  'notes',
  'startTime',
  'endTime',
  'createdAt',
  'lifecycleLabel',
  'sourceKind',
  'sourceReference',
  'sourceSchemaVersion',
  'diagnostics',
  'sourceDigest',
  'digest',
];

const _acceptedGameTypes = <String>{
  'race_to',
  'race_to_5',
  'race_to_7',
  'race_to_11',
  'ghost_challenge',
  'challenge_match',
  'league_match',
  'tournament_match',
  'practice_match',
  'practice',
  'warm_up',
  'drill',
  '9ball',
  'match',
  'tournament',
  'training',
};

const _acceptedTeamModes = <String>{'solo', 'doubles', 'team'};

void _add(
  List<_SortableDiagnostic> target,
  String field,
  MatchIdentityDiagnosticCode code,
) {
  target.add(
    _SortableDiagnostic(
      _fieldOrder.indexOf(field),
      MatchIdentityDiagnostic(field: field, code: code),
    ),
  );
}

void _validateRequiredCode({
  required String field,
  required String value,
  required Set<String> accepted,
  required List<_SortableDiagnostic> diagnostics,
}) {
  if (value.isEmpty) {
    _add(diagnostics, field, MatchIdentityDiagnosticCode.requiredEmpty);
  }
  if (value.contains('\u0000')) {
    _add(diagnostics, field, MatchIdentityDiagnosticCode.nullByte);
  }
  if (!accepted.contains(value)) {
    _add(diagnostics, field, MatchIdentityDiagnosticCode.codeUnsupported);
  }
}

void _validateOptionalString(
  String field,
  String? value,
  List<_SortableDiagnostic> diagnostics,
) {
  if (value != null && value.contains('\u0000')) {
    _add(diagnostics, field, MatchIdentityDiagnosticCode.nullByte);
  }
}

void _validateOptionalCode({
  required String field,
  required String? value,
  required Set<String> accepted,
  required List<_SortableDiagnostic> diagnostics,
}) {
  _validateOptionalString(field, value, diagnostics);
  if (value != null && !accepted.contains(value)) {
    _add(diagnostics, field, MatchIdentityDiagnosticCode.codeUnsupported);
  }
}

DateTime? _decodeStorageDate({
  required String field,
  required int? value,
  required List<_SortableDiagnostic> diagnostics,
  bool nullable = false,
}) {
  if (value == null) {
    if (!nullable) {
      _add(diagnostics, field, MatchIdentityDiagnosticCode.timestampInvalid);
    }
    return null;
  }
  if (value < -_maximumDateTimeStorageSeconds ||
      value > _maximumDateTimeStorageSeconds) {
    _add(diagnostics, field, MatchIdentityDiagnosticCode.timestampInvalid);
    return null;
  }
  try {
    return DateTime.fromMillisecondsSinceEpoch(value * 1000, isUtc: true);
  } on RangeError {
    _add(diagnostics, field, MatchIdentityDiagnosticCode.timestampInvalid);
    return null;
  }
}

String _canonicalInstant(DateTime value) {
  final utc = value.toUtc();
  String two(int part) => part.toString().padLeft(2, '0');
  String four(int part) => part.toString().padLeft(4, '0');
  String six(int part) => part.toString().padLeft(6, '0');
  return '${four(utc.year)}-${two(utc.month)}-${two(utc.day)}T'
      '${two(utc.hour)}:${two(utc.minute)}:${two(utc.second)}.'
      '${six(utc.millisecond * 1000 + utc.microsecond)}Z';
}

bool _isCanonicalInstant(String value) {
  if (!RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{6}Z$')
      .hasMatch(value)) {
    return false;
  }
  try {
    return _canonicalInstant(DateTime.parse(value)) == value;
  } on FormatException {
    return false;
  }
}

bool _hasValidCanonicalProvenance(Map<String, dynamic> map) {
  final start = map['startTime'] as String?;
  final end = map['endTime'] as String?;
  final created = map['createdAt']! as String;
  if ((start != null && !_isCanonicalInstant(start)) ||
      (end != null && !_isCanonicalInstant(end)) ||
      !_isCanonicalInstant(created)) {
    return false;
  }
  if (start != null &&
      end != null &&
      DateTime.parse(end).isBefore(DateTime.parse(start))) {
    return false;
  }
  final expectedLifecycle = end == null ? 'recording' : 'completed';
  final raceTo = map['raceTo'] as int?;
  return _isPositiveSqliteInteger(map['matchNumber']! as int) &&
      _acceptedGameTypes.contains(map['gameType']) &&
      (raceTo == null || _isPositiveSqliteInteger(raceTo)) &&
      (map['teamMode'] == null ||
          _acceptedTeamModes.contains(map['teamMode'])) &&
      [
        map['opponent'],
        map['partner'],
        map['winner'],
        map['result'],
        map['matchObjective'],
        map['notes'],
      ].whereType<String>().every((value) => !value.contains('\u0000')) &&
      map['lifecycleLabel'] == expectedLifecycle &&
      map['sourceKind'] == matchIdentitySourceKind &&
      (map['sourceSchemaVersion']! as int) > 0 &&
      (map['diagnostics']! as List).isEmpty;
}

int _parseCanonicalId(String value, {required String namespace}) {
  final prefix = '$namespace:';
  if (!value.startsWith(prefix)) {
    throw const MatchIdentityException(
      MatchIdentityFailureCode.snapshotIdentityInvalid,
    );
  }
  final raw = value.substring(prefix.length);
  if (!RegExp(r'^[1-9][0-9]*$').hasMatch(raw)) {
    throw const MatchIdentityException(
      MatchIdentityFailureCode.snapshotIdentityInvalid,
    );
  }
  final parsed = int.tryParse(raw);
  if (parsed == null || !_isPositiveSqliteInteger(parsed)) {
    throw const MatchIdentityException(
      MatchIdentityFailureCode.snapshotIdentityInvalid,
    );
  }
  if ('$namespace:$parsed' != value) {
    throw const MatchIdentityException(
      MatchIdentityFailureCode.snapshotIdentityInvalid,
    );
  }
  return parsed;
}

bool _isPositiveSqliteInteger(int value) =>
    value > 0 && value <= matchIdentitySqliteMaximumInteger;

bool _sameKeysInOrder(Iterable<String> actual, List<String> expected) {
  final keys = actual.toList(growable: false);
  if (keys.length != expected.length) return false;
  for (var index = 0; index < expected.length; index++) {
    if (keys[index] != expected[index]) return false;
  }
  return true;
}

bool _isNullable<T>(Object? value) => value == null || value is T;

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
