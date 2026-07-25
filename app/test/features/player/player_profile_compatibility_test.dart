import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/player/domain/player_profile_compatibility.dart';

void main() {
  const adapter = PlayerProfileCompatibilityAdapter();

  group('Player profile compatibility adapter', () {
    test('maps a full v29 row to exact assessment, snapshot, and targets', () {
      final result = adapter.adapt(
        _source(
          avatarPath: '/avatars/player.png',
          age: 31,
          gender: 'male',
          clubRegion: 'HCM',
          rank: 'A',
          mainGame: '10 Ball',
          goal: 'Tournament preparation',
          playStyles: '["safe", "attack"]',
          trainingGoals: '["rank_up", "position"]',
          startedPlayingAt: _seconds(2020, 2, 3, 17),
          hasCompeted: 1,
          hoursPerWeek: 12,
        ),
      );

      expect(result.isCompatible, isTrue);
      expect(result.assessment.toJson().keys, _assessmentKeys);
      final rawPayload = Map<String, Object?>.from(result.assessment.toJson())
        ..remove('rawAssessmentDigest')
        ..remove('diagnostics');
      expect(
        result.assessment.rawAssessmentDigest,
        sha256.convert(utf8.encode(jsonEncode(rawPayload))).toString(),
      );

      final snapshot = result.snapshot!;
      expect(snapshot.toJson().keys, _snapshotKeys);
      expect(snapshot.canonicalPlayerId, 'entity.player:7');
      expect(snapshot.sourceReference, 'player:7');
      expect(snapshot.sourceCreatedAt, '2024-01-02T03:04:05.000000Z');
      expect(snapshot.sourceUpdatedAt, '2024-01-02T04:04:05.000000Z');
      expect(snapshot.startedPlayingOn, '2020-02-04');
      expect(snapshot.playStyles, ['attack', 'safe']);
      expect(snapshot.trainingGoals, ['position', 'rank_up']);
      expect(result.foundationProfile!.id.canonical, 'entity.player:7');
      expect(result.foundationProfile!.displayName.value, 'Test Player');
      expect(result.foundationProfile!.lifecycleState.value, 'available');
      expect(result.contract!.playerId, 'entity.player:7');
      expect(result.contract!.dominantHand, 'right');
      expect(result.contract!.locale, 'en');
      expect(result.contract!.preferences, [
        'play-style:attack',
        'play-style:safe',
        'training-goal:position',
        'training-goal:rank_up',
      ]);
      expect(result.contract!.historyReferences, isEmpty);
    });

    test('semantic digests ignore accepted alias, JSON formatting, and order',
        () {
      final first = adapter.adapt(
        _source(
          language: 'english',
          playStyles: '["safe","attack"]',
          trainingGoals: '["position", "rank_up"]',
        ),
      );
      final second = adapter.adapt(
        _source(
          language: 'en',
          playStyles: '[ "attack", "safe" ]',
          trainingGoals: '["rank_up","position"]',
        ),
      );

      expect(first.assessment.rawAssessmentDigest,
          isNot(second.assessment.rawAssessmentDigest));
      expect(first.snapshot!.sourceDigest, second.snapshot!.sourceDigest);
      expect(first.snapshot!.digest, second.snapshot!.digest);
      expect(first.snapshot!.toJsonString(), second.snapshot!.toJsonString());
    });

    test('locks every accepted language and source-code alias', () {
      for (final entry in const {
        'vi': 'vi',
        'vietnamese': 'vi',
        'en': 'en',
        'english': 'en',
      }.entries) {
        expect(adapter.adapt(_source(language: entry.key)).snapshot!.locale,
            entry.value);
      }
      for (final measurement in const ['cm', 'in', 'inch', 'metric']) {
        expect(
          adapter
              .adapt(_source(measurement: measurement))
              .snapshot!
              .measurementSystem,
          measurement,
        );
      }
      for (final hand in const ['left', 'right']) {
        expect(adapter.adapt(_source(hand: hand)).snapshot!.dominantHand, hand);
      }
      for (final theme in const ['system', 'light', 'dark']) {
        expect(adapter.adapt(_source(theme: theme)).snapshot!.theme, theme);
      }
    });

    test('preserves explicit nulls and formats UTC instants with six digits',
        () {
      final snapshot = adapter.adapt(_source()).snapshot!;

      expect(snapshot.avatarPath, isNull);
      expect(snapshot.age, isNull);
      expect(snapshot.gender, isNull);
      expect(snapshot.clubRegion, isNull);
      expect(snapshot.rank, isNull);
      expect(snapshot.mainGame, isNull);
      expect(snapshot.goal, isNull);
      expect(snapshot.startedPlayingOn, isNull);
      expect(snapshot.hoursPerWeek, isNull);
      expect(snapshot.sourceCreatedAt, endsWith('.000000Z'));
      expect(snapshot.toJson()['avatarPath'], isNull);
    });

    test('strict identity parsing accepts bounded positive canonical IDs', () {
      expect(adapter.parseCanonicalPlayerId('entity.player:1'), 1);
      expect(
        adapter.parseCanonicalPlayerId(
          'entity.player:$sqliteMaximumInteger',
        ),
        sqliteMaximumInteger,
      );

      for (final invalid in [
        'entity.player:0',
        'entity.player:-1',
        'entity.player:+1',
        'entity.player:01',
        ' entity.player:1',
        'entity.player:1 ',
        'player:1',
        'entity.player:1.0',
        'entity.player:${sqliteMaximumInteger}0',
      ]) {
        expect(
          () => adapter.parseCanonicalPlayerId(invalid),
          throwsA(_failure(PlayerProfileFailureCode.snapshotIdentityInvalid)),
          reason: invalid,
        );
      }
    });

    test('signed zero and negative IDs remain attributable without output', () {
      for (final id in const [0, -9]) {
        final first = adapter.adapt(_source(id: id));
        final second = adapter.adapt(_source(id: id));

        expect(first.assessment.source.sourceReference, 'player:$id');
        expect(first.assessment.rawAssessmentDigest,
            second.assessment.rawAssessmentDigest);
        expect(
          first.assessment.diagnostics.map((item) => item.code),
          [PlayerProfileDiagnosticCode.invalidPlayerId],
        );
        expect(first.snapshot, isNull);
        expect(first.foundationProfile, isNull);
        expect(first.contract, isNull);
      }
    });

    test('diagnostics have stable field, index, and code precedence', () {
      final result = adapter.adapt(
        _source(
          name: ' Bad\u0000 ',
          hand: 'up',
          language: '',
          measurement: 'yards',
          theme: 'purple',
          playStyles: '["safe", " safe ", "", 4, "unknown"]',
          trainingGoals: 'false',
          createdAt: _seconds(2024, 1, 3),
          updatedAt: _seconds(2024, 1, 2),
        ),
      );

      expect(result.snapshot, isNull);
      expect(
        result.assessment.diagnostics.map(
          (item) => '${item.field}:${item.listIndex}:${item.code.value}',
        ),
        [
          'nameRaw:null:null-byte',
          'nameRaw:null:required-outer-whitespace',
          'dominantHandRaw:null:code-unsupported',
          'languageRaw:null:code-unsupported',
          'languageRaw:null:required-empty',
          'measurementSystemRaw:null:code-unsupported',
          'themeRaw:null:code-unsupported',
          'playStylesRawJson:1:list-item-duplicate',
          'playStylesRawJson:2:list-item-empty',
          'playStylesRawJson:3:list-item-not-string',
          'playStylesRawJson:4:code-unsupported',
          'trainingGoalsRawJson:null:list-not-array',
          'updatedAtStorageValue:null:timestamp-order-invalid',
        ],
      );
      expect(result.assessment.toJsonString(),
          jsonEncode(result.assessment.toJson()));
    });

    test('distinguishes invalid JSON, non-array, and malformed list items', () {
      final cases = <String, PlayerProfileDiagnosticCode>{
        '{': PlayerProfileDiagnosticCode.listJsonInvalid,
        '{}': PlayerProfileDiagnosticCode.listNotArray,
        '[1]': PlayerProfileDiagnosticCode.listItemNotString,
        '[""]': PlayerProfileDiagnosticCode.listItemEmpty,
        '["safe", " safe "]': PlayerProfileDiagnosticCode.listItemDuplicate,
        '["new-code"]': PlayerProfileDiagnosticCode.codeUnsupported,
      };
      for (final entry in cases.entries) {
        final result = adapter.adapt(_source(playStyles: entry.key));
        expect(
          result.assessment.diagnostics.single.code,
          entry.value,
          reason: entry.key,
        );
      }
    });

    test('rejects name whitespace, null bytes, invalid timestamps and codes',
        () {
      for (final name in const ['', ' name', 'name ', '\u0000']) {
        expect(adapter.adapt(_source(name: name)).isCompatible, isFalse);
      }
      for (final fieldCase in [
        _source(hand: 'Left'),
        _source(language: 'EN'),
        _source(measurement: 'imperial'),
        _source(theme: 'auto'),
        _source(rank: 'S'),
        _source(mainGame: '9ball'),
      ]) {
        expect(adapter.adapt(fieldCase).isCompatible, isFalse);
      }
      expect(
        adapter
            .adapt(_source(createdAt: sqliteMaximumInteger))
            .assessment
            .diagnostics
            .map((item) => item.code),
        contains(PlayerProfileDiagnosticCode.timestampInvalid),
      );
    });

    test('snapshot JSON round-trips byte-identically', () {
      final original = adapter.adapt(_source()).snapshot!;
      final decoded = adapter.decodeSnapshot(original.toJsonString());
      final representations = adapter.adaptSnapshot(decoded);

      expect(decoded.toJsonString(), original.toJsonString());
      expect(decoded.sourceDigest, original.sourceDigest);
      expect(decoded.digest, original.digest);
      expect(representations.foundationProfile.id.canonical,
          decoded.canonicalPlayerId);
      expect(representations.contract.playerId, decoded.canonicalPlayerId);
    });

    test('snapshot decoder enforces failure precedence', () {
      final valid = adapter.adapt(_source()).snapshot!.toJson();

      expect(
        () => adapter.decodeSnapshot('{'),
        throwsA(_failure(PlayerProfileFailureCode.snapshotJsonInvalid)),
      );
      expect(
        () => adapter.decodeSnapshot('[]'),
        throwsA(_failure(PlayerProfileFailureCode.snapshotShapeInvalid)),
      );
      expect(
        () => adapter.decodeSnapshot(jsonEncode({...valid}..remove('theme'))),
        throwsA(_failure(PlayerProfileFailureCode.snapshotShapeInvalid)),
      );
      expect(
        () => adapter.decodeSnapshot(
          jsonEncode(<String, Object?>{'extra': true, ...valid}),
        ),
        throwsA(_failure(PlayerProfileFailureCode.snapshotShapeInvalid)),
      );
      expect(
        () => adapter.decodeSnapshot(
          jsonEncode({...valid, 'age': '31'}),
        ),
        throwsA(_failure(PlayerProfileFailureCode.snapshotShapeInvalid)),
      );
      expect(
        () => adapter.decodeSnapshot(
          jsonEncode({...valid, 'schemaVersion': 2}),
        ),
        throwsA(_failure(PlayerProfileFailureCode.snapshotVersionUnsupported)),
      );
      expect(
        () => adapter.decodeSnapshot(
          jsonEncode({...valid, 'canonicalPlayerId': 'entity.player:8'}),
        ),
        throwsA(_failure(PlayerProfileFailureCode.snapshotIdentityInvalid)),
      );
      expect(
        () => adapter.decodeSnapshot(jsonEncode({...valid, 'name': 'Changed'})),
        throwsA(
          _failure(PlayerProfileFailureCode.snapshotProvenanceMismatch),
        ),
      );
      expect(
        () => adapter.decodeSnapshot(
          jsonEncode({...valid, 'startedPlayingOn': '2024-02-31'}),
        ),
        throwsA(
          _failure(PlayerProfileFailureCode.snapshotProvenanceMismatch),
        ),
      );
      expect(
        () => adapter.decodeSnapshot(
          jsonEncode({...valid, 'digest': List.filled(64, '0').join()}),
        ),
        throwsA(_failure(PlayerProfileFailureCode.snapshotDigestMismatch)),
      );
    });

    test('tampering every protected snapshot field is rejected', () {
      final valid = adapter.adapt(_source()).snapshot!.toJson();
      for (final key in valid.keys) {
        final tampered = <String, Object?>{...valid};
        tampered[key] = _sameTypeMutation(key, valid[key]);
        expect(
          () => adapter.decodeSnapshot(jsonEncode(tampered)),
          throwsA(isA<PlayerProfileException>()),
          reason: key,
        );
      }
    });
  });
}

PlayerProfileRawSource _source({
  int id = 7,
  String name = 'Test Player',
  String hand = 'right',
  String language = 'en',
  String measurement = 'metric',
  String theme = 'dark',
  String? avatarPath,
  int? age,
  String? gender,
  String? clubRegion,
  String? rank,
  String? mainGame,
  String? goal,
  String playStyles = '["safe", "attack"]',
  String trainingGoals = '["rank_up", "position"]',
  int? startedPlayingAt,
  int hasCompeted = 0,
  int? hoursPerWeek,
  int? createdAt,
  int? updatedAt,
}) =>
    PlayerProfileRawSource(
      sourceSchemaVersion: 29,
      legacyPlayerId: id,
      nameRaw: name,
      dominantHandRaw: hand,
      languageRaw: language,
      measurementSystemRaw: measurement,
      themeRaw: theme,
      avatarPathRaw: avatarPath,
      ageRaw: age,
      genderRaw: gender,
      clubRegionRaw: clubRegion,
      rankRaw: rank,
      mainGameRaw: mainGame,
      goalRaw: goal,
      playStylesRawJson: playStyles,
      trainingGoalsRawJson: trainingGoals,
      startedPlayingAtStorageValue: startedPlayingAt,
      hasCompetedStorageValue: hasCompeted,
      hoursPerWeekRaw: hoursPerWeek,
      createdAtStorageValue: createdAt ?? _seconds(2024, 1, 2, 3, 4, 5),
      updatedAtStorageValue: updatedAt ?? _seconds(2024, 1, 2, 4, 4, 5),
    );

int _seconds(
  int year,
  int month,
  int day, [
  int hour = 0,
  int minute = 0,
  int second = 0,
]) =>
    DateTime.utc(year, month, day, hour, minute, second)
        .millisecondsSinceEpoch ~/
    1000;

Object? _sameTypeMutation(String key, Object? value) {
  if (key == 'diagnostics') return ['tampered'];
  if (value == null) {
    return switch (key) {
      'age' || 'hoursPerWeek' => 1,
      _ => 'tampered',
    };
  }
  if (value is String) return '${value}x';
  if (value is int) return value + 1;
  if (value is bool) return !value;
  if (value is List) return [...value, 'tampered'];
  throw StateError('Unsupported test value for $key');
}

Matcher _failure(PlayerProfileFailureCode code) =>
    isA<PlayerProfileException>().having(
      (error) => error.code,
      'code',
      code,
    );

const _assessmentKeys = <String>[
  'schemaVersion',
  'adapterPolicyVersion',
  'sourceKind',
  'sourceReference',
  'sourceSchemaVersion',
  'legacyPlayerId',
  'nameRaw',
  'dominantHandRaw',
  'languageRaw',
  'measurementSystemRaw',
  'themeRaw',
  'avatarPathRaw',
  'ageRaw',
  'genderRaw',
  'clubRegionRaw',
  'rankRaw',
  'mainGameRaw',
  'goalRaw',
  'playStylesRawJson',
  'trainingGoalsRawJson',
  'startedPlayingAtStorageValue',
  'hasCompetedStorageValue',
  'hoursPerWeekRaw',
  'createdAtStorageValue',
  'updatedAtStorageValue',
  'rawAssessmentDigest',
  'diagnostics',
];

const _snapshotKeys = <String>[
  'schemaVersion',
  'adapterPolicyVersion',
  'sourceKind',
  'sourceReference',
  'sourceSchemaVersion',
  'legacyPlayerId',
  'canonicalPlayerId',
  'sourceCreatedAt',
  'sourceUpdatedAt',
  'name',
  'dominantHand',
  'locale',
  'measurementSystem',
  'theme',
  'avatarPath',
  'age',
  'gender',
  'clubRegion',
  'rank',
  'mainGame',
  'goal',
  'playStyles',
  'trainingGoals',
  'startedPlayingOn',
  'hasCompeted',
  'hoursPerWeek',
  'compatibilityStatus',
  'diagnostics',
  'sourceDigest',
  'digest',
];
