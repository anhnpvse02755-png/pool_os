import 'knowledge_enums.dart';

/// Drill difficulty levels
enum DrillDifficulty {
  beginner,
  intermediate,
  advanced,
  expert;

  String get displayName {
    switch (this) {
      case DrillDifficulty.beginner:
        return 'Beginner';
      case DrillDifficulty.intermediate:
        return 'Intermediate';
      case DrillDifficulty.advanced:
        return 'Advanced';
      case DrillDifficulty.expert:
        return 'Expert';
    }
  }

  static DrillDifficulty fromString(String value) {
    return DrillDifficulty.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => DrillDifficulty.beginner,
    );
  }
}

/// Represents a practice drill
class Drill {
  /// Drill code (e.g., "D001")
  final String code;

  /// Drill name in English
  final String name;

  /// Drill name in Vietnamese
  final String nameVi;

  /// Category
  final String category;

  /// Difficulty level
  final DrillDifficulty difficulty;

  /// Estimated time in minutes
  final int timeLimitMinutes;

  /// Brief description
  final String description;

  /// Setup instructions
  final String setup;

  /// Success criteria
  final List<String> successCriteria;

  /// Detailed instructions
  final List<String> instructions;

  /// Difficulty rating (1-5 stars)
  final int difficultyRating;

  /// Tags
  final List<String> tags;

  /// Version
  final String version;

  const Drill({
    required this.code,
    required this.name,
    required this.nameVi,
    required this.category,
    required this.difficulty,
    required this.timeLimitMinutes,
    required this.description,
    required this.setup,
    required this.successCriteria,
    required this.instructions,
    required this.difficultyRating,
    this.tags = const [],
    this.version = '1.0.0',
  });

  factory Drill.fromJson(Map<String, dynamic> json) {
    return Drill(
      code: json['code'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      nameVi: json['nameVi'] as String? ?? '',
      category: json['category'] as String? ?? '',
      difficulty: DrillDifficulty.fromString(
        json['difficulty'] as String? ?? 'beginner',
      ),
      timeLimitMinutes: json['timeLimitMinutes'] as int? ?? 10,
      description: json['description'] as String? ?? '',
      setup: json['setup'] as String? ?? '',
      successCriteria: (json['successCriteria'] as List?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      instructions: (json['instructions'] as List?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      difficultyRating: json['difficultyRating'] as int? ?? 1,
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      version: json['version'] as String? ?? '1.0.0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'nameVi': nameVi,
      'category': category,
      'difficulty': difficulty.name,
      'timeLimitMinutes': timeLimitMinutes,
      'description': description,
      'setup': setup,
      'successCriteria': successCriteria,
      'instructions': instructions,
      'difficultyRating': difficultyRating,
      'tags': tags,
      'version': version,
    };
  }

  String getName(String language) {
    if (language == 'vi' && nameVi.isNotEmpty) {
      return nameVi;
    }
    return name;
  }

  /// Get difficulty as KnowledgeDifficulty
  KnowledgeDifficulty get knowledgeDifficulty {
    switch (difficulty) {
      case DrillDifficulty.beginner:
        return KnowledgeDifficulty.beginner;
      case DrillDifficulty.intermediate:
        return KnowledgeDifficulty.intermediate;
      case DrillDifficulty.advanced:
        return KnowledgeDifficulty.advanced;
      case DrillDifficulty.expert:
        return KnowledgeDifficulty.professional;
    }
  }
}

/// Drill summary for lists
class DrillSummary {
  final String code;
  final String name;
  final String nameVi;
  final String category;
  final DrillDifficulty difficulty;
  final int timeLimitMinutes;
  final int difficultyRating;

  const DrillSummary({
    required this.code,
    required this.name,
    required this.nameVi,
    required this.category,
    required this.difficulty,
    required this.timeLimitMinutes,
    required this.difficultyRating,
  });

  factory DrillSummary.fromDrill(Drill drill) {
    return DrillSummary(
      code: drill.code,
      name: drill.name,
      nameVi: drill.nameVi,
      category: drill.category,
      difficulty: drill.difficulty,
      timeLimitMinutes: drill.timeLimitMinutes,
      difficultyRating: drill.difficultyRating,
    );
  }

  factory DrillSummary.fromJson(Map<String, dynamic> json) {
    return DrillSummary(
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      nameVi: json['nameVi'] as String? ?? '',
      category: json['category'] as String? ?? '',
      difficulty: DrillDifficulty.fromString(
        json['difficulty'] as String? ?? 'beginner',
      ),
      timeLimitMinutes: json['timeLimitMinutes'] as int? ?? 10,
      difficultyRating: json['difficultyRating'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'nameVi': nameVi,
      'category': category,
      'difficulty': difficulty.name,
      'timeLimitMinutes': timeLimitMinutes,
      'difficultyRating': difficultyRating,
    };
  }

  String getName(String language) {
    if (language == 'vi' && nameVi.isNotEmpty) {
      return nameVi;
    }
    return name;
  }
}
