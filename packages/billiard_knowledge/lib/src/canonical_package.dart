import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'executable_knowledge.dart';

const canonicalPackageManifestSchemaVersion = 1;

class CanonicalPackageException implements Exception {
  const CanonicalPackageException(this.message);
  final String message;
  @override
  String toString() => 'CanonicalPackageException: $message';
}

class RuntimeCompatibility {
  const RuntimeCompatibility({
    required this.runtimeVersion,
    required this.supportedContracts,
  });

  final String runtimeVersion;
  final Map<String, String> supportedContracts;
}

class CanonicalKnowledgePackageManifest {
  const CanonicalKnowledgePackageManifest({
    required this.packageVersion,
    required this.knowledgeVersion,
    required this.compilerVersion,
    required this.releaseCandidateDigest,
    required this.candidatePackDigest,
    required this.candidatePackByteLength,
    required this.artifactDigest,
    required this.artifactPath,
    required this.dependencyManifestDigest,
    required this.entryCount,
    required this.kinds,
    required this.minimumRuntimeVersion,
    required this.requiredRuntimeContracts,
    required this.manifestDigest,
  });

  factory CanonicalKnowledgePackageManifest.create({
    required String packageVersion,
    required ExecutableKnowledgePack pack,
    required String artifact,
    required String releaseCandidateDigest,
    required String dependencyManifestDigest,
    required String minimumRuntimeVersion,
    required Map<String, String> requiredRuntimeContracts,
    String artifactPath = 'package.json',
  }) {
    final bytes = utf8.encode(_normalizeNewlines(artifact));
    final kinds = pack.entries.map((entry) => entry.kind.name).toSet().toList()
      ..sort();
    final payload = _payload(
      packageVersion: packageVersion,
      knowledgeVersion: pack.knowledgeVersion,
      compilerVersion: pack.compilerVersion,
      releaseCandidateDigest: releaseCandidateDigest,
      candidatePackDigest: pack.contentDigest,
      candidatePackByteLength: bytes.length,
      artifactDigest: _digestBytes(bytes),
      artifactPath: artifactPath,
      dependencyManifestDigest: dependencyManifestDigest,
      entryCount: pack.entries.length,
      kinds: kinds,
      minimumRuntimeVersion: minimumRuntimeVersion,
      requiredRuntimeContracts: requiredRuntimeContracts,
    );
    return CanonicalKnowledgePackageManifest.fromJson({
      ...payload,
      'manifestDigest': _digest(payload),
    });
  }

  factory CanonicalKnowledgePackageManifest.fromJson(
    Map<String, dynamic> json,
  ) {
    if (json['schemaVersion'] != canonicalPackageManifestSchemaVersion) {
      throw const CanonicalPackageException('Unsupported manifest schema.');
    }
    final payload = Map<String, dynamic>.from(json)..remove('manifestDigest');
    if (json['manifestDigest'] != _digest(payload)) {
      throw const CanonicalPackageException('Manifest digest mismatch.');
    }
    final contracts = Map<String, String>.from(
      Map<String, dynamic>.from(
          json['compatibility'] as Map)['requiredRuntimeContracts'] as Map,
    );
    return CanonicalKnowledgePackageManifest(
      packageVersion: _string(json, 'packageVersion'),
      knowledgeVersion: _string(json, 'knowledgeVersion'),
      compilerVersion: _string(json, 'compilerVersion'),
      releaseCandidateDigest: _string(json, 'releaseCandidateDigest'),
      candidatePackDigest: _string(json, 'candidatePackDigest'),
      candidatePackByteLength: json['candidatePackByteLength'] as int,
      artifactDigest: _string(json, 'artifactDigest'),
      artifactPath: _string(json, 'artifactPath'),
      dependencyManifestDigest: _string(json, 'dependencyManifestDigest'),
      entryCount: json['metadata']['entryCount'] as int,
      kinds: List<String>.from(json['metadata']['kinds'] as List),
      minimumRuntimeVersion: _string(
          json['compatibility'] as Map<String, dynamic>,
          'minimumRuntimeVersion'),
      requiredRuntimeContracts: Map.unmodifiable(contracts),
      manifestDigest: _string(json, 'manifestDigest'),
    );
  }

  final String packageVersion;
  final String knowledgeVersion;
  final String compilerVersion;
  final String releaseCandidateDigest;
  final String candidatePackDigest;
  final int candidatePackByteLength;
  final String artifactDigest;
  final String artifactPath;
  final String dependencyManifestDigest;
  final int entryCount;
  final List<String> kinds;
  final String minimumRuntimeVersion;
  final Map<String, String> requiredRuntimeContracts;
  final String manifestDigest;

  Map<String, dynamic> toJson() => {
        ..._payload(
          packageVersion: packageVersion,
          knowledgeVersion: knowledgeVersion,
          compilerVersion: compilerVersion,
          releaseCandidateDigest: releaseCandidateDigest,
          candidatePackDigest: candidatePackDigest,
          candidatePackByteLength: candidatePackByteLength,
          artifactDigest: artifactDigest,
          artifactPath: artifactPath,
          dependencyManifestDigest: dependencyManifestDigest,
          entryCount: entryCount,
          kinds: kinds,
          minimumRuntimeVersion: minimumRuntimeVersion,
          requiredRuntimeContracts: requiredRuntimeContracts,
        ),
        'manifestDigest': manifestDigest,
      };
}

class CanonicalPackageRuntimeLoader {
  const CanonicalPackageRuntimeLoader(this.runtime);
  final RuntimeCompatibility runtime;

  ExecutableKnowledgePack load(String manifestRaw, String artifactRaw) {
    final manifest = CanonicalKnowledgePackageManifest.fromJson(
      Map<String, dynamic>.from(jsonDecode(manifestRaw) as Map),
    );
    if (_compareVersions(
            runtime.runtimeVersion, manifest.minimumRuntimeVersion) <
        0) {
      throw const CanonicalPackageException('Runtime version is too old.');
    }
    for (final required in manifest.requiredRuntimeContracts.entries) {
      if (runtime.supportedContracts[required.key] != required.value) {
        throw CanonicalPackageException(
          'Unsupported runtime contract: ${required.key}/${required.value}.',
        );
      }
    }
    final normalized = _normalizeNewlines(artifactRaw);
    final bytes = utf8.encode(normalized);
    if (bytes.length != manifest.candidatePackByteLength ||
        _digestBytes(bytes) != manifest.artifactDigest) {
      throw const CanonicalPackageException('Package artifact mismatch.');
    }
    final pack = ExecutableKnowledgePack.fromJsonString(normalized);
    if (pack.contentDigest != manifest.candidatePackDigest ||
        pack.knowledgeVersion != manifest.knowledgeVersion ||
        pack.compilerVersion != manifest.compilerVersion ||
        pack.entries.length != manifest.entryCount) {
      throw const CanonicalPackageException('Package metadata mismatch.');
    }
    return pack;
  }
}

Map<String, dynamic> _payload({
  required String packageVersion,
  required String knowledgeVersion,
  required String compilerVersion,
  required String releaseCandidateDigest,
  required String candidatePackDigest,
  required int candidatePackByteLength,
  required String artifactDigest,
  required String artifactPath,
  required String dependencyManifestDigest,
  required int entryCount,
  required List<String> kinds,
  required String minimumRuntimeVersion,
  required Map<String, String> requiredRuntimeContracts,
}) =>
    {
      'schemaVersion': canonicalPackageManifestSchemaVersion,
      'packageVersion': packageVersion,
      'knowledgeVersion': knowledgeVersion,
      'compilerVersion': compilerVersion,
      'releaseCandidateDigest': releaseCandidateDigest,
      'candidatePackDigest': candidatePackDigest,
      'candidatePackByteLength': candidatePackByteLength,
      'artifactDigest': artifactDigest,
      'artifactPath': artifactPath,
      'dependencyManifestDigest': dependencyManifestDigest,
      'metadata': {
        'entryCount': entryCount,
        'kinds': [...kinds]..sort()
      },
      'compatibility': {
        'minimumRuntimeVersion': minimumRuntimeVersion,
        'requiredRuntimeContracts': Map.fromEntries(
          requiredRuntimeContracts.entries.toList()
            ..sort((a, b) => a.key.compareTo(b.key)),
        ),
      },
    };

String _string(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.isEmpty) {
    throw CanonicalPackageException('$key must be a non-empty string.');
  }
  return value;
}

String _digest(Object value) => _digestBytes(utf8.encode(jsonEncode(value)));
String _digestBytes(List<int> bytes) => sha256.convert(bytes).toString();
String _normalizeNewlines(String value) =>
    value.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

int _compareVersions(String left, String right) {
  final a = left.split('.').map(int.parse).toList();
  final b = right.split('.').map(int.parse).toList();
  for (var index = 0; index < 3; index++) {
    final comparison = a[index].compareTo(b[index]);
    if (comparison != 0) return comparison;
  }
  return 0;
}
