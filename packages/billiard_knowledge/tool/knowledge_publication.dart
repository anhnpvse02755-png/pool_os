import 'dart:convert';
import 'dart:io';

import 'package:billiard_knowledge/billiard_knowledge.dart';
import 'package:crypto/crypto.dart';

import 'knowledge_compiler_v0.dart' as compiler;

part 'knowledge_publication_candidate.dart';

const publicationSchemaVersion = 2;

enum PublicationCheckpoint {
  artifactPublished,
  manifestPublished,
  pointerStaged,
  currentBackedUp,
  currentPromoted,
}

typedef PublicationFaultInjector = void Function(
  PublicationCheckpoint checkpoint,
);

typedef KnowledgeArtifactReader = KnowledgeArtifactIdentity Function(
  String artifact,
);

class KnowledgeArtifactIdentity {
  const KnowledgeArtifactIdentity({
    required this.compilerVersion,
    required this.knowledgeVersion,
    required this.generatedAt,
    required this.contentDigest,
  });

  final String compilerVersion;
  final String knowledgeVersion;
  final String generatedAt;
  final String contentDigest;
}

KnowledgeArtifactIdentity readExecutableKnowledgeArtifact(String artifact) {
  final pack = ExecutableKnowledgePack.fromJsonString(artifact);
  return KnowledgeArtifactIdentity(
    compilerVersion: pack.compilerVersion,
    knowledgeVersion: pack.knowledgeVersion,
    generatedAt: pack.generatedAt.toUtc().toIso8601String(),
    contentDigest: pack.contentDigest,
  );
}

void main(List<String> args) {
  final command = args.isEmpty ? 'check' : args.first;
  final packageRoot = Directory.current.absolute;
  final store = _publicationStoreFromArgs(args, packageRoot);
  final pipeline = KnowledgePublicationPipeline(store);

  try {
    switch (command) {
      case 'publish':
        final result = pipeline.submitCandidate(
          candidateId: 'canonical-executable-corpus',
          compile: () => compileCurrentCorpus(packageRoot),
          review: _reviewFromArgs(args),
        );
        if (result.status == PublicationCandidateStatus.quarantined) {
          final codes = result.quarantine!.issues
              .map((issue) => issue.code.name)
              .join(', ');
          throw KnowledgePublicationException(
            'Publication candidate quarantined: $codes.',
          );
        }
        final publication = result.publication!;
        stdout.writeln(
          'Published ${publication.knowledgeVersion} '
          '(${publication.contentDigest}).',
        );
      case 'check':
        final publication = pipeline.verifyCurrent(
          compileCurrentCorpus(packageRoot),
        );
        stdout.writeln(
          'Publication Check PASS: ${publication.contentDigest}.',
        );
        stdout.writeln(
          'Runtime Load PASS: Knowledge ${publication.knowledgeVersion}, '
          'Compiler ${publication.compilerVersion}.',
        );
      case 'rollback':
        final publication = pipeline.rollback();
        stdout.writeln(
          'Rolled back to ${publication.contentDigest}.',
        );
      default:
        throw const KnowledgePublicationException(
          'Usage: dart run tool/knowledge_publication.dart '
          '<publish|check|rollback> [--review <decision.json>] '
          '[--store <publication-directory>]',
        );
    }
  } on KnowledgePublicationException catch (error) {
    stderr.writeln(error.message);
    exitCode = 1;
  } on ExecutableKnowledgeException catch (error) {
    stderr.writeln(error.message);
    exitCode = 1;
  }
}

Directory _publicationStoreFromArgs(
  List<String> args,
  Directory packageRoot,
) {
  final index = args.indexOf('--store');
  if (index < 0) {
    return Directory(
      _join(packageRoot.path, 'build', 'knowledge_publication'),
    );
  }
  if (index + 1 >= args.length) {
    throw const KnowledgePublicationException(
      '--store requires a publication directory.',
    );
  }
  return Directory(args[index + 1]).absolute;
}

PublicationReviewDecision? _reviewFromArgs(List<String> args) {
  final index = args.indexOf('--review');
  if (index < 0) return null;
  if (index + 1 >= args.length) {
    throw const KnowledgePublicationException(
      '--review requires a decision JSON file.',
    );
  }
  return PublicationReviewDecision.fromJson(
    _readObject(File(args[index + 1])),
  );
}

String compileCurrentCorpus(Directory packageRoot) {
  final sourceRoot = Directory(
    _join(packageRoot.path, 'corpus', 'articles'),
  );
  final files = sourceRoot
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.md'))
      .toList()
    ..sort((left, right) => left.path.compareTo(right.path));
  final policyFile = File(
    _join(packageRoot.path, 'corpus', 'mastery_policies.yaml'),
  );
  return compiler.compileKnowledgeCorpus(
    files.map((file) => file.readAsStringSync()).toList(),
    masteryPolicyDocument: compiler.parseYamlObject(
      policyFile.readAsStringSync(),
    ),
  );
}

class KnowledgePublicationPipeline {
  KnowledgePublicationPipeline(
    this.storeRoot, {
    PublicationFaultInjector? faultInjector,
    KnowledgeArtifactReader? artifactReader,
  })  : _faultInjector = faultInjector,
        _artifactReader = artifactReader ?? readExecutableKnowledgeArtifact;

  final Directory storeRoot;
  final PublicationFaultInjector? _faultInjector;
  final KnowledgeArtifactReader _artifactReader;

  Directory get _objects => Directory(_join(storeRoot.path, 'objects'));
  Directory get _manifests => Directory(_join(storeRoot.path, 'manifests'));
  File get _current => File(_join(storeRoot.path, 'current.json'));
  File get _backup => File('${_current.path}.backup');
  File get _lockFile => File(_join(storeRoot.path, 'publication.lock'));

  KnowledgePublicationMetadata _publish(
    String compiled, {
    required PublicationReviewDecision reviewDecision,
    required String? releaseCandidateContentDigest,
    String? packageManifestDigest,
    bool activate = true,
  }) {
    final pack = _artifactReader(compiled);
    if (reviewDecision.outcome != PublicationReviewOutcome.accepted ||
        reviewDecision.candidateContentDigest != pack.contentDigest ||
        reviewDecision.compilerVersion != pack.compilerVersion ||
        reviewDecision.releaseCandidateContentDigest !=
            releaseCandidateContentDigest) {
      throw const KnowledgePublicationException(
        'Publication requires an accepted review scoped to the candidate.',
      );
    }
    final bytes = utf8.encode(_normalizeNewlines(compiled));
    final artifactDigest = _sha256(bytes);
    final objectDirectory = Directory(
      _join(_objects.path, pack.contentDigest),
    );
    final artifact = File(_join(objectDirectory.path, 'package.json'));
    final metadata = KnowledgePublicationMetadata.create(
      compilerVersion: pack.compilerVersion,
      knowledgeVersion: pack.knowledgeVersion,
      generatedAt: pack.generatedAt,
      contentDigest: pack.contentDigest,
      artifactDigest: artifactDigest,
      artifactByteLength: bytes.length,
      artifactPath: 'objects/${pack.contentDigest}/package.json',
      reviewDecision: reviewDecision,
      releaseCandidateContentDigest: releaseCandidateContentDigest,
      packageManifestDigest: packageManifestDigest,
    );
    final publicationRecordFile = File(
      _join(_manifests.path, '${metadata.digest}.json'),
    );

    _publishImmutable(artifact, bytes, expectedDigest: artifactDigest);
    _fault(PublicationCheckpoint.artifactPublished);
    _publishImmutable(
      publicationRecordFile,
      utf8.encode(_prettyJson(metadata.toJson())),
      expectedDigest: _sha256(utf8.encode(_prettyJson(metadata.toJson()))),
    );
    _fault(PublicationCheckpoint.manifestPublished);

    if (!activate) return _verifyPublication(metadata);
    final current = _tryLoadCurrent(heal: true);
    if (current?.publicationRecordDigest == metadata.digest) {
      return _verifyPointer(current!);
    }
    _publishPointer(_PublicationPointer.create(metadata));
    return _verifyPublication(metadata);
  }

  KnowledgePublicationMetadata current() =>
      _withExclusiveLock(_currentPublication);

  KnowledgePublicationMetadata _currentPublication() {
    final pointer = _loadCurrent(heal: true);
    return _verifyPointer(pointer);
  }

  KnowledgePublicationMetadata verifyCurrent(String compiled) =>
      _withExclusiveLock(() => _verifyCurrent(compiled));

  KnowledgePublicationMetadata _verifyCurrent(String compiled) {
    final expected = _artifactReader(compiled);
    final publication = _currentPublication();
    if (publication.contentDigest != expected.contentDigest ||
        publication.compilerVersion != expected.compilerVersion ||
        publication.knowledgeVersion != expected.knowledgeVersion) {
      throw const KnowledgePublicationException(
        'Current publication does not match the deterministic compiler output.',
      );
    }
    return publication;
  }

  KnowledgePublicationMetadata rollback() => _withExclusiveLock(_rollback);

  KnowledgePublicationMetadata _rollback() {
    final currentPointer = _loadCurrent(heal: true);
    if (!_backup.existsSync()) {
      throw const KnowledgePublicationException(
        'No previous publication is available for rollback.',
      );
    }
    final previous = _readPointer(_backup);
    _verifyPointer(previous);
    _publishPointer(previous, knownCurrent: currentPointer);
    return _verifyPointer(previous);
  }

  T _withExclusiveLock<T>(T Function() operation) {
    storeRoot.createSync(recursive: true);
    final handle = _lockFile.openSync(mode: FileMode.append);
    try {
      handle.lockSync(FileLock.blockingExclusive);
      return operation();
    } finally {
      try {
        handle.unlockSync();
      } finally {
        handle.closeSync();
      }
    }
  }

  void _publishImmutable(
    File target,
    List<int> bytes, {
    required String expectedDigest,
  }) {
    if (target.existsSync()) {
      final existing = target.readAsBytesSync();
      final canonicalExisting = _canonicalTextBytes(existing);
      if (_sha256(canonicalExisting) != expectedDigest ||
          !_bytesEqual(canonicalExisting, bytes)) {
        throw KnowledgePublicationException(
          'Immutable publication object conflicts at ${target.path}.',
        );
      }
      return;
    }
    target.parent.createSync(recursive: true);
    final staging = File('${target.path}.staging');
    if (staging.existsSync()) staging.deleteSync();
    final handle = staging.openSync(mode: FileMode.write);
    try {
      handle.writeFromSync(bytes);
      handle.flushSync();
    } finally {
      handle.closeSync();
    }
    if (_sha256(staging.readAsBytesSync()) != expectedDigest) {
      throw const KnowledgePublicationException(
        'Staged publication object failed digest verification.',
      );
    }
    staging.renameSync(target.path);
  }

  void _publishPointer(
    _PublicationPointer pointer, {
    _PublicationPointer? knownCurrent,
  }) {
    storeRoot.createSync(recursive: true);
    final next = File('${_current.path}.next');
    _writeFlushed(next, utf8.encode(_prettyJson(pointer.toJson())));
    _fault(PublicationCheckpoint.pointerStaged);

    final previous = knownCurrent ?? _tryLoadCurrent(heal: true);
    if (_current.existsSync()) {
      if (_backup.existsSync()) _backup.deleteSync();
      _current.renameSync(_backup.path);
    } else if (previous != null) {
      _writeFlushed(_backup, utf8.encode(_prettyJson(previous.toJson())));
    }
    try {
      _fault(PublicationCheckpoint.currentBackedUp);
      next.renameSync(_current.path);
      _fault(PublicationCheckpoint.currentPromoted);
    } catch (_) {
      if (!_current.existsSync() && _backup.existsSync()) {
        _backup.renameSync(_current.path);
      }
      rethrow;
    }
  }

  _PublicationPointer _loadCurrent({required bool heal}) {
    final pointer = _tryLoadCurrent(heal: heal);
    if (pointer == null) {
      throw const KnowledgePublicationException(
        'No valid current publication pointer.',
      );
    }
    return pointer;
  }

  _PublicationPointer? _tryLoadCurrent({required bool heal}) {
    if (_current.existsSync()) {
      try {
        final pointer = _readPointer(_current);
        _verifyPointer(pointer);
        return pointer;
      } catch (_) {
        // Fall back to the last committed pointer below.
      }
    }
    if (!_backup.existsSync()) return null;
    final pointer = _readPointer(_backup);
    _verifyPointer(pointer);
    if (heal) {
      _writeFlushed(_current, utf8.encode(_prettyJson(pointer.toJson())));
    }
    return pointer;
  }

  KnowledgePublicationMetadata _verifyPointer(_PublicationPointer pointer) {
    final publicationRecordFile = File(
      _join(_manifests.path, '${pointer.publicationRecordDigest}.json'),
    );
    if (!publicationRecordFile.existsSync()) {
      throw const KnowledgePublicationException(
        'Publication Record is missing.',
      );
    }
    final metadata = KnowledgePublicationMetadata.fromJson(
      _readObject(publicationRecordFile),
    );
    if (metadata.digest != pointer.publicationRecordDigest ||
        metadata.contentDigest != pointer.contentDigest) {
      throw const KnowledgePublicationException(
        'Publication pointer does not match its Publication Record.',
      );
    }
    return _verifyPublication(metadata);
  }

  KnowledgePublicationMetadata _verifyPublication(
    KnowledgePublicationMetadata metadata,
  ) {
    final artifact = File(
      _joinMany(storeRoot.path, metadata.artifactPath.split('/')),
    );
    if (!artifact.existsSync()) {
      throw const KnowledgePublicationException(
        'Published knowledge artifact is missing.',
      );
    }
    final bytes = artifact.readAsBytesSync();
    final canonicalBytes = _canonicalTextBytes(bytes);
    if (canonicalBytes.length != metadata.artifactByteLength ||
        _sha256(canonicalBytes) != metadata.artifactDigest) {
      throw const KnowledgePublicationException(
        'Published knowledge artifact failed verification.',
      );
    }
    final pack = _artifactReader(utf8.decode(canonicalBytes));
    if (pack.contentDigest != metadata.contentDigest ||
        pack.compilerVersion != metadata.compilerVersion ||
        pack.knowledgeVersion != metadata.knowledgeVersion ||
        metadata.reviewDecision.outcome != PublicationReviewOutcome.accepted ||
        metadata.reviewDecision.candidateContentDigest !=
            metadata.contentDigest ||
        metadata.reviewDecision.compilerVersion != metadata.compilerVersion ||
        metadata.reviewDecision.releaseCandidateContentDigest !=
            metadata.releaseCandidateContentDigest) {
      throw const KnowledgePublicationException(
        'Published knowledge artifact provenance does not match.',
      );
    }
    return metadata;
  }

  _PublicationPointer _readPointer(File file) =>
      _PublicationPointer.fromJson(_readObject(file));

  void _writeFlushed(File target, List<int> bytes) {
    target.parent.createSync(recursive: true);
    if (target.existsSync()) target.deleteSync();
    final handle = target.openSync(mode: FileMode.write);
    try {
      handle.writeFromSync(bytes);
      handle.flushSync();
    } finally {
      handle.closeSync();
    }
  }

  void _fault(PublicationCheckpoint checkpoint) {
    _faultInjector?.call(checkpoint);
  }
}

class KnowledgePublicationMetadata {
  const KnowledgePublicationMetadata({
    required this.compilerVersion,
    required this.knowledgeVersion,
    required this.generatedAt,
    required this.contentDigest,
    required this.artifactDigest,
    required this.artifactByteLength,
    required this.artifactPath,
    required this.reviewDecision,
    required this.releaseCandidateContentDigest,
    required this.packageManifestDigest,
    required this.digest,
  });

  factory KnowledgePublicationMetadata.create({
    required String compilerVersion,
    required String knowledgeVersion,
    required String generatedAt,
    required String contentDigest,
    required String artifactDigest,
    required int artifactByteLength,
    required String artifactPath,
    required PublicationReviewDecision reviewDecision,
    required String? releaseCandidateContentDigest,
    String? packageManifestDigest,
  }) {
    final payload = _metadataPayload(
      compilerVersion: compilerVersion,
      knowledgeVersion: knowledgeVersion,
      generatedAt: generatedAt,
      contentDigest: contentDigest,
      artifactDigest: artifactDigest,
      artifactByteLength: artifactByteLength,
      artifactPath: artifactPath,
      reviewDecision: reviewDecision,
      releaseCandidateContentDigest: releaseCandidateContentDigest,
      packageManifestDigest: packageManifestDigest,
    );
    return KnowledgePublicationMetadata(
      compilerVersion: compilerVersion,
      knowledgeVersion: knowledgeVersion,
      generatedAt: generatedAt,
      contentDigest: contentDigest,
      artifactDigest: artifactDigest,
      artifactByteLength: artifactByteLength,
      artifactPath: artifactPath,
      reviewDecision: reviewDecision,
      releaseCandidateContentDigest: releaseCandidateContentDigest,
      packageManifestDigest: packageManifestDigest,
      digest: _sha256(utf8.encode(jsonEncode(payload))),
    );
  }

  factory KnowledgePublicationMetadata.fromJson(Map<String, dynamic> json) {
    if (json['schemaVersion'] != publicationSchemaVersion) {
      throw const KnowledgePublicationException(
        'Unsupported publication manifest version.',
      );
    }
    final metadata = KnowledgePublicationMetadata.create(
      compilerVersion: _requiredString(json, 'compilerVersion'),
      knowledgeVersion: _requiredString(json, 'knowledgeVersion'),
      generatedAt: _requiredString(json, 'generatedAt'),
      contentDigest: _requiredString(json, 'contentDigest'),
      artifactDigest: _requiredString(json, 'artifactDigest'),
      artifactByteLength: _requiredInt(json, 'artifactByteLength'),
      artifactPath: _requiredString(json, 'artifactPath'),
      reviewDecision: PublicationReviewDecision.fromJson(
        Map<String, dynamic>.from(json['reviewDecision'] as Map),
      ),
      releaseCandidateContentDigest:
          json['releaseCandidateContentDigest'] as String?,
      packageManifestDigest: json['packageManifestDigest'] as String?,
    );
    if (metadata.artifactPath !=
        'objects/${metadata.contentDigest}/package.json') {
      throw const KnowledgePublicationException(
        'Publication manifest contains an invalid artifact path.',
      );
    }
    if (json['digest'] != metadata.digest) {
      throw const KnowledgePublicationException(
        'Publication manifest digest mismatch.',
      );
    }
    return metadata;
  }

  final String compilerVersion;
  final String knowledgeVersion;
  final String generatedAt;
  final String contentDigest;
  final String artifactDigest;
  final int artifactByteLength;
  final String artifactPath;
  final PublicationReviewDecision reviewDecision;
  final String? releaseCandidateContentDigest;
  final String? packageManifestDigest;
  final String digest;

  Map<String, dynamic> toJson() => {
        ..._metadataPayload(
          compilerVersion: compilerVersion,
          knowledgeVersion: knowledgeVersion,
          generatedAt: generatedAt,
          contentDigest: contentDigest,
          artifactDigest: artifactDigest,
          artifactByteLength: artifactByteLength,
          artifactPath: artifactPath,
          reviewDecision: reviewDecision,
          releaseCandidateContentDigest: releaseCandidateContentDigest,
          packageManifestDigest: packageManifestDigest,
        ),
        'digest': digest,
      };
}

class _PublicationPointer {
  const _PublicationPointer({
    required this.contentDigest,
    required this.publicationRecordDigest,
    required this.digest,
  });

  factory _PublicationPointer.create(KnowledgePublicationMetadata metadata) {
    final payload = _pointerPayload(
      contentDigest: metadata.contentDigest,
      publicationRecordDigest: metadata.digest,
    );
    return _PublicationPointer(
      contentDigest: metadata.contentDigest,
      publicationRecordDigest: metadata.digest,
      digest: _sha256(utf8.encode(jsonEncode(payload))),
    );
  }

  factory _PublicationPointer.fromJson(Map<String, dynamic> json) {
    if (json['schemaVersion'] != publicationSchemaVersion) {
      throw const KnowledgePublicationException(
        'Unsupported publication pointer version.',
      );
    }
    final contentDigest = _requiredString(json, 'contentDigest');
    final publicationRecordDigest = _requiredString(
      json,
      'publicationRecordDigest',
    );
    final payload = _pointerPayload(
      contentDigest: contentDigest,
      publicationRecordDigest: publicationRecordDigest,
    );
    final digest = _sha256(utf8.encode(jsonEncode(payload)));
    if (json['digest'] != digest) {
      throw const KnowledgePublicationException(
        'Publication pointer digest mismatch.',
      );
    }
    return _PublicationPointer(
      contentDigest: contentDigest,
      publicationRecordDigest: publicationRecordDigest,
      digest: digest,
    );
  }

  final String contentDigest;
  final String publicationRecordDigest;
  final String digest;

  Map<String, dynamic> toJson() => {
        ..._pointerPayload(
          contentDigest: contentDigest,
          publicationRecordDigest: publicationRecordDigest,
        ),
        'digest': digest,
      };
}

Map<String, dynamic> _metadataPayload({
  required String compilerVersion,
  required String knowledgeVersion,
  required String generatedAt,
  required String contentDigest,
  required String artifactDigest,
  required int artifactByteLength,
  required String artifactPath,
  required PublicationReviewDecision reviewDecision,
  required String? releaseCandidateContentDigest,
  required String? packageManifestDigest,
}) =>
    {
      'schemaVersion': publicationSchemaVersion,
      'compilerVersion': compilerVersion,
      'knowledgeVersion': knowledgeVersion,
      'generatedAt': generatedAt,
      'contentDigest': contentDigest,
      'artifactDigest': artifactDigest,
      'artifactByteLength': artifactByteLength,
      'artifactPath': artifactPath,
      'reviewDecision': reviewDecision.toJson(),
      if (releaseCandidateContentDigest != null)
        'releaseCandidateContentDigest': releaseCandidateContentDigest,
      if (packageManifestDigest != null)
        'packageManifestDigest': packageManifestDigest,
    };

Map<String, dynamic> _pointerPayload({
  required String contentDigest,
  required String publicationRecordDigest,
}) =>
    {
      'schemaVersion': publicationSchemaVersion,
      'contentDigest': contentDigest,
      'publicationRecordDigest': publicationRecordDigest,
    };

class KnowledgePublicationException implements Exception {
  const KnowledgePublicationException(this.message);

  final String message;

  @override
  String toString() => 'KnowledgePublicationException: $message';
}

Map<String, dynamic> _readObject(File file) {
  try {
    final decoded = jsonDecode(file.readAsStringSync());
    if (decoded is! Map<String, dynamic>) throw const FormatException();
    return decoded;
  } catch (_) {
    throw KnowledgePublicationException(
      'Invalid publication JSON: ${file.path}.',
    );
  }
}

String _requiredString(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value is! String || value.trim().isEmpty) {
    throw KnowledgePublicationException('$field must be a non-empty string.');
  }
  return value;
}

int _requiredInt(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value is! int || value < 0) {
    throw KnowledgePublicationException('$field must be a positive integer.');
  }
  return value;
}

String _prettyJson(Object value) =>
    '${const JsonEncoder.withIndent('  ').convert(value)}\n';

String _normalizeNewlines(String value) =>
    value.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

String _sha256(List<int> bytes) => sha256.convert(bytes).toString();

bool _bytesEqual(List<int> left, List<int> right) {
  if (left.length != right.length) return false;
  for (var index = 0; index < left.length; index++) {
    if (left[index] != right[index]) return false;
  }
  return true;
}

List<int> _canonicalTextBytes(List<int> bytes) =>
    utf8.encode(_normalizeNewlines(utf8.decode(bytes)));

String _join(String first, String second, [String? third]) {
  final separator = Platform.pathSeparator;
  return third == null
      ? '$first$separator$second'
      : '$first$separator$second$separator$third';
}

String _joinMany(String first, Iterable<String> rest) =>
    rest.fold(first, (path, segment) => _join(path, segment));
