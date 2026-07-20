import 'dart:convert';
import 'dart:io';

import 'package:billiard_knowledge/billiard_knowledge.dart';
import 'package:crypto/crypto.dart';

import 'knowledge_compiler_v0.dart' as compiler;

const publicationSchemaVersion = 1;

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

void main(List<String> args) {
  final command = args.isEmpty ? 'check' : args.first;
  final packageRoot = Directory.current.absolute;
  final store = Directory(
    _join(packageRoot.path, 'build', 'knowledge_publication'),
  );
  final pipeline = KnowledgePublicationPipeline(store);

  try {
    switch (command) {
      case 'publish':
        final publication = pipeline.publish(
          compileCurrentCorpus(packageRoot),
        );
        stdout.writeln(
          'Published ${publication.knowledgeVersion} '
          '(${publication.contentDigest}).',
        );
      case 'check':
        final publication = pipeline.verifyCurrent(
          compileCurrentCorpus(packageRoot),
        );
        stdout.writeln(
          'Current publication is valid: ${publication.contentDigest}.',
        );
      case 'rollback':
        final publication = pipeline.rollback();
        stdout.writeln(
          'Rolled back to ${publication.contentDigest}.',
        );
      default:
        throw const KnowledgePublicationException(
          'Usage: dart run tool/knowledge_publication.dart '
          '<publish|check|rollback>',
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
  }) : _faultInjector = faultInjector;

  final Directory storeRoot;
  final PublicationFaultInjector? _faultInjector;

  Directory get _objects => Directory(_join(storeRoot.path, 'objects'));
  Directory get _manifests => Directory(_join(storeRoot.path, 'manifests'));
  File get _current => File(_join(storeRoot.path, 'current.json'));
  File get _backup => File('${_current.path}.backup');
  File get _lockFile => File(_join(storeRoot.path, 'publication.lock'));

  KnowledgePublicationMetadata publish(String compiled) =>
      _withExclusiveLock(() => _publish(compiled));

  KnowledgePublicationMetadata _publish(String compiled) {
    final pack = ExecutableKnowledgePack.fromJsonString(compiled);
    final bytes = utf8.encode(_normalizeNewlines(compiled));
    final artifactDigest = _sha256(bytes);
    final objectDirectory = Directory(
      _join(_objects.path, pack.contentDigest),
    );
    final artifact = File(_join(objectDirectory.path, 'package.json'));
    final manifestFile = File(
      _join(_manifests.path, '${pack.contentDigest}.json'),
    );
    final metadata = KnowledgePublicationMetadata.create(
      compilerVersion: pack.compilerVersion,
      knowledgeVersion: pack.knowledgeVersion,
      generatedAt: pack.generatedAt.toUtc().toIso8601String(),
      contentDigest: pack.contentDigest,
      artifactDigest: artifactDigest,
      artifactByteLength: bytes.length,
      artifactPath: 'objects/${pack.contentDigest}/package.json',
    );

    _publishImmutable(artifact, bytes, expectedDigest: artifactDigest);
    _fault(PublicationCheckpoint.artifactPublished);
    _publishImmutable(
      manifestFile,
      utf8.encode(_prettyJson(metadata.toJson())),
      expectedDigest: _sha256(utf8.encode(_prettyJson(metadata.toJson()))),
    );
    _fault(PublicationCheckpoint.manifestPublished);

    final current = _tryLoadCurrent(heal: true);
    if (current?.contentDigest == metadata.contentDigest) {
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
    final expected = ExecutableKnowledgePack.fromJsonString(compiled);
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
      if (_sha256(existing) != expectedDigest ||
          !_bytesEqual(existing, bytes)) {
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
    final manifestFile = File(
      _join(_manifests.path, '${pointer.contentDigest}.json'),
    );
    if (!manifestFile.existsSync()) {
      throw const KnowledgePublicationException(
        'Publication manifest is missing.',
      );
    }
    final metadata = KnowledgePublicationMetadata.fromJson(
      _readObject(manifestFile),
    );
    if (metadata.digest != pointer.manifestDigest ||
        metadata.contentDigest != pointer.contentDigest) {
      throw const KnowledgePublicationException(
        'Publication pointer does not match its manifest.',
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
    if (bytes.length != metadata.artifactByteLength ||
        _sha256(bytes) != metadata.artifactDigest) {
      throw const KnowledgePublicationException(
        'Published knowledge artifact failed verification.',
      );
    }
    final pack = ExecutableKnowledgePack.fromJsonString(utf8.decode(bytes));
    if (pack.contentDigest != metadata.contentDigest ||
        pack.compilerVersion != metadata.compilerVersion ||
        pack.knowledgeVersion != metadata.knowledgeVersion) {
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
  }) {
    final payload = _metadataPayload(
      compilerVersion: compilerVersion,
      knowledgeVersion: knowledgeVersion,
      generatedAt: generatedAt,
      contentDigest: contentDigest,
      artifactDigest: artifactDigest,
      artifactByteLength: artifactByteLength,
      artifactPath: artifactPath,
    );
    return KnowledgePublicationMetadata(
      compilerVersion: compilerVersion,
      knowledgeVersion: knowledgeVersion,
      generatedAt: generatedAt,
      contentDigest: contentDigest,
      artifactDigest: artifactDigest,
      artifactByteLength: artifactByteLength,
      artifactPath: artifactPath,
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
        ),
        'digest': digest,
      };
}

class _PublicationPointer {
  const _PublicationPointer({
    required this.contentDigest,
    required this.manifestDigest,
    required this.digest,
  });

  factory _PublicationPointer.create(KnowledgePublicationMetadata metadata) {
    final payload = _pointerPayload(
      contentDigest: metadata.contentDigest,
      manifestDigest: metadata.digest,
    );
    return _PublicationPointer(
      contentDigest: metadata.contentDigest,
      manifestDigest: metadata.digest,
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
    final manifestDigest = _requiredString(json, 'manifestDigest');
    final payload = _pointerPayload(
      contentDigest: contentDigest,
      manifestDigest: manifestDigest,
    );
    final digest = _sha256(utf8.encode(jsonEncode(payload)));
    if (json['digest'] != digest) {
      throw const KnowledgePublicationException(
        'Publication pointer digest mismatch.',
      );
    }
    return _PublicationPointer(
      contentDigest: contentDigest,
      manifestDigest: manifestDigest,
      digest: digest,
    );
  }

  final String contentDigest;
  final String manifestDigest;
  final String digest;

  Map<String, dynamic> toJson() => {
        ..._pointerPayload(
          contentDigest: contentDigest,
          manifestDigest: manifestDigest,
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
    };

Map<String, dynamic> _pointerPayload({
  required String contentDigest,
  required String manifestDigest,
}) =>
    {
      'schemaVersion': publicationSchemaVersion,
      'contentDigest': contentDigest,
      'manifestDigest': manifestDigest,
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

String _join(String first, String second, [String? third]) {
  final separator = Platform.pathSeparator;
  return third == null
      ? '$first$separator$second'
      : '$first$separator$second$separator$third';
}

String _joinMany(String first, Iterable<String> rest) =>
    rest.fold(first, (path, segment) => _join(path, segment));
