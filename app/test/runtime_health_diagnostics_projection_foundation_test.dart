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

  test('health projection is immutable and deterministic', () {
    final first = fixture.project();
    final second = fixture.project();
    expect(second.toJson(), first.toJson());
    expect(first.entries, hasLength(2));
    expect(
      () => first.entries.add(first.entries.first),
      throwsUnsupportedError,
    );
  });

  test('every entry binds the aggregate runtime validation digest', () {
    final projection = fixture.project();
    expect(projection.runtimeValidationDigest, fixture.validation.digest);
    expect(
      projection.entries.every(
        (entry) =>
            entry.runtimeValidationDigest == fixture.validation.digest &&
            entry.validationArtifactDigest == fixture.validation.digest &&
            entry.validationStatus == RuntimeValidationStatus.passed,
      ),
      isTrue,
    );
  });

  test('pair authority projects a supplied failed validation as failed', () {
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
    final projection = const RuntimeHealthDiagnosticsProjector().project(
      runtimeLifecycleHostProjection: fixture.host,
      runtimeValidation: failed,
    );
    expect(
      projection.entries.every(
          (entry) => entry.validationStatus == RuntimeValidationStatus.failed),
      isTrue,
    );
    expect(projection.runtimeValidationDigest, failed.digest);
  });

  test('canonical host order is independent of supplied entry order', () {
    final source = fixture.project();
    final projection = RuntimeHealthDiagnosticsProjectionContract.create(
      runtimeLifecycleHostProjection: fixture.host,
      runtimeValidation: fixture.validation,
      entries: source.entries.reversed.toList(),
    );
    expect(projection.toJson(), source.toJson());
  });

  test('rejects stale aggregate binding and duplicate positions', () {
    final source = fixture.project().entries.first;
    final stale = RuntimeHealthDiagnosticsEntry(
      runtimeHealthProjectionId: source.runtimeHealthProjectionId,
      runtimeLifecycleHostProjectionDigest:
          source.runtimeLifecycleHostProjectionDigest,
      runtimeValidationDigest: 'stale',
      lifecycleHostEntryId: source.lifecycleHostEntryId,
      runtimeNodeId: source.runtimeNodeId,
      serviceId: source.serviceId,
      validationArtifactDigest: source.validationArtifactDigest,
      validationStatus: source.validationStatus,
      canonicalPosition: source.canonicalPosition,
    );
    expect(
      () => RuntimeHealthDiagnosticsProjectionContract.create(
        runtimeLifecycleHostProjection: fixture.host,
        runtimeValidation: fixture.validation,
        entries: [stale, ...fixture.project().entries.skip(1)],
      ),
      throwsArgumentError,
    );
    expect(
      () => RuntimeHealthDiagnosticsProjectionContract.create(
        runtimeLifecycleHostProjection: fixture.host,
        runtimeValidation: fixture.validation,
        entries: [source, source],
      ),
      throwsArgumentError,
    );
  });

  test('does not mutate lifecycle host or runtime validation', () {
    final host = fixture.host.toJson();
    final validation = fixture.validation.toJson();
    fixture.project();
    expect(fixture.host.toJson(), host);
    expect(fixture.validation.toJson(), validation);
  });
}

class _Fixture {
  const _Fixture({required this.host, required this.validation});

  final RuntimeLifecycleHostProjectionContract host;
  final RuntimeValidationContract validation;

  RuntimeHealthDiagnosticsProjectionContract project() =>
      const RuntimeHealthDiagnosticsProjector().project(
        runtimeLifecycleHostProjection: host,
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
  return _Fixture(host: host, validation: validation);
}
