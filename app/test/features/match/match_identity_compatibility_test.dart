import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/match/domain/match_identity_compatibility.dart';

void main() {
  const adapter = MatchIdentityCompatibilityAdapter();

  group('Match identity compatibility adapter', () {
    test('maps exact raw wire, canonical wire, and frozen targets', () {
      final result = adapter.adapt(
        _source(
          gameType: 'race_to_5',
          raceTo: 5,
          opponent: 'Opponent ',
          partner: '',
          teamMode: 'doubles',
          winner: 'Player',
          matchResult: '5-3',
          objective: 'win',
          notes: ' exact notes ',
          startTime: _seconds(2026, 7, 25, 10),
          endTime: _seconds(2026, 7, 25, 11),
        ),
      );

      expect(result.isCompatible, isTrue);
      expect(
        result.assessment.toJson().keys,
        [
          'schemaVersion',
          'sourceKind',
          'sourceSchemaVersion',
          'legacyMatchId',
          'sourceReference',
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
          'rawAssessmentDigest',
          'diagnostics',
        ],
      );

      final snapshot = result.snapshot!;
      expect(snapshot.toJson().keys, _snapshotKeys);
      expect(snapshot.canonicalMatchId, 'entity.match:7');
      expect(snapshot.canonicalSessionId, 'entity.session:3');
      expect(snapshot.sourceReference, 'match:7');
      expect(snapshot.gameType, 'race_to_5');
      expect(snapshot.opponent, 'Opponent ');
      expect(snapshot.partner, '');
      expect(snapshot.notes, ' exact notes ');
      expect(snapshot.lifecycleLabel, 'completed');
      expect(snapshot.startTime, '2026-07-25T10:00:00.000000Z');
      expect(snapshot.endTime, '2026-07-25T11:00:00.000000Z');

      final foundation = result.foundationMatch!;
      expect(foundation.id.canonical, snapshot.canonicalMatchId);
      expect(foundation.version.value, 1);
      expect(foundation.createdAt.value.isUtc, isTrue);
      expect(foundation.lifecycleState.value, 'completed');
      expect(foundation.participantIds, isEmpty);
      expect(
        foundation.sessionIds.single.canonical,
        snapshot.canonicalSessionId,
      );
      expect(result.aggregate!.root, same(foundation));
      expect(result.aggregate!.rackSessionIds, isEmpty);
    });

    test('digest payloads use the exact documented key participation', () {
      final result = adapter.adapt(_source());
      final assessment = result.assessment;
      final snapshotJson = result.snapshot!.toJson();

      expect(
        assessment.rawAssessmentDigest,
        _digest(assessment.source.toDigestPayload()),
      );
      expect(
        result.snapshot!.sourceDigest,
        _digest(
          Map<String, Object?>.fromEntries(
            snapshotJson.entries.skip(1).take(22),
          ),
        ),
      );
      expect(
        result.snapshot!.digest,
        _digest(
          Map<String, Object?>.fromEntries(snapshotJson.entries.take(25)),
        ),
      );
      expect(
        adapter.adapt(_source()).snapshot!.toJsonString(),
        result.snapshot!.toJsonString(),
      );
    });

    test('every accepted historic game code remains distinct', () {
      const codes = [
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
      ];
      final sourceDigests = <String>{};
      final rawDigests = <String>{};
      for (final code in codes) {
        final result = adapter.adapt(_source(gameType: code));
        expect(result.snapshot!.gameType, code);
        sourceDigests.add(result.snapshot!.sourceDigest);
        rawDigests.add(result.assessment.rawAssessmentDigest);
      }
      expect(sourceDigests, hasLength(codes.length));
      expect(rawDigests, hasLength(codes.length));
    });

    test('race target has no cross-field inference', () {
      expect(
        adapter.adapt(_source(gameType: 'race_to', raceTo: null)).isCompatible,
        isTrue,
      );
      expect(
        adapter.adapt(_source(gameType: 'drill', raceTo: 5)).isCompatible,
        isTrue,
      );
      expect(
        adapter.adapt(_source(raceTo: 0)).assessment.diagnostics.single.code,
        MatchIdentityDiagnosticCode.integerOutOfRange,
      );
    });

    test('strict Match and Session parsers round-trip bounded IDs', () {
      expect(adapter.parseCanonicalMatchId('entity.match:1'), 1);
      expect(adapter.parseCanonicalSessionId('entity.session:3'), 3);
      expect(
        adapter.parseCanonicalMatchId(
          'entity.match:$matchIdentitySqliteMaximumInteger',
        ),
        matchIdentitySqliteMaximumInteger,
      );

      for (final invalid in [
        'entity.match:0',
        'entity.match:-1',
        'entity.match:+1',
        'entity.match:01',
        ' entity.match:1',
        'entity.match:1 ',
        'match:1',
        'entity.match:1.0',
        'entity.match:1e2',
        'entity.match:${matchIdentitySqliteMaximumInteger}0',
      ]) {
        expect(
          () => adapter.parseCanonicalMatchId(invalid),
          throwsA(_failure(MatchIdentityFailureCode.snapshotIdentityInvalid)),
          reason: invalid,
        );
      }
      for (final invalid in [
        'entity.session:0',
        'entity.session:-1',
        'entity.session:+1',
        'entity.session:03',
        'entity.player:3',
      ]) {
        expect(
          () => adapter.parseCanonicalSessionId(invalid),
          throwsA(_failure(MatchIdentityFailureCode.snapshotIdentityInvalid)),
          reason: invalid,
        );
      }
    });

    test('invalid identities remain attributable without partial output', () {
      final result = adapter.adapt(
        _source(id: 0, sessionId: null, matchNumber: -1),
      );

      expect(result.assessment.source.sourceReference, 'match:0');
      expect(
        result.assessment.diagnostics.map((item) => item.code),
        [
          MatchIdentityDiagnosticCode.invalidMatchId,
          MatchIdentityDiagnosticCode.invalidSessionId,
          MatchIdentityDiagnosticCode.invalidMatchNumber,
        ],
      );
      expect(result.snapshot, isNull);
      expect(result.foundationMatch, isNull);
      expect(result.aggregate, isNull);
      expect(
        adapter.adapt(_source(id: -9)).assessment.source.sourceReference,
        'match:-9',
      );
    });

    test('diagnostics follow exact field and code precedence', () {
      final result = adapter.adapt(
        _source(
          sourceSchemaVersion: 0,
          gameType: '\u0000',
          raceTo: 0,
          opponent: '\u0000',
          teamMode: 'bad\u0000',
          startTime: 10,
          endTime: 9,
          createdAt: matchIdentitySqliteMaximumInteger,
        ),
      );

      expect(
        result.assessment.diagnostics
            .map((item) => '${item.field}:${item.code.value}'),
        [
          'gameTypeRaw:null-byte',
          'gameTypeRaw:code-unsupported',
          'raceToRaw:integer-out-of-range',
          'opponentRaw:null-byte',
          'teamModeRaw:null-byte',
          'teamModeRaw:code-unsupported',
          'endTimeStorageValue:timestamp-order-invalid',
          'createdAtStorageValue:timestamp-invalid',
          'sourceSchemaVersion:code-unsupported',
        ],
      );

      final empty = adapter.adapt(_source(gameType: ''));
      expect(
        empty.assessment.diagnostics.map((item) => item.code),
        [
          MatchIdentityDiagnosticCode.requiredEmpty,
          MatchIdentityDiagnosticCode.codeUnsupported,
        ],
      );
    });

    test('timestamp null, range, ordering, and lifecycle semantics are exact',
        () {
      final recording = adapter.adapt(
        _source(startTime: null, endTime: null),
      );
      expect(recording.snapshot!.startTime, isNull);
      expect(recording.snapshot!.endTime, isNull);
      expect(recording.snapshot!.lifecycleLabel, 'recording');
      expect(recording.snapshot!.createdAt, endsWith('.000000Z'));

      final completedWithoutStart = adapter.adapt(
        _source(startTime: null, endTime: 0),
      );
      expect(completedWithoutStart.isCompatible, isTrue);
      expect(completedWithoutStart.snapshot!.endTime,
          '1970-01-01T00:00:00.000000Z');
      expect(completedWithoutStart.snapshot!.lifecycleLabel, 'completed');

      expect(
        adapter
            .adapt(_source(startTime: matchIdentitySqliteMaximumInteger))
            .assessment
            .diagnostics
            .single
            .code,
        MatchIdentityDiagnosticCode.timestampInvalid,
      );
    });

    test('optional text is exact and empty values are compatible', () {
      final snapshot = adapter
          .adapt(
            _source(
              opponent: '',
              partner: ' partner ',
              winner: '',
              matchResult: ' 7-5 ',
              objective: '',
              notes: ' notes ',
            ),
          )
          .snapshot!;

      expect(snapshot.opponent, '');
      expect(snapshot.partner, ' partner ');
      expect(snapshot.result, ' 7-5 ');
      expect(snapshot.notes, ' notes ');
    });

    test('snapshot round-trips byte-identically', () {
      final original = adapter.adapt(_source()).snapshot!;
      final decoded = adapter.decodeSnapshot(original.toJsonString());
      final targets = adapter.adaptSnapshot(decoded);

      expect(decoded.toJsonString(), original.toJsonString());
      expect(decoded.sourceDigest, original.sourceDigest);
      expect(decoded.digest, original.digest);
      expect(targets.foundationMatch.id.canonical, decoded.canonicalMatchId);
      expect(
        targets.foundationMatch.sessionIds.single.canonical,
        decoded.canonicalSessionId,
      );
      expect(targets.aggregate.root, same(targets.foundationMatch));
    });

    test('snapshot decoder enforces exact failure precedence', () {
      final valid = adapter.adapt(_source()).snapshot!.toJson();

      expect(
        () => adapter.decodeSnapshot('{'),
        throwsA(_failure(MatchIdentityFailureCode.snapshotJsonInvalid)),
      );
      expect(
        () => adapter.decodeSnapshot('[]'),
        throwsA(_failure(MatchIdentityFailureCode.snapshotShapeInvalid)),
      );
      expect(
        () => adapter.decodeSnapshot(jsonEncode({...valid}..remove('notes'))),
        throwsA(_failure(MatchIdentityFailureCode.snapshotShapeInvalid)),
      );
      expect(
        () => adapter.decodeSnapshot(
          jsonEncode(<String, Object?>{'extra': true, ...valid}),
        ),
        throwsA(_failure(MatchIdentityFailureCode.snapshotShapeInvalid)),
      );
      expect(
        () => adapter.decodeSnapshot(jsonEncode({...valid, 'raceTo': '5'})),
        throwsA(_failure(MatchIdentityFailureCode.snapshotShapeInvalid)),
      );
      expect(
        () => adapter.decodeSnapshot(
          jsonEncode({...valid, 'schemaVersion': 2}),
        ),
        throwsA(
          _failure(MatchIdentityFailureCode.snapshotVersionUnsupported),
        ),
      );
      expect(
        () => adapter.decodeSnapshot(
          jsonEncode({...valid, 'canonicalSessionId': 'entity.session:4'}),
        ),
        throwsA(_failure(MatchIdentityFailureCode.snapshotIdentityInvalid)),
      );
      expect(
        () => adapter.decodeSnapshot(
          jsonEncode({...valid, 'lifecycleLabel': 'other'}),
        ),
        throwsA(
          _failure(MatchIdentityFailureCode.snapshotProvenanceMismatch),
        ),
      );
      expect(
        () => adapter.decodeSnapshot(
          jsonEncode({...valid, 'gameType': 'training'}),
        ),
        throwsA(
          _failure(MatchIdentityFailureCode.snapshotProvenanceMismatch),
        ),
      );
      expect(
        () => adapter.decodeSnapshot(
          jsonEncode({...valid, 'digest': List.filled(64, '0').join()}),
        ),
        throwsA(_failure(MatchIdentityFailureCode.snapshotDigestMismatch)),
      );
    });

    test('tampering every protected snapshot field is rejected', () {
      final valid = adapter.adapt(_source()).snapshot!.toJson();
      for (final key in valid.keys) {
        final tampered = <String, Object?>{...valid};
        tampered[key] = _sameTypeMutation(key, valid[key]);
        expect(
          () => adapter.decodeSnapshot(jsonEncode(tampered)),
          throwsA(isA<MatchIdentityException>()),
          reason: key,
        );
      }
    });
  });
}

MatchIdentityRawSource _source({
  int sourceSchemaVersion = 29,
  int id = 7,
  int? sessionId = 3,
  int matchNumber = 2,
  String gameType = 'race_to',
  int? raceTo = 7,
  String? opponent,
  String? partner,
  String? teamMode = 'solo',
  String? winner,
  String? matchResult,
  String? objective,
  String? notes,
  int? startTime,
  int? endTime,
  int? createdAt,
}) =>
    MatchIdentityRawSource(
      sourceSchemaVersion: sourceSchemaVersion,
      legacyMatchId: id,
      legacySessionId: sessionId,
      matchNumber: matchNumber,
      gameTypeRaw: gameType,
      raceToRaw: raceTo,
      opponentRaw: opponent,
      partnerRaw: partner,
      teamModeRaw: teamMode,
      winnerRaw: winner,
      resultRaw: matchResult,
      matchObjectiveRaw: objective,
      notesRaw: notes,
      startTimeStorageValue: startTime,
      endTimeStorageValue: endTime,
      createdAtStorageValue: createdAt ?? _seconds(2026, 7, 25, 9),
    );

int _seconds(int year, int month, int day, [int hour = 0]) =>
    DateTime.utc(year, month, day, hour).millisecondsSinceEpoch ~/ 1000;

Object? _sameTypeMutation(String key, Object? value) {
  if (key == 'diagnostics') return <Object?>['tampered'];
  if (value == null) return key == 'raceTo' ? 1 : 'tampered';
  if (value is int) return value == 1 ? 2 : value + 1;
  if (value is String) return '$value-tampered';
  if (value is List) return <Object?>['tampered'];
  throw StateError('No mutation for $key');
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();

Matcher _failure(MatchIdentityFailureCode code) =>
    isA<MatchIdentityException>().having(
      (error) => error.code,
      'code',
      code,
    );

const _snapshotKeys = [
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
