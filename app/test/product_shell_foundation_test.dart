import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/product_shell_contracts.dart';
import 'package:pool_os/contracts/runtime_activation_coordination_contracts.dart';
import 'package:pool_os/contracts/runtime_composition_contracts.dart';
import 'package:pool_os/contracts/runtime_delivery_projection_contracts.dart';
import 'package:pool_os/contracts/runtime_dependency_resolution_contracts.dart';
import 'package:pool_os/contracts/runtime_service_composition_contracts.dart';
import 'package:pool_os/contracts/runtime_service_exposure_contracts.dart';
import 'package:pool_os/contracts/runtime_service_registry_contracts.dart';

void main() {
  final runtimeComposition = const RuntimeCompositionEngine().compose(
    nodes: const [
      RuntimeNodeContract(
          id: 'a',
          kind: RuntimeNodeKind.session,
          sourceContractVersion: 1,
          sourceDigest: 'a'),
      RuntimeNodeContract(
          id: 'b',
          kind: RuntimeNodeKind.toolInvocation,
          sourceContractVersion: 1,
          sourceDigest: 'b'),
      RuntimeNodeContract(
          id: 'c',
          kind: RuntimeNodeKind.promptAssembly,
          sourceContractVersion: 1,
          sourceDigest: 'c'),
      RuntimeNodeContract(
          id: 'd',
          kind: RuntimeNodeKind.providerRequest,
          sourceContractVersion: 1,
          sourceDigest: 'd'),
    ],
    edges: const [
      RuntimeEdgeContract(fromId: 'a', toId: 'b'),
      RuntimeEdgeContract(fromId: 'b', toId: 'c'),
      RuntimeEdgeContract(fromId: 'c', toId: 'd'),
    ],
  );
  final serviceComposition =
      const RuntimeServiceCompositionEngine().compose(runtimeComposition);
  final registry =
      const RuntimeServiceRegistryBuilder().build(serviceComposition);
  final dependencies = const RuntimeDependencyResolutionBuilder().build(
    registry: registry,
    runtimeComposition: runtimeComposition,
  );
  final activation =
      const RuntimeActivationCoordinator().coordinate(dependencies);
  final exposure = const RuntimeServiceExposureProjector().project(
    activationCoordination: activation,
    registry: registry,
  );
  final delivery = const RuntimeDeliveryProjector().project(exposure);
  final policy = ProductNavigationPolicy.create(
    entries: const [
      ProductNavigationPolicyEntry(
          featureId: 'home',
          category: ProductNavigationCategory.home,
          position: 0,
          visible: true),
      ProductNavigationPolicyEntry(
          featureId: 'training',
          category: ProductNavigationCategory.training,
          position: 1,
          visible: true,
          parentFeatureId: 'home'),
      ProductNavigationPolicyEntry(
          featureId: 'coach',
          category: ProductNavigationCategory.coach,
          position: 2,
          visible: true,
          parentFeatureId: 'home'),
      ProductNavigationPolicyEntry(
          featureId: 'ai',
          category: ProductNavigationCategory.ai,
          position: 3,
          visible: true,
          parentFeatureId: 'coach'),
    ],
  );

  test('product shell is immutable, canonical, and deterministic', () {
    final first = const ProductShellBuilder()
        .build(exposure: exposure, delivery: delivery, policy: policy);
    final second = const ProductShellBuilder()
        .build(exposure: exposure, delivery: delivery, policy: policy);
    expect(second.toJson(), first.toJson());
    expect(first.nodes, hasLength(4));
    expect(first.edges, hasLength(3));
    expect(() => first.nodes.add(first.nodes.first), throwsUnsupportedError);
  });

  test('policy categories and parent topology are preserved', () {
    final result = const ProductShellBuilder()
        .build(exposure: exposure, delivery: delivery, policy: policy);
    expect(result.nodes.map((node) => node.category), [
      ProductNavigationCategory.home,
      ProductNavigationCategory.training,
      ProductNavigationCategory.coach,
      ProductNavigationCategory.ai,
    ]);
    expect(result.edges.last.parentFeatureId, 'coach');
    expect(result.edges.last.childFeatureId, 'ai');
  });

  test('shell binds exposure, delivery, and policy provenance', () {
    final result = const ProductShellBuilder()
        .build(exposure: exposure, delivery: delivery, policy: policy);
    expect(result.exposureDigest, exposure.digest);
    expect(result.deliveryDigest, delivery.digest);
    expect(result.policyDigest, policy.digest);
    expect(result.nodes.first.deliveryId, delivery.entries.first.deliveryId);
  });

  test('duplicate policy identity or position fails closed', () {
    expect(
      () => ProductNavigationPolicy.create(entries: const [
        ProductNavigationPolicyEntry(
            featureId: 'home',
            category: ProductNavigationCategory.home,
            position: 0,
            visible: true),
        ProductNavigationPolicyEntry(
            featureId: 'home',
            category: ProductNavigationCategory.coach,
            position: 1,
            visible: true),
      ]),
      throwsArgumentError,
    );
  });

  test('stale delivery or exposure projection fails closed', () {
    final other = const RuntimeDeliveryProjectionContractFactory().empty();
    expect(
      () => const ProductShellBuilder()
          .build(exposure: exposure, delivery: other, policy: policy),
      throwsArgumentError,
    );
  });

  test('missing navigation edge fails closed', () {
    final result = const ProductShellBuilder()
        .build(exposure: exposure, delivery: delivery, policy: policy);
    expect(
      () => ProductShellContract.create(
        exposure: exposure,
        delivery: delivery,
        policy: policy,
        nodes: result.nodes,
        edges: result.edges.take(2).toList(),
      ),
      throwsArgumentError,
    );
  });

  test('cyclic parent policy fails closed', () {
    expect(
      () => ProductNavigationPolicy.create(entries: const [
        ProductNavigationPolicyEntry(
            featureId: 'a',
            category: ProductNavigationCategory.home,
            position: 0,
            visible: true,
            parentFeatureId: 'b'),
        ProductNavigationPolicyEntry(
            featureId: 'b',
            category: ProductNavigationCategory.coach,
            position: 1,
            visible: true,
            parentFeatureId: 'a'),
      ]),
      throwsArgumentError,
    );
  });

  test('builder does not mutate authoritative inputs or policy', () {
    final beforeExposure = exposure.toJson();
    final beforeDelivery = delivery.toJson();
    final beforePolicy = policy.toJson();
    const ProductShellBuilder()
        .build(exposure: exposure, delivery: delivery, policy: policy);
    expect(exposure.toJson(), beforeExposure);
    expect(delivery.toJson(), beforeDelivery);
    expect(policy.toJson(), beforePolicy);
  });
}

class RuntimeDeliveryProjectionContractFactory {
  const RuntimeDeliveryProjectionContractFactory();

  RuntimeDeliveryProjectionContract empty() {
    final runtime = const RuntimeCompositionEngine().compose(
      nodes: const [
        RuntimeNodeContract(
            id: 'x',
            kind: RuntimeNodeKind.session,
            sourceContractVersion: 1,
            sourceDigest: 'x')
      ],
      edges: const [],
    );
    final service = const RuntimeServiceCompositionEngine().compose(runtime);
    final registry = const RuntimeServiceRegistryBuilder().build(service);
    final dependency = const RuntimeDependencyResolutionBuilder()
        .build(registry: registry, runtimeComposition: runtime);
    final activation =
        const RuntimeActivationCoordinator().coordinate(dependency);
    final exposure = const RuntimeServiceExposureProjector()
        .project(activationCoordination: activation, registry: registry);
    return const RuntimeDeliveryProjector().project(exposure);
  }
}
