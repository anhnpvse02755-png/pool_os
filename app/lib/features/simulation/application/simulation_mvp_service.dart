import '../../../application/foundation/application_context.dart';
import '../../../application/foundation/application_handlers.dart';
import '../../../capabilities/simulation/simulation_capability_contracts.dart';
import '../../../framework/query/query_executor.dart';
import '../../../runtime/simulation/simulation_capability_runtime.dart';
import '../../../shared/foundation/identifier.dart';
import '../../../shared/foundation/result.dart';
import '../../../shared/foundation/value_object.dart';

enum SimulationScenarioKind { matchReplay, trainingReplay, combinedReplay }

enum SimulationSampleKind { match, training }

final class SimulationReplaySample extends ValueObject {
  const SimulationReplaySample({
    required this.kind,
    required this.id,
    required this.occurredAt,
    required this.observedRate,
    required this.duration,
  });

  final SimulationSampleKind kind;
  final int id;
  final DateTime occurredAt;
  final double observedRate;
  final Duration duration;

  @override
  List<Object?> get components => [
        kind,
        id,
        occurredAt.microsecondsSinceEpoch,
        observedRate,
        duration.inMicroseconds,
      ];
}

final class SimulationRequest extends ValueObject {
  const SimulationRequest({
    required this.requestId,
    required this.scenario,
    this.sampleLimit = 5,
  }) : assert(sampleLimit > 0);

  final String requestId;
  final SimulationScenarioKind scenario;
  final int sampleLimit;

  @override
  List<Object?> get components => [requestId, scenario, sampleLimit];
}

final class SimulationPreview extends ValueObject {
  SimulationPreview({
    required this.request,
    required List<SimulationReplaySample> samples,
  }) : samples = List.unmodifiable(samples);

  final SimulationRequest request;
  final List<SimulationReplaySample> samples;

  double get observedRate => samples.isEmpty
      ? 0
      : samples.fold<double>(0, (sum, item) => sum + item.observedRate) /
          samples.length;

  Duration get observedDuration => Duration(
        microseconds: samples.fold<int>(
          0,
          (sum, item) => sum + item.duration.inMicroseconds,
        ),
      );

  @override
  List<Object?> get components => [request, samples.length, ...samples];
}

final class SimulationComparison extends ValueObject {
  const SimulationComparison({required this.left, required this.right});

  final SimulationPreview left;
  final SimulationPreview right;

  double get observedRateDelta => right.observedRate - left.observedRate;

  @override
  List<Object?> get components => [left, right];
}

typedef SimulationReplayLoader = Future<List<SimulationReplaySample>>
    Function();

final class SimulationMvpService {
  SimulationMvpService({
    required SimulationReplayLoader loadMatches,
    required SimulationReplayLoader loadTraining,
  })  : _loadMatches = loadMatches,
        _loadTraining = loadTraining {
    final capability = _SimulationMvpCapability();
    const SimulationCapabilityBootstrap().initialize(
      registry: SimulationCapabilityRegistry([capability]),
      identity: capability.metadata.identity,
      compatibility: SimulationCapabilityCompatibility(
        requiredVersion: capability.metadata.version,
      ),
    );
  }

  final SimulationReplayLoader _loadMatches;
  final SimulationReplayLoader _loadTraining;

  Future<SimulationPreview> preview(SimulationRequest request) async {
    final executionId = RuntimeIdentifier(
      namespace: 'product.simulation-mvp.request',
      value: request.requestId,
    );
    final execution = await QueryExecutor<SimulationRequest, SimulationPreview>(
      handler: _SimulationPreviewHandler(_loadMatches, _loadTraining),
      handlerId: RuntimeIdentifier(
        namespace: 'product.simulation-mvp.handler',
        value: 'replay-scenario',
      ),
    ).execute(
      query: request,
      context: ApplicationExecutionContext(
        request: ApplicationRequestContext(
          requestId: executionId,
          correlationId: executionId,
          requestedAtUtc: DateTime.now().toUtc(),
        ),
        cancellationToken: const _NeverCancelled(),
      ),
    );
    return execution.result.fold(
      onSuccess: (preview) => preview,
      onFailure: (failure) => throw StateError(failure.code),
    );
  }

  Future<SimulationComparison> compare({
    required SimulationRequest left,
    required SimulationRequest right,
  }) async {
    return SimulationComparison(
      left: await preview(left),
      right: await preview(right),
    );
  }
}

final class _SimulationMvpCapability
    implements
        SimulationLifecycleCapability,
        ScenarioPreparationCapability,
        ResultCollectionCapability,
        SimulationStatisticsCapability {
  _SimulationMvpCapability()
      : metadata = SimulationCapabilityMetadata(
          identity: SimulationCapabilityIdentity(_id('capability', 'replay')),
          version: SimulationCapabilityVersion(_id('version', 'v1')),
          kinds: const [
            SimulationCapabilityKind.lifecycle,
            SimulationCapabilityKind.scenarioPreparation,
            SimulationCapabilityKind.resultCollection,
            SimulationCapabilityKind.statistics,
          ],
        );

  @override
  final SimulationCapabilityMetadata metadata;
}

final class _SimulationPreviewHandler
    implements QueryHandler<SimulationRequest, SimulationPreview> {
  const _SimulationPreviewHandler(this.loadMatches, this.loadTraining);

  final SimulationReplayLoader loadMatches;
  final SimulationReplayLoader loadTraining;

  @override
  Future<Result<SimulationPreview>> handle(
    SimulationRequest request,
    ApplicationExecutionContext context,
  ) async {
    final samples = switch (request.scenario) {
      SimulationScenarioKind.matchReplay => await loadMatches(),
      SimulationScenarioKind.trainingReplay => await loadTraining(),
      SimulationScenarioKind.combinedReplay => [
          ...await loadMatches(),
          ...await loadTraining(),
        ],
    }
      ..sort((left, right) {
        final time = right.occurredAt.compareTo(left.occurredAt);
        if (time != 0) return time;
        final kind = left.kind.index.compareTo(right.kind.index);
        return kind != 0 ? kind : right.id.compareTo(left.id);
      });
    return Success(SimulationPreview(
      request: request,
      samples: samples.take(request.sampleLimit).toList(),
    ));
  }
}

final class _NeverCancelled implements CancellationToken {
  const _NeverCancelled();

  @override
  bool get isCancellationRequested => false;
}

RuntimeIdentifier _id(String segment, String value) => RuntimeIdentifier(
      namespace: 'product.simulation-mvp.$segment',
      value: value,
    );
