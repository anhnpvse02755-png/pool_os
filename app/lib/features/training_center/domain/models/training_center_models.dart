// Task 09 — Training Center domain models.
//
// Pure Dart, no persistence annotations (mirrors the drill/ and session/
// features). The repository maps these to/from Drift rows. Training Center is
// a hand-entered practice log: the player picks a drill, sets a rep target,
// records Đạt (success) / Miss, and saves. It is completely separate from the
// LOCKED RFC-301/302 recording pipeline (Session/Match/Rack/Shot/Event) — a
// TrainingSession here is NOT a recording Session.

/// A bài tập do người chơi tự tạo (Phần 3 — Custom Drill). Reusable: once
/// created it appears in the library alongside the built-in [DrillLibrary]
/// drills and can be run in any training session.
class CustomDrill {
  final int? id;
  final String name;

  /// One of [DrillCategory] codes (Claude-designed categories, reused).
  final String category;

  /// Mục tiêu — số lần muốn thực hiện.
  final int targetReps;

  /// Điều kiện thành công — người chơi tự định nghĩa (text tự do, có thể null).
  final String? successCriteria;

  final DateTime createdAt;

  const CustomDrill({
    this.id,
    required this.name,
    required this.category,
    this.targetReps = 100,
    this.successCriteria,
    required this.createdAt,
  });

  /// Stable key used by favorites / recent / progress so a custom drill and a
  /// built-in drill never collide. Built-in drills key on their code.
  String get drillKey => 'custom:$id';

  CustomDrill copyWith({
    int? id,
    String? name,
    String? category,
    int? targetReps,
    String? successCriteria,
    DateTime? createdAt,
  }) {
    return CustomDrill(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      targetReps: targetReps ?? this.targetReps,
      successCriteria: successCriteria ?? this.successCriteria,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// A buổi luyện tập (Phần 2 — Training Session). Container for one or more
/// [DrillRun]s. Open while the player is practising; [completedAt] is set on
/// save/finish.
class TrainingSession {
  final int? id;
  final int? playerId;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String? notes;

  const TrainingSession({
    this.id,
    this.playerId,
    required this.startedAt,
    this.completedAt,
    this.notes,
  });

  bool get isComplete => completedAt != null;

  TrainingSession copyWith({
    int? id,
    int? playerId,
    DateTime? startedAt,
    DateTime? completedAt,
    String? notes,
  }) {
    return TrainingSession(
      id: id ?? this.id,
      playerId: playerId ?? this.playerId,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
    );
  }
}

/// One drill executed inside a [TrainingSession] (Phần 2). Records the target,
/// how many attempts were made, and how many were Đạt (success). A single
/// session can hold many runs — this is the "nhiều Drill trong một Session".
///
/// [drillCode] links to a built-in [DrillLibrary] drill; [customDrillId] links
/// to a [CustomDrill]. Exactly one is set. Both are soft references (no FK) so
/// deleting a custom drill never cascades away historical practice data.
class DrillRun {
  final int? id;
  final int sessionId;
  final String? drillCode;
  final int? customDrillId;
  final String? knowledgeEntryId;

  /// Denormalised so history survives even if the source drill is renamed or
  /// deleted (mirrors how DrillSession stores drillName in the drill feature).
  final String drillName;
  final String category;
  final int targetReps;
  final int attempts;
  final int successes;
  final DateTime createdAt;

  const DrillRun({
    this.id,
    required this.sessionId,
    this.drillCode,
    this.customDrillId,
    this.knowledgeEntryId,
    required this.drillName,
    required this.category,
    required this.targetReps,
    this.attempts = 0,
    this.successes = 0,
    required this.createdAt,
  });

  /// Đạt count (alias for readability at call sites).
  int get misses => (attempts - successes).clamp(0, attempts);

  /// Success rate 0.0–1.0. Zero attempts => 0.0 (no fabricated data).
  double get successRate => attempts == 0 ? 0.0 : successes / attempts;

  /// Whether the rep target has been reached.
  bool get reachedTarget => attempts >= targetReps;

  /// Stable progress/favorite key — matches [CustomDrill.drillKey] for custom
  /// drills, or the built-in drill code otherwise.
  String get drillKey =>
      customDrillId != null ? 'custom:$customDrillId' : (drillCode ?? '');

  DrillRun copyWith({
    int? id,
    int? sessionId,
    String? drillCode,
    int? customDrillId,
    String? knowledgeEntryId,
    String? drillName,
    String? category,
    int? targetReps,
    int? attempts,
    int? successes,
    DateTime? createdAt,
  }) {
    return DrillRun(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      drillCode: drillCode ?? this.drillCode,
      customDrillId: customDrillId ?? this.customDrillId,
      knowledgeEntryId: knowledgeEntryId ?? this.knowledgeEntryId,
      drillName: drillName ?? this.drillName,
      category: category ?? this.category,
      targetReps: targetReps ?? this.targetReps,
      attempts: attempts ?? this.attempts,
      successes: successes ?? this.successes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class TrainingCompletion {
  final int sessionId;
  final List<DrillRun> runs;

  const TrainingCompletion({required this.sessionId, required this.runs});

  int get attempts => runs.fold(0, (sum, run) => sum + run.attempts);
  int get successes => runs.fold(0, (sum, run) => sum + run.successes);
  double get successRate => attempts == 0 ? 0 : successes / attempts;
}

/// Progress comparison for one drill or category (Phần 4 — Progress). Pure
/// display data derived from [DrillRun] history — no AI, no recommendation.
/// Compares an earlier window's success rate to a later window's.
class DrillProgress {
  final String label; // drill name or category name
  final String drillKey; // key this progress was computed for
  final double previousRate; // earlier window success rate (0.0–1.0)
  final double currentRate; // later window success rate (0.0–1.0)
  final int previousAttempts;
  final int currentAttempts;

  const DrillProgress({
    required this.label,
    required this.drillKey,
    required this.previousRate,
    required this.currentRate,
    required this.previousAttempts,
    required this.currentAttempts,
  });

  /// Signed change in percentage points (current − previous). Positive = better.
  double get deltaPoints => (currentRate - previousRate) * 100;

  /// True only when both windows have data — otherwise the UI shows "chưa đủ
  /// dữ liệu để so sánh" instead of a misleading arrow.
  bool get hasComparison => previousAttempts > 0 && currentAttempts > 0;
}
