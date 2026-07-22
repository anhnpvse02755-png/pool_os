import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/application_bootstrap_contracts.dart';
import 'package:pool_os/contracts/dependency_composition_root_contracts.dart';
import 'package:pool_os/contracts/runtime_activation_coordination_contracts.dart';
import 'package:pool_os/contracts/runtime_activation_projection_contracts.dart';
import 'package:pool_os/contracts/runtime_composition_contracts.dart';
import 'package:pool_os/contracts/runtime_composition_coordination_contracts.dart';
import 'package:pool_os/contracts/runtime_delivery_projection_contracts.dart';
import 'package:pool_os/contracts/runtime_dispatch_contracts.dart';
import 'package:pool_os/contracts/runtime_dependency_resolution_contracts.dart';
import 'package:pool_os/contracts/runtime_lifecycle_host_projection_contracts.dart';
import 'package:pool_os/contracts/runtime_lifecycle_projection_contracts.dart';
import 'package:pool_os/contracts/runtime_pipeline_contracts.dart';
import 'package:pool_os/contracts/runtime_service_activation_projection_contracts.dart';
import 'package:pool_os/contracts/runtime_service_composition_contracts.dart';
import 'package:pool_os/contracts/runtime_service_exposure_contracts.dart';
import 'package:pool_os/contracts/runtime_service_registry_contracts.dart';
import 'package:pool_os/contracts/runtime_validation_contracts.dart';

void main() {
  final fixture = _fixture('primary');

  test('lifecycle host projection is immutable and deterministic', () {
    final first = fixture.project();
    final second = fixture.project();
    expect(second.toJson(), first.toJson());
    expect(first.entries, hasLength(4));
    expect(
      () => first.entries.add(first.entries.first),
      throwsUnsupportedError,
    );
  });

  test('binds activation and lifecycle provenance', () {
    final projection = fixture.project();
    expect(
      projection.runtimeServiceActivationProjectionDigest,
      fixture.activationProjection.digest,
    );
    expect(
      projection.runtimeLifecycleProjectionDigest,
      fixture.lifecycle.digest,
    );
    for (final entry in projection.entries) {
      expect(entry.lifecycleEntryId, startsWith('runtime-lifecycle-entry.'));
      expect(entry.lifecyclePhase, isNotNull);
    }
  });

  test('canonical activation order is independent of supplied order', () {
    final source = fixture.project();
    final projection = RuntimeLifecycleHostProjectionContract.create(
      runtimeServiceActivationProjection: fixture.activationProjection,
      runtimeLifecycleProjection: fixture.lifecycle,
      entries: source.entries.reversed.toList(),
    );
    expect(projection.toJson(), source.toJson());
  });

  test('rejects stale or foreign lifecycle projection', () {
    final foreign = _fixture('foreign');
    expect(
      () => const RuntimeLifecycleHostProjector().project(
        runtimeServiceActivationProjection: fixture.activationProjection,
        runtimeLifecycleProjection: foreign.lifecycle,
      ),
      throwsArgumentError,
    );
  });

  test('rejects orphan lifecycle entries and duplicate positions', () {
    final source = fixture.project().entries.first;
    final orphan = RuntimeLifecycleHostEntry(
      lifecycleHostProjectionId: source.lifecycleHostProjectionId,
      runtimeServiceActivationProjectionDigest:
          source.runtimeServiceActivationProjectionDigest,
      runtimeLifecycleProjectionDigest: source.runtimeLifecycleProjectionDigest,
      activationId: source.activationId,
      lifecycleEntryId: source.lifecycleEntryId,
      serviceId: source.serviceId,
      runtimeNodeId: 'foreign-node',
      lifecyclePhase: source.lifecyclePhase,
      canonicalPosition: source.canonicalPosition,
    );
    expect(
      () => RuntimeLifecycleHostProjectionContract.create(
        runtimeServiceActivationProjection: fixture.activationProjection,
        runtimeLifecycleProjection: fixture.lifecycle,
        entries: [orphan, ...fixture.project().entries.skip(1)],
      ),
      throwsArgumentError,
    );
    expect(
      () => RuntimeLifecycleHostProjectionContract.create(
        runtimeServiceActivationProjection: fixture.activationProjection,
        runtimeLifecycleProjection: fixture.lifecycle,
        entries: [source, source, ...fixture.project().entries.skip(2)],
      ),
      throwsArgumentError,
    );
  });

  test('does not mutate activation or lifecycle projections', () {
    final activation = fixture.activationProjection.toJson();
    final lifecycle = fixture.lifecycle.toJson();
    fixture.project();
    expect(fixture.activationProjection.toJson(), activation);
    expect(fixture.lifecycle.toJson(), lifecycle);
  });
}

class _Fixture {
  const _Fixture({required this.activationProjection, required this.lifecycle});

  final RuntimeServiceActivationProjectionContract activationProjection;
  final RuntimeLifecycleProjectionContract lifecycle;

  RuntimeLifecycleHostProjectionContract project() =>
      const RuntimeLifecycleHostProjector().project(
        runtimeServiceActivationProjection: activationProjection,
        runtimeLifecycleProjection: lifecycle,
      );
}

_Fixture _fixture(String suffix) {
  final composition = RuntimeCompositionContract.create(
    nodes: [
      RuntimeNodeContract(
        id: 'a.$suffix',
        kind: RuntimeNodeKind.session,
        sourceContractVersion: 1,
        sourceDigest: 'a.$suffix',
      ),
      RuntimeNodeContract(
        id: 'b.$suffix',
        kind: RuntimeNodeKind.toolInvocation,
        sourceContractVersion: 1,
        sourceDigest: 'b.$suffix',
      ),
      RuntimeNodeContract(
        id: 'c.$suffix',
        kind: RuntimeNodeKind.promptAssembly,
        sourceContractVersion: 1,
        sourceDigest: 'c.$suffix',
      ),
      RuntimeNodeContract(
        id: 'd.$suffix',
        kind: RuntimeNodeKind.providerRequest,
        sourceContractVersion: 1,
        sourceDigest: 'd.$suffix',
      ),
    ],
    edges: [
      RuntimeEdgeContract(fromId: 'a.$suffix', toId: 'b.$suffix'),
      RuntimeEdgeContract(fromId: 'b.$suffix', toId: 'c.$suffix'),
      RuntimeEdgeContract(fromId: 'c.$suffix', toId: 'd.$suffix'),
    ],
  );
  final pipeline = const RuntimePipelineEngine().build(
    composition: composition,
    stages: [
      PipelineStage(id: 'first.$suffix', runtimeNodeId: 'a.$suffix'),
      PipelineStage(id: 'second.$suffix', runtimeNodeId: 'b.$suffix'),
      PipelineStage(id: 'third.$suffix', runtimeNodeId: 'c.$suffix'),
      PipelineStage(id: 'fourth.$suffix', runtimeNodeId: 'd.$suffix'),
    ],
    transitions: [
      PipelineTransition(
          fromStageId: 'first.$suffix', toStageId: 'second.$suffix'),
      PipelineTransition(
          fromStageId: 'second.$suffix', toStageId: 'third.$suffix'),
      PipelineTransition(
          fromStageId: 'third.$suffix', toStageId: 'fourth.$suffix'),
    ],
  );
  final coordination = const RuntimeCompositionCoordinator().coordinate(
    composition: composition,
    pipeline: pipeline,
    mappings: [
      RuntimeCoordinationMapping(
        runtimeNodeId: 'a.$suffix',
        pipelineStageId: 'first.$suffix',
      ),
      RuntimeCoordinationMapping(
        runtimeNodeId: 'b.$suffix',
        pipelineStageId: 'second.$suffix',
      ),
      RuntimeCoordinationMapping(
        runtimeNodeId: 'c.$suffix',
        pipelineStageId: 'third.$suffix',
      ),
      RuntimeCoordinationMapping(
        runtimeNodeId: 'd.$suffix',
        pipelineStageId: 'fourth.$suffix',
      ),
    ],
  );
  final dispatch = const RuntimeDispatcher().project(coordination);
  final activation = const RuntimeActivationProjector().project(dispatch);
  final lifecycle = const RuntimeLifecycleProjector().project(activation);

  final services = const RuntimeServiceCompositionEngine().compose(composition);
  final registry = const RuntimeServiceRegistryBuilder().build(services);
  final dependencies = const RuntimeDependencyResolutionBuilder().build(
    registry: registry,
    runtimeComposition: composition,
  );
  final activationCoordination =
      const RuntimeActivationCoordinator().coordinate(dependencies);
  final exposure = const RuntimeServiceExposureProjector().project(
    activationCoordination: activationCoordination,
    registry: registry,
  );
  final delivery = const RuntimeDeliveryProjector().project(exposure);
  final validation = const RuntimeValidator().validate(
    artifactDigests: {
      'composition': composition.digest,
      'delivery': delivery.digest,
      'graph': 'g',
      'state': 's',
      'transition': 't',
    },
  );
  final bootstrap = const ApplicationBootstrapBuilder().build(
    runtimeComposition: composition,
    runtimeValidation: validation,
    runtimeDelivery: delivery,
  );
  final root = const DependencyCompositionRootBuilder().build(
    bootstrap: bootstrap,
    runtimeServiceComposition: services,
  );
  final activationProjection =
      const RuntimeServiceActivationProjector().project(
    dependencyCompositionRoot: root,
    runtimeActivationCoordination: activationCoordination,
  );
  return _Fixture(
    activationProjection: activationProjection,
    lifecycle: lifecycle,
  );
}
