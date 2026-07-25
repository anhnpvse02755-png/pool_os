import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../../contracts/player_model_contracts.dart';
import '../../../domain/entities/player_profile.dart';
import '../../../domain/shared/entity_ids.dart';
import '../../../domain/shared/scalar_values.dart';
import '../../../domain/shared/temporal_values.dart';

const playerProfileCompatibilitySchemaVersion = 1;
const playerProfileAdapterPolicyVersion = 1;
const playerProfileSourceKind = 'legacy-player-row';
const sqliteMaximumInteger = 9223372036854775807;
const _maximumDateTimeStorageSeconds = 8640000000000;

enum PlayerProfileFailureCode {
  targetNotFound('player-profile-target-not-found'),
  activeInvariantViolated('player-profile-active-invariant-violated'),
  databaseFailure('player-profile-database-failure'),
  sourceReadFailure('player-profile-source-read-failure'),
  snapshotJsonInvalid('player-profile-snapshot-json-invalid'),
  snapshotShapeInvalid('player-profile-snapshot-shape-invalid'),
  snapshotVersionUnsupported('player-profile-snapshot-version-unsupported'),
  snapshotIdentityInvalid('player-profile-snapshot-identity-invalid'),
  snapshotProvenanceMismatch('player-profile-snapshot-provenance-mismatch'),
  snapshotDigestMismatch('player-profile-snapshot-digest-mismatch');

  const PlayerProfileFailureCode(this.value);

  final String value;
}

final class PlayerProfileException implements Exception {
  const PlayerProfileException(this.code, {this.cause});

  final PlayerProfileFailureCode code;
  final Object? cause;

  @override
  String toString() => code.value;
}

enum PlayerProfileSourceFailureKind { database, sourceRead }

final class PlayerProfileSourceException implements Exception {
  const PlayerProfileSourceException(this.kind, {this.cause});

  final PlayerProfileSourceFailureKind kind;
  final Object? cause;
}

enum PlayerProfileDiagnosticCode {
  invalidPlayerId('invalid-player-id'),
  requiredEmpty('required-empty'),
  requiredOuterWhitespace('required-outer-whitespace'),
  nullByte('null-byte'),
  timestampInvalid('timestamp-invalid'),
  timestampOrderInvalid('timestamp-order-invalid'),
  listJsonInvalid('list-json-invalid'),
  listNotArray('list-not-array'),
  listItemNotString('list-item-not-string'),
  listItemEmpty('list-item-empty'),
  listItemDuplicate('list-item-duplicate'),
  codeUnsupported('code-unsupported');

  const PlayerProfileDiagnosticCode(this.value);

  final String value;
}

final class PlayerProfileDiagnostic {
  const PlayerProfileDiagnostic({
    required this.field,
    required this.code,
    this.listIndex,
  });

  final String field;
  final PlayerProfileDiagnosticCode code;
  final int? listIndex;

  Map<String, Object?> toJson() => <String, Object?>{
        'field': field,
        'listIndex': listIndex,
        'code': code.value,
      };
}

abstract interface class PlayerProfileRawSourceReader {
  Future<PlayerProfileRawSource?> readPlayerProfileRawSource(
      int legacyPlayerId);

  Future<PlayerProfileRawSource?> readActivePlayerProfileRawSource();
}

abstract interface class PlayerProfileCompatibilityReadPort {
  Future<PlayerProfileCompatibilityResult> readByLegacyPlayerId(
    int legacyPlayerId,
  );

  Future<PlayerProfileCompatibilityResult?> readActivePlayer();

  CanonicalPlayerProfileSnapshot decodeSnapshot(String rawJson);

  PlayerProfileRepresentations adaptSnapshot(
    CanonicalPlayerProfileSnapshot snapshot,
  );
}

final class PlayerProfileRawSource {
  const PlayerProfileRawSource({
    required this.sourceSchemaVersion,
    required this.legacyPlayerId,
    required this.nameRaw,
    required this.dominantHandRaw,
    required this.languageRaw,
    required this.measurementSystemRaw,
    required this.themeRaw,
    required this.avatarPathRaw,
    required this.ageRaw,
    required this.genderRaw,
    required this.clubRegionRaw,
    required this.rankRaw,
    required this.mainGameRaw,
    required this.goalRaw,
    required this.playStylesRawJson,
    required this.trainingGoalsRawJson,
    required this.startedPlayingAtStorageValue,
    required this.hasCompetedStorageValue,
    required this.hoursPerWeekRaw,
    required this.createdAtStorageValue,
    required this.updatedAtStorageValue,
  });

  final int sourceSchemaVersion;
  final int legacyPlayerId;
  final String nameRaw;
  final String dominantHandRaw;
  final String languageRaw;
  final String measurementSystemRaw;
  final String themeRaw;
  final String? avatarPathRaw;
  final int? ageRaw;
  final String? genderRaw;
  final String? clubRegionRaw;
  final String? rankRaw;
  final String? mainGameRaw;
  final String? goalRaw;
  final String playStylesRawJson;
  final String trainingGoalsRawJson;
  final int? startedPlayingAtStorageValue;
  final int hasCompetedStorageValue;
  final int? hoursPerWeekRaw;
  final int createdAtStorageValue;
  final int updatedAtStorageValue;

  String get sourceReference => 'player:$legacyPlayerId';

  Map<String, Object?> toDigestPayload() => <String, Object?>{
        'schemaVersion': playerProfileCompatibilitySchemaVersion,
        'adapterPolicyVersion': playerProfileAdapterPolicyVersion,
        'sourceKind': playerProfileSourceKind,
        'sourceReference': sourceReference,
        'sourceSchemaVersion': sourceSchemaVersion,
        'legacyPlayerId': legacyPlayerId,
        'nameRaw': nameRaw,
        'dominantHandRaw': dominantHandRaw,
        'languageRaw': languageRaw,
        'measurementSystemRaw': measurementSystemRaw,
        'themeRaw': themeRaw,
        'avatarPathRaw': avatarPathRaw,
        'ageRaw': ageRaw,
        'genderRaw': genderRaw,
        'clubRegionRaw': clubRegionRaw,
        'rankRaw': rankRaw,
        'mainGameRaw': mainGameRaw,
        'goalRaw': goalRaw,
        'playStylesRawJson': playStylesRawJson,
        'trainingGoalsRawJson': trainingGoalsRawJson,
        'startedPlayingAtStorageValue': startedPlayingAtStorageValue,
        'hasCompetedStorageValue': hasCompetedStorageValue,
        'hoursPerWeekRaw': hoursPerWeekRaw,
        'createdAtStorageValue': createdAtStorageValue,
        'updatedAtStorageValue': updatedAtStorageValue,
      };
}

final class PlayerProfileSourceAssessment {
  PlayerProfileSourceAssessment._({
    required this.source,
    required List<PlayerProfileDiagnostic> diagnostics,
  })  : rawAssessmentDigest = _digest(source.toDigestPayload()),
        diagnostics = List.unmodifiable(diagnostics);

  final PlayerProfileRawSource source;
  final String rawAssessmentDigest;
  final List<PlayerProfileDiagnostic> diagnostics;

  bool get isCompatible => diagnostics.isEmpty;

  Map<String, Object?> toJson() => <String, Object?>{
        ...source.toDigestPayload(),
        'rawAssessmentDigest': rawAssessmentDigest,
        'diagnostics': diagnostics.map((item) => item.toJson()).toList(),
      };

  String toJsonString() => jsonEncode(toJson());
}

final class CanonicalPlayerProfileSnapshot {
  CanonicalPlayerProfileSnapshot._({
    required this.sourceReference,
    required this.sourceSchemaVersion,
    required this.legacyPlayerId,
    required this.canonicalPlayerId,
    required this.sourceCreatedAt,
    required this.sourceUpdatedAt,
    required this.name,
    required this.dominantHand,
    required this.locale,
    required this.measurementSystem,
    required this.theme,
    required this.avatarPath,
    required this.age,
    required this.gender,
    required this.clubRegion,
    required this.rank,
    required this.mainGame,
    required this.goal,
    required List<String> playStyles,
    required List<String> trainingGoals,
    required this.startedPlayingOn,
    required this.hasCompeted,
    required this.hoursPerWeek,
    String? expectedSourceDigest,
    String? expectedDigest,
  })  : playStyles = List.unmodifiable(playStyles),
        trainingGoals = List.unmodifiable(trainingGoals) {
    sourceDigest = _digest(_sourcePayload());
    digest = _digest(_snapshotPayload());
    if (expectedSourceDigest != null && sourceDigest != expectedSourceDigest) {
      throw const PlayerProfileException(
        PlayerProfileFailureCode.snapshotProvenanceMismatch,
      );
    }
    if (expectedDigest != null && digest != expectedDigest) {
      throw const PlayerProfileException(
        PlayerProfileFailureCode.snapshotDigestMismatch,
      );
    }
  }

  final String sourceReference;
  final int sourceSchemaVersion;
  final int legacyPlayerId;
  final String canonicalPlayerId;
  final String sourceCreatedAt;
  final String sourceUpdatedAt;
  final String name;
  final String dominantHand;
  final String locale;
  final String measurementSystem;
  final String theme;
  final String? avatarPath;
  final int? age;
  final String? gender;
  final String? clubRegion;
  final String? rank;
  final String? mainGame;
  final String? goal;
  final List<String> playStyles;
  final List<String> trainingGoals;
  final String? startedPlayingOn;
  final bool hasCompeted;
  final int? hoursPerWeek;
  late final String sourceDigest;
  late final String digest;

  Map<String, Object?> _sourcePayload() => <String, Object?>{
        'schemaVersion': playerProfileCompatibilitySchemaVersion,
        'adapterPolicyVersion': playerProfileAdapterPolicyVersion,
        'sourceKind': playerProfileSourceKind,
        'sourceReference': sourceReference,
        'sourceSchemaVersion': sourceSchemaVersion,
        'legacyPlayerId': legacyPlayerId,
        'canonicalPlayerId': canonicalPlayerId,
        'sourceCreatedAt': sourceCreatedAt,
        'sourceUpdatedAt': sourceUpdatedAt,
        'name': name,
        'dominantHand': dominantHand,
        'locale': locale,
        'measurementSystem': measurementSystem,
        'theme': theme,
        'avatarPath': avatarPath,
        'age': age,
        'gender': gender,
        'clubRegion': clubRegion,
        'rank': rank,
        'mainGame': mainGame,
        'goal': goal,
        'playStyles': playStyles,
        'trainingGoals': trainingGoals,
        'startedPlayingOn': startedPlayingOn,
        'hasCompeted': hasCompeted,
        'hoursPerWeek': hoursPerWeek,
      };

  Map<String, Object?> _snapshotPayload() => <String, Object?>{
        ..._sourcePayload(),
        'compatibilityStatus': 'compatible',
        'diagnostics': const <Object?>[],
        'sourceDigest': sourceDigest,
      };

  Map<String, Object?> toJson() => <String, Object?>{
        ..._snapshotPayload(),
        'digest': digest,
      };

  String toJsonString() => jsonEncode(toJson());
}

final class PlayerProfileCompatibilityResult {
  const PlayerProfileCompatibilityResult({
    required this.assessment,
    required this.snapshot,
    required this.foundationProfile,
    required this.contract,
  });

  final PlayerProfileSourceAssessment assessment;
  final CanonicalPlayerProfileSnapshot? snapshot;
  final PlayerProfile? foundationProfile;
  final PlayerProfileContract? contract;

  bool get isCompatible => snapshot != null;
}

final class PlayerProfileRepresentations {
  const PlayerProfileRepresentations({
    required this.foundationProfile,
    required this.contract,
  });

  final PlayerProfile foundationProfile;
  final PlayerProfileContract contract;
}

final class PlayerProfileCompatibilityAdapter {
  const PlayerProfileCompatibilityAdapter();

  PlayerProfileCompatibilityResult adapt(PlayerProfileRawSource source) {
    final diagnostics = <_SortableDiagnostic>[];
    final normalized = _NormalizedProfile();

    if (!_isCanonicalLegacyId(source.legacyPlayerId)) {
      _add(diagnostics, 'legacyPlayerId',
          PlayerProfileDiagnosticCode.invalidPlayerId);
    }
    if (source.sourceSchemaVersion <= 0) {
      _add(diagnostics, 'sourceSchemaVersion',
          PlayerProfileDiagnosticCode.codeUnsupported);
    }

    _validateRequiredName(source.nameRaw, diagnostics);
    _validateRequiredCode(
      field: 'dominantHandRaw',
      value: source.dominantHandRaw,
      accepted: const {'left', 'right'},
      diagnostics: diagnostics,
    );
    _validateRequiredCode(
      field: 'languageRaw',
      value: source.languageRaw,
      accepted: const {'vi', 'en', 'vietnamese', 'english'},
      diagnostics: diagnostics,
    );
    _validateRequiredCode(
      field: 'measurementSystemRaw',
      value: source.measurementSystemRaw,
      accepted: const {'cm', 'in', 'inch', 'metric'},
      diagnostics: diagnostics,
    );
    _validateRequiredCode(
      field: 'themeRaw',
      value: source.themeRaw,
      accepted: const {'system', 'light', 'dark'},
      diagnostics: diagnostics,
    );
    _validateOptionalString('avatarPathRaw', source.avatarPathRaw, diagnostics);
    _validateOptionalString('genderRaw', source.genderRaw, diagnostics);
    _validateOptionalString('clubRegionRaw', source.clubRegionRaw, diagnostics);
    _validateOptionalCode(
      field: 'rankRaw',
      value: source.rankRaw,
      accepted: const {'H', 'G', 'F', 'E', 'D', 'C', 'B', 'A'},
      diagnostics: diagnostics,
    );
    _validateOptionalCode(
      field: 'mainGameRaw',
      value: source.mainGameRaw,
      accepted: const {'9 Ball', '10 Ball', '8 Ball'},
      diagnostics: diagnostics,
    );
    _validateOptionalString('goalRaw', source.goalRaw, diagnostics);

    normalized.playStyles = _parseCodeList(
      field: 'playStylesRawJson',
      raw: source.playStylesRawJson,
      accepted: const {
        'safe',
        'attack',
        'fast',
        'steady',
        'control',
        'power_break',
      },
      diagnostics: diagnostics,
    );
    normalized.trainingGoals = _parseCodeList(
      field: 'trainingGoalsRawJson',
      raw: source.trainingGoalsRawJson,
      accepted: const {
        'rank_up',
        'break_power',
        'position',
        'jump',
        'safety',
        'tournament',
      },
      diagnostics: diagnostics,
    );

    normalized.startedPlaying = _decodeStorageDate(
      field: 'startedPlayingAtStorageValue',
      value: source.startedPlayingAtStorageValue,
      diagnostics: diagnostics,
      nullable: true,
    );
    normalized.createdAt = _decodeStorageDate(
      field: 'createdAtStorageValue',
      value: source.createdAtStorageValue,
      diagnostics: diagnostics,
    );
    normalized.updatedAt = _decodeStorageDate(
      field: 'updatedAtStorageValue',
      value: source.updatedAtStorageValue,
      diagnostics: diagnostics,
    );
    if (normalized.createdAt != null &&
        normalized.updatedAt != null &&
        normalized.updatedAt!.isBefore(normalized.createdAt!)) {
      _add(diagnostics, 'updatedAtStorageValue',
          PlayerProfileDiagnosticCode.timestampOrderInvalid);
    }
    if (source.hasCompetedStorageValue != 0 &&
        source.hasCompetedStorageValue != 1) {
      _add(diagnostics, 'hasCompetedStorageValue',
          PlayerProfileDiagnosticCode.codeUnsupported);
    }

    diagnostics.sort();
    final assessment = PlayerProfileSourceAssessment._(
      source: source,
      diagnostics: diagnostics.map((item) => item.value).toList(),
    );
    if (!assessment.isCompatible) {
      return PlayerProfileCompatibilityResult(
        assessment: assessment,
        snapshot: null,
        foundationProfile: null,
        contract: null,
      );
    }

    final canonicalId = 'entity.player:${source.legacyPlayerId}';
    final snapshot = CanonicalPlayerProfileSnapshot._(
      sourceReference: source.sourceReference,
      sourceSchemaVersion: source.sourceSchemaVersion,
      legacyPlayerId: source.legacyPlayerId,
      canonicalPlayerId: canonicalId,
      sourceCreatedAt: _canonicalInstant(normalized.createdAt!),
      sourceUpdatedAt: _canonicalInstant(normalized.updatedAt!),
      name: source.nameRaw,
      dominantHand: source.dominantHandRaw,
      locale: switch (source.languageRaw) {
        'vi' || 'vietnamese' => 'vi',
        'en' || 'english' => 'en',
        _ => throw StateError('validated language became unsupported'),
      },
      measurementSystem: source.measurementSystemRaw,
      theme: source.themeRaw,
      avatarPath: source.avatarPathRaw,
      age: source.ageRaw,
      gender: source.genderRaw,
      clubRegion: source.clubRegionRaw,
      rank: source.rankRaw,
      mainGame: source.mainGameRaw,
      goal: source.goalRaw,
      playStyles: normalized.playStyles!,
      trainingGoals: normalized.trainingGoals!,
      startedPlayingOn: normalized.startedPlaying == null
          ? null
          : _calendarDate(normalized.startedPlaying!),
      hasCompeted: source.hasCompetedStorageValue == 1,
      hoursPerWeek: source.hoursPerWeekRaw,
    );
    final representations = adaptSnapshot(snapshot);
    return PlayerProfileCompatibilityResult(
      assessment: assessment,
      snapshot: snapshot,
      foundationProfile: representations.foundationProfile,
      contract: representations.contract,
    );
  }

  PlayerProfileRepresentations adaptSnapshot(
    CanonicalPlayerProfileSnapshot snapshot,
  ) {
    final foundation = PlayerProfile(
      id: PlayerId(snapshot.legacyPlayerId.toString()),
      version: VersionNumber(playerProfileAdapterPolicyVersion),
      createdAt: UtcTimestamp(DateTime.parse(snapshot.sourceCreatedAt)),
      displayName: NonEmptyString(snapshot.name),
      lifecycleState: NonEmptyString('available'),
    );
    final preferences = <String>[
      ...snapshot.playStyles.map((item) => 'play-style:$item'),
      ...snapshot.trainingGoals.map((item) => 'training-goal:$item'),
    ]..sort();
    final contract = PlayerProfileContract(
      playerId: snapshot.canonicalPlayerId,
      dominantHand: snapshot.dominantHand,
      locale: snapshot.locale,
      preferences: preferences,
      historyReferences: const [],
    );
    _validateRepresentationIdentity(snapshot, foundation, contract);
    return PlayerProfileRepresentations(
      foundationProfile: foundation,
      contract: contract,
    );
  }

  int parseCanonicalPlayerId(String value) {
    const prefix = 'entity.player:';
    if (!value.startsWith(prefix)) {
      throw const PlayerProfileException(
        PlayerProfileFailureCode.snapshotIdentityInvalid,
      );
    }
    final raw = value.substring(prefix.length);
    if (!RegExp(r'^[1-9][0-9]*$').hasMatch(raw)) {
      throw const PlayerProfileException(
        PlayerProfileFailureCode.snapshotIdentityInvalid,
      );
    }
    final parsed = int.tryParse(raw);
    if (parsed == null || !_isCanonicalLegacyId(parsed)) {
      throw const PlayerProfileException(
        PlayerProfileFailureCode.snapshotIdentityInvalid,
      );
    }
    if ('entity.player:$parsed' != value) {
      throw const PlayerProfileException(
        PlayerProfileFailureCode.snapshotIdentityInvalid,
      );
    }
    return parsed;
  }

  CanonicalPlayerProfileSnapshot decodeSnapshot(String rawJson) {
    Object? decoded;
    try {
      decoded = jsonDecode(rawJson);
    } on FormatException catch (error) {
      throw PlayerProfileException(
        PlayerProfileFailureCode.snapshotJsonInvalid,
        cause: error,
      );
    }
    if (decoded is! Map<String, dynamic>) {
      throw const PlayerProfileException(
        PlayerProfileFailureCode.snapshotShapeInvalid,
      );
    }
    final map = decoded;
    if (!_hasExactSnapshotShape(map)) {
      throw const PlayerProfileException(
        PlayerProfileFailureCode.snapshotShapeInvalid,
      );
    }
    if (map['schemaVersion'] != playerProfileCompatibilitySchemaVersion ||
        map['adapterPolicyVersion'] != playerProfileAdapterPolicyVersion) {
      throw const PlayerProfileException(
        PlayerProfileFailureCode.snapshotVersionUnsupported,
      );
    }

    final legacyId = map['legacyPlayerId']! as int;
    final canonicalId = map['canonicalPlayerId']! as String;
    final parsedId = parseCanonicalPlayerId(canonicalId);
    if (parsedId != legacyId || map['sourceReference'] != 'player:$legacyId') {
      throw const PlayerProfileException(
        PlayerProfileFailureCode.snapshotIdentityInvalid,
      );
    }

    final sourceCreatedAt = map['sourceCreatedAt']! as String;
    final sourceUpdatedAt = map['sourceUpdatedAt']! as String;
    final playStyles = List<String>.from(map['playStyles']! as List);
    final trainingGoals = List<String>.from(map['trainingGoals']! as List);
    if (!_isCanonicalInstant(sourceCreatedAt) ||
        !_isCanonicalInstant(sourceUpdatedAt) ||
        DateTime.parse(sourceUpdatedAt)
            .isBefore(DateTime.parse(sourceCreatedAt)) ||
        !_isSortedUnique(playStyles) ||
        !_isSortedUnique(trainingGoals) ||
        !_validCanonicalCodes(map, playStyles, trainingGoals)) {
      throw const PlayerProfileException(
        PlayerProfileFailureCode.snapshotProvenanceMismatch,
      );
    }
    final startedPlayingOn = map['startedPlayingOn'] as String?;
    if (startedPlayingOn != null &&
        !_isCanonicalCalendarDate(startedPlayingOn)) {
      throw const PlayerProfileException(
        PlayerProfileFailureCode.snapshotProvenanceMismatch,
      );
    }

    return CanonicalPlayerProfileSnapshot._(
      sourceReference: map['sourceReference']! as String,
      sourceSchemaVersion: map['sourceSchemaVersion']! as int,
      legacyPlayerId: legacyId,
      canonicalPlayerId: canonicalId,
      sourceCreatedAt: sourceCreatedAt,
      sourceUpdatedAt: sourceUpdatedAt,
      name: map['name']! as String,
      dominantHand: map['dominantHand']! as String,
      locale: map['locale']! as String,
      measurementSystem: map['measurementSystem']! as String,
      theme: map['theme']! as String,
      avatarPath: map['avatarPath'] as String?,
      age: map['age'] as int?,
      gender: map['gender'] as String?,
      clubRegion: map['clubRegion'] as String?,
      rank: map['rank'] as String?,
      mainGame: map['mainGame'] as String?,
      goal: map['goal'] as String?,
      playStyles: playStyles,
      trainingGoals: trainingGoals,
      startedPlayingOn: startedPlayingOn,
      hasCompeted: map['hasCompeted']! as bool,
      hoursPerWeek: map['hoursPerWeek'] as int?,
      expectedSourceDigest: map['sourceDigest']! as String,
      expectedDigest: map['digest']! as String,
    );
  }

  bool _hasExactSnapshotShape(Map<String, dynamic> map) {
    if (!_sameKeysInOrder(map.keys, _snapshotKeys)) return false;
    return map['schemaVersion'] is int &&
        map['adapterPolicyVersion'] is int &&
        map['sourceKind'] is String &&
        map['sourceReference'] is String &&
        map['sourceSchemaVersion'] is int &&
        map['legacyPlayerId'] is int &&
        map['canonicalPlayerId'] is String &&
        map['sourceCreatedAt'] is String &&
        map['sourceUpdatedAt'] is String &&
        map['name'] is String &&
        map['dominantHand'] is String &&
        map['locale'] is String &&
        map['measurementSystem'] is String &&
        map['theme'] is String &&
        _isNullable<String>(map['avatarPath']) &&
        _isNullable<int>(map['age']) &&
        _isNullable<String>(map['gender']) &&
        _isNullable<String>(map['clubRegion']) &&
        _isNullable<String>(map['rank']) &&
        _isNullable<String>(map['mainGame']) &&
        _isNullable<String>(map['goal']) &&
        _isStringList(map['playStyles']) &&
        _isStringList(map['trainingGoals']) &&
        _isNullable<String>(map['startedPlayingOn']) &&
        map['hasCompeted'] is bool &&
        _isNullable<int>(map['hoursPerWeek']) &&
        map['compatibilityStatus'] is String &&
        map['diagnostics'] is List &&
        map['sourceDigest'] is String &&
        map['digest'] is String;
  }
}

final class _NormalizedProfile {
  List<String>? playStyles;
  List<String>? trainingGoals;
  DateTime? startedPlaying;
  DateTime? createdAt;
  DateTime? updatedAt;
}

final class _SortableDiagnostic implements Comparable<_SortableDiagnostic> {
  const _SortableDiagnostic(this.fieldOrder, this.value);

  final int fieldOrder;
  final PlayerProfileDiagnostic value;

  @override
  int compareTo(_SortableDiagnostic other) {
    final fieldComparison = fieldOrder.compareTo(other.fieldOrder);
    if (fieldComparison != 0) return fieldComparison;
    final indexComparison =
        (value.listIndex ?? -1).compareTo(other.value.listIndex ?? -1);
    if (indexComparison != 0) return indexComparison;
    return value.code.value.compareTo(other.value.code.value);
  }
}

const _fieldOrder = <String>[
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

void _add(
  List<_SortableDiagnostic> target,
  String field,
  PlayerProfileDiagnosticCode code, {
  int? listIndex,
}) {
  target.add(
    _SortableDiagnostic(
      _fieldOrder.indexOf(field),
      PlayerProfileDiagnostic(field: field, code: code, listIndex: listIndex),
    ),
  );
}

void _validateRequiredName(
  String value,
  List<_SortableDiagnostic> diagnostics,
) {
  if (value.isEmpty) {
    _add(diagnostics, 'nameRaw', PlayerProfileDiagnosticCode.requiredEmpty);
  } else if (value.trim() != value) {
    _add(diagnostics, 'nameRaw',
        PlayerProfileDiagnosticCode.requiredOuterWhitespace);
  }
  if (value.contains('\u0000')) {
    _add(diagnostics, 'nameRaw', PlayerProfileDiagnosticCode.nullByte);
  }
}

void _validateRequiredCode({
  required String field,
  required String value,
  required Set<String> accepted,
  required List<_SortableDiagnostic> diagnostics,
}) {
  if (value.isEmpty) {
    _add(diagnostics, field, PlayerProfileDiagnosticCode.requiredEmpty);
  }
  if (value.contains('\u0000')) {
    _add(diagnostics, field, PlayerProfileDiagnosticCode.nullByte);
  }
  if (!accepted.contains(value)) {
    _add(diagnostics, field, PlayerProfileDiagnosticCode.codeUnsupported);
  }
}

void _validateOptionalString(
  String field,
  String? value,
  List<_SortableDiagnostic> diagnostics,
) {
  if (value != null && value.contains('\u0000')) {
    _add(diagnostics, field, PlayerProfileDiagnosticCode.nullByte);
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
    _add(diagnostics, field, PlayerProfileDiagnosticCode.codeUnsupported);
  }
}

List<String>? _parseCodeList({
  required String field,
  required String raw,
  required Set<String> accepted,
  required List<_SortableDiagnostic> diagnostics,
}) {
  Object? decoded;
  try {
    decoded = jsonDecode(raw);
  } on FormatException {
    _add(diagnostics, field, PlayerProfileDiagnosticCode.listJsonInvalid);
    return null;
  }
  if (decoded is! List) {
    _add(diagnostics, field, PlayerProfileDiagnosticCode.listNotArray);
    return null;
  }
  final result = <String>[];
  final seen = <String>{};
  for (var index = 0; index < decoded.length; index++) {
    final item = decoded[index];
    if (item is! String) {
      _add(
        diagnostics,
        field,
        PlayerProfileDiagnosticCode.listItemNotString,
        listIndex: index,
      );
      continue;
    }
    final normalized = item.trim();
    if (normalized.isEmpty) {
      _add(
        diagnostics,
        field,
        PlayerProfileDiagnosticCode.listItemEmpty,
        listIndex: index,
      );
      continue;
    }
    if (!seen.add(normalized)) {
      _add(
        diagnostics,
        field,
        PlayerProfileDiagnosticCode.listItemDuplicate,
        listIndex: index,
      );
      continue;
    }
    if (!accepted.contains(normalized)) {
      _add(
        diagnostics,
        field,
        PlayerProfileDiagnosticCode.codeUnsupported,
        listIndex: index,
      );
      continue;
    }
    result.add(normalized);
  }
  result.sort();
  return result;
}

DateTime? _decodeStorageDate({
  required String field,
  required int? value,
  required List<_SortableDiagnostic> diagnostics,
  bool nullable = false,
}) {
  if (value == null) {
    if (!nullable) {
      _add(diagnostics, field, PlayerProfileDiagnosticCode.timestampInvalid);
    }
    return null;
  }
  if (value < -_maximumDateTimeStorageSeconds ||
      value > _maximumDateTimeStorageSeconds) {
    _add(diagnostics, field, PlayerProfileDiagnosticCode.timestampInvalid);
    return null;
  }
  try {
    return DateTime.fromMillisecondsSinceEpoch(value * 1000);
  } on RangeError {
    _add(diagnostics, field, PlayerProfileDiagnosticCode.timestampInvalid);
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

String _calendarDate(DateTime value) {
  String two(int part) => part.toString().padLeft(2, '0');
  return '${value.year.toString().padLeft(4, '0')}-'
      '${two(value.month)}-${two(value.day)}';
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

bool _isCanonicalLegacyId(int value) =>
    value > 0 && value <= sqliteMaximumInteger;

bool _sameKeysInOrder(Iterable<String> actual, List<String> expected) {
  final keys = actual.toList(growable: false);
  if (keys.length != expected.length) return false;
  for (var index = 0; index < expected.length; index++) {
    if (keys[index] != expected[index]) return false;
  }
  return true;
}

bool _isNullable<T>(Object? value) => value == null || value is T;

bool _isStringList(Object? value) =>
    value is List && value.every((item) => item is String);

bool _isSortedUnique(List<String> values) {
  final sorted = [...values]..sort();
  return values.length == values.toSet().length &&
      List.generate(values.length, (index) => values[index] == sorted[index])
          .every((item) => item);
}

bool _validCanonicalCodes(
  Map<String, dynamic> map,
  List<String> playStyles,
  List<String> trainingGoals,
) {
  return map['sourceKind'] == playerProfileSourceKind &&
      (map['sourceSchemaVersion']! as int) > 0 &&
      (map['name']! as String).isNotEmpty &&
      (map['name']! as String).trim() == map['name'] &&
      !(map['name']! as String).contains('\u0000') &&
      [
        map['avatarPath'],
        map['gender'],
        map['clubRegion'],
        map['goal'],
      ].whereType<String>().every((value) => !value.contains('\u0000')) &&
      const {'left', 'right'}.contains(map['dominantHand']) &&
      const {'vi', 'en'}.contains(map['locale']) &&
      const {'cm', 'in', 'inch', 'metric'}.contains(map['measurementSystem']) &&
      const {'system', 'light', 'dark'}.contains(map['theme']) &&
      (map['rank'] == null ||
          const {'H', 'G', 'F', 'E', 'D', 'C', 'B', 'A'}
              .contains(map['rank'])) &&
      (map['mainGame'] == null ||
          const {'9 Ball', '10 Ball', '8 Ball'}.contains(map['mainGame'])) &&
      playStyles.every(const {
        'safe',
        'attack',
        'fast',
        'steady',
        'control',
        'power_break',
      }.contains) &&
      trainingGoals.every(const {
        'rank_up',
        'break_power',
        'position',
        'jump',
        'safety',
        'tournament',
      }.contains) &&
      map['compatibilityStatus'] == 'compatible' &&
      (map['diagnostics']! as List).isEmpty;
}

bool _isCanonicalCalendarDate(String value) {
  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) return false;
  final parts = value.split('-').map(int.parse).toList(growable: false);
  final parsed = DateTime.utc(parts[0], parts[1], parts[2]);
  return _calendarDate(parsed) == value;
}

void _validateRepresentationIdentity(
  CanonicalPlayerProfileSnapshot snapshot,
  PlayerProfile foundation,
  PlayerProfileContract contract,
) {
  final expected = snapshot.canonicalPlayerId;
  if (foundation.id.canonical != expected || contract.playerId != expected) {
    throw const PlayerProfileException(
      PlayerProfileFailureCode.snapshotIdentityInvalid,
    );
  }
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
