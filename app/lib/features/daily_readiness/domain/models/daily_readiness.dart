class DailyReadinessModel {
  final int? id;
  final String date;
  final double? sleepHours;
  final int? energyLevel;
  final int? focusLevel;
  final int? confidenceLevel;
  final String? mood;
  final int? stressLevel;
  final int? shoulderCondition; // 1-10 scale
  final int? wristCondition; // 1-10 scale (new)
  final int? backCondition; // 1-10 scale (new)
  final String? equipment;
  final String? playingLocation;
  final String? tableSpeed;
  final String? todayGoal;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  DailyReadinessModel({
    this.id,
    required this.date,
    this.sleepHours,
    this.energyLevel,
    this.focusLevel,
    this.confidenceLevel,
    this.mood,
    this.stressLevel,
    this.shoulderCondition,
    this.wristCondition,
    this.backCondition,
    this.equipment,
    this.playingLocation,
    this.tableSpeed,
    this.todayGoal,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  DailyReadinessModel copyWith({
    int? id,
    String? date,
    double? sleepHours,
    int? energyLevel,
    int? focusLevel,
    int? confidenceLevel,
    String? mood,
    int? stressLevel,
    int? shoulderCondition,
    int? wristCondition,
    int? backCondition,
    String? equipment,
    String? playingLocation,
    String? tableSpeed,
    String? todayGoal,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyReadinessModel(
      id: id ?? this.id,
      date: date ?? this.date,
      sleepHours: sleepHours ?? this.sleepHours,
      energyLevel: energyLevel ?? this.energyLevel,
      focusLevel: focusLevel ?? this.focusLevel,
      confidenceLevel: confidenceLevel ?? this.confidenceLevel,
      mood: mood ?? this.mood,
      stressLevel: stressLevel ?? this.stressLevel,
      shoulderCondition: shoulderCondition ?? this.shoulderCondition,
      wristCondition: wristCondition ?? this.wristCondition,
      backCondition: backCondition ?? this.backCondition,
      equipment: equipment ?? this.equipment,
      playingLocation: playingLocation ?? this.playingLocation,
      tableSpeed: tableSpeed ?? this.tableSpeed,
      todayGoal: todayGoal ?? this.todayGoal,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Ready Score - mental/physical readiness based on energy, focus, confidence, and stress
  int get readyScore {
    int score = 0;
    int count = 0;
    if (energyLevel != null) { score += energyLevel!; count++; }
    if (focusLevel != null) { score += focusLevel!; count++; }
    if (confidenceLevel != null) { score += confidenceLevel!; count++; }
    if (stressLevel != null) { score += (10 - stressLevel!); count++; }
    return count > 0 ? (score / count).round() : 0;
  }

  /// Recovery Score - physical recovery based on sleep and body conditions
  int get recoveryScore {
    int score = 0;
    int count = 0;
    
    // Sleep is weighted heavily (0-12 hours mapped to 0-10)
    if (sleepHours != null) {
      score += (sleepHours! * 10 / 12).clamp(0, 10).round();
      count++;
    }
    
    // Physical conditions
    if (shoulderCondition != null) { score += shoulderCondition!; count++; }
    if (wristCondition != null) { score += wristCondition!; count++; }
    if (backCondition != null) { score += backCondition!; count++; }
    
    return count > 0 ? (score / count).round() : 0;
  }

  /// Overall Score - combination of ready and recovery
  int get overallScore => ((readyScore + recoveryScore) / 2).round();

  /// Coach Note - generated advice based on the data
  String get coachNote {
    final notes = <String>[];
    
    // Sleep analysis
    if (sleepHours != null) {
      if (sleepHours! < 6) {
        notes.add('Prioritize rest - less than 6 hours of sleep detected.');
      } else if (sleepHours! >= 8) {
        notes.add('Great sleep! You should be well-rested.');
      }
    }
    
    // Energy analysis
    if (energyLevel != null && energyLevel! < 4) {
      notes.add('Low energy detected. Consider lighter practice or a rest day.');
    } else if (energyLevel != null && energyLevel! >= 8) {
      notes.add('High energy! Great day for intense practice.');
    }
    
    // Stress analysis
    if (stressLevel != null && stressLevel! > 7) {
      notes.add('High stress may affect focus. Try breathing exercises before playing.');
    }
    
    // Physical condition analysis
    final physicalIssues = <String>[];
    if (shoulderCondition != null && shoulderCondition! < 5) {
      physicalIssues.add('shoulder');
    }
    if (wristCondition != null && wristCondition! < 5) {
      physicalIssues.add('wrist');
    }
    if (backCondition != null && backCondition! < 5) {
      physicalIssues.add('back');
    }
    if (physicalIssues.isNotEmpty) {
      notes.add('Be careful with your ${physicalIssues.join(' and ')} today.');
    }
    
    // Overall recommendation
    if (notes.isEmpty) {
      if (overallScore >= 7) {
        notes.add('You\'re in great shape to play today!');
      } else if (overallScore >= 5) {
        notes.add('Moderate readiness. Focus on fundamentals today.');
      } else {
        notes.add('Consider light practice or rest today.');
      }
    }
    
    return notes.join(' ');
  }

  bool get isComplete =>
      sleepHours != null &&
      energyLevel != null &&
      focusLevel != null &&
      confidenceLevel != null &&
      mood != null;
}
