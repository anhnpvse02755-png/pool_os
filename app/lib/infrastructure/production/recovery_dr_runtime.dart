import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/infrastructure/production/deployment_topology_runtime.dart';

const recoveryDrRuntimeVersion = 1;
const recoveryDrPolicyVersion = 'recovery-dr-runtime/1.0.0';

enum RecoveryInformationClass {
  authoredSource,
  publishedImmutableArtifact,
  authoritativeEventHistory,
  durableOperationalState,
  rebuildableProjection,
  operationalEvidence,
  ephemeralData,
}

enum RecoveryBoundaryKind {
  primary,
  recoveryVault,
  isolatedValidation,
  recoveryControl,
  evidenceCustody,
  recoveryServing,
}

enum RecoveryGovernanceState {
  protected,
  protectionDegraded,
  recoveryDeclared,
  isolatedRestore,
  validationFailed,
  cutoverReady,
  recoveringService,
  recovered,
  aborted,
}

enum RecoveryValidationUnit {
  protectionInventory,
  recoveryPointIdentity,
  isolatedRestore,
  structuralValidation,
  contractSchemaValidation,
  domainValidation,
  replayValidation,
  securityValidation,
  cutoverGovernance,
  rehearsalEvidence,
}

class RecoveryGovernanceReference {
  const RecoveryGovernanceReference._({
    required this.category,
    required this.referenceId,
    required this.ownerId,
    required this.evidenceIdentity,
    required this.contractVersion,
    required this.digest,
  });

  factory RecoveryGovernanceReference.create({
    required String category,
    required String referenceId,
    required String ownerId,
    required String evidenceIdentity,
    required String contractVersion,
  }) {
    for (final value in [
      category,
      referenceId,
      ownerId,
      evidenceIdentity,
      contractVersion,
    ]) {
      if (value.trim().isEmpty || value != value.trim()) {
        throw ArgumentError('Recovery reference is not canonical.');
      }
    }
    final payload = {
      'category': category,
      'referenceId': referenceId,
      'ownerId': ownerId,
      'evidenceIdentity': evidenceIdentity,
      'contractVersion': contractVersion,
    };
    return RecoveryGovernanceReference._(
      category: category,
      referenceId: referenceId,
      ownerId: ownerId,
      evidenceIdentity: evidenceIdentity,
      contractVersion: contractVersion,
      digest: _digest(payload),
    );
  }

  final String category;
  final String referenceId;
  final String ownerId;
  final String evidenceIdentity;
  final String contractVersion;
  final String digest;

  Map<String, dynamic> toJson() => {
        'category': category,
        'referenceId': referenceId,
        'ownerId': ownerId,
        'evidenceIdentity': evidenceIdentity,
        'contractVersion': contractVersion,
        'digest': digest,
      };
}

class RecoveryDrRequest {
  RecoveryDrRequest._({
    required this.recoveryId,
    required this.recoveryVersion,
    required this.topologyId,
    required this.topologyDigest,
    required this.artifactIdentityDigest,
    required List<RecoveryGovernanceReference> informationClasses,
    required List<RecoveryGovernanceReference> boundaries,
    required List<RecoveryGovernanceReference> validationUnits,
    required List<RecoveryGovernanceReference> rehearsalReferences,
    required this.provenanceDigest,
    required this.digest,
  })  : informationClasses = List.unmodifiable(informationClasses),
        boundaries = List.unmodifiable(boundaries),
        validationUnits = List.unmodifiable(validationUnits),
        rehearsalReferences = List.unmodifiable(rehearsalReferences);

  factory RecoveryDrRequest.create({
    required String recoveryId,
    required String recoveryVersion,
    required DeploymentTopologyRecord topology,
    required Iterable<RecoveryGovernanceReference> informationClasses,
    required Iterable<RecoveryGovernanceReference> boundaries,
    required Iterable<RecoveryGovernanceReference> validationUnits,
    required Iterable<RecoveryGovernanceReference> rehearsalReferences,
  }) {
    _requireValue(recoveryId, 'Recovery ID');
    _requireValue(recoveryVersion, 'Recovery version');
    _requireValue(topology.id, 'Topology ID');
    _requireValue(topology.digest, 'Topology digest');
    _requireValue(topology.artifactIdentityDigest, 'Artifact identity digest');
    final classes = _canonicalize(informationClasses, [
      for (final kind in RecoveryInformationClass.values) 'class.${kind.name}',
    ]);
    final boundaryItems = _canonicalize(boundaries, [
      for (final kind in RecoveryBoundaryKind.values) 'boundary.${kind.name}',
    ]);
    final units = _canonicalize(validationUnits, [
      for (final kind in RecoveryValidationUnit.values) 'unit.${kind.name}',
    ]);
    final rehearsals = _canonicalize(rehearsalReferences, [
      for (final state in RecoveryGovernanceState.values)
        'rehearsal.${state.name}',
    ]);
    final provenancePayload = {
      'topologyDigest': topology.digest,
      'artifactIdentityDigest': topology.artifactIdentityDigest,
      'informationClasses': classes.map((item) => item.toJson()).toList(),
      'boundaries': boundaryItems.map((item) => item.toJson()).toList(),
      'validationUnits': units.map((item) => item.toJson()).toList(),
      'rehearsalReferences': rehearsals.map((item) => item.toJson()).toList(),
    };
    final provenanceDigest = _digest(provenancePayload);
    final payload = {
      'version': recoveryDrRuntimeVersion,
      'policyVersion': recoveryDrPolicyVersion,
      'recoveryId': recoveryId,
      'recoveryVersion': recoveryVersion,
      'topologyId': topology.id,
      'topologyDigest': topology.digest,
      'artifactIdentityDigest': topology.artifactIdentityDigest,
      'states':
          RecoveryGovernanceState.values.map((item) => item.name).toList(),
      'informationClasses': classes.map((item) => item.toJson()).toList(),
      'boundaries': boundaryItems.map((item) => item.toJson()).toList(),
      'validationUnits': units.map((item) => item.toJson()).toList(),
      'rehearsalReferences': rehearsals.map((item) => item.toJson()).toList(),
      'provenanceDigest': provenanceDigest,
    };
    return RecoveryDrRequest._(
      recoveryId: recoveryId,
      recoveryVersion: recoveryVersion,
      topologyId: topology.id,
      topologyDigest: topology.digest,
      artifactIdentityDigest: topology.artifactIdentityDigest,
      informationClasses: classes,
      boundaries: boundaryItems,
      validationUnits: units,
      rehearsalReferences: rehearsals,
      provenanceDigest: provenanceDigest,
      digest: _digest(payload),
    );
  }

  final String recoveryId;
  final String recoveryVersion;
  final String topologyId;
  final String topologyDigest;
  final String artifactIdentityDigest;
  final List<RecoveryGovernanceReference> informationClasses;
  final List<RecoveryGovernanceReference> boundaries;
  final List<RecoveryGovernanceReference> validationUnits;
  final List<RecoveryGovernanceReference> rehearsalReferences;
  final String provenanceDigest;
  final String digest;
}

class RecoveryDrAuthorization {
  const RecoveryDrAuthorization._({
    required this.requestDigest,
    required this.topologyDigest,
    required this.provenanceDigest,
    required this.digest,
  });

  factory RecoveryDrAuthorization.create(RecoveryDrRequest request) {
    final payload = {
      'version': recoveryDrRuntimeVersion,
      'requestDigest': request.digest,
      'topologyDigest': request.topologyDigest,
      'provenanceDigest': request.provenanceDigest,
    };
    return RecoveryDrAuthorization._(
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

class RecoveryDrRecord {
  RecoveryDrRecord._({
    required this.id,
    required this.recoveryVersion,
    required this.topologyId,
    required this.topologyDigest,
    required this.artifactIdentityDigest,
    required List<RecoveryGovernanceState> states,
    required List<RecoveryGovernanceReference> informationClasses,
    required List<RecoveryGovernanceReference> boundaries,
    required List<RecoveryGovernanceReference> validationUnits,
    required List<RecoveryGovernanceReference> rehearsalReferences,
    required this.requestDigest,
    required this.authorizationDigest,
    required this.provenanceDigest,
    required this.digest,
  })  : states = List.unmodifiable(states),
        informationClasses = List.unmodifiable(informationClasses),
        boundaries = List.unmodifiable(boundaries),
        validationUnits = List.unmodifiable(validationUnits),
        rehearsalReferences = List.unmodifiable(rehearsalReferences);

  final String id;
  final String recoveryVersion;
  final String topologyId;
  final String topologyDigest;
  final String artifactIdentityDigest;
  final List<RecoveryGovernanceState> states;
  final List<RecoveryGovernanceReference> informationClasses;
  final List<RecoveryGovernanceReference> boundaries;
  final List<RecoveryGovernanceReference> validationUnits;
  final List<RecoveryGovernanceReference> rehearsalReferences;
  final String requestDigest;
  final String authorizationDigest;
  final String provenanceDigest;
  final String digest;

  Map<String, dynamic> toJson() => {
        'version': recoveryDrRuntimeVersion,
        'policyVersion': recoveryDrPolicyVersion,
        'id': id,
        'recoveryVersion': recoveryVersion,
        'topologyId': topologyId,
        'topologyDigest': topologyDigest,
        'artifactIdentityDigest': artifactIdentityDigest,
        'states': states.map((item) => item.name).toList(),
        'informationClasses':
            informationClasses.map((item) => item.toJson()).toList(),
        'boundaries': boundaries.map((item) => item.toJson()).toList(),
        'validationUnits':
            validationUnits.map((item) => item.toJson()).toList(),
        'rehearsalReferences':
            rehearsalReferences.map((item) => item.toJson()).toList(),
        'requestDigest': requestDigest,
        'authorizationDigest': authorizationDigest,
        'provenanceDigest': provenanceDigest,
        'digest': digest,
      };
}

class RecoveryDrRuntime {
  const RecoveryDrRuntime();

  RecoveryDrRecord assemble({
    required RecoveryDrRequest request,
    required RecoveryDrAuthorization authorization,
  }) {
    _validateRequest(request);
    final expectedAuthorization = RecoveryDrAuthorization.create(request);
    if (authorization.requestDigest != expectedAuthorization.requestDigest ||
        authorization.topologyDigest != expectedAuthorization.topologyDigest ||
        authorization.provenanceDigest !=
            expectedAuthorization.provenanceDigest ||
        authorization.digest != expectedAuthorization.digest) {
      throw ArgumentError('Recovery authorization is stale.');
    }
    final payload = {
      'version': recoveryDrRuntimeVersion,
      'policyVersion': recoveryDrPolicyVersion,
      'recoveryId': request.recoveryId,
      'recoveryVersion': request.recoveryVersion,
      'topologyId': request.topologyId,
      'topologyDigest': request.topologyDigest,
      'artifactIdentityDigest': request.artifactIdentityDigest,
      'states':
          RecoveryGovernanceState.values.map((item) => item.name).toList(),
      'informationClasses':
          request.informationClasses.map((item) => item.toJson()).toList(),
      'boundaries': request.boundaries.map((item) => item.toJson()).toList(),
      'validationUnits':
          request.validationUnits.map((item) => item.toJson()).toList(),
      'rehearsalReferences':
          request.rehearsalReferences.map((item) => item.toJson()).toList(),
      'requestDigest': request.digest,
      'authorizationDigest': authorization.digest,
      'provenanceDigest': request.provenanceDigest,
    };
    final digest = _digest(payload);
    return RecoveryDrRecord._(
      id: '${request.recoveryId}.${digest.substring(0, 16)}',
      recoveryVersion: request.recoveryVersion,
      topologyId: request.topologyId,
      topologyDigest: request.topologyDigest,
      artifactIdentityDigest: request.artifactIdentityDigest,
      states: RecoveryGovernanceState.values,
      informationClasses: request.informationClasses,
      boundaries: request.boundaries,
      validationUnits: request.validationUnits,
      rehearsalReferences: request.rehearsalReferences,
      requestDigest: request.digest,
      authorizationDigest: authorization.digest,
      provenanceDigest: request.provenanceDigest,
      digest: digest,
    );
  }

  RecoveryDrRecord replay({
    required RecoveryDrRequest request,
    required RecoveryDrAuthorization authorization,
    required RecoveryDrRecord expected,
  }) {
    final replayed = assemble(request: request, authorization: authorization);
    if (jsonEncode(replayed.toJson()) != jsonEncode(expected.toJson())) {
      throw StateError('Recovery replay does not match.');
    }
    return replayed;
  }
}

List<RecoveryGovernanceReference> _canonicalize(
  Iterable<RecoveryGovernanceReference> input,
  List<String> expected,
) {
  final byCategory = <String, RecoveryGovernanceReference>{};
  final references = <String>{};
  final evidence = <String>{};
  for (final item in input) {
    final canonical = RecoveryGovernanceReference.create(
      category: item.category,
      referenceId: item.referenceId,
      ownerId: item.ownerId,
      evidenceIdentity: item.evidenceIdentity,
      contractVersion: item.contractVersion,
    );
    if (canonical.digest != item.digest ||
        byCategory.containsKey(item.category) ||
        !references.add(item.referenceId) ||
        !evidence.add(item.evidenceIdentity)) {
      throw ArgumentError('Recovery provenance is invalid.');
    }
    byCategory[item.category] = item;
  }
  if (byCategory.length != expected.length ||
      expected.any((category) => !byCategory.containsKey(category))) {
    throw ArgumentError('Recovery coverage is incomplete.');
  }
  return List.unmodifiable(
      [for (final category in expected) byCategory[category]!]);
}

void _validateRequest(RecoveryDrRequest request) {
  _canonicalize(request.informationClasses, [
    for (final kind in RecoveryInformationClass.values) 'class.${kind.name}',
  ]);
  _canonicalize(request.boundaries, [
    for (final kind in RecoveryBoundaryKind.values) 'boundary.${kind.name}',
  ]);
  _canonicalize(request.validationUnits, [
    for (final kind in RecoveryValidationUnit.values) 'unit.${kind.name}',
  ]);
  _canonicalize(request.rehearsalReferences, [
    for (final state in RecoveryGovernanceState.values)
      'rehearsal.${state.name}',
  ]);
}

void _requireValue(String value, String field) {
  if (value.trim().isEmpty || value != value.trim()) {
    throw ArgumentError('$field must be a non-empty canonical value.');
  }
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
