import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/application/flutter_application_startup_runtime.dart';
import 'package:pool_os/application/infrastructure_integration_validation_planner.dart';

const productionRuntimeVersion = 1;
const productionRuntimePolicyVersion = 'production-runtime/1.0.0';

enum ProductionRuntimeLogPhase {
  validateAuthorization,
  orderRuntime,
  bindInfrastructureCoverage,
  invokeProductionRuntimeExecutor,
  completed,
}

class ProductionRuntimeAuthorization {
  const ProductionRuntimeAuthorization._({
    required this.flutterStartupStateId,
    required this.flutterStartupStateDigest,
    required this.infrastructurePlanId,
    required this.infrastructurePlanDigest,
    required this.digest,
  });

  factory ProductionRuntimeAuthorization.create({
    required RuntimeFlutterStartupState flutterStartupState,
    required InfrastructureIntegrationValidationPlan infrastructurePlan,
  }) {
    if (flutterStartupState.id.isEmpty ||
        flutterStartupState.digest.isEmpty ||
        flutterStartupState.entries.isEmpty ||
        infrastructurePlan.id.isEmpty ||
        infrastructurePlan.digest.isEmpty ||
        infrastructurePlan.entries.isEmpty) {
      throw ArgumentError('Production runtime authorization is incomplete.');
    }
    final payload = {
      'version': productionRuntimeVersion,
      'flutterStartupStateId': flutterStartupState.id,
      'flutterStartupStateDigest': flutterStartupState.digest,
      'infrastructurePlanId': infrastructurePlan.id,
      'infrastructurePlanDigest': infrastructurePlan.digest,
    };
    return ProductionRuntimeAuthorization._(
      flutterStartupStateId: flutterStartupState.id,
      flutterStartupStateDigest: flutterStartupState.digest,
      infrastructurePlanId: infrastructurePlan.id,
      infrastructurePlanDigest: infrastructurePlan.digest,
      digest: _digest(payload),
    );
  }

  final String flutterStartupStateId;
  final String flutterStartupStateDigest;
  final String infrastructurePlanId;
  final String infrastructurePlanDigest;
  final String digest;
}

abstract interface class ProductionRuntimeExecutor {
  Future<List<ProductionRuntimeResult>> execute(
    ProductionRuntimeRequest request,
  );
}

class ProductionRuntimeTarget {
  const ProductionRuntimeTarget({
    required this.runtimeTargetId,
    required this.featureId,
    required this.canonicalPosition,
    required this.startupEntryDigest,
    required this.infrastructureEntryDigest,
    required this.authorizationDigest,
  });

  final String runtimeTargetId;
  final String featureId;
  final int canonicalPosition;
  final String startupEntryDigest;
  final String infrastructureEntryDigest;
  final String authorizationDigest;

  Map<String, dynamic> toJson() => {
        'runtimeTargetId': runtimeTargetId,
        'featureId': featureId,
        'canonicalPosition': canonicalPosition,
        'startupEntryDigest': startupEntryDigest,
        'infrastructureEntryDigest': infrastructureEntryDigest,
        'authorizationDigest': authorizationDigest,
      };
}

class ProductionRuntimeRequest {
  ProductionRuntimeRequest._({
    required this.authorizationDigest,
    required List<ProductionRuntimeTarget> targets,
    required this.digest,
  }) : targets = List.unmodifiable(targets);
  final String authorizationDigest;
  final List<ProductionRuntimeTarget> targets;
  final String digest;
}

class ProductionRuntimeResult {
  const ProductionRuntimeResult._({
    required this.runtimeTargetId,
    required this.runtimeHandleId,
    required this.requestDigest,
    required this.digest,
  });

  factory ProductionRuntimeResult.create({
    required String runtimeTargetId,
    required String runtimeHandleId,
    required String requestDigest,
  }) {
    if (runtimeTargetId.isEmpty ||
        runtimeHandleId.isEmpty ||
        requestDigest.isEmpty) {
      throw ArgumentError('Production runtime result is incomplete.');
    }
    final payload = {
      'runtimeTargetId': runtimeTargetId,
      'runtimeHandleId': runtimeHandleId,
      'requestDigest': requestDigest,
    };
    return ProductionRuntimeResult._(
      runtimeTargetId: runtimeTargetId,
      runtimeHandleId: runtimeHandleId,
      requestDigest: requestDigest,
      digest: _digest(payload),
    );
  }
  final String runtimeTargetId;
  final String runtimeHandleId;
  final String requestDigest;
  final String digest;
}

class ProductionRuntimeEntry {
  const ProductionRuntimeEntry._({
    required this.runtimeTargetId,
    required this.featureId,
    required this.canonicalPosition,
    required this.runtimeHandleId,
    required this.startupEntryDigest,
    required this.infrastructureEntryDigest,
    required this.resultDigest,
    required this.digest,
  });
  final String runtimeTargetId;
  final String featureId;
  final int canonicalPosition;
  final String runtimeHandleId;
  final String startupEntryDigest;
  final String infrastructureEntryDigest;
  final String resultDigest;
  final String digest;

  Map<String, dynamic> toJson() => {
        'runtimeTargetId': runtimeTargetId,
        'featureId': featureId,
        'canonicalPosition': canonicalPosition,
        'runtimeHandleId': runtimeHandleId,
        'startupEntryDigest': startupEntryDigest,
        'infrastructureEntryDigest': infrastructureEntryDigest,
        'resultDigest': resultDigest,
        'digest': digest,
      };
}

class ProductionRuntimeState {
  ProductionRuntimeState._({
    required this.id,
    required this.authorizationDigest,
    required this.flutterStartupStateId,
    required this.flutterStartupStateDigest,
    required this.infrastructurePlanId,
    required this.infrastructurePlanDigest,
    required this.requestDigest,
    required List<ProductionRuntimeEntry> entries,
    required List<ProductionRuntimeLogPhase> log,
    required this.digest,
  })  : entries = List.unmodifiable(entries),
        log = List.unmodifiable(log);
  final String id;
  final String authorizationDigest;
  final String flutterStartupStateId;
  final String flutterStartupStateDigest;
  final String infrastructurePlanId;
  final String infrastructurePlanDigest;
  final String requestDigest;
  final List<ProductionRuntimeEntry> entries;
  final List<ProductionRuntimeLogPhase> log;
  final String digest;

  Map<String, dynamic> toJson() => {
        'version': productionRuntimeVersion,
        'policyVersion': productionRuntimePolicyVersion,
        'id': id,
        'authorizationDigest': authorizationDigest,
        'flutterStartupStateId': flutterStartupStateId,
        'flutterStartupStateDigest': flutterStartupStateDigest,
        'infrastructurePlanId': infrastructurePlanId,
        'infrastructurePlanDigest': infrastructurePlanDigest,
        'requestDigest': requestDigest,
        'entries': entries.map((entry) => entry.toJson()).toList(),
        'log': log.map((phase) => phase.name).toList(),
        'digest': digest,
      };
}

class ProductionRuntimeOrchestrator {
  const ProductionRuntimeOrchestrator();

  Future<ProductionRuntimeState> execute({
    required RuntimeFlutterStartupState flutterStartupState,
    required InfrastructureIntegrationValidationPlan infrastructurePlan,
    required ProductionRuntimeAuthorization authorization,
    required ProductionRuntimeExecutor executor,
  }) async {
    final expectedAuthorization = ProductionRuntimeAuthorization.create(
      flutterStartupState: flutterStartupState,
      infrastructurePlan: infrastructurePlan,
    );
    if (authorization.flutterStartupStateId !=
            expectedAuthorization.flutterStartupStateId ||
        authorization.flutterStartupStateDigest !=
            expectedAuthorization.flutterStartupStateDigest ||
        authorization.infrastructurePlanId !=
            expectedAuthorization.infrastructurePlanId ||
        authorization.infrastructurePlanDigest !=
            expectedAuthorization.infrastructurePlanDigest ||
        authorization.digest != expectedAuthorization.digest) {
      throw ArgumentError('Production runtime authorization is invalid.');
    }
    final startup = [...flutterStartupState.entries]
      ..sort((left, right) => left.position.compareTo(right.position));
    final infrastructure = [...infrastructurePlan.entries]
      ..sort((left, right) => left.position.compareTo(right.position));
    if (startup.length != infrastructure.length) {
      throw ArgumentError('Production runtime coverage is incomplete.');
    }
    final features = <String>{};
    final targets = <ProductionRuntimeTarget>[];
    for (var position = 0; position < startup.length; position++) {
      final startupEntry = startup[position];
      final infrastructureEntry = infrastructure[position];
      final expected = InfrastructureIntegrationValidationEntry.create(
        featureId: infrastructureEntry.featureId,
        packagingDeploymentAdapterEntryId:
            infrastructureEntry.packagingDeploymentAdapterEntryId,
        position: position,
        packagingDeploymentAdapterPlanDigest:
            infrastructurePlan.packagingDeploymentAdapterPlanDigest,
        productionReadinessProjectionDigest:
            infrastructurePlan.productionReadinessProjectionDigest,
      );
      if (startupEntry.position != position ||
          infrastructureEntry.position != position ||
          startupEntry.featureId != infrastructureEntry.featureId ||
          infrastructureEntry.infrastructureIntegrationValidationEntryId !=
              expected.infrastructureIntegrationValidationEntryId ||
          infrastructureEntry.provenanceDigest != expected.provenanceDigest ||
          infrastructureEntry.digest != expected.digest ||
          !features.add(startupEntry.featureId)) {
        throw ArgumentError('Production runtime provenance is invalid.');
      }
      targets.add(ProductionRuntimeTarget(
        runtimeTargetId: 'production-runtime-target.${startupEntry.featureId}',
        featureId: startupEntry.featureId,
        canonicalPosition: position,
        startupEntryDigest: startupEntry.digest,
        infrastructureEntryDigest: infrastructureEntry.digest,
        authorizationDigest: authorization.digest,
      ));
    }
    final requestPayload = {
      'version': productionRuntimeVersion,
      'authorizationDigest': authorization.digest,
      'targets': targets.map((target) => target.toJson()).toList(),
    };
    final request = ProductionRuntimeRequest._(
      authorizationDigest: authorization.digest,
      targets: targets,
      digest: _digest(requestPayload),
    );
    final results = await executor.execute(request);
    final byId = <String, ProductionRuntimeResult>{};
    final handles = <String>{};
    for (final result in results) {
      final expected = ProductionRuntimeResult.create(
        runtimeTargetId: result.runtimeTargetId,
        runtimeHandleId: result.runtimeHandleId,
        requestDigest: request.digest,
      );
      if (result.requestDigest != request.digest ||
          result.digest != expected.digest ||
          byId.containsKey(result.runtimeTargetId) ||
          !handles.add(result.runtimeHandleId)) {
        throw StateError('Production runtime result is invalid.');
      }
      byId[result.runtimeTargetId] = result;
    }
    final targetIds = targets.map((target) => target.runtimeTargetId).toSet();
    if (byId.length != targets.length ||
        byId.keys.any((id) => !targetIds.contains(id))) {
      throw StateError('Production runtime result coverage is invalid.');
    }
    final entries = <ProductionRuntimeEntry>[];
    for (final target in targets) {
      final result = byId[target.runtimeTargetId]!;
      final payload = {
        ...target.toJson(),
        'runtimeHandleId': result.runtimeHandleId,
        'resultDigest': result.digest,
      };
      entries.add(ProductionRuntimeEntry._(
        runtimeTargetId: target.runtimeTargetId,
        featureId: target.featureId,
        canonicalPosition: target.canonicalPosition,
        runtimeHandleId: result.runtimeHandleId,
        startupEntryDigest: target.startupEntryDigest,
        infrastructureEntryDigest: target.infrastructureEntryDigest,
        resultDigest: result.digest,
        digest: _digest(payload),
      ));
    }
    final payload = {
      ...requestPayload,
      'requestDigest': request.digest,
      'entries': entries.map((entry) => entry.toJson()).toList(),
      'log':
          ProductionRuntimeLogPhase.values.map((phase) => phase.name).toList(),
    };
    final digest = _digest(payload);
    return ProductionRuntimeState._(
      id: 'production-runtime.${digest.substring(0, 16)}',
      authorizationDigest: authorization.digest,
      flutterStartupStateId: flutterStartupState.id,
      flutterStartupStateDigest: flutterStartupState.digest,
      infrastructurePlanId: infrastructurePlan.id,
      infrastructurePlanDigest: infrastructurePlan.digest,
      requestDigest: request.digest,
      entries: entries,
      log: ProductionRuntimeLogPhase.values,
      digest: digest,
    );
  }
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
