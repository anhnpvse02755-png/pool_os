import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/infrastructure/production/deployment_topology_runtime.dart';

const performanceCapacityRuntimeVersion = 1;
const performanceCapacityPolicyVersion = 'performance-capacity-runtime/1.0.0';

enum PerformanceObjectiveDimension {
  responsiveness,
  throughput,
  concurrency,
  startupReadiness,
  resourceEfficiency,
  durabilityIntegrity,
  dependencyResilience,
  recoveryPerformance,
  clientExperience,
}

enum PerformanceWorkloadClass {
  interactiveCommandQuery,
  applicationStartup,
  evidenceIngestionReplay,
  projectionDecisionPipeline,
  knowledgeCompilePublication,
  externalProviderInteraction,
  operationalRecoveryAction,
  mixedProductionJourney,
}

enum PerformanceResourceClass {
  computeScheduling,
  memory,
  durableStorage,
  storageAccess,
  networkTransport,
  externalDependencyQuota,
  clientDevice,
  operationalCapacity,
  costEnvelope,
}

enum PerformanceBottleneckClass {
  applicationPath,
  domainAlgorithmProjection,
  durableStoreAccess,
  transportEdge,
  externalProviderQuota,
  clientDevice,
  operationalProcess,
  crossBoundaryContention,
}

enum PerformanceEvidenceClass {
  objectiveDefinition,
  workloadModel,
  environmentEquivalence,
  validationPlan,
  resultRecord,
  bottleneckAssessment,
  capacityDecision,
  growthForecast,
  optimizationProof,
}

class PerformanceCapacityReference {
  const PerformanceCapacityReference._({
    required this.category,
    required this.referenceId,
    required this.ownerId,
    required this.evidenceIdentity,
    required this.definitionVersion,
    required this.digest,
  });

  factory PerformanceCapacityReference.create({
    required String category,
    required String referenceId,
    required String ownerId,
    required String evidenceIdentity,
    required String definitionVersion,
  }) {
    for (final value in [
      category,
      referenceId,
      ownerId,
      evidenceIdentity,
      definitionVersion,
    ]) {
      if (value.trim().isEmpty || value != value.trim()) {
        throw ArgumentError('Performance reference is not canonical.');
      }
    }
    final payload = {
      'category': category,
      'referenceId': referenceId,
      'ownerId': ownerId,
      'evidenceIdentity': evidenceIdentity,
      'definitionVersion': definitionVersion,
    };
    return PerformanceCapacityReference._(
      category: category,
      referenceId: referenceId,
      ownerId: ownerId,
      evidenceIdentity: evidenceIdentity,
      definitionVersion: definitionVersion,
      digest: _digest(payload),
    );
  }

  final String category;
  final String referenceId;
  final String ownerId;
  final String evidenceIdentity;
  final String definitionVersion;
  final String digest;

  Map<String, dynamic> toJson() => {
        'category': category,
        'referenceId': referenceId,
        'ownerId': ownerId,
        'evidenceIdentity': evidenceIdentity,
        'definitionVersion': definitionVersion,
        'digest': digest,
      };
}

class PerformanceCapacityRequest {
  PerformanceCapacityRequest._({
    required this.performanceId,
    required this.performanceVersion,
    required this.topologyId,
    required this.topologyDigest,
    required this.artifactIdentityDigest,
    required List<PerformanceCapacityReference> objectives,
    required List<PerformanceCapacityReference> workloads,
    required List<PerformanceCapacityReference> resources,
    required List<PerformanceCapacityReference> bottlenecks,
    required List<PerformanceCapacityReference> evidenceReferences,
    required this.provenanceDigest,
    required this.digest,
  })  : objectives = List.unmodifiable(objectives),
        workloads = List.unmodifiable(workloads),
        resources = List.unmodifiable(resources),
        bottlenecks = List.unmodifiable(bottlenecks),
        evidenceReferences = List.unmodifiable(evidenceReferences);

  factory PerformanceCapacityRequest.create({
    required String performanceId,
    required String performanceVersion,
    required DeploymentTopologyRecord topology,
    required Iterable<PerformanceCapacityReference> objectives,
    required Iterable<PerformanceCapacityReference> workloads,
    required Iterable<PerformanceCapacityReference> resources,
    required Iterable<PerformanceCapacityReference> bottlenecks,
    required Iterable<PerformanceCapacityReference> evidenceReferences,
  }) {
    _requireValue(performanceId, 'Performance ID');
    _requireValue(performanceVersion, 'Performance version');
    _requireValue(topology.id, 'Topology ID');
    _requireValue(topology.digest, 'Topology digest');
    _requireValue(topology.artifactIdentityDigest, 'Artifact identity digest');
    final objectiveItems = _canonicalize(objectives, [
      for (final item in PerformanceObjectiveDimension.values)
        'objective.${item.name}',
    ]);
    final workloadItems = _canonicalize(workloads, [
      for (final item in PerformanceWorkloadClass.values)
        'workload.${item.name}',
    ]);
    final resourceItems = _canonicalize(resources, [
      for (final item in PerformanceResourceClass.values)
        'resource.${item.name}',
    ]);
    final bottleneckItems = _canonicalize(bottlenecks, [
      for (final item in PerformanceBottleneckClass.values)
        'bottleneck.${item.name}',
    ]);
    final evidenceItems = _canonicalize(evidenceReferences, [
      for (final item in PerformanceEvidenceClass.values)
        'evidence.${item.name}',
    ]);
    final provenancePayload = {
      'topologyDigest': topology.digest,
      'artifactIdentityDigest': topology.artifactIdentityDigest,
      'objectives': objectiveItems.map((item) => item.toJson()).toList(),
      'workloads': workloadItems.map((item) => item.toJson()).toList(),
      'resources': resourceItems.map((item) => item.toJson()).toList(),
      'bottlenecks': bottleneckItems.map((item) => item.toJson()).toList(),
      'evidenceReferences': evidenceItems.map((item) => item.toJson()).toList(),
    };
    final provenanceDigest = _digest(provenancePayload);
    final payload = {
      'version': performanceCapacityRuntimeVersion,
      'policyVersion': performanceCapacityPolicyVersion,
      'performanceId': performanceId,
      'performanceVersion': performanceVersion,
      'topologyId': topology.id,
      ...provenancePayload,
      'provenanceDigest': provenanceDigest,
    };
    return PerformanceCapacityRequest._(
      performanceId: performanceId,
      performanceVersion: performanceVersion,
      topologyId: topology.id,
      topologyDigest: topology.digest,
      artifactIdentityDigest: topology.artifactIdentityDigest,
      objectives: objectiveItems,
      workloads: workloadItems,
      resources: resourceItems,
      bottlenecks: bottleneckItems,
      evidenceReferences: evidenceItems,
      provenanceDigest: provenanceDigest,
      digest: _digest(payload),
    );
  }

  final String performanceId;
  final String performanceVersion;
  final String topologyId;
  final String topologyDigest;
  final String artifactIdentityDigest;
  final List<PerformanceCapacityReference> objectives;
  final List<PerformanceCapacityReference> workloads;
  final List<PerformanceCapacityReference> resources;
  final List<PerformanceCapacityReference> bottlenecks;
  final List<PerformanceCapacityReference> evidenceReferences;
  final String provenanceDigest;
  final String digest;
}

class PerformanceCapacityAuthorization {
  const PerformanceCapacityAuthorization._({
    required this.requestDigest,
    required this.topologyDigest,
    required this.provenanceDigest,
    required this.digest,
  });

  factory PerformanceCapacityAuthorization.create(
    PerformanceCapacityRequest request,
  ) {
    final payload = {
      'version': performanceCapacityRuntimeVersion,
      'requestDigest': request.digest,
      'topologyDigest': request.topologyDigest,
      'provenanceDigest': request.provenanceDigest,
    };
    return PerformanceCapacityAuthorization._(
      requestDigest: request.digest,
      topologyDigest: request.topologyDigest,
      provenanceDigest: request.provenanceDigest,
      digest: _digest(payload),
    );
  }

  final String requestDigest;
  final String topologyDigest;
  final String provenanceDigest;
  final String digest;
}

class PerformanceCapacityRecord {
  PerformanceCapacityRecord._({
    required this.id,
    required this.performanceVersion,
    required this.topologyId,
    required this.topologyDigest,
    required this.artifactIdentityDigest,
    required List<PerformanceCapacityReference> objectives,
    required List<PerformanceCapacityReference> workloads,
    required List<PerformanceCapacityReference> resources,
    required List<PerformanceCapacityReference> bottlenecks,
    required List<PerformanceCapacityReference> evidenceReferences,
    required this.requestDigest,
    required this.authorizationDigest,
    required this.provenanceDigest,
    required this.digest,
  })  : objectives = List.unmodifiable(objectives),
        workloads = List.unmodifiable(workloads),
        resources = List.unmodifiable(resources),
        bottlenecks = List.unmodifiable(bottlenecks),
        evidenceReferences = List.unmodifiable(evidenceReferences);

  final String id;
  final String performanceVersion;
  final String topologyId;
  final String topologyDigest;
  final String artifactIdentityDigest;
  final List<PerformanceCapacityReference> objectives;
  final List<PerformanceCapacityReference> workloads;
  final List<PerformanceCapacityReference> resources;
  final List<PerformanceCapacityReference> bottlenecks;
  final List<PerformanceCapacityReference> evidenceReferences;
  final String requestDigest;
  final String authorizationDigest;
  final String provenanceDigest;
  final String digest;

  Map<String, dynamic> toJson() => {
        'version': performanceCapacityRuntimeVersion,
        'policyVersion': performanceCapacityPolicyVersion,
        'id': id,
        'performanceVersion': performanceVersion,
        'topologyId': topologyId,
        'topologyDigest': topologyDigest,
        'artifactIdentityDigest': artifactIdentityDigest,
        'objectives': objectives.map((item) => item.toJson()).toList(),
        'workloads': workloads.map((item) => item.toJson()).toList(),
        'resources': resources.map((item) => item.toJson()).toList(),
        'bottlenecks': bottlenecks.map((item) => item.toJson()).toList(),
        'evidenceReferences':
            evidenceReferences.map((item) => item.toJson()).toList(),
        'requestDigest': requestDigest,
        'authorizationDigest': authorizationDigest,
        'provenanceDigest': provenanceDigest,
        'digest': digest,
      };
}

class PerformanceCapacityRuntime {
  const PerformanceCapacityRuntime();

  PerformanceCapacityRecord assemble({
    required PerformanceCapacityRequest request,
    required PerformanceCapacityAuthorization authorization,
  }) {
    _validateRequest(request);
    final expected = PerformanceCapacityAuthorization.create(request);
    if (authorization.requestDigest != expected.requestDigest ||
        authorization.topologyDigest != expected.topologyDigest ||
        authorization.provenanceDigest != expected.provenanceDigest ||
        authorization.digest != expected.digest) {
      throw ArgumentError('Performance authorization is stale.');
    }
    final payload = {
      'version': performanceCapacityRuntimeVersion,
      'policyVersion': performanceCapacityPolicyVersion,
      'performanceId': request.performanceId,
      'performanceVersion': request.performanceVersion,
      'topologyId': request.topologyId,
      'topologyDigest': request.topologyDigest,
      'artifactIdentityDigest': request.artifactIdentityDigest,
      'objectives': request.objectives.map((item) => item.toJson()).toList(),
      'workloads': request.workloads.map((item) => item.toJson()).toList(),
      'resources': request.resources.map((item) => item.toJson()).toList(),
      'bottlenecks': request.bottlenecks.map((item) => item.toJson()).toList(),
      'evidenceReferences':
          request.evidenceReferences.map((item) => item.toJson()).toList(),
      'requestDigest': request.digest,
      'authorizationDigest': authorization.digest,
      'provenanceDigest': request.provenanceDigest,
    };
    final digest = _digest(payload);
    return PerformanceCapacityRecord._(
      id: '${request.performanceId}.${digest.substring(0, 16)}',
      performanceVersion: request.performanceVersion,
      topologyId: request.topologyId,
      topologyDigest: request.topologyDigest,
      artifactIdentityDigest: request.artifactIdentityDigest,
      objectives: request.objectives,
      workloads: request.workloads,
      resources: request.resources,
      bottlenecks: request.bottlenecks,
      evidenceReferences: request.evidenceReferences,
      requestDigest: request.digest,
      authorizationDigest: authorization.digest,
      provenanceDigest: request.provenanceDigest,
      digest: digest,
    );
  }

  PerformanceCapacityRecord replay({
    required PerformanceCapacityRequest request,
    required PerformanceCapacityAuthorization authorization,
    required PerformanceCapacityRecord expected,
  }) {
    final replayed = assemble(request: request, authorization: authorization);
    if (jsonEncode(replayed.toJson()) != jsonEncode(expected.toJson())) {
      throw StateError('Performance replay does not match.');
    }
    return replayed;
  }
}

List<PerformanceCapacityReference> _canonicalize(
  Iterable<PerformanceCapacityReference> input,
  List<String> expected,
) {
  final byCategory = <String, PerformanceCapacityReference>{};
  final references = <String>{};
  final evidence = <String>{};
  for (final item in input) {
    final canonical = PerformanceCapacityReference.create(
      category: item.category,
      referenceId: item.referenceId,
      ownerId: item.ownerId,
      evidenceIdentity: item.evidenceIdentity,
      definitionVersion: item.definitionVersion,
    );
    if (item.digest != canonical.digest ||
        byCategory.containsKey(item.category) ||
        !references.add(item.referenceId) ||
        !evidence.add(item.evidenceIdentity)) {
      throw ArgumentError('Performance provenance is invalid.');
    }
    byCategory[item.category] = item;
  }
  if (byCategory.length != expected.length ||
      expected.any((category) => !byCategory.containsKey(category))) {
    throw ArgumentError('Performance catalog coverage is incomplete.');
  }
  return List.unmodifiable(
      [for (final category in expected) byCategory[category]!]);
}

void _validateRequest(PerformanceCapacityRequest request) {
  _canonicalize(request.objectives, [
    for (final item in PerformanceObjectiveDimension.values)
      'objective.${item.name}',
  ]);
  _canonicalize(request.workloads, [
    for (final item in PerformanceWorkloadClass.values) 'workload.${item.name}',
  ]);
  _canonicalize(request.resources, [
    for (final item in PerformanceResourceClass.values) 'resource.${item.name}',
  ]);
  _canonicalize(request.bottlenecks, [
    for (final item in PerformanceBottleneckClass.values)
      'bottleneck.${item.name}',
  ]);
  _canonicalize(request.evidenceReferences, [
    for (final item in PerformanceEvidenceClass.values) 'evidence.${item.name}',
  ]);
}

void _requireValue(String value, String field) {
  if (value.trim().isEmpty || value != value.trim()) {
    throw ArgumentError('$field must be a non-empty canonical value.');
  }
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
