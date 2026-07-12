class ShotRecord {
  final int? id;
  final int? rackId;
  final int? sessionId;
  final int? matchId;
  final int shotNumber;
  final ShotType shotType;
  final ShotDifficulty difficulty;
  final ShotResult result;
  final PositionQuality? positionQuality;
  final String? decision;
  final String? confidence;
  final String? notes;
  final int? pocketNumber;
  final String? ballPocketed;
  final bool isBreakShot;
  final bool isSafety;
  // Task 02: intent (what the player meant to do) + missReason (why it failed,
  // null when made) — stored as string codes matching the intent_*/miss_reason_*
  // localization keys.
  final String? intent;
  final String? missReason;
  final DateTime createdAt;

  ShotRecord({
    this.id,
    this.rackId,
    this.sessionId,
    this.matchId,
    required this.shotNumber,
    required this.shotType,
    required this.difficulty,
    required this.result,
    this.positionQuality,
    this.decision,
    this.confidence,
    this.notes,
    this.pocketNumber,
    this.ballPocketed,
    this.isBreakShot = false,
    this.isSafety = false,
    this.intent,
    this.missReason,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  ShotRecord copyWith({
    int? id,
    int? rackId,
    int? sessionId,
    int? matchId,
    int? shotNumber,
    ShotType? shotType,
    ShotDifficulty? difficulty,
    ShotResult? result,
    PositionQuality? positionQuality,
    String? decision,
    String? confidence,
    String? notes,
    int? pocketNumber,
    String? ballPocketed,
    bool? isBreakShot,
    bool? isSafety,
    String? intent,
    String? missReason,
    DateTime? createdAt,
  }) {
    return ShotRecord(
      id: id ?? this.id,
      rackId: rackId ?? this.rackId,
      sessionId: sessionId ?? this.sessionId,
      matchId: matchId ?? this.matchId,
      shotNumber: shotNumber ?? this.shotNumber,
      shotType: shotType ?? this.shotType,
      difficulty: difficulty ?? this.difficulty,
      result: result ?? this.result,
      positionQuality: positionQuality ?? this.positionQuality,
      decision: decision ?? this.decision,
      confidence: confidence ?? this.confidence,
      notes: notes ?? this.notes,
      pocketNumber: pocketNumber ?? this.pocketNumber,
      ballPocketed: ballPocketed ?? this.ballPocketed,
      isBreakShot: isBreakShot ?? this.isBreakShot,
      isSafety: isSafety ?? this.isSafety,
      intent: intent ?? this.intent,
      missReason: missReason ?? this.missReason,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isMade => result == ShotResult.made;
  bool get isMissed => result == ShotResult.missed;
  bool get isFoul => result == ShotResult.foul;
}

enum ShotType {
  straight,
  cut,
  bank,
  masse,
  jump,
  double,
  combo,
  pool,
  safetyReturn,
  pushShot,
  legalSafety,
}

extension ShotTypeExtension on ShotType {
  String get name {
    return switch (this) {
      ShotType.straight => 'straight',
      ShotType.cut => 'cut',
      ShotType.bank => 'bank',
      ShotType.masse => 'masse',
      ShotType.jump => 'jump',
      ShotType.double => 'double',
      ShotType.combo => 'combo',
      ShotType.pool => 'pool',
      ShotType.safetyReturn => 'safety_return',
      ShotType.pushShot => 'push_shot',
      ShotType.legalSafety => 'legal_safety',
    };
  }

  String getDisplayName() {
    return switch (this) {
      ShotType.straight => 'Straight',
      ShotType.cut => 'Cut',
      ShotType.bank => 'Bank',
      ShotType.masse => 'Masse',
      ShotType.jump => 'Jump',
      ShotType.double => 'Double',
      ShotType.combo => 'Combo',
      ShotType.pool => 'Pool',
      ShotType.safetyReturn => 'Safety Return',
      ShotType.pushShot => 'Push Shot',
      ShotType.legalSafety => 'Legal Safety',
    };
  }

  String getDisplayNameVi() {
    return switch (this) {
      ShotType.straight => 'Thang',
      ShotType.cut => 'Cat',
      ShotType.bank => 'Gien',
      ShotType.masse => 'Xoay',
      ShotType.jump => 'Nhay',
      ShotType.double => 'Kep',
      ShotType.combo => 'Combo',
      ShotType.pool => 'Danh bi',
      ShotType.safetyReturn => 'An toan ve',
      ShotType.pushShot => 'Day',
      ShotType.legalSafety => 'An toan hop le',
    };
  }
}

enum ShotDifficulty {
  easy,
  medium,
  hard,
  expert,
}

extension ShotDifficultyExtension on ShotDifficulty {
  String get name {
    return switch (this) {
      ShotDifficulty.easy => 'easy',
      ShotDifficulty.medium => 'medium',
      ShotDifficulty.hard => 'hard',
      ShotDifficulty.expert => 'expert',
    };
  }

  String getDisplayName() {
    return switch (this) {
      ShotDifficulty.easy => 'Easy',
      ShotDifficulty.medium => 'Medium',
      ShotDifficulty.hard => 'Hard',
      ShotDifficulty.expert => 'Expert',
    };
  }

  String getDisplayNameVi() {
    return switch (this) {
      ShotDifficulty.easy => 'Dễ',
      ShotDifficulty.medium => 'Trung bình',
      ShotDifficulty.hard => 'Khó',
      ShotDifficulty.expert => 'Chuyên gia',
    };
  }
}

enum ShotResult {
  made,
  missed,
  foul,
  scratch,
}

extension ShotResultExtension on ShotResult {
  String get name {
    return switch (this) {
      ShotResult.made => 'made',
      ShotResult.missed => 'missed',
      ShotResult.foul => 'foul',
      ShotResult.scratch => 'scratch',
    };
  }

  String getDisplayName() {
    return switch (this) {
      ShotResult.made => 'Made',
      ShotResult.missed => 'Missed',
      ShotResult.foul => 'Foul',
      ShotResult.scratch => 'Scratch',
    };
  }

  String getDisplayNameVi() {
    return switch (this) {
      ShotResult.made => 'Trúng',
      ShotResult.missed => 'Trượt',
      ShotResult.foul => 'Lỗi',
      ShotResult.scratch => 'Điểm',
    };
  }
}

enum PositionQuality {
  perfect,
  good,
  playable,
  recovery,
  bad,
}

extension PositionQualityExtension on PositionQuality {
  String get name {
    return switch (this) {
      PositionQuality.perfect => 'perfect',
      PositionQuality.good => 'good',
      PositionQuality.playable => 'playable',
      PositionQuality.recovery => 'recovery',
      PositionQuality.bad => 'bad',
    };
  }

  String getDisplayName() {
    return switch (this) {
      PositionQuality.perfect => 'Perfect',
      PositionQuality.good => 'Good',
      PositionQuality.playable => 'Playable',
      PositionQuality.recovery => 'Recovery',
      PositionQuality.bad => 'Bad',
    };
  }

  String getDisplayNameVi() {
    return switch (this) {
      PositionQuality.perfect => 'Hoàn hảo',
      PositionQuality.good => 'Tốt',
      PositionQuality.playable => 'Chơi được',
      PositionQuality.recovery => 'Cứu',
      PositionQuality.bad => 'Xấu',
    };
  }
}

// Task 02: what the player MEANT to do with the shot (step 1 of the wizard).
// Stored as the string `code` on Shot.intent; labels resolve via l10n key
// intent_<code>.
enum ShotIntent {
  pot,
  position,
  safety,
  breakShot,
  escape;

  String get code => switch (this) {
        ShotIntent.pot => 'pot',
        ShotIntent.position => 'position',
        ShotIntent.safety => 'safety',
        ShotIntent.breakShot => 'break',
        ShotIntent.escape => 'escape',
      };

  String get l10nKey => 'intent_$code';

  static ShotIntent? fromCode(String? code) {
    if (code == null) return null;
    for (final v in ShotIntent.values) {
      if (v.code == code) return v;
    }
    return null;
  }
}

// Task 02: why a shot FAILED (step 4, shown only when result != made).
// Stored as the string `code` on Shot.missReason; labels resolve via l10n key
// miss_reason_<code>. Intentionally NON-technique-only: includes process/mental
// causes (rush, nerves) so Coach can tell a technique miss from a state miss.
enum MissReason {
  aim,
  speed,
  position,
  english,
  kick,
  rush,
  nerves,
  badDecision;

  String get code => switch (this) {
        MissReason.aim => 'aim',
        MissReason.speed => 'speed',
        MissReason.position => 'position',
        MissReason.english => 'english',
        MissReason.kick => 'kick',
        MissReason.rush => 'rush',
        MissReason.nerves => 'nerves',
        MissReason.badDecision => 'bad_decision',
      };

  String get l10nKey => 'miss_reason_$code';

  static MissReason? fromCode(String? code) {
    if (code == null) return null;
    for (final v in MissReason.values) {
      if (v.code == code) return v;
    }
    return null;
  }
}
