import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/training_program_library.dart';
import '../domain/models/training_program.dart';

final trainingProgramLibraryProvider = Provider<List<TrainingProgram>>((ref) {
  return TrainingProgramLibrary.getAllPrograms();
});

final activeProgramProvider = StateNotifierProvider<ActiveProgramNotifier, ActiveProgramState>((ref) {
  return ActiveProgramNotifier();
});

class ActiveProgramState {
  final TrainingProgram? program;
  final ProgramProgress? progress;
  final TrainingSession? currentSession;
  final bool isLoading;
  final String? error;

  const ActiveProgramState({
    this.program,
    this.progress,
    this.currentSession,
    this.isLoading = false,
    this.error,
  });

  ActiveProgramState copyWith({
    TrainingProgram? program,
    ProgramProgress? progress,
    TrainingSession? currentSession,
    bool? isLoading,
    String? error,
    bool clearProgram = false,
    bool clearProgress = false,
    bool clearSession = false,
  }) {
    return ActiveProgramState(
      program: clearProgram ? null : (program ?? this.program),
      progress: clearProgress ? null : (progress ?? this.progress),
      currentSession: clearSession ? null : (currentSession ?? this.currentSession),
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get hasActiveProgram => program != null && progress != null;
}

class ActiveProgramNotifier extends StateNotifier<ActiveProgramState> {
  ActiveProgramNotifier() : super(const ActiveProgramState());

  void enrollInProgram(TrainingProgram program) {
    final totalSessions = program.phases.fold<int>(
      0,
      (sum, phase) => sum + phase.sessions.length,
    );

    final progress = ProgramProgress(
      programId: program.id ?? 0,
      totalSessions: totalSessions,
      startedAt: DateTime.now(),
      weeklyProgress: List.generate(
        program.durationWeeks,
        (index) => WeekProgress(
          weekNumber: index + 1,
          completedSessions: 0,
          totalSessions: (totalSessions / program.durationWeeks).ceil(),
          completionRate: 0.0,
        ),
      ),
    );

    final firstSession = _getNextSession(program, progress);

    state = state.copyWith(
      program: program,
      progress: progress,
      currentSession: firstSession,
    );
  }

  void completeCurrentSession() {
    if (state.progress == null || state.currentSession == null) return;

    final progress = state.progress!;
    final completedId = state.currentSession!.id ?? 0;

    final updatedProgress = progress.copyWith(
      completedSessions: progress.completedSessions + 1,
      completedSessionIds: [...progress.completedSessionIds, completedId],
      overallProgress: (progress.completedSessions + 1) / progress.totalSessions,
      completedAt: progress.completedSessions + 1 >= progress.totalSessions
          ? DateTime.now()
          : null,
    );

    final nextSession = _getNextSession(state.program!, updatedProgress);

    state = state.copyWith(
      progress: updatedProgress,
      currentSession: nextSession,
    );
  }

  void skipSession() {
    if (state.program == null || state.progress == null) return;

    final progress = state.progress!;
    final nextSession = _getNextSession(state.program!, progress, skipCurrent: true);

    state = state.copyWith(currentSession: nextSession);
  }

  void startSession(TrainingSession session) {
    state = state.copyWith(currentSession: session);
  }

  void pauseProgram() {
    if (state.program == null) return;
    state = state.copyWith(clearSession: true);
  }

  void resumeProgram() {
    if (state.program == null || state.progress == null) return;
    final nextSession = _getNextSession(state.program!, state.progress!);
    state = state.copyWith(currentSession: nextSession);
  }

  void withdrawFromProgram() {
    state = const ActiveProgramState();
  }

  TrainingSession? _getNextSession(
    TrainingProgram program,
    ProgramProgress progress, {
    bool skipCurrent = false,
  }) {
    final allSessions = <TrainingSession>[];
    for (final phase in program.phases) {
      allSessions.addAll(phase.sessions);
    }

    if (allSessions.isEmpty) return null;

    final completedIds = progress.completedSessionIds;

    for (final session in allSessions) {
      if (!completedIds.contains(session.id ?? 0) && !skipCurrent) {
        return session;
      }
    }

    return allSessions.isNotEmpty ? allSessions.first : null;
  }
}

final upcomingSessionsProvider = Provider<List<TrainingSession>>((ref) {
  final activeState = ref.watch(activeProgramProvider);

  if (!activeState.hasActiveProgram) {
    return [];
  }

  final program = activeState.program!;
  final progress = activeState.progress!;
  final completedIds = progress.completedSessionIds;

  final upcoming = <TrainingSession>[];
  for (final phase in program.phases) {
    for (final session in phase.sessions) {
      if (!completedIds.contains(session.id ?? 0)) {
        upcoming.add(session);
        if (upcoming.length >= 7) return upcoming;
      }
    }
  }

  return upcoming;
});

final programProgressHistoryProvider = StateNotifierProvider<ProgramProgressHistoryNotifier, ProgramProgressHistoryState>((ref) {
  return ProgramProgressHistoryNotifier();
});

class ProgramProgressHistoryState {
  final List<ProgramProgress> completedPrograms;
  final List<ProgramProgress> inProgressPrograms;
  final bool isLoading;

  const ProgramProgressHistoryState({
    this.completedPrograms = const [],
    this.inProgressPrograms = const [],
    this.isLoading = false,
  });
}

class ProgramProgressHistoryNotifier extends StateNotifier<ProgramProgressHistoryState> {
  ProgramProgressHistoryNotifier() : super(const ProgramProgressHistoryState());

  void addInProgressProgram(ProgramProgress progress) {
    state = ProgramProgressHistoryState(
      completedPrograms: state.completedPrograms,
      inProgressPrograms: [...state.inProgressPrograms, progress],
    );
  }

  void markProgramComplete(ProgramProgress progress) {
    state = ProgramProgressHistoryState(
      completedPrograms: [...state.completedPrograms, progress],
      inProgressPrograms: state.inProgressPrograms
          .where((p) => p.programId != progress.programId)
          .toList(),
    );
  }

  void removeProgram(int programId) {
    state = ProgramProgressHistoryState(
      completedPrograms: state.completedPrograms
          .where((p) => p.programId != programId)
          .toList(),
      inProgressPrograms: state.inProgressPrograms
          .where((p) => p.programId != programId)
          .toList(),
    );
  }
}
