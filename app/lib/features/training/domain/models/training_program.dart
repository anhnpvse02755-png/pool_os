class TrainingProgram {
  final int? id;
  final String name;
  final String nameVi;
  final String description;
  final String descriptionVi;
  final ProgramType type;
  final int durationWeeks;
  final int sessionsPerWeek;
  final int minutesPerSession;
  final List<TrainingPhase> phases;
  final List<String> focusAreas;
  final int difficulty;
  final bool isCustom;

  TrainingProgram({
    this.id,
    required this.name,
    required this.nameVi,
    required this.description,
    required this.descriptionVi,
    required this.type,
    this.durationWeeks = 4,
    this.sessionsPerWeek = 3,
    this.minutesPerSession = 60,
    this.phases = const [],
    this.focusAreas = const [],
    this.difficulty = 1,
    this.isCustom = false,
  });

  TrainingProgram copyWith({
    int? id,
    String? name,
    String? nameVi,
    String? description,
    String? descriptionVi,
    ProgramType? type,
    int? durationWeeks,
    int? sessionsPerWeek,
    int? minutesPerSession,
    List<TrainingPhase>? phases,
    List<String>? focusAreas,
    int? difficulty,
    bool? isCustom,
  }) {
    return TrainingProgram(
      id: id ?? this.id,
      name: name ?? this.name,
      nameVi: nameVi ?? this.nameVi,
      description: description ?? this.description,
      descriptionVi: descriptionVi ?? this.descriptionVi,
      type: type ?? this.type,
      durationWeeks: durationWeeks ?? this.durationWeeks,
      sessionsPerWeek: sessionsPerWeek ?? this.sessionsPerWeek,
      minutesPerSession: minutesPerSession ?? this.minutesPerSession,
      phases: phases ?? this.phases,
      focusAreas: focusAreas ?? this.focusAreas,
      difficulty: difficulty ?? this.difficulty,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  int get totalSessions => durationWeeks * sessionsPerWeek;

  int get totalMinutes => totalSessions * minutesPerSession;
}

class TrainingPhase {
  final String name;
  final String nameVi;
  final int weekStart;
  final int weekEnd;
  final String description;
  final String descriptionVi;
  final List<TrainingSession> sessions;

  TrainingPhase({
    required this.name,
    required this.nameVi,
    required this.weekStart,
    required this.weekEnd,
    required this.description,
    required this.descriptionVi,
    this.sessions = const [],
  });

  int get durationWeeks => weekEnd - weekStart + 1;
}

class TrainingSession {
  final int? id;
  final int programId;
  final int weekNumber;
  final int dayNumber;
  final String title;
  final String titleVi;
  final SessionType type;
  final int durationMinutes;
  final List<String> drills;
  final List<String> exercises;
  final String? notes;
  final String? notesVi;
  final bool isCompleted;
  final DateTime? completedAt;

  TrainingSession({
    this.id,
    required this.programId,
    required this.weekNumber,
    required this.dayNumber,
    required this.title,
    required this.titleVi,
    required this.type,
    this.durationMinutes = 60,
    this.drills = const [],
    this.exercises = const [],
    this.notes,
    this.notesVi,
    this.isCompleted = false,
    this.completedAt,
  });

  TrainingSession copyWith({
    int? id,
    int? programId,
    int? weekNumber,
    int? dayNumber,
    String? title,
    String? titleVi,
    SessionType? type,
    int? durationMinutes,
    List<String>? drills,
    List<String>? exercises,
    String? notes,
    String? notesVi,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return TrainingSession(
      id: id ?? this.id,
      programId: programId ?? this.programId,
      weekNumber: weekNumber ?? this.weekNumber,
      dayNumber: dayNumber ?? this.dayNumber,
      title: title ?? this.title,
      titleVi: titleVi ?? this.titleVi,
      type: type ?? this.type,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      drills: drills ?? this.drills,
      exercises: exercises ?? this.exercises,
      notes: notes ?? this.notes,
      notesVi: notesVi ?? this.notesVi,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  String get dayLabel {
    return switch (dayNumber) {
      1 => 'Monday',
      2 => 'Tuesday',
      3 => 'Wednesday',
      4 => 'Thursday',
      5 => 'Friday',
      6 => 'Saturday',
      7 => 'Sunday',
      _ => 'Day $dayNumber',
    };
  }
}

class ProgramProgress {
  final int? id;
  final int programId;
  final int currentWeek;
  final int currentSession;
  final int completedSessions;
  final int totalSessions;
  final double overallProgress;
  final DateTime startedAt;
  final DateTime? completedAt;
  final List<int> completedSessionIds;
  final List<WeekProgress> weeklyProgress;

  ProgramProgress({
    this.id,
    required this.programId,
    this.currentWeek = 1,
    this.currentSession = 0,
    this.completedSessions = 0,
    required this.totalSessions,
    this.overallProgress = 0.0,
    required this.startedAt,
    this.completedAt,
    this.completedSessionIds = const [],
    this.weeklyProgress = const [],
  });

  ProgramProgress copyWith({
    int? id,
    int? programId,
    int? currentWeek,
    int? currentSession,
    int? completedSessions,
    int? totalSessions,
    double? overallProgress,
    DateTime? startedAt,
    DateTime? completedAt,
    List<int>? completedSessionIds,
    List<WeekProgress>? weeklyProgress,
  }) {
    return ProgramProgress(
      id: id ?? this.id,
      programId: programId ?? this.programId,
      currentWeek: currentWeek ?? this.currentWeek,
      currentSession: currentSession ?? this.currentSession,
      completedSessions: completedSessions ?? this.completedSessions,
      totalSessions: totalSessions ?? this.totalSessions,
      overallProgress: overallProgress ?? this.overallProgress,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      completedSessionIds: completedSessionIds ?? this.completedSessionIds,
      weeklyProgress: weeklyProgress ?? this.weeklyProgress,
    );
  }

  bool get isComplete => completedSessions >= totalSessions;

  int get sessionsRemaining => totalSessions - completedSessions;

  DateTime? get estimatedCompletion {
    if (isComplete) return completedAt;
    final remaining = sessionsRemaining;
    final daysRemaining = (remaining / 7).ceil();
    return DateTime.now().add(Duration(days: daysRemaining));
  }
}

class WeekProgress {
  final int weekNumber;
  final int completedSessions;
  final int totalSessions;
  final double completionRate;
  final List<int> sessionIds;

  WeekProgress({
    required this.weekNumber,
    required this.completedSessions,
    required this.totalSessions,
    required this.completionRate,
    this.sessionIds = const [],
  });
}

enum ProgramType {
  beginner,
  intermediate,
  advanced,
  skill,
  tournament,
  custom,
}

enum SessionType {
  warmUp,
  drill,
  practice,
  match,
  review,
  rest,
}

extension ProgramTypeExtension on ProgramType {
  String get name {
    return switch (this) {
      ProgramType.beginner => 'beginner',
      ProgramType.intermediate => 'intermediate',
      ProgramType.advanced => 'advanced',
      ProgramType.skill => 'skill',
      ProgramType.tournament => 'tournament',
      ProgramType.custom => 'custom',
    };
  }

  String getNameVi() {
    return switch (this) {
      ProgramType.beginner => 'Người mới',
      ProgramType.intermediate => 'Trung bình',
      ProgramType.advanced => 'Nâng cao',
      ProgramType.skill => 'Kỹ năng',
      ProgramType.tournament => 'Giải đấu',
      ProgramType.custom => 'Tùy chỉnh',
    };
  }
}

extension SessionTypeExtension on SessionType {
  String get name {
    return switch (this) {
      SessionType.warmUp => 'warm_up',
      SessionType.drill => 'drill',
      SessionType.practice => 'practice',
      SessionType.match => 'match',
      SessionType.review => 'review',
      SessionType.rest => 'rest',
    };
  }

  String getNameVi() {
    return switch (this) {
      SessionType.warmUp => 'Khởi động',
      SessionType.drill => 'Bài tập',
      SessionType.practice => 'Luyện tập',
      SessionType.match => 'Đấu',
      SessionType.review => 'Ôn tập',
      SessionType.rest => 'Nghỉ ngơi',
    };
  }
}
