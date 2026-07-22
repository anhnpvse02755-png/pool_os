import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/application_bootstrap_contracts.dart';
import 'package:pool_os/contracts/runtime_composition_contracts.dart';
import 'package:pool_os/contracts/runtime_activation_coordination_contracts.dart';
import 'package:pool_os/contracts/runtime_delivery_projection_contracts.dart';
import 'package:pool_os/contracts/runtime_dependency_resolution_contracts.dart';
import 'package:pool_os/contracts/runtime_service_composition_contracts.dart';
import 'package:pool_os/contracts/runtime_service_exposure_contracts.dart';
import 'package:pool_os/contracts/runtime_service_registry_contracts.dart';
import 'package:pool_os/contracts/runtime_validation_contracts.dart';

void main() {
  final fixture = _fixture();

  test('bootstrap projection is immutable and deterministic', () {
    final first = fixture.build();
    final second = fixture.build();
    expect(second.toJson(), first.toJson());
    expect(first.entries, hasLength(4));
    expect(
      () => first.entries.add(first.entries.first),
      throwsUnsupportedError,
    );
  });

  test('binds composition, validation, and delivery provenance', () {
    final bootstrap = fixture.build();
    expect(bootstrap.runtimeCompositionDigest, fixture.composition.digest);
    expect(bootstrap.runtimeValidationDigest, fixture.validation.digest);
    expect(bootstrap.runtimeDeliveryDigest, fixture.delivery.digest);
    expect(
      bootstrap.entries.every(
        (entry) =>
            entry.runtimeCompositionDigest == fixture.composition.digest &&
            entry.runtimeValidationDigest == fixture.validation.digest &&
            entry.runtimeDeliveryDigest == fixture.delivery.digest,
      ),
      isTrue,
    );
  });

  test('canonical delivery order is independent of input entry order', () {
    final bootstrap = ApplicationBootstrapContract.create(
      runtimeComposition: fixture.composition,
      runtimeValidation: fixture.validation,
      runtimeDelivery: fixture.delivery,
      entries: fixture.build().entries.reversed.toList(),
    );
    expect(bootstrap.toJson(), fixture.build().toJson());
  });

  test('rejects stale validation or failed validation', () {
    final stale = const RuntimeValidator().validate(
      artifactDigests: {
        'composition': fixture.composition.digest,
        'delivery': 'stale',
        'graph': 'g',
        'state': 's',
        'transition': 't',
      },
    );
    expect(
      () => const ApplicationBootstrapBuilder().build(
        runtimeComposition: fixture.composition,
        runtimeValidation: stale,
        runtimeDelivery: fixture.delivery,
      ),
      throwsArgumentError,
    );
    final failed = const RuntimeValidator().validate(
      artifactDigests: {
        'composition': fixture.composition.digest,
        'delivery': fixture.delivery.digest,
        'graph': 'g',
        'state': 's',
        'transition': 't',
      },
      expectedDigests: const {'graph': 'old'},
    );
    expect(
      () => const ApplicationBootstrapBuilder().build(
        runtimeComposition: fixture.composition,
        runtimeValidation: failed,
        runtimeDelivery: fixture.delivery,
      ),
      throwsArgumentError,
    );
  });

  test('rejects orphan runtime references and duplicate entries', () {
    final source = fixture.build().entries.first;
    final orphan = ApplicationBootstrapEntry(
      bootstrapEntryId: source.bootstrapEntryId,
      runtimeNodeId: 'missing-node',
      deliveryId: source.deliveryId,
      serviceId: source.serviceId,
      position: source.position,
      runtimeCompositionDigest: source.runtimeCompositionDigest,
      runtimeValidationDigest: source.runtimeValidationDigest,
      runtimeDeliveryDigest: source.runtimeDeliveryDigest,
    );
    expect(
      () => ApplicationBootstrapContract.create(
        runtimeComposition: fixture.composition,
        runtimeValidation: fixture.validation,
        runtimeDelivery: fixture.delivery,
        entries: [orphan, ...fixture.build().entries.skip(1)],
      ),
      throwsArgumentError,
    );
    expect(
      () => ApplicationBootstrapContract.create(
        runtimeComposition: fixture.composition,
        runtimeValidation: fixture.validation,
        runtimeDelivery: fixture.delivery,
        entries: [source, source, ...fixture.build().entries.skip(2)],
      ),
      throwsArgumentError,
    );
  });

  test('does not mutate any source projection', () {
    final composition = fixture.composition.toJson();
    final validation = fixture.validation.toJson();
    final delivery = fixture.delivery.toJson();
    fixture.build();
    expect(fixture.composition.toJson(), composition);
    expect(fixture.validation.toJson(), validation);
    expect(fixture.delivery.toJson(), delivery);
  });
}

class _Fixture {
  const _Fixture({
    required this.composition,
    required this.validation,
    required this.delivery,
  });

  final RuntimeCompositionContract composition;
  final RuntimeValidationContract validation;
  final RuntimeDeliveryProjectionContract delivery;

  ApplicationBootstrapContract build() =>
      const ApplicationBootstrapBuilder().build(
        runtimeComposition: composition,
        runtimeValidation: validation,
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
        kind: RuntimeNodeKind.toolInvocation,
        sourceContractVersion: 1,
        sourceDigest: 'b',
      ),
      RuntimeNodeContract(
        id: 'c',
        kind: RuntimeNodeKind.promptAssembly,
        sourceContractVersion: 1,
        sourceDigest: 'c',
      ),
      RuntimeNodeContract(
        id: 'd',
        kind: RuntimeNodeKind.providerRequest,
        sourceContractVersion: 1,
        sourceDigest: 'd',
      ),
    ],
    edges: const [
      RuntimeEdgeContract(fromId: 'a', toId: 'b'),
      RuntimeEdgeContract(fromId: 'b', toId: 'c'),
      RuntimeEdgeContract(fromId: 'c', toId: 'd'),
    ],
  );
  final serviceComposition = const RuntimeServiceCompositionEngine().compose(
    composition,
  );
  final registry = const RuntimeServiceRegistryBuilder().build(
    serviceComposition,
  );
  final dependencies = const RuntimeDependencyResolutionBuilder().build(
    registry: registry,
    runtimeComposition: composition,
  );
  final activation = const RuntimeActivationCoordinator().coordinate(
    dependencies,
  );
  final exposure = const RuntimeServiceExposureProjector().project(
    activationCoordination: activation,
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
  return _Fixture(
    composition: composition,
    validation: validation,
    delivery: delivery,
  );
}
