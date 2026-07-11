// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PlayersTable extends Players with TableInfo<$PlayersTable, Player> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dominantHandMeta =
      const VerificationMeta('dominantHand');
  @override
  late final GeneratedColumn<String> dominantHand = GeneratedColumn<String>(
      'dominant_hand', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: Constant(AppConstants.defaultDominantHand.name));
  static const VerificationMeta _languageMeta =
      const VerificationMeta('language');
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
      'language', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: Constant(AppConstants.defaultLanguage.name));
  static const VerificationMeta _measurementSystemMeta =
      const VerificationMeta('measurementSystem');
  @override
  late final GeneratedColumn<String> measurementSystem =
      GeneratedColumn<String>('measurement_system', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: Constant(AppConstants.defaultMeasurementSystem.name));
  static const VerificationMeta _themeMeta = const VerificationMeta('theme');
  @override
  late final GeneratedColumn<String> theme = GeneratedColumn<String>(
      'theme', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(AppConstants.themeDark));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        dominantHand,
        language,
        measurementSystem,
        theme,
        isActive,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'players';
  @override
  VerificationContext validateIntegrity(Insertable<Player> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('dominant_hand')) {
      context.handle(
          _dominantHandMeta,
          dominantHand.isAcceptableOrUnknown(
              data['dominant_hand']!, _dominantHandMeta));
    }
    if (data.containsKey('language')) {
      context.handle(_languageMeta,
          language.isAcceptableOrUnknown(data['language']!, _languageMeta));
    }
    if (data.containsKey('measurement_system')) {
      context.handle(
          _measurementSystemMeta,
          measurementSystem.isAcceptableOrUnknown(
              data['measurement_system']!, _measurementSystemMeta));
    }
    if (data.containsKey('theme')) {
      context.handle(
          _themeMeta, theme.isAcceptableOrUnknown(data['theme']!, _themeMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Player map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Player(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      dominantHand: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dominant_hand'])!,
      language: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}language'])!,
      measurementSystem: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}measurement_system'])!,
      theme: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}theme'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $PlayersTable createAlias(String alias) {
    return $PlayersTable(attachedDatabase, alias);
  }
}

class Player extends DataClass implements Insertable<Player> {
  final int id;
  final String name;
  final String dominantHand;
  final String language;
  final String measurementSystem;
  final String theme;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Player(
      {required this.id,
      required this.name,
      required this.dominantHand,
      required this.language,
      required this.measurementSystem,
      required this.theme,
      required this.isActive,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['dominant_hand'] = Variable<String>(dominantHand);
    map['language'] = Variable<String>(language);
    map['measurement_system'] = Variable<String>(measurementSystem);
    map['theme'] = Variable<String>(theme);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PlayersCompanion toCompanion(bool nullToAbsent) {
    return PlayersCompanion(
      id: Value(id),
      name: Value(name),
      dominantHand: Value(dominantHand),
      language: Value(language),
      measurementSystem: Value(measurementSystem),
      theme: Value(theme),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Player.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Player(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      dominantHand: serializer.fromJson<String>(json['dominantHand']),
      language: serializer.fromJson<String>(json['language']),
      measurementSystem: serializer.fromJson<String>(json['measurementSystem']),
      theme: serializer.fromJson<String>(json['theme']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'dominantHand': serializer.toJson<String>(dominantHand),
      'language': serializer.toJson<String>(language),
      'measurementSystem': serializer.toJson<String>(measurementSystem),
      'theme': serializer.toJson<String>(theme),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Player copyWith(
          {int? id,
          String? name,
          String? dominantHand,
          String? language,
          String? measurementSystem,
          String? theme,
          bool? isActive,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Player(
        id: id ?? this.id,
        name: name ?? this.name,
        dominantHand: dominantHand ?? this.dominantHand,
        language: language ?? this.language,
        measurementSystem: measurementSystem ?? this.measurementSystem,
        theme: theme ?? this.theme,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Player copyWithCompanion(PlayersCompanion data) {
    return Player(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      dominantHand: data.dominantHand.present
          ? data.dominantHand.value
          : this.dominantHand,
      language: data.language.present ? data.language.value : this.language,
      measurementSystem: data.measurementSystem.present
          ? data.measurementSystem.value
          : this.measurementSystem,
      theme: data.theme.present ? data.theme.value : this.theme,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Player(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('dominantHand: $dominantHand, ')
          ..write('language: $language, ')
          ..write('measurementSystem: $measurementSystem, ')
          ..write('theme: $theme, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, dominantHand, language,
      measurementSystem, theme, isActive, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Player &&
          other.id == this.id &&
          other.name == this.name &&
          other.dominantHand == this.dominantHand &&
          other.language == this.language &&
          other.measurementSystem == this.measurementSystem &&
          other.theme == this.theme &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PlayersCompanion extends UpdateCompanion<Player> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> dominantHand;
  final Value<String> language;
  final Value<String> measurementSystem;
  final Value<String> theme;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const PlayersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.dominantHand = const Value.absent(),
    this.language = const Value.absent(),
    this.measurementSystem = const Value.absent(),
    this.theme = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PlayersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.dominantHand = const Value.absent(),
    this.language = const Value.absent(),
    this.measurementSystem = const Value.absent(),
    this.theme = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Player> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? dominantHand,
    Expression<String>? language,
    Expression<String>? measurementSystem,
    Expression<String>? theme,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (dominantHand != null) 'dominant_hand': dominantHand,
      if (language != null) 'language': language,
      if (measurementSystem != null) 'measurement_system': measurementSystem,
      if (theme != null) 'theme': theme,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  PlayersCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? dominantHand,
      Value<String>? language,
      Value<String>? measurementSystem,
      Value<String>? theme,
      Value<bool>? isActive,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return PlayersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      dominantHand: dominantHand ?? this.dominantHand,
      language: language ?? this.language,
      measurementSystem: measurementSystem ?? this.measurementSystem,
      theme: theme ?? this.theme,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (dominantHand.present) {
      map['dominant_hand'] = Variable<String>(dominantHand.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (measurementSystem.present) {
      map['measurement_system'] = Variable<String>(measurementSystem.value);
    }
    if (theme.present) {
      map['theme'] = Variable<String>(theme.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('dominantHand: $dominantHand, ')
          ..write('language: $language, ')
          ..write('measurementSystem: $measurementSystem, ')
          ..write('theme: $theme, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CuesTable extends Cues with TableInfo<$CuesTable, Cue> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _playerIdMeta =
      const VerificationMeta('playerId');
  @override
  late final GeneratedColumn<int> playerId = GeneratedColumn<int>(
      'player_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _shaftMeta = const VerificationMeta('shaft');
  @override
  late final GeneratedColumn<String> shaft = GeneratedColumn<String>(
      'shaft', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tipMeta = const VerificationMeta('tip');
  @override
  late final GeneratedColumn<String> tip = GeneratedColumn<String>(
      'tip', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _shaftMaterialMeta =
      const VerificationMeta('shaftMaterial');
  @override
  late final GeneratedColumn<String> shaftMaterial = GeneratedColumn<String>(
      'shaft_material', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _shaftDiameterMeta =
      const VerificationMeta('shaftDiameter');
  @override
  late final GeneratedColumn<double> shaftDiameter = GeneratedColumn<double>(
      'shaft_diameter', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _tipBrandMeta =
      const VerificationMeta('tipBrand');
  @override
  late final GeneratedColumn<String> tipBrand = GeneratedColumn<String>(
      'tip_brand', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tipHardnessMeta =
      const VerificationMeta('tipHardness');
  @override
  late final GeneratedColumn<String> tipHardness = GeneratedColumn<String>(
      'tip_hardness', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tipSizeMeta =
      const VerificationMeta('tipSize');
  @override
  late final GeneratedColumn<double> tipSize = GeneratedColumn<double>(
      'tip_size', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _cueTypeMeta =
      const VerificationMeta('cueType');
  @override
  late final GeneratedColumn<String> cueType = GeneratedColumn<String>(
      'cue_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('playing'));
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
      'weight', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _balanceMeta =
      const VerificationMeta('balance');
  @override
  late final GeneratedColumn<String> balance = GeneratedColumn<String>(
      'balance', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _jointMeta = const VerificationMeta('joint');
  @override
  late final GeneratedColumn<String> joint = GeneratedColumn<String>(
      'joint', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _isBreakCueMeta =
      const VerificationMeta('isBreakCue');
  @override
  late final GeneratedColumn<bool> isBreakCue = GeneratedColumn<bool>(
      'is_break_cue', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_break_cue" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        playerId,
        name,
        shaft,
        tip,
        shaftMaterial,
        shaftDiameter,
        tipBrand,
        tipHardness,
        tipSize,
        cueType,
        weight,
        balance,
        joint,
        isActive,
        isBreakCue,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cues';
  @override
  VerificationContext validateIntegrity(Insertable<Cue> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('player_id')) {
      context.handle(_playerIdMeta,
          playerId.isAcceptableOrUnknown(data['player_id']!, _playerIdMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('shaft')) {
      context.handle(
          _shaftMeta, shaft.isAcceptableOrUnknown(data['shaft']!, _shaftMeta));
    } else if (isInserting) {
      context.missing(_shaftMeta);
    }
    if (data.containsKey('tip')) {
      context.handle(
          _tipMeta, tip.isAcceptableOrUnknown(data['tip']!, _tipMeta));
    } else if (isInserting) {
      context.missing(_tipMeta);
    }
    if (data.containsKey('shaft_material')) {
      context.handle(
          _shaftMaterialMeta,
          shaftMaterial.isAcceptableOrUnknown(
              data['shaft_material']!, _shaftMaterialMeta));
    } else if (isInserting) {
      context.missing(_shaftMaterialMeta);
    }
    if (data.containsKey('shaft_diameter')) {
      context.handle(
          _shaftDiameterMeta,
          shaftDiameter.isAcceptableOrUnknown(
              data['shaft_diameter']!, _shaftDiameterMeta));
    } else if (isInserting) {
      context.missing(_shaftDiameterMeta);
    }
    if (data.containsKey('tip_brand')) {
      context.handle(_tipBrandMeta,
          tipBrand.isAcceptableOrUnknown(data['tip_brand']!, _tipBrandMeta));
    } else if (isInserting) {
      context.missing(_tipBrandMeta);
    }
    if (data.containsKey('tip_hardness')) {
      context.handle(
          _tipHardnessMeta,
          tipHardness.isAcceptableOrUnknown(
              data['tip_hardness']!, _tipHardnessMeta));
    } else if (isInserting) {
      context.missing(_tipHardnessMeta);
    }
    if (data.containsKey('tip_size')) {
      context.handle(_tipSizeMeta,
          tipSize.isAcceptableOrUnknown(data['tip_size']!, _tipSizeMeta));
    }
    if (data.containsKey('cue_type')) {
      context.handle(_cueTypeMeta,
          cueType.isAcceptableOrUnknown(data['cue_type']!, _cueTypeMeta));
    }
    if (data.containsKey('weight')) {
      context.handle(_weightMeta,
          weight.isAcceptableOrUnknown(data['weight']!, _weightMeta));
    } else if (isInserting) {
      context.missing(_weightMeta);
    }
    if (data.containsKey('balance')) {
      context.handle(_balanceMeta,
          balance.isAcceptableOrUnknown(data['balance']!, _balanceMeta));
    } else if (isInserting) {
      context.missing(_balanceMeta);
    }
    if (data.containsKey('joint')) {
      context.handle(
          _jointMeta, joint.isAcceptableOrUnknown(data['joint']!, _jointMeta));
    } else if (isInserting) {
      context.missing(_jointMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('is_break_cue')) {
      context.handle(
          _isBreakCueMeta,
          isBreakCue.isAcceptableOrUnknown(
              data['is_break_cue']!, _isBreakCueMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Cue map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Cue(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      playerId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}player_id']),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      shaft: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}shaft'])!,
      tip: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tip'])!,
      shaftMaterial: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}shaft_material'])!,
      shaftDiameter: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}shaft_diameter'])!,
      tipBrand: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tip_brand'])!,
      tipHardness: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tip_hardness'])!,
      tipSize: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}tip_size']),
      cueType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cue_type'])!,
      weight: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight'])!,
      balance: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}balance'])!,
      joint: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}joint'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      isBreakCue: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_break_cue'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CuesTable createAlias(String alias) {
    return $CuesTable(attachedDatabase, alias);
  }
}

class Cue extends DataClass implements Insertable<Cue> {
  final int id;
  final int? playerId;
  final String name;
  final String shaft;
  final String tip;
  final String shaftMaterial;
  final double shaftDiameter;
  final String tipBrand;
  final String tipHardness;
  final double? tipSize;
  final String cueType;
  final double weight;
  final String balance;
  final String joint;
  final bool isActive;
  final bool isBreakCue;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Cue(
      {required this.id,
      this.playerId,
      required this.name,
      required this.shaft,
      required this.tip,
      required this.shaftMaterial,
      required this.shaftDiameter,
      required this.tipBrand,
      required this.tipHardness,
      this.tipSize,
      required this.cueType,
      required this.weight,
      required this.balance,
      required this.joint,
      required this.isActive,
      required this.isBreakCue,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || playerId != null) {
      map['player_id'] = Variable<int>(playerId);
    }
    map['name'] = Variable<String>(name);
    map['shaft'] = Variable<String>(shaft);
    map['tip'] = Variable<String>(tip);
    map['shaft_material'] = Variable<String>(shaftMaterial);
    map['shaft_diameter'] = Variable<double>(shaftDiameter);
    map['tip_brand'] = Variable<String>(tipBrand);
    map['tip_hardness'] = Variable<String>(tipHardness);
    if (!nullToAbsent || tipSize != null) {
      map['tip_size'] = Variable<double>(tipSize);
    }
    map['cue_type'] = Variable<String>(cueType);
    map['weight'] = Variable<double>(weight);
    map['balance'] = Variable<String>(balance);
    map['joint'] = Variable<String>(joint);
    map['is_active'] = Variable<bool>(isActive);
    map['is_break_cue'] = Variable<bool>(isBreakCue);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CuesCompanion toCompanion(bool nullToAbsent) {
    return CuesCompanion(
      id: Value(id),
      playerId: playerId == null && nullToAbsent
          ? const Value.absent()
          : Value(playerId),
      name: Value(name),
      shaft: Value(shaft),
      tip: Value(tip),
      shaftMaterial: Value(shaftMaterial),
      shaftDiameter: Value(shaftDiameter),
      tipBrand: Value(tipBrand),
      tipHardness: Value(tipHardness),
      tipSize: tipSize == null && nullToAbsent
          ? const Value.absent()
          : Value(tipSize),
      cueType: Value(cueType),
      weight: Value(weight),
      balance: Value(balance),
      joint: Value(joint),
      isActive: Value(isActive),
      isBreakCue: Value(isBreakCue),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Cue.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Cue(
      id: serializer.fromJson<int>(json['id']),
      playerId: serializer.fromJson<int?>(json['playerId']),
      name: serializer.fromJson<String>(json['name']),
      shaft: serializer.fromJson<String>(json['shaft']),
      tip: serializer.fromJson<String>(json['tip']),
      shaftMaterial: serializer.fromJson<String>(json['shaftMaterial']),
      shaftDiameter: serializer.fromJson<double>(json['shaftDiameter']),
      tipBrand: serializer.fromJson<String>(json['tipBrand']),
      tipHardness: serializer.fromJson<String>(json['tipHardness']),
      tipSize: serializer.fromJson<double?>(json['tipSize']),
      cueType: serializer.fromJson<String>(json['cueType']),
      weight: serializer.fromJson<double>(json['weight']),
      balance: serializer.fromJson<String>(json['balance']),
      joint: serializer.fromJson<String>(json['joint']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      isBreakCue: serializer.fromJson<bool>(json['isBreakCue']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'playerId': serializer.toJson<int?>(playerId),
      'name': serializer.toJson<String>(name),
      'shaft': serializer.toJson<String>(shaft),
      'tip': serializer.toJson<String>(tip),
      'shaftMaterial': serializer.toJson<String>(shaftMaterial),
      'shaftDiameter': serializer.toJson<double>(shaftDiameter),
      'tipBrand': serializer.toJson<String>(tipBrand),
      'tipHardness': serializer.toJson<String>(tipHardness),
      'tipSize': serializer.toJson<double?>(tipSize),
      'cueType': serializer.toJson<String>(cueType),
      'weight': serializer.toJson<double>(weight),
      'balance': serializer.toJson<String>(balance),
      'joint': serializer.toJson<String>(joint),
      'isActive': serializer.toJson<bool>(isActive),
      'isBreakCue': serializer.toJson<bool>(isBreakCue),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Cue copyWith(
          {int? id,
          Value<int?> playerId = const Value.absent(),
          String? name,
          String? shaft,
          String? tip,
          String? shaftMaterial,
          double? shaftDiameter,
          String? tipBrand,
          String? tipHardness,
          Value<double?> tipSize = const Value.absent(),
          String? cueType,
          double? weight,
          String? balance,
          String? joint,
          bool? isActive,
          bool? isBreakCue,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Cue(
        id: id ?? this.id,
        playerId: playerId.present ? playerId.value : this.playerId,
        name: name ?? this.name,
        shaft: shaft ?? this.shaft,
        tip: tip ?? this.tip,
        shaftMaterial: shaftMaterial ?? this.shaftMaterial,
        shaftDiameter: shaftDiameter ?? this.shaftDiameter,
        tipBrand: tipBrand ?? this.tipBrand,
        tipHardness: tipHardness ?? this.tipHardness,
        tipSize: tipSize.present ? tipSize.value : this.tipSize,
        cueType: cueType ?? this.cueType,
        weight: weight ?? this.weight,
        balance: balance ?? this.balance,
        joint: joint ?? this.joint,
        isActive: isActive ?? this.isActive,
        isBreakCue: isBreakCue ?? this.isBreakCue,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Cue copyWithCompanion(CuesCompanion data) {
    return Cue(
      id: data.id.present ? data.id.value : this.id,
      playerId: data.playerId.present ? data.playerId.value : this.playerId,
      name: data.name.present ? data.name.value : this.name,
      shaft: data.shaft.present ? data.shaft.value : this.shaft,
      tip: data.tip.present ? data.tip.value : this.tip,
      shaftMaterial: data.shaftMaterial.present
          ? data.shaftMaterial.value
          : this.shaftMaterial,
      shaftDiameter: data.shaftDiameter.present
          ? data.shaftDiameter.value
          : this.shaftDiameter,
      tipBrand: data.tipBrand.present ? data.tipBrand.value : this.tipBrand,
      tipHardness:
          data.tipHardness.present ? data.tipHardness.value : this.tipHardness,
      tipSize: data.tipSize.present ? data.tipSize.value : this.tipSize,
      cueType: data.cueType.present ? data.cueType.value : this.cueType,
      weight: data.weight.present ? data.weight.value : this.weight,
      balance: data.balance.present ? data.balance.value : this.balance,
      joint: data.joint.present ? data.joint.value : this.joint,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      isBreakCue:
          data.isBreakCue.present ? data.isBreakCue.value : this.isBreakCue,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Cue(')
          ..write('id: $id, ')
          ..write('playerId: $playerId, ')
          ..write('name: $name, ')
          ..write('shaft: $shaft, ')
          ..write('tip: $tip, ')
          ..write('shaftMaterial: $shaftMaterial, ')
          ..write('shaftDiameter: $shaftDiameter, ')
          ..write('tipBrand: $tipBrand, ')
          ..write('tipHardness: $tipHardness, ')
          ..write('tipSize: $tipSize, ')
          ..write('cueType: $cueType, ')
          ..write('weight: $weight, ')
          ..write('balance: $balance, ')
          ..write('joint: $joint, ')
          ..write('isActive: $isActive, ')
          ..write('isBreakCue: $isBreakCue, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      playerId,
      name,
      shaft,
      tip,
      shaftMaterial,
      shaftDiameter,
      tipBrand,
      tipHardness,
      tipSize,
      cueType,
      weight,
      balance,
      joint,
      isActive,
      isBreakCue,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Cue &&
          other.id == this.id &&
          other.playerId == this.playerId &&
          other.name == this.name &&
          other.shaft == this.shaft &&
          other.tip == this.tip &&
          other.shaftMaterial == this.shaftMaterial &&
          other.shaftDiameter == this.shaftDiameter &&
          other.tipBrand == this.tipBrand &&
          other.tipHardness == this.tipHardness &&
          other.tipSize == this.tipSize &&
          other.cueType == this.cueType &&
          other.weight == this.weight &&
          other.balance == this.balance &&
          other.joint == this.joint &&
          other.isActive == this.isActive &&
          other.isBreakCue == this.isBreakCue &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CuesCompanion extends UpdateCompanion<Cue> {
  final Value<int> id;
  final Value<int?> playerId;
  final Value<String> name;
  final Value<String> shaft;
  final Value<String> tip;
  final Value<String> shaftMaterial;
  final Value<double> shaftDiameter;
  final Value<String> tipBrand;
  final Value<String> tipHardness;
  final Value<double?> tipSize;
  final Value<String> cueType;
  final Value<double> weight;
  final Value<String> balance;
  final Value<String> joint;
  final Value<bool> isActive;
  final Value<bool> isBreakCue;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const CuesCompanion({
    this.id = const Value.absent(),
    this.playerId = const Value.absent(),
    this.name = const Value.absent(),
    this.shaft = const Value.absent(),
    this.tip = const Value.absent(),
    this.shaftMaterial = const Value.absent(),
    this.shaftDiameter = const Value.absent(),
    this.tipBrand = const Value.absent(),
    this.tipHardness = const Value.absent(),
    this.tipSize = const Value.absent(),
    this.cueType = const Value.absent(),
    this.weight = const Value.absent(),
    this.balance = const Value.absent(),
    this.joint = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isBreakCue = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CuesCompanion.insert({
    this.id = const Value.absent(),
    this.playerId = const Value.absent(),
    required String name,
    required String shaft,
    required String tip,
    required String shaftMaterial,
    required double shaftDiameter,
    required String tipBrand,
    required String tipHardness,
    this.tipSize = const Value.absent(),
    this.cueType = const Value.absent(),
    required double weight,
    required String balance,
    required String joint,
    this.isActive = const Value.absent(),
    this.isBreakCue = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : name = Value(name),
        shaft = Value(shaft),
        tip = Value(tip),
        shaftMaterial = Value(shaftMaterial),
        shaftDiameter = Value(shaftDiameter),
        tipBrand = Value(tipBrand),
        tipHardness = Value(tipHardness),
        weight = Value(weight),
        balance = Value(balance),
        joint = Value(joint);
  static Insertable<Cue> custom({
    Expression<int>? id,
    Expression<int>? playerId,
    Expression<String>? name,
    Expression<String>? shaft,
    Expression<String>? tip,
    Expression<String>? shaftMaterial,
    Expression<double>? shaftDiameter,
    Expression<String>? tipBrand,
    Expression<String>? tipHardness,
    Expression<double>? tipSize,
    Expression<String>? cueType,
    Expression<double>? weight,
    Expression<String>? balance,
    Expression<String>? joint,
    Expression<bool>? isActive,
    Expression<bool>? isBreakCue,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (playerId != null) 'player_id': playerId,
      if (name != null) 'name': name,
      if (shaft != null) 'shaft': shaft,
      if (tip != null) 'tip': tip,
      if (shaftMaterial != null) 'shaft_material': shaftMaterial,
      if (shaftDiameter != null) 'shaft_diameter': shaftDiameter,
      if (tipBrand != null) 'tip_brand': tipBrand,
      if (tipHardness != null) 'tip_hardness': tipHardness,
      if (tipSize != null) 'tip_size': tipSize,
      if (cueType != null) 'cue_type': cueType,
      if (weight != null) 'weight': weight,
      if (balance != null) 'balance': balance,
      if (joint != null) 'joint': joint,
      if (isActive != null) 'is_active': isActive,
      if (isBreakCue != null) 'is_break_cue': isBreakCue,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CuesCompanion copyWith(
      {Value<int>? id,
      Value<int?>? playerId,
      Value<String>? name,
      Value<String>? shaft,
      Value<String>? tip,
      Value<String>? shaftMaterial,
      Value<double>? shaftDiameter,
      Value<String>? tipBrand,
      Value<String>? tipHardness,
      Value<double?>? tipSize,
      Value<String>? cueType,
      Value<double>? weight,
      Value<String>? balance,
      Value<String>? joint,
      Value<bool>? isActive,
      Value<bool>? isBreakCue,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return CuesCompanion(
      id: id ?? this.id,
      playerId: playerId ?? this.playerId,
      name: name ?? this.name,
      shaft: shaft ?? this.shaft,
      tip: tip ?? this.tip,
      shaftMaterial: shaftMaterial ?? this.shaftMaterial,
      shaftDiameter: shaftDiameter ?? this.shaftDiameter,
      tipBrand: tipBrand ?? this.tipBrand,
      tipHardness: tipHardness ?? this.tipHardness,
      tipSize: tipSize ?? this.tipSize,
      cueType: cueType ?? this.cueType,
      weight: weight ?? this.weight,
      balance: balance ?? this.balance,
      joint: joint ?? this.joint,
      isActive: isActive ?? this.isActive,
      isBreakCue: isBreakCue ?? this.isBreakCue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (playerId.present) {
      map['player_id'] = Variable<int>(playerId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (shaft.present) {
      map['shaft'] = Variable<String>(shaft.value);
    }
    if (tip.present) {
      map['tip'] = Variable<String>(tip.value);
    }
    if (shaftMaterial.present) {
      map['shaft_material'] = Variable<String>(shaftMaterial.value);
    }
    if (shaftDiameter.present) {
      map['shaft_diameter'] = Variable<double>(shaftDiameter.value);
    }
    if (tipBrand.present) {
      map['tip_brand'] = Variable<String>(tipBrand.value);
    }
    if (tipHardness.present) {
      map['tip_hardness'] = Variable<String>(tipHardness.value);
    }
    if (tipSize.present) {
      map['tip_size'] = Variable<double>(tipSize.value);
    }
    if (cueType.present) {
      map['cue_type'] = Variable<String>(cueType.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (balance.present) {
      map['balance'] = Variable<String>(balance.value);
    }
    if (joint.present) {
      map['joint'] = Variable<String>(joint.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (isBreakCue.present) {
      map['is_break_cue'] = Variable<bool>(isBreakCue.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CuesCompanion(')
          ..write('id: $id, ')
          ..write('playerId: $playerId, ')
          ..write('name: $name, ')
          ..write('shaft: $shaft, ')
          ..write('tip: $tip, ')
          ..write('shaftMaterial: $shaftMaterial, ')
          ..write('shaftDiameter: $shaftDiameter, ')
          ..write('tipBrand: $tipBrand, ')
          ..write('tipHardness: $tipHardness, ')
          ..write('tipSize: $tipSize, ')
          ..write('cueType: $cueType, ')
          ..write('weight: $weight, ')
          ..write('balance: $balance, ')
          ..write('joint: $joint, ')
          ..write('isActive: $isActive, ')
          ..write('isBreakCue: $isBreakCue, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _playerIdMeta =
      const VerificationMeta('playerId');
  @override
  late final GeneratedColumn<int> playerId = GeneratedColumn<int>(
      'player_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _sessionTypeMeta =
      const VerificationMeta('sessionType');
  @override
  late final GeneratedColumn<String> sessionType = GeneratedColumn<String>(
      'session_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _locationMeta =
      const VerificationMeta('location');
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
      'location', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tableMeta = const VerificationMeta('table');
  @override
  late final GeneratedColumn<String> table = GeneratedColumn<String>(
      'table', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _clothMeta = const VerificationMeta('cloth');
  @override
  late final GeneratedColumn<String> cloth = GeneratedColumn<String>(
      'cloth', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ballsMeta = const VerificationMeta('balls');
  @override
  late final GeneratedColumn<String> balls = GeneratedColumn<String>(
      'balls', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _trainingGoalMeta =
      const VerificationMeta('trainingGoal');
  @override
  late final GeneratedColumn<String> trainingGoal = GeneratedColumn<String>(
      'training_goal', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _weatherMeta =
      const VerificationMeta('weather');
  @override
  late final GeneratedColumn<String> weather = GeneratedColumn<String>(
      'weather', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
      'started_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _finishedAtMeta =
      const VerificationMeta('finishedAt');
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
      'finished_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        playerId,
        sessionType,
        location,
        table,
        cloth,
        balls,
        trainingGoal,
        notes,
        weather,
        startedAt,
        finishedAt,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(Insertable<Session> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('player_id')) {
      context.handle(_playerIdMeta,
          playerId.isAcceptableOrUnknown(data['player_id']!, _playerIdMeta));
    }
    if (data.containsKey('session_type')) {
      context.handle(
          _sessionTypeMeta,
          sessionType.isAcceptableOrUnknown(
              data['session_type']!, _sessionTypeMeta));
    } else if (isInserting) {
      context.missing(_sessionTypeMeta);
    }
    if (data.containsKey('location')) {
      context.handle(_locationMeta,
          location.isAcceptableOrUnknown(data['location']!, _locationMeta));
    }
    if (data.containsKey('table')) {
      context.handle(
          _tableMeta, table.isAcceptableOrUnknown(data['table']!, _tableMeta));
    }
    if (data.containsKey('cloth')) {
      context.handle(
          _clothMeta, cloth.isAcceptableOrUnknown(data['cloth']!, _clothMeta));
    }
    if (data.containsKey('balls')) {
      context.handle(
          _ballsMeta, balls.isAcceptableOrUnknown(data['balls']!, _ballsMeta));
    }
    if (data.containsKey('training_goal')) {
      context.handle(
          _trainingGoalMeta,
          trainingGoal.isAcceptableOrUnknown(
              data['training_goal']!, _trainingGoalMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('weather')) {
      context.handle(_weatherMeta,
          weather.isAcceptableOrUnknown(data['weather']!, _weatherMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('finished_at')) {
      context.handle(
          _finishedAtMeta,
          finishedAt.isAcceptableOrUnknown(
              data['finished_at']!, _finishedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      playerId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}player_id']),
      sessionType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}session_type'])!,
      location: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location']),
      table: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}table']),
      cloth: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cloth']),
      balls: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}balls']),
      trainingGoal: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}training_goal']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      weather: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}weather']),
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}started_at'])!,
      finishedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}finished_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class Session extends DataClass implements Insertable<Session> {
  final int id;
  final int? playerId;
  final String sessionType;
  final String? location;
  final String? table;
  final String? cloth;
  final String? balls;
  final String? trainingGoal;
  final String? notes;
  final String? weather;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Session(
      {required this.id,
      this.playerId,
      required this.sessionType,
      this.location,
      this.table,
      this.cloth,
      this.balls,
      this.trainingGoal,
      this.notes,
      this.weather,
      required this.startedAt,
      this.finishedAt,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || playerId != null) {
      map['player_id'] = Variable<int>(playerId);
    }
    map['session_type'] = Variable<String>(sessionType);
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || table != null) {
      map['table'] = Variable<String>(table);
    }
    if (!nullToAbsent || cloth != null) {
      map['cloth'] = Variable<String>(cloth);
    }
    if (!nullToAbsent || balls != null) {
      map['balls'] = Variable<String>(balls);
    }
    if (!nullToAbsent || trainingGoal != null) {
      map['training_goal'] = Variable<String>(trainingGoal);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || weather != null) {
      map['weather'] = Variable<String>(weather);
    }
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<DateTime>(finishedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      playerId: playerId == null && nullToAbsent
          ? const Value.absent()
          : Value(playerId),
      sessionType: Value(sessionType),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      table:
          table == null && nullToAbsent ? const Value.absent() : Value(table),
      cloth:
          cloth == null && nullToAbsent ? const Value.absent() : Value(cloth),
      balls:
          balls == null && nullToAbsent ? const Value.absent() : Value(balls),
      trainingGoal: trainingGoal == null && nullToAbsent
          ? const Value.absent()
          : Value(trainingGoal),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      weather: weather == null && nullToAbsent
          ? const Value.absent()
          : Value(weather),
      startedAt: Value(startedAt),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Session.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<int>(json['id']),
      playerId: serializer.fromJson<int?>(json['playerId']),
      sessionType: serializer.fromJson<String>(json['sessionType']),
      location: serializer.fromJson<String?>(json['location']),
      table: serializer.fromJson<String?>(json['table']),
      cloth: serializer.fromJson<String?>(json['cloth']),
      balls: serializer.fromJson<String?>(json['balls']),
      trainingGoal: serializer.fromJson<String?>(json['trainingGoal']),
      notes: serializer.fromJson<String?>(json['notes']),
      weather: serializer.fromJson<String?>(json['weather']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      finishedAt: serializer.fromJson<DateTime?>(json['finishedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'playerId': serializer.toJson<int?>(playerId),
      'sessionType': serializer.toJson<String>(sessionType),
      'location': serializer.toJson<String?>(location),
      'table': serializer.toJson<String?>(table),
      'cloth': serializer.toJson<String?>(cloth),
      'balls': serializer.toJson<String?>(balls),
      'trainingGoal': serializer.toJson<String?>(trainingGoal),
      'notes': serializer.toJson<String?>(notes),
      'weather': serializer.toJson<String?>(weather),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'finishedAt': serializer.toJson<DateTime?>(finishedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Session copyWith(
          {int? id,
          Value<int?> playerId = const Value.absent(),
          String? sessionType,
          Value<String?> location = const Value.absent(),
          Value<String?> table = const Value.absent(),
          Value<String?> cloth = const Value.absent(),
          Value<String?> balls = const Value.absent(),
          Value<String?> trainingGoal = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          Value<String?> weather = const Value.absent(),
          DateTime? startedAt,
          Value<DateTime?> finishedAt = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Session(
        id: id ?? this.id,
        playerId: playerId.present ? playerId.value : this.playerId,
        sessionType: sessionType ?? this.sessionType,
        location: location.present ? location.value : this.location,
        table: table.present ? table.value : this.table,
        cloth: cloth.present ? cloth.value : this.cloth,
        balls: balls.present ? balls.value : this.balls,
        trainingGoal:
            trainingGoal.present ? trainingGoal.value : this.trainingGoal,
        notes: notes.present ? notes.value : this.notes,
        weather: weather.present ? weather.value : this.weather,
        startedAt: startedAt ?? this.startedAt,
        finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      playerId: data.playerId.present ? data.playerId.value : this.playerId,
      sessionType:
          data.sessionType.present ? data.sessionType.value : this.sessionType,
      location: data.location.present ? data.location.value : this.location,
      table: data.table.present ? data.table.value : this.table,
      cloth: data.cloth.present ? data.cloth.value : this.cloth,
      balls: data.balls.present ? data.balls.value : this.balls,
      trainingGoal: data.trainingGoal.present
          ? data.trainingGoal.value
          : this.trainingGoal,
      notes: data.notes.present ? data.notes.value : this.notes,
      weather: data.weather.present ? data.weather.value : this.weather,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      finishedAt:
          data.finishedAt.present ? data.finishedAt.value : this.finishedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('id: $id, ')
          ..write('playerId: $playerId, ')
          ..write('sessionType: $sessionType, ')
          ..write('location: $location, ')
          ..write('table: $table, ')
          ..write('cloth: $cloth, ')
          ..write('balls: $balls, ')
          ..write('trainingGoal: $trainingGoal, ')
          ..write('notes: $notes, ')
          ..write('weather: $weather, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      playerId,
      sessionType,
      location,
      table,
      cloth,
      balls,
      trainingGoal,
      notes,
      weather,
      startedAt,
      finishedAt,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.playerId == this.playerId &&
          other.sessionType == this.sessionType &&
          other.location == this.location &&
          other.table == this.table &&
          other.cloth == this.cloth &&
          other.balls == this.balls &&
          other.trainingGoal == this.trainingGoal &&
          other.notes == this.notes &&
          other.weather == this.weather &&
          other.startedAt == this.startedAt &&
          other.finishedAt == this.finishedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<int> id;
  final Value<int?> playerId;
  final Value<String> sessionType;
  final Value<String?> location;
  final Value<String?> table;
  final Value<String?> cloth;
  final Value<String?> balls;
  final Value<String?> trainingGoal;
  final Value<String?> notes;
  final Value<String?> weather;
  final Value<DateTime> startedAt;
  final Value<DateTime?> finishedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.playerId = const Value.absent(),
    this.sessionType = const Value.absent(),
    this.location = const Value.absent(),
    this.table = const Value.absent(),
    this.cloth = const Value.absent(),
    this.balls = const Value.absent(),
    this.trainingGoal = const Value.absent(),
    this.notes = const Value.absent(),
    this.weather = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SessionsCompanion.insert({
    this.id = const Value.absent(),
    this.playerId = const Value.absent(),
    required String sessionType,
    this.location = const Value.absent(),
    this.table = const Value.absent(),
    this.cloth = const Value.absent(),
    this.balls = const Value.absent(),
    this.trainingGoal = const Value.absent(),
    this.notes = const Value.absent(),
    this.weather = const Value.absent(),
    required DateTime startedAt,
    this.finishedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : sessionType = Value(sessionType),
        startedAt = Value(startedAt);
  static Insertable<Session> custom({
    Expression<int>? id,
    Expression<int>? playerId,
    Expression<String>? sessionType,
    Expression<String>? location,
    Expression<String>? table,
    Expression<String>? cloth,
    Expression<String>? balls,
    Expression<String>? trainingGoal,
    Expression<String>? notes,
    Expression<String>? weather,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? finishedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (playerId != null) 'player_id': playerId,
      if (sessionType != null) 'session_type': sessionType,
      if (location != null) 'location': location,
      if (table != null) 'table': table,
      if (cloth != null) 'cloth': cloth,
      if (balls != null) 'balls': balls,
      if (trainingGoal != null) 'training_goal': trainingGoal,
      if (notes != null) 'notes': notes,
      if (weather != null) 'weather': weather,
      if (startedAt != null) 'started_at': startedAt,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SessionsCompanion copyWith(
      {Value<int>? id,
      Value<int?>? playerId,
      Value<String>? sessionType,
      Value<String?>? location,
      Value<String?>? table,
      Value<String?>? cloth,
      Value<String?>? balls,
      Value<String?>? trainingGoal,
      Value<String?>? notes,
      Value<String?>? weather,
      Value<DateTime>? startedAt,
      Value<DateTime?>? finishedAt,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return SessionsCompanion(
      id: id ?? this.id,
      playerId: playerId ?? this.playerId,
      sessionType: sessionType ?? this.sessionType,
      location: location ?? this.location,
      table: table ?? this.table,
      cloth: cloth ?? this.cloth,
      balls: balls ?? this.balls,
      trainingGoal: trainingGoal ?? this.trainingGoal,
      notes: notes ?? this.notes,
      weather: weather ?? this.weather,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (playerId.present) {
      map['player_id'] = Variable<int>(playerId.value);
    }
    if (sessionType.present) {
      map['session_type'] = Variable<String>(sessionType.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (table.present) {
      map['table'] = Variable<String>(table.value);
    }
    if (cloth.present) {
      map['cloth'] = Variable<String>(cloth.value);
    }
    if (balls.present) {
      map['balls'] = Variable<String>(balls.value);
    }
    if (trainingGoal.present) {
      map['training_goal'] = Variable<String>(trainingGoal.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (weather.present) {
      map['weather'] = Variable<String>(weather.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('playerId: $playerId, ')
          ..write('sessionType: $sessionType, ')
          ..write('location: $location, ')
          ..write('table: $table, ')
          ..write('cloth: $cloth, ')
          ..write('balls: $balls, ')
          ..write('trainingGoal: $trainingGoal, ')
          ..write('notes: $notes, ')
          ..write('weather: $weather, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $MatchesTable extends Matches with TableInfo<$MatchesTable, Matche> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MatchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
      'session_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES sessions (id)'));
  static const VerificationMeta _matchNumberMeta =
      const VerificationMeta('matchNumber');
  @override
  late final GeneratedColumn<int> matchNumber = GeneratedColumn<int>(
      'match_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _gameTypeMeta =
      const VerificationMeta('gameType');
  @override
  late final GeneratedColumn<String> gameType = GeneratedColumn<String>(
      'game_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _raceToMeta = const VerificationMeta('raceTo');
  @override
  late final GeneratedColumn<int> raceTo = GeneratedColumn<int>(
      'race_to', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _opponentMeta =
      const VerificationMeta('opponent');
  @override
  late final GeneratedColumn<String> opponent = GeneratedColumn<String>(
      'opponent', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _partnerMeta =
      const VerificationMeta('partner');
  @override
  late final GeneratedColumn<String> partner = GeneratedColumn<String>(
      'partner', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _teamModeMeta =
      const VerificationMeta('teamMode');
  @override
  late final GeneratedColumn<String> teamMode = GeneratedColumn<String>(
      'team_mode', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _winnerMeta = const VerificationMeta('winner');
  @override
  late final GeneratedColumn<String> winner = GeneratedColumn<String>(
      'winner', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _resultMeta = const VerificationMeta('result');
  @override
  late final GeneratedColumn<String> result = GeneratedColumn<String>(
      'result', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _startTimeMeta =
      const VerificationMeta('startTime');
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
      'start_time', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _endTimeMeta =
      const VerificationMeta('endTime');
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
      'end_time', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _matchObjectiveMeta =
      const VerificationMeta('matchObjective');
  @override
  late final GeneratedColumn<String> matchObjective = GeneratedColumn<String>(
      'match_objective', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        sessionId,
        matchNumber,
        gameType,
        raceTo,
        opponent,
        partner,
        teamMode,
        winner,
        result,
        startTime,
        endTime,
        matchObjective,
        notes,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'matches';
  @override
  VerificationContext validateIntegrity(Insertable<Matche> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('match_number')) {
      context.handle(
          _matchNumberMeta,
          matchNumber.isAcceptableOrUnknown(
              data['match_number']!, _matchNumberMeta));
    } else if (isInserting) {
      context.missing(_matchNumberMeta);
    }
    if (data.containsKey('game_type')) {
      context.handle(_gameTypeMeta,
          gameType.isAcceptableOrUnknown(data['game_type']!, _gameTypeMeta));
    } else if (isInserting) {
      context.missing(_gameTypeMeta);
    }
    if (data.containsKey('race_to')) {
      context.handle(_raceToMeta,
          raceTo.isAcceptableOrUnknown(data['race_to']!, _raceToMeta));
    }
    if (data.containsKey('opponent')) {
      context.handle(_opponentMeta,
          opponent.isAcceptableOrUnknown(data['opponent']!, _opponentMeta));
    }
    if (data.containsKey('partner')) {
      context.handle(_partnerMeta,
          partner.isAcceptableOrUnknown(data['partner']!, _partnerMeta));
    }
    if (data.containsKey('team_mode')) {
      context.handle(_teamModeMeta,
          teamMode.isAcceptableOrUnknown(data['team_mode']!, _teamModeMeta));
    }
    if (data.containsKey('winner')) {
      context.handle(_winnerMeta,
          winner.isAcceptableOrUnknown(data['winner']!, _winnerMeta));
    }
    if (data.containsKey('result')) {
      context.handle(_resultMeta,
          result.isAcceptableOrUnknown(data['result']!, _resultMeta));
    }
    if (data.containsKey('start_time')) {
      context.handle(_startTimeMeta,
          startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta));
    }
    if (data.containsKey('end_time')) {
      context.handle(_endTimeMeta,
          endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta));
    }
    if (data.containsKey('match_objective')) {
      context.handle(
          _matchObjectiveMeta,
          matchObjective.isAcceptableOrUnknown(
              data['match_objective']!, _matchObjectiveMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Matche map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Matche(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}session_id'])!,
      matchNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}match_number'])!,
      gameType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}game_type'])!,
      raceTo: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}race_to']),
      opponent: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}opponent']),
      partner: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}partner']),
      teamMode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}team_mode']),
      winner: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}winner']),
      result: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}result']),
      startTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_time']),
      endTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_time']),
      matchObjective: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}match_objective']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $MatchesTable createAlias(String alias) {
    return $MatchesTable(attachedDatabase, alias);
  }
}

class Matche extends DataClass implements Insertable<Matche> {
  final int id;
  final int sessionId;
  final int matchNumber;
  final String gameType;
  final int? raceTo;
  final String? opponent;
  final String? partner;
  final String? teamMode;
  final String? winner;
  final String? result;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? matchObjective;
  final String? notes;
  final DateTime createdAt;
  const Matche(
      {required this.id,
      required this.sessionId,
      required this.matchNumber,
      required this.gameType,
      this.raceTo,
      this.opponent,
      this.partner,
      this.teamMode,
      this.winner,
      this.result,
      this.startTime,
      this.endTime,
      this.matchObjective,
      this.notes,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['match_number'] = Variable<int>(matchNumber);
    map['game_type'] = Variable<String>(gameType);
    if (!nullToAbsent || raceTo != null) {
      map['race_to'] = Variable<int>(raceTo);
    }
    if (!nullToAbsent || opponent != null) {
      map['opponent'] = Variable<String>(opponent);
    }
    if (!nullToAbsent || partner != null) {
      map['partner'] = Variable<String>(partner);
    }
    if (!nullToAbsent || teamMode != null) {
      map['team_mode'] = Variable<String>(teamMode);
    }
    if (!nullToAbsent || winner != null) {
      map['winner'] = Variable<String>(winner);
    }
    if (!nullToAbsent || result != null) {
      map['result'] = Variable<String>(result);
    }
    if (!nullToAbsent || startTime != null) {
      map['start_time'] = Variable<DateTime>(startTime);
    }
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<DateTime>(endTime);
    }
    if (!nullToAbsent || matchObjective != null) {
      map['match_objective'] = Variable<String>(matchObjective);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MatchesCompanion toCompanion(bool nullToAbsent) {
    return MatchesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      matchNumber: Value(matchNumber),
      gameType: Value(gameType),
      raceTo:
          raceTo == null && nullToAbsent ? const Value.absent() : Value(raceTo),
      opponent: opponent == null && nullToAbsent
          ? const Value.absent()
          : Value(opponent),
      partner: partner == null && nullToAbsent
          ? const Value.absent()
          : Value(partner),
      teamMode: teamMode == null && nullToAbsent
          ? const Value.absent()
          : Value(teamMode),
      winner:
          winner == null && nullToAbsent ? const Value.absent() : Value(winner),
      result:
          result == null && nullToAbsent ? const Value.absent() : Value(result),
      startTime: startTime == null && nullToAbsent
          ? const Value.absent()
          : Value(startTime),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
      matchObjective: matchObjective == null && nullToAbsent
          ? const Value.absent()
          : Value(matchObjective),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory Matche.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Matche(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      matchNumber: serializer.fromJson<int>(json['matchNumber']),
      gameType: serializer.fromJson<String>(json['gameType']),
      raceTo: serializer.fromJson<int?>(json['raceTo']),
      opponent: serializer.fromJson<String?>(json['opponent']),
      partner: serializer.fromJson<String?>(json['partner']),
      teamMode: serializer.fromJson<String?>(json['teamMode']),
      winner: serializer.fromJson<String?>(json['winner']),
      result: serializer.fromJson<String?>(json['result']),
      startTime: serializer.fromJson<DateTime?>(json['startTime']),
      endTime: serializer.fromJson<DateTime?>(json['endTime']),
      matchObjective: serializer.fromJson<String?>(json['matchObjective']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'matchNumber': serializer.toJson<int>(matchNumber),
      'gameType': serializer.toJson<String>(gameType),
      'raceTo': serializer.toJson<int?>(raceTo),
      'opponent': serializer.toJson<String?>(opponent),
      'partner': serializer.toJson<String?>(partner),
      'teamMode': serializer.toJson<String?>(teamMode),
      'winner': serializer.toJson<String?>(winner),
      'result': serializer.toJson<String?>(result),
      'startTime': serializer.toJson<DateTime?>(startTime),
      'endTime': serializer.toJson<DateTime?>(endTime),
      'matchObjective': serializer.toJson<String?>(matchObjective),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Matche copyWith(
          {int? id,
          int? sessionId,
          int? matchNumber,
          String? gameType,
          Value<int?> raceTo = const Value.absent(),
          Value<String?> opponent = const Value.absent(),
          Value<String?> partner = const Value.absent(),
          Value<String?> teamMode = const Value.absent(),
          Value<String?> winner = const Value.absent(),
          Value<String?> result = const Value.absent(),
          Value<DateTime?> startTime = const Value.absent(),
          Value<DateTime?> endTime = const Value.absent(),
          Value<String?> matchObjective = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt}) =>
      Matche(
        id: id ?? this.id,
        sessionId: sessionId ?? this.sessionId,
        matchNumber: matchNumber ?? this.matchNumber,
        gameType: gameType ?? this.gameType,
        raceTo: raceTo.present ? raceTo.value : this.raceTo,
        opponent: opponent.present ? opponent.value : this.opponent,
        partner: partner.present ? partner.value : this.partner,
        teamMode: teamMode.present ? teamMode.value : this.teamMode,
        winner: winner.present ? winner.value : this.winner,
        result: result.present ? result.value : this.result,
        startTime: startTime.present ? startTime.value : this.startTime,
        endTime: endTime.present ? endTime.value : this.endTime,
        matchObjective:
            matchObjective.present ? matchObjective.value : this.matchObjective,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
      );
  Matche copyWithCompanion(MatchesCompanion data) {
    return Matche(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      matchNumber:
          data.matchNumber.present ? data.matchNumber.value : this.matchNumber,
      gameType: data.gameType.present ? data.gameType.value : this.gameType,
      raceTo: data.raceTo.present ? data.raceTo.value : this.raceTo,
      opponent: data.opponent.present ? data.opponent.value : this.opponent,
      partner: data.partner.present ? data.partner.value : this.partner,
      teamMode: data.teamMode.present ? data.teamMode.value : this.teamMode,
      winner: data.winner.present ? data.winner.value : this.winner,
      result: data.result.present ? data.result.value : this.result,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      matchObjective: data.matchObjective.present
          ? data.matchObjective.value
          : this.matchObjective,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Matche(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('matchNumber: $matchNumber, ')
          ..write('gameType: $gameType, ')
          ..write('raceTo: $raceTo, ')
          ..write('opponent: $opponent, ')
          ..write('partner: $partner, ')
          ..write('teamMode: $teamMode, ')
          ..write('winner: $winner, ')
          ..write('result: $result, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('matchObjective: $matchObjective, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      sessionId,
      matchNumber,
      gameType,
      raceTo,
      opponent,
      partner,
      teamMode,
      winner,
      result,
      startTime,
      endTime,
      matchObjective,
      notes,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Matche &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.matchNumber == this.matchNumber &&
          other.gameType == this.gameType &&
          other.raceTo == this.raceTo &&
          other.opponent == this.opponent &&
          other.partner == this.partner &&
          other.teamMode == this.teamMode &&
          other.winner == this.winner &&
          other.result == this.result &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.matchObjective == this.matchObjective &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class MatchesCompanion extends UpdateCompanion<Matche> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<int> matchNumber;
  final Value<String> gameType;
  final Value<int?> raceTo;
  final Value<String?> opponent;
  final Value<String?> partner;
  final Value<String?> teamMode;
  final Value<String?> winner;
  final Value<String?> result;
  final Value<DateTime?> startTime;
  final Value<DateTime?> endTime;
  final Value<String?> matchObjective;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  const MatchesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.matchNumber = const Value.absent(),
    this.gameType = const Value.absent(),
    this.raceTo = const Value.absent(),
    this.opponent = const Value.absent(),
    this.partner = const Value.absent(),
    this.teamMode = const Value.absent(),
    this.winner = const Value.absent(),
    this.result = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.matchObjective = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MatchesCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required int matchNumber,
    required String gameType,
    this.raceTo = const Value.absent(),
    this.opponent = const Value.absent(),
    this.partner = const Value.absent(),
    this.teamMode = const Value.absent(),
    this.winner = const Value.absent(),
    this.result = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.matchObjective = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : sessionId = Value(sessionId),
        matchNumber = Value(matchNumber),
        gameType = Value(gameType);
  static Insertable<Matche> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<int>? matchNumber,
    Expression<String>? gameType,
    Expression<int>? raceTo,
    Expression<String>? opponent,
    Expression<String>? partner,
    Expression<String>? teamMode,
    Expression<String>? winner,
    Expression<String>? result,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<String>? matchObjective,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (matchNumber != null) 'match_number': matchNumber,
      if (gameType != null) 'game_type': gameType,
      if (raceTo != null) 'race_to': raceTo,
      if (opponent != null) 'opponent': opponent,
      if (partner != null) 'partner': partner,
      if (teamMode != null) 'team_mode': teamMode,
      if (winner != null) 'winner': winner,
      if (result != null) 'result': result,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (matchObjective != null) 'match_objective': matchObjective,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MatchesCompanion copyWith(
      {Value<int>? id,
      Value<int>? sessionId,
      Value<int>? matchNumber,
      Value<String>? gameType,
      Value<int?>? raceTo,
      Value<String?>? opponent,
      Value<String?>? partner,
      Value<String?>? teamMode,
      Value<String?>? winner,
      Value<String?>? result,
      Value<DateTime?>? startTime,
      Value<DateTime?>? endTime,
      Value<String?>? matchObjective,
      Value<String?>? notes,
      Value<DateTime>? createdAt}) {
    return MatchesCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      matchNumber: matchNumber ?? this.matchNumber,
      gameType: gameType ?? this.gameType,
      raceTo: raceTo ?? this.raceTo,
      opponent: opponent ?? this.opponent,
      partner: partner ?? this.partner,
      teamMode: teamMode ?? this.teamMode,
      winner: winner ?? this.winner,
      result: result ?? this.result,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      matchObjective: matchObjective ?? this.matchObjective,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (matchNumber.present) {
      map['match_number'] = Variable<int>(matchNumber.value);
    }
    if (gameType.present) {
      map['game_type'] = Variable<String>(gameType.value);
    }
    if (raceTo.present) {
      map['race_to'] = Variable<int>(raceTo.value);
    }
    if (opponent.present) {
      map['opponent'] = Variable<String>(opponent.value);
    }
    if (partner.present) {
      map['partner'] = Variable<String>(partner.value);
    }
    if (teamMode.present) {
      map['team_mode'] = Variable<String>(teamMode.value);
    }
    if (winner.present) {
      map['winner'] = Variable<String>(winner.value);
    }
    if (result.present) {
      map['result'] = Variable<String>(result.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (matchObjective.present) {
      map['match_objective'] = Variable<String>(matchObjective.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MatchesCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('matchNumber: $matchNumber, ')
          ..write('gameType: $gameType, ')
          ..write('raceTo: $raceTo, ')
          ..write('opponent: $opponent, ')
          ..write('partner: $partner, ')
          ..write('teamMode: $teamMode, ')
          ..write('winner: $winner, ')
          ..write('result: $result, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('matchObjective: $matchObjective, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $RacksTable extends Racks with TableInfo<$RacksTable, Rack> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RacksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _matchIdMeta =
      const VerificationMeta('matchId');
  @override
  late final GeneratedColumn<int> matchId = GeneratedColumn<int>(
      'match_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES matches (id)'));
  static const VerificationMeta _rackNumberMeta =
      const VerificationMeta('rackNumber');
  @override
  late final GeneratedColumn<int> rackNumber = GeneratedColumn<int>(
      'rack_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _resultMeta = const VerificationMeta('result');
  @override
  late final GeneratedColumn<bool> result = GeneratedColumn<bool>(
      'result', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("result" IN (0, 1))'));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _biggestMistakeMeta =
      const VerificationMeta('biggestMistake');
  @override
  late final GeneratedColumn<String> biggestMistake = GeneratedColumn<String>(
      'biggest_mistake', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _biggestStrengthMeta =
      const VerificationMeta('biggestStrength');
  @override
  late final GeneratedColumn<String> biggestStrength = GeneratedColumn<String>(
      'biggest_strength', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _confidenceMeta =
      const VerificationMeta('confidence');
  @override
  late final GeneratedColumn<int> confidence = GeneratedColumn<int>(
      'confidence', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _ballsPottedMeta =
      const VerificationMeta('ballsPotted');
  @override
  late final GeneratedColumn<int> ballsPotted = GeneratedColumn<int>(
      'balls_potted', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _largestRunMeta =
      const VerificationMeta('largestRun');
  @override
  late final GeneratedColumn<int> largestRun = GeneratedColumn<int>(
      'largest_run', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _breakSuccessMeta =
      const VerificationMeta('breakSuccess');
  @override
  late final GeneratedColumn<bool> breakSuccess = GeneratedColumn<bool>(
      'break_success', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("break_success" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _breakScratchMeta =
      const VerificationMeta('breakScratch');
  @override
  late final GeneratedColumn<bool> breakScratch = GeneratedColumn<bool>(
      'break_scratch', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("break_scratch" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _breakFoulMeta =
      const VerificationMeta('breakFoul');
  @override
  late final GeneratedColumn<bool> breakFoul = GeneratedColumn<bool>(
      'break_foul', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("break_foul" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _easyMissCountMeta =
      const VerificationMeta('easyMissCount');
  @override
  late final GeneratedColumn<int> easyMissCount = GeneratedColumn<int>(
      'easy_miss_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _hardMissCountMeta =
      const VerificationMeta('hardMissCount');
  @override
  late final GeneratedColumn<int> hardMissCount = GeneratedColumn<int>(
      'hard_miss_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _scratchErrorCountMeta =
      const VerificationMeta('scratchErrorCount');
  @override
  late final GeneratedColumn<int> scratchErrorCount = GeneratedColumn<int>(
      'scratch_error_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _positionErrorCountMeta =
      const VerificationMeta('positionErrorCount');
  @override
  late final GeneratedColumn<int> positionErrorCount = GeneratedColumn<int>(
      'position_error_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _safetyErrorCountMeta =
      const VerificationMeta('safetyErrorCount');
  @override
  late final GeneratedColumn<int> safetyErrorCount = GeneratedColumn<int>(
      'safety_error_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _kickErrorCountMeta =
      const VerificationMeta('kickErrorCount');
  @override
  late final GeneratedColumn<int> kickErrorCount = GeneratedColumn<int>(
      'kick_error_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _jumpErrorCountMeta =
      const VerificationMeta('jumpErrorCount');
  @override
  late final GeneratedColumn<int> jumpErrorCount = GeneratedColumn<int>(
      'jump_error_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _bestStrengthsMeta =
      const VerificationMeta('bestStrengths');
  @override
  late final GeneratedColumn<String> bestStrengths = GeneratedColumn<String>(
      'best_strengths', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _biggestMistakesMeta =
      const VerificationMeta('biggestMistakes');
  @override
  late final GeneratedColumn<String> biggestMistakes = GeneratedColumn<String>(
      'biggest_mistakes', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        matchId,
        rackNumber,
        result,
        notes,
        createdAt,
        biggestMistake,
        biggestStrength,
        confidence,
        ballsPotted,
        largestRun,
        breakSuccess,
        breakScratch,
        breakFoul,
        easyMissCount,
        hardMissCount,
        scratchErrorCount,
        positionErrorCount,
        safetyErrorCount,
        kickErrorCount,
        jumpErrorCount,
        bestStrengths,
        biggestMistakes
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'racks';
  @override
  VerificationContext validateIntegrity(Insertable<Rack> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('match_id')) {
      context.handle(_matchIdMeta,
          matchId.isAcceptableOrUnknown(data['match_id']!, _matchIdMeta));
    } else if (isInserting) {
      context.missing(_matchIdMeta);
    }
    if (data.containsKey('rack_number')) {
      context.handle(
          _rackNumberMeta,
          rackNumber.isAcceptableOrUnknown(
              data['rack_number']!, _rackNumberMeta));
    } else if (isInserting) {
      context.missing(_rackNumberMeta);
    }
    if (data.containsKey('result')) {
      context.handle(_resultMeta,
          result.isAcceptableOrUnknown(data['result']!, _resultMeta));
    } else if (isInserting) {
      context.missing(_resultMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('biggest_mistake')) {
      context.handle(
          _biggestMistakeMeta,
          biggestMistake.isAcceptableOrUnknown(
              data['biggest_mistake']!, _biggestMistakeMeta));
    }
    if (data.containsKey('biggest_strength')) {
      context.handle(
          _biggestStrengthMeta,
          biggestStrength.isAcceptableOrUnknown(
              data['biggest_strength']!, _biggestStrengthMeta));
    }
    if (data.containsKey('confidence')) {
      context.handle(
          _confidenceMeta,
          confidence.isAcceptableOrUnknown(
              data['confidence']!, _confidenceMeta));
    }
    if (data.containsKey('balls_potted')) {
      context.handle(
          _ballsPottedMeta,
          ballsPotted.isAcceptableOrUnknown(
              data['balls_potted']!, _ballsPottedMeta));
    }
    if (data.containsKey('largest_run')) {
      context.handle(
          _largestRunMeta,
          largestRun.isAcceptableOrUnknown(
              data['largest_run']!, _largestRunMeta));
    }
    if (data.containsKey('break_success')) {
      context.handle(
          _breakSuccessMeta,
          breakSuccess.isAcceptableOrUnknown(
              data['break_success']!, _breakSuccessMeta));
    }
    if (data.containsKey('break_scratch')) {
      context.handle(
          _breakScratchMeta,
          breakScratch.isAcceptableOrUnknown(
              data['break_scratch']!, _breakScratchMeta));
    }
    if (data.containsKey('break_foul')) {
      context.handle(_breakFoulMeta,
          breakFoul.isAcceptableOrUnknown(data['break_foul']!, _breakFoulMeta));
    }
    if (data.containsKey('easy_miss_count')) {
      context.handle(
          _easyMissCountMeta,
          easyMissCount.isAcceptableOrUnknown(
              data['easy_miss_count']!, _easyMissCountMeta));
    }
    if (data.containsKey('hard_miss_count')) {
      context.handle(
          _hardMissCountMeta,
          hardMissCount.isAcceptableOrUnknown(
              data['hard_miss_count']!, _hardMissCountMeta));
    }
    if (data.containsKey('scratch_error_count')) {
      context.handle(
          _scratchErrorCountMeta,
          scratchErrorCount.isAcceptableOrUnknown(
              data['scratch_error_count']!, _scratchErrorCountMeta));
    }
    if (data.containsKey('position_error_count')) {
      context.handle(
          _positionErrorCountMeta,
          positionErrorCount.isAcceptableOrUnknown(
              data['position_error_count']!, _positionErrorCountMeta));
    }
    if (data.containsKey('safety_error_count')) {
      context.handle(
          _safetyErrorCountMeta,
          safetyErrorCount.isAcceptableOrUnknown(
              data['safety_error_count']!, _safetyErrorCountMeta));
    }
    if (data.containsKey('kick_error_count')) {
      context.handle(
          _kickErrorCountMeta,
          kickErrorCount.isAcceptableOrUnknown(
              data['kick_error_count']!, _kickErrorCountMeta));
    }
    if (data.containsKey('jump_error_count')) {
      context.handle(
          _jumpErrorCountMeta,
          jumpErrorCount.isAcceptableOrUnknown(
              data['jump_error_count']!, _jumpErrorCountMeta));
    }
    if (data.containsKey('best_strengths')) {
      context.handle(
          _bestStrengthsMeta,
          bestStrengths.isAcceptableOrUnknown(
              data['best_strengths']!, _bestStrengthsMeta));
    }
    if (data.containsKey('biggest_mistakes')) {
      context.handle(
          _biggestMistakesMeta,
          biggestMistakes.isAcceptableOrUnknown(
              data['biggest_mistakes']!, _biggestMistakesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Rack map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Rack(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      matchId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}match_id'])!,
      rackNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rack_number'])!,
      result: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}result'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      biggestMistake: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}biggest_mistake']),
      biggestStrength: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}biggest_strength']),
      confidence: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}confidence']),
      ballsPotted: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}balls_potted'])!,
      largestRun: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}largest_run'])!,
      breakSuccess: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}break_success'])!,
      breakScratch: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}break_scratch'])!,
      breakFoul: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}break_foul'])!,
      easyMissCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}easy_miss_count'])!,
      hardMissCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}hard_miss_count'])!,
      scratchErrorCount: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}scratch_error_count'])!,
      positionErrorCount: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}position_error_count'])!,
      safetyErrorCount: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}safety_error_count'])!,
      kickErrorCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}kick_error_count'])!,
      jumpErrorCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}jump_error_count'])!,
      bestStrengths: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}best_strengths'])!,
      biggestMistakes: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}biggest_mistakes'])!,
    );
  }

  @override
  $RacksTable createAlias(String alias) {
    return $RacksTable(attachedDatabase, alias);
  }
}

class Rack extends DataClass implements Insertable<Rack> {
  final int id;
  final int matchId;
  final int rackNumber;
  final bool result;
  final String? notes;
  final DateTime createdAt;
  final String? biggestMistake;
  final String? biggestStrength;
  final int? confidence;
  final int ballsPotted;
  final int largestRun;
  final bool breakSuccess;
  final bool breakScratch;
  final bool breakFoul;
  final int easyMissCount;
  final int hardMissCount;
  final int scratchErrorCount;
  final int positionErrorCount;
  final int safetyErrorCount;
  final int kickErrorCount;
  final int jumpErrorCount;
  final String bestStrengths;
  final String biggestMistakes;
  const Rack(
      {required this.id,
      required this.matchId,
      required this.rackNumber,
      required this.result,
      this.notes,
      required this.createdAt,
      this.biggestMistake,
      this.biggestStrength,
      this.confidence,
      required this.ballsPotted,
      required this.largestRun,
      required this.breakSuccess,
      required this.breakScratch,
      required this.breakFoul,
      required this.easyMissCount,
      required this.hardMissCount,
      required this.scratchErrorCount,
      required this.positionErrorCount,
      required this.safetyErrorCount,
      required this.kickErrorCount,
      required this.jumpErrorCount,
      required this.bestStrengths,
      required this.biggestMistakes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['match_id'] = Variable<int>(matchId);
    map['rack_number'] = Variable<int>(rackNumber);
    map['result'] = Variable<bool>(result);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || biggestMistake != null) {
      map['biggest_mistake'] = Variable<String>(biggestMistake);
    }
    if (!nullToAbsent || biggestStrength != null) {
      map['biggest_strength'] = Variable<String>(biggestStrength);
    }
    if (!nullToAbsent || confidence != null) {
      map['confidence'] = Variable<int>(confidence);
    }
    map['balls_potted'] = Variable<int>(ballsPotted);
    map['largest_run'] = Variable<int>(largestRun);
    map['break_success'] = Variable<bool>(breakSuccess);
    map['break_scratch'] = Variable<bool>(breakScratch);
    map['break_foul'] = Variable<bool>(breakFoul);
    map['easy_miss_count'] = Variable<int>(easyMissCount);
    map['hard_miss_count'] = Variable<int>(hardMissCount);
    map['scratch_error_count'] = Variable<int>(scratchErrorCount);
    map['position_error_count'] = Variable<int>(positionErrorCount);
    map['safety_error_count'] = Variable<int>(safetyErrorCount);
    map['kick_error_count'] = Variable<int>(kickErrorCount);
    map['jump_error_count'] = Variable<int>(jumpErrorCount);
    map['best_strengths'] = Variable<String>(bestStrengths);
    map['biggest_mistakes'] = Variable<String>(biggestMistakes);
    return map;
  }

  RacksCompanion toCompanion(bool nullToAbsent) {
    return RacksCompanion(
      id: Value(id),
      matchId: Value(matchId),
      rackNumber: Value(rackNumber),
      result: Value(result),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      biggestMistake: biggestMistake == null && nullToAbsent
          ? const Value.absent()
          : Value(biggestMistake),
      biggestStrength: biggestStrength == null && nullToAbsent
          ? const Value.absent()
          : Value(biggestStrength),
      confidence: confidence == null && nullToAbsent
          ? const Value.absent()
          : Value(confidence),
      ballsPotted: Value(ballsPotted),
      largestRun: Value(largestRun),
      breakSuccess: Value(breakSuccess),
      breakScratch: Value(breakScratch),
      breakFoul: Value(breakFoul),
      easyMissCount: Value(easyMissCount),
      hardMissCount: Value(hardMissCount),
      scratchErrorCount: Value(scratchErrorCount),
      positionErrorCount: Value(positionErrorCount),
      safetyErrorCount: Value(safetyErrorCount),
      kickErrorCount: Value(kickErrorCount),
      jumpErrorCount: Value(jumpErrorCount),
      bestStrengths: Value(bestStrengths),
      biggestMistakes: Value(biggestMistakes),
    );
  }

  factory Rack.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Rack(
      id: serializer.fromJson<int>(json['id']),
      matchId: serializer.fromJson<int>(json['matchId']),
      rackNumber: serializer.fromJson<int>(json['rackNumber']),
      result: serializer.fromJson<bool>(json['result']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      biggestMistake: serializer.fromJson<String?>(json['biggestMistake']),
      biggestStrength: serializer.fromJson<String?>(json['biggestStrength']),
      confidence: serializer.fromJson<int?>(json['confidence']),
      ballsPotted: serializer.fromJson<int>(json['ballsPotted']),
      largestRun: serializer.fromJson<int>(json['largestRun']),
      breakSuccess: serializer.fromJson<bool>(json['breakSuccess']),
      breakScratch: serializer.fromJson<bool>(json['breakScratch']),
      breakFoul: serializer.fromJson<bool>(json['breakFoul']),
      easyMissCount: serializer.fromJson<int>(json['easyMissCount']),
      hardMissCount: serializer.fromJson<int>(json['hardMissCount']),
      scratchErrorCount: serializer.fromJson<int>(json['scratchErrorCount']),
      positionErrorCount: serializer.fromJson<int>(json['positionErrorCount']),
      safetyErrorCount: serializer.fromJson<int>(json['safetyErrorCount']),
      kickErrorCount: serializer.fromJson<int>(json['kickErrorCount']),
      jumpErrorCount: serializer.fromJson<int>(json['jumpErrorCount']),
      bestStrengths: serializer.fromJson<String>(json['bestStrengths']),
      biggestMistakes: serializer.fromJson<String>(json['biggestMistakes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'matchId': serializer.toJson<int>(matchId),
      'rackNumber': serializer.toJson<int>(rackNumber),
      'result': serializer.toJson<bool>(result),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'biggestMistake': serializer.toJson<String?>(biggestMistake),
      'biggestStrength': serializer.toJson<String?>(biggestStrength),
      'confidence': serializer.toJson<int?>(confidence),
      'ballsPotted': serializer.toJson<int>(ballsPotted),
      'largestRun': serializer.toJson<int>(largestRun),
      'breakSuccess': serializer.toJson<bool>(breakSuccess),
      'breakScratch': serializer.toJson<bool>(breakScratch),
      'breakFoul': serializer.toJson<bool>(breakFoul),
      'easyMissCount': serializer.toJson<int>(easyMissCount),
      'hardMissCount': serializer.toJson<int>(hardMissCount),
      'scratchErrorCount': serializer.toJson<int>(scratchErrorCount),
      'positionErrorCount': serializer.toJson<int>(positionErrorCount),
      'safetyErrorCount': serializer.toJson<int>(safetyErrorCount),
      'kickErrorCount': serializer.toJson<int>(kickErrorCount),
      'jumpErrorCount': serializer.toJson<int>(jumpErrorCount),
      'bestStrengths': serializer.toJson<String>(bestStrengths),
      'biggestMistakes': serializer.toJson<String>(biggestMistakes),
    };
  }

  Rack copyWith(
          {int? id,
          int? matchId,
          int? rackNumber,
          bool? result,
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt,
          Value<String?> biggestMistake = const Value.absent(),
          Value<String?> biggestStrength = const Value.absent(),
          Value<int?> confidence = const Value.absent(),
          int? ballsPotted,
          int? largestRun,
          bool? breakSuccess,
          bool? breakScratch,
          bool? breakFoul,
          int? easyMissCount,
          int? hardMissCount,
          int? scratchErrorCount,
          int? positionErrorCount,
          int? safetyErrorCount,
          int? kickErrorCount,
          int? jumpErrorCount,
          String? bestStrengths,
          String? biggestMistakes}) =>
      Rack(
        id: id ?? this.id,
        matchId: matchId ?? this.matchId,
        rackNumber: rackNumber ?? this.rackNumber,
        result: result ?? this.result,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        biggestMistake:
            biggestMistake.present ? biggestMistake.value : this.biggestMistake,
        biggestStrength: biggestStrength.present
            ? biggestStrength.value
            : this.biggestStrength,
        confidence: confidence.present ? confidence.value : this.confidence,
        ballsPotted: ballsPotted ?? this.ballsPotted,
        largestRun: largestRun ?? this.largestRun,
        breakSuccess: breakSuccess ?? this.breakSuccess,
        breakScratch: breakScratch ?? this.breakScratch,
        breakFoul: breakFoul ?? this.breakFoul,
        easyMissCount: easyMissCount ?? this.easyMissCount,
        hardMissCount: hardMissCount ?? this.hardMissCount,
        scratchErrorCount: scratchErrorCount ?? this.scratchErrorCount,
        positionErrorCount: positionErrorCount ?? this.positionErrorCount,
        safetyErrorCount: safetyErrorCount ?? this.safetyErrorCount,
        kickErrorCount: kickErrorCount ?? this.kickErrorCount,
        jumpErrorCount: jumpErrorCount ?? this.jumpErrorCount,
        bestStrengths: bestStrengths ?? this.bestStrengths,
        biggestMistakes: biggestMistakes ?? this.biggestMistakes,
      );
  Rack copyWithCompanion(RacksCompanion data) {
    return Rack(
      id: data.id.present ? data.id.value : this.id,
      matchId: data.matchId.present ? data.matchId.value : this.matchId,
      rackNumber:
          data.rackNumber.present ? data.rackNumber.value : this.rackNumber,
      result: data.result.present ? data.result.value : this.result,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      biggestMistake: data.biggestMistake.present
          ? data.biggestMistake.value
          : this.biggestMistake,
      biggestStrength: data.biggestStrength.present
          ? data.biggestStrength.value
          : this.biggestStrength,
      confidence:
          data.confidence.present ? data.confidence.value : this.confidence,
      ballsPotted:
          data.ballsPotted.present ? data.ballsPotted.value : this.ballsPotted,
      largestRun:
          data.largestRun.present ? data.largestRun.value : this.largestRun,
      breakSuccess: data.breakSuccess.present
          ? data.breakSuccess.value
          : this.breakSuccess,
      breakScratch: data.breakScratch.present
          ? data.breakScratch.value
          : this.breakScratch,
      breakFoul: data.breakFoul.present ? data.breakFoul.value : this.breakFoul,
      easyMissCount: data.easyMissCount.present
          ? data.easyMissCount.value
          : this.easyMissCount,
      hardMissCount: data.hardMissCount.present
          ? data.hardMissCount.value
          : this.hardMissCount,
      scratchErrorCount: data.scratchErrorCount.present
          ? data.scratchErrorCount.value
          : this.scratchErrorCount,
      positionErrorCount: data.positionErrorCount.present
          ? data.positionErrorCount.value
          : this.positionErrorCount,
      safetyErrorCount: data.safetyErrorCount.present
          ? data.safetyErrorCount.value
          : this.safetyErrorCount,
      kickErrorCount: data.kickErrorCount.present
          ? data.kickErrorCount.value
          : this.kickErrorCount,
      jumpErrorCount: data.jumpErrorCount.present
          ? data.jumpErrorCount.value
          : this.jumpErrorCount,
      bestStrengths: data.bestStrengths.present
          ? data.bestStrengths.value
          : this.bestStrengths,
      biggestMistakes: data.biggestMistakes.present
          ? data.biggestMistakes.value
          : this.biggestMistakes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Rack(')
          ..write('id: $id, ')
          ..write('matchId: $matchId, ')
          ..write('rackNumber: $rackNumber, ')
          ..write('result: $result, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('biggestMistake: $biggestMistake, ')
          ..write('biggestStrength: $biggestStrength, ')
          ..write('confidence: $confidence, ')
          ..write('ballsPotted: $ballsPotted, ')
          ..write('largestRun: $largestRun, ')
          ..write('breakSuccess: $breakSuccess, ')
          ..write('breakScratch: $breakScratch, ')
          ..write('breakFoul: $breakFoul, ')
          ..write('easyMissCount: $easyMissCount, ')
          ..write('hardMissCount: $hardMissCount, ')
          ..write('scratchErrorCount: $scratchErrorCount, ')
          ..write('positionErrorCount: $positionErrorCount, ')
          ..write('safetyErrorCount: $safetyErrorCount, ')
          ..write('kickErrorCount: $kickErrorCount, ')
          ..write('jumpErrorCount: $jumpErrorCount, ')
          ..write('bestStrengths: $bestStrengths, ')
          ..write('biggestMistakes: $biggestMistakes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        matchId,
        rackNumber,
        result,
        notes,
        createdAt,
        biggestMistake,
        biggestStrength,
        confidence,
        ballsPotted,
        largestRun,
        breakSuccess,
        breakScratch,
        breakFoul,
        easyMissCount,
        hardMissCount,
        scratchErrorCount,
        positionErrorCount,
        safetyErrorCount,
        kickErrorCount,
        jumpErrorCount,
        bestStrengths,
        biggestMistakes
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Rack &&
          other.id == this.id &&
          other.matchId == this.matchId &&
          other.rackNumber == this.rackNumber &&
          other.result == this.result &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.biggestMistake == this.biggestMistake &&
          other.biggestStrength == this.biggestStrength &&
          other.confidence == this.confidence &&
          other.ballsPotted == this.ballsPotted &&
          other.largestRun == this.largestRun &&
          other.breakSuccess == this.breakSuccess &&
          other.breakScratch == this.breakScratch &&
          other.breakFoul == this.breakFoul &&
          other.easyMissCount == this.easyMissCount &&
          other.hardMissCount == this.hardMissCount &&
          other.scratchErrorCount == this.scratchErrorCount &&
          other.positionErrorCount == this.positionErrorCount &&
          other.safetyErrorCount == this.safetyErrorCount &&
          other.kickErrorCount == this.kickErrorCount &&
          other.jumpErrorCount == this.jumpErrorCount &&
          other.bestStrengths == this.bestStrengths &&
          other.biggestMistakes == this.biggestMistakes);
}

class RacksCompanion extends UpdateCompanion<Rack> {
  final Value<int> id;
  final Value<int> matchId;
  final Value<int> rackNumber;
  final Value<bool> result;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<String?> biggestMistake;
  final Value<String?> biggestStrength;
  final Value<int?> confidence;
  final Value<int> ballsPotted;
  final Value<int> largestRun;
  final Value<bool> breakSuccess;
  final Value<bool> breakScratch;
  final Value<bool> breakFoul;
  final Value<int> easyMissCount;
  final Value<int> hardMissCount;
  final Value<int> scratchErrorCount;
  final Value<int> positionErrorCount;
  final Value<int> safetyErrorCount;
  final Value<int> kickErrorCount;
  final Value<int> jumpErrorCount;
  final Value<String> bestStrengths;
  final Value<String> biggestMistakes;
  const RacksCompanion({
    this.id = const Value.absent(),
    this.matchId = const Value.absent(),
    this.rackNumber = const Value.absent(),
    this.result = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.biggestMistake = const Value.absent(),
    this.biggestStrength = const Value.absent(),
    this.confidence = const Value.absent(),
    this.ballsPotted = const Value.absent(),
    this.largestRun = const Value.absent(),
    this.breakSuccess = const Value.absent(),
    this.breakScratch = const Value.absent(),
    this.breakFoul = const Value.absent(),
    this.easyMissCount = const Value.absent(),
    this.hardMissCount = const Value.absent(),
    this.scratchErrorCount = const Value.absent(),
    this.positionErrorCount = const Value.absent(),
    this.safetyErrorCount = const Value.absent(),
    this.kickErrorCount = const Value.absent(),
    this.jumpErrorCount = const Value.absent(),
    this.bestStrengths = const Value.absent(),
    this.biggestMistakes = const Value.absent(),
  });
  RacksCompanion.insert({
    this.id = const Value.absent(),
    required int matchId,
    required int rackNumber,
    required bool result,
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.biggestMistake = const Value.absent(),
    this.biggestStrength = const Value.absent(),
    this.confidence = const Value.absent(),
    this.ballsPotted = const Value.absent(),
    this.largestRun = const Value.absent(),
    this.breakSuccess = const Value.absent(),
    this.breakScratch = const Value.absent(),
    this.breakFoul = const Value.absent(),
    this.easyMissCount = const Value.absent(),
    this.hardMissCount = const Value.absent(),
    this.scratchErrorCount = const Value.absent(),
    this.positionErrorCount = const Value.absent(),
    this.safetyErrorCount = const Value.absent(),
    this.kickErrorCount = const Value.absent(),
    this.jumpErrorCount = const Value.absent(),
    this.bestStrengths = const Value.absent(),
    this.biggestMistakes = const Value.absent(),
  })  : matchId = Value(matchId),
        rackNumber = Value(rackNumber),
        result = Value(result);
  static Insertable<Rack> custom({
    Expression<int>? id,
    Expression<int>? matchId,
    Expression<int>? rackNumber,
    Expression<bool>? result,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<String>? biggestMistake,
    Expression<String>? biggestStrength,
    Expression<int>? confidence,
    Expression<int>? ballsPotted,
    Expression<int>? largestRun,
    Expression<bool>? breakSuccess,
    Expression<bool>? breakScratch,
    Expression<bool>? breakFoul,
    Expression<int>? easyMissCount,
    Expression<int>? hardMissCount,
    Expression<int>? scratchErrorCount,
    Expression<int>? positionErrorCount,
    Expression<int>? safetyErrorCount,
    Expression<int>? kickErrorCount,
    Expression<int>? jumpErrorCount,
    Expression<String>? bestStrengths,
    Expression<String>? biggestMistakes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (matchId != null) 'match_id': matchId,
      if (rackNumber != null) 'rack_number': rackNumber,
      if (result != null) 'result': result,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (biggestMistake != null) 'biggest_mistake': biggestMistake,
      if (biggestStrength != null) 'biggest_strength': biggestStrength,
      if (confidence != null) 'confidence': confidence,
      if (ballsPotted != null) 'balls_potted': ballsPotted,
      if (largestRun != null) 'largest_run': largestRun,
      if (breakSuccess != null) 'break_success': breakSuccess,
      if (breakScratch != null) 'break_scratch': breakScratch,
      if (breakFoul != null) 'break_foul': breakFoul,
      if (easyMissCount != null) 'easy_miss_count': easyMissCount,
      if (hardMissCount != null) 'hard_miss_count': hardMissCount,
      if (scratchErrorCount != null) 'scratch_error_count': scratchErrorCount,
      if (positionErrorCount != null)
        'position_error_count': positionErrorCount,
      if (safetyErrorCount != null) 'safety_error_count': safetyErrorCount,
      if (kickErrorCount != null) 'kick_error_count': kickErrorCount,
      if (jumpErrorCount != null) 'jump_error_count': jumpErrorCount,
      if (bestStrengths != null) 'best_strengths': bestStrengths,
      if (biggestMistakes != null) 'biggest_mistakes': biggestMistakes,
    });
  }

  RacksCompanion copyWith(
      {Value<int>? id,
      Value<int>? matchId,
      Value<int>? rackNumber,
      Value<bool>? result,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<String?>? biggestMistake,
      Value<String?>? biggestStrength,
      Value<int?>? confidence,
      Value<int>? ballsPotted,
      Value<int>? largestRun,
      Value<bool>? breakSuccess,
      Value<bool>? breakScratch,
      Value<bool>? breakFoul,
      Value<int>? easyMissCount,
      Value<int>? hardMissCount,
      Value<int>? scratchErrorCount,
      Value<int>? positionErrorCount,
      Value<int>? safetyErrorCount,
      Value<int>? kickErrorCount,
      Value<int>? jumpErrorCount,
      Value<String>? bestStrengths,
      Value<String>? biggestMistakes}) {
    return RacksCompanion(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      rackNumber: rackNumber ?? this.rackNumber,
      result: result ?? this.result,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      biggestMistake: biggestMistake ?? this.biggestMistake,
      biggestStrength: biggestStrength ?? this.biggestStrength,
      confidence: confidence ?? this.confidence,
      ballsPotted: ballsPotted ?? this.ballsPotted,
      largestRun: largestRun ?? this.largestRun,
      breakSuccess: breakSuccess ?? this.breakSuccess,
      breakScratch: breakScratch ?? this.breakScratch,
      breakFoul: breakFoul ?? this.breakFoul,
      easyMissCount: easyMissCount ?? this.easyMissCount,
      hardMissCount: hardMissCount ?? this.hardMissCount,
      scratchErrorCount: scratchErrorCount ?? this.scratchErrorCount,
      positionErrorCount: positionErrorCount ?? this.positionErrorCount,
      safetyErrorCount: safetyErrorCount ?? this.safetyErrorCount,
      kickErrorCount: kickErrorCount ?? this.kickErrorCount,
      jumpErrorCount: jumpErrorCount ?? this.jumpErrorCount,
      bestStrengths: bestStrengths ?? this.bestStrengths,
      biggestMistakes: biggestMistakes ?? this.biggestMistakes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (matchId.present) {
      map['match_id'] = Variable<int>(matchId.value);
    }
    if (rackNumber.present) {
      map['rack_number'] = Variable<int>(rackNumber.value);
    }
    if (result.present) {
      map['result'] = Variable<bool>(result.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (biggestMistake.present) {
      map['biggest_mistake'] = Variable<String>(biggestMistake.value);
    }
    if (biggestStrength.present) {
      map['biggest_strength'] = Variable<String>(biggestStrength.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<int>(confidence.value);
    }
    if (ballsPotted.present) {
      map['balls_potted'] = Variable<int>(ballsPotted.value);
    }
    if (largestRun.present) {
      map['largest_run'] = Variable<int>(largestRun.value);
    }
    if (breakSuccess.present) {
      map['break_success'] = Variable<bool>(breakSuccess.value);
    }
    if (breakScratch.present) {
      map['break_scratch'] = Variable<bool>(breakScratch.value);
    }
    if (breakFoul.present) {
      map['break_foul'] = Variable<bool>(breakFoul.value);
    }
    if (easyMissCount.present) {
      map['easy_miss_count'] = Variable<int>(easyMissCount.value);
    }
    if (hardMissCount.present) {
      map['hard_miss_count'] = Variable<int>(hardMissCount.value);
    }
    if (scratchErrorCount.present) {
      map['scratch_error_count'] = Variable<int>(scratchErrorCount.value);
    }
    if (positionErrorCount.present) {
      map['position_error_count'] = Variable<int>(positionErrorCount.value);
    }
    if (safetyErrorCount.present) {
      map['safety_error_count'] = Variable<int>(safetyErrorCount.value);
    }
    if (kickErrorCount.present) {
      map['kick_error_count'] = Variable<int>(kickErrorCount.value);
    }
    if (jumpErrorCount.present) {
      map['jump_error_count'] = Variable<int>(jumpErrorCount.value);
    }
    if (bestStrengths.present) {
      map['best_strengths'] = Variable<String>(bestStrengths.value);
    }
    if (biggestMistakes.present) {
      map['biggest_mistakes'] = Variable<String>(biggestMistakes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RacksCompanion(')
          ..write('id: $id, ')
          ..write('matchId: $matchId, ')
          ..write('rackNumber: $rackNumber, ')
          ..write('result: $result, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('biggestMistake: $biggestMistake, ')
          ..write('biggestStrength: $biggestStrength, ')
          ..write('confidence: $confidence, ')
          ..write('ballsPotted: $ballsPotted, ')
          ..write('largestRun: $largestRun, ')
          ..write('breakSuccess: $breakSuccess, ')
          ..write('breakScratch: $breakScratch, ')
          ..write('breakFoul: $breakFoul, ')
          ..write('easyMissCount: $easyMissCount, ')
          ..write('hardMissCount: $hardMissCount, ')
          ..write('scratchErrorCount: $scratchErrorCount, ')
          ..write('positionErrorCount: $positionErrorCount, ')
          ..write('safetyErrorCount: $safetyErrorCount, ')
          ..write('kickErrorCount: $kickErrorCount, ')
          ..write('jumpErrorCount: $jumpErrorCount, ')
          ..write('bestStrengths: $bestStrengths, ')
          ..write('biggestMistakes: $biggestMistakes')
          ..write(')'))
        .toString();
  }
}

class $ShotsTable extends Shots with TableInfo<$ShotsTable, Shot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _rackIdMeta = const VerificationMeta('rackId');
  @override
  late final GeneratedColumn<int> rackId = GeneratedColumn<int>(
      'rack_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES racks (id)'));
  static const VerificationMeta _shotNumberMeta =
      const VerificationMeta('shotNumber');
  @override
  late final GeneratedColumn<int> shotNumber = GeneratedColumn<int>(
      'shot_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _shotTypeMeta =
      const VerificationMeta('shotType');
  @override
  late final GeneratedColumn<String> shotType = GeneratedColumn<String>(
      'shot_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _difficultyMeta =
      const VerificationMeta('difficulty');
  @override
  late final GeneratedColumn<String> difficulty = GeneratedColumn<String>(
      'difficulty', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _resultMeta = const VerificationMeta('result');
  @override
  late final GeneratedColumn<String> result = GeneratedColumn<String>(
      'result', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _positionQualityMeta =
      const VerificationMeta('positionQuality');
  @override
  late final GeneratedColumn<String> positionQuality = GeneratedColumn<String>(
      'position_quality', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _decisionMeta =
      const VerificationMeta('decision');
  @override
  late final GeneratedColumn<String> decision = GeneratedColumn<String>(
      'decision', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _confidenceMeta =
      const VerificationMeta('confidence');
  @override
  late final GeneratedColumn<String> confidence = GeneratedColumn<String>(
      'confidence', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _playerNoteMeta =
      const VerificationMeta('playerNote');
  @override
  late final GeneratedColumn<String> playerNote = GeneratedColumn<String>(
      'player_note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        rackId,
        shotNumber,
        shotType,
        difficulty,
        result,
        positionQuality,
        decision,
        confidence,
        playerNote,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shots';
  @override
  VerificationContext validateIntegrity(Insertable<Shot> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('rack_id')) {
      context.handle(_rackIdMeta,
          rackId.isAcceptableOrUnknown(data['rack_id']!, _rackIdMeta));
    } else if (isInserting) {
      context.missing(_rackIdMeta);
    }
    if (data.containsKey('shot_number')) {
      context.handle(
          _shotNumberMeta,
          shotNumber.isAcceptableOrUnknown(
              data['shot_number']!, _shotNumberMeta));
    } else if (isInserting) {
      context.missing(_shotNumberMeta);
    }
    if (data.containsKey('shot_type')) {
      context.handle(_shotTypeMeta,
          shotType.isAcceptableOrUnknown(data['shot_type']!, _shotTypeMeta));
    } else if (isInserting) {
      context.missing(_shotTypeMeta);
    }
    if (data.containsKey('difficulty')) {
      context.handle(
          _difficultyMeta,
          difficulty.isAcceptableOrUnknown(
              data['difficulty']!, _difficultyMeta));
    } else if (isInserting) {
      context.missing(_difficultyMeta);
    }
    if (data.containsKey('result')) {
      context.handle(_resultMeta,
          result.isAcceptableOrUnknown(data['result']!, _resultMeta));
    } else if (isInserting) {
      context.missing(_resultMeta);
    }
    if (data.containsKey('position_quality')) {
      context.handle(
          _positionQualityMeta,
          positionQuality.isAcceptableOrUnknown(
              data['position_quality']!, _positionQualityMeta));
    }
    if (data.containsKey('decision')) {
      context.handle(_decisionMeta,
          decision.isAcceptableOrUnknown(data['decision']!, _decisionMeta));
    }
    if (data.containsKey('confidence')) {
      context.handle(
          _confidenceMeta,
          confidence.isAcceptableOrUnknown(
              data['confidence']!, _confidenceMeta));
    }
    if (data.containsKey('player_note')) {
      context.handle(
          _playerNoteMeta,
          playerNote.isAcceptableOrUnknown(
              data['player_note']!, _playerNoteMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Shot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Shot(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      rackId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rack_id'])!,
      shotNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}shot_number'])!,
      shotType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}shot_type'])!,
      difficulty: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}difficulty'])!,
      result: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}result'])!,
      positionQuality: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}position_quality']),
      decision: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}decision']),
      confidence: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}confidence']),
      playerNote: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}player_note']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ShotsTable createAlias(String alias) {
    return $ShotsTable(attachedDatabase, alias);
  }
}

class Shot extends DataClass implements Insertable<Shot> {
  final int id;
  final int rackId;
  final int shotNumber;
  final String shotType;
  final String difficulty;
  final String result;
  final String? positionQuality;
  final String? decision;
  final String? confidence;
  final String? playerNote;
  final DateTime createdAt;
  const Shot(
      {required this.id,
      required this.rackId,
      required this.shotNumber,
      required this.shotType,
      required this.difficulty,
      required this.result,
      this.positionQuality,
      this.decision,
      this.confidence,
      this.playerNote,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['rack_id'] = Variable<int>(rackId);
    map['shot_number'] = Variable<int>(shotNumber);
    map['shot_type'] = Variable<String>(shotType);
    map['difficulty'] = Variable<String>(difficulty);
    map['result'] = Variable<String>(result);
    if (!nullToAbsent || positionQuality != null) {
      map['position_quality'] = Variable<String>(positionQuality);
    }
    if (!nullToAbsent || decision != null) {
      map['decision'] = Variable<String>(decision);
    }
    if (!nullToAbsent || confidence != null) {
      map['confidence'] = Variable<String>(confidence);
    }
    if (!nullToAbsent || playerNote != null) {
      map['player_note'] = Variable<String>(playerNote);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ShotsCompanion toCompanion(bool nullToAbsent) {
    return ShotsCompanion(
      id: Value(id),
      rackId: Value(rackId),
      shotNumber: Value(shotNumber),
      shotType: Value(shotType),
      difficulty: Value(difficulty),
      result: Value(result),
      positionQuality: positionQuality == null && nullToAbsent
          ? const Value.absent()
          : Value(positionQuality),
      decision: decision == null && nullToAbsent
          ? const Value.absent()
          : Value(decision),
      confidence: confidence == null && nullToAbsent
          ? const Value.absent()
          : Value(confidence),
      playerNote: playerNote == null && nullToAbsent
          ? const Value.absent()
          : Value(playerNote),
      createdAt: Value(createdAt),
    );
  }

  factory Shot.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Shot(
      id: serializer.fromJson<int>(json['id']),
      rackId: serializer.fromJson<int>(json['rackId']),
      shotNumber: serializer.fromJson<int>(json['shotNumber']),
      shotType: serializer.fromJson<String>(json['shotType']),
      difficulty: serializer.fromJson<String>(json['difficulty']),
      result: serializer.fromJson<String>(json['result']),
      positionQuality: serializer.fromJson<String?>(json['positionQuality']),
      decision: serializer.fromJson<String?>(json['decision']),
      confidence: serializer.fromJson<String?>(json['confidence']),
      playerNote: serializer.fromJson<String?>(json['playerNote']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'rackId': serializer.toJson<int>(rackId),
      'shotNumber': serializer.toJson<int>(shotNumber),
      'shotType': serializer.toJson<String>(shotType),
      'difficulty': serializer.toJson<String>(difficulty),
      'result': serializer.toJson<String>(result),
      'positionQuality': serializer.toJson<String?>(positionQuality),
      'decision': serializer.toJson<String?>(decision),
      'confidence': serializer.toJson<String?>(confidence),
      'playerNote': serializer.toJson<String?>(playerNote),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Shot copyWith(
          {int? id,
          int? rackId,
          int? shotNumber,
          String? shotType,
          String? difficulty,
          String? result,
          Value<String?> positionQuality = const Value.absent(),
          Value<String?> decision = const Value.absent(),
          Value<String?> confidence = const Value.absent(),
          Value<String?> playerNote = const Value.absent(),
          DateTime? createdAt}) =>
      Shot(
        id: id ?? this.id,
        rackId: rackId ?? this.rackId,
        shotNumber: shotNumber ?? this.shotNumber,
        shotType: shotType ?? this.shotType,
        difficulty: difficulty ?? this.difficulty,
        result: result ?? this.result,
        positionQuality: positionQuality.present
            ? positionQuality.value
            : this.positionQuality,
        decision: decision.present ? decision.value : this.decision,
        confidence: confidence.present ? confidence.value : this.confidence,
        playerNote: playerNote.present ? playerNote.value : this.playerNote,
        createdAt: createdAt ?? this.createdAt,
      );
  Shot copyWithCompanion(ShotsCompanion data) {
    return Shot(
      id: data.id.present ? data.id.value : this.id,
      rackId: data.rackId.present ? data.rackId.value : this.rackId,
      shotNumber:
          data.shotNumber.present ? data.shotNumber.value : this.shotNumber,
      shotType: data.shotType.present ? data.shotType.value : this.shotType,
      difficulty:
          data.difficulty.present ? data.difficulty.value : this.difficulty,
      result: data.result.present ? data.result.value : this.result,
      positionQuality: data.positionQuality.present
          ? data.positionQuality.value
          : this.positionQuality,
      decision: data.decision.present ? data.decision.value : this.decision,
      confidence:
          data.confidence.present ? data.confidence.value : this.confidence,
      playerNote:
          data.playerNote.present ? data.playerNote.value : this.playerNote,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Shot(')
          ..write('id: $id, ')
          ..write('rackId: $rackId, ')
          ..write('shotNumber: $shotNumber, ')
          ..write('shotType: $shotType, ')
          ..write('difficulty: $difficulty, ')
          ..write('result: $result, ')
          ..write('positionQuality: $positionQuality, ')
          ..write('decision: $decision, ')
          ..write('confidence: $confidence, ')
          ..write('playerNote: $playerNote, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, rackId, shotNumber, shotType, difficulty,
      result, positionQuality, decision, confidence, playerNote, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Shot &&
          other.id == this.id &&
          other.rackId == this.rackId &&
          other.shotNumber == this.shotNumber &&
          other.shotType == this.shotType &&
          other.difficulty == this.difficulty &&
          other.result == this.result &&
          other.positionQuality == this.positionQuality &&
          other.decision == this.decision &&
          other.confidence == this.confidence &&
          other.playerNote == this.playerNote &&
          other.createdAt == this.createdAt);
}

class ShotsCompanion extends UpdateCompanion<Shot> {
  final Value<int> id;
  final Value<int> rackId;
  final Value<int> shotNumber;
  final Value<String> shotType;
  final Value<String> difficulty;
  final Value<String> result;
  final Value<String?> positionQuality;
  final Value<String?> decision;
  final Value<String?> confidence;
  final Value<String?> playerNote;
  final Value<DateTime> createdAt;
  const ShotsCompanion({
    this.id = const Value.absent(),
    this.rackId = const Value.absent(),
    this.shotNumber = const Value.absent(),
    this.shotType = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.result = const Value.absent(),
    this.positionQuality = const Value.absent(),
    this.decision = const Value.absent(),
    this.confidence = const Value.absent(),
    this.playerNote = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ShotsCompanion.insert({
    this.id = const Value.absent(),
    required int rackId,
    required int shotNumber,
    required String shotType,
    required String difficulty,
    required String result,
    this.positionQuality = const Value.absent(),
    this.decision = const Value.absent(),
    this.confidence = const Value.absent(),
    this.playerNote = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : rackId = Value(rackId),
        shotNumber = Value(shotNumber),
        shotType = Value(shotType),
        difficulty = Value(difficulty),
        result = Value(result);
  static Insertable<Shot> custom({
    Expression<int>? id,
    Expression<int>? rackId,
    Expression<int>? shotNumber,
    Expression<String>? shotType,
    Expression<String>? difficulty,
    Expression<String>? result,
    Expression<String>? positionQuality,
    Expression<String>? decision,
    Expression<String>? confidence,
    Expression<String>? playerNote,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rackId != null) 'rack_id': rackId,
      if (shotNumber != null) 'shot_number': shotNumber,
      if (shotType != null) 'shot_type': shotType,
      if (difficulty != null) 'difficulty': difficulty,
      if (result != null) 'result': result,
      if (positionQuality != null) 'position_quality': positionQuality,
      if (decision != null) 'decision': decision,
      if (confidence != null) 'confidence': confidence,
      if (playerNote != null) 'player_note': playerNote,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ShotsCompanion copyWith(
      {Value<int>? id,
      Value<int>? rackId,
      Value<int>? shotNumber,
      Value<String>? shotType,
      Value<String>? difficulty,
      Value<String>? result,
      Value<String?>? positionQuality,
      Value<String?>? decision,
      Value<String?>? confidence,
      Value<String?>? playerNote,
      Value<DateTime>? createdAt}) {
    return ShotsCompanion(
      id: id ?? this.id,
      rackId: rackId ?? this.rackId,
      shotNumber: shotNumber ?? this.shotNumber,
      shotType: shotType ?? this.shotType,
      difficulty: difficulty ?? this.difficulty,
      result: result ?? this.result,
      positionQuality: positionQuality ?? this.positionQuality,
      decision: decision ?? this.decision,
      confidence: confidence ?? this.confidence,
      playerNote: playerNote ?? this.playerNote,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (rackId.present) {
      map['rack_id'] = Variable<int>(rackId.value);
    }
    if (shotNumber.present) {
      map['shot_number'] = Variable<int>(shotNumber.value);
    }
    if (shotType.present) {
      map['shot_type'] = Variable<String>(shotType.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<String>(difficulty.value);
    }
    if (result.present) {
      map['result'] = Variable<String>(result.value);
    }
    if (positionQuality.present) {
      map['position_quality'] = Variable<String>(positionQuality.value);
    }
    if (decision.present) {
      map['decision'] = Variable<String>(decision.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<String>(confidence.value);
    }
    if (playerNote.present) {
      map['player_note'] = Variable<String>(playerNote.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShotsCompanion(')
          ..write('id: $id, ')
          ..write('rackId: $rackId, ')
          ..write('shotNumber: $shotNumber, ')
          ..write('shotType: $shotType, ')
          ..write('difficulty: $difficulty, ')
          ..write('result: $result, ')
          ..write('positionQuality: $positionQuality, ')
          ..write('decision: $decision, ')
          ..write('confidence: $confidence, ')
          ..write('playerNote: $playerNote, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $EventsTable extends Events with TableInfo<$EventsTable, Event> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _shotIdMeta = const VerificationMeta('shotId');
  @override
  late final GeneratedColumn<int> shotId = GeneratedColumn<int>(
      'shot_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES shots (id)'));
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _severityMeta =
      const VerificationMeta('severity');
  @override
  late final GeneratedColumn<String> severity = GeneratedColumn<String>(
      'severity', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _confidenceMeta =
      const VerificationMeta('confidence');
  @override
  late final GeneratedColumn<String> confidence = GeneratedColumn<String>(
      'confidence', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _metadataJsonMeta =
      const VerificationMeta('metadataJson');
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
      'metadata_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        shotId,
        category,
        type,
        severity,
        confidence,
        metadataJson,
        notes,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'events';
  @override
  VerificationContext validateIntegrity(Insertable<Event> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('shot_id')) {
      context.handle(_shotIdMeta,
          shotId.isAcceptableOrUnknown(data['shot_id']!, _shotIdMeta));
    } else if (isInserting) {
      context.missing(_shotIdMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('severity')) {
      context.handle(_severityMeta,
          severity.isAcceptableOrUnknown(data['severity']!, _severityMeta));
    }
    if (data.containsKey('confidence')) {
      context.handle(
          _confidenceMeta,
          confidence.isAcceptableOrUnknown(
              data['confidence']!, _confidenceMeta));
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
          _metadataJsonMeta,
          metadataJson.isAcceptableOrUnknown(
              data['metadata_json']!, _metadataJsonMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Event map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Event(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      shotId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}shot_id'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      severity: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}severity']),
      confidence: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}confidence']),
      metadataJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metadata_json']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $EventsTable createAlias(String alias) {
    return $EventsTable(attachedDatabase, alias);
  }
}

class Event extends DataClass implements Insertable<Event> {
  final int id;
  final int shotId;
  final String category;
  final String type;
  final String? severity;
  final String? confidence;
  final String? metadataJson;
  final String? notes;
  final DateTime createdAt;
  const Event(
      {required this.id,
      required this.shotId,
      required this.category,
      required this.type,
      this.severity,
      this.confidence,
      this.metadataJson,
      this.notes,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['shot_id'] = Variable<int>(shotId);
    map['category'] = Variable<String>(category);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || severity != null) {
      map['severity'] = Variable<String>(severity);
    }
    if (!nullToAbsent || confidence != null) {
      map['confidence'] = Variable<String>(confidence);
    }
    if (!nullToAbsent || metadataJson != null) {
      map['metadata_json'] = Variable<String>(metadataJson);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  EventsCompanion toCompanion(bool nullToAbsent) {
    return EventsCompanion(
      id: Value(id),
      shotId: Value(shotId),
      category: Value(category),
      type: Value(type),
      severity: severity == null && nullToAbsent
          ? const Value.absent()
          : Value(severity),
      confidence: confidence == null && nullToAbsent
          ? const Value.absent()
          : Value(confidence),
      metadataJson: metadataJson == null && nullToAbsent
          ? const Value.absent()
          : Value(metadataJson),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory Event.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Event(
      id: serializer.fromJson<int>(json['id']),
      shotId: serializer.fromJson<int>(json['shotId']),
      category: serializer.fromJson<String>(json['category']),
      type: serializer.fromJson<String>(json['type']),
      severity: serializer.fromJson<String?>(json['severity']),
      confidence: serializer.fromJson<String?>(json['confidence']),
      metadataJson: serializer.fromJson<String?>(json['metadataJson']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'shotId': serializer.toJson<int>(shotId),
      'category': serializer.toJson<String>(category),
      'type': serializer.toJson<String>(type),
      'severity': serializer.toJson<String?>(severity),
      'confidence': serializer.toJson<String?>(confidence),
      'metadataJson': serializer.toJson<String?>(metadataJson),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Event copyWith(
          {int? id,
          int? shotId,
          String? category,
          String? type,
          Value<String?> severity = const Value.absent(),
          Value<String?> confidence = const Value.absent(),
          Value<String?> metadataJson = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt}) =>
      Event(
        id: id ?? this.id,
        shotId: shotId ?? this.shotId,
        category: category ?? this.category,
        type: type ?? this.type,
        severity: severity.present ? severity.value : this.severity,
        confidence: confidence.present ? confidence.value : this.confidence,
        metadataJson:
            metadataJson.present ? metadataJson.value : this.metadataJson,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
      );
  Event copyWithCompanion(EventsCompanion data) {
    return Event(
      id: data.id.present ? data.id.value : this.id,
      shotId: data.shotId.present ? data.shotId.value : this.shotId,
      category: data.category.present ? data.category.value : this.category,
      type: data.type.present ? data.type.value : this.type,
      severity: data.severity.present ? data.severity.value : this.severity,
      confidence:
          data.confidence.present ? data.confidence.value : this.confidence,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Event(')
          ..write('id: $id, ')
          ..write('shotId: $shotId, ')
          ..write('category: $category, ')
          ..write('type: $type, ')
          ..write('severity: $severity, ')
          ..write('confidence: $confidence, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, shotId, category, type, severity,
      confidence, metadataJson, notes, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Event &&
          other.id == this.id &&
          other.shotId == this.shotId &&
          other.category == this.category &&
          other.type == this.type &&
          other.severity == this.severity &&
          other.confidence == this.confidence &&
          other.metadataJson == this.metadataJson &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class EventsCompanion extends UpdateCompanion<Event> {
  final Value<int> id;
  final Value<int> shotId;
  final Value<String> category;
  final Value<String> type;
  final Value<String?> severity;
  final Value<String?> confidence;
  final Value<String?> metadataJson;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  const EventsCompanion({
    this.id = const Value.absent(),
    this.shotId = const Value.absent(),
    this.category = const Value.absent(),
    this.type = const Value.absent(),
    this.severity = const Value.absent(),
    this.confidence = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  EventsCompanion.insert({
    this.id = const Value.absent(),
    required int shotId,
    required String category,
    required String type,
    this.severity = const Value.absent(),
    this.confidence = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : shotId = Value(shotId),
        category = Value(category),
        type = Value(type);
  static Insertable<Event> custom({
    Expression<int>? id,
    Expression<int>? shotId,
    Expression<String>? category,
    Expression<String>? type,
    Expression<String>? severity,
    Expression<String>? confidence,
    Expression<String>? metadataJson,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shotId != null) 'shot_id': shotId,
      if (category != null) 'category': category,
      if (type != null) 'type': type,
      if (severity != null) 'severity': severity,
      if (confidence != null) 'confidence': confidence,
      if (metadataJson != null) 'metadata_json': metadataJson,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  EventsCompanion copyWith(
      {Value<int>? id,
      Value<int>? shotId,
      Value<String>? category,
      Value<String>? type,
      Value<String?>? severity,
      Value<String?>? confidence,
      Value<String?>? metadataJson,
      Value<String?>? notes,
      Value<DateTime>? createdAt}) {
    return EventsCompanion(
      id: id ?? this.id,
      shotId: shotId ?? this.shotId,
      category: category ?? this.category,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      confidence: confidence ?? this.confidence,
      metadataJson: metadataJson ?? this.metadataJson,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (shotId.present) {
      map['shot_id'] = Variable<int>(shotId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (severity.present) {
      map['severity'] = Variable<String>(severity.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<String>(confidence.value);
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventsCompanion(')
          ..write('id: $id, ')
          ..write('shotId: $shotId, ')
          ..write('category: $category, ')
          ..write('type: $type, ')
          ..write('severity: $severity, ')
          ..write('confidence: $confidence, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ConversationsTable extends Conversations
    with TableInfo<$ConversationsTable, Conversation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConversationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastMessageMeta =
      const VerificationMeta('lastMessage');
  @override
  late final GeneratedColumn<String> lastMessage = GeneratedColumn<String>(
      'last_message', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastMessageAtMeta =
      const VerificationMeta('lastMessageAt');
  @override
  late final GeneratedColumn<DateTime> lastMessageAt =
      GeneratedColumn<DateTime>('last_message_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _unreadCountMeta =
      const VerificationMeta('unreadCount');
  @override
  late final GeneratedColumn<int> unreadCount = GeneratedColumn<int>(
      'unread_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        lastMessage,
        lastMessageAt,
        unreadCount,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conversations';
  @override
  VerificationContext validateIntegrity(Insertable<Conversation> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('last_message')) {
      context.handle(
          _lastMessageMeta,
          lastMessage.isAcceptableOrUnknown(
              data['last_message']!, _lastMessageMeta));
    }
    if (data.containsKey('last_message_at')) {
      context.handle(
          _lastMessageAtMeta,
          lastMessageAt.isAcceptableOrUnknown(
              data['last_message_at']!, _lastMessageAtMeta));
    }
    if (data.containsKey('unread_count')) {
      context.handle(
          _unreadCountMeta,
          unreadCount.isAcceptableOrUnknown(
              data['unread_count']!, _unreadCountMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Conversation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Conversation(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      lastMessage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_message']),
      lastMessageAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_message_at']),
      unreadCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}unread_count'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ConversationsTable createAlias(String alias) {
    return $ConversationsTable(attachedDatabase, alias);
  }
}

class Conversation extends DataClass implements Insertable<Conversation> {
  final int id;
  final String title;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Conversation(
      {required this.id,
      required this.title,
      this.lastMessage,
      this.lastMessageAt,
      required this.unreadCount,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || lastMessage != null) {
      map['last_message'] = Variable<String>(lastMessage);
    }
    if (!nullToAbsent || lastMessageAt != null) {
      map['last_message_at'] = Variable<DateTime>(lastMessageAt);
    }
    map['unread_count'] = Variable<int>(unreadCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ConversationsCompanion toCompanion(bool nullToAbsent) {
    return ConversationsCompanion(
      id: Value(id),
      title: Value(title),
      lastMessage: lastMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessage),
      lastMessageAt: lastMessageAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageAt),
      unreadCount: Value(unreadCount),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Conversation.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Conversation(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      lastMessage: serializer.fromJson<String?>(json['lastMessage']),
      lastMessageAt: serializer.fromJson<DateTime?>(json['lastMessageAt']),
      unreadCount: serializer.fromJson<int>(json['unreadCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'lastMessage': serializer.toJson<String?>(lastMessage),
      'lastMessageAt': serializer.toJson<DateTime?>(lastMessageAt),
      'unreadCount': serializer.toJson<int>(unreadCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Conversation copyWith(
          {int? id,
          String? title,
          Value<String?> lastMessage = const Value.absent(),
          Value<DateTime?> lastMessageAt = const Value.absent(),
          int? unreadCount,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Conversation(
        id: id ?? this.id,
        title: title ?? this.title,
        lastMessage: lastMessage.present ? lastMessage.value : this.lastMessage,
        lastMessageAt:
            lastMessageAt.present ? lastMessageAt.value : this.lastMessageAt,
        unreadCount: unreadCount ?? this.unreadCount,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Conversation copyWithCompanion(ConversationsCompanion data) {
    return Conversation(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      lastMessage:
          data.lastMessage.present ? data.lastMessage.value : this.lastMessage,
      lastMessageAt: data.lastMessageAt.present
          ? data.lastMessageAt.value
          : this.lastMessageAt,
      unreadCount:
          data.unreadCount.present ? data.unreadCount.value : this.unreadCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Conversation(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('lastMessage: $lastMessage, ')
          ..write('lastMessageAt: $lastMessageAt, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, title, lastMessage, lastMessageAt, unreadCount, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Conversation &&
          other.id == this.id &&
          other.title == this.title &&
          other.lastMessage == this.lastMessage &&
          other.lastMessageAt == this.lastMessageAt &&
          other.unreadCount == this.unreadCount &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ConversationsCompanion extends UpdateCompanion<Conversation> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> lastMessage;
  final Value<DateTime?> lastMessageAt;
  final Value<int> unreadCount;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const ConversationsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.lastMessage = const Value.absent(),
    this.lastMessageAt = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ConversationsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.lastMessage = const Value.absent(),
    this.lastMessageAt = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : title = Value(title);
  static Insertable<Conversation> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? lastMessage,
    Expression<DateTime>? lastMessageAt,
    Expression<int>? unreadCount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (lastMessage != null) 'last_message': lastMessage,
      if (lastMessageAt != null) 'last_message_at': lastMessageAt,
      if (unreadCount != null) 'unread_count': unreadCount,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ConversationsCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<String?>? lastMessage,
      Value<DateTime?>? lastMessageAt,
      Value<int>? unreadCount,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return ConversationsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (lastMessage.present) {
      map['last_message'] = Variable<String>(lastMessage.value);
    }
    if (lastMessageAt.present) {
      map['last_message_at'] = Variable<DateTime>(lastMessageAt.value);
    }
    if (unreadCount.present) {
      map['unread_count'] = Variable<int>(unreadCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConversationsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('lastMessage: $lastMessage, ')
          ..write('lastMessageAt: $lastMessageAt, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $MessagesTable extends Messages with TableInfo<$MessagesTable, Message> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _conversationIdMeta =
      const VerificationMeta('conversationId');
  @override
  late final GeneratedColumn<int> conversationId = GeneratedColumn<int>(
      'conversation_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES conversations (id)'));
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isFromUserMeta =
      const VerificationMeta('isFromUser');
  @override
  late final GeneratedColumn<bool> isFromUser = GeneratedColumn<bool>(
      'is_from_user', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_from_user" IN (0, 1))'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, conversationId, content, isFromUser, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(Insertable<Message> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
          _conversationIdMeta,
          conversationId.isAcceptableOrUnknown(
              data['conversation_id']!, _conversationIdMeta));
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('is_from_user')) {
      context.handle(
          _isFromUserMeta,
          isFromUser.isAcceptableOrUnknown(
              data['is_from_user']!, _isFromUserMeta));
    } else if (isInserting) {
      context.missing(_isFromUserMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Message map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Message(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      conversationId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}conversation_id'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      isFromUser: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_from_user'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }
}

class Message extends DataClass implements Insertable<Message> {
  final int id;
  final int conversationId;
  final String content;
  final bool isFromUser;
  final DateTime createdAt;
  const Message(
      {required this.id,
      required this.conversationId,
      required this.content,
      required this.isFromUser,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['conversation_id'] = Variable<int>(conversationId);
    map['content'] = Variable<String>(content);
    map['is_from_user'] = Variable<bool>(isFromUser);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      id: Value(id),
      conversationId: Value(conversationId),
      content: Value(content),
      isFromUser: Value(isFromUser),
      createdAt: Value(createdAt),
    );
  }

  factory Message.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Message(
      id: serializer.fromJson<int>(json['id']),
      conversationId: serializer.fromJson<int>(json['conversationId']),
      content: serializer.fromJson<String>(json['content']),
      isFromUser: serializer.fromJson<bool>(json['isFromUser']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'conversationId': serializer.toJson<int>(conversationId),
      'content': serializer.toJson<String>(content),
      'isFromUser': serializer.toJson<bool>(isFromUser),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Message copyWith(
          {int? id,
          int? conversationId,
          String? content,
          bool? isFromUser,
          DateTime? createdAt}) =>
      Message(
        id: id ?? this.id,
        conversationId: conversationId ?? this.conversationId,
        content: content ?? this.content,
        isFromUser: isFromUser ?? this.isFromUser,
        createdAt: createdAt ?? this.createdAt,
      );
  Message copyWithCompanion(MessagesCompanion data) {
    return Message(
      id: data.id.present ? data.id.value : this.id,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      content: data.content.present ? data.content.value : this.content,
      isFromUser:
          data.isFromUser.present ? data.isFromUser.value : this.isFromUser,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Message(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('content: $content, ')
          ..write('isFromUser: $isFromUser, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, conversationId, content, isFromUser, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Message &&
          other.id == this.id &&
          other.conversationId == this.conversationId &&
          other.content == this.content &&
          other.isFromUser == this.isFromUser &&
          other.createdAt == this.createdAt);
}

class MessagesCompanion extends UpdateCompanion<Message> {
  final Value<int> id;
  final Value<int> conversationId;
  final Value<String> content;
  final Value<bool> isFromUser;
  final Value<DateTime> createdAt;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.content = const Value.absent(),
    this.isFromUser = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MessagesCompanion.insert({
    this.id = const Value.absent(),
    required int conversationId,
    required String content,
    required bool isFromUser,
    this.createdAt = const Value.absent(),
  })  : conversationId = Value(conversationId),
        content = Value(content),
        isFromUser = Value(isFromUser);
  static Insertable<Message> custom({
    Expression<int>? id,
    Expression<int>? conversationId,
    Expression<String>? content,
    Expression<bool>? isFromUser,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (conversationId != null) 'conversation_id': conversationId,
      if (content != null) 'content': content,
      if (isFromUser != null) 'is_from_user': isFromUser,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MessagesCompanion copyWith(
      {Value<int>? id,
      Value<int>? conversationId,
      Value<String>? content,
      Value<bool>? isFromUser,
      Value<DateTime>? createdAt}) {
    return MessagesCompanion(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      content: content ?? this.content,
      isFromUser: isFromUser ?? this.isFromUser,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<int>(conversationId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (isFromUser.present) {
      map['is_from_user'] = Variable<bool>(isFromUser.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('content: $content, ')
          ..write('isFromUser: $isFromUser, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SkillsTable extends Skills with TableInfo<$SkillsTable, Skill> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SkillsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _playerIdMeta =
      const VerificationMeta('playerId');
  @override
  late final GeneratedColumn<int> playerId = GeneratedColumn<int>(
      'player_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<double> score = GeneratedColumn<double>(
      'score', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _confidenceMeta =
      const VerificationMeta('confidence');
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
      'confidence', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _trendMeta = const VerificationMeta('trend');
  @override
  late final GeneratedColumn<String> trend = GeneratedColumn<String>(
      'trend', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _calculatedAtMeta =
      const VerificationMeta('calculatedAt');
  @override
  late final GeneratedColumn<DateTime> calculatedAt = GeneratedColumn<DateTime>(
      'calculated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  @override
  List<GeneratedColumn> get $columns =>
      [id, playerId, category, score, confidence, trend, calculatedAt, version];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'skills';
  @override
  VerificationContext validateIntegrity(Insertable<Skill> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('player_id')) {
      context.handle(_playerIdMeta,
          playerId.isAcceptableOrUnknown(data['player_id']!, _playerIdMeta));
    } else if (isInserting) {
      context.missing(_playerIdMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
          _scoreMeta, score.isAcceptableOrUnknown(data['score']!, _scoreMeta));
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
          _confidenceMeta,
          confidence.isAcceptableOrUnknown(
              data['confidence']!, _confidenceMeta));
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    if (data.containsKey('trend')) {
      context.handle(
          _trendMeta, trend.isAcceptableOrUnknown(data['trend']!, _trendMeta));
    } else if (isInserting) {
      context.missing(_trendMeta);
    }
    if (data.containsKey('calculated_at')) {
      context.handle(
          _calculatedAtMeta,
          calculatedAt.isAcceptableOrUnknown(
              data['calculated_at']!, _calculatedAtMeta));
    } else if (isInserting) {
      context.missing(_calculatedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Skill map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Skill(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      playerId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}player_id'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      score: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}score'])!,
      confidence: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}confidence'])!,
      trend: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}trend'])!,
      calculatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}calculated_at'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
    );
  }

  @override
  $SkillsTable createAlias(String alias) {
    return $SkillsTable(attachedDatabase, alias);
  }
}

class Skill extends DataClass implements Insertable<Skill> {
  final int id;
  final int playerId;
  final String category;
  final double score;
  final double confidence;
  final String trend;
  final DateTime calculatedAt;
  final int version;
  const Skill(
      {required this.id,
      required this.playerId,
      required this.category,
      required this.score,
      required this.confidence,
      required this.trend,
      required this.calculatedAt,
      required this.version});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['player_id'] = Variable<int>(playerId);
    map['category'] = Variable<String>(category);
    map['score'] = Variable<double>(score);
    map['confidence'] = Variable<double>(confidence);
    map['trend'] = Variable<String>(trend);
    map['calculated_at'] = Variable<DateTime>(calculatedAt);
    map['version'] = Variable<int>(version);
    return map;
  }

  SkillsCompanion toCompanion(bool nullToAbsent) {
    return SkillsCompanion(
      id: Value(id),
      playerId: Value(playerId),
      category: Value(category),
      score: Value(score),
      confidence: Value(confidence),
      trend: Value(trend),
      calculatedAt: Value(calculatedAt),
      version: Value(version),
    );
  }

  factory Skill.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Skill(
      id: serializer.fromJson<int>(json['id']),
      playerId: serializer.fromJson<int>(json['playerId']),
      category: serializer.fromJson<String>(json['category']),
      score: serializer.fromJson<double>(json['score']),
      confidence: serializer.fromJson<double>(json['confidence']),
      trend: serializer.fromJson<String>(json['trend']),
      calculatedAt: serializer.fromJson<DateTime>(json['calculatedAt']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'playerId': serializer.toJson<int>(playerId),
      'category': serializer.toJson<String>(category),
      'score': serializer.toJson<double>(score),
      'confidence': serializer.toJson<double>(confidence),
      'trend': serializer.toJson<String>(trend),
      'calculatedAt': serializer.toJson<DateTime>(calculatedAt),
      'version': serializer.toJson<int>(version),
    };
  }

  Skill copyWith(
          {int? id,
          int? playerId,
          String? category,
          double? score,
          double? confidence,
          String? trend,
          DateTime? calculatedAt,
          int? version}) =>
      Skill(
        id: id ?? this.id,
        playerId: playerId ?? this.playerId,
        category: category ?? this.category,
        score: score ?? this.score,
        confidence: confidence ?? this.confidence,
        trend: trend ?? this.trend,
        calculatedAt: calculatedAt ?? this.calculatedAt,
        version: version ?? this.version,
      );
  Skill copyWithCompanion(SkillsCompanion data) {
    return Skill(
      id: data.id.present ? data.id.value : this.id,
      playerId: data.playerId.present ? data.playerId.value : this.playerId,
      category: data.category.present ? data.category.value : this.category,
      score: data.score.present ? data.score.value : this.score,
      confidence:
          data.confidence.present ? data.confidence.value : this.confidence,
      trend: data.trend.present ? data.trend.value : this.trend,
      calculatedAt: data.calculatedAt.present
          ? data.calculatedAt.value
          : this.calculatedAt,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Skill(')
          ..write('id: $id, ')
          ..write('playerId: $playerId, ')
          ..write('category: $category, ')
          ..write('score: $score, ')
          ..write('confidence: $confidence, ')
          ..write('trend: $trend, ')
          ..write('calculatedAt: $calculatedAt, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, playerId, category, score, confidence, trend, calculatedAt, version);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Skill &&
          other.id == this.id &&
          other.playerId == this.playerId &&
          other.category == this.category &&
          other.score == this.score &&
          other.confidence == this.confidence &&
          other.trend == this.trend &&
          other.calculatedAt == this.calculatedAt &&
          other.version == this.version);
}

class SkillsCompanion extends UpdateCompanion<Skill> {
  final Value<int> id;
  final Value<int> playerId;
  final Value<String> category;
  final Value<double> score;
  final Value<double> confidence;
  final Value<String> trend;
  final Value<DateTime> calculatedAt;
  final Value<int> version;
  const SkillsCompanion({
    this.id = const Value.absent(),
    this.playerId = const Value.absent(),
    this.category = const Value.absent(),
    this.score = const Value.absent(),
    this.confidence = const Value.absent(),
    this.trend = const Value.absent(),
    this.calculatedAt = const Value.absent(),
    this.version = const Value.absent(),
  });
  SkillsCompanion.insert({
    this.id = const Value.absent(),
    required int playerId,
    required String category,
    required double score,
    required double confidence,
    required String trend,
    required DateTime calculatedAt,
    this.version = const Value.absent(),
  })  : playerId = Value(playerId),
        category = Value(category),
        score = Value(score),
        confidence = Value(confidence),
        trend = Value(trend),
        calculatedAt = Value(calculatedAt);
  static Insertable<Skill> custom({
    Expression<int>? id,
    Expression<int>? playerId,
    Expression<String>? category,
    Expression<double>? score,
    Expression<double>? confidence,
    Expression<String>? trend,
    Expression<DateTime>? calculatedAt,
    Expression<int>? version,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (playerId != null) 'player_id': playerId,
      if (category != null) 'category': category,
      if (score != null) 'score': score,
      if (confidence != null) 'confidence': confidence,
      if (trend != null) 'trend': trend,
      if (calculatedAt != null) 'calculated_at': calculatedAt,
      if (version != null) 'version': version,
    });
  }

  SkillsCompanion copyWith(
      {Value<int>? id,
      Value<int>? playerId,
      Value<String>? category,
      Value<double>? score,
      Value<double>? confidence,
      Value<String>? trend,
      Value<DateTime>? calculatedAt,
      Value<int>? version}) {
    return SkillsCompanion(
      id: id ?? this.id,
      playerId: playerId ?? this.playerId,
      category: category ?? this.category,
      score: score ?? this.score,
      confidence: confidence ?? this.confidence,
      trend: trend ?? this.trend,
      calculatedAt: calculatedAt ?? this.calculatedAt,
      version: version ?? this.version,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (playerId.present) {
      map['player_id'] = Variable<int>(playerId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (score.present) {
      map['score'] = Variable<double>(score.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (trend.present) {
      map['trend'] = Variable<String>(trend.value);
    }
    if (calculatedAt.present) {
      map['calculated_at'] = Variable<DateTime>(calculatedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SkillsCompanion(')
          ..write('id: $id, ')
          ..write('playerId: $playerId, ')
          ..write('category: $category, ')
          ..write('score: $score, ')
          ..write('confidence: $confidence, ')
          ..write('trend: $trend, ')
          ..write('calculatedAt: $calculatedAt, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }
}

class $SkillHistoryTableTable extends SkillHistoryTable
    with TableInfo<$SkillHistoryTableTable, SkillHistory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SkillHistoryTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _skillIdMeta =
      const VerificationMeta('skillId');
  @override
  late final GeneratedColumn<int> skillId = GeneratedColumn<int>(
      'skill_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
      'session_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<double> score = GeneratedColumn<double>(
      'score', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _confidenceMeta =
      const VerificationMeta('confidence');
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
      'confidence', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _trendMeta = const VerificationMeta('trend');
  @override
  late final GeneratedColumn<String> trend = GeneratedColumn<String>(
      'trend', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, skillId, sessionId, score, confidence, trend, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'skill_history_table';
  @override
  VerificationContext validateIntegrity(Insertable<SkillHistory> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('skill_id')) {
      context.handle(_skillIdMeta,
          skillId.isAcceptableOrUnknown(data['skill_id']!, _skillIdMeta));
    } else if (isInserting) {
      context.missing(_skillIdMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
          _scoreMeta, score.isAcceptableOrUnknown(data['score']!, _scoreMeta));
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
          _confidenceMeta,
          confidence.isAcceptableOrUnknown(
              data['confidence']!, _confidenceMeta));
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    if (data.containsKey('trend')) {
      context.handle(
          _trendMeta, trend.isAcceptableOrUnknown(data['trend']!, _trendMeta));
    } else if (isInserting) {
      context.missing(_trendMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SkillHistory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SkillHistory(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      skillId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}skill_id'])!,
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}session_id'])!,
      score: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}score'])!,
      confidence: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}confidence'])!,
      trend: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}trend'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SkillHistoryTableTable createAlias(String alias) {
    return $SkillHistoryTableTable(attachedDatabase, alias);
  }
}

class SkillHistory extends DataClass implements Insertable<SkillHistory> {
  final int id;
  final int skillId;
  final int sessionId;
  final double score;
  final double confidence;
  final String trend;
  final DateTime createdAt;
  const SkillHistory(
      {required this.id,
      required this.skillId,
      required this.sessionId,
      required this.score,
      required this.confidence,
      required this.trend,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['skill_id'] = Variable<int>(skillId);
    map['session_id'] = Variable<int>(sessionId);
    map['score'] = Variable<double>(score);
    map['confidence'] = Variable<double>(confidence);
    map['trend'] = Variable<String>(trend);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SkillHistoryTableCompanion toCompanion(bool nullToAbsent) {
    return SkillHistoryTableCompanion(
      id: Value(id),
      skillId: Value(skillId),
      sessionId: Value(sessionId),
      score: Value(score),
      confidence: Value(confidence),
      trend: Value(trend),
      createdAt: Value(createdAt),
    );
  }

  factory SkillHistory.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SkillHistory(
      id: serializer.fromJson<int>(json['id']),
      skillId: serializer.fromJson<int>(json['skillId']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      score: serializer.fromJson<double>(json['score']),
      confidence: serializer.fromJson<double>(json['confidence']),
      trend: serializer.fromJson<String>(json['trend']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'skillId': serializer.toJson<int>(skillId),
      'sessionId': serializer.toJson<int>(sessionId),
      'score': serializer.toJson<double>(score),
      'confidence': serializer.toJson<double>(confidence),
      'trend': serializer.toJson<String>(trend),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SkillHistory copyWith(
          {int? id,
          int? skillId,
          int? sessionId,
          double? score,
          double? confidence,
          String? trend,
          DateTime? createdAt}) =>
      SkillHistory(
        id: id ?? this.id,
        skillId: skillId ?? this.skillId,
        sessionId: sessionId ?? this.sessionId,
        score: score ?? this.score,
        confidence: confidence ?? this.confidence,
        trend: trend ?? this.trend,
        createdAt: createdAt ?? this.createdAt,
      );
  SkillHistory copyWithCompanion(SkillHistoryTableCompanion data) {
    return SkillHistory(
      id: data.id.present ? data.id.value : this.id,
      skillId: data.skillId.present ? data.skillId.value : this.skillId,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      score: data.score.present ? data.score.value : this.score,
      confidence:
          data.confidence.present ? data.confidence.value : this.confidence,
      trend: data.trend.present ? data.trend.value : this.trend,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SkillHistory(')
          ..write('id: $id, ')
          ..write('skillId: $skillId, ')
          ..write('sessionId: $sessionId, ')
          ..write('score: $score, ')
          ..write('confidence: $confidence, ')
          ..write('trend: $trend, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, skillId, sessionId, score, confidence, trend, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SkillHistory &&
          other.id == this.id &&
          other.skillId == this.skillId &&
          other.sessionId == this.sessionId &&
          other.score == this.score &&
          other.confidence == this.confidence &&
          other.trend == this.trend &&
          other.createdAt == this.createdAt);
}

class SkillHistoryTableCompanion extends UpdateCompanion<SkillHistory> {
  final Value<int> id;
  final Value<int> skillId;
  final Value<int> sessionId;
  final Value<double> score;
  final Value<double> confidence;
  final Value<String> trend;
  final Value<DateTime> createdAt;
  const SkillHistoryTableCompanion({
    this.id = const Value.absent(),
    this.skillId = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.score = const Value.absent(),
    this.confidence = const Value.absent(),
    this.trend = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SkillHistoryTableCompanion.insert({
    this.id = const Value.absent(),
    required int skillId,
    required int sessionId,
    required double score,
    required double confidence,
    required String trend,
    required DateTime createdAt,
  })  : skillId = Value(skillId),
        sessionId = Value(sessionId),
        score = Value(score),
        confidence = Value(confidence),
        trend = Value(trend),
        createdAt = Value(createdAt);
  static Insertable<SkillHistory> custom({
    Expression<int>? id,
    Expression<int>? skillId,
    Expression<int>? sessionId,
    Expression<double>? score,
    Expression<double>? confidence,
    Expression<String>? trend,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (skillId != null) 'skill_id': skillId,
      if (sessionId != null) 'session_id': sessionId,
      if (score != null) 'score': score,
      if (confidence != null) 'confidence': confidence,
      if (trend != null) 'trend': trend,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SkillHistoryTableCompanion copyWith(
      {Value<int>? id,
      Value<int>? skillId,
      Value<int>? sessionId,
      Value<double>? score,
      Value<double>? confidence,
      Value<String>? trend,
      Value<DateTime>? createdAt}) {
    return SkillHistoryTableCompanion(
      id: id ?? this.id,
      skillId: skillId ?? this.skillId,
      sessionId: sessionId ?? this.sessionId,
      score: score ?? this.score,
      confidence: confidence ?? this.confidence,
      trend: trend ?? this.trend,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (skillId.present) {
      map['skill_id'] = Variable<int>(skillId.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (score.present) {
      map['score'] = Variable<double>(score.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (trend.present) {
      map['trend'] = Variable<String>(trend.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SkillHistoryTableCompanion(')
          ..write('id: $id, ')
          ..write('skillId: $skillId, ')
          ..write('sessionId: $sessionId, ')
          ..write('score: $score, ')
          ..write('confidence: $confidence, ')
          ..write('trend: $trend, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $DailyGoalsTable extends DailyGoals
    with TableInfo<$DailyGoalsTable, DailyGoal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyGoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleViMeta =
      const VerificationMeta('titleVi');
  @override
  late final GeneratedColumn<String> titleVi = GeneratedColumn<String>(
      'title_vi', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
      'priority', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _targetValueMeta =
      const VerificationMeta('targetValue');
  @override
  late final GeneratedColumn<int> targetValue = GeneratedColumn<int>(
      'target_value', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _currentValueMeta =
      const VerificationMeta('currentValue');
  @override
  late final GeneratedColumn<int> currentValue = GeneratedColumn<int>(
      'current_value', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _targetDateMeta =
      const VerificationMeta('targetDate');
  @override
  late final GeneratedColumn<String> targetDate = GeneratedColumn<String>(
      'target_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isRecurringMeta =
      const VerificationMeta('isRecurring');
  @override
  late final GeneratedColumn<bool> isRecurring = GeneratedColumn<bool>(
      'is_recurring', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_recurring" IN (0, 1))'));
  static const VerificationMeta _recurrenceMeta =
      const VerificationMeta('recurrence');
  @override
  late final GeneratedColumn<String> recurrence = GeneratedColumn<String>(
      'recurrence', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        titleVi,
        description,
        category,
        priority,
        status,
        targetValue,
        currentValue,
        unit,
        createdAt,
        completedAt,
        targetDate,
        isRecurring,
        recurrence
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_goals';
  @override
  VerificationContext validateIntegrity(Insertable<DailyGoal> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('title_vi')) {
      context.handle(_titleViMeta,
          titleVi.isAcceptableOrUnknown(data['title_vi']!, _titleViMeta));
    } else if (isInserting) {
      context.missing(_titleViMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    } else if (isInserting) {
      context.missing(_priorityMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('target_value')) {
      context.handle(
          _targetValueMeta,
          targetValue.isAcceptableOrUnknown(
              data['target_value']!, _targetValueMeta));
    } else if (isInserting) {
      context.missing(_targetValueMeta);
    }
    if (data.containsKey('current_value')) {
      context.handle(
          _currentValueMeta,
          currentValue.isAcceptableOrUnknown(
              data['current_value']!, _currentValueMeta));
    } else if (isInserting) {
      context.missing(_currentValueMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('target_date')) {
      context.handle(
          _targetDateMeta,
          targetDate.isAcceptableOrUnknown(
              data['target_date']!, _targetDateMeta));
    }
    if (data.containsKey('is_recurring')) {
      context.handle(
          _isRecurringMeta,
          isRecurring.isAcceptableOrUnknown(
              data['is_recurring']!, _isRecurringMeta));
    } else if (isInserting) {
      context.missing(_isRecurringMeta);
    }
    if (data.containsKey('recurrence')) {
      context.handle(
          _recurrenceMeta,
          recurrence.isAcceptableOrUnknown(
              data['recurrence']!, _recurrenceMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DailyGoal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyGoal(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      titleVi: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title_vi'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}priority'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      targetValue: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}target_value'])!,
      currentValue: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}current_value'])!,
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      targetDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}target_date']),
      isRecurring: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_recurring'])!,
      recurrence: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}recurrence']),
    );
  }

  @override
  $DailyGoalsTable createAlias(String alias) {
    return $DailyGoalsTable(attachedDatabase, alias);
  }
}

class DailyGoal extends DataClass implements Insertable<DailyGoal> {
  final int id;
  final String title;
  final String titleVi;
  final String? description;
  final String category;
  final String priority;
  final String status;
  final int targetValue;
  final int currentValue;
  final String unit;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? targetDate;
  final bool isRecurring;
  final String? recurrence;
  const DailyGoal(
      {required this.id,
      required this.title,
      required this.titleVi,
      this.description,
      required this.category,
      required this.priority,
      required this.status,
      required this.targetValue,
      required this.currentValue,
      required this.unit,
      required this.createdAt,
      this.completedAt,
      this.targetDate,
      required this.isRecurring,
      this.recurrence});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['title_vi'] = Variable<String>(titleVi);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['category'] = Variable<String>(category);
    map['priority'] = Variable<String>(priority);
    map['status'] = Variable<String>(status);
    map['target_value'] = Variable<int>(targetValue);
    map['current_value'] = Variable<int>(currentValue);
    map['unit'] = Variable<String>(unit);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || targetDate != null) {
      map['target_date'] = Variable<String>(targetDate);
    }
    map['is_recurring'] = Variable<bool>(isRecurring);
    if (!nullToAbsent || recurrence != null) {
      map['recurrence'] = Variable<String>(recurrence);
    }
    return map;
  }

  DailyGoalsCompanion toCompanion(bool nullToAbsent) {
    return DailyGoalsCompanion(
      id: Value(id),
      title: Value(title),
      titleVi: Value(titleVi),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      category: Value(category),
      priority: Value(priority),
      status: Value(status),
      targetValue: Value(targetValue),
      currentValue: Value(currentValue),
      unit: Value(unit),
      createdAt: Value(createdAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      targetDate: targetDate == null && nullToAbsent
          ? const Value.absent()
          : Value(targetDate),
      isRecurring: Value(isRecurring),
      recurrence: recurrence == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrence),
    );
  }

  factory DailyGoal.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyGoal(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      titleVi: serializer.fromJson<String>(json['titleVi']),
      description: serializer.fromJson<String?>(json['description']),
      category: serializer.fromJson<String>(json['category']),
      priority: serializer.fromJson<String>(json['priority']),
      status: serializer.fromJson<String>(json['status']),
      targetValue: serializer.fromJson<int>(json['targetValue']),
      currentValue: serializer.fromJson<int>(json['currentValue']),
      unit: serializer.fromJson<String>(json['unit']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      targetDate: serializer.fromJson<String?>(json['targetDate']),
      isRecurring: serializer.fromJson<bool>(json['isRecurring']),
      recurrence: serializer.fromJson<String?>(json['recurrence']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'titleVi': serializer.toJson<String>(titleVi),
      'description': serializer.toJson<String?>(description),
      'category': serializer.toJson<String>(category),
      'priority': serializer.toJson<String>(priority),
      'status': serializer.toJson<String>(status),
      'targetValue': serializer.toJson<int>(targetValue),
      'currentValue': serializer.toJson<int>(currentValue),
      'unit': serializer.toJson<String>(unit),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'targetDate': serializer.toJson<String?>(targetDate),
      'isRecurring': serializer.toJson<bool>(isRecurring),
      'recurrence': serializer.toJson<String?>(recurrence),
    };
  }

  DailyGoal copyWith(
          {int? id,
          String? title,
          String? titleVi,
          Value<String?> description = const Value.absent(),
          String? category,
          String? priority,
          String? status,
          int? targetValue,
          int? currentValue,
          String? unit,
          DateTime? createdAt,
          Value<DateTime?> completedAt = const Value.absent(),
          Value<String?> targetDate = const Value.absent(),
          bool? isRecurring,
          Value<String?> recurrence = const Value.absent()}) =>
      DailyGoal(
        id: id ?? this.id,
        title: title ?? this.title,
        titleVi: titleVi ?? this.titleVi,
        description: description.present ? description.value : this.description,
        category: category ?? this.category,
        priority: priority ?? this.priority,
        status: status ?? this.status,
        targetValue: targetValue ?? this.targetValue,
        currentValue: currentValue ?? this.currentValue,
        unit: unit ?? this.unit,
        createdAt: createdAt ?? this.createdAt,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        targetDate: targetDate.present ? targetDate.value : this.targetDate,
        isRecurring: isRecurring ?? this.isRecurring,
        recurrence: recurrence.present ? recurrence.value : this.recurrence,
      );
  DailyGoal copyWithCompanion(DailyGoalsCompanion data) {
    return DailyGoal(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      titleVi: data.titleVi.present ? data.titleVi.value : this.titleVi,
      description:
          data.description.present ? data.description.value : this.description,
      category: data.category.present ? data.category.value : this.category,
      priority: data.priority.present ? data.priority.value : this.priority,
      status: data.status.present ? data.status.value : this.status,
      targetValue:
          data.targetValue.present ? data.targetValue.value : this.targetValue,
      currentValue: data.currentValue.present
          ? data.currentValue.value
          : this.currentValue,
      unit: data.unit.present ? data.unit.value : this.unit,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      targetDate:
          data.targetDate.present ? data.targetDate.value : this.targetDate,
      isRecurring:
          data.isRecurring.present ? data.isRecurring.value : this.isRecurring,
      recurrence:
          data.recurrence.present ? data.recurrence.value : this.recurrence,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyGoal(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('titleVi: $titleVi, ')
          ..write('description: $description, ')
          ..write('category: $category, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('targetValue: $targetValue, ')
          ..write('currentValue: $currentValue, ')
          ..write('unit: $unit, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('targetDate: $targetDate, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('recurrence: $recurrence')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      title,
      titleVi,
      description,
      category,
      priority,
      status,
      targetValue,
      currentValue,
      unit,
      createdAt,
      completedAt,
      targetDate,
      isRecurring,
      recurrence);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyGoal &&
          other.id == this.id &&
          other.title == this.title &&
          other.titleVi == this.titleVi &&
          other.description == this.description &&
          other.category == this.category &&
          other.priority == this.priority &&
          other.status == this.status &&
          other.targetValue == this.targetValue &&
          other.currentValue == this.currentValue &&
          other.unit == this.unit &&
          other.createdAt == this.createdAt &&
          other.completedAt == this.completedAt &&
          other.targetDate == this.targetDate &&
          other.isRecurring == this.isRecurring &&
          other.recurrence == this.recurrence);
}

class DailyGoalsCompanion extends UpdateCompanion<DailyGoal> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> titleVi;
  final Value<String?> description;
  final Value<String> category;
  final Value<String> priority;
  final Value<String> status;
  final Value<int> targetValue;
  final Value<int> currentValue;
  final Value<String> unit;
  final Value<DateTime> createdAt;
  final Value<DateTime?> completedAt;
  final Value<String?> targetDate;
  final Value<bool> isRecurring;
  final Value<String?> recurrence;
  const DailyGoalsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.titleVi = const Value.absent(),
    this.description = const Value.absent(),
    this.category = const Value.absent(),
    this.priority = const Value.absent(),
    this.status = const Value.absent(),
    this.targetValue = const Value.absent(),
    this.currentValue = const Value.absent(),
    this.unit = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.isRecurring = const Value.absent(),
    this.recurrence = const Value.absent(),
  });
  DailyGoalsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String titleVi,
    this.description = const Value.absent(),
    required String category,
    required String priority,
    required String status,
    required int targetValue,
    required int currentValue,
    required String unit,
    required DateTime createdAt,
    this.completedAt = const Value.absent(),
    this.targetDate = const Value.absent(),
    required bool isRecurring,
    this.recurrence = const Value.absent(),
  })  : title = Value(title),
        titleVi = Value(titleVi),
        category = Value(category),
        priority = Value(priority),
        status = Value(status),
        targetValue = Value(targetValue),
        currentValue = Value(currentValue),
        unit = Value(unit),
        createdAt = Value(createdAt),
        isRecurring = Value(isRecurring);
  static Insertable<DailyGoal> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? titleVi,
    Expression<String>? description,
    Expression<String>? category,
    Expression<String>? priority,
    Expression<String>? status,
    Expression<int>? targetValue,
    Expression<int>? currentValue,
    Expression<String>? unit,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? completedAt,
    Expression<String>? targetDate,
    Expression<bool>? isRecurring,
    Expression<String>? recurrence,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (titleVi != null) 'title_vi': titleVi,
      if (description != null) 'description': description,
      if (category != null) 'category': category,
      if (priority != null) 'priority': priority,
      if (status != null) 'status': status,
      if (targetValue != null) 'target_value': targetValue,
      if (currentValue != null) 'current_value': currentValue,
      if (unit != null) 'unit': unit,
      if (createdAt != null) 'created_at': createdAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (targetDate != null) 'target_date': targetDate,
      if (isRecurring != null) 'is_recurring': isRecurring,
      if (recurrence != null) 'recurrence': recurrence,
    });
  }

  DailyGoalsCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<String>? titleVi,
      Value<String?>? description,
      Value<String>? category,
      Value<String>? priority,
      Value<String>? status,
      Value<int>? targetValue,
      Value<int>? currentValue,
      Value<String>? unit,
      Value<DateTime>? createdAt,
      Value<DateTime?>? completedAt,
      Value<String?>? targetDate,
      Value<bool>? isRecurring,
      Value<String?>? recurrence}) {
    return DailyGoalsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      titleVi: titleVi ?? this.titleVi,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      unit: unit ?? this.unit,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      targetDate: targetDate ?? this.targetDate,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrence: recurrence ?? this.recurrence,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (titleVi.present) {
      map['title_vi'] = Variable<String>(titleVi.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (targetValue.present) {
      map['target_value'] = Variable<int>(targetValue.value);
    }
    if (currentValue.present) {
      map['current_value'] = Variable<int>(currentValue.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (targetDate.present) {
      map['target_date'] = Variable<String>(targetDate.value);
    }
    if (isRecurring.present) {
      map['is_recurring'] = Variable<bool>(isRecurring.value);
    }
    if (recurrence.present) {
      map['recurrence'] = Variable<String>(recurrence.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyGoalsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('titleVi: $titleVi, ')
          ..write('description: $description, ')
          ..write('category: $category, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('targetValue: $targetValue, ')
          ..write('currentValue: $currentValue, ')
          ..write('unit: $unit, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('targetDate: $targetDate, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('recurrence: $recurrence')
          ..write(')'))
        .toString();
  }
}

class $DrillSessionsTable extends DrillSessions
    with TableInfo<$DrillSessionsTable, DrillSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DrillSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _drillIdMeta =
      const VerificationMeta('drillId');
  @override
  late final GeneratedColumn<int> drillId = GeneratedColumn<int>(
      'drill_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _drillNameMeta =
      const VerificationMeta('drillName');
  @override
  late final GeneratedColumn<String> drillName = GeneratedColumn<String>(
      'drill_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
      'started_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _currentScoreMeta =
      const VerificationMeta('currentScore');
  @override
  late final GeneratedColumn<int> currentScore = GeneratedColumn<int>(
      'current_score', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _targetScoreMeta =
      const VerificationMeta('targetScore');
  @override
  late final GeneratedColumn<int> targetScore = GeneratedColumn<int>(
      'target_score', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _attemptsMeta =
      const VerificationMeta('attempts');
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
      'attempts', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _successfulAttemptsMeta =
      const VerificationMeta('successfulAttempts');
  @override
  late final GeneratedColumn<int> successfulAttempts = GeneratedColumn<int>(
      'successful_attempts', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<String> rating = GeneratedColumn<String>(
      'rating', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        drillId,
        drillName,
        startedAt,
        completedAt,
        currentScore,
        targetScore,
        attempts,
        successfulAttempts,
        rating,
        notes
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'drill_sessions';
  @override
  VerificationContext validateIntegrity(Insertable<DrillSession> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('drill_id')) {
      context.handle(_drillIdMeta,
          drillId.isAcceptableOrUnknown(data['drill_id']!, _drillIdMeta));
    } else if (isInserting) {
      context.missing(_drillIdMeta);
    }
    if (data.containsKey('drill_name')) {
      context.handle(_drillNameMeta,
          drillName.isAcceptableOrUnknown(data['drill_name']!, _drillNameMeta));
    } else if (isInserting) {
      context.missing(_drillNameMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('current_score')) {
      context.handle(
          _currentScoreMeta,
          currentScore.isAcceptableOrUnknown(
              data['current_score']!, _currentScoreMeta));
    } else if (isInserting) {
      context.missing(_currentScoreMeta);
    }
    if (data.containsKey('target_score')) {
      context.handle(
          _targetScoreMeta,
          targetScore.isAcceptableOrUnknown(
              data['target_score']!, _targetScoreMeta));
    } else if (isInserting) {
      context.missing(_targetScoreMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(_attemptsMeta,
          attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta));
    } else if (isInserting) {
      context.missing(_attemptsMeta);
    }
    if (data.containsKey('successful_attempts')) {
      context.handle(
          _successfulAttemptsMeta,
          successfulAttempts.isAcceptableOrUnknown(
              data['successful_attempts']!, _successfulAttemptsMeta));
    } else if (isInserting) {
      context.missing(_successfulAttemptsMeta);
    }
    if (data.containsKey('rating')) {
      context.handle(_ratingMeta,
          rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DrillSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DrillSession(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      drillId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}drill_id'])!,
      drillName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}drill_name'])!,
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}started_at'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      currentScore: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}current_score'])!,
      targetScore: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}target_score'])!,
      attempts: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attempts'])!,
      successfulAttempts: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}successful_attempts'])!,
      rating: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rating']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
    );
  }

  @override
  $DrillSessionsTable createAlias(String alias) {
    return $DrillSessionsTable(attachedDatabase, alias);
  }
}

class DrillSession extends DataClass implements Insertable<DrillSession> {
  final int id;
  final int drillId;
  final String drillName;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int currentScore;
  final int targetScore;
  final int attempts;
  final int successfulAttempts;
  final String? rating;
  final String? notes;
  const DrillSession(
      {required this.id,
      required this.drillId,
      required this.drillName,
      required this.startedAt,
      this.completedAt,
      required this.currentScore,
      required this.targetScore,
      required this.attempts,
      required this.successfulAttempts,
      this.rating,
      this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['drill_id'] = Variable<int>(drillId);
    map['drill_name'] = Variable<String>(drillName);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['current_score'] = Variable<int>(currentScore);
    map['target_score'] = Variable<int>(targetScore);
    map['attempts'] = Variable<int>(attempts);
    map['successful_attempts'] = Variable<int>(successfulAttempts);
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<String>(rating);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  DrillSessionsCompanion toCompanion(bool nullToAbsent) {
    return DrillSessionsCompanion(
      id: Value(id),
      drillId: Value(drillId),
      drillName: Value(drillName),
      startedAt: Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      currentScore: Value(currentScore),
      targetScore: Value(targetScore),
      attempts: Value(attempts),
      successfulAttempts: Value(successfulAttempts),
      rating:
          rating == null && nullToAbsent ? const Value.absent() : Value(rating),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
    );
  }

  factory DrillSession.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DrillSession(
      id: serializer.fromJson<int>(json['id']),
      drillId: serializer.fromJson<int>(json['drillId']),
      drillName: serializer.fromJson<String>(json['drillName']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      currentScore: serializer.fromJson<int>(json['currentScore']),
      targetScore: serializer.fromJson<int>(json['targetScore']),
      attempts: serializer.fromJson<int>(json['attempts']),
      successfulAttempts: serializer.fromJson<int>(json['successfulAttempts']),
      rating: serializer.fromJson<String?>(json['rating']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'drillId': serializer.toJson<int>(drillId),
      'drillName': serializer.toJson<String>(drillName),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'currentScore': serializer.toJson<int>(currentScore),
      'targetScore': serializer.toJson<int>(targetScore),
      'attempts': serializer.toJson<int>(attempts),
      'successfulAttempts': serializer.toJson<int>(successfulAttempts),
      'rating': serializer.toJson<String?>(rating),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  DrillSession copyWith(
          {int? id,
          int? drillId,
          String? drillName,
          DateTime? startedAt,
          Value<DateTime?> completedAt = const Value.absent(),
          int? currentScore,
          int? targetScore,
          int? attempts,
          int? successfulAttempts,
          Value<String?> rating = const Value.absent(),
          Value<String?> notes = const Value.absent()}) =>
      DrillSession(
        id: id ?? this.id,
        drillId: drillId ?? this.drillId,
        drillName: drillName ?? this.drillName,
        startedAt: startedAt ?? this.startedAt,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        currentScore: currentScore ?? this.currentScore,
        targetScore: targetScore ?? this.targetScore,
        attempts: attempts ?? this.attempts,
        successfulAttempts: successfulAttempts ?? this.successfulAttempts,
        rating: rating.present ? rating.value : this.rating,
        notes: notes.present ? notes.value : this.notes,
      );
  DrillSession copyWithCompanion(DrillSessionsCompanion data) {
    return DrillSession(
      id: data.id.present ? data.id.value : this.id,
      drillId: data.drillId.present ? data.drillId.value : this.drillId,
      drillName: data.drillName.present ? data.drillName.value : this.drillName,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      currentScore: data.currentScore.present
          ? data.currentScore.value
          : this.currentScore,
      targetScore:
          data.targetScore.present ? data.targetScore.value : this.targetScore,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      successfulAttempts: data.successfulAttempts.present
          ? data.successfulAttempts.value
          : this.successfulAttempts,
      rating: data.rating.present ? data.rating.value : this.rating,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DrillSession(')
          ..write('id: $id, ')
          ..write('drillId: $drillId, ')
          ..write('drillName: $drillName, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('currentScore: $currentScore, ')
          ..write('targetScore: $targetScore, ')
          ..write('attempts: $attempts, ')
          ..write('successfulAttempts: $successfulAttempts, ')
          ..write('rating: $rating, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      drillId,
      drillName,
      startedAt,
      completedAt,
      currentScore,
      targetScore,
      attempts,
      successfulAttempts,
      rating,
      notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DrillSession &&
          other.id == this.id &&
          other.drillId == this.drillId &&
          other.drillName == this.drillName &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.currentScore == this.currentScore &&
          other.targetScore == this.targetScore &&
          other.attempts == this.attempts &&
          other.successfulAttempts == this.successfulAttempts &&
          other.rating == this.rating &&
          other.notes == this.notes);
}

class DrillSessionsCompanion extends UpdateCompanion<DrillSession> {
  final Value<int> id;
  final Value<int> drillId;
  final Value<String> drillName;
  final Value<DateTime> startedAt;
  final Value<DateTime?> completedAt;
  final Value<int> currentScore;
  final Value<int> targetScore;
  final Value<int> attempts;
  final Value<int> successfulAttempts;
  final Value<String?> rating;
  final Value<String?> notes;
  const DrillSessionsCompanion({
    this.id = const Value.absent(),
    this.drillId = const Value.absent(),
    this.drillName = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.currentScore = const Value.absent(),
    this.targetScore = const Value.absent(),
    this.attempts = const Value.absent(),
    this.successfulAttempts = const Value.absent(),
    this.rating = const Value.absent(),
    this.notes = const Value.absent(),
  });
  DrillSessionsCompanion.insert({
    this.id = const Value.absent(),
    required int drillId,
    required String drillName,
    required DateTime startedAt,
    this.completedAt = const Value.absent(),
    required int currentScore,
    required int targetScore,
    required int attempts,
    required int successfulAttempts,
    this.rating = const Value.absent(),
    this.notes = const Value.absent(),
  })  : drillId = Value(drillId),
        drillName = Value(drillName),
        startedAt = Value(startedAt),
        currentScore = Value(currentScore),
        targetScore = Value(targetScore),
        attempts = Value(attempts),
        successfulAttempts = Value(successfulAttempts);
  static Insertable<DrillSession> custom({
    Expression<int>? id,
    Expression<int>? drillId,
    Expression<String>? drillName,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<int>? currentScore,
    Expression<int>? targetScore,
    Expression<int>? attempts,
    Expression<int>? successfulAttempts,
    Expression<String>? rating,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (drillId != null) 'drill_id': drillId,
      if (drillName != null) 'drill_name': drillName,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (currentScore != null) 'current_score': currentScore,
      if (targetScore != null) 'target_score': targetScore,
      if (attempts != null) 'attempts': attempts,
      if (successfulAttempts != null) 'successful_attempts': successfulAttempts,
      if (rating != null) 'rating': rating,
      if (notes != null) 'notes': notes,
    });
  }

  DrillSessionsCompanion copyWith(
      {Value<int>? id,
      Value<int>? drillId,
      Value<String>? drillName,
      Value<DateTime>? startedAt,
      Value<DateTime?>? completedAt,
      Value<int>? currentScore,
      Value<int>? targetScore,
      Value<int>? attempts,
      Value<int>? successfulAttempts,
      Value<String?>? rating,
      Value<String?>? notes}) {
    return DrillSessionsCompanion(
      id: id ?? this.id,
      drillId: drillId ?? this.drillId,
      drillName: drillName ?? this.drillName,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      currentScore: currentScore ?? this.currentScore,
      targetScore: targetScore ?? this.targetScore,
      attempts: attempts ?? this.attempts,
      successfulAttempts: successfulAttempts ?? this.successfulAttempts,
      rating: rating ?? this.rating,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (drillId.present) {
      map['drill_id'] = Variable<int>(drillId.value);
    }
    if (drillName.present) {
      map['drill_name'] = Variable<String>(drillName.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (currentScore.present) {
      map['current_score'] = Variable<int>(currentScore.value);
    }
    if (targetScore.present) {
      map['target_score'] = Variable<int>(targetScore.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (successfulAttempts.present) {
      map['successful_attempts'] = Variable<int>(successfulAttempts.value);
    }
    if (rating.present) {
      map['rating'] = Variable<String>(rating.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DrillSessionsCompanion(')
          ..write('id: $id, ')
          ..write('drillId: $drillId, ')
          ..write('drillName: $drillName, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('currentScore: $currentScore, ')
          ..write('targetScore: $targetScore, ')
          ..write('attempts: $attempts, ')
          ..write('successfulAttempts: $successfulAttempts, ')
          ..write('rating: $rating, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $TrainingProgramProgressTable extends TrainingProgramProgress
    with TableInfo<$TrainingProgramProgressTable, TrainingProgramProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrainingProgramProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _programIdMeta =
      const VerificationMeta('programId');
  @override
  late final GeneratedColumn<int> programId = GeneratedColumn<int>(
      'program_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _currentWeekMeta =
      const VerificationMeta('currentWeek');
  @override
  late final GeneratedColumn<int> currentWeek = GeneratedColumn<int>(
      'current_week', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _currentSessionMeta =
      const VerificationMeta('currentSession');
  @override
  late final GeneratedColumn<int> currentSession = GeneratedColumn<int>(
      'current_session', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _completedSessionsMeta =
      const VerificationMeta('completedSessions');
  @override
  late final GeneratedColumn<int> completedSessions = GeneratedColumn<int>(
      'completed_sessions', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _totalSessionsMeta =
      const VerificationMeta('totalSessions');
  @override
  late final GeneratedColumn<int> totalSessions = GeneratedColumn<int>(
      'total_sessions', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _overallProgressMeta =
      const VerificationMeta('overallProgress');
  @override
  late final GeneratedColumn<double> overallProgress = GeneratedColumn<double>(
      'overall_progress', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
      'started_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _completedSessionIdsMeta =
      const VerificationMeta('completedSessionIds');
  @override
  late final GeneratedColumn<String> completedSessionIds =
      GeneratedColumn<String>('completed_session_ids', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        programId,
        currentWeek,
        currentSession,
        completedSessions,
        totalSessions,
        overallProgress,
        startedAt,
        completedAt,
        completedSessionIds
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'training_program_progress';
  @override
  VerificationContext validateIntegrity(
      Insertable<TrainingProgramProgressData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('program_id')) {
      context.handle(_programIdMeta,
          programId.isAcceptableOrUnknown(data['program_id']!, _programIdMeta));
    } else if (isInserting) {
      context.missing(_programIdMeta);
    }
    if (data.containsKey('current_week')) {
      context.handle(
          _currentWeekMeta,
          currentWeek.isAcceptableOrUnknown(
              data['current_week']!, _currentWeekMeta));
    } else if (isInserting) {
      context.missing(_currentWeekMeta);
    }
    if (data.containsKey('current_session')) {
      context.handle(
          _currentSessionMeta,
          currentSession.isAcceptableOrUnknown(
              data['current_session']!, _currentSessionMeta));
    } else if (isInserting) {
      context.missing(_currentSessionMeta);
    }
    if (data.containsKey('completed_sessions')) {
      context.handle(
          _completedSessionsMeta,
          completedSessions.isAcceptableOrUnknown(
              data['completed_sessions']!, _completedSessionsMeta));
    } else if (isInserting) {
      context.missing(_completedSessionsMeta);
    }
    if (data.containsKey('total_sessions')) {
      context.handle(
          _totalSessionsMeta,
          totalSessions.isAcceptableOrUnknown(
              data['total_sessions']!, _totalSessionsMeta));
    } else if (isInserting) {
      context.missing(_totalSessionsMeta);
    }
    if (data.containsKey('overall_progress')) {
      context.handle(
          _overallProgressMeta,
          overallProgress.isAcceptableOrUnknown(
              data['overall_progress']!, _overallProgressMeta));
    } else if (isInserting) {
      context.missing(_overallProgressMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('completed_session_ids')) {
      context.handle(
          _completedSessionIdsMeta,
          completedSessionIds.isAcceptableOrUnknown(
              data['completed_session_ids']!, _completedSessionIdsMeta));
    } else if (isInserting) {
      context.missing(_completedSessionIdsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrainingProgramProgressData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrainingProgramProgressData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      programId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}program_id'])!,
      currentWeek: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}current_week'])!,
      currentSession: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}current_session'])!,
      completedSessions: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}completed_sessions'])!,
      totalSessions: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_sessions'])!,
      overallProgress: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}overall_progress'])!,
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}started_at'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      completedSessionIds: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}completed_session_ids'])!,
    );
  }

  @override
  $TrainingProgramProgressTable createAlias(String alias) {
    return $TrainingProgramProgressTable(attachedDatabase, alias);
  }
}

class TrainingProgramProgressData extends DataClass
    implements Insertable<TrainingProgramProgressData> {
  final int id;
  final int programId;
  final int currentWeek;
  final int currentSession;
  final int completedSessions;
  final int totalSessions;
  final double overallProgress;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String completedSessionIds;
  const TrainingProgramProgressData(
      {required this.id,
      required this.programId,
      required this.currentWeek,
      required this.currentSession,
      required this.completedSessions,
      required this.totalSessions,
      required this.overallProgress,
      required this.startedAt,
      this.completedAt,
      required this.completedSessionIds});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['program_id'] = Variable<int>(programId);
    map['current_week'] = Variable<int>(currentWeek);
    map['current_session'] = Variable<int>(currentSession);
    map['completed_sessions'] = Variable<int>(completedSessions);
    map['total_sessions'] = Variable<int>(totalSessions);
    map['overall_progress'] = Variable<double>(overallProgress);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['completed_session_ids'] = Variable<String>(completedSessionIds);
    return map;
  }

  TrainingProgramProgressCompanion toCompanion(bool nullToAbsent) {
    return TrainingProgramProgressCompanion(
      id: Value(id),
      programId: Value(programId),
      currentWeek: Value(currentWeek),
      currentSession: Value(currentSession),
      completedSessions: Value(completedSessions),
      totalSessions: Value(totalSessions),
      overallProgress: Value(overallProgress),
      startedAt: Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      completedSessionIds: Value(completedSessionIds),
    );
  }

  factory TrainingProgramProgressData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrainingProgramProgressData(
      id: serializer.fromJson<int>(json['id']),
      programId: serializer.fromJson<int>(json['programId']),
      currentWeek: serializer.fromJson<int>(json['currentWeek']),
      currentSession: serializer.fromJson<int>(json['currentSession']),
      completedSessions: serializer.fromJson<int>(json['completedSessions']),
      totalSessions: serializer.fromJson<int>(json['totalSessions']),
      overallProgress: serializer.fromJson<double>(json['overallProgress']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      completedSessionIds:
          serializer.fromJson<String>(json['completedSessionIds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'programId': serializer.toJson<int>(programId),
      'currentWeek': serializer.toJson<int>(currentWeek),
      'currentSession': serializer.toJson<int>(currentSession),
      'completedSessions': serializer.toJson<int>(completedSessions),
      'totalSessions': serializer.toJson<int>(totalSessions),
      'overallProgress': serializer.toJson<double>(overallProgress),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'completedSessionIds': serializer.toJson<String>(completedSessionIds),
    };
  }

  TrainingProgramProgressData copyWith(
          {int? id,
          int? programId,
          int? currentWeek,
          int? currentSession,
          int? completedSessions,
          int? totalSessions,
          double? overallProgress,
          DateTime? startedAt,
          Value<DateTime?> completedAt = const Value.absent(),
          String? completedSessionIds}) =>
      TrainingProgramProgressData(
        id: id ?? this.id,
        programId: programId ?? this.programId,
        currentWeek: currentWeek ?? this.currentWeek,
        currentSession: currentSession ?? this.currentSession,
        completedSessions: completedSessions ?? this.completedSessions,
        totalSessions: totalSessions ?? this.totalSessions,
        overallProgress: overallProgress ?? this.overallProgress,
        startedAt: startedAt ?? this.startedAt,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        completedSessionIds: completedSessionIds ?? this.completedSessionIds,
      );
  TrainingProgramProgressData copyWithCompanion(
      TrainingProgramProgressCompanion data) {
    return TrainingProgramProgressData(
      id: data.id.present ? data.id.value : this.id,
      programId: data.programId.present ? data.programId.value : this.programId,
      currentWeek:
          data.currentWeek.present ? data.currentWeek.value : this.currentWeek,
      currentSession: data.currentSession.present
          ? data.currentSession.value
          : this.currentSession,
      completedSessions: data.completedSessions.present
          ? data.completedSessions.value
          : this.completedSessions,
      totalSessions: data.totalSessions.present
          ? data.totalSessions.value
          : this.totalSessions,
      overallProgress: data.overallProgress.present
          ? data.overallProgress.value
          : this.overallProgress,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      completedSessionIds: data.completedSessionIds.present
          ? data.completedSessionIds.value
          : this.completedSessionIds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrainingProgramProgressData(')
          ..write('id: $id, ')
          ..write('programId: $programId, ')
          ..write('currentWeek: $currentWeek, ')
          ..write('currentSession: $currentSession, ')
          ..write('completedSessions: $completedSessions, ')
          ..write('totalSessions: $totalSessions, ')
          ..write('overallProgress: $overallProgress, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('completedSessionIds: $completedSessionIds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      programId,
      currentWeek,
      currentSession,
      completedSessions,
      totalSessions,
      overallProgress,
      startedAt,
      completedAt,
      completedSessionIds);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrainingProgramProgressData &&
          other.id == this.id &&
          other.programId == this.programId &&
          other.currentWeek == this.currentWeek &&
          other.currentSession == this.currentSession &&
          other.completedSessions == this.completedSessions &&
          other.totalSessions == this.totalSessions &&
          other.overallProgress == this.overallProgress &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.completedSessionIds == this.completedSessionIds);
}

class TrainingProgramProgressCompanion
    extends UpdateCompanion<TrainingProgramProgressData> {
  final Value<int> id;
  final Value<int> programId;
  final Value<int> currentWeek;
  final Value<int> currentSession;
  final Value<int> completedSessions;
  final Value<int> totalSessions;
  final Value<double> overallProgress;
  final Value<DateTime> startedAt;
  final Value<DateTime?> completedAt;
  final Value<String> completedSessionIds;
  const TrainingProgramProgressCompanion({
    this.id = const Value.absent(),
    this.programId = const Value.absent(),
    this.currentWeek = const Value.absent(),
    this.currentSession = const Value.absent(),
    this.completedSessions = const Value.absent(),
    this.totalSessions = const Value.absent(),
    this.overallProgress = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.completedSessionIds = const Value.absent(),
  });
  TrainingProgramProgressCompanion.insert({
    this.id = const Value.absent(),
    required int programId,
    required int currentWeek,
    required int currentSession,
    required int completedSessions,
    required int totalSessions,
    required double overallProgress,
    required DateTime startedAt,
    this.completedAt = const Value.absent(),
    required String completedSessionIds,
  })  : programId = Value(programId),
        currentWeek = Value(currentWeek),
        currentSession = Value(currentSession),
        completedSessions = Value(completedSessions),
        totalSessions = Value(totalSessions),
        overallProgress = Value(overallProgress),
        startedAt = Value(startedAt),
        completedSessionIds = Value(completedSessionIds);
  static Insertable<TrainingProgramProgressData> custom({
    Expression<int>? id,
    Expression<int>? programId,
    Expression<int>? currentWeek,
    Expression<int>? currentSession,
    Expression<int>? completedSessions,
    Expression<int>? totalSessions,
    Expression<double>? overallProgress,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<String>? completedSessionIds,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (programId != null) 'program_id': programId,
      if (currentWeek != null) 'current_week': currentWeek,
      if (currentSession != null) 'current_session': currentSession,
      if (completedSessions != null) 'completed_sessions': completedSessions,
      if (totalSessions != null) 'total_sessions': totalSessions,
      if (overallProgress != null) 'overall_progress': overallProgress,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (completedSessionIds != null)
        'completed_session_ids': completedSessionIds,
    });
  }

  TrainingProgramProgressCompanion copyWith(
      {Value<int>? id,
      Value<int>? programId,
      Value<int>? currentWeek,
      Value<int>? currentSession,
      Value<int>? completedSessions,
      Value<int>? totalSessions,
      Value<double>? overallProgress,
      Value<DateTime>? startedAt,
      Value<DateTime?>? completedAt,
      Value<String>? completedSessionIds}) {
    return TrainingProgramProgressCompanion(
      id: id ?? this.id,
      programId: programId ?? this.programId,
      currentWeek: currentWeek ?? this.currentWeek,
      currentSession: currentSession ?? this.currentSession,
      completedSessions: completedSessions ?? this.completedSessions,
      totalSessions: totalSessions ?? this.totalSessions,
      overallProgress: overallProgress ?? this.overallProgress,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      completedSessionIds: completedSessionIds ?? this.completedSessionIds,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (programId.present) {
      map['program_id'] = Variable<int>(programId.value);
    }
    if (currentWeek.present) {
      map['current_week'] = Variable<int>(currentWeek.value);
    }
    if (currentSession.present) {
      map['current_session'] = Variable<int>(currentSession.value);
    }
    if (completedSessions.present) {
      map['completed_sessions'] = Variable<int>(completedSessions.value);
    }
    if (totalSessions.present) {
      map['total_sessions'] = Variable<int>(totalSessions.value);
    }
    if (overallProgress.present) {
      map['overall_progress'] = Variable<double>(overallProgress.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (completedSessionIds.present) {
      map['completed_session_ids'] =
          Variable<String>(completedSessionIds.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrainingProgramProgressCompanion(')
          ..write('id: $id, ')
          ..write('programId: $programId, ')
          ..write('currentWeek: $currentWeek, ')
          ..write('currentSession: $currentSession, ')
          ..write('completedSessions: $completedSessions, ')
          ..write('totalSessions: $totalSessions, ')
          ..write('overallProgress: $overallProgress, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('completedSessionIds: $completedSessionIds')
          ..write(')'))
        .toString();
  }
}

class $PracticeShotsTable extends PracticeShots
    with TableInfo<$PracticeShotsTable, PracticeShot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PracticeShotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
      'session_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _drillCodeMeta =
      const VerificationMeta('drillCode');
  @override
  late final GeneratedColumn<String> drillCode = GeneratedColumn<String>(
      'drill_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _shotNumberMeta =
      const VerificationMeta('shotNumber');
  @override
  late final GeneratedColumn<int> shotNumber = GeneratedColumn<int>(
      'shot_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _shotTypeMeta =
      const VerificationMeta('shotType');
  @override
  late final GeneratedColumn<String> shotType = GeneratedColumn<String>(
      'shot_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _successMeta =
      const VerificationMeta('success');
  @override
  late final GeneratedColumn<bool> success = GeneratedColumn<bool>(
      'success', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("success" IN (0, 1))'));
  static const VerificationMeta _missTypeMeta =
      const VerificationMeta('missType');
  @override
  late final GeneratedColumn<String> missType = GeneratedColumn<String>(
      'miss_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cueBallControlMeta =
      const VerificationMeta('cueBallControl');
  @override
  late final GeneratedColumn<int> cueBallControl = GeneratedColumn<int>(
      'cue_ball_control', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(3));
  static const VerificationMeta _positionMeta =
      const VerificationMeta('position');
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
      'position', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(3));
  static const VerificationMeta _difficultyMeta =
      const VerificationMeta('difficulty');
  @override
  late final GeneratedColumn<int> difficulty = GeneratedColumn<int>(
      'difficulty', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(3));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        sessionId,
        drillCode,
        shotNumber,
        shotType,
        success,
        missType,
        cueBallControl,
        position,
        difficulty,
        notes,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'practice_shots';
  @override
  VerificationContext validateIntegrity(Insertable<PracticeShot> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    }
    if (data.containsKey('drill_code')) {
      context.handle(_drillCodeMeta,
          drillCode.isAcceptableOrUnknown(data['drill_code']!, _drillCodeMeta));
    } else if (isInserting) {
      context.missing(_drillCodeMeta);
    }
    if (data.containsKey('shot_number')) {
      context.handle(
          _shotNumberMeta,
          shotNumber.isAcceptableOrUnknown(
              data['shot_number']!, _shotNumberMeta));
    } else if (isInserting) {
      context.missing(_shotNumberMeta);
    }
    if (data.containsKey('shot_type')) {
      context.handle(_shotTypeMeta,
          shotType.isAcceptableOrUnknown(data['shot_type']!, _shotTypeMeta));
    } else if (isInserting) {
      context.missing(_shotTypeMeta);
    }
    if (data.containsKey('success')) {
      context.handle(_successMeta,
          success.isAcceptableOrUnknown(data['success']!, _successMeta));
    } else if (isInserting) {
      context.missing(_successMeta);
    }
    if (data.containsKey('miss_type')) {
      context.handle(_missTypeMeta,
          missType.isAcceptableOrUnknown(data['miss_type']!, _missTypeMeta));
    }
    if (data.containsKey('cue_ball_control')) {
      context.handle(
          _cueBallControlMeta,
          cueBallControl.isAcceptableOrUnknown(
              data['cue_ball_control']!, _cueBallControlMeta));
    }
    if (data.containsKey('position')) {
      context.handle(_positionMeta,
          position.isAcceptableOrUnknown(data['position']!, _positionMeta));
    }
    if (data.containsKey('difficulty')) {
      context.handle(
          _difficultyMeta,
          difficulty.isAcceptableOrUnknown(
              data['difficulty']!, _difficultyMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PracticeShot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PracticeShot(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}session_id']),
      drillCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}drill_code'])!,
      shotNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}shot_number'])!,
      shotType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}shot_type'])!,
      success: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}success'])!,
      missType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}miss_type']),
      cueBallControl: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cue_ball_control'])!,
      position: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}position'])!,
      difficulty: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}difficulty'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PracticeShotsTable createAlias(String alias) {
    return $PracticeShotsTable(attachedDatabase, alias);
  }
}

class PracticeShot extends DataClass implements Insertable<PracticeShot> {
  final int id;
  final int? sessionId;
  final String drillCode;
  final int shotNumber;
  final String shotType;
  final bool success;
  final String? missType;
  final int cueBallControl;
  final int position;
  final int difficulty;
  final String? notes;
  final DateTime createdAt;
  const PracticeShot(
      {required this.id,
      this.sessionId,
      required this.drillCode,
      required this.shotNumber,
      required this.shotType,
      required this.success,
      this.missType,
      required this.cueBallControl,
      required this.position,
      required this.difficulty,
      this.notes,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<int>(sessionId);
    }
    map['drill_code'] = Variable<String>(drillCode);
    map['shot_number'] = Variable<int>(shotNumber);
    map['shot_type'] = Variable<String>(shotType);
    map['success'] = Variable<bool>(success);
    if (!nullToAbsent || missType != null) {
      map['miss_type'] = Variable<String>(missType);
    }
    map['cue_ball_control'] = Variable<int>(cueBallControl);
    map['position'] = Variable<int>(position);
    map['difficulty'] = Variable<int>(difficulty);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PracticeShotsCompanion toCompanion(bool nullToAbsent) {
    return PracticeShotsCompanion(
      id: Value(id),
      sessionId: sessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionId),
      drillCode: Value(drillCode),
      shotNumber: Value(shotNumber),
      shotType: Value(shotType),
      success: Value(success),
      missType: missType == null && nullToAbsent
          ? const Value.absent()
          : Value(missType),
      cueBallControl: Value(cueBallControl),
      position: Value(position),
      difficulty: Value(difficulty),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory PracticeShot.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PracticeShot(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int?>(json['sessionId']),
      drillCode: serializer.fromJson<String>(json['drillCode']),
      shotNumber: serializer.fromJson<int>(json['shotNumber']),
      shotType: serializer.fromJson<String>(json['shotType']),
      success: serializer.fromJson<bool>(json['success']),
      missType: serializer.fromJson<String?>(json['missType']),
      cueBallControl: serializer.fromJson<int>(json['cueBallControl']),
      position: serializer.fromJson<int>(json['position']),
      difficulty: serializer.fromJson<int>(json['difficulty']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int?>(sessionId),
      'drillCode': serializer.toJson<String>(drillCode),
      'shotNumber': serializer.toJson<int>(shotNumber),
      'shotType': serializer.toJson<String>(shotType),
      'success': serializer.toJson<bool>(success),
      'missType': serializer.toJson<String?>(missType),
      'cueBallControl': serializer.toJson<int>(cueBallControl),
      'position': serializer.toJson<int>(position),
      'difficulty': serializer.toJson<int>(difficulty),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PracticeShot copyWith(
          {int? id,
          Value<int?> sessionId = const Value.absent(),
          String? drillCode,
          int? shotNumber,
          String? shotType,
          bool? success,
          Value<String?> missType = const Value.absent(),
          int? cueBallControl,
          int? position,
          int? difficulty,
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt}) =>
      PracticeShot(
        id: id ?? this.id,
        sessionId: sessionId.present ? sessionId.value : this.sessionId,
        drillCode: drillCode ?? this.drillCode,
        shotNumber: shotNumber ?? this.shotNumber,
        shotType: shotType ?? this.shotType,
        success: success ?? this.success,
        missType: missType.present ? missType.value : this.missType,
        cueBallControl: cueBallControl ?? this.cueBallControl,
        position: position ?? this.position,
        difficulty: difficulty ?? this.difficulty,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
      );
  PracticeShot copyWithCompanion(PracticeShotsCompanion data) {
    return PracticeShot(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      drillCode: data.drillCode.present ? data.drillCode.value : this.drillCode,
      shotNumber:
          data.shotNumber.present ? data.shotNumber.value : this.shotNumber,
      shotType: data.shotType.present ? data.shotType.value : this.shotType,
      success: data.success.present ? data.success.value : this.success,
      missType: data.missType.present ? data.missType.value : this.missType,
      cueBallControl: data.cueBallControl.present
          ? data.cueBallControl.value
          : this.cueBallControl,
      position: data.position.present ? data.position.value : this.position,
      difficulty:
          data.difficulty.present ? data.difficulty.value : this.difficulty,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PracticeShot(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('drillCode: $drillCode, ')
          ..write('shotNumber: $shotNumber, ')
          ..write('shotType: $shotType, ')
          ..write('success: $success, ')
          ..write('missType: $missType, ')
          ..write('cueBallControl: $cueBallControl, ')
          ..write('position: $position, ')
          ..write('difficulty: $difficulty, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      sessionId,
      drillCode,
      shotNumber,
      shotType,
      success,
      missType,
      cueBallControl,
      position,
      difficulty,
      notes,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PracticeShot &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.drillCode == this.drillCode &&
          other.shotNumber == this.shotNumber &&
          other.shotType == this.shotType &&
          other.success == this.success &&
          other.missType == this.missType &&
          other.cueBallControl == this.cueBallControl &&
          other.position == this.position &&
          other.difficulty == this.difficulty &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class PracticeShotsCompanion extends UpdateCompanion<PracticeShot> {
  final Value<int> id;
  final Value<int?> sessionId;
  final Value<String> drillCode;
  final Value<int> shotNumber;
  final Value<String> shotType;
  final Value<bool> success;
  final Value<String?> missType;
  final Value<int> cueBallControl;
  final Value<int> position;
  final Value<int> difficulty;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  const PracticeShotsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.drillCode = const Value.absent(),
    this.shotNumber = const Value.absent(),
    this.shotType = const Value.absent(),
    this.success = const Value.absent(),
    this.missType = const Value.absent(),
    this.cueBallControl = const Value.absent(),
    this.position = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PracticeShotsCompanion.insert({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    required String drillCode,
    required int shotNumber,
    required String shotType,
    required bool success,
    this.missType = const Value.absent(),
    this.cueBallControl = const Value.absent(),
    this.position = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
  })  : drillCode = Value(drillCode),
        shotNumber = Value(shotNumber),
        shotType = Value(shotType),
        success = Value(success),
        createdAt = Value(createdAt);
  static Insertable<PracticeShot> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<String>? drillCode,
    Expression<int>? shotNumber,
    Expression<String>? shotType,
    Expression<bool>? success,
    Expression<String>? missType,
    Expression<int>? cueBallControl,
    Expression<int>? position,
    Expression<int>? difficulty,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (drillCode != null) 'drill_code': drillCode,
      if (shotNumber != null) 'shot_number': shotNumber,
      if (shotType != null) 'shot_type': shotType,
      if (success != null) 'success': success,
      if (missType != null) 'miss_type': missType,
      if (cueBallControl != null) 'cue_ball_control': cueBallControl,
      if (position != null) 'position': position,
      if (difficulty != null) 'difficulty': difficulty,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PracticeShotsCompanion copyWith(
      {Value<int>? id,
      Value<int?>? sessionId,
      Value<String>? drillCode,
      Value<int>? shotNumber,
      Value<String>? shotType,
      Value<bool>? success,
      Value<String?>? missType,
      Value<int>? cueBallControl,
      Value<int>? position,
      Value<int>? difficulty,
      Value<String?>? notes,
      Value<DateTime>? createdAt}) {
    return PracticeShotsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      drillCode: drillCode ?? this.drillCode,
      shotNumber: shotNumber ?? this.shotNumber,
      shotType: shotType ?? this.shotType,
      success: success ?? this.success,
      missType: missType ?? this.missType,
      cueBallControl: cueBallControl ?? this.cueBallControl,
      position: position ?? this.position,
      difficulty: difficulty ?? this.difficulty,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (drillCode.present) {
      map['drill_code'] = Variable<String>(drillCode.value);
    }
    if (shotNumber.present) {
      map['shot_number'] = Variable<int>(shotNumber.value);
    }
    if (shotType.present) {
      map['shot_type'] = Variable<String>(shotType.value);
    }
    if (success.present) {
      map['success'] = Variable<bool>(success.value);
    }
    if (missType.present) {
      map['miss_type'] = Variable<String>(missType.value);
    }
    if (cueBallControl.present) {
      map['cue_ball_control'] = Variable<int>(cueBallControl.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<int>(difficulty.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PracticeShotsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('drillCode: $drillCode, ')
          ..write('shotNumber: $shotNumber, ')
          ..write('shotType: $shotType, ')
          ..write('success: $success, ')
          ..write('missType: $missType, ')
          ..write('cueBallControl: $cueBallControl, ')
          ..write('position: $position, ')
          ..write('difficulty: $difficulty, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PracticeSessionsTable extends PracticeSessions
    with TableInfo<$PracticeSessionsTable, PracticeSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PracticeSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _playerIdMeta =
      const VerificationMeta('playerId');
  @override
  late final GeneratedColumn<int> playerId = GeneratedColumn<int>(
      'player_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
      'session_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _drillCodeMeta =
      const VerificationMeta('drillCode');
  @override
  late final GeneratedColumn<String> drillCode = GeneratedColumn<String>(
      'drill_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _drillNameMeta =
      const VerificationMeta('drillName');
  @override
  late final GeneratedColumn<String> drillName = GeneratedColumn<String>(
      'drill_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
      'started_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _totalShotsMeta =
      const VerificationMeta('totalShots');
  @override
  late final GeneratedColumn<int> totalShots = GeneratedColumn<int>(
      'total_shots', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _successfulShotsMeta =
      const VerificationMeta('successfulShots');
  @override
  late final GeneratedColumn<int> successfulShots = GeneratedColumn<int>(
      'successful_shots', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _successRateMeta =
      const VerificationMeta('successRate');
  @override
  late final GeneratedColumn<double> successRate = GeneratedColumn<double>(
      'success_rate', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _averageDifficultyMeta =
      const VerificationMeta('averageDifficulty');
  @override
  late final GeneratedColumn<double> averageDifficulty =
      GeneratedColumn<double>('average_difficulty', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(0.0));
  static const VerificationMeta _longestRunMeta =
      const VerificationMeta('longestRun');
  @override
  late final GeneratedColumn<int> longestRun = GeneratedColumn<int>(
      'longest_run', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _shotsByTypeMeta =
      const VerificationMeta('shotsByType');
  @override
  late final GeneratedColumn<String> shotsByType = GeneratedColumn<String>(
      'shots_by_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _missesByTypeMeta =
      const VerificationMeta('missesByType');
  @override
  late final GeneratedColumn<String> missesByType = GeneratedColumn<String>(
      'misses_by_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        playerId,
        sessionId,
        drillCode,
        drillName,
        startedAt,
        completedAt,
        notes,
        totalShots,
        successfulShots,
        successRate,
        averageDifficulty,
        longestRun,
        shotsByType,
        missesByType
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'practice_sessions';
  @override
  VerificationContext validateIntegrity(Insertable<PracticeSession> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('player_id')) {
      context.handle(_playerIdMeta,
          playerId.isAcceptableOrUnknown(data['player_id']!, _playerIdMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    }
    if (data.containsKey('drill_code')) {
      context.handle(_drillCodeMeta,
          drillCode.isAcceptableOrUnknown(data['drill_code']!, _drillCodeMeta));
    } else if (isInserting) {
      context.missing(_drillCodeMeta);
    }
    if (data.containsKey('drill_name')) {
      context.handle(_drillNameMeta,
          drillName.isAcceptableOrUnknown(data['drill_name']!, _drillNameMeta));
    } else if (isInserting) {
      context.missing(_drillNameMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('total_shots')) {
      context.handle(
          _totalShotsMeta,
          totalShots.isAcceptableOrUnknown(
              data['total_shots']!, _totalShotsMeta));
    }
    if (data.containsKey('successful_shots')) {
      context.handle(
          _successfulShotsMeta,
          successfulShots.isAcceptableOrUnknown(
              data['successful_shots']!, _successfulShotsMeta));
    }
    if (data.containsKey('success_rate')) {
      context.handle(
          _successRateMeta,
          successRate.isAcceptableOrUnknown(
              data['success_rate']!, _successRateMeta));
    }
    if (data.containsKey('average_difficulty')) {
      context.handle(
          _averageDifficultyMeta,
          averageDifficulty.isAcceptableOrUnknown(
              data['average_difficulty']!, _averageDifficultyMeta));
    }
    if (data.containsKey('longest_run')) {
      context.handle(
          _longestRunMeta,
          longestRun.isAcceptableOrUnknown(
              data['longest_run']!, _longestRunMeta));
    }
    if (data.containsKey('shots_by_type')) {
      context.handle(
          _shotsByTypeMeta,
          shotsByType.isAcceptableOrUnknown(
              data['shots_by_type']!, _shotsByTypeMeta));
    }
    if (data.containsKey('misses_by_type')) {
      context.handle(
          _missesByTypeMeta,
          missesByType.isAcceptableOrUnknown(
              data['misses_by_type']!, _missesByTypeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PracticeSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PracticeSession(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      playerId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}player_id']),
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}session_id']),
      drillCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}drill_code'])!,
      drillName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}drill_name'])!,
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}started_at'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      totalShots: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_shots'])!,
      successfulShots: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}successful_shots'])!,
      successRate: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}success_rate'])!,
      averageDifficulty: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}average_difficulty'])!,
      longestRun: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}longest_run'])!,
      shotsByType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}shots_by_type'])!,
      missesByType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}misses_by_type'])!,
    );
  }

  @override
  $PracticeSessionsTable createAlias(String alias) {
    return $PracticeSessionsTable(attachedDatabase, alias);
  }
}

class PracticeSession extends DataClass implements Insertable<PracticeSession> {
  final int id;
  final int? playerId;
  final int? sessionId;
  final String drillCode;
  final String drillName;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String? notes;
  final int totalShots;
  final int successfulShots;
  final double successRate;
  final double averageDifficulty;
  final int longestRun;
  final String shotsByType;
  final String missesByType;
  const PracticeSession(
      {required this.id,
      this.playerId,
      this.sessionId,
      required this.drillCode,
      required this.drillName,
      required this.startedAt,
      this.completedAt,
      this.notes,
      required this.totalShots,
      required this.successfulShots,
      required this.successRate,
      required this.averageDifficulty,
      required this.longestRun,
      required this.shotsByType,
      required this.missesByType});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || playerId != null) {
      map['player_id'] = Variable<int>(playerId);
    }
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<int>(sessionId);
    }
    map['drill_code'] = Variable<String>(drillCode);
    map['drill_name'] = Variable<String>(drillName);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['total_shots'] = Variable<int>(totalShots);
    map['successful_shots'] = Variable<int>(successfulShots);
    map['success_rate'] = Variable<double>(successRate);
    map['average_difficulty'] = Variable<double>(averageDifficulty);
    map['longest_run'] = Variable<int>(longestRun);
    map['shots_by_type'] = Variable<String>(shotsByType);
    map['misses_by_type'] = Variable<String>(missesByType);
    return map;
  }

  PracticeSessionsCompanion toCompanion(bool nullToAbsent) {
    return PracticeSessionsCompanion(
      id: Value(id),
      playerId: playerId == null && nullToAbsent
          ? const Value.absent()
          : Value(playerId),
      sessionId: sessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionId),
      drillCode: Value(drillCode),
      drillName: Value(drillName),
      startedAt: Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      totalShots: Value(totalShots),
      successfulShots: Value(successfulShots),
      successRate: Value(successRate),
      averageDifficulty: Value(averageDifficulty),
      longestRun: Value(longestRun),
      shotsByType: Value(shotsByType),
      missesByType: Value(missesByType),
    );
  }

  factory PracticeSession.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PracticeSession(
      id: serializer.fromJson<int>(json['id']),
      playerId: serializer.fromJson<int?>(json['playerId']),
      sessionId: serializer.fromJson<int?>(json['sessionId']),
      drillCode: serializer.fromJson<String>(json['drillCode']),
      drillName: serializer.fromJson<String>(json['drillName']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      notes: serializer.fromJson<String?>(json['notes']),
      totalShots: serializer.fromJson<int>(json['totalShots']),
      successfulShots: serializer.fromJson<int>(json['successfulShots']),
      successRate: serializer.fromJson<double>(json['successRate']),
      averageDifficulty: serializer.fromJson<double>(json['averageDifficulty']),
      longestRun: serializer.fromJson<int>(json['longestRun']),
      shotsByType: serializer.fromJson<String>(json['shotsByType']),
      missesByType: serializer.fromJson<String>(json['missesByType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'playerId': serializer.toJson<int?>(playerId),
      'sessionId': serializer.toJson<int?>(sessionId),
      'drillCode': serializer.toJson<String>(drillCode),
      'drillName': serializer.toJson<String>(drillName),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'notes': serializer.toJson<String?>(notes),
      'totalShots': serializer.toJson<int>(totalShots),
      'successfulShots': serializer.toJson<int>(successfulShots),
      'successRate': serializer.toJson<double>(successRate),
      'averageDifficulty': serializer.toJson<double>(averageDifficulty),
      'longestRun': serializer.toJson<int>(longestRun),
      'shotsByType': serializer.toJson<String>(shotsByType),
      'missesByType': serializer.toJson<String>(missesByType),
    };
  }

  PracticeSession copyWith(
          {int? id,
          Value<int?> playerId = const Value.absent(),
          Value<int?> sessionId = const Value.absent(),
          String? drillCode,
          String? drillName,
          DateTime? startedAt,
          Value<DateTime?> completedAt = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          int? totalShots,
          int? successfulShots,
          double? successRate,
          double? averageDifficulty,
          int? longestRun,
          String? shotsByType,
          String? missesByType}) =>
      PracticeSession(
        id: id ?? this.id,
        playerId: playerId.present ? playerId.value : this.playerId,
        sessionId: sessionId.present ? sessionId.value : this.sessionId,
        drillCode: drillCode ?? this.drillCode,
        drillName: drillName ?? this.drillName,
        startedAt: startedAt ?? this.startedAt,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        notes: notes.present ? notes.value : this.notes,
        totalShots: totalShots ?? this.totalShots,
        successfulShots: successfulShots ?? this.successfulShots,
        successRate: successRate ?? this.successRate,
        averageDifficulty: averageDifficulty ?? this.averageDifficulty,
        longestRun: longestRun ?? this.longestRun,
        shotsByType: shotsByType ?? this.shotsByType,
        missesByType: missesByType ?? this.missesByType,
      );
  PracticeSession copyWithCompanion(PracticeSessionsCompanion data) {
    return PracticeSession(
      id: data.id.present ? data.id.value : this.id,
      playerId: data.playerId.present ? data.playerId.value : this.playerId,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      drillCode: data.drillCode.present ? data.drillCode.value : this.drillCode,
      drillName: data.drillName.present ? data.drillName.value : this.drillName,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      notes: data.notes.present ? data.notes.value : this.notes,
      totalShots:
          data.totalShots.present ? data.totalShots.value : this.totalShots,
      successfulShots: data.successfulShots.present
          ? data.successfulShots.value
          : this.successfulShots,
      successRate:
          data.successRate.present ? data.successRate.value : this.successRate,
      averageDifficulty: data.averageDifficulty.present
          ? data.averageDifficulty.value
          : this.averageDifficulty,
      longestRun:
          data.longestRun.present ? data.longestRun.value : this.longestRun,
      shotsByType:
          data.shotsByType.present ? data.shotsByType.value : this.shotsByType,
      missesByType: data.missesByType.present
          ? data.missesByType.value
          : this.missesByType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PracticeSession(')
          ..write('id: $id, ')
          ..write('playerId: $playerId, ')
          ..write('sessionId: $sessionId, ')
          ..write('drillCode: $drillCode, ')
          ..write('drillName: $drillName, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('notes: $notes, ')
          ..write('totalShots: $totalShots, ')
          ..write('successfulShots: $successfulShots, ')
          ..write('successRate: $successRate, ')
          ..write('averageDifficulty: $averageDifficulty, ')
          ..write('longestRun: $longestRun, ')
          ..write('shotsByType: $shotsByType, ')
          ..write('missesByType: $missesByType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      playerId,
      sessionId,
      drillCode,
      drillName,
      startedAt,
      completedAt,
      notes,
      totalShots,
      successfulShots,
      successRate,
      averageDifficulty,
      longestRun,
      shotsByType,
      missesByType);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PracticeSession &&
          other.id == this.id &&
          other.playerId == this.playerId &&
          other.sessionId == this.sessionId &&
          other.drillCode == this.drillCode &&
          other.drillName == this.drillName &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.notes == this.notes &&
          other.totalShots == this.totalShots &&
          other.successfulShots == this.successfulShots &&
          other.successRate == this.successRate &&
          other.averageDifficulty == this.averageDifficulty &&
          other.longestRun == this.longestRun &&
          other.shotsByType == this.shotsByType &&
          other.missesByType == this.missesByType);
}

class PracticeSessionsCompanion extends UpdateCompanion<PracticeSession> {
  final Value<int> id;
  final Value<int?> playerId;
  final Value<int?> sessionId;
  final Value<String> drillCode;
  final Value<String> drillName;
  final Value<DateTime> startedAt;
  final Value<DateTime?> completedAt;
  final Value<String?> notes;
  final Value<int> totalShots;
  final Value<int> successfulShots;
  final Value<double> successRate;
  final Value<double> averageDifficulty;
  final Value<int> longestRun;
  final Value<String> shotsByType;
  final Value<String> missesByType;
  const PracticeSessionsCompanion({
    this.id = const Value.absent(),
    this.playerId = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.drillCode = const Value.absent(),
    this.drillName = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.totalShots = const Value.absent(),
    this.successfulShots = const Value.absent(),
    this.successRate = const Value.absent(),
    this.averageDifficulty = const Value.absent(),
    this.longestRun = const Value.absent(),
    this.shotsByType = const Value.absent(),
    this.missesByType = const Value.absent(),
  });
  PracticeSessionsCompanion.insert({
    this.id = const Value.absent(),
    this.playerId = const Value.absent(),
    this.sessionId = const Value.absent(),
    required String drillCode,
    required String drillName,
    required DateTime startedAt,
    this.completedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.totalShots = const Value.absent(),
    this.successfulShots = const Value.absent(),
    this.successRate = const Value.absent(),
    this.averageDifficulty = const Value.absent(),
    this.longestRun = const Value.absent(),
    this.shotsByType = const Value.absent(),
    this.missesByType = const Value.absent(),
  })  : drillCode = Value(drillCode),
        drillName = Value(drillName),
        startedAt = Value(startedAt);
  static Insertable<PracticeSession> custom({
    Expression<int>? id,
    Expression<int>? playerId,
    Expression<int>? sessionId,
    Expression<String>? drillCode,
    Expression<String>? drillName,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<String>? notes,
    Expression<int>? totalShots,
    Expression<int>? successfulShots,
    Expression<double>? successRate,
    Expression<double>? averageDifficulty,
    Expression<int>? longestRun,
    Expression<String>? shotsByType,
    Expression<String>? missesByType,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (playerId != null) 'player_id': playerId,
      if (sessionId != null) 'session_id': sessionId,
      if (drillCode != null) 'drill_code': drillCode,
      if (drillName != null) 'drill_name': drillName,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (notes != null) 'notes': notes,
      if (totalShots != null) 'total_shots': totalShots,
      if (successfulShots != null) 'successful_shots': successfulShots,
      if (successRate != null) 'success_rate': successRate,
      if (averageDifficulty != null) 'average_difficulty': averageDifficulty,
      if (longestRun != null) 'longest_run': longestRun,
      if (shotsByType != null) 'shots_by_type': shotsByType,
      if (missesByType != null) 'misses_by_type': missesByType,
    });
  }

  PracticeSessionsCompanion copyWith(
      {Value<int>? id,
      Value<int?>? playerId,
      Value<int?>? sessionId,
      Value<String>? drillCode,
      Value<String>? drillName,
      Value<DateTime>? startedAt,
      Value<DateTime?>? completedAt,
      Value<String?>? notes,
      Value<int>? totalShots,
      Value<int>? successfulShots,
      Value<double>? successRate,
      Value<double>? averageDifficulty,
      Value<int>? longestRun,
      Value<String>? shotsByType,
      Value<String>? missesByType}) {
    return PracticeSessionsCompanion(
      id: id ?? this.id,
      playerId: playerId ?? this.playerId,
      sessionId: sessionId ?? this.sessionId,
      drillCode: drillCode ?? this.drillCode,
      drillName: drillName ?? this.drillName,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
      totalShots: totalShots ?? this.totalShots,
      successfulShots: successfulShots ?? this.successfulShots,
      successRate: successRate ?? this.successRate,
      averageDifficulty: averageDifficulty ?? this.averageDifficulty,
      longestRun: longestRun ?? this.longestRun,
      shotsByType: shotsByType ?? this.shotsByType,
      missesByType: missesByType ?? this.missesByType,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (playerId.present) {
      map['player_id'] = Variable<int>(playerId.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (drillCode.present) {
      map['drill_code'] = Variable<String>(drillCode.value);
    }
    if (drillName.present) {
      map['drill_name'] = Variable<String>(drillName.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (totalShots.present) {
      map['total_shots'] = Variable<int>(totalShots.value);
    }
    if (successfulShots.present) {
      map['successful_shots'] = Variable<int>(successfulShots.value);
    }
    if (successRate.present) {
      map['success_rate'] = Variable<double>(successRate.value);
    }
    if (averageDifficulty.present) {
      map['average_difficulty'] = Variable<double>(averageDifficulty.value);
    }
    if (longestRun.present) {
      map['longest_run'] = Variable<int>(longestRun.value);
    }
    if (shotsByType.present) {
      map['shots_by_type'] = Variable<String>(shotsByType.value);
    }
    if (missesByType.present) {
      map['misses_by_type'] = Variable<String>(missesByType.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PracticeSessionsCompanion(')
          ..write('id: $id, ')
          ..write('playerId: $playerId, ')
          ..write('sessionId: $sessionId, ')
          ..write('drillCode: $drillCode, ')
          ..write('drillName: $drillName, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('notes: $notes, ')
          ..write('totalShots: $totalShots, ')
          ..write('successfulShots: $successfulShots, ')
          ..write('successRate: $successRate, ')
          ..write('averageDifficulty: $averageDifficulty, ')
          ..write('longestRun: $longestRun, ')
          ..write('shotsByType: $shotsByType, ')
          ..write('missesByType: $missesByType')
          ..write(')'))
        .toString();
  }
}

class $PlayerStateLogsTable extends PlayerStateLogs
    with TableInfo<$PlayerStateLogsTable, PlayerStateLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayerStateLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
      'session_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _matchIdMeta =
      const VerificationMeta('matchId');
  @override
  late final GeneratedColumn<int> matchId = GeneratedColumn<int>(
      'match_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _readyToCompeteMeta =
      const VerificationMeta('readyToCompete');
  @override
  late final GeneratedColumn<int> readyToCompete = GeneratedColumn<int>(
      'ready_to_compete', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _warmedUpMeta =
      const VerificationMeta('warmedUp');
  @override
  late final GeneratedColumn<int> warmedUp = GeneratedColumn<int>(
      'warmed_up', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _handFeelMeta =
      const VerificationMeta('handFeel');
  @override
  late final GeneratedColumn<int> handFeel = GeneratedColumn<int>(
      'hand_feel', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _fatigueLevelMeta =
      const VerificationMeta('fatigueLevel');
  @override
  late final GeneratedColumn<int> fatigueLevel = GeneratedColumn<int>(
      'fatigue_level', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        sessionId,
        matchId,
        kind,
        readyToCompete,
        warmedUp,
        handFeel,
        fatigueLevel,
        notes,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'player_state_logs';
  @override
  VerificationContext validateIntegrity(Insertable<PlayerStateLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('match_id')) {
      context.handle(_matchIdMeta,
          matchId.isAcceptableOrUnknown(data['match_id']!, _matchIdMeta));
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('ready_to_compete')) {
      context.handle(
          _readyToCompeteMeta,
          readyToCompete.isAcceptableOrUnknown(
              data['ready_to_compete']!, _readyToCompeteMeta));
    }
    if (data.containsKey('warmed_up')) {
      context.handle(_warmedUpMeta,
          warmedUp.isAcceptableOrUnknown(data['warmed_up']!, _warmedUpMeta));
    }
    if (data.containsKey('hand_feel')) {
      context.handle(_handFeelMeta,
          handFeel.isAcceptableOrUnknown(data['hand_feel']!, _handFeelMeta));
    }
    if (data.containsKey('fatigue_level')) {
      context.handle(
          _fatigueLevelMeta,
          fatigueLevel.isAcceptableOrUnknown(
              data['fatigue_level']!, _fatigueLevelMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlayerStateLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlayerStateLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}session_id'])!,
      matchId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}match_id']),
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      readyToCompete: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ready_to_compete']),
      warmedUp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}warmed_up']),
      handFeel: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}hand_feel']),
      fatigueLevel: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}fatigue_level']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PlayerStateLogsTable createAlias(String alias) {
    return $PlayerStateLogsTable(attachedDatabase, alias);
  }
}

class PlayerStateLog extends DataClass implements Insertable<PlayerStateLog> {
  final int id;
  final int sessionId;
  final int? matchId;
  final String kind;
  final int? readyToCompete;
  final int? warmedUp;
  final int? handFeel;
  final int? fatigueLevel;
  final String? notes;
  final DateTime createdAt;
  const PlayerStateLog(
      {required this.id,
      required this.sessionId,
      this.matchId,
      required this.kind,
      this.readyToCompete,
      this.warmedUp,
      this.handFeel,
      this.fatigueLevel,
      this.notes,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    if (!nullToAbsent || matchId != null) {
      map['match_id'] = Variable<int>(matchId);
    }
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || readyToCompete != null) {
      map['ready_to_compete'] = Variable<int>(readyToCompete);
    }
    if (!nullToAbsent || warmedUp != null) {
      map['warmed_up'] = Variable<int>(warmedUp);
    }
    if (!nullToAbsent || handFeel != null) {
      map['hand_feel'] = Variable<int>(handFeel);
    }
    if (!nullToAbsent || fatigueLevel != null) {
      map['fatigue_level'] = Variable<int>(fatigueLevel);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PlayerStateLogsCompanion toCompanion(bool nullToAbsent) {
    return PlayerStateLogsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      matchId: matchId == null && nullToAbsent
          ? const Value.absent()
          : Value(matchId),
      kind: Value(kind),
      readyToCompete: readyToCompete == null && nullToAbsent
          ? const Value.absent()
          : Value(readyToCompete),
      warmedUp: warmedUp == null && nullToAbsent
          ? const Value.absent()
          : Value(warmedUp),
      handFeel: handFeel == null && nullToAbsent
          ? const Value.absent()
          : Value(handFeel),
      fatigueLevel: fatigueLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(fatigueLevel),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory PlayerStateLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlayerStateLog(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      matchId: serializer.fromJson<int?>(json['matchId']),
      kind: serializer.fromJson<String>(json['kind']),
      readyToCompete: serializer.fromJson<int?>(json['readyToCompete']),
      warmedUp: serializer.fromJson<int?>(json['warmedUp']),
      handFeel: serializer.fromJson<int?>(json['handFeel']),
      fatigueLevel: serializer.fromJson<int?>(json['fatigueLevel']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'matchId': serializer.toJson<int?>(matchId),
      'kind': serializer.toJson<String>(kind),
      'readyToCompete': serializer.toJson<int?>(readyToCompete),
      'warmedUp': serializer.toJson<int?>(warmedUp),
      'handFeel': serializer.toJson<int?>(handFeel),
      'fatigueLevel': serializer.toJson<int?>(fatigueLevel),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PlayerStateLog copyWith(
          {int? id,
          int? sessionId,
          Value<int?> matchId = const Value.absent(),
          String? kind,
          Value<int?> readyToCompete = const Value.absent(),
          Value<int?> warmedUp = const Value.absent(),
          Value<int?> handFeel = const Value.absent(),
          Value<int?> fatigueLevel = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt}) =>
      PlayerStateLog(
        id: id ?? this.id,
        sessionId: sessionId ?? this.sessionId,
        matchId: matchId.present ? matchId.value : this.matchId,
        kind: kind ?? this.kind,
        readyToCompete:
            readyToCompete.present ? readyToCompete.value : this.readyToCompete,
        warmedUp: warmedUp.present ? warmedUp.value : this.warmedUp,
        handFeel: handFeel.present ? handFeel.value : this.handFeel,
        fatigueLevel:
            fatigueLevel.present ? fatigueLevel.value : this.fatigueLevel,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
      );
  PlayerStateLog copyWithCompanion(PlayerStateLogsCompanion data) {
    return PlayerStateLog(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      matchId: data.matchId.present ? data.matchId.value : this.matchId,
      kind: data.kind.present ? data.kind.value : this.kind,
      readyToCompete: data.readyToCompete.present
          ? data.readyToCompete.value
          : this.readyToCompete,
      warmedUp: data.warmedUp.present ? data.warmedUp.value : this.warmedUp,
      handFeel: data.handFeel.present ? data.handFeel.value : this.handFeel,
      fatigueLevel: data.fatigueLevel.present
          ? data.fatigueLevel.value
          : this.fatigueLevel,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlayerStateLog(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('matchId: $matchId, ')
          ..write('kind: $kind, ')
          ..write('readyToCompete: $readyToCompete, ')
          ..write('warmedUp: $warmedUp, ')
          ..write('handFeel: $handFeel, ')
          ..write('fatigueLevel: $fatigueLevel, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sessionId, matchId, kind, readyToCompete,
      warmedUp, handFeel, fatigueLevel, notes, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlayerStateLog &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.matchId == this.matchId &&
          other.kind == this.kind &&
          other.readyToCompete == this.readyToCompete &&
          other.warmedUp == this.warmedUp &&
          other.handFeel == this.handFeel &&
          other.fatigueLevel == this.fatigueLevel &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class PlayerStateLogsCompanion extends UpdateCompanion<PlayerStateLog> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<int?> matchId;
  final Value<String> kind;
  final Value<int?> readyToCompete;
  final Value<int?> warmedUp;
  final Value<int?> handFeel;
  final Value<int?> fatigueLevel;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  const PlayerStateLogsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.matchId = const Value.absent(),
    this.kind = const Value.absent(),
    this.readyToCompete = const Value.absent(),
    this.warmedUp = const Value.absent(),
    this.handFeel = const Value.absent(),
    this.fatigueLevel = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PlayerStateLogsCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    this.matchId = const Value.absent(),
    required String kind,
    this.readyToCompete = const Value.absent(),
    this.warmedUp = const Value.absent(),
    this.handFeel = const Value.absent(),
    this.fatigueLevel = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
  })  : sessionId = Value(sessionId),
        kind = Value(kind),
        createdAt = Value(createdAt);
  static Insertable<PlayerStateLog> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<int>? matchId,
    Expression<String>? kind,
    Expression<int>? readyToCompete,
    Expression<int>? warmedUp,
    Expression<int>? handFeel,
    Expression<int>? fatigueLevel,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (matchId != null) 'match_id': matchId,
      if (kind != null) 'kind': kind,
      if (readyToCompete != null) 'ready_to_compete': readyToCompete,
      if (warmedUp != null) 'warmed_up': warmedUp,
      if (handFeel != null) 'hand_feel': handFeel,
      if (fatigueLevel != null) 'fatigue_level': fatigueLevel,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PlayerStateLogsCompanion copyWith(
      {Value<int>? id,
      Value<int>? sessionId,
      Value<int?>? matchId,
      Value<String>? kind,
      Value<int?>? readyToCompete,
      Value<int?>? warmedUp,
      Value<int?>? handFeel,
      Value<int?>? fatigueLevel,
      Value<String?>? notes,
      Value<DateTime>? createdAt}) {
    return PlayerStateLogsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      matchId: matchId ?? this.matchId,
      kind: kind ?? this.kind,
      readyToCompete: readyToCompete ?? this.readyToCompete,
      warmedUp: warmedUp ?? this.warmedUp,
      handFeel: handFeel ?? this.handFeel,
      fatigueLevel: fatigueLevel ?? this.fatigueLevel,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (matchId.present) {
      map['match_id'] = Variable<int>(matchId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (readyToCompete.present) {
      map['ready_to_compete'] = Variable<int>(readyToCompete.value);
    }
    if (warmedUp.present) {
      map['warmed_up'] = Variable<int>(warmedUp.value);
    }
    if (handFeel.present) {
      map['hand_feel'] = Variable<int>(handFeel.value);
    }
    if (fatigueLevel.present) {
      map['fatigue_level'] = Variable<int>(fatigueLevel.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayerStateLogsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('matchId: $matchId, ')
          ..write('kind: $kind, ')
          ..write('readyToCompete: $readyToCompete, ')
          ..write('warmedUp: $warmedUp, ')
          ..write('handFeel: $handFeel, ')
          ..write('fatigueLevel: $fatigueLevel, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PlayersTable players = $PlayersTable(this);
  late final $CuesTable cues = $CuesTable(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $MatchesTable matches = $MatchesTable(this);
  late final $RacksTable racks = $RacksTable(this);
  late final $ShotsTable shots = $ShotsTable(this);
  late final $EventsTable events = $EventsTable(this);
  late final $ConversationsTable conversations = $ConversationsTable(this);
  late final $MessagesTable messages = $MessagesTable(this);
  late final $SkillsTable skills = $SkillsTable(this);
  late final $SkillHistoryTableTable skillHistoryTable =
      $SkillHistoryTableTable(this);
  late final $DailyGoalsTable dailyGoals = $DailyGoalsTable(this);
  late final $DrillSessionsTable drillSessions = $DrillSessionsTable(this);
  late final $TrainingProgramProgressTable trainingProgramProgress =
      $TrainingProgramProgressTable(this);
  late final $PracticeShotsTable practiceShots = $PracticeShotsTable(this);
  late final $PracticeSessionsTable practiceSessions =
      $PracticeSessionsTable(this);
  late final $PlayerStateLogsTable playerStateLogs =
      $PlayerStateLogsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        players,
        cues,
        sessions,
        matches,
        racks,
        shots,
        events,
        conversations,
        messages,
        skills,
        skillHistoryTable,
        dailyGoals,
        drillSessions,
        trainingProgramProgress,
        practiceShots,
        practiceSessions,
        playerStateLogs
      ];
}

typedef $$PlayersTableCreateCompanionBuilder = PlayersCompanion Function({
  Value<int> id,
  required String name,
  Value<String> dominantHand,
  Value<String> language,
  Value<String> measurementSystem,
  Value<String> theme,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$PlayersTableUpdateCompanionBuilder = PlayersCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> dominantHand,
  Value<String> language,
  Value<String> measurementSystem,
  Value<String> theme,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$PlayersTableFilterComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dominantHand => $composableBuilder(
      column: $table.dominantHand, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get measurementSystem => $composableBuilder(
      column: $table.measurementSystem,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get theme => $composableBuilder(
      column: $table.theme, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$PlayersTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dominantHand => $composableBuilder(
      column: $table.dominantHand,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get measurementSystem => $composableBuilder(
      column: $table.measurementSystem,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get theme => $composableBuilder(
      column: $table.theme, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$PlayersTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get dominantHand => $composableBuilder(
      column: $table.dominantHand, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get measurementSystem => $composableBuilder(
      column: $table.measurementSystem, builder: (column) => column);

  GeneratedColumn<String> get theme =>
      $composableBuilder(column: $table.theme, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PlayersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlayersTable,
    Player,
    $$PlayersTableFilterComposer,
    $$PlayersTableOrderingComposer,
    $$PlayersTableAnnotationComposer,
    $$PlayersTableCreateCompanionBuilder,
    $$PlayersTableUpdateCompanionBuilder,
    (Player, BaseReferences<_$AppDatabase, $PlayersTable, Player>),
    Player,
    PrefetchHooks Function()> {
  $$PlayersTableTableManager(_$AppDatabase db, $PlayersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> dominantHand = const Value.absent(),
            Value<String> language = const Value.absent(),
            Value<String> measurementSystem = const Value.absent(),
            Value<String> theme = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              PlayersCompanion(
            id: id,
            name: name,
            dominantHand: dominantHand,
            language: language,
            measurementSystem: measurementSystem,
            theme: theme,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String> dominantHand = const Value.absent(),
            Value<String> language = const Value.absent(),
            Value<String> measurementSystem = const Value.absent(),
            Value<String> theme = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              PlayersCompanion.insert(
            id: id,
            name: name,
            dominantHand: dominantHand,
            language: language,
            measurementSystem: measurementSystem,
            theme: theme,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PlayersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PlayersTable,
    Player,
    $$PlayersTableFilterComposer,
    $$PlayersTableOrderingComposer,
    $$PlayersTableAnnotationComposer,
    $$PlayersTableCreateCompanionBuilder,
    $$PlayersTableUpdateCompanionBuilder,
    (Player, BaseReferences<_$AppDatabase, $PlayersTable, Player>),
    Player,
    PrefetchHooks Function()>;
typedef $$CuesTableCreateCompanionBuilder = CuesCompanion Function({
  Value<int> id,
  Value<int?> playerId,
  required String name,
  required String shaft,
  required String tip,
  required String shaftMaterial,
  required double shaftDiameter,
  required String tipBrand,
  required String tipHardness,
  Value<double?> tipSize,
  Value<String> cueType,
  required double weight,
  required String balance,
  required String joint,
  Value<bool> isActive,
  Value<bool> isBreakCue,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$CuesTableUpdateCompanionBuilder = CuesCompanion Function({
  Value<int> id,
  Value<int?> playerId,
  Value<String> name,
  Value<String> shaft,
  Value<String> tip,
  Value<String> shaftMaterial,
  Value<double> shaftDiameter,
  Value<String> tipBrand,
  Value<String> tipHardness,
  Value<double?> tipSize,
  Value<String> cueType,
  Value<double> weight,
  Value<String> balance,
  Value<String> joint,
  Value<bool> isActive,
  Value<bool> isBreakCue,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$CuesTableFilterComposer extends Composer<_$AppDatabase, $CuesTable> {
  $$CuesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get playerId => $composableBuilder(
      column: $table.playerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get shaft => $composableBuilder(
      column: $table.shaft, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tip => $composableBuilder(
      column: $table.tip, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get shaftMaterial => $composableBuilder(
      column: $table.shaftMaterial, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get shaftDiameter => $composableBuilder(
      column: $table.shaftDiameter, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tipBrand => $composableBuilder(
      column: $table.tipBrand, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tipHardness => $composableBuilder(
      column: $table.tipHardness, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get tipSize => $composableBuilder(
      column: $table.tipSize, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cueType => $composableBuilder(
      column: $table.cueType, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get balance => $composableBuilder(
      column: $table.balance, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get joint => $composableBuilder(
      column: $table.joint, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isBreakCue => $composableBuilder(
      column: $table.isBreakCue, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$CuesTableOrderingComposer extends Composer<_$AppDatabase, $CuesTable> {
  $$CuesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get playerId => $composableBuilder(
      column: $table.playerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get shaft => $composableBuilder(
      column: $table.shaft, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tip => $composableBuilder(
      column: $table.tip, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get shaftMaterial => $composableBuilder(
      column: $table.shaftMaterial,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get shaftDiameter => $composableBuilder(
      column: $table.shaftDiameter,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tipBrand => $composableBuilder(
      column: $table.tipBrand, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tipHardness => $composableBuilder(
      column: $table.tipHardness, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get tipSize => $composableBuilder(
      column: $table.tipSize, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cueType => $composableBuilder(
      column: $table.cueType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get balance => $composableBuilder(
      column: $table.balance, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get joint => $composableBuilder(
      column: $table.joint, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isBreakCue => $composableBuilder(
      column: $table.isBreakCue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$CuesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CuesTable> {
  $$CuesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get playerId =>
      $composableBuilder(column: $table.playerId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get shaft =>
      $composableBuilder(column: $table.shaft, builder: (column) => column);

  GeneratedColumn<String> get tip =>
      $composableBuilder(column: $table.tip, builder: (column) => column);

  GeneratedColumn<String> get shaftMaterial => $composableBuilder(
      column: $table.shaftMaterial, builder: (column) => column);

  GeneratedColumn<double> get shaftDiameter => $composableBuilder(
      column: $table.shaftDiameter, builder: (column) => column);

  GeneratedColumn<String> get tipBrand =>
      $composableBuilder(column: $table.tipBrand, builder: (column) => column);

  GeneratedColumn<String> get tipHardness => $composableBuilder(
      column: $table.tipHardness, builder: (column) => column);

  GeneratedColumn<double> get tipSize =>
      $composableBuilder(column: $table.tipSize, builder: (column) => column);

  GeneratedColumn<String> get cueType =>
      $composableBuilder(column: $table.cueType, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<String> get balance =>
      $composableBuilder(column: $table.balance, builder: (column) => column);

  GeneratedColumn<String> get joint =>
      $composableBuilder(column: $table.joint, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<bool> get isBreakCue => $composableBuilder(
      column: $table.isBreakCue, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CuesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CuesTable,
    Cue,
    $$CuesTableFilterComposer,
    $$CuesTableOrderingComposer,
    $$CuesTableAnnotationComposer,
    $$CuesTableCreateCompanionBuilder,
    $$CuesTableUpdateCompanionBuilder,
    (Cue, BaseReferences<_$AppDatabase, $CuesTable, Cue>),
    Cue,
    PrefetchHooks Function()> {
  $$CuesTableTableManager(_$AppDatabase db, $CuesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CuesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CuesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> playerId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> shaft = const Value.absent(),
            Value<String> tip = const Value.absent(),
            Value<String> shaftMaterial = const Value.absent(),
            Value<double> shaftDiameter = const Value.absent(),
            Value<String> tipBrand = const Value.absent(),
            Value<String> tipHardness = const Value.absent(),
            Value<double?> tipSize = const Value.absent(),
            Value<String> cueType = const Value.absent(),
            Value<double> weight = const Value.absent(),
            Value<String> balance = const Value.absent(),
            Value<String> joint = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<bool> isBreakCue = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              CuesCompanion(
            id: id,
            playerId: playerId,
            name: name,
            shaft: shaft,
            tip: tip,
            shaftMaterial: shaftMaterial,
            shaftDiameter: shaftDiameter,
            tipBrand: tipBrand,
            tipHardness: tipHardness,
            tipSize: tipSize,
            cueType: cueType,
            weight: weight,
            balance: balance,
            joint: joint,
            isActive: isActive,
            isBreakCue: isBreakCue,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> playerId = const Value.absent(),
            required String name,
            required String shaft,
            required String tip,
            required String shaftMaterial,
            required double shaftDiameter,
            required String tipBrand,
            required String tipHardness,
            Value<double?> tipSize = const Value.absent(),
            Value<String> cueType = const Value.absent(),
            required double weight,
            required String balance,
            required String joint,
            Value<bool> isActive = const Value.absent(),
            Value<bool> isBreakCue = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              CuesCompanion.insert(
            id: id,
            playerId: playerId,
            name: name,
            shaft: shaft,
            tip: tip,
            shaftMaterial: shaftMaterial,
            shaftDiameter: shaftDiameter,
            tipBrand: tipBrand,
            tipHardness: tipHardness,
            tipSize: tipSize,
            cueType: cueType,
            weight: weight,
            balance: balance,
            joint: joint,
            isActive: isActive,
            isBreakCue: isBreakCue,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CuesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CuesTable,
    Cue,
    $$CuesTableFilterComposer,
    $$CuesTableOrderingComposer,
    $$CuesTableAnnotationComposer,
    $$CuesTableCreateCompanionBuilder,
    $$CuesTableUpdateCompanionBuilder,
    (Cue, BaseReferences<_$AppDatabase, $CuesTable, Cue>),
    Cue,
    PrefetchHooks Function()>;
typedef $$SessionsTableCreateCompanionBuilder = SessionsCompanion Function({
  Value<int> id,
  Value<int?> playerId,
  required String sessionType,
  Value<String?> location,
  Value<String?> table,
  Value<String?> cloth,
  Value<String?> balls,
  Value<String?> trainingGoal,
  Value<String?> notes,
  Value<String?> weather,
  required DateTime startedAt,
  Value<DateTime?> finishedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$SessionsTableUpdateCompanionBuilder = SessionsCompanion Function({
  Value<int> id,
  Value<int?> playerId,
  Value<String> sessionType,
  Value<String?> location,
  Value<String?> table,
  Value<String?> cloth,
  Value<String?> balls,
  Value<String?> trainingGoal,
  Value<String?> notes,
  Value<String?> weather,
  Value<DateTime> startedAt,
  Value<DateTime?> finishedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$SessionsTableReferences
    extends BaseReferences<_$AppDatabase, $SessionsTable, Session> {
  $$SessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MatchesTable, List<Matche>> _matchesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.matches,
          aliasName:
              $_aliasNameGenerator(db.sessions.id, db.matches.sessionId));

  $$MatchesTableProcessedTableManager get matchesRefs {
    final manager = $$MatchesTableTableManager($_db, $_db.matches)
        .filter((f) => f.sessionId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_matchesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get playerId => $composableBuilder(
      column: $table.playerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sessionType => $composableBuilder(
      column: $table.sessionType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get table => $composableBuilder(
      column: $table.table, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cloth => $composableBuilder(
      column: $table.cloth, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get balls => $composableBuilder(
      column: $table.balls, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get trainingGoal => $composableBuilder(
      column: $table.trainingGoal, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get weather => $composableBuilder(
      column: $table.weather, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get finishedAt => $composableBuilder(
      column: $table.finishedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> matchesRefs(
      Expression<bool> Function($$MatchesTableFilterComposer f) f) {
    final $$MatchesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.matches,
        getReferencedColumn: (t) => t.sessionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MatchesTableFilterComposer(
              $db: $db,
              $table: $db.matches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get playerId => $composableBuilder(
      column: $table.playerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sessionType => $composableBuilder(
      column: $table.sessionType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get table => $composableBuilder(
      column: $table.table, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cloth => $composableBuilder(
      column: $table.cloth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get balls => $composableBuilder(
      column: $table.balls, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get trainingGoal => $composableBuilder(
      column: $table.trainingGoal,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get weather => $composableBuilder(
      column: $table.weather, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get finishedAt => $composableBuilder(
      column: $table.finishedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get playerId =>
      $composableBuilder(column: $table.playerId, builder: (column) => column);

  GeneratedColumn<String> get sessionType => $composableBuilder(
      column: $table.sessionType, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get table =>
      $composableBuilder(column: $table.table, builder: (column) => column);

  GeneratedColumn<String> get cloth =>
      $composableBuilder(column: $table.cloth, builder: (column) => column);

  GeneratedColumn<String> get balls =>
      $composableBuilder(column: $table.balls, builder: (column) => column);

  GeneratedColumn<String> get trainingGoal => $composableBuilder(
      column: $table.trainingGoal, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get weather =>
      $composableBuilder(column: $table.weather, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get finishedAt => $composableBuilder(
      column: $table.finishedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> matchesRefs<T extends Object>(
      Expression<T> Function($$MatchesTableAnnotationComposer a) f) {
    final $$MatchesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.matches,
        getReferencedColumn: (t) => t.sessionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MatchesTableAnnotationComposer(
              $db: $db,
              $table: $db.matches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SessionsTable,
    Session,
    $$SessionsTableFilterComposer,
    $$SessionsTableOrderingComposer,
    $$SessionsTableAnnotationComposer,
    $$SessionsTableCreateCompanionBuilder,
    $$SessionsTableUpdateCompanionBuilder,
    (Session, $$SessionsTableReferences),
    Session,
    PrefetchHooks Function({bool matchesRefs})> {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> playerId = const Value.absent(),
            Value<String> sessionType = const Value.absent(),
            Value<String?> location = const Value.absent(),
            Value<String?> table = const Value.absent(),
            Value<String?> cloth = const Value.absent(),
            Value<String?> balls = const Value.absent(),
            Value<String?> trainingGoal = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> weather = const Value.absent(),
            Value<DateTime> startedAt = const Value.absent(),
            Value<DateTime?> finishedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              SessionsCompanion(
            id: id,
            playerId: playerId,
            sessionType: sessionType,
            location: location,
            table: table,
            cloth: cloth,
            balls: balls,
            trainingGoal: trainingGoal,
            notes: notes,
            weather: weather,
            startedAt: startedAt,
            finishedAt: finishedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> playerId = const Value.absent(),
            required String sessionType,
            Value<String?> location = const Value.absent(),
            Value<String?> table = const Value.absent(),
            Value<String?> cloth = const Value.absent(),
            Value<String?> balls = const Value.absent(),
            Value<String?> trainingGoal = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> weather = const Value.absent(),
            required DateTime startedAt,
            Value<DateTime?> finishedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              SessionsCompanion.insert(
            id: id,
            playerId: playerId,
            sessionType: sessionType,
            location: location,
            table: table,
            cloth: cloth,
            balls: balls,
            trainingGoal: trainingGoal,
            notes: notes,
            weather: weather,
            startedAt: startedAt,
            finishedAt: finishedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$SessionsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({matchesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (matchesRefs) db.matches],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (matchesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$SessionsTableReferences._matchesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SessionsTableReferences(db, table, p0)
                                .matchesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.sessionId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SessionsTable,
    Session,
    $$SessionsTableFilterComposer,
    $$SessionsTableOrderingComposer,
    $$SessionsTableAnnotationComposer,
    $$SessionsTableCreateCompanionBuilder,
    $$SessionsTableUpdateCompanionBuilder,
    (Session, $$SessionsTableReferences),
    Session,
    PrefetchHooks Function({bool matchesRefs})>;
typedef $$MatchesTableCreateCompanionBuilder = MatchesCompanion Function({
  Value<int> id,
  required int sessionId,
  required int matchNumber,
  required String gameType,
  Value<int?> raceTo,
  Value<String?> opponent,
  Value<String?> partner,
  Value<String?> teamMode,
  Value<String?> winner,
  Value<String?> result,
  Value<DateTime?> startTime,
  Value<DateTime?> endTime,
  Value<String?> matchObjective,
  Value<String?> notes,
  Value<DateTime> createdAt,
});
typedef $$MatchesTableUpdateCompanionBuilder = MatchesCompanion Function({
  Value<int> id,
  Value<int> sessionId,
  Value<int> matchNumber,
  Value<String> gameType,
  Value<int?> raceTo,
  Value<String?> opponent,
  Value<String?> partner,
  Value<String?> teamMode,
  Value<String?> winner,
  Value<String?> result,
  Value<DateTime?> startTime,
  Value<DateTime?> endTime,
  Value<String?> matchObjective,
  Value<String?> notes,
  Value<DateTime> createdAt,
});

final class $$MatchesTableReferences
    extends BaseReferences<_$AppDatabase, $MatchesTable, Matche> {
  $$MatchesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionsTable _sessionIdTable(_$AppDatabase db) => db.sessions
      .createAlias($_aliasNameGenerator(db.matches.sessionId, db.sessions.id));

  $$SessionsTableProcessedTableManager get sessionId {
    final manager = $$SessionsTableTableManager($_db, $_db.sessions)
        .filter((f) => f.id($_item.sessionId));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$RacksTable, List<Rack>> _racksRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.racks,
          aliasName: $_aliasNameGenerator(db.matches.id, db.racks.matchId));

  $$RacksTableProcessedTableManager get racksRefs {
    final manager = $$RacksTableTableManager($_db, $_db.racks)
        .filter((f) => f.matchId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_racksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$MatchesTableFilterComposer
    extends Composer<_$AppDatabase, $MatchesTable> {
  $$MatchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get matchNumber => $composableBuilder(
      column: $table.matchNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gameType => $composableBuilder(
      column: $table.gameType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get raceTo => $composableBuilder(
      column: $table.raceTo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get opponent => $composableBuilder(
      column: $table.opponent, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get partner => $composableBuilder(
      column: $table.partner, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get teamMode => $composableBuilder(
      column: $table.teamMode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get winner => $composableBuilder(
      column: $table.winner, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get result => $composableBuilder(
      column: $table.result, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get matchObjective => $composableBuilder(
      column: $table.matchObjective,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.sessions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SessionsTableFilterComposer(
              $db: $db,
              $table: $db.sessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> racksRefs(
      Expression<bool> Function($$RacksTableFilterComposer f) f) {
    final $$RacksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.racks,
        getReferencedColumn: (t) => t.matchId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RacksTableFilterComposer(
              $db: $db,
              $table: $db.racks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$MatchesTableOrderingComposer
    extends Composer<_$AppDatabase, $MatchesTable> {
  $$MatchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get matchNumber => $composableBuilder(
      column: $table.matchNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gameType => $composableBuilder(
      column: $table.gameType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get raceTo => $composableBuilder(
      column: $table.raceTo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get opponent => $composableBuilder(
      column: $table.opponent, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get partner => $composableBuilder(
      column: $table.partner, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get teamMode => $composableBuilder(
      column: $table.teamMode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get winner => $composableBuilder(
      column: $table.winner, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get result => $composableBuilder(
      column: $table.result, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get matchObjective => $composableBuilder(
      column: $table.matchObjective,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.sessions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SessionsTableOrderingComposer(
              $db: $db,
              $table: $db.sessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MatchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MatchesTable> {
  $$MatchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get matchNumber => $composableBuilder(
      column: $table.matchNumber, builder: (column) => column);

  GeneratedColumn<String> get gameType =>
      $composableBuilder(column: $table.gameType, builder: (column) => column);

  GeneratedColumn<int> get raceTo =>
      $composableBuilder(column: $table.raceTo, builder: (column) => column);

  GeneratedColumn<String> get opponent =>
      $composableBuilder(column: $table.opponent, builder: (column) => column);

  GeneratedColumn<String> get partner =>
      $composableBuilder(column: $table.partner, builder: (column) => column);

  GeneratedColumn<String> get teamMode =>
      $composableBuilder(column: $table.teamMode, builder: (column) => column);

  GeneratedColumn<String> get winner =>
      $composableBuilder(column: $table.winner, builder: (column) => column);

  GeneratedColumn<String> get result =>
      $composableBuilder(column: $table.result, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<String> get matchObjective => $composableBuilder(
      column: $table.matchObjective, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.sessions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SessionsTableAnnotationComposer(
              $db: $db,
              $table: $db.sessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> racksRefs<T extends Object>(
      Expression<T> Function($$RacksTableAnnotationComposer a) f) {
    final $$RacksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.racks,
        getReferencedColumn: (t) => t.matchId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RacksTableAnnotationComposer(
              $db: $db,
              $table: $db.racks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$MatchesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MatchesTable,
    Matche,
    $$MatchesTableFilterComposer,
    $$MatchesTableOrderingComposer,
    $$MatchesTableAnnotationComposer,
    $$MatchesTableCreateCompanionBuilder,
    $$MatchesTableUpdateCompanionBuilder,
    (Matche, $$MatchesTableReferences),
    Matche,
    PrefetchHooks Function({bool sessionId, bool racksRefs})> {
  $$MatchesTableTableManager(_$AppDatabase db, $MatchesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MatchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MatchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MatchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> sessionId = const Value.absent(),
            Value<int> matchNumber = const Value.absent(),
            Value<String> gameType = const Value.absent(),
            Value<int?> raceTo = const Value.absent(),
            Value<String?> opponent = const Value.absent(),
            Value<String?> partner = const Value.absent(),
            Value<String?> teamMode = const Value.absent(),
            Value<String?> winner = const Value.absent(),
            Value<String?> result = const Value.absent(),
            Value<DateTime?> startTime = const Value.absent(),
            Value<DateTime?> endTime = const Value.absent(),
            Value<String?> matchObjective = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              MatchesCompanion(
            id: id,
            sessionId: sessionId,
            matchNumber: matchNumber,
            gameType: gameType,
            raceTo: raceTo,
            opponent: opponent,
            partner: partner,
            teamMode: teamMode,
            winner: winner,
            result: result,
            startTime: startTime,
            endTime: endTime,
            matchObjective: matchObjective,
            notes: notes,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int sessionId,
            required int matchNumber,
            required String gameType,
            Value<int?> raceTo = const Value.absent(),
            Value<String?> opponent = const Value.absent(),
            Value<String?> partner = const Value.absent(),
            Value<String?> teamMode = const Value.absent(),
            Value<String?> winner = const Value.absent(),
            Value<String?> result = const Value.absent(),
            Value<DateTime?> startTime = const Value.absent(),
            Value<DateTime?> endTime = const Value.absent(),
            Value<String?> matchObjective = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              MatchesCompanion.insert(
            id: id,
            sessionId: sessionId,
            matchNumber: matchNumber,
            gameType: gameType,
            raceTo: raceTo,
            opponent: opponent,
            partner: partner,
            teamMode: teamMode,
            winner: winner,
            result: result,
            startTime: startTime,
            endTime: endTime,
            matchObjective: matchObjective,
            notes: notes,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$MatchesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({sessionId = false, racksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (racksRefs) db.racks],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (sessionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.sessionId,
                    referencedTable:
                        $$MatchesTableReferences._sessionIdTable(db),
                    referencedColumn:
                        $$MatchesTableReferences._sessionIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (racksRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$MatchesTableReferences._racksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$MatchesTableReferences(db, table, p0).racksRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.matchId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$MatchesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MatchesTable,
    Matche,
    $$MatchesTableFilterComposer,
    $$MatchesTableOrderingComposer,
    $$MatchesTableAnnotationComposer,
    $$MatchesTableCreateCompanionBuilder,
    $$MatchesTableUpdateCompanionBuilder,
    (Matche, $$MatchesTableReferences),
    Matche,
    PrefetchHooks Function({bool sessionId, bool racksRefs})>;
typedef $$RacksTableCreateCompanionBuilder = RacksCompanion Function({
  Value<int> id,
  required int matchId,
  required int rackNumber,
  required bool result,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<String?> biggestMistake,
  Value<String?> biggestStrength,
  Value<int?> confidence,
  Value<int> ballsPotted,
  Value<int> largestRun,
  Value<bool> breakSuccess,
  Value<bool> breakScratch,
  Value<bool> breakFoul,
  Value<int> easyMissCount,
  Value<int> hardMissCount,
  Value<int> scratchErrorCount,
  Value<int> positionErrorCount,
  Value<int> safetyErrorCount,
  Value<int> kickErrorCount,
  Value<int> jumpErrorCount,
  Value<String> bestStrengths,
  Value<String> biggestMistakes,
});
typedef $$RacksTableUpdateCompanionBuilder = RacksCompanion Function({
  Value<int> id,
  Value<int> matchId,
  Value<int> rackNumber,
  Value<bool> result,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<String?> biggestMistake,
  Value<String?> biggestStrength,
  Value<int?> confidence,
  Value<int> ballsPotted,
  Value<int> largestRun,
  Value<bool> breakSuccess,
  Value<bool> breakScratch,
  Value<bool> breakFoul,
  Value<int> easyMissCount,
  Value<int> hardMissCount,
  Value<int> scratchErrorCount,
  Value<int> positionErrorCount,
  Value<int> safetyErrorCount,
  Value<int> kickErrorCount,
  Value<int> jumpErrorCount,
  Value<String> bestStrengths,
  Value<String> biggestMistakes,
});

final class $$RacksTableReferences
    extends BaseReferences<_$AppDatabase, $RacksTable, Rack> {
  $$RacksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MatchesTable _matchIdTable(_$AppDatabase db) => db.matches
      .createAlias($_aliasNameGenerator(db.racks.matchId, db.matches.id));

  $$MatchesTableProcessedTableManager get matchId {
    final manager = $$MatchesTableTableManager($_db, $_db.matches)
        .filter((f) => f.id($_item.matchId));
    final item = $_typedResult.readTableOrNull(_matchIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$ShotsTable, List<Shot>> _shotsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.shots,
          aliasName: $_aliasNameGenerator(db.racks.id, db.shots.rackId));

  $$ShotsTableProcessedTableManager get shotsRefs {
    final manager = $$ShotsTableTableManager($_db, $_db.shots)
        .filter((f) => f.rackId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_shotsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$RacksTableFilterComposer extends Composer<_$AppDatabase, $RacksTable> {
  $$RacksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get rackNumber => $composableBuilder(
      column: $table.rackNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get result => $composableBuilder(
      column: $table.result, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get biggestMistake => $composableBuilder(
      column: $table.biggestMistake,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get biggestStrength => $composableBuilder(
      column: $table.biggestStrength,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ballsPotted => $composableBuilder(
      column: $table.ballsPotted, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get largestRun => $composableBuilder(
      column: $table.largestRun, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get breakSuccess => $composableBuilder(
      column: $table.breakSuccess, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get breakScratch => $composableBuilder(
      column: $table.breakScratch, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get breakFoul => $composableBuilder(
      column: $table.breakFoul, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get easyMissCount => $composableBuilder(
      column: $table.easyMissCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get hardMissCount => $composableBuilder(
      column: $table.hardMissCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get scratchErrorCount => $composableBuilder(
      column: $table.scratchErrorCount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get positionErrorCount => $composableBuilder(
      column: $table.positionErrorCount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get safetyErrorCount => $composableBuilder(
      column: $table.safetyErrorCount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get kickErrorCount => $composableBuilder(
      column: $table.kickErrorCount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get jumpErrorCount => $composableBuilder(
      column: $table.jumpErrorCount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bestStrengths => $composableBuilder(
      column: $table.bestStrengths, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get biggestMistakes => $composableBuilder(
      column: $table.biggestMistakes,
      builder: (column) => ColumnFilters(column));

  $$MatchesTableFilterComposer get matchId {
    final $$MatchesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.matchId,
        referencedTable: $db.matches,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MatchesTableFilterComposer(
              $db: $db,
              $table: $db.matches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> shotsRefs(
      Expression<bool> Function($$ShotsTableFilterComposer f) f) {
    final $$ShotsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.shots,
        getReferencedColumn: (t) => t.rackId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ShotsTableFilterComposer(
              $db: $db,
              $table: $db.shots,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$RacksTableOrderingComposer
    extends Composer<_$AppDatabase, $RacksTable> {
  $$RacksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get rackNumber => $composableBuilder(
      column: $table.rackNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get result => $composableBuilder(
      column: $table.result, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get biggestMistake => $composableBuilder(
      column: $table.biggestMistake,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get biggestStrength => $composableBuilder(
      column: $table.biggestStrength,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ballsPotted => $composableBuilder(
      column: $table.ballsPotted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get largestRun => $composableBuilder(
      column: $table.largestRun, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get breakSuccess => $composableBuilder(
      column: $table.breakSuccess,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get breakScratch => $composableBuilder(
      column: $table.breakScratch,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get breakFoul => $composableBuilder(
      column: $table.breakFoul, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get easyMissCount => $composableBuilder(
      column: $table.easyMissCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get hardMissCount => $composableBuilder(
      column: $table.hardMissCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get scratchErrorCount => $composableBuilder(
      column: $table.scratchErrorCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get positionErrorCount => $composableBuilder(
      column: $table.positionErrorCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get safetyErrorCount => $composableBuilder(
      column: $table.safetyErrorCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get kickErrorCount => $composableBuilder(
      column: $table.kickErrorCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get jumpErrorCount => $composableBuilder(
      column: $table.jumpErrorCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bestStrengths => $composableBuilder(
      column: $table.bestStrengths,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get biggestMistakes => $composableBuilder(
      column: $table.biggestMistakes,
      builder: (column) => ColumnOrderings(column));

  $$MatchesTableOrderingComposer get matchId {
    final $$MatchesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.matchId,
        referencedTable: $db.matches,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MatchesTableOrderingComposer(
              $db: $db,
              $table: $db.matches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RacksTableAnnotationComposer
    extends Composer<_$AppDatabase, $RacksTable> {
  $$RacksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get rackNumber => $composableBuilder(
      column: $table.rackNumber, builder: (column) => column);

  GeneratedColumn<bool> get result =>
      $composableBuilder(column: $table.result, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get biggestMistake => $composableBuilder(
      column: $table.biggestMistake, builder: (column) => column);

  GeneratedColumn<String> get biggestStrength => $composableBuilder(
      column: $table.biggestStrength, builder: (column) => column);

  GeneratedColumn<int> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => column);

  GeneratedColumn<int> get ballsPotted => $composableBuilder(
      column: $table.ballsPotted, builder: (column) => column);

  GeneratedColumn<int> get largestRun => $composableBuilder(
      column: $table.largestRun, builder: (column) => column);

  GeneratedColumn<bool> get breakSuccess => $composableBuilder(
      column: $table.breakSuccess, builder: (column) => column);

  GeneratedColumn<bool> get breakScratch => $composableBuilder(
      column: $table.breakScratch, builder: (column) => column);

  GeneratedColumn<bool> get breakFoul =>
      $composableBuilder(column: $table.breakFoul, builder: (column) => column);

  GeneratedColumn<int> get easyMissCount => $composableBuilder(
      column: $table.easyMissCount, builder: (column) => column);

  GeneratedColumn<int> get hardMissCount => $composableBuilder(
      column: $table.hardMissCount, builder: (column) => column);

  GeneratedColumn<int> get scratchErrorCount => $composableBuilder(
      column: $table.scratchErrorCount, builder: (column) => column);

  GeneratedColumn<int> get positionErrorCount => $composableBuilder(
      column: $table.positionErrorCount, builder: (column) => column);

  GeneratedColumn<int> get safetyErrorCount => $composableBuilder(
      column: $table.safetyErrorCount, builder: (column) => column);

  GeneratedColumn<int> get kickErrorCount => $composableBuilder(
      column: $table.kickErrorCount, builder: (column) => column);

  GeneratedColumn<int> get jumpErrorCount => $composableBuilder(
      column: $table.jumpErrorCount, builder: (column) => column);

  GeneratedColumn<String> get bestStrengths => $composableBuilder(
      column: $table.bestStrengths, builder: (column) => column);

  GeneratedColumn<String> get biggestMistakes => $composableBuilder(
      column: $table.biggestMistakes, builder: (column) => column);

  $$MatchesTableAnnotationComposer get matchId {
    final $$MatchesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.matchId,
        referencedTable: $db.matches,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MatchesTableAnnotationComposer(
              $db: $db,
              $table: $db.matches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> shotsRefs<T extends Object>(
      Expression<T> Function($$ShotsTableAnnotationComposer a) f) {
    final $$ShotsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.shots,
        getReferencedColumn: (t) => t.rackId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ShotsTableAnnotationComposer(
              $db: $db,
              $table: $db.shots,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$RacksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RacksTable,
    Rack,
    $$RacksTableFilterComposer,
    $$RacksTableOrderingComposer,
    $$RacksTableAnnotationComposer,
    $$RacksTableCreateCompanionBuilder,
    $$RacksTableUpdateCompanionBuilder,
    (Rack, $$RacksTableReferences),
    Rack,
    PrefetchHooks Function({bool matchId, bool shotsRefs})> {
  $$RacksTableTableManager(_$AppDatabase db, $RacksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RacksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RacksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RacksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> matchId = const Value.absent(),
            Value<int> rackNumber = const Value.absent(),
            Value<bool> result = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String?> biggestMistake = const Value.absent(),
            Value<String?> biggestStrength = const Value.absent(),
            Value<int?> confidence = const Value.absent(),
            Value<int> ballsPotted = const Value.absent(),
            Value<int> largestRun = const Value.absent(),
            Value<bool> breakSuccess = const Value.absent(),
            Value<bool> breakScratch = const Value.absent(),
            Value<bool> breakFoul = const Value.absent(),
            Value<int> easyMissCount = const Value.absent(),
            Value<int> hardMissCount = const Value.absent(),
            Value<int> scratchErrorCount = const Value.absent(),
            Value<int> positionErrorCount = const Value.absent(),
            Value<int> safetyErrorCount = const Value.absent(),
            Value<int> kickErrorCount = const Value.absent(),
            Value<int> jumpErrorCount = const Value.absent(),
            Value<String> bestStrengths = const Value.absent(),
            Value<String> biggestMistakes = const Value.absent(),
          }) =>
              RacksCompanion(
            id: id,
            matchId: matchId,
            rackNumber: rackNumber,
            result: result,
            notes: notes,
            createdAt: createdAt,
            biggestMistake: biggestMistake,
            biggestStrength: biggestStrength,
            confidence: confidence,
            ballsPotted: ballsPotted,
            largestRun: largestRun,
            breakSuccess: breakSuccess,
            breakScratch: breakScratch,
            breakFoul: breakFoul,
            easyMissCount: easyMissCount,
            hardMissCount: hardMissCount,
            scratchErrorCount: scratchErrorCount,
            positionErrorCount: positionErrorCount,
            safetyErrorCount: safetyErrorCount,
            kickErrorCount: kickErrorCount,
            jumpErrorCount: jumpErrorCount,
            bestStrengths: bestStrengths,
            biggestMistakes: biggestMistakes,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int matchId,
            required int rackNumber,
            required bool result,
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String?> biggestMistake = const Value.absent(),
            Value<String?> biggestStrength = const Value.absent(),
            Value<int?> confidence = const Value.absent(),
            Value<int> ballsPotted = const Value.absent(),
            Value<int> largestRun = const Value.absent(),
            Value<bool> breakSuccess = const Value.absent(),
            Value<bool> breakScratch = const Value.absent(),
            Value<bool> breakFoul = const Value.absent(),
            Value<int> easyMissCount = const Value.absent(),
            Value<int> hardMissCount = const Value.absent(),
            Value<int> scratchErrorCount = const Value.absent(),
            Value<int> positionErrorCount = const Value.absent(),
            Value<int> safetyErrorCount = const Value.absent(),
            Value<int> kickErrorCount = const Value.absent(),
            Value<int> jumpErrorCount = const Value.absent(),
            Value<String> bestStrengths = const Value.absent(),
            Value<String> biggestMistakes = const Value.absent(),
          }) =>
              RacksCompanion.insert(
            id: id,
            matchId: matchId,
            rackNumber: rackNumber,
            result: result,
            notes: notes,
            createdAt: createdAt,
            biggestMistake: biggestMistake,
            biggestStrength: biggestStrength,
            confidence: confidence,
            ballsPotted: ballsPotted,
            largestRun: largestRun,
            breakSuccess: breakSuccess,
            breakScratch: breakScratch,
            breakFoul: breakFoul,
            easyMissCount: easyMissCount,
            hardMissCount: hardMissCount,
            scratchErrorCount: scratchErrorCount,
            positionErrorCount: positionErrorCount,
            safetyErrorCount: safetyErrorCount,
            kickErrorCount: kickErrorCount,
            jumpErrorCount: jumpErrorCount,
            bestStrengths: bestStrengths,
            biggestMistakes: biggestMistakes,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$RacksTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({matchId = false, shotsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (shotsRefs) db.shots],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (matchId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.matchId,
                    referencedTable: $$RacksTableReferences._matchIdTable(db),
                    referencedColumn:
                        $$RacksTableReferences._matchIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (shotsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$RacksTableReferences._shotsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$RacksTableReferences(db, table, p0).shotsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.rackId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$RacksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RacksTable,
    Rack,
    $$RacksTableFilterComposer,
    $$RacksTableOrderingComposer,
    $$RacksTableAnnotationComposer,
    $$RacksTableCreateCompanionBuilder,
    $$RacksTableUpdateCompanionBuilder,
    (Rack, $$RacksTableReferences),
    Rack,
    PrefetchHooks Function({bool matchId, bool shotsRefs})>;
typedef $$ShotsTableCreateCompanionBuilder = ShotsCompanion Function({
  Value<int> id,
  required int rackId,
  required int shotNumber,
  required String shotType,
  required String difficulty,
  required String result,
  Value<String?> positionQuality,
  Value<String?> decision,
  Value<String?> confidence,
  Value<String?> playerNote,
  Value<DateTime> createdAt,
});
typedef $$ShotsTableUpdateCompanionBuilder = ShotsCompanion Function({
  Value<int> id,
  Value<int> rackId,
  Value<int> shotNumber,
  Value<String> shotType,
  Value<String> difficulty,
  Value<String> result,
  Value<String?> positionQuality,
  Value<String?> decision,
  Value<String?> confidence,
  Value<String?> playerNote,
  Value<DateTime> createdAt,
});

final class $$ShotsTableReferences
    extends BaseReferences<_$AppDatabase, $ShotsTable, Shot> {
  $$ShotsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RacksTable _rackIdTable(_$AppDatabase db) =>
      db.racks.createAlias($_aliasNameGenerator(db.shots.rackId, db.racks.id));

  $$RacksTableProcessedTableManager get rackId {
    final manager = $$RacksTableTableManager($_db, $_db.racks)
        .filter((f) => f.id($_item.rackId));
    final item = $_typedResult.readTableOrNull(_rackIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$EventsTable, List<Event>> _eventsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.events,
          aliasName: $_aliasNameGenerator(db.shots.id, db.events.shotId));

  $$EventsTableProcessedTableManager get eventsRefs {
    final manager = $$EventsTableTableManager($_db, $_db.events)
        .filter((f) => f.shotId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_eventsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ShotsTableFilterComposer extends Composer<_$AppDatabase, $ShotsTable> {
  $$ShotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get shotNumber => $composableBuilder(
      column: $table.shotNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get shotType => $composableBuilder(
      column: $table.shotType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get result => $composableBuilder(
      column: $table.result, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get positionQuality => $composableBuilder(
      column: $table.positionQuality,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get decision => $composableBuilder(
      column: $table.decision, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get playerNote => $composableBuilder(
      column: $table.playerNote, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$RacksTableFilterComposer get rackId {
    final $$RacksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.rackId,
        referencedTable: $db.racks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RacksTableFilterComposer(
              $db: $db,
              $table: $db.racks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> eventsRefs(
      Expression<bool> Function($$EventsTableFilterComposer f) f) {
    final $$EventsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.events,
        getReferencedColumn: (t) => t.shotId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EventsTableFilterComposer(
              $db: $db,
              $table: $db.events,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ShotsTableOrderingComposer
    extends Composer<_$AppDatabase, $ShotsTable> {
  $$ShotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get shotNumber => $composableBuilder(
      column: $table.shotNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get shotType => $composableBuilder(
      column: $table.shotType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get result => $composableBuilder(
      column: $table.result, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get positionQuality => $composableBuilder(
      column: $table.positionQuality,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get decision => $composableBuilder(
      column: $table.decision, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get playerNote => $composableBuilder(
      column: $table.playerNote, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$RacksTableOrderingComposer get rackId {
    final $$RacksTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.rackId,
        referencedTable: $db.racks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RacksTableOrderingComposer(
              $db: $db,
              $table: $db.racks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ShotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShotsTable> {
  $$ShotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get shotNumber => $composableBuilder(
      column: $table.shotNumber, builder: (column) => column);

  GeneratedColumn<String> get shotType =>
      $composableBuilder(column: $table.shotType, builder: (column) => column);

  GeneratedColumn<String> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => column);

  GeneratedColumn<String> get result =>
      $composableBuilder(column: $table.result, builder: (column) => column);

  GeneratedColumn<String> get positionQuality => $composableBuilder(
      column: $table.positionQuality, builder: (column) => column);

  GeneratedColumn<String> get decision =>
      $composableBuilder(column: $table.decision, builder: (column) => column);

  GeneratedColumn<String> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => column);

  GeneratedColumn<String> get playerNote => $composableBuilder(
      column: $table.playerNote, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$RacksTableAnnotationComposer get rackId {
    final $$RacksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.rackId,
        referencedTable: $db.racks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RacksTableAnnotationComposer(
              $db: $db,
              $table: $db.racks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> eventsRefs<T extends Object>(
      Expression<T> Function($$EventsTableAnnotationComposer a) f) {
    final $$EventsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.events,
        getReferencedColumn: (t) => t.shotId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EventsTableAnnotationComposer(
              $db: $db,
              $table: $db.events,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ShotsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ShotsTable,
    Shot,
    $$ShotsTableFilterComposer,
    $$ShotsTableOrderingComposer,
    $$ShotsTableAnnotationComposer,
    $$ShotsTableCreateCompanionBuilder,
    $$ShotsTableUpdateCompanionBuilder,
    (Shot, $$ShotsTableReferences),
    Shot,
    PrefetchHooks Function({bool rackId, bool eventsRefs})> {
  $$ShotsTableTableManager(_$AppDatabase db, $ShotsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> rackId = const Value.absent(),
            Value<int> shotNumber = const Value.absent(),
            Value<String> shotType = const Value.absent(),
            Value<String> difficulty = const Value.absent(),
            Value<String> result = const Value.absent(),
            Value<String?> positionQuality = const Value.absent(),
            Value<String?> decision = const Value.absent(),
            Value<String?> confidence = const Value.absent(),
            Value<String?> playerNote = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ShotsCompanion(
            id: id,
            rackId: rackId,
            shotNumber: shotNumber,
            shotType: shotType,
            difficulty: difficulty,
            result: result,
            positionQuality: positionQuality,
            decision: decision,
            confidence: confidence,
            playerNote: playerNote,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int rackId,
            required int shotNumber,
            required String shotType,
            required String difficulty,
            required String result,
            Value<String?> positionQuality = const Value.absent(),
            Value<String?> decision = const Value.absent(),
            Value<String?> confidence = const Value.absent(),
            Value<String?> playerNote = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ShotsCompanion.insert(
            id: id,
            rackId: rackId,
            shotNumber: shotNumber,
            shotType: shotType,
            difficulty: difficulty,
            result: result,
            positionQuality: positionQuality,
            decision: decision,
            confidence: confidence,
            playerNote: playerNote,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ShotsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({rackId = false, eventsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (eventsRefs) db.events],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (rackId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.rackId,
                    referencedTable: $$ShotsTableReferences._rackIdTable(db),
                    referencedColumn:
                        $$ShotsTableReferences._rackIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (eventsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$ShotsTableReferences._eventsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ShotsTableReferences(db, table, p0).eventsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.shotId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ShotsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ShotsTable,
    Shot,
    $$ShotsTableFilterComposer,
    $$ShotsTableOrderingComposer,
    $$ShotsTableAnnotationComposer,
    $$ShotsTableCreateCompanionBuilder,
    $$ShotsTableUpdateCompanionBuilder,
    (Shot, $$ShotsTableReferences),
    Shot,
    PrefetchHooks Function({bool rackId, bool eventsRefs})>;
typedef $$EventsTableCreateCompanionBuilder = EventsCompanion Function({
  Value<int> id,
  required int shotId,
  required String category,
  required String type,
  Value<String?> severity,
  Value<String?> confidence,
  Value<String?> metadataJson,
  Value<String?> notes,
  Value<DateTime> createdAt,
});
typedef $$EventsTableUpdateCompanionBuilder = EventsCompanion Function({
  Value<int> id,
  Value<int> shotId,
  Value<String> category,
  Value<String> type,
  Value<String?> severity,
  Value<String?> confidence,
  Value<String?> metadataJson,
  Value<String?> notes,
  Value<DateTime> createdAt,
});

final class $$EventsTableReferences
    extends BaseReferences<_$AppDatabase, $EventsTable, Event> {
  $$EventsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ShotsTable _shotIdTable(_$AppDatabase db) =>
      db.shots.createAlias($_aliasNameGenerator(db.events.shotId, db.shots.id));

  $$ShotsTableProcessedTableManager get shotId {
    final manager = $$ShotsTableTableManager($_db, $_db.shots)
        .filter((f) => f.id($_item.shotId));
    final item = $_typedResult.readTableOrNull(_shotIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$EventsTableFilterComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get severity => $composableBuilder(
      column: $table.severity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metadataJson => $composableBuilder(
      column: $table.metadataJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$ShotsTableFilterComposer get shotId {
    final $$ShotsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.shotId,
        referencedTable: $db.shots,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ShotsTableFilterComposer(
              $db: $db,
              $table: $db.shots,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$EventsTableOrderingComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get severity => $composableBuilder(
      column: $table.severity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metadataJson => $composableBuilder(
      column: $table.metadataJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$ShotsTableOrderingComposer get shotId {
    final $$ShotsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.shotId,
        referencedTable: $db.shots,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ShotsTableOrderingComposer(
              $db: $db,
              $table: $db.shots,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$EventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<String> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => column);

  GeneratedColumn<String> get metadataJson => $composableBuilder(
      column: $table.metadataJson, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ShotsTableAnnotationComposer get shotId {
    final $$ShotsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.shotId,
        referencedTable: $db.shots,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ShotsTableAnnotationComposer(
              $db: $db,
              $table: $db.shots,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$EventsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EventsTable,
    Event,
    $$EventsTableFilterComposer,
    $$EventsTableOrderingComposer,
    $$EventsTableAnnotationComposer,
    $$EventsTableCreateCompanionBuilder,
    $$EventsTableUpdateCompanionBuilder,
    (Event, $$EventsTableReferences),
    Event,
    PrefetchHooks Function({bool shotId})> {
  $$EventsTableTableManager(_$AppDatabase db, $EventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> shotId = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> severity = const Value.absent(),
            Value<String?> confidence = const Value.absent(),
            Value<String?> metadataJson = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              EventsCompanion(
            id: id,
            shotId: shotId,
            category: category,
            type: type,
            severity: severity,
            confidence: confidence,
            metadataJson: metadataJson,
            notes: notes,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int shotId,
            required String category,
            required String type,
            Value<String?> severity = const Value.absent(),
            Value<String?> confidence = const Value.absent(),
            Value<String?> metadataJson = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              EventsCompanion.insert(
            id: id,
            shotId: shotId,
            category: category,
            type: type,
            severity: severity,
            confidence: confidence,
            metadataJson: metadataJson,
            notes: notes,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$EventsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({shotId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (shotId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.shotId,
                    referencedTable: $$EventsTableReferences._shotIdTable(db),
                    referencedColumn:
                        $$EventsTableReferences._shotIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$EventsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $EventsTable,
    Event,
    $$EventsTableFilterComposer,
    $$EventsTableOrderingComposer,
    $$EventsTableAnnotationComposer,
    $$EventsTableCreateCompanionBuilder,
    $$EventsTableUpdateCompanionBuilder,
    (Event, $$EventsTableReferences),
    Event,
    PrefetchHooks Function({bool shotId})>;
typedef $$ConversationsTableCreateCompanionBuilder = ConversationsCompanion
    Function({
  Value<int> id,
  required String title,
  Value<String?> lastMessage,
  Value<DateTime?> lastMessageAt,
  Value<int> unreadCount,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$ConversationsTableUpdateCompanionBuilder = ConversationsCompanion
    Function({
  Value<int> id,
  Value<String> title,
  Value<String?> lastMessage,
  Value<DateTime?> lastMessageAt,
  Value<int> unreadCount,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$ConversationsTableReferences
    extends BaseReferences<_$AppDatabase, $ConversationsTable, Conversation> {
  $$ConversationsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MessagesTable, List<Message>> _messagesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.messages,
          aliasName: $_aliasNameGenerator(
              db.conversations.id, db.messages.conversationId));

  $$MessagesTableProcessedTableManager get messagesRefs {
    final manager = $$MessagesTableTableManager($_db, $_db.messages)
        .filter((f) => f.conversationId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_messagesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ConversationsTableFilterComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastMessage => $composableBuilder(
      column: $table.lastMessage, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastMessageAt => $composableBuilder(
      column: $table.lastMessageAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get unreadCount => $composableBuilder(
      column: $table.unreadCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> messagesRefs(
      Expression<bool> Function($$MessagesTableFilterComposer f) f) {
    final $$MessagesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.messages,
        getReferencedColumn: (t) => t.conversationId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MessagesTableFilterComposer(
              $db: $db,
              $table: $db.messages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ConversationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastMessage => $composableBuilder(
      column: $table.lastMessage, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastMessageAt => $composableBuilder(
      column: $table.lastMessageAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get unreadCount => $composableBuilder(
      column: $table.unreadCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ConversationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get lastMessage => $composableBuilder(
      column: $table.lastMessage, builder: (column) => column);

  GeneratedColumn<DateTime> get lastMessageAt => $composableBuilder(
      column: $table.lastMessageAt, builder: (column) => column);

  GeneratedColumn<int> get unreadCount => $composableBuilder(
      column: $table.unreadCount, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> messagesRefs<T extends Object>(
      Expression<T> Function($$MessagesTableAnnotationComposer a) f) {
    final $$MessagesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.messages,
        getReferencedColumn: (t) => t.conversationId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MessagesTableAnnotationComposer(
              $db: $db,
              $table: $db.messages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ConversationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ConversationsTable,
    Conversation,
    $$ConversationsTableFilterComposer,
    $$ConversationsTableOrderingComposer,
    $$ConversationsTableAnnotationComposer,
    $$ConversationsTableCreateCompanionBuilder,
    $$ConversationsTableUpdateCompanionBuilder,
    (Conversation, $$ConversationsTableReferences),
    Conversation,
    PrefetchHooks Function({bool messagesRefs})> {
  $$ConversationsTableTableManager(_$AppDatabase db, $ConversationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConversationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConversationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConversationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> lastMessage = const Value.absent(),
            Value<DateTime?> lastMessageAt = const Value.absent(),
            Value<int> unreadCount = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              ConversationsCompanion(
            id: id,
            title: title,
            lastMessage: lastMessage,
            lastMessageAt: lastMessageAt,
            unreadCount: unreadCount,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String title,
            Value<String?> lastMessage = const Value.absent(),
            Value<DateTime?> lastMessageAt = const Value.absent(),
            Value<int> unreadCount = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              ConversationsCompanion.insert(
            id: id,
            title: title,
            lastMessage: lastMessage,
            lastMessageAt: lastMessageAt,
            unreadCount: unreadCount,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ConversationsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({messagesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (messagesRefs) db.messages],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (messagesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$ConversationsTableReferences
                            ._messagesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ConversationsTableReferences(db, table, p0)
                                .messagesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.conversationId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ConversationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ConversationsTable,
    Conversation,
    $$ConversationsTableFilterComposer,
    $$ConversationsTableOrderingComposer,
    $$ConversationsTableAnnotationComposer,
    $$ConversationsTableCreateCompanionBuilder,
    $$ConversationsTableUpdateCompanionBuilder,
    (Conversation, $$ConversationsTableReferences),
    Conversation,
    PrefetchHooks Function({bool messagesRefs})>;
typedef $$MessagesTableCreateCompanionBuilder = MessagesCompanion Function({
  Value<int> id,
  required int conversationId,
  required String content,
  required bool isFromUser,
  Value<DateTime> createdAt,
});
typedef $$MessagesTableUpdateCompanionBuilder = MessagesCompanion Function({
  Value<int> id,
  Value<int> conversationId,
  Value<String> content,
  Value<bool> isFromUser,
  Value<DateTime> createdAt,
});

final class $$MessagesTableReferences
    extends BaseReferences<_$AppDatabase, $MessagesTable, Message> {
  $$MessagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ConversationsTable _conversationIdTable(_$AppDatabase db) =>
      db.conversations.createAlias($_aliasNameGenerator(
          db.messages.conversationId, db.conversations.id));

  $$ConversationsTableProcessedTableManager get conversationId {
    final manager = $$ConversationsTableTableManager($_db, $_db.conversations)
        .filter((f) => f.id($_item.conversationId));
    final item = $_typedResult.readTableOrNull(_conversationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$MessagesTableFilterComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFromUser => $composableBuilder(
      column: $table.isFromUser, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$ConversationsTableFilterComposer get conversationId {
    final $$ConversationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.conversationId,
        referencedTable: $db.conversations,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ConversationsTableFilterComposer(
              $db: $db,
              $table: $db.conversations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFromUser => $composableBuilder(
      column: $table.isFromUser, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$ConversationsTableOrderingComposer get conversationId {
    final $$ConversationsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.conversationId,
        referencedTable: $db.conversations,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ConversationsTableOrderingComposer(
              $db: $db,
              $table: $db.conversations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<bool> get isFromUser => $composableBuilder(
      column: $table.isFromUser, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ConversationsTableAnnotationComposer get conversationId {
    final $$ConversationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.conversationId,
        referencedTable: $db.conversations,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ConversationsTableAnnotationComposer(
              $db: $db,
              $table: $db.conversations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MessagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MessagesTable,
    Message,
    $$MessagesTableFilterComposer,
    $$MessagesTableOrderingComposer,
    $$MessagesTableAnnotationComposer,
    $$MessagesTableCreateCompanionBuilder,
    $$MessagesTableUpdateCompanionBuilder,
    (Message, $$MessagesTableReferences),
    Message,
    PrefetchHooks Function({bool conversationId})> {
  $$MessagesTableTableManager(_$AppDatabase db, $MessagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> conversationId = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<bool> isFromUser = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              MessagesCompanion(
            id: id,
            conversationId: conversationId,
            content: content,
            isFromUser: isFromUser,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int conversationId,
            required String content,
            required bool isFromUser,
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              MessagesCompanion.insert(
            id: id,
            conversationId: conversationId,
            content: content,
            isFromUser: isFromUser,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$MessagesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({conversationId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (conversationId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.conversationId,
                    referencedTable:
                        $$MessagesTableReferences._conversationIdTable(db),
                    referencedColumn:
                        $$MessagesTableReferences._conversationIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$MessagesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MessagesTable,
    Message,
    $$MessagesTableFilterComposer,
    $$MessagesTableOrderingComposer,
    $$MessagesTableAnnotationComposer,
    $$MessagesTableCreateCompanionBuilder,
    $$MessagesTableUpdateCompanionBuilder,
    (Message, $$MessagesTableReferences),
    Message,
    PrefetchHooks Function({bool conversationId})>;
typedef $$SkillsTableCreateCompanionBuilder = SkillsCompanion Function({
  Value<int> id,
  required int playerId,
  required String category,
  required double score,
  required double confidence,
  required String trend,
  required DateTime calculatedAt,
  Value<int> version,
});
typedef $$SkillsTableUpdateCompanionBuilder = SkillsCompanion Function({
  Value<int> id,
  Value<int> playerId,
  Value<String> category,
  Value<double> score,
  Value<double> confidence,
  Value<String> trend,
  Value<DateTime> calculatedAt,
  Value<int> version,
});

class $$SkillsTableFilterComposer
    extends Composer<_$AppDatabase, $SkillsTable> {
  $$SkillsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get playerId => $composableBuilder(
      column: $table.playerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get score => $composableBuilder(
      column: $table.score, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get trend => $composableBuilder(
      column: $table.trend, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get calculatedAt => $composableBuilder(
      column: $table.calculatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));
}

class $$SkillsTableOrderingComposer
    extends Composer<_$AppDatabase, $SkillsTable> {
  $$SkillsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get playerId => $composableBuilder(
      column: $table.playerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get score => $composableBuilder(
      column: $table.score, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get trend => $composableBuilder(
      column: $table.trend, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get calculatedAt => $composableBuilder(
      column: $table.calculatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));
}

class $$SkillsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SkillsTable> {
  $$SkillsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get playerId =>
      $composableBuilder(column: $table.playerId, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => column);

  GeneratedColumn<String> get trend =>
      $composableBuilder(column: $table.trend, builder: (column) => column);

  GeneratedColumn<DateTime> get calculatedAt => $composableBuilder(
      column: $table.calculatedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);
}

class $$SkillsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SkillsTable,
    Skill,
    $$SkillsTableFilterComposer,
    $$SkillsTableOrderingComposer,
    $$SkillsTableAnnotationComposer,
    $$SkillsTableCreateCompanionBuilder,
    $$SkillsTableUpdateCompanionBuilder,
    (Skill, BaseReferences<_$AppDatabase, $SkillsTable, Skill>),
    Skill,
    PrefetchHooks Function()> {
  $$SkillsTableTableManager(_$AppDatabase db, $SkillsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SkillsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SkillsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SkillsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> playerId = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<double> score = const Value.absent(),
            Value<double> confidence = const Value.absent(),
            Value<String> trend = const Value.absent(),
            Value<DateTime> calculatedAt = const Value.absent(),
            Value<int> version = const Value.absent(),
          }) =>
              SkillsCompanion(
            id: id,
            playerId: playerId,
            category: category,
            score: score,
            confidence: confidence,
            trend: trend,
            calculatedAt: calculatedAt,
            version: version,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int playerId,
            required String category,
            required double score,
            required double confidence,
            required String trend,
            required DateTime calculatedAt,
            Value<int> version = const Value.absent(),
          }) =>
              SkillsCompanion.insert(
            id: id,
            playerId: playerId,
            category: category,
            score: score,
            confidence: confidence,
            trend: trend,
            calculatedAt: calculatedAt,
            version: version,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SkillsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SkillsTable,
    Skill,
    $$SkillsTableFilterComposer,
    $$SkillsTableOrderingComposer,
    $$SkillsTableAnnotationComposer,
    $$SkillsTableCreateCompanionBuilder,
    $$SkillsTableUpdateCompanionBuilder,
    (Skill, BaseReferences<_$AppDatabase, $SkillsTable, Skill>),
    Skill,
    PrefetchHooks Function()>;
typedef $$SkillHistoryTableTableCreateCompanionBuilder
    = SkillHistoryTableCompanion Function({
  Value<int> id,
  required int skillId,
  required int sessionId,
  required double score,
  required double confidence,
  required String trend,
  required DateTime createdAt,
});
typedef $$SkillHistoryTableTableUpdateCompanionBuilder
    = SkillHistoryTableCompanion Function({
  Value<int> id,
  Value<int> skillId,
  Value<int> sessionId,
  Value<double> score,
  Value<double> confidence,
  Value<String> trend,
  Value<DateTime> createdAt,
});

class $$SkillHistoryTableTableFilterComposer
    extends Composer<_$AppDatabase, $SkillHistoryTableTable> {
  $$SkillHistoryTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get skillId => $composableBuilder(
      column: $table.skillId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get score => $composableBuilder(
      column: $table.score, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get trend => $composableBuilder(
      column: $table.trend, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$SkillHistoryTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SkillHistoryTableTable> {
  $$SkillHistoryTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get skillId => $composableBuilder(
      column: $table.skillId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get score => $composableBuilder(
      column: $table.score, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get trend => $composableBuilder(
      column: $table.trend, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$SkillHistoryTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SkillHistoryTableTable> {
  $$SkillHistoryTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get skillId =>
      $composableBuilder(column: $table.skillId, builder: (column) => column);

  GeneratedColumn<int> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<double> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => column);

  GeneratedColumn<String> get trend =>
      $composableBuilder(column: $table.trend, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SkillHistoryTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SkillHistoryTableTable,
    SkillHistory,
    $$SkillHistoryTableTableFilterComposer,
    $$SkillHistoryTableTableOrderingComposer,
    $$SkillHistoryTableTableAnnotationComposer,
    $$SkillHistoryTableTableCreateCompanionBuilder,
    $$SkillHistoryTableTableUpdateCompanionBuilder,
    (
      SkillHistory,
      BaseReferences<_$AppDatabase, $SkillHistoryTableTable, SkillHistory>
    ),
    SkillHistory,
    PrefetchHooks Function()> {
  $$SkillHistoryTableTableTableManager(
      _$AppDatabase db, $SkillHistoryTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SkillHistoryTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SkillHistoryTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SkillHistoryTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> skillId = const Value.absent(),
            Value<int> sessionId = const Value.absent(),
            Value<double> score = const Value.absent(),
            Value<double> confidence = const Value.absent(),
            Value<String> trend = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              SkillHistoryTableCompanion(
            id: id,
            skillId: skillId,
            sessionId: sessionId,
            score: score,
            confidence: confidence,
            trend: trend,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int skillId,
            required int sessionId,
            required double score,
            required double confidence,
            required String trend,
            required DateTime createdAt,
          }) =>
              SkillHistoryTableCompanion.insert(
            id: id,
            skillId: skillId,
            sessionId: sessionId,
            score: score,
            confidence: confidence,
            trend: trend,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SkillHistoryTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SkillHistoryTableTable,
    SkillHistory,
    $$SkillHistoryTableTableFilterComposer,
    $$SkillHistoryTableTableOrderingComposer,
    $$SkillHistoryTableTableAnnotationComposer,
    $$SkillHistoryTableTableCreateCompanionBuilder,
    $$SkillHistoryTableTableUpdateCompanionBuilder,
    (
      SkillHistory,
      BaseReferences<_$AppDatabase, $SkillHistoryTableTable, SkillHistory>
    ),
    SkillHistory,
    PrefetchHooks Function()>;
typedef $$DailyGoalsTableCreateCompanionBuilder = DailyGoalsCompanion Function({
  Value<int> id,
  required String title,
  required String titleVi,
  Value<String?> description,
  required String category,
  required String priority,
  required String status,
  required int targetValue,
  required int currentValue,
  required String unit,
  required DateTime createdAt,
  Value<DateTime?> completedAt,
  Value<String?> targetDate,
  required bool isRecurring,
  Value<String?> recurrence,
});
typedef $$DailyGoalsTableUpdateCompanionBuilder = DailyGoalsCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String> titleVi,
  Value<String?> description,
  Value<String> category,
  Value<String> priority,
  Value<String> status,
  Value<int> targetValue,
  Value<int> currentValue,
  Value<String> unit,
  Value<DateTime> createdAt,
  Value<DateTime?> completedAt,
  Value<String?> targetDate,
  Value<bool> isRecurring,
  Value<String?> recurrence,
});

class $$DailyGoalsTableFilterComposer
    extends Composer<_$AppDatabase, $DailyGoalsTable> {
  $$DailyGoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get titleVi => $composableBuilder(
      column: $table.titleVi, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get targetValue => $composableBuilder(
      column: $table.targetValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get currentValue => $composableBuilder(
      column: $table.currentValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetDate => $composableBuilder(
      column: $table.targetDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isRecurring => $composableBuilder(
      column: $table.isRecurring, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recurrence => $composableBuilder(
      column: $table.recurrence, builder: (column) => ColumnFilters(column));
}

class $$DailyGoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyGoalsTable> {
  $$DailyGoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get titleVi => $composableBuilder(
      column: $table.titleVi, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get targetValue => $composableBuilder(
      column: $table.targetValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get currentValue => $composableBuilder(
      column: $table.currentValue,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetDate => $composableBuilder(
      column: $table.targetDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRecurring => $composableBuilder(
      column: $table.isRecurring, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recurrence => $composableBuilder(
      column: $table.recurrence, builder: (column) => ColumnOrderings(column));
}

class $$DailyGoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyGoalsTable> {
  $$DailyGoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get titleVi =>
      $composableBuilder(column: $table.titleVi, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get targetValue => $composableBuilder(
      column: $table.targetValue, builder: (column) => column);

  GeneratedColumn<int> get currentValue => $composableBuilder(
      column: $table.currentValue, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<String> get targetDate => $composableBuilder(
      column: $table.targetDate, builder: (column) => column);

  GeneratedColumn<bool> get isRecurring => $composableBuilder(
      column: $table.isRecurring, builder: (column) => column);

  GeneratedColumn<String> get recurrence => $composableBuilder(
      column: $table.recurrence, builder: (column) => column);
}

class $$DailyGoalsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DailyGoalsTable,
    DailyGoal,
    $$DailyGoalsTableFilterComposer,
    $$DailyGoalsTableOrderingComposer,
    $$DailyGoalsTableAnnotationComposer,
    $$DailyGoalsTableCreateCompanionBuilder,
    $$DailyGoalsTableUpdateCompanionBuilder,
    (DailyGoal, BaseReferences<_$AppDatabase, $DailyGoalsTable, DailyGoal>),
    DailyGoal,
    PrefetchHooks Function()> {
  $$DailyGoalsTableTableManager(_$AppDatabase db, $DailyGoalsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyGoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyGoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyGoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> titleVi = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> priority = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> targetValue = const Value.absent(),
            Value<int> currentValue = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<String?> targetDate = const Value.absent(),
            Value<bool> isRecurring = const Value.absent(),
            Value<String?> recurrence = const Value.absent(),
          }) =>
              DailyGoalsCompanion(
            id: id,
            title: title,
            titleVi: titleVi,
            description: description,
            category: category,
            priority: priority,
            status: status,
            targetValue: targetValue,
            currentValue: currentValue,
            unit: unit,
            createdAt: createdAt,
            completedAt: completedAt,
            targetDate: targetDate,
            isRecurring: isRecurring,
            recurrence: recurrence,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String title,
            required String titleVi,
            Value<String?> description = const Value.absent(),
            required String category,
            required String priority,
            required String status,
            required int targetValue,
            required int currentValue,
            required String unit,
            required DateTime createdAt,
            Value<DateTime?> completedAt = const Value.absent(),
            Value<String?> targetDate = const Value.absent(),
            required bool isRecurring,
            Value<String?> recurrence = const Value.absent(),
          }) =>
              DailyGoalsCompanion.insert(
            id: id,
            title: title,
            titleVi: titleVi,
            description: description,
            category: category,
            priority: priority,
            status: status,
            targetValue: targetValue,
            currentValue: currentValue,
            unit: unit,
            createdAt: createdAt,
            completedAt: completedAt,
            targetDate: targetDate,
            isRecurring: isRecurring,
            recurrence: recurrence,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DailyGoalsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DailyGoalsTable,
    DailyGoal,
    $$DailyGoalsTableFilterComposer,
    $$DailyGoalsTableOrderingComposer,
    $$DailyGoalsTableAnnotationComposer,
    $$DailyGoalsTableCreateCompanionBuilder,
    $$DailyGoalsTableUpdateCompanionBuilder,
    (DailyGoal, BaseReferences<_$AppDatabase, $DailyGoalsTable, DailyGoal>),
    DailyGoal,
    PrefetchHooks Function()>;
typedef $$DrillSessionsTableCreateCompanionBuilder = DrillSessionsCompanion
    Function({
  Value<int> id,
  required int drillId,
  required String drillName,
  required DateTime startedAt,
  Value<DateTime?> completedAt,
  required int currentScore,
  required int targetScore,
  required int attempts,
  required int successfulAttempts,
  Value<String?> rating,
  Value<String?> notes,
});
typedef $$DrillSessionsTableUpdateCompanionBuilder = DrillSessionsCompanion
    Function({
  Value<int> id,
  Value<int> drillId,
  Value<String> drillName,
  Value<DateTime> startedAt,
  Value<DateTime?> completedAt,
  Value<int> currentScore,
  Value<int> targetScore,
  Value<int> attempts,
  Value<int> successfulAttempts,
  Value<String?> rating,
  Value<String?> notes,
});

class $$DrillSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $DrillSessionsTable> {
  $$DrillSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get drillId => $composableBuilder(
      column: $table.drillId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get drillName => $composableBuilder(
      column: $table.drillName, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get currentScore => $composableBuilder(
      column: $table.currentScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get targetScore => $composableBuilder(
      column: $table.targetScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get successfulAttempts => $composableBuilder(
      column: $table.successfulAttempts,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rating => $composableBuilder(
      column: $table.rating, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));
}

class $$DrillSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $DrillSessionsTable> {
  $$DrillSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get drillId => $composableBuilder(
      column: $table.drillId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get drillName => $composableBuilder(
      column: $table.drillName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get currentScore => $composableBuilder(
      column: $table.currentScore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get targetScore => $composableBuilder(
      column: $table.targetScore, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get successfulAttempts => $composableBuilder(
      column: $table.successfulAttempts,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rating => $composableBuilder(
      column: $table.rating, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));
}

class $$DrillSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DrillSessionsTable> {
  $$DrillSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get drillId =>
      $composableBuilder(column: $table.drillId, builder: (column) => column);

  GeneratedColumn<String> get drillName =>
      $composableBuilder(column: $table.drillName, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<int> get currentScore => $composableBuilder(
      column: $table.currentScore, builder: (column) => column);

  GeneratedColumn<int> get targetScore => $composableBuilder(
      column: $table.targetScore, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<int> get successfulAttempts => $composableBuilder(
      column: $table.successfulAttempts, builder: (column) => column);

  GeneratedColumn<String> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$DrillSessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DrillSessionsTable,
    DrillSession,
    $$DrillSessionsTableFilterComposer,
    $$DrillSessionsTableOrderingComposer,
    $$DrillSessionsTableAnnotationComposer,
    $$DrillSessionsTableCreateCompanionBuilder,
    $$DrillSessionsTableUpdateCompanionBuilder,
    (
      DrillSession,
      BaseReferences<_$AppDatabase, $DrillSessionsTable, DrillSession>
    ),
    DrillSession,
    PrefetchHooks Function()> {
  $$DrillSessionsTableTableManager(_$AppDatabase db, $DrillSessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DrillSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DrillSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DrillSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> drillId = const Value.absent(),
            Value<String> drillName = const Value.absent(),
            Value<DateTime> startedAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<int> currentScore = const Value.absent(),
            Value<int> targetScore = const Value.absent(),
            Value<int> attempts = const Value.absent(),
            Value<int> successfulAttempts = const Value.absent(),
            Value<String?> rating = const Value.absent(),
            Value<String?> notes = const Value.absent(),
          }) =>
              DrillSessionsCompanion(
            id: id,
            drillId: drillId,
            drillName: drillName,
            startedAt: startedAt,
            completedAt: completedAt,
            currentScore: currentScore,
            targetScore: targetScore,
            attempts: attempts,
            successfulAttempts: successfulAttempts,
            rating: rating,
            notes: notes,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int drillId,
            required String drillName,
            required DateTime startedAt,
            Value<DateTime?> completedAt = const Value.absent(),
            required int currentScore,
            required int targetScore,
            required int attempts,
            required int successfulAttempts,
            Value<String?> rating = const Value.absent(),
            Value<String?> notes = const Value.absent(),
          }) =>
              DrillSessionsCompanion.insert(
            id: id,
            drillId: drillId,
            drillName: drillName,
            startedAt: startedAt,
            completedAt: completedAt,
            currentScore: currentScore,
            targetScore: targetScore,
            attempts: attempts,
            successfulAttempts: successfulAttempts,
            rating: rating,
            notes: notes,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DrillSessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DrillSessionsTable,
    DrillSession,
    $$DrillSessionsTableFilterComposer,
    $$DrillSessionsTableOrderingComposer,
    $$DrillSessionsTableAnnotationComposer,
    $$DrillSessionsTableCreateCompanionBuilder,
    $$DrillSessionsTableUpdateCompanionBuilder,
    (
      DrillSession,
      BaseReferences<_$AppDatabase, $DrillSessionsTable, DrillSession>
    ),
    DrillSession,
    PrefetchHooks Function()>;
typedef $$TrainingProgramProgressTableCreateCompanionBuilder
    = TrainingProgramProgressCompanion Function({
  Value<int> id,
  required int programId,
  required int currentWeek,
  required int currentSession,
  required int completedSessions,
  required int totalSessions,
  required double overallProgress,
  required DateTime startedAt,
  Value<DateTime?> completedAt,
  required String completedSessionIds,
});
typedef $$TrainingProgramProgressTableUpdateCompanionBuilder
    = TrainingProgramProgressCompanion Function({
  Value<int> id,
  Value<int> programId,
  Value<int> currentWeek,
  Value<int> currentSession,
  Value<int> completedSessions,
  Value<int> totalSessions,
  Value<double> overallProgress,
  Value<DateTime> startedAt,
  Value<DateTime?> completedAt,
  Value<String> completedSessionIds,
});

class $$TrainingProgramProgressTableFilterComposer
    extends Composer<_$AppDatabase, $TrainingProgramProgressTable> {
  $$TrainingProgramProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get programId => $composableBuilder(
      column: $table.programId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get currentWeek => $composableBuilder(
      column: $table.currentWeek, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get currentSession => $composableBuilder(
      column: $table.currentSession,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get completedSessions => $composableBuilder(
      column: $table.completedSessions,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalSessions => $composableBuilder(
      column: $table.totalSessions, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get overallProgress => $composableBuilder(
      column: $table.overallProgress,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get completedSessionIds => $composableBuilder(
      column: $table.completedSessionIds,
      builder: (column) => ColumnFilters(column));
}

class $$TrainingProgramProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $TrainingProgramProgressTable> {
  $$TrainingProgramProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get programId => $composableBuilder(
      column: $table.programId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get currentWeek => $composableBuilder(
      column: $table.currentWeek, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get currentSession => $composableBuilder(
      column: $table.currentSession,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get completedSessions => $composableBuilder(
      column: $table.completedSessions,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalSessions => $composableBuilder(
      column: $table.totalSessions,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get overallProgress => $composableBuilder(
      column: $table.overallProgress,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get completedSessionIds => $composableBuilder(
      column: $table.completedSessionIds,
      builder: (column) => ColumnOrderings(column));
}

class $$TrainingProgramProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrainingProgramProgressTable> {
  $$TrainingProgramProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get programId =>
      $composableBuilder(column: $table.programId, builder: (column) => column);

  GeneratedColumn<int> get currentWeek => $composableBuilder(
      column: $table.currentWeek, builder: (column) => column);

  GeneratedColumn<int> get currentSession => $composableBuilder(
      column: $table.currentSession, builder: (column) => column);

  GeneratedColumn<int> get completedSessions => $composableBuilder(
      column: $table.completedSessions, builder: (column) => column);

  GeneratedColumn<int> get totalSessions => $composableBuilder(
      column: $table.totalSessions, builder: (column) => column);

  GeneratedColumn<double> get overallProgress => $composableBuilder(
      column: $table.overallProgress, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<String> get completedSessionIds => $composableBuilder(
      column: $table.completedSessionIds, builder: (column) => column);
}

class $$TrainingProgramProgressTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TrainingProgramProgressTable,
    TrainingProgramProgressData,
    $$TrainingProgramProgressTableFilterComposer,
    $$TrainingProgramProgressTableOrderingComposer,
    $$TrainingProgramProgressTableAnnotationComposer,
    $$TrainingProgramProgressTableCreateCompanionBuilder,
    $$TrainingProgramProgressTableUpdateCompanionBuilder,
    (
      TrainingProgramProgressData,
      BaseReferences<_$AppDatabase, $TrainingProgramProgressTable,
          TrainingProgramProgressData>
    ),
    TrainingProgramProgressData,
    PrefetchHooks Function()> {
  $$TrainingProgramProgressTableTableManager(
      _$AppDatabase db, $TrainingProgramProgressTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrainingProgramProgressTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$TrainingProgramProgressTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrainingProgramProgressTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> programId = const Value.absent(),
            Value<int> currentWeek = const Value.absent(),
            Value<int> currentSession = const Value.absent(),
            Value<int> completedSessions = const Value.absent(),
            Value<int> totalSessions = const Value.absent(),
            Value<double> overallProgress = const Value.absent(),
            Value<DateTime> startedAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<String> completedSessionIds = const Value.absent(),
          }) =>
              TrainingProgramProgressCompanion(
            id: id,
            programId: programId,
            currentWeek: currentWeek,
            currentSession: currentSession,
            completedSessions: completedSessions,
            totalSessions: totalSessions,
            overallProgress: overallProgress,
            startedAt: startedAt,
            completedAt: completedAt,
            completedSessionIds: completedSessionIds,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int programId,
            required int currentWeek,
            required int currentSession,
            required int completedSessions,
            required int totalSessions,
            required double overallProgress,
            required DateTime startedAt,
            Value<DateTime?> completedAt = const Value.absent(),
            required String completedSessionIds,
          }) =>
              TrainingProgramProgressCompanion.insert(
            id: id,
            programId: programId,
            currentWeek: currentWeek,
            currentSession: currentSession,
            completedSessions: completedSessions,
            totalSessions: totalSessions,
            overallProgress: overallProgress,
            startedAt: startedAt,
            completedAt: completedAt,
            completedSessionIds: completedSessionIds,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TrainingProgramProgressTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $TrainingProgramProgressTable,
        TrainingProgramProgressData,
        $$TrainingProgramProgressTableFilterComposer,
        $$TrainingProgramProgressTableOrderingComposer,
        $$TrainingProgramProgressTableAnnotationComposer,
        $$TrainingProgramProgressTableCreateCompanionBuilder,
        $$TrainingProgramProgressTableUpdateCompanionBuilder,
        (
          TrainingProgramProgressData,
          BaseReferences<_$AppDatabase, $TrainingProgramProgressTable,
              TrainingProgramProgressData>
        ),
        TrainingProgramProgressData,
        PrefetchHooks Function()>;
typedef $$PracticeShotsTableCreateCompanionBuilder = PracticeShotsCompanion
    Function({
  Value<int> id,
  Value<int?> sessionId,
  required String drillCode,
  required int shotNumber,
  required String shotType,
  required bool success,
  Value<String?> missType,
  Value<int> cueBallControl,
  Value<int> position,
  Value<int> difficulty,
  Value<String?> notes,
  required DateTime createdAt,
});
typedef $$PracticeShotsTableUpdateCompanionBuilder = PracticeShotsCompanion
    Function({
  Value<int> id,
  Value<int?> sessionId,
  Value<String> drillCode,
  Value<int> shotNumber,
  Value<String> shotType,
  Value<bool> success,
  Value<String?> missType,
  Value<int> cueBallControl,
  Value<int> position,
  Value<int> difficulty,
  Value<String?> notes,
  Value<DateTime> createdAt,
});

class $$PracticeShotsTableFilterComposer
    extends Composer<_$AppDatabase, $PracticeShotsTable> {
  $$PracticeShotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get drillCode => $composableBuilder(
      column: $table.drillCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get shotNumber => $composableBuilder(
      column: $table.shotNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get shotType => $composableBuilder(
      column: $table.shotType, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get success => $composableBuilder(
      column: $table.success, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get missType => $composableBuilder(
      column: $table.missType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cueBallControl => $composableBuilder(
      column: $table.cueBallControl,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$PracticeShotsTableOrderingComposer
    extends Composer<_$AppDatabase, $PracticeShotsTable> {
  $$PracticeShotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get drillCode => $composableBuilder(
      column: $table.drillCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get shotNumber => $composableBuilder(
      column: $table.shotNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get shotType => $composableBuilder(
      column: $table.shotType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get success => $composableBuilder(
      column: $table.success, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get missType => $composableBuilder(
      column: $table.missType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cueBallControl => $composableBuilder(
      column: $table.cueBallControl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$PracticeShotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PracticeShotsTable> {
  $$PracticeShotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get drillCode =>
      $composableBuilder(column: $table.drillCode, builder: (column) => column);

  GeneratedColumn<int> get shotNumber => $composableBuilder(
      column: $table.shotNumber, builder: (column) => column);

  GeneratedColumn<String> get shotType =>
      $composableBuilder(column: $table.shotType, builder: (column) => column);

  GeneratedColumn<bool> get success =>
      $composableBuilder(column: $table.success, builder: (column) => column);

  GeneratedColumn<String> get missType =>
      $composableBuilder(column: $table.missType, builder: (column) => column);

  GeneratedColumn<int> get cueBallControl => $composableBuilder(
      column: $table.cueBallControl, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PracticeShotsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PracticeShotsTable,
    PracticeShot,
    $$PracticeShotsTableFilterComposer,
    $$PracticeShotsTableOrderingComposer,
    $$PracticeShotsTableAnnotationComposer,
    $$PracticeShotsTableCreateCompanionBuilder,
    $$PracticeShotsTableUpdateCompanionBuilder,
    (
      PracticeShot,
      BaseReferences<_$AppDatabase, $PracticeShotsTable, PracticeShot>
    ),
    PracticeShot,
    PrefetchHooks Function()> {
  $$PracticeShotsTableTableManager(_$AppDatabase db, $PracticeShotsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PracticeShotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PracticeShotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PracticeShotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> sessionId = const Value.absent(),
            Value<String> drillCode = const Value.absent(),
            Value<int> shotNumber = const Value.absent(),
            Value<String> shotType = const Value.absent(),
            Value<bool> success = const Value.absent(),
            Value<String?> missType = const Value.absent(),
            Value<int> cueBallControl = const Value.absent(),
            Value<int> position = const Value.absent(),
            Value<int> difficulty = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              PracticeShotsCompanion(
            id: id,
            sessionId: sessionId,
            drillCode: drillCode,
            shotNumber: shotNumber,
            shotType: shotType,
            success: success,
            missType: missType,
            cueBallControl: cueBallControl,
            position: position,
            difficulty: difficulty,
            notes: notes,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> sessionId = const Value.absent(),
            required String drillCode,
            required int shotNumber,
            required String shotType,
            required bool success,
            Value<String?> missType = const Value.absent(),
            Value<int> cueBallControl = const Value.absent(),
            Value<int> position = const Value.absent(),
            Value<int> difficulty = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            required DateTime createdAt,
          }) =>
              PracticeShotsCompanion.insert(
            id: id,
            sessionId: sessionId,
            drillCode: drillCode,
            shotNumber: shotNumber,
            shotType: shotType,
            success: success,
            missType: missType,
            cueBallControl: cueBallControl,
            position: position,
            difficulty: difficulty,
            notes: notes,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PracticeShotsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PracticeShotsTable,
    PracticeShot,
    $$PracticeShotsTableFilterComposer,
    $$PracticeShotsTableOrderingComposer,
    $$PracticeShotsTableAnnotationComposer,
    $$PracticeShotsTableCreateCompanionBuilder,
    $$PracticeShotsTableUpdateCompanionBuilder,
    (
      PracticeShot,
      BaseReferences<_$AppDatabase, $PracticeShotsTable, PracticeShot>
    ),
    PracticeShot,
    PrefetchHooks Function()>;
typedef $$PracticeSessionsTableCreateCompanionBuilder
    = PracticeSessionsCompanion Function({
  Value<int> id,
  Value<int?> playerId,
  Value<int?> sessionId,
  required String drillCode,
  required String drillName,
  required DateTime startedAt,
  Value<DateTime?> completedAt,
  Value<String?> notes,
  Value<int> totalShots,
  Value<int> successfulShots,
  Value<double> successRate,
  Value<double> averageDifficulty,
  Value<int> longestRun,
  Value<String> shotsByType,
  Value<String> missesByType,
});
typedef $$PracticeSessionsTableUpdateCompanionBuilder
    = PracticeSessionsCompanion Function({
  Value<int> id,
  Value<int?> playerId,
  Value<int?> sessionId,
  Value<String> drillCode,
  Value<String> drillName,
  Value<DateTime> startedAt,
  Value<DateTime?> completedAt,
  Value<String?> notes,
  Value<int> totalShots,
  Value<int> successfulShots,
  Value<double> successRate,
  Value<double> averageDifficulty,
  Value<int> longestRun,
  Value<String> shotsByType,
  Value<String> missesByType,
});

class $$PracticeSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $PracticeSessionsTable> {
  $$PracticeSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get playerId => $composableBuilder(
      column: $table.playerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get drillCode => $composableBuilder(
      column: $table.drillCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get drillName => $composableBuilder(
      column: $table.drillName, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalShots => $composableBuilder(
      column: $table.totalShots, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get successfulShots => $composableBuilder(
      column: $table.successfulShots,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get successRate => $composableBuilder(
      column: $table.successRate, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get averageDifficulty => $composableBuilder(
      column: $table.averageDifficulty,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get longestRun => $composableBuilder(
      column: $table.longestRun, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get shotsByType => $composableBuilder(
      column: $table.shotsByType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get missesByType => $composableBuilder(
      column: $table.missesByType, builder: (column) => ColumnFilters(column));
}

class $$PracticeSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PracticeSessionsTable> {
  $$PracticeSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get playerId => $composableBuilder(
      column: $table.playerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get drillCode => $composableBuilder(
      column: $table.drillCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get drillName => $composableBuilder(
      column: $table.drillName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalShots => $composableBuilder(
      column: $table.totalShots, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get successfulShots => $composableBuilder(
      column: $table.successfulShots,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get successRate => $composableBuilder(
      column: $table.successRate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get averageDifficulty => $composableBuilder(
      column: $table.averageDifficulty,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get longestRun => $composableBuilder(
      column: $table.longestRun, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get shotsByType => $composableBuilder(
      column: $table.shotsByType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get missesByType => $composableBuilder(
      column: $table.missesByType,
      builder: (column) => ColumnOrderings(column));
}

class $$PracticeSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PracticeSessionsTable> {
  $$PracticeSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get playerId =>
      $composableBuilder(column: $table.playerId, builder: (column) => column);

  GeneratedColumn<int> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get drillCode =>
      $composableBuilder(column: $table.drillCode, builder: (column) => column);

  GeneratedColumn<String> get drillName =>
      $composableBuilder(column: $table.drillName, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get totalShots => $composableBuilder(
      column: $table.totalShots, builder: (column) => column);

  GeneratedColumn<int> get successfulShots => $composableBuilder(
      column: $table.successfulShots, builder: (column) => column);

  GeneratedColumn<double> get successRate => $composableBuilder(
      column: $table.successRate, builder: (column) => column);

  GeneratedColumn<double> get averageDifficulty => $composableBuilder(
      column: $table.averageDifficulty, builder: (column) => column);

  GeneratedColumn<int> get longestRun => $composableBuilder(
      column: $table.longestRun, builder: (column) => column);

  GeneratedColumn<String> get shotsByType => $composableBuilder(
      column: $table.shotsByType, builder: (column) => column);

  GeneratedColumn<String> get missesByType => $composableBuilder(
      column: $table.missesByType, builder: (column) => column);
}

class $$PracticeSessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PracticeSessionsTable,
    PracticeSession,
    $$PracticeSessionsTableFilterComposer,
    $$PracticeSessionsTableOrderingComposer,
    $$PracticeSessionsTableAnnotationComposer,
    $$PracticeSessionsTableCreateCompanionBuilder,
    $$PracticeSessionsTableUpdateCompanionBuilder,
    (
      PracticeSession,
      BaseReferences<_$AppDatabase, $PracticeSessionsTable, PracticeSession>
    ),
    PracticeSession,
    PrefetchHooks Function()> {
  $$PracticeSessionsTableTableManager(
      _$AppDatabase db, $PracticeSessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PracticeSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PracticeSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PracticeSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> playerId = const Value.absent(),
            Value<int?> sessionId = const Value.absent(),
            Value<String> drillCode = const Value.absent(),
            Value<String> drillName = const Value.absent(),
            Value<DateTime> startedAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> totalShots = const Value.absent(),
            Value<int> successfulShots = const Value.absent(),
            Value<double> successRate = const Value.absent(),
            Value<double> averageDifficulty = const Value.absent(),
            Value<int> longestRun = const Value.absent(),
            Value<String> shotsByType = const Value.absent(),
            Value<String> missesByType = const Value.absent(),
          }) =>
              PracticeSessionsCompanion(
            id: id,
            playerId: playerId,
            sessionId: sessionId,
            drillCode: drillCode,
            drillName: drillName,
            startedAt: startedAt,
            completedAt: completedAt,
            notes: notes,
            totalShots: totalShots,
            successfulShots: successfulShots,
            successRate: successRate,
            averageDifficulty: averageDifficulty,
            longestRun: longestRun,
            shotsByType: shotsByType,
            missesByType: missesByType,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> playerId = const Value.absent(),
            Value<int?> sessionId = const Value.absent(),
            required String drillCode,
            required String drillName,
            required DateTime startedAt,
            Value<DateTime?> completedAt = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> totalShots = const Value.absent(),
            Value<int> successfulShots = const Value.absent(),
            Value<double> successRate = const Value.absent(),
            Value<double> averageDifficulty = const Value.absent(),
            Value<int> longestRun = const Value.absent(),
            Value<String> shotsByType = const Value.absent(),
            Value<String> missesByType = const Value.absent(),
          }) =>
              PracticeSessionsCompanion.insert(
            id: id,
            playerId: playerId,
            sessionId: sessionId,
            drillCode: drillCode,
            drillName: drillName,
            startedAt: startedAt,
            completedAt: completedAt,
            notes: notes,
            totalShots: totalShots,
            successfulShots: successfulShots,
            successRate: successRate,
            averageDifficulty: averageDifficulty,
            longestRun: longestRun,
            shotsByType: shotsByType,
            missesByType: missesByType,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PracticeSessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PracticeSessionsTable,
    PracticeSession,
    $$PracticeSessionsTableFilterComposer,
    $$PracticeSessionsTableOrderingComposer,
    $$PracticeSessionsTableAnnotationComposer,
    $$PracticeSessionsTableCreateCompanionBuilder,
    $$PracticeSessionsTableUpdateCompanionBuilder,
    (
      PracticeSession,
      BaseReferences<_$AppDatabase, $PracticeSessionsTable, PracticeSession>
    ),
    PracticeSession,
    PrefetchHooks Function()>;
typedef $$PlayerStateLogsTableCreateCompanionBuilder = PlayerStateLogsCompanion
    Function({
  Value<int> id,
  required int sessionId,
  Value<int?> matchId,
  required String kind,
  Value<int?> readyToCompete,
  Value<int?> warmedUp,
  Value<int?> handFeel,
  Value<int?> fatigueLevel,
  Value<String?> notes,
  required DateTime createdAt,
});
typedef $$PlayerStateLogsTableUpdateCompanionBuilder = PlayerStateLogsCompanion
    Function({
  Value<int> id,
  Value<int> sessionId,
  Value<int?> matchId,
  Value<String> kind,
  Value<int?> readyToCompete,
  Value<int?> warmedUp,
  Value<int?> handFeel,
  Value<int?> fatigueLevel,
  Value<String?> notes,
  Value<DateTime> createdAt,
});

class $$PlayerStateLogsTableFilterComposer
    extends Composer<_$AppDatabase, $PlayerStateLogsTable> {
  $$PlayerStateLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get matchId => $composableBuilder(
      column: $table.matchId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get readyToCompete => $composableBuilder(
      column: $table.readyToCompete,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get warmedUp => $composableBuilder(
      column: $table.warmedUp, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get handFeel => $composableBuilder(
      column: $table.handFeel, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fatigueLevel => $composableBuilder(
      column: $table.fatigueLevel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$PlayerStateLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayerStateLogsTable> {
  $$PlayerStateLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get matchId => $composableBuilder(
      column: $table.matchId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get readyToCompete => $composableBuilder(
      column: $table.readyToCompete,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get warmedUp => $composableBuilder(
      column: $table.warmedUp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get handFeel => $composableBuilder(
      column: $table.handFeel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fatigueLevel => $composableBuilder(
      column: $table.fatigueLevel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$PlayerStateLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayerStateLogsTable> {
  $$PlayerStateLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<int> get matchId =>
      $composableBuilder(column: $table.matchId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get readyToCompete => $composableBuilder(
      column: $table.readyToCompete, builder: (column) => column);

  GeneratedColumn<int> get warmedUp =>
      $composableBuilder(column: $table.warmedUp, builder: (column) => column);

  GeneratedColumn<int> get handFeel =>
      $composableBuilder(column: $table.handFeel, builder: (column) => column);

  GeneratedColumn<int> get fatigueLevel => $composableBuilder(
      column: $table.fatigueLevel, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PlayerStateLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlayerStateLogsTable,
    PlayerStateLog,
    $$PlayerStateLogsTableFilterComposer,
    $$PlayerStateLogsTableOrderingComposer,
    $$PlayerStateLogsTableAnnotationComposer,
    $$PlayerStateLogsTableCreateCompanionBuilder,
    $$PlayerStateLogsTableUpdateCompanionBuilder,
    (
      PlayerStateLog,
      BaseReferences<_$AppDatabase, $PlayerStateLogsTable, PlayerStateLog>
    ),
    PlayerStateLog,
    PrefetchHooks Function()> {
  $$PlayerStateLogsTableTableManager(
      _$AppDatabase db, $PlayerStateLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayerStateLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayerStateLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayerStateLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> sessionId = const Value.absent(),
            Value<int?> matchId = const Value.absent(),
            Value<String> kind = const Value.absent(),
            Value<int?> readyToCompete = const Value.absent(),
            Value<int?> warmedUp = const Value.absent(),
            Value<int?> handFeel = const Value.absent(),
            Value<int?> fatigueLevel = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              PlayerStateLogsCompanion(
            id: id,
            sessionId: sessionId,
            matchId: matchId,
            kind: kind,
            readyToCompete: readyToCompete,
            warmedUp: warmedUp,
            handFeel: handFeel,
            fatigueLevel: fatigueLevel,
            notes: notes,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int sessionId,
            Value<int?> matchId = const Value.absent(),
            required String kind,
            Value<int?> readyToCompete = const Value.absent(),
            Value<int?> warmedUp = const Value.absent(),
            Value<int?> handFeel = const Value.absent(),
            Value<int?> fatigueLevel = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            required DateTime createdAt,
          }) =>
              PlayerStateLogsCompanion.insert(
            id: id,
            sessionId: sessionId,
            matchId: matchId,
            kind: kind,
            readyToCompete: readyToCompete,
            warmedUp: warmedUp,
            handFeel: handFeel,
            fatigueLevel: fatigueLevel,
            notes: notes,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PlayerStateLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PlayerStateLogsTable,
    PlayerStateLog,
    $$PlayerStateLogsTableFilterComposer,
    $$PlayerStateLogsTableOrderingComposer,
    $$PlayerStateLogsTableAnnotationComposer,
    $$PlayerStateLogsTableCreateCompanionBuilder,
    $$PlayerStateLogsTableUpdateCompanionBuilder,
    (
      PlayerStateLog,
      BaseReferences<_$AppDatabase, $PlayerStateLogsTable, PlayerStateLog>
    ),
    PlayerStateLog,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PlayersTableTableManager get players =>
      $$PlayersTableTableManager(_db, _db.players);
  $$CuesTableTableManager get cues => $$CuesTableTableManager(_db, _db.cues);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$MatchesTableTableManager get matches =>
      $$MatchesTableTableManager(_db, _db.matches);
  $$RacksTableTableManager get racks =>
      $$RacksTableTableManager(_db, _db.racks);
  $$ShotsTableTableManager get shots =>
      $$ShotsTableTableManager(_db, _db.shots);
  $$EventsTableTableManager get events =>
      $$EventsTableTableManager(_db, _db.events);
  $$ConversationsTableTableManager get conversations =>
      $$ConversationsTableTableManager(_db, _db.conversations);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
  $$SkillsTableTableManager get skills =>
      $$SkillsTableTableManager(_db, _db.skills);
  $$SkillHistoryTableTableTableManager get skillHistoryTable =>
      $$SkillHistoryTableTableTableManager(_db, _db.skillHistoryTable);
  $$DailyGoalsTableTableManager get dailyGoals =>
      $$DailyGoalsTableTableManager(_db, _db.dailyGoals);
  $$DrillSessionsTableTableManager get drillSessions =>
      $$DrillSessionsTableTableManager(_db, _db.drillSessions);
  $$TrainingProgramProgressTableTableManager get trainingProgramProgress =>
      $$TrainingProgramProgressTableTableManager(
          _db, _db.trainingProgramProgress);
  $$PracticeShotsTableTableManager get practiceShots =>
      $$PracticeShotsTableTableManager(_db, _db.practiceShots);
  $$PracticeSessionsTableTableManager get practiceSessions =>
      $$PracticeSessionsTableTableManager(_db, _db.practiceSessions);
  $$PlayerStateLogsTableTableManager get playerStateLogs =>
      $$PlayerStateLogsTableTableManager(_db, _db.playerStateLogs);
}
