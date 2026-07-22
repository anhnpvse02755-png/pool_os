import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/infrastructure/production/deployment_topology_runtime.dart';

const operationsRuntimeVersion = 1;
const operationsRuntimePolicyVersion = 'operations-runtime/1.0.0';

enum ProductionOperatingState {
  normal,
  degraded,
  incident,
  maintenance,
  recovery,
}

enum OperationsWorkstreamKind {
  stateCoordination,
  dutyOnCall,
  incidentManagement,
  escalation,
  runbookFramework,
  operationalEvidence,
  kpiSliFramework,
  audit,
  handover,
}

enum OperationsEvidenceKind {
  dutyHandover,
  operationalEvent,
  incident,
  changeMaintenance,
  escalationCommunication,
  recoveryHandoff,
  readinessKpiSli,
  auditAccess,
}

enum OperationsRunbookScenario {
  applicationStartup,
  ingress,
  durableStore,
  provider,
  knowledgeCompatibility,
  evidenceIntegrity,
  securityPrivacy,
  releaseRollback,
  recovery,
  controlPlaneDegradation,
}

enum OperationsIncidentSeverity { low, medium, high, critical }

class OperationsOwnedReference {
  const OperationsOwnedReference._({
    required this.category,
    required this.semanticId,
    required this.ownerId,
    required this.schemaVersion,
    required this.digest,
  });

  factory OperationsOwnedReference.create({
    required String category,
    required String semanticId,
    required String ownerId,
    required String schemaVersion,
  }) {
    for (final value in [category, semanticId, ownerId, schemaVersion]) {
      if (value.trim().isEmpty || value != value.trim()) {
        throw ArgumentError('Operations reference is not canonical.');
      }
    }
    final payload = {
      'category': category,
      'semanticId': semanticId,
      'ownerId': ownerId,
      'schemaVersion': schemaVersion,
    };
    return OperationsOwnedReference._(
      category: category,
      semanticId: semanticId,
      ownerId: ownerId,
      schemaVersion: schemaVersion,
      digest: _digest(payload),
    );
  }

  final String category;
  final String semanticId;
  final String ownerId;
  final String schemaVersion;
  final String digest;

  Map<String, dynamic> toJson() => {
        'category': category,
        'semanticId': semanticId,
        'ownerId': ownerId,
        'schemaVersion': schemaVersion,
        'digest': digest,
      };
}

class OperationsRuntimeRequest {
  OperationsRuntimeRequest._({
    required this.operationsId,
    required this.operationsVersion,
    required this.topologyId,
    required this.topologyDigest,
    required this.artifactIdentityDigest,
    required this.initialState,
    required List<OperationsOwnedReference> workstreams,
    required List<OperationsOwnedReference> evidenceSchemas,
    required List<OperationsOwnedReference> runbookReferences,
    required List<OperationsOwnedReference> escalationRules,
    required this.provenanceDigest,
    required this.digest,
  })  : workstreams = List.unmodifiable(workstreams),
        evidenceSchemas = List.unmodifiable(evidenceSchemas),
        runbookReferences = List.unmodifiable(runbookReferences),
        escalationRules = List.unmodifiable(escalationRules);

  factory OperationsRuntimeRequest.create({
    required String operationsId,
    required String operationsVersion,
    required DeploymentTopologyRecord topology,
    required ProductionOperatingState initialState,
    required Iterable<OperationsOwnedReference> workstreams,
    required Iterable<OperationsOwnedReference> evidenceSchemas,
    required Iterable<OperationsOwnedReference> runbookReferences,
    required Iterable<OperationsOwnedReference> escalationRules,
  }) {
    _requireValue(operationsId, 'Operations ID');
    _requireValue(operationsVersion, 'Operations version');
    _requireValue(topology.id, 'Topology ID');
    _requireValue(topology.digest, 'Topology digest');
    _requireValue(topology.artifactIdentityDigest, 'Artifact identity digest');
    final canonicalWorkstreams = _canonicalize(
      workstreams,
      [
        for (final kind in OperationsWorkstreamKind.values)
          'workstream.${kind.name}'
      ],
    );
    final canonicalEvidence = _canonicalize(
      evidenceSchemas,
      [
        for (final kind in OperationsEvidenceKind.values)
          'evidence.${kind.name}'
      ],
    );
    final canonicalRunbooks = _canonicalize(
      runbookReferences,
      [
        for (final kind in OperationsRunbookScenario.values)
          'runbook.${kind.name}'
      ],
    );
    final canonicalEscalations = _canonicalize(
      escalationRules,
      [
        for (final kind in OperationsIncidentSeverity.values)
          'severity.${kind.name}'
      ],
    );
    final provenancePayload = {
      'topologyDigest': topology.digest,
      'artifactIdentityDigest': topology.artifactIdentityDigest,
      'workstreams': canonicalWorkstreams.map((item) => item.toJson()).toList(),
      'evidenceSchemas':
          canonicalEvidence.map((item) => item.toJson()).toList(),
      'runbookReferences':
          canonicalRunbooks.map((item) => item.toJson()).toList(),
      'escalationRules':
          canonicalEscalations.map((item) => item.toJson()).toList(),
    };
    final provenanceDigest = _digest(provenancePayload);
    final payload = {
      'version': operationsRuntimeVersion,
      'policyVersion': operationsRuntimePolicyVersion,
      'operationsId': operationsId,
      'operationsVersion': operationsVersion,
      'topologyId': topology.id,
      'topologyDigest': topology.digest,
      'artifactIdentityDigest': topology.artifactIdentityDigest,
      'initialState': initialState.name,
      'supportedStates':
          ProductionOperatingState.values.map((state) => state.name).toList(),
      'provenanceDigest': provenanceDigest,
      'workstreams': canonicalWorkstreams.map((item) => item.toJson()).toList(),
      'evidenceSchemas':
          canonicalEvidence.map((item) => item.toJson()).toList(),
      'runbookReferences':
          canonicalRunbooks.map((item) => item.toJson()).toList(),
      'escalationRules':
          canonicalEscalations.map((item) => item.toJson()).toList(),
    };
    return OperationsRuntimeRequest._(
      operationsId: operationsId,
      operationsVersion: operationsVersion,
      topologyId: topology.id,
      topologyDigest: topology.digest,
      artifactIdentityDigest: topology.artifactIdentityDigest,
      initialState: initialState,
      workstreams: canonicalWorkstreams,
      evidenceSchemas: canonicalEvidence,
      runbookReferences: canonicalRunbooks,
      escalationRules: canonicalEscalations,
      provenanceDigest: provenanceDigest,
      digest: _digest(payload),
    );
  }

  final String operationsId;
  final String operationsVersion;
  final String topologyId;
  final String topologyDigest;
  final String artifactIdentityDigest;
  final ProductionOperatingState initialState;
  final List<OperationsOwnedReference> workstreams;
  final List<OperationsOwnedReference> evidenceSchemas;
  final List<OperationsOwnedReference> runbookReferences;
  final List<OperationsOwnedReference> escalationRules;
  final String provenanceDigest;
  final String digest;
}

class OperationsRuntimeAuthorization {
  const OperationsRuntimeAuthorization._({
    required this.requestDigest,
    required this.topologyDigest,
    required this.provenanceDigest,
    required this.digest,
  });

  factory OperationsRuntimeAuthorization.create(
      OperationsRuntimeRequest request) {
    final payload = {
      'version': operationsRuntimeVersion,
      'requestDigest': request.digest,
      'topologyDigest': request.topologyDigest,
      'provenanceDigest': request.provenanceDigest,
    };
    return OperationsRuntimeAuthorization._(
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

class OperationsRuntimeRecord {
  OperationsRuntimeRecord._({
    required this.id,
    required this.operationsVersion,
    required this.topologyId,
    required this.topologyDigest,
    required this.artifactIdentityDigest,
    required this.initialState,
    required List<ProductionOperatingState> supportedStates,
    required List<OperationsOwnedReference> workstreams,
    required List<OperationsOwnedReference> evidenceSchemas,
    required List<OperationsOwnedReference> runbookReferences,
    required List<OperationsOwnedReference> escalationRules,
    required this.requestDigest,
    required this.authorizationDigest,
    required this.provenanceDigest,
    required this.digest,
  })  : supportedStates = List.unmodifiable(supportedStates),
        workstreams = List.unmodifiable(workstreams),
        evidenceSchemas = List.unmodifiable(evidenceSchemas),
        runbookReferences = List.unmodifiable(runbookReferences),
        escalationRules = List.unmodifiable(escalationRules);

  final String id;
  final String operationsVersion;
  final String topologyId;
  final String topologyDigest;
  final String artifactIdentityDigest;
  final ProductionOperatingState initialState;
  final List<ProductionOperatingState> supportedStates;
  final List<OperationsOwnedReference> workstreams;
  final List<OperationsOwnedReference> evidenceSchemas;
  final List<OperationsOwnedReference> runbookReferences;
  final List<OperationsOwnedReference> escalationRules;
  final String requestDigest;
  final String authorizationDigest;
  final String provenanceDigest;
  final String digest;

  Map<String, dynamic> toJson() => {
        'version': operationsRuntimeVersion,
        'policyVersion': operationsRuntimePolicyVersion,
        'id': id,
        'operationsVersion': operationsVersion,
        'topologyId': topologyId,
        'topologyDigest': topologyDigest,
        'artifactIdentityDigest': artifactIdentityDigest,
        'initialState': initialState.name,
        'supportedStates': supportedStates.map((state) => state.name).toList(),
        'workstreams': workstreams.map((item) => item.toJson()).toList(),
        'evidenceSchemas':
            evidenceSchemas.map((item) => item.toJson()).toList(),
        'runbookReferences':
            runbookReferences.map((item) => item.toJson()).toList(),
        'escalationRules':
            escalationRules.map((item) => item.toJson()).toList(),
        'requestDigest': requestDigest,
        'authorizationDigest': authorizationDigest,
        'provenanceDigest': provenanceDigest,
        'digest': digest,
      };
}

class OperationsRuntime {
  const OperationsRuntime();

  OperationsRuntimeRecord assemble({
    required OperationsRuntimeRequest request,
    required OperationsRuntimeAuthorization authorization,
  }) {
    final expectedAuthorization =
        OperationsRuntimeAuthorization.create(request);
    if (authorization.requestDigest != expectedAuthorization.requestDigest ||
        authorization.topologyDigest != expectedAuthorization.topologyDigest ||
        authorization.provenanceDigest !=
            expectedAuthorization.provenanceDigest ||
        authorization.digest != expectedAuthorization.digest) {
      throw ArgumentError('Operations authorization is stale.');
    }
    _validateRequestInventories(request);
    final payload = {
      'version': operationsRuntimeVersion,
      'policyVersion': operationsRuntimePolicyVersion,
      'operationsId': request.operationsId,
      'operationsVersion': request.operationsVersion,
      'topologyId': request.topologyId,
      'topologyDigest': request.topologyDigest,
      'artifactIdentityDigest': request.artifactIdentityDigest,
      'initialState': request.initialState.name,
      'supportedStates':
          ProductionOperatingState.values.map((state) => state.name).toList(),
      'workstreams': request.workstreams.map((item) => item.toJson()).toList(),
      'evidenceSchemas':
          request.evidenceSchemas.map((item) => item.toJson()).toList(),
      'runbookReferences':
          request.runbookReferences.map((item) => item.toJson()).toList(),
      'escalationRules':
          request.escalationRules.map((item) => item.toJson()).toList(),
      'requestDigest': request.digest,
      'authorizationDigest': authorization.digest,
      'provenanceDigest': request.provenanceDigest,
    };
    final digest = _digest(payload);
    return OperationsRuntimeRecord._(
      id: '${request.operationsId}.${digest.substring(0, 16)}',
      operationsVersion: request.operationsVersion,
      topologyId: request.topologyId,
      topologyDigest: request.topologyDigest,
      artifactIdentityDigest: request.artifactIdentityDigest,
      initialState: request.initialState,
      supportedStates: ProductionOperatingState.values,
      workstreams: request.workstreams,
      evidenceSchemas: request.evidenceSchemas,
      runbookReferences: request.runbookReferences,
      escalationRules: request.escalationRules,
      requestDigest: request.digest,
      authorizationDigest: authorization.digest,
      provenanceDigest: request.provenanceDigest,
      digest: digest,
    );
  }

  OperationsRuntimeRecord replay({
    required OperationsRuntimeRequest request,
    required OperationsRuntimeAuthorization authorization,
    required OperationsRuntimeRecord expected,
  }) {
    final replayed = assemble(request: request, authorization: authorization);
    if (jsonEncode(replayed.toJson()) != jsonEncode(expected.toJson())) {
      throw StateError('Operations replay does not match.');
    }
    return replayed;
  }
}

List<OperationsOwnedReference> _canonicalize(
  Iterable<OperationsOwnedReference> input,
  List<String> expectedCategories,
) {
  final byCategory = <String, OperationsOwnedReference>{};
  final semanticIds = <String>{};
  for (final item in input) {
    final canonical = OperationsOwnedReference.create(
      category: item.category,
      semanticId: item.semanticId,
      ownerId: item.ownerId,
      schemaVersion: item.schemaVersion,
    );
    if (item.digest != canonical.digest ||
        byCategory.containsKey(item.category) ||
        !semanticIds.add(item.semanticId)) {
      throw ArgumentError('Operations inventory provenance is invalid.');
    }
    byCategory[item.category] = item;
  }
  if (byCategory.length != expectedCategories.length ||
      expectedCategories.any((category) => !byCategory.containsKey(category))) {
    throw ArgumentError('Operations inventory coverage is incomplete.');
  }
  return List.unmodifiable([
    for (final category in expectedCategories) byCategory[category]!,
  ]);
}

void _validateRequestInventories(OperationsRuntimeRequest request) {
  _canonicalize(request.workstreams, [
    for (final kind in OperationsWorkstreamKind.values)
      'workstream.${kind.name}',
  ]);
  _canonicalize(request.evidenceSchemas, [
    for (final kind in OperationsEvidenceKind.values) 'evidence.${kind.name}',
  ]);
  _canonicalize(request.runbookReferences, [
    for (final kind in OperationsRunbookScenario.values) 'runbook.${kind.name}',
  ]);
  _canonicalize(request.escalationRules, [
    for (final kind in OperationsIncidentSeverity.values)
      'severity.${kind.name}',
  ]);
}

void _requireValue(String value, String field) {
  if (value.trim().isEmpty || value != value.trim()) {
    throw ArgumentError('$field must be a non-empty canonical value.');
  }
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
