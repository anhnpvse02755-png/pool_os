class Session {
  final int? id;
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

  Session({
    this.id,
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
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Session copyWith({
    int? id,
    String? sessionType,
    String? location,
    String? table,
    String? cloth,
    String? balls,
    String? trainingGoal,
    String? notes,
    String? weather,
    DateTime? startedAt,
    DateTime? finishedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Session(
      id: id ?? this.id,
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

  bool get isActive => finishedAt == null;

  Duration get duration {
    final end = finishedAt ?? DateTime.now();
    return end.difference(startedAt);
  }
}

class SessionTypes {
  static const String practice = 'practice';
  static const String match = 'match';
  static const String tournament = 'tournament';
  static const String training = 'training';

  static const List<String> all = [practice, match, tournament, training];
}
