// EPIC 03 — Training System
//
// Domain models for the 3 new Training entities introduced by Epic 03:
// Lesson, CoachNote, TrainingProgram. Pure Dart, no Drift annotations.
//
// All other domain models (Drill, DrillSession, Goal, GoalProgress,
// TrainingCenterSession, etc.) live in their owning feature (drill/,
// goal_center/, training_center/). This file is the home only of the
// newly-introduced Training entities that are not covered by an
// existing feature.

import 'dart:convert' as convert;

/// A static learning unit. Spec §6 — Lesson is non-adaptive; only the
/// player's [completedAt] timestamp is mutable, the rest is seeded.
/// Title, description, objectives, required drills, references.
class Lesson {
  final int? id;
  final String code;
  final String title;
  final String description;

  /// 3..5 short outcome statements.
  final List<String> objectives;

  /// drillCode[] references into DrillLibrary.
  final List<String> requiredDrills;

  /// Free-form reference links / book titles.
  final List<String> references;
  final String? difficulty;
  final String? skillLevel;
  final int orderIndex;
  final DateTime createdAt;

  /// Per-player completion. Stored separately from the lesson itself
  /// (table LessonCompletions in the repository) so the seed lesson
  /// table is read-only after publication.
  final DateTime? completedAt;

  const Lesson({
    this.id,
    required this.code,
    required this.title,
    required this.description,
    this.objectives = const [],
    this.requiredDrills = const [],
    this.references = const [],
    this.difficulty,
    this.skillLevel,
    this.orderIndex = 0,
    required this.createdAt,
    this.completedAt,
  });

  bool get isComplete => completedAt != null;

  Lesson copyWith({
    int? id,
    String? code,
    String? title,
    String? description,
    List<String>? objectives,
    List<String>? requiredDrills,
    List<String>? references,
    String? difficulty,
    String? skillLevel,
    int? orderIndex,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Lesson(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      description: description ?? this.description,
      objectives: objectives ?? this.objectives,
      requiredDrills: requiredDrills ?? this.requiredDrills,
      references: references ?? this.references,
      difficulty: difficulty ?? this.difficulty,
      skillLevel: skillLevel ?? this.skillLevel,
      orderIndex: orderIndex ?? this.orderIndex,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

/// Coach / self note attached to a session or floating.
/// Categories per spec §7 — Coach Notes.
enum CoachNoteCategory {
  /// Today's mistakes.
  mistake,

  /// Things to improve.
  improve,

  /// Practice observations.
  observation,

  /// Coach comments.
  coachComment,
}

extension CoachNoteCategoryInfo on CoachNoteCategory {
  String get code {
    switch (this) {
      case CoachNoteCategory.mistake:
        return 'mistake';
      case CoachNoteCategory.improve:
        return 'improve';
      case CoachNoteCategory.observation:
        return 'observation';
      case CoachNoteCategory.coachComment:
        return 'coach_comment';
    }
  }

  String get labelKey => 'ts_coach_note_$code';

  static CoachNoteCategory fromCode(String code) {
    return CoachNoteCategory.values.firstWhere(
      (c) => c.code == code,
      orElse: () => CoachNoteCategory.observation,
    );
  }
}

class CoachNote {
  final int? id;
  final int? playerId;

  /// Soft reference to a recording [Sessions] row, optional.
  /// A note with no session is a "floating" note.
  final int? sessionId;
  final CoachNoteCategory category;
  final String body;
  final DateTime createdAt;

  const CoachNote({
    this.id,
    this.playerId,
    this.sessionId,
    required this.category,
    required this.body,
    required this.createdAt,
  });

  CoachNote copyWith({
    int? id,
    int? playerId,
    int? sessionId,
    CoachNoteCategory? category,
    String? body,
    DateTime? createdAt,
  }) {
    return CoachNote(
      id: id ?? this.id,
      playerId: playerId ?? this.playerId,
      sessionId: sessionId ?? this.sessionId,
      category: category ?? this.category,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Difficulty of a Personal Training Program.
enum ProgramDifficulty {
  beginner,
  intermediate,
  advanced,
  custom,
}

extension ProgramDifficultyInfo on ProgramDifficulty {
  String get code {
    switch (this) {
      case ProgramDifficulty.beginner:
        return 'beginner';
      case ProgramDifficulty.intermediate:
        return 'intermediate';
      case ProgramDifficulty.advanced:
        return 'advanced';
      case ProgramDifficulty.custom:
        return 'custom';
    }
  }

  String get labelKey => 'ts_program_$code';

  static ProgramDifficulty fromCode(String code) {
    return ProgramDifficulty.values.firstWhere(
      (d) => d.code == code,
      orElse: () => ProgramDifficulty.custom,
    );
  }
}

/// A single drill within a [ProgramDay].
class ProgramDrill {
  final String drillCode;
  final int targetReps;
  final String? note;

  const ProgramDrill({
    required this.drillCode,
    this.targetReps = 10,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'drillCode': drillCode,
        'targetReps': targetReps,
        if (note != null) 'note': note,
      };

  static ProgramDrill fromJson(Map<String, dynamic> json) => ProgramDrill(
        drillCode: json['drillCode'] as String,
        targetReps: (json['targetReps'] as num?)?.toInt() ?? 10,
        note: json['note'] as String?,
      );
}

/// One day inside a [ProgramWeek].
class ProgramDay {
  final int dayIndex; // 1..7
  final String title;
  final List<ProgramDrill> drills;

  const ProgramDay({
    required this.dayIndex,
    this.title = '',
    this.drills = const [],
  });

  Map<String, dynamic> toJson() => {
        'dayIndex': dayIndex,
        'title': title,
        'drills': drills.map((d) => d.toJson()).toList(),
      };

  static ProgramDay fromJson(Map<String, dynamic> json) => ProgramDay(
        dayIndex: (json['dayIndex'] as num).toInt(),
        title: (json['title'] as String?) ?? '',
        drills: ((json['drills'] as List<dynamic>?) ?? const [])
            .map((e) => ProgramDrill.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// One week inside a [TrainingProgramHierarchy].
class ProgramWeek {
  final int weekIndex; // 1..N
  final String title;
  final List<ProgramDay> days;

  const ProgramWeek({
    required this.weekIndex,
    this.title = '',
    this.days = const [],
  });

  Map<String, dynamic> toJson() => {
        'weekIndex': weekIndex,
        'title': title,
        'days': days.map((d) => d.toJson()).toList(),
      };

  static ProgramWeek fromJson(Map<String, dynamic> json) => ProgramWeek(
        weekIndex: (json['weekIndex'] as num).toInt(),
        title: (json['title'] as String?) ?? '',
        days: ((json['days'] as List<dynamic>?) ?? const [])
            .map((e) => ProgramDay.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// Encoded as JSON in the [TrainingPrograms.hierarchy] column.
/// Program -> Week -> Day -> Practice Session -> Drills
/// hierarchy from spec §5. "Practice Session" is a template inside
/// the program (no real recording); the drills are references into
/// the DrillLibrary.
class TrainingProgramHierarchy {
  final List<ProgramWeek> weeks;

  const TrainingProgramHierarchy({this.weeks = const []});

  Map<String, dynamic> toJson() => {
        'weeks': weeks.map((w) => w.toJson()).toList(),
      };

  static TrainingProgramHierarchy fromJson(Map<String, dynamic> json) =>
      TrainingProgramHierarchy(
        weeks: ((json['weeks'] as List<dynamic>?) ?? const [])
            .map((e) => ProgramWeek.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  static TrainingProgramHierarchy fromJsonString(String raw) {
    try {
      final decoded = raw.isEmpty
          ? <String, dynamic>{}
          : (convert.jsonDecode(raw) as Map<String, dynamic>);
      return fromJson(decoded);
    } catch (_) {
      return const TrainingProgramHierarchy();
    }
  }

  String toJsonString() => convert.jsonEncode(toJson());

  int get totalDrills =>
      weeks.fold(0, (acc, w) => acc + w.days.fold(0, (a, d) => a + d.drills.length));
}

/// Top-level Training Program. Spec §5 — Beginner / Intermediate /
/// Advanced / Custom. Seeded programs (Beginner..Advanced) have
/// [isSeed] = true and are read-only; Custom programs are player-
/// authored.
class TrainingProgram {
  final int? id;
  final int? playerId;
  final String code;
  final String title;
  final String description;
  final ProgramDifficulty difficulty;
  final int weekCount;
  final TrainingProgramHierarchy hierarchy;
  final bool isSeed;
  final DateTime createdAt;

  const TrainingProgram({
    this.id,
    this.playerId,
    required this.code,
    required this.title,
    required this.description,
    this.difficulty = ProgramDifficulty.custom,
    this.weekCount = 0,
    this.hierarchy = const TrainingProgramHierarchy(),
    this.isSeed = false,
    required this.createdAt,
  });

  TrainingProgram copyWith({
    int? id,
    int? playerId,
    String? code,
    String? title,
    String? description,
    ProgramDifficulty? difficulty,
    int? weekCount,
    TrainingProgramHierarchy? hierarchy,
    bool? isSeed,
    DateTime? createdAt,
  }) {
    return TrainingProgram(
      id: id ?? this.id,
      playerId: playerId ?? this.playerId,
      code: code ?? this.code,
      title: title ?? this.title,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      weekCount: weekCount ?? this.weekCount,
      hierarchy: hierarchy ?? this.hierarchy,
      isSeed: isSeed ?? this.isSeed,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Per-player enrollment into a [TrainingProgram].
/// Tracks week-by-week completion so the UI can show progress.
class TrainingProgramEnrollment {
  final int? id;
  final int? playerId;
  final int? programId;
  final int currentWeek;
  final List<int> completedWeeks;
  final DateTime startedAt;
  final DateTime? completedAt;

  const TrainingProgramEnrollment({
    this.id,
    this.playerId,
    required this.programId,
    this.currentWeek = 1,
    this.completedWeeks = const [],
    required this.startedAt,
    this.completedAt,
  });

  bool get isComplete => completedAt != null;

  double get progressRatio {
    final total = completedWeeks.length;
    final all = currentWeek > total ? currentWeek : total + 1;
    return all <= 0 ? 0.0 : (total / all).clamp(0.0, 1.0).toDouble();
  }

  TrainingProgramEnrollment copyWith({
    int? id,
    int? playerId,
    int? programId,
    int? currentWeek,
    List<int>? completedWeeks,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return TrainingProgramEnrollment(
      id: id ?? this.id,
      playerId: playerId ?? this.playerId,
      programId: programId ?? this.programId,
      currentWeek: currentWeek ?? this.currentWeek,
      completedWeeks: completedWeeks ?? this.completedWeeks,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
    return TrainingProgramEnrollment(
      id: id ?? this.id,
      playerId: playerId ?? this.playerId,
      programId: programId ?? this.programId,
      currentWeek: currentWeek ?? this.currentWeek,
      completedWeeks: completedWeeks ?? this.completedWeeks,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

// Required for jsonDecode used by TrainingProgramHierarchy.fromJsonString.
// const _jsonDecode = null;
// ignore: unused_element
// const _ = _jsonDecode;