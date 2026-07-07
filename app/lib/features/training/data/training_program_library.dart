import '../domain/models/training_program.dart';

class TrainingProgramLibrary {
  static List<TrainingProgram> getAllPrograms() {
    return [
      _beginnerProgram,
      _intermediateProgram,
      _advancedProgram,
      _skillFocusProgram,
      _tournamentPrepProgram,
    ];
  }

  static TrainingProgram? getProgramById(int id) {
    try {
      return getAllPrograms().firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<TrainingProgram> getProgramsByType(ProgramType type) {
    return getAllPrograms().where((p) => p.type == type).toList();
  }

  static final TrainingProgram _beginnerProgram = TrainingProgram(
    id: 1,
    name: 'Beginner Fundamentals',
    nameVi: 'Nền Tảng Cho Người Mới',
    description: 'Learn the basics of pool including stance, grip, and fundamental shots',
    descriptionVi: 'Học các kiến thức cơ bản về bida bao gồm tư thế, cách cầm cơ và các cú đánh cơ bản',
    type: ProgramType.beginner,
    durationWeeks: 6,
    sessionsPerWeek: 3,
    minutesPerSession: 45,
    difficulty: 1,
    focusAreas: ['stroke', 'stance', 'aiming', 'basic_shots'],
    phases: [
      TrainingPhase(
        name: 'Foundation',
        nameVi: 'Nền tảng',
        weekStart: 1,
        weekEnd: 2,
        description: 'Learn proper stance and grip',
        descriptionVi: 'Học tư thế và cách cầm cơ đúng',
        sessions: _generateWeekSessions(1, 2, ProgramType.beginner),
      ),
      TrainingPhase(
        name: 'Basic Shots',
        nameVi: 'Các cú đánh cơ bản',
        weekStart: 3,
        weekEnd: 4,
        description: 'Master straight shots and basic cuts',
        descriptionVi: 'Thành thạo cú đánh thẳng và cắt cơ bản',
        sessions: _generateWeekSessions(3, 4, ProgramType.beginner),
      ),
      TrainingPhase(
        name: 'Position Play Intro',
        nameVi: 'Giới thiệu điều bi',
        weekStart: 5,
        weekEnd: 6,
        description: 'Introduction to position play',
        descriptionVi: 'Giới thiệu về điều bi',
        sessions: _generateWeekSessions(5, 6, ProgramType.beginner),
      ),
    ],
  );

  static final TrainingProgram _intermediateProgram = TrainingProgram(
    id: 2,
    name: 'Intermediate Skills',
    nameVi: 'Kỹ Năng Trung Bình',
    description: 'Develop consistency and position play mastery',
    descriptionVi: 'Phát triển sự ổn định và thành thạo điều bi',
    type: ProgramType.intermediate,
    durationWeeks: 8,
    sessionsPerWeek: 4,
    minutesPerSession: 60,
    difficulty: 2,
    focusAreas: ['position', 'pattern', 'safety', 'consistency'],
    phases: [
      TrainingPhase(
        name: 'Position Mastery',
        nameVi: 'Thành thạo điều bi',
        weekStart: 1,
        weekEnd: 3,
        description: 'Deep dive into position play',
        descriptionVi: 'Đi sâu vào điều bi',
        sessions: _generateWeekSessions(1, 3, ProgramType.intermediate),
      ),
      TrainingPhase(
        name: 'Pattern Play',
        nameVi: 'Chơi theo quỹ đạo',
        weekStart: 4,
        weekEnd: 6,
        description: 'Learn pattern recognition and run outs',
        descriptionVi: 'Học nhận diện quỹ đạo và chạy bàn',
        sessions: _generateWeekSessions(4, 6, ProgramType.intermediate),
      ),
      TrainingPhase(
        name: 'Safety Game',
        nameVi: 'Chơi an toàn',
        weekStart: 7,
        weekEnd: 8,
        description: 'Develop safety play skills',
        descriptionVi: 'Phát triển kỹ năng chơi an toàn',
        sessions: _generateWeekSessions(7, 8, ProgramType.intermediate),
      ),
    ],
  );

  static final TrainingProgram _advancedProgram = TrainingProgram(
    id: 3,
    name: 'Advanced Tournament Prep',
    nameVi: 'Chuẩn Bị Giải Đấu Nâng Cao',
    description: 'Prepare for competitive play with advanced techniques',
    descriptionVi: 'Chuẩn bị thi đấu với các kỹ thuật nâng cao',
    type: ProgramType.advanced,
    durationWeeks: 12,
    sessionsPerWeek: 5,
    minutesPerSession: 90,
    difficulty: 3,
    focusAreas: ['mental', 'advanced_shots', 'tournament_strategy', 'pressure'],
    phases: [
      TrainingPhase(
        name: 'Advanced Technique',
        nameVi: 'Kỹ thuật nâng cao',
        weekStart: 1,
        weekEnd: 4,
        description: 'Master advanced shots and techniques',
        descriptionVi: 'Thành thạo các cú đánh và kỹ thuật nâng cao',
        sessions: _generateWeekSessions(1, 4, ProgramType.advanced),
      ),
      TrainingPhase(
        name: 'Mental Game',
        nameVi: 'Trò chơi tâm lý',
        weekStart: 5,
        weekEnd: 8,
        description: 'Develop mental strength and focus',
        descriptionVi: 'Phát triển sức mạnh tinh thần và tập trung',
        sessions: _generateWeekSessions(5, 8, ProgramType.advanced),
      ),
      TrainingPhase(
        name: 'Tournament Simulation',
        nameVi: 'Mô phỏng giải đấu',
        weekStart: 9,
        weekEnd: 12,
        description: 'Practice tournament conditions',
        descriptionVi: 'Luyện tập trong điều kiện giải đấu',
        sessions: _generateWeekSessions(9, 12, ProgramType.advanced),
      ),
    ],
  );

  static final TrainingProgram _skillFocusProgram = TrainingProgram(
    id: 4,
    name: 'Break & Run Mastery',
    nameVi: 'Thành Thạo Phá & Chạy',
    description: 'Specialized program for improving break effectiveness and run outs',
    descriptionVi: 'Chương trình chuyên biệt để cải thiện hiệu quả phá bàn và chạy bàn',
    type: ProgramType.skill,
    durationWeeks: 4,
    sessionsPerWeek: 3,
    minutesPerSession: 75,
    difficulty: 2,
    focusAreas: ['break', 'position', 'pattern', 'run_out'],
    phases: [
      TrainingPhase(
        name: 'Break Technique',
        nameVi: 'Kỹ thuật phá',
        weekStart: 1,
        weekEnd: 2,
        description: 'Improve break power and accuracy',
        descriptionVi: 'Cải thiện lực và độ chính xác khi phá',
        sessions: _generateWeekSessions(1, 2, ProgramType.skill),
      ),
      TrainingPhase(
        name: 'Run Out Practice',
        nameVi: 'Luyện chạy bàn',
        weekStart: 3,
        weekEnd: 4,
        description: 'Master full table run outs',
        descriptionVi: 'Thành thạo chạy bàn đầy đủ',
        sessions: _generateWeekSessions(3, 4, ProgramType.skill),
      ),
    ],
  );

  static final TrainingProgram _tournamentPrepProgram = TrainingProgram(
    id: 5,
    name: 'Tournament Ready',
    nameVi: 'Sẵn Sàng Thi Đấu',
    description: '4-week intensive tournament preparation',
    descriptionVi: 'Chuẩn bị thi đấu chuyên sâu 4 tuần',
    type: ProgramType.tournament,
    durationWeeks: 4,
    sessionsPerWeek: 6,
    minutesPerSession: 90,
    difficulty: 3,
    focusAreas: ['match_play', 'mental', 'strategy', 'pressure'],
    phases: [
      TrainingPhase(
        name: 'Physical Prep',
        nameVi: 'Chuẩn bị thể chất',
        weekStart: 1,
        weekEnd: 1,
        description: 'Build endurance and consistency',
        descriptionVi: 'Xây dựng sức bền và sự ổn định',
        sessions: _generateWeekSessions(1, 1, ProgramType.tournament),
      ),
      TrainingPhase(
        name: 'Match Practice',
        nameVi: 'Luyện đấu',
        weekStart: 2,
        weekEnd: 2,
        description: 'Practice match conditions',
        descriptionVi: 'Luyện tập trong điều kiện thi đấu',
        sessions: _generateWeekSessions(2, 2, ProgramType.tournament),
      ),
      TrainingPhase(
        name: 'Mental Prep',
        nameVi: 'Chuẩn bị tâm lý',
        weekStart: 3,
        weekEnd: 3,
        description: 'Mental conditioning',
        descriptionVi: 'Rèn luyện tâm lý',
        sessions: _generateWeekSessions(3, 3, ProgramType.tournament),
      ),
      TrainingPhase(
        name: 'Final Prep',
        nameVi: 'Chuẩn bị cuối',
        weekStart: 4,
        weekEnd: 4,
        description: 'Light practice and rest',
        descriptionVi: 'Tập nhẹ và nghỉ ngơi',
        sessions: _generateWeekSessions(4, 4, ProgramType.tournament),
      ),
    ],
  );

  static List<TrainingSession> _generateWeekSessions(
    int weekStart,
    int weekEnd,
    ProgramType type,
  ) {
    final sessions = <TrainingSession>[];
    var sessionIndex = 0;

    for (var week = weekStart; week <= weekEnd; week++) {
      final daysPerWeek = type == ProgramType.tournament ? 6 : 4;
      final restDays = type == ProgramType.tournament ? [4] : [3];

      for (var day = 1; day <= 7; day++) {
        if (restDays.contains(day)) continue;
        if (sessionIndex >= daysPerWeek * (weekEnd - weekStart + 1)) break;

        final sessionType = _getSessionType(day, type);
        sessions.add(TrainingSession(
          programId: type.hashCode,
          weekNumber: week,
          dayNumber: day,
          title: _getSessionTitle(sessionType, day),
          titleVi: _getSessionTitleVi(sessionType, day),
          type: sessionType,
          durationMinutes: type == ProgramType.beginner ? 45 : 60,
          drills: _getSessionDrills(sessionType),
        ));

        sessionIndex++;
      }
    }

    return sessions;
  }

  static SessionType _getSessionType(int day, ProgramType type) {
    if (day == 1) return SessionType.warmUp;
    if (day == 2) return SessionType.drill;
    if (day == 3) return SessionType.practice;
    if (day == 5) return SessionType.drill;
    if (day == 6) return SessionType.match;
    if (day == 7) return SessionType.review;
    return SessionType.practice;
  }

  static String _getSessionTitle(SessionType type, int day) {
    return switch (type) {
      SessionType.warmUp => 'Warm Up & Fundamentals',
      SessionType.drill => 'Technical Drills',
      SessionType.practice => 'Practice Session',
      SessionType.match => 'Match Play',
      SessionType.review => 'Review & Analysis',
      SessionType.rest => 'Rest Day',
    };
  }

  static String _getSessionTitleVi(SessionType type, int day) {
    return switch (type) {
      SessionType.warmUp => 'Khởi động & Cơ bản',
      SessionType.drill => 'Bài tập kỹ thuật',
      SessionType.practice => 'Luyện tập',
      SessionType.match => 'Thi đấu',
      SessionType.review => 'Ôn tập & Phân tích',
      SessionType.rest => 'Nghỉ ngơi',
    };
  }

  static List<String> _getSessionDrills(SessionType type) {
    return switch (type) {
      SessionType.warmUp => [
        'Straight Shot Drill',
        'Basic Aiming',
        'Stance Practice',
      ],
      SessionType.drill => [
        'Position Circle Drill',
        'Cut Shot Drill',
        'Speed Control Drill',
      ],
      SessionType.practice => [
        'Free Practice',
        'Pattern Play',
        'Shot Making',
      ],
      SessionType.match => [
        'Race to 3',
        'Pressure Practice',
        'Match Simulation',
      ],
      SessionType.review => [
        'Session Analysis',
        'Video Review',
        'Goal Setting',
      ],
      SessionType.rest => [],
    };
  }
}
