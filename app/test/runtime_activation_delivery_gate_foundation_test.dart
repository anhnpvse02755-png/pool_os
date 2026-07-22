import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/application_bootstrap_contracts.dart';
import 'package:pool_os/contracts/dependency_composition_root_contracts.dart';
import 'package:pool_os/contracts/production_readiness_validation_contracts.dart';
import 'package:pool_os/contracts/runtime_activation_coordination_contracts.dart';
import 'package:pool_os/contracts/runtime_activation_delivery_gate_contracts.dart';
import 'package:pool_os/contracts/runtime_activation_projection_contracts.dart';
import 'package:pool_os/contracts/runtime_composition_contracts.dart';
import 'package:pool_os/contracts/runtime_composition_coordination_contracts.dart';
import 'package:pool_os/contracts/runtime_configuration_environment_projection_contracts.dart';
import 'package:pool_os/contracts/runtime_delivery_projection_contracts.dart';
import 'package:pool_os/contracts/runtime_dispatch_contracts.dart';
import 'package:pool_os/contracts/runtime_dependency_resolution_contracts.dart';
import 'package:pool_os/contracts/runtime_health_diagnostics_projection_contracts.dart';
import 'package:pool_os/contracts/runtime_lifecycle_host_projection_contracts.dart';
import 'package:pool_os/contracts/runtime_lifecycle_projection_contracts.dart';
import 'package:pool_os/contracts/runtime_pipeline_contracts.dart';
import 'package:pool_os/contracts/runtime_service_activation_projection_contracts.dart';
import 'package:pool_os/contracts/runtime_service_composition_contracts.dart';
import 'package:pool_os/contracts/runtime_service_exposure_contracts.dart';
import 'package:pool_os/contracts/runtime_service_registry_contracts.dart';
import 'package:pool_os/contracts/runtime_validation_contracts.dart';

void main() {
  final fixture = _fixture();

  test('activation delivery gate is immutable and deterministic', () {
    final first = fixture.project();
    final second = fixture.project();
    expect(second.toJson(), first.toJson());
    expect(first.entries, hasLength(2));
    expect(() => first.entries.add(first.entries.first), throwsUnsupportedError);
  });

  test('gate binds readiness and delivery through public identity pair', () {
    final gate = fixture.project();
    expect(gate.readinessProjectionDigest, fixture.readiness.digest);
    expect(gate.runtimeDeliveryProjectionDigest, fixture.delivery.digest);
    expect(
      gate.entries.every(
        (entry) =>
            entry.gateStatus == RuntimeActivationDeliveryGateStatus.eligible &&
            entry.readinessProjectionDigest == fixture.readiness.digest &&
            entry.runtimeDeliveryProjectionDigest == fixture.delivery.digest &&
            entry.provenanceDigest.length == 64,
      ),
      isTrue,
    );
  });

  test('blocked readiness projects a blocked declarative gate', () {
    final failedValidation = const RuntimeValidator().validate(
      artifactDigests: const {
        'composition': 'c',
        'delivery': 'd',
        'graph': 'g',
        'state': 's',
        'transition': 't',
      },
      expectedDigests: const {'graph': 'stale'},
    );
    final blockedReadiness = const ProductionReadinessProjector().project(
      configuration: fixture.configuration,
      runtimeValidation: failedValidation,
    );
    final gate = const RuntimeActivationDeliveryGateProjector().project(
      readiness: blockedReadiness,
      runtimeDelivery: fixture.delivery,
    );
    expect(
      gate.entries.every(
        (entry) =>
            entry.gateStatus == RuntimeActivationDeliveryGateStatus.blocked,
      ),
      isTrue,
    );
  });

  test('delivery order canonicalizes supplied gate entries', () {
    final source = fixture.project();
    final canonical = RuntimeActivationDeliveryGateContract.create(
      readiness: fixture.readiness,
      runtimeDelivery: fixture.delivery,
      entries: source.entries.reversed.toList(),
    );
    expect(canonical.toJson(), source.toJson());
  });

  test('rejects stale bindings, duplicate positions, and broken provenance', () {
    final source = fixture.project();
    final first = source.entries.first;
    final stale = RuntimeActivationDeliveryGateEntry(
      gateProjectionId: first.gateProjectionId,
      readinessProjectionDigest: 'stale',
      runtimeDeliveryProjectionDigest: first.runtimeDeliveryProjectionDigest,
      runtimeNodeId: first.runtimeNodeId,
      serviceId: first.serviceId,
      deliveryTarget: first.deliveryTarget,
      gateStatus: first.gateStatus,
      canonicalPosition: first.canonicalPosition,
      provenanceDigest: first.provenanceDigest,
    );
    expect(
      () => RuntimeActivationDeliveryGateContract.create(
        readiness: fixture.readiness,
        runtimeDelivery: fixture.delivery,
        entries: [stale, ...source.entries.skip(1)],
      ),
      throwsArgumentError,
    );
    expect(
      () => RuntimeActivationDeliveryGateContract.create(
        readiness: fixture.readiness,
        runtimeDelivery: fixture.delivery,
        entries: [first, first],
      ),
      throwsArgumentError,
    );
    final broken = RuntimeActivationDeliveryGateEntry(
      gateProjectionId: first.gateProjectionId,
      readinessProjectionDigest: first.readinessProjectionDigest,
      runtimeDeliveryProjectionDigest: first.runtimeDeliveryProjectionDigest,
      runtimeNodeId: first.runtimeNodeId,
      serviceId: first.serviceId,
      deliveryTarget: first.deliveryTarget,
      gateStatus: first.gateStatus,
      canonicalPosition: first.canonicalPosition,
      provenanceDigest: 'broken',
    );
    expect(
      () => RuntimeActivationDeliveryGateContract.create(
        readiness: fixture.readiness,
        runtimeDelivery: fixture.delivery,
        entries: [broken, ...source.entries.skip(1)],
      ),
      throwsArgumentError,
    );
  });

  test('does not mutate readiness or runtime delivery inputs', () {
    final readiness = fixture.readiness.toJson();
    final delivery = fixture.delivery.toJson();
    fixture.project();
    expect(fixture.readiness.toJson(), readiness);
    expect(fixture.delivery.toJson(), delivery);
  });
}

class _Fixture {
  const _Fixture({
    required this.configuration,
    required this.readiness,
    required this.delivery,
  });

  final RuntimeConfigurationEnvironmentProjectionContract configuration;
  final ProductionReadinessProjectionContract readiness;
  final RuntimeDeliveryProjectionContract delivery;

  RuntimeActivationDeliveryGateContract project() =>
      const RuntimeActivationDeliveryGateProjector().project(
        readiness: readiness,
        runtimeDelivery: delivery,
      );
}

_Fixture _fixture() {
  final composition = const RuntimeCompositionEngine().compose(
    nodes: const [
      RuntimeNodeContract(
        id: 'a',
        kind: RuntimeNodeKind.session,
        sourceContractVersion: 1,
        sourceDigest: 'a',
      ),
      RuntimeNodeContract(
        id: 'b',
        kind: RuntimeNodeKind.activation,
        sourceContractVersion: 1,
        sourceDigest: 'b',
      ),
    ],
    edges: const [RuntimeEdgeContract(fromId: 'a', toId: 'b')],
  );
  final pipeline = const RuntimePipelineEngine().build(
    composition: composition,
    stages: const [
      PipelineStage(id: 'first', runtimeNodeId: 'a'),
      PipelineStage(id: 'second', runtimeNodeId: 'b'),
    ],
    transitions: const [
      PipelineTransition(fromStageId: 'first', toStageId: 'second'),
    ],
  );
  final coordination = const RuntimeCompositionCoordinator().coordinate(
    composition: composition,
    pipeline: pipeline,
    mappings: const [
      RuntimeCoordinationMapping(
        runtimeNodeId: 'a',
        pipelineStageId: 'first',
      ),
      RuntimeCoordinationMapping(
        runtimeNodeId: 'b',
        pipelineStageId: 'second',
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
  final serviceActivation = const RuntimeServiceActivationProjector().project(
    dependencyCompositionRoot: root,
    runtimeActivationCoordination: activationCoordination,
  );
  final host = const RuntimeLifecycleHostProjector().project(
    runtimeServiceActivationProjection: serviceActivation,
    runtimeLifecycleProjection: lifecycle,
  );
  final health = const RuntimeHealthDiagnosticsProjector().project(
    runtimeLifecycleHostProjection: host,
    runtimeValidation: validation,
  );
  final configuration =
      const RuntimeConfigurationEnvironmentProjector().project(
    runtimeHealth: health,
    runtimeDelivery: delivery,
  );
  final readiness = const ProductionReadinessProjector().project(
    configuration: configuration,
    runtimeValidation: validation,
  );
  return _Fixture(
    configuration: configuration,
    readiness: readiness,
    delivery: delivery,
  );
}
