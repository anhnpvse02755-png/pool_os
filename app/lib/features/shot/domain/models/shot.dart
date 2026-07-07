class Shot {
  final int? id;
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

  Shot({
    this.id,
    required this.rackId,
    required this.shotNumber,
    required this.shotType,
    required this.difficulty,
    required this.result,
    this.positionQuality,
    this.decision,
    this.confidence,
    this.playerNote,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Shot copyWith({
    int? id,
    int? rackId,
    int? shotNumber,
    String? shotType,
    String? difficulty,
    String? result,
    String? positionQuality,
    String? decision,
    String? confidence,
    String? playerNote,
    DateTime? createdAt,
  }) {
    return Shot(
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

  bool get isMade => result == 'made';
}

class ShotTypes {
  static const String breakShot = 'break';
  static const String openingShot = 'opening';
  static const String normalShot = 'normal';
  static const String safetyShot = 'safety';
  static const String jumpShot = 'jump';
  static const String bankShot = 'bank';
  static const String masse = 'masse';

  static const List<String> all = [
    breakShot,
    openingShot,
    normalShot,
    safetyShot,
    jumpShot,
    bankShot,
    masse,
  ];
}

class ShotDifficulty {
  static const String easy = 'easy';
  static const String medium = 'medium';
  static const String hard = 'hard';
  static const String extreme = 'extreme';

  static const List<String> all = [easy, medium, hard, extreme];
}

class ShotResult {
  static const String made = 'made';
  static const String missed = 'missed';
  static const String scratch = 'scratch';
  static const String foul = 'foul';

  static const List<String> all = [made, missed, scratch, foul];
}

class PositionQuality {
  static const String perfect = 'perfect';
  static const String good = 'good';
  static const String playable = 'playable';
  static const String recovery = 'recovery';
  static const String bad = 'bad';

  static const List<String> all = [perfect, good, playable, recovery, bad];
}

class ShotConfidence {
  static const String veryConfident = 'very_confident';
  static const String confident = 'confident';
  static const String unsure = 'unsure';
  static const String guessing = 'guessing';

  static const List<String> all = [veryConfident, confident, unsure, guessing];
}
