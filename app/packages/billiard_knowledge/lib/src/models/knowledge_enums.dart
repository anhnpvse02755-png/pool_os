/// Enums for billiard knowledge types
library billiard_knowledge.enums;

/// Difficulty levels for knowledge items and drills
enum KnowledgeDifficulty {
  /// Beginner level - fundamental skills
  beginner,
  
  /// Intermediate level - basic techniques
  intermediate,
  
  /// Advanced level - complex skills
  advanced,
  
  /// Professional level - expert techniques
  professional;

  /// Get display name in English
  String get displayName {
    switch (this) {
      case KnowledgeDifficulty.beginner:
        return 'Beginner';
      case KnowledgeDifficulty.intermediate:
        return 'Intermediate';
      case KnowledgeDifficulty.advanced:
        return 'Advanced';
      case KnowledgeDifficulty.professional:
        return 'Professional';
    }
  }

  /// Get display name in Vietnamese
  String get displayNameVi {
    switch (this) {
      case KnowledgeDifficulty.beginner:
        return 'Người mới';
      case KnowledgeDifficulty.intermediate:
        return 'Trung cấp';
      case KnowledgeDifficulty.advanced:
        return 'Nâng cao';
      case KnowledgeDifficulty.professional:
        return 'Chuyên nghiệp';
    }
  }

  /// Convert from string
  static KnowledgeDifficulty fromString(String value) {
    return KnowledgeDifficulty.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => KnowledgeDifficulty.beginner,
    );
  }
}

/// Player levels (H=Beginner, G=Intermediate, F=Advanced, etc.)
enum PlayerLevel {
  h('H', KnowledgeDifficulty.beginner),
  g('G', KnowledgeDifficulty.intermediate),
  f('F', KnowledgeDifficulty.intermediate),
  e('E', KnowledgeDifficulty.advanced),
  d('D', KnowledgeDifficulty.advanced),
  c('C', KnowledgeDifficulty.advanced),
  b('B', KnowledgeDifficulty.professional),
  a('A', KnowledgeDifficulty.professional),
  pro('Pro', KnowledgeDifficulty.professional);

  final String code;
  final KnowledgeDifficulty difficulty;

  const PlayerLevel(this.code, this.difficulty);

  /// Get display name
  String get displayName {
    switch (this) {
      case PlayerLevel.h:
        return 'H - Beginner';
      case PlayerLevel.g:
        return 'G - Novice';
      case PlayerLevel.f:
        return 'F - Intermediate';
      case PlayerLevel.e:
        return 'E - Upper Intermediate';
      case PlayerLevel.d:
        return 'D - Advanced';
      case PlayerLevel.c:
        return 'C - Upper Advanced';
      case PlayerLevel.b:
        return 'B - Expert';
      case PlayerLevel.a:
        return 'A - Elite';
      case PlayerLevel.pro:
        return 'Professional';
    }
  }

  /// Convert from string
  static PlayerLevel fromString(String value) {
    return PlayerLevel.values.firstWhere(
      (e) => e.code == value.toUpperCase() || e.name == value.toLowerCase(),
      orElse: () => PlayerLevel.h,
    );
  }
}

/// Types of knowledge items
enum KnowledgeType {
  /// Technique skill (e.g., draw shot, bank shot)
  technique,
  
  /// Common mistake and correction
  mistake,
  
  /// Strategic knowledge
  strategy,
  
  /// Equipment information
  equipment,
  
  /// Mental game and psychology
  mental,
  
  /// Aiming fundamentals
  aim,
  
  /// Bridge technique
  bridge,
  
  /// Cue ball control
  cueBall,
  
  /// Bank shot technique
  bank,
  
  /// Safety play
  safety,
  
  /// Break shot
  breakShot,
  
  /// Other
  other;

  /// Get display name in English
  String get displayName {
    switch (this) {
      case KnowledgeType.technique:
        return 'Technique';
      case KnowledgeType.mistake:
        return 'Mistake';
      case KnowledgeType.strategy:
        return 'Strategy';
      case KnowledgeType.equipment:
        return 'Equipment';
      case KnowledgeType.mental:
        return 'Mental';
      case KnowledgeType.aim:
        return 'Aiming';
      case KnowledgeType.bridge:
        return 'Bridge';
      case KnowledgeType.cueBall:
        return 'Cue Ball Control';
      case KnowledgeType.bank:
        return 'Bank Shot';
      case KnowledgeType.safety:
        return 'Safety Play';
      case KnowledgeType.breakShot:
        return 'Break Shot';
      case KnowledgeType.other:
        return 'Other';
    }
  }

  /// Get display name in Vietnamese
  String get displayNameVi {
    switch (this) {
      case KnowledgeType.technique:
        return 'Kỹ thuật';
      case KnowledgeType.mistake:
        return 'Lỗi thường gặp';
      case KnowledgeType.strategy:
        return 'Chiến lược';
      case KnowledgeType.equipment:
        return 'Dụng cụ';
      case KnowledgeType.mental:
        return 'Tâm lý';
      case KnowledgeType.aim:
        return 'Ngắm bắn';
      case KnowledgeType.bridge:
        return 'Giá đỡ tay';
      case KnowledgeType.cueBall:
        return 'Kiểm soát bi a';
      case KnowledgeType.bank:
        return 'Đánh dội';
      case KnowledgeType.safety:
        return 'Chơi an toàn';
      case KnowledgeType.breakShot:
        return 'Đánh phá';
      case KnowledgeType.other:
        return 'Khác';
    }
  }

  /// Convert from string
  static KnowledgeType fromString(String value) {
    final normalized = value.toLowerCase();
    
    // Map common variations
    final mappings = {
      'techniques': KnowledgeType.technique,
      'technique': KnowledgeType.technique,
      'mistakes': KnowledgeType.mistake,
      'mistake': KnowledgeType.mistake,
      'strategies': KnowledgeType.strategy,
      'strategy': KnowledgeType.strategy,
      'equipment': KnowledgeType.equipment,
      'mental': KnowledgeType.mental,
      'aim': KnowledgeType.aim,
      'aiming': KnowledgeType.aim,
      'bridge': KnowledgeType.bridge,
      'cue_ball': KnowledgeType.cueBall,
      'cueball': KnowledgeType.cueBall,
      'bank': KnowledgeType.bank,
      'bank_shot': KnowledgeType.bank,
      'safety': KnowledgeType.safety,
      'break': KnowledgeType.breakShot,
      'break_shot': KnowledgeType.breakShot,
      'other': KnowledgeType.other,
    };

    return mappings[normalized] ?? KnowledgeType.other;
  }
}

/// Verification status of a knowledge item
enum KnowledgeStatus {
  /// Verified by experts
  verified,
  
  /// In testing/beta
  beta,
  
  /// Draft, not complete
  draft;

  /// Get display name
  String get displayName {
    switch (this) {
      case KnowledgeStatus.verified:
        return 'Verified';
      case KnowledgeStatus.beta:
        return 'Beta';
      case KnowledgeStatus.draft:
        return 'Draft';
    }
  }

  /// Convert from string
  static KnowledgeStatus fromString(String value) {
    return KnowledgeStatus.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => KnowledgeStatus.draft,
    );
  }
}

/// Relationship types between knowledge items
enum RelationType {
  /// Related but not prerequisite
  related,
  
  /// Must learn before
  prerequisite,
  
  /// Builds upon
  buildsUpon,
  
  /// Similar to
  similarTo,
  
  /// Opposite technique
  opposite,
  
  /// Advanced version
  advancedVersion,
  
  /// Part of a group
  partOf;

  /// Convert from string
  static RelationType fromString(String value) {
    return RelationType.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => RelationType.related,
    );
  }
}

/// Learning goal types
enum LearningGoal {
  /// Improve accuracy/pocketing
  improveAccuracy,
  
  /// Improve cue ball control
  improvePosition,
  
  /// Improve break effectiveness
  improveBreak,
  
  /// Improve safety play
  improveSafety,
  
  /// Learn a specific technique
  learnNewShot,
  
  /// Fix common mistakes
  fixMistakes,
  
  /// Tournament preparation
  tournamentPrep,
  
  /// Quick warm-up
  warmUp,
  
  /// Cool down/end session
  coolDown,
  
  /// Find weaknesses
  assessWeaknesses,
  
  /// Advance to next level
  levelUp,
  
  /// Maintain current skill
  maintainSkill,
  
  /// Master fundamentals
  masterFundamentals;

  /// Convert from string
  static LearningGoal fromString(String value) {
    return LearningGoal.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => LearningGoal.improveAccuracy,
    );
  }
}
