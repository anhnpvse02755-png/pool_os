import 'dart:convert';

import 'package:crypto/crypto.dart';

const releaseArtifactIdentityRuntimeVersion = 1;
const releaseArtifactIdentityPolicyVersion =
    'release-artifact-identity-runtime/1.0.0';

enum ReleaseArtifactInputKind {
  artifactContent,
  sourceRevision,
  dependencySet,
  buildContract,
  configurationSchema,
  migrationSet,
  knowledge,
  frozenContractSet,
  providerCompatibilitySet,
  evidenceIndex,
}

class ReleaseArtifactInputAttestation {
  const ReleaseArtifactInputAttestation._({
    required this.kind,
    required this.identity,
    required this.ownerId,
    required this.contractVersion,
    required this.digest,
  });

  factory ReleaseArtifactInputAttestation.create({
    required ReleaseArtifactInputKind kind,
    required String identity,
    required String ownerId,
    required String contractVersion,
  }) {
    _requireValue(identity, 'Input identity');
    _requireValue(ownerId, 'Input owner');
    _requireValue(contractVersion, 'Input contract version');
    final payload = {
      'kind': kind.name,
      'identity': identity,
      'ownerId': ownerId,
      'contractVersion': contractVersion,
    };
    return ReleaseArtifactInputAttestation._(
      kind: kind,
      identity: identity,
      ownerId: ownerId,
      contractVersion: contractVersion,
      digest: _digest(payload),
    );
  }

  final ReleaseArtifactInputKind kind;
  final String identity;
  final String ownerId;
  final String contractVersion;
  final String digest;

  Map<String, dynamic> toJson() => {
        'kind': kind.name,
        'identity': identity,
        'ownerId': ownerId,
        'contractVersion': contractVersion,
        'digest': digest,
      };
}

class ReleaseArtifactIdentityRequest {
  ReleaseArtifactIdentityRequest._({
    required this.artifactId,
    required this.artifactVersion,
    required this.createdAt,
    required List<ReleaseArtifactInputAttestation> inputs,
    required this.provenanceIdentity,
    required this.digest,
  }) : inputs = List.unmodifiable(inputs);

  factory ReleaseArtifactIdentityRequest.create({
    required String artifactId,
    required String artifactVersion,
    required DateTime createdAt,
    required Iterable<ReleaseArtifactInputAttestation> inputs,
  }) {
    _requireValue(artifactId, 'Artifact ID');
    _requireValue(artifactVersion, 'Artifact version');
    if (!createdAt.isUtc) {
      throw ArgumentError('Artifact creation time must be UTC.');
    }
    final canonicalInputs = [...inputs]
      ..sort((left, right) => left.kind.index.compareTo(right.kind.index));
    _validateInputs(canonicalInputs);
    final provenancePayload = {
      'version': releaseArtifactIdentityRuntimeVersion,
      'inputs': canonicalInputs.map((input) => input.toJson()).toList(),
    };
    final provenanceIdentity = _digest(provenancePayload);
    final payload = {
      'version': releaseArtifactIdentityRuntimeVersion,
      'policyVersion': releaseArtifactIdentityPolicyVersion,
      'artifactId': artifactId,
      'artifactVersion': artifactVersion,
      'createdAt': createdAt.toIso8601String(),
      'provenanceIdentity': provenanceIdentity,
      'inputs': canonicalInputs.map((input) => input.toJson()).toList(),
    };
    return ReleaseArtifactIdentityRequest._(
      artifactId: artifactId,
      artifactVersion: artifactVersion,
      createdAt: createdAt,
      inputs: canonicalInputs,
      provenanceIdentity: provenanceIdentity,
      digest: _digest(payload),
    );
  }

  final String artifactId;
  final String artifactVersion;
  final DateTime createdAt;
  final List<ReleaseArtifactInputAttestation> inputs;
  final String provenanceIdentity;
  final String digest;

  Map<String, dynamic> toJson() => {
        'version': releaseArtifactIdentityRuntimeVersion,
        'policyVersion': releaseArtifactIdentityPolicyVersion,
        'artifactId': artifactId,
        'artifactVersion': artifactVersion,
        'createdAt': createdAt.toIso8601String(),
        'provenanceIdentity': provenanceIdentity,
        'inputs': inputs.map((input) => input.toJson()).toList(),
        'digest': digest,
      };
}

class ReleaseArtifactIdentityAuthorization {
  const ReleaseArtifactIdentityAuthorization._({
    required this.requestDigest,
    required this.provenanceIdentity,
    required this.digest,
  });

  factory ReleaseArtifactIdentityAuthorization.create(
    ReleaseArtifactIdentityRequest request,
  ) {
    final payload = {
      'version': releaseArtifactIdentityRuntimeVersion,
      'requestDigest': request.digest,
      'provenanceIdentity': request.provenanceIdentity,
    };
    return ReleaseArtifactIdentityAuthorization._(
      requestDigest: request.digest,
      provenanceIdentity: request.provenanceIdentity,
      digest: _digest(payload),
    );
  }

  final String requestDigest;
  final String provenanceIdentity;
  final String digest;
}

class ReleaseArtifactIdentityRecord {
  const ReleaseArtifactIdentityRecord._({
    required this.artifactId,
    required this.artifactVersion,
    required this.artifactDigest,
    required this.sourceRevision,
    required this.dependencySetIdentity,
    required this.buildContractVersion,
    required this.configurationSchemaIdentity,
    required this.migrationSetIdentity,
    required this.knowledgeIdentity,
    required this.frozenContractSetIdentity,
    required this.providerCompatibilitySet,
    required this.evidenceIndexIdentity,
    required this.createdAt,
    required this.provenanceIdentity,
    required this.requestDigest,
    required this.authorizationDigest,
    required this.digest,
  });

  final String artifactId;
  final String artifactVersion;
  final String artifactDigest;
  final String sourceRevision;
  final String dependencySetIdentity;
  final String buildContractVersion;
  final String configurationSchemaIdentity;
  final String migrationSetIdentity;
  final String knowledgeIdentity;
  final String frozenContractSetIdentity;
  final String providerCompatibilitySet;
  final String evidenceIndexIdentity;
  final DateTime createdAt;
  final String provenanceIdentity;
  final String requestDigest;
  final String authorizationDigest;
  final String digest;

  Map<String, dynamic> toJson() => {
        'version': releaseArtifactIdentityRuntimeVersion,
        'policyVersion': releaseArtifactIdentityPolicyVersion,
        'artifactId': artifactId,
        'artifactVersion': artifactVersion,
        'artifactDigest': artifactDigest,
        'sourceRevision': sourceRevision,
        'dependencySetIdentity': dependencySetIdentity,
        'buildContractVersion': buildContractVersion,
        'configurationSchemaIdentity': configurationSchemaIdentity,
        'migrationSetIdentity': migrationSetIdentity,
        'knowledgeIdentity': knowledgeIdentity,
        'frozenContractSetIdentity': frozenContractSetIdentity,
        'providerCompatibilitySet': providerCompatibilitySet,
        'evidenceIndexIdentity': evidenceIndexIdentity,
        'createdAt': createdAt.toIso8601String(),
        'provenanceIdentity': provenanceIdentity,
        'requestDigest': requestDigest,
        'authorizationDigest': authorizationDigest,
        'digest': digest,
      };
}

class ReleaseArtifactIdentityRuntime {
  const ReleaseArtifactIdentityRuntime();

  ReleaseArtifactIdentityRecord assemble({
    required ReleaseArtifactIdentityRequest request,
    required ReleaseArtifactIdentityAuthorization authorization,
  }) {
    final canonicalRequest = ReleaseArtifactIdentityRequest.create(
      artifactId: request.artifactId,
      artifactVersion: request.artifactVersion,
      createdAt: request.createdAt,
      inputs: request.inputs,
    );
    if (request.digest != canonicalRequest.digest ||
        request.provenanceIdentity != canonicalRequest.provenanceIdentity) {
      throw ArgumentError('Release artifact identity request is invalid.');
    }
    final expectedAuthorization =
        ReleaseArtifactIdentityAuthorization.create(canonicalRequest);
    if (authorization.requestDigest != expectedAuthorization.requestDigest ||
        authorization.provenanceIdentity !=
            expectedAuthorization.provenanceIdentity ||
        authorization.digest != expectedAuthorization.digest) {
      throw ArgumentError('Release artifact identity authorization is stale.');
    }
    final byKind = {
      for (final input in canonicalRequest.inputs) input.kind: input,
    };
    final payload = {
      'version': releaseArtifactIdentityRuntimeVersion,
      'policyVersion': releaseArtifactIdentityPolicyVersion,
      'artifactId': canonicalRequest.artifactId,
      'artifactVersion': canonicalRequest.artifactVersion,
      'artifactDigest':
          byKind[ReleaseArtifactInputKind.artifactContent]!.identity,
      'sourceRevision':
          byKind[ReleaseArtifactInputKind.sourceRevision]!.identity,
      'dependencySetIdentity':
          byKind[ReleaseArtifactInputKind.dependencySet]!.identity,
      'buildContractVersion':
          byKind[ReleaseArtifactInputKind.buildContract]!.identity,
      'configurationSchemaIdentity':
          byKind[ReleaseArtifactInputKind.configurationSchema]!.identity,
      'migrationSetIdentity':
          byKind[ReleaseArtifactInputKind.migrationSet]!.identity,
      'knowledgeIdentity': byKind[ReleaseArtifactInputKind.knowledge]!.identity,
      'frozenContractSetIdentity':
          byKind[ReleaseArtifactInputKind.frozenContractSet]!.identity,
      'providerCompatibilitySet':
          byKind[ReleaseArtifactInputKind.providerCompatibilitySet]!.identity,
      'evidenceIndexIdentity':
          byKind[ReleaseArtifactInputKind.evidenceIndex]!.identity,
      'createdAt': canonicalRequest.createdAt.toIso8601String(),
      'provenanceIdentity': canonicalRequest.provenanceIdentity,
      'requestDigest': canonicalRequest.digest,
      'authorizationDigest': authorization.digest,
    };
    return ReleaseArtifactIdentityRecord._(
      artifactId: canonicalRequest.artifactId,
      artifactVersion: canonicalRequest.artifactVersion,
      artifactDigest: payload['artifactDigest']! as String,
      sourceRevision: payload['sourceRevision']! as String,
      dependencySetIdentity: payload['dependencySetIdentity']! as String,
      buildContractVersion: payload['buildContractVersion']! as String,
      configurationSchemaIdentity:
          payload['configurationSchemaIdentity']! as String,
      migrationSetIdentity: payload['migrationSetIdentity']! as String,
      knowledgeIdentity: payload['knowledgeIdentity']! as String,
      frozenContractSetIdentity:
          payload['frozenContractSetIdentity']! as String,
      providerCompatibilitySet: payload['providerCompatibilitySet']! as String,
      evidenceIndexIdentity: payload['evidenceIndexIdentity']! as String,
      createdAt: canonicalRequest.createdAt,
      provenanceIdentity: canonicalRequest.provenanceIdentity,
      requestDigest: canonicalRequest.digest,
      authorizationDigest: authorization.digest,
      digest: _digest(payload),
    );
  }

  ReleaseArtifactIdentityRecord replay({
    required ReleaseArtifactIdentityRequest request,
    required ReleaseArtifactIdentityAuthorization authorization,
    required ReleaseArtifactIdentityRecord expected,
  }) {
    final replayed = assemble(request: request, authorization: authorization);
    if (jsonEncode(replayed.toJson()) != jsonEncode(expected.toJson())) {
      throw StateError('Release artifact identity replay does not match.');
    }
    return replayed;
  }
}

void _validateInputs(List<ReleaseArtifactInputAttestation> inputs) {
  if (inputs.length != ReleaseArtifactInputKind.values.length) {
    throw ArgumentError('Release artifact input coverage is incomplete.');
  }
  final kinds = <ReleaseArtifactInputKind>{};
  final identities = <String>{};
  for (var position = 0; position < inputs.length; position++) {
    final input = inputs[position];
    final canonical = ReleaseArtifactInputAttestation.create(
      kind: input.kind,
      identity: input.identity,
      ownerId: input.ownerId,
      contractVersion: input.contractVersion,
    );
    if (input.kind.index != position ||
        input.digest != canonical.digest ||
        !kinds.add(input.kind) ||
        !identities.add(input.identity)) {
      throw ArgumentError('Release artifact input provenance is invalid.');
    }
  }
}

void _requireValue(String value, String field) {
  if (value.trim().isEmpty || value != value.trim()) {
    throw ArgumentError('$field must be a non-empty canonical value.');
  }
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
