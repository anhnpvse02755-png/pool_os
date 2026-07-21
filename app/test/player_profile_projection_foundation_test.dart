import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/player_model_contracts.dart';
import 'package:pool_os/contracts/player_profile_projection_contracts.dart';
import 'package:pool_os/contracts/product_shell_contracts.dart';
import 'package:pool_os/contracts/runtime_activation_coordination_contracts.dart';
import 'package:pool_os/contracts/runtime_composition_contracts.dart';
import 'package:pool_os/contracts/runtime_delivery_projection_contracts.dart';
import 'package:pool_os/contracts/runtime_dependency_resolution_contracts.dart';
import 'package:pool_os/contracts/runtime_service_composition_contracts.dart';
import 'package:pool_os/contracts/runtime_service_exposure_contracts.dart';
import 'package:pool_os/contracts/runtime_service_registry_contracts.dart';

void main() {
  final shell = _buildShell();
  final progress = _progress('player-1');

  test('projection is immutable, canonical, and deterministic', () {
    final first = const PlayerProfileProjector()
        .project(progress: progress, shell: shell);
    final second = const PlayerProfileProjector()
        .project(progress: progress, shell: shell);
    expect(second.toJson(), first.toJson());
    expect(first.entries.map((entry) => entry.position), [0, 1, 2, 3]);
    expect(
        () => first.entries.add(first.entries.first), throwsUnsupportedError);
  });

  test('entries bind player and product feature identities', () {
    final result = const PlayerProfileProjector()
        .project(progress: progress, shell: shell);
    expect(result.playerId, progress.playerId);
    expect(result.entries.map((entry) => entry.featureId),
        shell.nodes.map((node) => node.featureId));
    expect(
        result.entries.every((entry) => entry.playerId == 'player-1'), isTrue);
  });

  test('projection preserves progress and shell provenance', () {
    final result = const PlayerProfileProjector()
        .project(progress: progress, shell: shell);
    expect(result.progressDigest, progress.digest);
    expect(result.shellDigest, shell.digest);
    expect(
        result.entries
            .every((entry) => entry.progressDigest == progress.digest),
        isTrue);
    expect(result.entries.every((entry) => entry.shellDigest == shell.digest),
        isTrue);
  });

  test('foreign player entry fails closed', () {
    final result = const PlayerProfileProjector()
        .project(progress: progress, shell: shell);
    final entries = [...result.entries];
    entries[0] = PlayerProfileEntry(
      playerId: 'foreign-player',
      featureId: entries[0].featureId,
      position: entries[0].position,
      progressDigest: entries[0].progressDigest,
      shellDigest: entries[0].shellDigest,
    );
    expect(
      () => PlayerProfileProjectionContract.create(
          progress: progress, shell: shell, entries: entries),
      throwsArgumentError,
    );
  });

  test('stale progress or shell provenance fails closed', () {
    final result = const PlayerProfileProjector()
        .project(progress: progress, shell: shell);
    final entries = [...result.entries];
    entries[1] = PlayerProfileEntry(
      playerId: entries[1].playerId,
      featureId: entries[1].featureId,
      position: entries[1].position,
      progressDigest: 'stale-progress',
      shellDigest: 'stale-shell',
    );
    expect(
      () => PlayerProfileProjectionContract.create(
          progress: progress, shell: shell, entries: entries),
      throwsArgumentError,
    );
  });

  test('duplicate feature or canonical position fails closed', () {
    final result = const PlayerProfileProjector()
        .project(progress: progress, shell: shell);
    final entries = [...result.entries];
    entries[1] = PlayerProfileEntry(
      playerId: entries[1].playerId,
      featureId: entries[0].featureId,
      position: entries[0].position,
      progressDigest: entries[1].progressDigest,
      shellDigest: entries[1].shellDigest,
    );
    expect(
      () => PlayerProfileProjectionContract.create(
          progress: progress, shell: shell, entries: entries),
      throwsArgumentError,
    );
  });

  test('orphan feature fails closed', () {
    final result = const PlayerProfileProjector()
        .project(progress: progress, shell: shell);
    final entries = [...result.entries];
    entries[2] = PlayerProfileEntry(
      playerId: entries[2].playerId,
      featureId: 'orphan-feature',
      position: entries[2].position,
      progressDigest: entries[2].progressDigest,
      shellDigest: entries[2].shellDigest,
    );
    expect(
      () => PlayerProfileProjectionContract.create(
          progress: progress, shell: shell, entries: entries),
      throwsArgumentError,
    );
  });

  test('projector does not mutate progress or product shell', () {
    final beforeProgress = progress.toJson();
    final beforeShell = shell.toJson();
    const PlayerProfileProjector().project(progress: progress, shell: shell);
    expect(progress.toJson(), beforeProgress);
    expect(shell.toJson(), beforeShell);
  });
}

PlayerProgressSnapshot _progress(String playerId) =>
    PlayerProgressSnapshot.create(
      playerId: playerId,
      knowledgeVersion: 'knowledge/1.0.0',
      knowledgeDigest: 'knowledge-digest',
      sourceDecisionReferences: const ['decision-1'],
      state: PlayerModelState(
        mastery: const [],
        mistakes: const [],
        preferences: const [],
        historyReferences: const [],
      ),
    );

ProductShellContract _buildShell() {
  final runtime = const RuntimeCompositionEngine().compose(
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
  final services = const RuntimeServiceCompositionEngine().compose(runtime);
  final registry = const RuntimeServiceRegistryBuilder().build(services);
  final dependencies = const RuntimeDependencyResolutionBuilder()
      .build(registry: registry, runtimeComposition: runtime);
  final activation =
      const RuntimeActivationCoordinator().coordinate(dependencies);
  final exposure = const RuntimeServiceExposureProjector()
      .project(activationCoordination: activation, registry: registry);
  final delivery = const RuntimeDeliveryProjector().project(exposure);
  final policy = ProductNavigationPolicy.create(entries: const [
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
  ]);
  return const ProductShellBuilder()
      .build(exposure: exposure, delivery: delivery, policy: policy);
}
