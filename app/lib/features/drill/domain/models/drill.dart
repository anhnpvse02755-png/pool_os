class Drill {
  final int? id;
  final String code;
  final String name;
  final String nameVi;
  final String description;
  final String descriptionVi;
  final String category;
  final String difficulty;
  final int difficultyStars; // 1-5 stars
  final int targetScore;
  final int timeLimitMinutes;
  final List<String> instructions;
  final List<String> instructionsVi;
  final String? equipment;
  final List<String> focusSkills;
  final bool isCustom;
  final String skillLevel; // beginner, intermediate, advanced, professional, coachCustom
  final String? purpose; // Vietnamese only - Mục đích
  final String? tableLayout; // Vietnamese only - Sơ đồ bàn
  final String? ballSetup; // Vietnamese only - Xếp bi
  final List<String>? commonMistakes; // Vietnamese only - Lỗi thường gặp
  final List<String>? expectedImprovement; // Vietnamese only - Cải thiện mong đợi
  final List<String>? relatedSkills; // Vietnamese only - Kỹ năng liên quan
  final int? recommendedRepetitions; // Số lần lặp đề xuất

  Drill({
    this.id,
    this.code = '',
    required this.name,
    required this.nameVi,
    required this.description,
    required this.descriptionVi,
    required this.category,
    required this.difficulty,
    this.difficultyStars = 1,
    this.targetScore = 10,
    this.timeLimitMinutes = 15,
    this.instructions = const [],
    this.instructionsVi = const [],
    this.equipment,
    this.focusSkills = const [],
    this.isCustom = false,
    this.skillLevel = 'beginner',
    this.purpose,
    this.tableLayout,
    this.ballSetup,
    this.commonMistakes,
    this.expectedImprovement,
    this.relatedSkills,
    this.recommendedRepetitions,
  });

  Drill copyWith({
    int? id,
    String? code,
    String? name,
    String? nameVi,
    String? description,
    String? descriptionVi,
    String? category,
    String? difficulty,
    int? difficultyStars,
    int? targetScore,
    int? timeLimitMinutes,
    List<String>? instructions,
    List<String>? instructionsVi,
    String? equipment,
    List<String>? focusSkills,
    bool? isCustom,
    String? skillLevel,
    String? purpose,
    String? tableLayout,
    String? ballSetup,
    List<String>? commonMistakes,
    List<String>? expectedImprovement,
    List<String>? relatedSkills,
    int? recommendedRepetitions,
  }) {
    return Drill(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      nameVi: nameVi ?? this.nameVi,
      description: description ?? this.description,
      descriptionVi: descriptionVi ?? this.descriptionVi,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      difficultyStars: difficultyStars ?? this.difficultyStars,
      targetScore: targetScore ?? this.targetScore,
      timeLimitMinutes: timeLimitMinutes ?? this.timeLimitMinutes,
      instructions: instructions ?? this.instructions,
      instructionsVi: instructionsVi ?? this.instructionsVi,
      equipment: equipment ?? this.equipment,
      focusSkills: focusSkills ?? this.focusSkills,
      isCustom: isCustom ?? this.isCustom,
      skillLevel: skillLevel ?? this.skillLevel,
      purpose: purpose ?? this.purpose,
      tableLayout: tableLayout ?? this.tableLayout,
      ballSetup: ballSetup ?? this.ballSetup,
      commonMistakes: commonMistakes ?? this.commonMistakes,
      expectedImprovement: expectedImprovement ?? this.expectedImprovement,
      relatedSkills: relatedSkills ?? this.relatedSkills,
      recommendedRepetitions: recommendedRepetitions ?? this.recommendedRepetitions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'nameVi': nameVi,
      'description': description,
      'descriptionVi': descriptionVi,
      'category': category,
      'difficulty': difficulty,
      'difficultyStars': difficultyStars,
      'targetScore': targetScore,
      'timeLimitMinutes': timeLimitMinutes,
      'instructions': instructions,
      'instructionsVi': instructionsVi,
      'equipment': equipment,
      'focusSkills': focusSkills,
      'isCustom': isCustom,
      'skillLevel': skillLevel,
      'purpose': purpose,
      'tableLayout': tableLayout,
      'ballSetup': ballSetup,
      'commonMistakes': commonMistakes,
      'expectedImprovement': expectedImprovement,
      'relatedSkills': relatedSkills,
      'recommendedRepetitions': recommendedRepetitions,
    };
  }

  factory Drill.fromJson(Map<String, dynamic> json) {
    return Drill(
      id: json['id'] as int?,
      code: json['code'] as String? ?? '',
      name: json['name'] as String,
      nameVi: json['nameVi'] as String? ?? json['name'] as String,
      description: json['description'] as String,
      descriptionVi: json['descriptionVi'] as String? ?? json['description'] as String,
      category: json['category'] as String,
      difficulty: json['difficulty'] as String,
      difficultyStars: json['difficultyStars'] as int? ?? 1,
      targetScore: json['targetScore'] as int? ?? 10,
      timeLimitMinutes: json['timeLimitMinutes'] as int? ?? 15,
      instructions: List<String>.from(json['instructions'] ?? []),
      instructionsVi: List<String>.from(json['instructionsVi'] ?? json['instructions'] ?? []),
      equipment: json['equipment'] as String?,
      focusSkills: List<String>.from(json['focusSkills'] ?? []),
      isCustom: json['isCustom'] as bool? ?? false,
      skillLevel: json['skillLevel'] as String? ?? 'beginner',
      purpose: json['purpose'] as String?,
      tableLayout: json['tableLayout'] as String?,
      ballSetup: json['ballSetup'] as String?,
      commonMistakes: json['commonMistakes'] != null ? List<String>.from(json['commonMistakes']) : null,
      expectedImprovement: json['expectedImprovement'] != null ? List<String>.from(json['expectedImprovement']) : null,
      relatedSkills: json['relatedSkills'] != null ? List<String>.from(json['relatedSkills']) : null,
      recommendedRepetitions: json['recommendedRepetitions'] as int?,
    );
  }
}

class DrillSession {
  final int? id;
  final String drillCode;
  final String drillName;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int currentScore;
  final int targetScore;
  final int attempts;
  final int successfulAttempts;
  final List<String> notes;
  final String? rating;

  DrillSession({
    this.id,
    required this.drillCode,
    required this.drillName,
    required this.startedAt,
    this.completedAt,
    this.currentScore = 0,
    required this.targetScore,
    this.attempts = 0,
    this.successfulAttempts = 0,
    this.notes = const [],
    this.rating,
  });

  DrillSession copyWith({
    int? id,
    String? drillCode,
    String? drillName,
    DateTime? startedAt,
    DateTime? completedAt,
    int? currentScore,
    int? targetScore,
    int? attempts,
    int? successfulAttempts,
    List<String>? notes,
    String? rating,
  }) {
    return DrillSession(
      id: id ?? this.id,
      drillCode: drillCode ?? this.drillCode,
      drillName: drillName ?? this.drillName,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      currentScore: currentScore ?? this.currentScore,
      targetScore: targetScore ?? this.targetScore,
      attempts: attempts ?? this.attempts,
      successfulAttempts: successfulAttempts ?? this.successfulAttempts,
      notes: notes ?? this.notes,
      rating: rating ?? this.rating,
    );
  }

  double get successRate =>
      attempts == 0 ? 0.0 : successfulAttempts / attempts;

  bool get isComplete => currentScore >= targetScore;

  Duration? get elapsedTime {
    if (completedAt == null) return null;
    return completedAt!.difference(startedAt);
  }
}

class DrillCategory {
  static const String warmup = 'warmup';
  static const String straightShot = 'straightShot';
  static const String thinCut = 'thinCut';
  static const String thickCut = 'thickCut';
  static const String longPot = 'longPot';
  static const String position = 'position';
  static const String cueBallControl = 'cueBallControl';
  static const String breakShot = 'break';
  static const String safety = 'safety';
  static const String kick = 'kick';
  static const String bank = 'bank';
  static const String jump = 'jump';
  static const String patternPlay = 'patternPlay';
  static const String pressure = 'pressure';
  static const String tournament = 'tournament';
  static const String mental = 'mental';
  static const String recovery = 'recovery';

  static const List<String> all = [
    warmup,
    straightShot,
    thinCut,
    thickCut,
    longPot,
    position,
    cueBallControl,
    breakShot,
    safety,
    kick,
    bank,
    jump,
    patternPlay,
    pressure,
    tournament,
    mental,
    recovery,
  ];

  static String getName(String category, String locale) {
    final names = {
      warmup: locale == 'vi' ? 'Khởi động' : 'Warmup',
      straightShot: locale == 'vi' ? 'Đánh Thẳng' : 'Straight Shot',
      thinCut: locale == 'vi' ? 'Cắt Mỏng' : 'Thin Cut',
      thickCut: locale == 'vi' ? 'Cắt Dày' : 'Thick Cut',
      longPot: locale == 'vi' ? 'Đánh Bi Xa' : 'Long Pot',
      position: locale == 'vi' ? 'Điều Bi' : 'Position',
      cueBallControl: locale == 'vi' ? 'Kiểm Soát Bi Cue' : 'Cue Ball Control',
      breakShot: locale == 'vi' ? 'Phá Bàn' : 'Break',
      safety: locale == 'vi' ? 'An Toàn' : 'Safety',
      kick: locale == 'vi' ? 'Đá Bi' : 'Kick',
      bank: locale == 'vi' ? 'Ghiên' : 'Bank',
      jump: locale == 'vi' ? 'Nhảy' : 'Jump',
      patternPlay: locale == 'vi' ? 'Quỹ Đạo' : 'Pattern Play',
      pressure: locale == 'vi' ? 'Áp Lực' : 'Pressure',
      tournament: locale == 'vi' ? 'Thi Đấu' : 'Tournament',
      mental: locale == 'vi' ? 'Tâm Lý' : 'Mental',
      recovery: locale == 'vi' ? 'Phục Hồi' : 'Recovery',
    };
    return names[category] ?? category;
  }
}

class DrillDifficulty {
  static const String beginner = 'beginner';
  static const String intermediate = 'intermediate';
  static const String advanced = 'advanced';
  static const String expert = 'expert';

  static const List<String> all = [
    beginner,
    intermediate,
    advanced,
    expert,
  ];
}

class DrillSkillLevel {
  static const String beginner = 'beginner';
  static const String intermediate = 'intermediate';
  static const String advanced = 'advanced';
  static const String professional = 'professional';
  static const String coachCustom = 'coachCustom';

  static const List<String> all = [
    beginner,
    intermediate,
    advanced,
    professional,
    coachCustom,
  ];

  static String getName(String level, String locale) {
    final names = {
      beginner: locale == 'vi' ? 'Người mới' : 'Beginner',
      intermediate: locale == 'vi' ? 'Trung bình' : 'Intermediate',
      advanced: locale == 'vi' ? 'Nâng cao' : 'Advanced',
      professional: locale == 'vi' ? 'Chuyên nghiệp' : 'Professional',
      coachCustom: locale == 'vi' ? 'Coach tùy chỉnh' : 'Coach Custom',
    };
    return names[level] ?? level;
  }
}

class DrillStatus {
  static const String notStarted = 'notStarted';
  static const String inProgress = 'inProgress';
  static const String completed = 'completed';
  static const String mastered = 'mastered';

  static const List<String> all = [
    notStarted,
    inProgress,
    completed,
    mastered,
  ];

  static String getName(String status, String locale) {
    final names = {
      notStarted: locale == 'vi' ? 'Chưa bắt đầu' : 'Not Started',
      inProgress: locale == 'vi' ? 'Đang tập' : 'In Progress',
      completed: locale == 'vi' ? 'Hoàn thành' : 'Completed',
      mastered: locale == 'vi' ? 'Thành thạo' : 'Mastered',
    };
    return names[status] ?? status;
  }
}
