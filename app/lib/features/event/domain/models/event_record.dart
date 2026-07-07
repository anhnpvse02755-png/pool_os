import 'dart:ui';

class EventRecord {
  final int? id;
  final int? shotId;
  final int? rackId;
  final int? sessionId;
  final int? matchId;
  final EventCategory category;
  final EventType type;
  final EventSeverity severity;
  final String? confidence;
  final String? notes;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  EventRecord({
    this.id,
    this.shotId,
    this.rackId,
    this.sessionId,
    this.matchId,
    required this.category,
    required this.type,
    required this.severity,
    this.confidence,
    this.notes,
    this.metadata,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  EventRecord copyWith({
    int? id,
    int? shotId,
    int? rackId,
    int? sessionId,
    int? matchId,
    EventCategory? category,
    EventType? type,
    EventSeverity? severity,
    String? confidence,
    String? notes,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return EventRecord(
      id: id ?? this.id,
      shotId: shotId ?? this.shotId,
      rackId: rackId ?? this.rackId,
      sessionId: sessionId ?? this.sessionId,
      matchId: matchId ?? this.matchId,
      category: category ?? this.category,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      confidence: confidence ?? this.confidence,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get displayLabel => '${category.name} - ${type.name}';
}

enum EventCategory {
  foul,
  breakEvent,
  safety,
  greatShot,
  mistake,
  mental,
  equipment,
  other,
}

extension EventCategoryExtension on EventCategory {
  String get name {
    return switch (this) {
      EventCategory.foul => 'foul',
      EventCategory.breakEvent => 'break',
      EventCategory.safety => 'safety',
      EventCategory.greatShot => 'great_shot',
      EventCategory.mistake => 'mistake',
      EventCategory.mental => 'mental',
      EventCategory.equipment => 'equipment',
      EventCategory.other => 'other',
    };
  }

  String getDisplayName() {
    return switch (this) {
      EventCategory.foul => 'Foul',
      EventCategory.breakEvent => 'Break',
      EventCategory.safety => 'Safety',
      EventCategory.greatShot => 'Great Shot',
      EventCategory.mistake => 'Mistake',
      EventCategory.mental => 'Mental',
      EventCategory.equipment => 'Equipment',
      EventCategory.other => 'Other',
    };
  }

  String getDisplayNameVi() {
    return switch (this) {
      EventCategory.foul => 'Lỗi',
      EventCategory.breakEvent => 'Phá bàn',
      EventCategory.safety => 'An toàn',
      EventCategory.greatShot => 'Cú đánh hay',
      EventCategory.mistake => 'Sai lầm',
      EventCategory.mental => 'Tâm lý',
      EventCategory.equipment => 'Dụng cụ',
      EventCategory.other => 'Khác',
    };
  }
}

enum EventType {
  scratch,
  foulBall,
  ballInHand,
  badContact,
  earlyRelease,
  miscue,
  doubleHit,
  jumpingBall,
  pushShot,
  illegalBreak,
  dryBreak,
  poorScatter,
  clusterCreated,
  badLeave,
  poorLeave,
  opponentEasyBall,
  easyShotMissed,
  difficultShotMade,
  toughShotMissed,
  pressureShotMade,
  pressureShotMissed,
  comebackShot,
  runOut,
  safetyWin,
  safetyLost,
  forcedError,
  opponentError,
  lapse,
  tilt,
  nerves,
  frustration,
  lossOfFocus,
  equipmentChange,
  tipChange,
  cueProblem,
  tableCondition,
}

extension EventTypeExtension on EventType {
  String getDisplayName() {
    return switch (this) {
      EventType.scratch => 'Scratch',
      EventType.foulBall => 'Foul Ball',
      EventType.ballInHand => 'Ball in Hand',
      EventType.badContact => 'Bad Contact',
      EventType.earlyRelease => 'Early Release',
      EventType.miscue => 'Miscue',
      EventType.doubleHit => 'Double Hit',
      EventType.jumpingBall => 'Jumping Ball',
      EventType.pushShot => 'Push Shot',
      EventType.illegalBreak => 'Illegal Break',
      EventType.dryBreak => 'Dry Break',
      EventType.poorScatter => 'Poor Scatter',
      EventType.clusterCreated => 'Cluster Created',
      EventType.badLeave => 'Bad Leave',
      EventType.poorLeave => 'Poor Leave',
      EventType.opponentEasyBall => 'Opponent Easy Ball',
      EventType.easyShotMissed => 'Easy Shot Missed',
      EventType.difficultShotMade => 'Difficult Shot Made',
      EventType.toughShotMissed => 'Tough Shot Missed',
      EventType.pressureShotMade => 'Pressure Shot Made',
      EventType.pressureShotMissed => 'Pressure Shot Missed',
      EventType.comebackShot => 'Comeback Shot',
      EventType.runOut => 'Run Out',
      EventType.safetyWin => 'Safety Win',
      EventType.safetyLost => 'Safety Lost',
      EventType.forcedError => 'Forced Error',
      EventType.opponentError => 'Opponent Error',
      EventType.lapse => 'Lapse',
      EventType.tilt => 'Tilt',
      EventType.nerves => 'Nerves',
      EventType.frustration => 'Frustration',
      EventType.lossOfFocus => 'Loss of Focus',
      EventType.equipmentChange => 'Equipment Change',
      EventType.tipChange => 'Tip Change',
      EventType.cueProblem => 'Cue Problem',
      EventType.tableCondition => 'Table Condition',
    };
  }

  String getDisplayNameVi() {
    return switch (this) {
      EventType.scratch => 'Ghiền bi',
      EventType.foulBall => 'Đánh bi sai',
      EventType.ballInHand => 'Bi trong tay',
      EventType.badContact => 'Chạm bi kém',
      EventType.earlyRelease => 'Thả sớm',
      EventType.miscue => 'Đánh trượt',
      EventType.doubleHit => 'Chạm hai lần',
      EventType.jumpingBall => 'Bi nhảy',
      EventType.pushShot => 'Đẩy bi',
      EventType.illegalBreak => 'Phá bất hợp lệ',
      EventType.dryBreak => 'Phá khô',
      EventType.poorScatter => 'Tải kém',
      EventType.clusterCreated => 'Tạo cụm',
      EventType.badLeave => 'Để lại xấu',
      EventType.poorLeave => 'Để lại kém',
      EventType.opponentEasyBall => 'Đối thủ được bi dễ',
      EventType.easyShotMissed => 'Bỏ bi dễ',
      EventType.difficultShotMade => 'Đánh bi khó trúng',
      EventType.toughShotMissed => 'Bỏ bi khó',
      EventType.pressureShotMade => 'Đánh bi áp lực trúng',
      EventType.pressureShotMissed => 'Bỏ bi áp lực',
      EventType.comebackShot => 'Cú cứu',
      EventType.runOut => 'Chạy bàn',
      EventType.safetyWin => 'Thắng an toàn',
      EventType.safetyLost => 'Thua an toàn',
      EventType.forcedError => 'Sai do ép',
      EventType.opponentError => 'Đối thủ sai',
      EventType.lapse => 'Đen điểm',
      EventType.tilt => 'Mất bình tĩnh',
      EventType.nerves => 'Hồi hộp',
      EventType.frustration => 'Thất vọng',
      EventType.lossOfFocus => 'Mất tập trung',
      EventType.equipmentChange => 'Đổi dụng cụ',
      EventType.tipChange => 'Đổi đầu cơ',
      EventType.cueProblem => 'Vấn đề cơ',
      EventType.tableCondition => 'Tình trạng bàn',
    };
  }

  EventCategory getCategory() {
    return switch (this) {
      EventType.scratch ||
      EventType.foulBall ||
      EventType.ballInHand ||
      EventType.badContact ||
      EventType.earlyRelease ||
      EventType.miscue ||
      EventType.doubleHit ||
      EventType.jumpingBall ||
      EventType.pushShot ||
      EventType.illegalBreak =>
        EventCategory.foul,
      EventType.dryBreak ||
      EventType.poorScatter ||
      EventType.clusterCreated =>
        EventCategory.breakEvent,
      EventType.badLeave ||
      EventType.poorLeave ||
      EventType.opponentEasyBall ||
      EventType.safetyWin ||
      EventType.safetyLost =>
        EventCategory.safety,
      EventType.easyShotMissed ||
      EventType.difficultShotMade ||
      EventType.toughShotMissed ||
      EventType.pressureShotMade ||
      EventType.pressureShotMissed ||
      EventType.comebackShot ||
      EventType.runOut =>
        EventCategory.greatShot,
      EventType.forcedError ||
      EventType.opponentError =>
        EventCategory.mistake,
      EventType.lapse ||
      EventType.tilt ||
      EventType.nerves ||
      EventType.frustration ||
      EventType.lossOfFocus =>
        EventCategory.mental,
      EventType.equipmentChange ||
      EventType.tipChange ||
      EventType.cueProblem ||
      EventType.tableCondition =>
        EventCategory.equipment,
    };
  }
}

enum EventSeverity {
  minor,
  moderate,
  significant,
  critical,
}

extension EventSeverityExtension on EventSeverity {
  String get name {
    return switch (this) {
      EventSeverity.minor => 'minor',
      EventSeverity.moderate => 'moderate',
      EventSeverity.significant => 'significant',
      EventSeverity.critical => 'critical',
    };
  }

  String getDisplayName() {
    return switch (this) {
      EventSeverity.minor => 'Minor',
      EventSeverity.moderate => 'Moderate',
      EventSeverity.significant => 'Significant',
      EventSeverity.critical => 'Critical',
    };
  }

  String getDisplayNameVi() {
    return switch (this) {
      EventSeverity.minor => 'Nhẹ',
      EventSeverity.moderate => 'Trung bình',
      EventSeverity.significant => 'Đáng kể',
      EventSeverity.critical => 'Nghiêm trọng',
    };
  }

  Color getColor() {
    return switch (this) {
      EventSeverity.minor => EventColors.grey,
      EventSeverity.moderate => EventColors.blue,
      EventSeverity.significant => EventColors.orange,
      EventSeverity.critical => EventColors.red,
    };
  }
}

class EventColors {
  static const Color grey = Color(0xFF9E9E9E);
  static const Color blue = Color(0xFF2196F3);
  static const Color orange = Color(0xFFFF9800);
  static const Color red = Color(0xFFF44336);
}
