import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/foundation/application_context.dart';
import '../../../application/foundation/application_handlers.dart';
import '../../../framework/command/command_executor.dart';
import '../../../shared/foundation/identifier.dart';
import '../../../shared/foundation/result.dart';
import '../../../shared/foundation/value_object.dart';
import '../../match/data/repositories/match_repository.dart';
import '../../rack/data/repositories/rack_repository.dart';
import '../data/recording_coordinator.dart';
import '../data/repositories/session_repository.dart';
import '../domain/models/session.dart';

final trainingSessionExecutionServiceProvider =
    Provider<TrainingSessionExecutionService>((ref) {
  return TrainingSessionExecutionService(
    sessions: ref.watch(sessionRepositoryProvider),
    matches: ref.watch(matchRepositoryProvider),
    racks: ref.watch(rackRepositoryProvider),
    recording: ref.watch(recordingCoordinatorProvider),
  );
});

final class TrainingSessionExecutionService {
  TrainingSessionExecutionService({
    required SessionRepository sessions,
    required MatchRepository matches,
    required RackRepository racks,
    required RecordingCoordinator recording,
  })  : _sessions = sessions,
        _matches = matches,
        _racks = racks,
        _recording = recording;

  final SessionRepository _sessions;
  final MatchRepository _matches;
  final RackRepository _racks;
  final RecordingCoordinator _recording;
  var _requestSequence = 0;

  Future<
      List<
          ({
            int matchId,
            int rackId,
            String code,
            String name,
            int attempts,
            int successes,
            bool completed,
          })>> loadExercises(int sessionId) async {
    final matches = await _matches.getMatchesBySessionId(sessionId);
    final exercises = <({
      int matchId,
      int rackId,
      String code,
      String name,
      int attempts,
      int successes,
      bool completed,
    })>[];
    for (final match in matches.where(
      (item) => item.gameType == RecordingCoordinator.drillGameType,
    )) {
      final racks = await _racks.getRacksByMatchId(match.id!);
      if (racks.isEmpty || racks.first.id == null) continue;
      final rack = racks.first;
      final successes = rack.ballsPotted;
      final misses = rack.easyMissCount;
      exercises.add((
        matchId: match.id!,
        rackId: rack.id!,
        code: match.notes ?? '',
        name: match.matchObjective ?? match.notes ?? 'Exercise',
        attempts: successes + misses,
        successes: successes,
        completed: !match.isActive,
      ));
    }
    return exercises;
  }

  Future<int> createSession({DateTime? startedAt}) async {
    final result = await _run(
      _CreateTrainingSession(startedAt ?? DateTime.now()),
      _CreateTrainingSessionHandler(_sessions),
      'create-session',
    );
    return result.value;
  }

  Future<({int matchId, int rackId})> addExercise({
    required int sessionId,
    required String exerciseCode,
    required String exerciseName,
  }) async {
    final result = await _run(
      _AddExercise(sessionId, exerciseCode, exerciseName),
      _AddExerciseHandler(_sessions, _recording),
      'add-exercise',
    );
    return (matchId: result.matchId, rackId: result.rackId);
  }

  Future<void> completeExercise({
    required int matchId,
    required int rackId,
    required int attempts,
    required int successes,
    required int target,
  }) async {
    await _run(
      _CompleteExercise(matchId, rackId, attempts, successes, target),
      _CompleteExerciseHandler(_matches, _racks, _recording),
      'complete-exercise',
    );
  }

  Future<void> finishSession(int sessionId) async {
    await _run(
      _FinishTrainingSession(sessionId),
      _FinishTrainingSessionHandler(_sessions, _recording),
      'finish-session',
    );
  }

  Future<TResult>
      _run<TCommand extends ValueObject, TResult extends ValueObject>(
    TCommand command,
    CommandHandler<TCommand, TResult> handler,
    String operation,
  ) async {
    _requestSequence += 1;
    final requestId = RuntimeIdentifier(
      namespace: 'product.training-session.request',
      value: '$operation-$_requestSequence',
    );
    final execution = await CommandExecutor<TCommand, TResult>(
      handler: handler,
      handlerId: RuntimeIdentifier(
        namespace: 'product.training-session.handler',
        value: operation,
      ),
    ).execute(
      command: command,
      context: ApplicationExecutionContext(
        request: ApplicationRequestContext(
          requestId: requestId,
          correlationId: requestId,
          requestedAtUtc: DateTime.now().toUtc(),
        ),
        cancellationToken: const _NeverCancelled(),
      ),
    );
    return execution.result.fold(
      onSuccess: (value) => value,
      onFailure: (failure) => throw StateError(failure.code),
    );
  }
}

final class _CreateTrainingSession extends ValueObject {
  const _CreateTrainingSession(this.startedAt);
  final DateTime startedAt;
  @override
  List<Object?> get components => [startedAt.toUtc()];
}

final class _AddExercise extends ValueObject {
  const _AddExercise(this.sessionId, this.exerciseCode, this.exerciseName);
  final int sessionId;
  final String exerciseCode;
  final String exerciseName;
  @override
  List<Object?> get components => [sessionId, exerciseCode, exerciseName];
}

final class _CompleteExercise extends ValueObject {
  const _CompleteExercise(
    this.matchId,
    this.rackId,
    this.attempts,
    this.successes,
    this.target,
  );
  final int matchId;
  final int rackId;
  final int attempts;
  final int successes;
  final int target;
  @override
  List<Object?> get components =>
      [matchId, rackId, attempts, successes, target];
}

final class _FinishTrainingSession extends ValueObject {
  const _FinishTrainingSession(this.sessionId);
  final int sessionId;
  @override
  List<Object?> get components => [sessionId];
}

final class _IdResult extends ValueObject {
  const _IdResult(this.value);
  final int value;
  @override
  List<Object?> get components => [value];
}

final class _ExerciseIds extends ValueObject {
  const _ExerciseIds(this.matchId, this.rackId);
  final int matchId;
  final int rackId;
  @override
  List<Object?> get components => [matchId, rackId];
}

final class _Done extends ValueObject {
  const _Done();
  @override
  List<Object?> get components => const [];
}

final class _CreateTrainingSessionHandler
    implements CommandHandler<_CreateTrainingSession, _IdResult> {
  const _CreateTrainingSessionHandler(this.sessions);
  final SessionRepository sessions;
  @override
  Future<Result<_IdResult>> handle(
    _CreateTrainingSession command,
    ApplicationExecutionContext context,
  ) async {
    if (await sessions.getActiveSession() != null) {
      throw StateError('training-session-active-session');
    }
    final id = await sessions.createSession(
      Session(
        sessionType: SessionTypes.training,
        startedAt: command.startedAt,
        createdAt: command.startedAt,
        updatedAt: command.startedAt,
      ),
    );
    return Success(_IdResult(id));
  }
}

final class _AddExerciseHandler
    implements CommandHandler<_AddExercise, _ExerciseIds> {
  const _AddExerciseHandler(this.sessions, this.recording);
  final SessionRepository sessions;
  final RecordingCoordinator recording;
  @override
  Future<Result<_ExerciseIds>> handle(
    _AddExercise command,
    ApplicationExecutionContext context,
  ) async {
    final session = await sessions.getSessionById(command.sessionId);
    if (session == null ||
        session.sessionType != SessionTypes.training ||
        !session.isActive ||
        command.exerciseCode.trim().isEmpty ||
        command.exerciseName.trim().isEmpty) {
      throw StateError('training-session-invalid-exercise');
    }
    final ids = await recording.startDrillMatch(
      sessionId: command.sessionId,
      drillCode: command.exerciseCode.trim(),
      drillName: command.exerciseName.trim(),
    );
    return Success(_ExerciseIds(ids.matchId, ids.rackId));
  }
}

final class _CompleteExerciseHandler
    implements CommandHandler<_CompleteExercise, _Done> {
  const _CompleteExerciseHandler(this.matches, this.racks, this.recording);
  final MatchRepository matches;
  final RackRepository racks;
  final RecordingCoordinator recording;
  @override
  Future<Result<_Done>> handle(
    _CompleteExercise command,
    ApplicationExecutionContext context,
  ) async {
    final match = await matches.getMatchById(command.matchId);
    final rack = await racks.getRackById(command.rackId);
    if (match == null ||
        match.gameType != RecordingCoordinator.drillGameType ||
        !match.isActive ||
        rack == null ||
        rack.matchId != command.matchId ||
        command.attempts < 0 ||
        command.successes < 0 ||
        command.successes > command.attempts ||
        command.target <= 0) {
      throw StateError('training-session-invalid-result');
    }
    await recording.finishDrillMatch(
      matchId: command.matchId,
      rackId: command.rackId,
      attempts: command.attempts,
      successfulAttempts: command.successes,
      targetScore: command.target,
    );
    return const Success(_Done());
  }
}

final class _FinishTrainingSessionHandler
    implements CommandHandler<_FinishTrainingSession, _Done> {
  const _FinishTrainingSessionHandler(this.sessions, this.recording);
  final SessionRepository sessions;
  final RecordingCoordinator recording;
  @override
  Future<Result<_Done>> handle(
    _FinishTrainingSession command,
    ApplicationExecutionContext context,
  ) async {
    final session = await sessions.getSessionById(command.sessionId);
    if (session == null || session.sessionType != SessionTypes.training) {
      throw StateError('training-session-not-found');
    }
    await recording.finishSession(command.sessionId);
    return const Success(_Done());
  }
}

final class _NeverCancelled implements CancellationToken {
  const _NeverCancelled();
  @override
  bool get isCancellationRequested => false;
}
