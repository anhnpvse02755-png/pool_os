import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/foundation/application_context.dart';
import '../../../application/foundation/application_handlers.dart';
import '../../../capabilities/match/match_capability_contracts.dart';
import '../../../framework/command/command_executor.dart';
import '../../../runtime/match/match_capability_runtime.dart';
import '../../../shared/foundation/identifier.dart';
import '../../../shared/foundation/result.dart';
import '../../../shared/foundation/value_object.dart';
import '../../session/data/recording_coordinator.dart';
import '../domain/models/match.dart';
import '../../rack/domain/models/rack.dart';
import '../../player_model/application/player_progress_service.dart';
import '../../equipment/application/equipment_performance_projection_service.dart';
import '../../player/application/career_timeline_service.dart';

final matchRecordingServiceProvider = Provider<MatchRecordingService>((ref) {
  return MatchRecordingService(
    ref.watch(recordingCoordinatorProvider),
    refreshPlayerProgress: () =>
        ref.read(playerProgressServiceProvider).refreshActivePlayer(),
    refreshEquipmentPerformance: () => ref
        .read(equipmentPerformanceProjectionServiceProvider)
        .refreshActivePlayer(),
    refreshCareerTimeline: () =>
        ref.read(careerTimelineServiceProvider).rebuildActivePlayer(),
  );
});

final class MatchRecordingService {
  MatchRecordingService(
    this._coordinator, {
    Future<void> Function()? refreshPlayerProgress,
    Future<void> Function()? refreshEquipmentPerformance,
    Future<void> Function()? refreshCareerTimeline,
  })  : _refreshPlayerProgress = refreshPlayerProgress,
        _refreshEquipmentPerformance = refreshEquipmentPerformance,
        _refreshCareerTimeline = refreshCareerTimeline {
    final capability = _MatchRecordingCapability();
    final registry = MatchCapabilityRegistry([capability]);
    const MatchCapabilityBootstrap().initialize(
      registry: registry,
      identity: capability.metadata.identity,
      compatibility: MatchCapabilityCompatibility(
        requiredVersion: capability.metadata.version,
      ),
    );
  }

  final RecordingCoordinator _coordinator;
  final Future<void> Function()? _refreshPlayerProgress;
  final Future<void> Function()? _refreshEquipmentPerformance;
  final Future<void> Function()? _refreshCareerTimeline;
  var _requestSequence = 0;

  Future<int> createMatch(Match match) async {
    final output = await _run(
      _CreateMatchCommand(match),
      _CreateMatchHandler(_coordinator),
      'create-match',
    );
    return output.value;
  }

  Future<int> recordRack(Rack rack) async {
    final output = await _run(
      _RecordRackCommand(rack),
      _RecordRackHandler(_coordinator),
      'record-rack',
    );
    return output.value;
  }

  Future<void> finishMatch(int matchId, [String? winner]) async {
    await _run(
      _FinishMatchCommand(matchId, winner),
      _FinishMatchHandler(_coordinator),
      'finish-match',
    );
    await _refreshPlayerProgress?.call();
    await _refreshEquipmentPerformance?.call();
    await _refreshCareerTimeline?.call();
  }

  Future<void> finishSession(int sessionId) async {
    await _run(
      _FinishSessionCommand(sessionId),
      _FinishSessionHandler(_coordinator),
      'finish-session',
    );
    await _refreshPlayerProgress?.call();
    await _refreshEquipmentPerformance?.call();
    await _refreshCareerTimeline?.call();
  }

  Future<TResult>
      _run<TCommand extends ValueObject, TResult extends ValueObject>(
    TCommand command,
    CommandHandler<TCommand, TResult> handler,
    String operation,
  ) async {
    _requestSequence += 1;
    final requestId = RuntimeIdentifier(
      namespace: 'product.match-recording.request',
      value: '$operation-$_requestSequence',
    );
    final execution = await CommandExecutor<TCommand, TResult>(
      handler: handler,
      handlerId: RuntimeIdentifier(
        namespace: 'product.match-recording.handler',
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

final class _MatchRecordingCapability
    implements
        MatchLifecycleCapability,
        RackManagementCapability,
        MatchScoringCapability {
  _MatchRecordingCapability()
      : metadata = MatchCapabilityMetadata(
          identity: MatchCapabilityIdentity(_id('capability', 'recording')),
          version: MatchCapabilityVersion(_id('version', 'v1')),
          kinds: const [
            MatchCapabilityKind.lifecycle,
            MatchCapabilityKind.rackManagement,
            MatchCapabilityKind.scoring,
          ],
        );

  @override
  final MatchCapabilityMetadata metadata;
}

final class _CreateMatchCommand extends ValueObject {
  const _CreateMatchCommand(this.match);
  final Match match;
  @override
  List<Object?> get components => [match];
}

final class _RecordRackCommand extends ValueObject {
  const _RecordRackCommand(this.rack);
  final Rack rack;
  @override
  List<Object?> get components => [rack];
}

final class _FinishMatchCommand extends ValueObject {
  const _FinishMatchCommand(this.matchId, this.winner);
  final int matchId;
  final String? winner;
  @override
  List<Object?> get components => [matchId, winner];
}

final class _FinishSessionCommand extends ValueObject {
  const _FinishSessionCommand(this.sessionId);
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

final class _Done extends ValueObject {
  const _Done();
  @override
  List<Object?> get components => const [];
}

final class _CreateMatchHandler
    implements CommandHandler<_CreateMatchCommand, _IdResult> {
  const _CreateMatchHandler(this.coordinator);
  final RecordingCoordinator coordinator;
  @override
  Future<Result<_IdResult>> handle(
    _CreateMatchCommand command,
    ApplicationExecutionContext context,
  ) async =>
      Success(_IdResult(await coordinator.createMatch(command.match)));
}

final class _RecordRackHandler
    implements CommandHandler<_RecordRackCommand, _IdResult> {
  const _RecordRackHandler(this.coordinator);
  final RecordingCoordinator coordinator;
  @override
  Future<Result<_IdResult>> handle(
    _RecordRackCommand command,
    ApplicationExecutionContext context,
  ) async =>
      Success(_IdResult(await coordinator.recordRack(command.rack)));
}

final class _FinishMatchHandler
    implements CommandHandler<_FinishMatchCommand, _Done> {
  const _FinishMatchHandler(this.coordinator);
  final RecordingCoordinator coordinator;
  @override
  Future<Result<_Done>> handle(
    _FinishMatchCommand command,
    ApplicationExecutionContext context,
  ) async {
    await coordinator.finishMatch(command.matchId, command.winner);
    return const Success(_Done());
  }
}

final class _FinishSessionHandler
    implements CommandHandler<_FinishSessionCommand, _Done> {
  const _FinishSessionHandler(this.coordinator);
  final RecordingCoordinator coordinator;
  @override
  Future<Result<_Done>> handle(
    _FinishSessionCommand command,
    ApplicationExecutionContext context,
  ) async {
    await coordinator.finishSession(command.sessionId);
    return const Success(_Done());
  }
}

final class _NeverCancelled implements CancellationToken {
  const _NeverCancelled();
  @override
  bool get isCancellationRequested => false;
}

RuntimeIdentifier _id(String segment, String value) => RuntimeIdentifier(
      namespace: 'product.match-recording.$segment',
      value: value,
    );
