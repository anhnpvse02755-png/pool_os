class Player {
  final int? id;
  final String name;
  final String dominantHand;
  final String language;
  final String measurementSystem;
  final String theme;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Player({
    this.id,
    required this.name,
    required this.dominantHand,
    required this.language,
    required this.measurementSystem,
    required this.theme,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Player copyWith({
    int? id,
    String? name,
    String? dominantHand,
    String? language,
    String? measurementSystem,
    String? theme,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Player(
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

  String get initials {
    if (name.isEmpty) return 'P';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}

enum SkillLevel {
  beginner,
  intermediate,
  advanced,
  expert,
  professional;

  String get displayName {
    switch (this) {
      case SkillLevel.beginner:
        return 'Beginner';
      case SkillLevel.intermediate:
        return 'Intermediate';
      case SkillLevel.advanced:
        return 'Advanced';
      case SkillLevel.expert:
        return 'Expert';
      case SkillLevel.professional:
        return 'Professional';
    }
  }
}
