import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/application_bootstrap_contracts.dart';
import 'package:pool_os/contracts/dependency_composition_root_contracts.dart';
import 'package:pool_os/contracts/runtime_activation_coordination_contracts.dart';
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
  final fixture = _fixture('primary');

  test('configuration projection is immutable and deterministic', () {
    final first = fixture.project();
    final second = fixture.project();
    expect(second.toJson(), first.toJson());
    expect(first.entries, hasLength(2));
    expect(
      () => first.entries.add(first.entries.first),
      throwsUnsupportedError,
    );
  });

  test('binds ownership identities and delivery targets only', () {
    final projection = fixture.project();
    for (var index = 0; index < projection.entries.length; index++) {
      final entry = projection.entries[index];
      final delivery = fixture.delivery.entries[index];
      expect(entry.runtimeNodeId, delivery.runtimeNodeId);
      expect(entry.serviceId, delivery.serviceId);
      expect(entry.deliveryTarget, delivery.target);
      expect(entry.configurationId, startsWith('runtime-configuration.'));
      expect(entry.environmentId, startsWith('runtime-environment.'));
      expect(entry.configurationProvenanceDigest, hasLength(64));
    }
  });

  test('canonical delivery order is independent of supplied order', () {
    final source = fixture.project();
    final projection = RuntimeConfigurationEnvironmentProjectionContract.create(
      runtimeHealth: fixture.health,
      runtimeDelivery: fixture.delivery,
      entries: source.entries.reversed.toList(),
    );
    expect(projection.toJson(), source.toJson());
  });

  test('rejects foreign delivery coverage', () {
    final foreign = _fixture('foreign');
    expect(
      () => const RuntimeConfigurationEnvironmentProjector().project(
        runtimeHealth: fixture.health,
        runtimeDelivery: foreign.delivery,
      ),
      throwsArgumentError,
    );
  });

  test('rejects broken provenance and duplicate positions', () {
    final source = fixture.project().entries.first;
    final stale = RuntimeConfigurationEnvironmentEntry(
      configurationEntryId: source.configurationEntryId,
      configurationId: source.configurationId,
      environmentId: source.environmentId,
      runtimeNodeId: source.runtimeNodeId,
      serviceId: source.serviceId,
      deliveryId: source.deliveryId,
      deliveryTarget: source.deliveryTarget,
      runtimeHealthProjectionDigest: 'stale',
      runtimeDeliveryProjectionDigest: source.runtimeDeliveryProjectionDigest,
      configurationProvenanceDigest: source.configurationProvenanceDigest,
      canonicalPosition: source.canonicalPosition,
    );
    expect(
      () => RuntimeConfigurationEnvironmentProjectionContract.create(
        runtimeHealth: fixture.health,
        runtimeDelivery: fixture.delivery,
        entries: [stale, ...fixture.project().entries.skip(1)],
      ),
      throwsArgumentError,
    );
    expect(
      () => RuntimeConfigurationEnvironmentProjectionContract.create(
        runtimeHealth: fixture.health,
        runtimeDelivery: fixture.delivery,
        entries: [source, source],
      ),
      throwsArgumentError,
    );
  });

  test('does not mutate health or delivery projections', () {
    final health = fixture.health.toJson();
    final delivery = fixture.delivery.toJson();
    fixture.project();
    expect(fixture.health.toJson(), health);
    expect(fixture.delivery.toJson(), delivery);
  });
}

class _Fixture {
  const _Fixture({required this.health, required this.delivery});

  final RuntimeHealthDiagnosticsProjectionContract health;
  final RuntimeDeliveryProjectionContract delivery;

  RuntimeConfigurationEnvironmentProjectionContract project() =>
      const RuntimeConfigurationEnvironmentProjector().project(
        runtimeHealth: health,
        runtimeDelivery: delivery,
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
        kind: RuntimeNodeKind.activation,
        sourceContractVersion: 1,
        sourceDigest: 'b.$suffix',
      ),
    ],
    edges: [
      RuntimeEdgeContract(fromId: 'a.$suffix', toId: 'b.$suffix'),
    ],
  );
  final pipeline = const RuntimePipelineEngine().build(
    composition: composition,
    stages: [
      PipelineStage(id: 'first.$suffix', runtimeNodeId: 'a.$suffix'),
      PipelineStage(id: 'second.$suffix', runtimeNodeId: 'b.$suffix'),
    ],
    transitions: [
      PipelineTransition(
        fromStageId: 'first.$suffix',
        toStageId: 'second.$suffix',
      ),
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
  return _Fixture(health: health, delivery: delivery);
}
