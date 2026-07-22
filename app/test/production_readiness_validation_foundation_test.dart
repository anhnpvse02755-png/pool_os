import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/application_bootstrap_contracts.dart';
import 'package:pool_os/contracts/dependency_composition_root_contracts.dart';
import 'package:pool_os/contracts/production_readiness_validation_contracts.dart';
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
  final fixture = _fixture();

  test('readiness projection is immutable and deterministic', () {
    final first = fixture.project();
    final second = fixture.project();
    expect(second.toJson(), first.toJson());
    expect(first.entries, hasLength(2));
    expect(
      () => first.entries.add(first.entries.first),
      throwsUnsupportedError,
    );
  });

  test('ready status binds the authoritative input pair', () {
    final projection = fixture.project();
    expect(
      projection.runtimeConfigurationEnvironmentProjectionDigest,
      fixture.configuration.digest,
    );
    expect(projection.runtimeValidationDigest, fixture.validation.digest);
    expect(
      projection.entries.every(
        (entry) =>
            entry.readinessStatus == ProductionReadinessStatus.ready &&
            entry.runtimeValidationDigest == fixture.validation.digest &&
            entry.provenanceDigest.length == 64,
      ),
      isTrue,
    );
  });

  test('pair authority projects failed validation as blocked', () {
    final failed = const RuntimeValidator().validate(
      artifactDigests: {
        'composition': 'c',
        'delivery': 'd',
        'graph': 'g',
        'state': 's',
        'transition': 't',
      },
      expectedDigests: const {'graph': 'old'},
    );
    final projection = const ProductionReadinessProjector().project(
      configuration: fixture.configuration,
      runtimeValidation: failed,
    );
    expect(
      projection.entries.every(
        (entry) => entry.readinessStatus == ProductionReadinessStatus.blocked,
      ),
      isTrue,
    );
  });

  test('canonical configuration order is independent of supplied order', () {
    final source = fixture.project();
    final projection = ProductionReadinessProjectionContract.create(
      configuration: fixture.configuration,
      runtimeValidation: fixture.validation,
      entries: source.entries.reversed.toList(),
    );
    expect(projection.toJson(), source.toJson());
  });

  test('rejects stale validation binding and duplicate positions', () {
    final source = fixture.project().entries.first;
    final stale = ProductionReadinessEntry(
      readinessProjectionId: source.readinessProjectionId,
      runtimeConfigurationEnvironmentProjectionDigest:
          source.runtimeConfigurationEnvironmentProjectionDigest,
      runtimeValidationDigest: 'stale',
      runtimeNodeId: source.runtimeNodeId,
      serviceId: source.serviceId,
      readinessStatus: source.readinessStatus,
      canonicalPosition: source.canonicalPosition,
      provenanceDigest: source.provenanceDigest,
    );
    expect(
      () => ProductionReadinessProjectionContract.create(
        configuration: fixture.configuration,
        runtimeValidation: fixture.validation,
        entries: [stale, ...fixture.project().entries.skip(1)],
      ),
      throwsArgumentError,
    );
    expect(
      () => ProductionReadinessProjectionContract.create(
        configuration: fixture.configuration,
        runtimeValidation: fixture.validation,
        entries: [source, source],
      ),
      throwsArgumentError,
    );
  });

  test('does not mutate configuration or validation inputs', () {
    final configuration = fixture.configuration.toJson();
    final validation = fixture.validation.toJson();
    fixture.project();
    expect(fixture.configuration.toJson(), configuration);
    expect(fixture.validation.toJson(), validation);
  });
}

class _Fixture {
  const _Fixture({required this.configuration, required this.validation});

  final RuntimeConfigurationEnvironmentProjectionContract configuration;
  final RuntimeValidationContract validation;

  ProductionReadinessProjectionContract project() =>
      const ProductionReadinessProjector().project(
        configuration: configuration,
        runtimeValidation: validation,
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
  return _Fixture(configuration: configuration, validation: validation);
}
