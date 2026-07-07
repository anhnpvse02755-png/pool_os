/// FIX-003: Practice Shot Model for Practice Mode
/// Each shot stores detailed information for drill sessions
class PracticeShot {
  final int? id;
  final int? sessionId;
  final String drillCode;
  final int shotNumber;
  
  // Shot Type (in Vietnamese)
  final PracticeShotType shotType;
  
  // Result
  final bool success;
  
  // Miss Type (if missed)
  final MissType? missType;
  
  // Cue Ball Control rating (1-5)
  final int cueBallControl;
  
  // Position quality (1-5)
  final int position;
  
  // Difficulty level (1-5)
  final int difficulty;
  
  // Notes
  final String? notes;
  
  // Timestamp
  final DateTime createdAt;

  PracticeShot({
    this.id,
    this.sessionId,
    required this.drillCode,
    required this.shotNumber,
    required this.shotType,
    required this.success,
    this.missType,
    this.cueBallControl = 3,
    this.position = 3,
    this.difficulty = 3,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  PracticeShot copyWith({
    int? id,
    int? sessionId,
    String? drillCode,
    int? shotNumber,
    PracticeShotType? shotType,
    bool? success,
    MissType? missType,
    int? cueBallControl,
    int? position,
    int? difficulty,
    String? notes,
    DateTime? createdAt,
  }) {
    return PracticeShot(
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'drillCode': drillCode,
      'shotNumber': shotNumber,
      'shotType': shotType.name,
      'success': success,
      'missType': missType?.name,
      'cueBallControl': cueBallControl,
      'position': position,
      'difficulty': difficulty,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PracticeShot.fromJson(Map<String, dynamic> json) {
    return PracticeShot(
      id: json['id'] as int?,
      sessionId: json['sessionId'] as int?,
      drillCode: json['drillCode'] as String,
      shotNumber: json['shotNumber'] as int,
      shotType: PracticeShotType.values.firstWhere(
        (e) => e.name == json['shotType'],
        orElse: () => PracticeShotType.straight,
      ),
      success: json['success'] as bool,
      missType: json['missType'] != null 
          ? MissType.values.firstWhere(
              (e) => e.name == json['missType'],
              orElse: () => MissType.position,
            )
          : null,
      cueBallControl: json['cueBallControl'] as int? ?? 3,
      position: json['position'] as int? ?? 3,
      difficulty: json['difficulty'] as int? ?? 3,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}

/// FIX-003: Practice Shot Types in Vietnamese
/// All shot types displayed in Vietnamese as per FIX-003 requirement
enum PracticeShotType {
  // Cắt mỏng
  thinCut,
  // Cắt dày
  thickCut,
  // Bi thẳng
  straight,
  // Retro
  retro,
  // Follow
  follow,
  // Stun
  stun,
  // Bank
  bank,
  // Kick
  kick,
  // Jump
  jump,
  // Masse
  masse,
  // Combination
  combination,
  // Carom
  carom,
  // Safety
  safety,
  // Break
  practiceBreak,
  // Cue Ball Control
  cueBallControl,
}

extension PracticeShotTypeExtension on PracticeShotType {
  String get displayNameVi {
    switch (this) {
      case PracticeShotType.thinCut: return 'Cắt mỏng';
      case PracticeShotType.thickCut: return 'Cắt dày';
      case PracticeShotType.straight: return 'Bi thẳng';
      case PracticeShotType.retro: return 'Retro';
      case PracticeShotType.follow: return 'Follow';
      case PracticeShotType.stun: return 'Stun';
      case PracticeShotType.bank: return 'Bank';
      case PracticeShotType.kick: return 'Kick';
      case PracticeShotType.jump: return 'Jump';
      case PracticeShotType.masse: return 'Masse';
      case PracticeShotType.combination: return 'Combination';
      case PracticeShotType.carom: return 'Carom';
      case PracticeShotType.safety: return 'Safety';
      case PracticeShotType.practiceBreak: return 'Break';
      case PracticeShotType.cueBallControl: return 'Kiểm soát bi cue';
    }
  }

  String get displayNameEn {
    switch (this) {
      case PracticeShotType.thinCut: return 'Thin Cut';
      case PracticeShotType.thickCut: return 'Thick Cut';
      case PracticeShotType.straight: return 'Straight';
      case PracticeShotType.retro: return 'Retro';
      case PracticeShotType.follow: return 'Follow';
      case PracticeShotType.stun: return 'Stun';
      case PracticeShotType.bank: return 'Bank';
      case PracticeShotType.kick: return 'Kick';
      case PracticeShotType.jump: return 'Jump';
      case PracticeShotType.masse: return 'Masse';
      case PracticeShotType.combination: return 'Combination';
      case PracticeShotType.carom: return 'Carom';
      case PracticeShotType.safety: return 'Safety';
      case PracticeShotType.practiceBreak: return 'Break';
      case PracticeShotType.cueBallControl: return 'Cue Ball Control';
    }
  }
}

/// FIX-003: Miss Types for Practice Mode
enum MissType {
  thin,
  thick,
  underCut,
  overCut,
  speed,
  position,
  wrongSpin,
  wrongAim,
}

extension MissTypeExtension on MissType {
  String get displayNameVi {
    switch (this) {
      case MissType.thin: return 'Mỏng';
      case MissType.thick: return 'Dày';
      case MissType.underCut: return 'Cắt dưới';
      case MissType.overCut: return 'Cắt trên';
      case MissType.speed: return 'Tốc độ';
      case MissType.position: return 'Vị trí';
      case MissType.wrongSpin: return 'Xoáy sai';
      case MissType.wrongAim: return 'Ngắm sai';
    }
  }

  String get displayNameEn {
    switch (this) {
      case MissType.thin: return 'Thin';
      case MissType.thick: return 'Thick';
      case MissType.underCut: return 'Under Cut';
      case MissType.overCut: return 'Over Cut';
      case MissType.speed: return 'Speed';
      case MissType.position: return 'Position';
      case MissType.wrongSpin: return 'Wrong Spin';
      case MissType.wrongAim: return 'Wrong Aim';
    }
  }
}
