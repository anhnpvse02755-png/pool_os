import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/stop_shot_contracts.dart';
import 'package:pool_os/features/event/domain/stop_shot_evidence_log.dart';

const _snapshotSchemaVersion = 3;
const _archiveManifestSchemaVersion = 1;

class FileLearningEvidenceLog implements CompactingLearningEvidenceLog {
  FileLearningEvidenceLog(
    this.file, {
    File? snapshotFile,
    Directory? archiveDirectory,
  })  : snapshotFile = snapshotFile ?? File('${file.path}.snapshot.json'),
        archiveDirectory =
            archiveDirectory ?? Directory('${file.path}.archive');

  final File file;
  final File snapshotFile;
  final Directory archiveDirectory;

  @override
  Future<bool> append(LearningEvidenceBatch batch) async {
    return _withLockedFile((handle) async {
      final state = await _readLocked(handle, recoverTail: true);
      if (state.batches.any((item) => item.commandId == batch.commandId)) {
        return false;
      }

      final committedLength = await handle.length();
      final separator = state.completeTailWithoutNewline ? '\n' : '';
      final bytes = utf8.encode(
        '$separator${jsonEncode(batch.toJson())}\n',
      );
      try {
        await handle.setPosition(committedLength);
        await handle.writeFrom(bytes);
        await handle.flush();
      } catch (_) {
        await handle.truncate(committedLength);
        await handle.flush();
        rethrow;
      }
      return true;
    });
  }

  @override
  Future<List<LearningEvidenceBatch>> readAll() async {
    return _withLockedFile((handle) async {
      final state = await _readLocked(handle, recoverTail: true);
      return List.unmodifiable(state.batches);
    });
  }

  @override
  Future<LearningEvidenceSnapshotMetadata> createSnapshot() {
    return _withLockedFile((handle) async {
      final state = await _readLocked(handle, recoverTail: true);
      final journalBytes = await _readBytes(handle);
      final snapshot = _LearningEvidenceSnapshot.create(
        journalBytes: journalBytes,
        batches: state.batches,
        archiveManifestDigest: state.archiveManifestDigest,
      );
      await _publishSnapshot(snapshot);
      return LearningEvidenceSnapshotMetadata(
        recordCount: snapshot.batches.length,
        journalByteLength: snapshot.journalByteLength,
        digest: snapshot.digest,
      );
    });
  }

  @override
  Future<LearningEvidenceArchiveMetadata> compactActiveJournal() {
    return _withLockedFile((handle) async {
      final state = await _readLocked(handle, recoverTail: true);
      final journalBytes = await _readBytes(handle);
      var archive = await _loadArchive();
      if (journalBytes.isEmpty) return archive.metadata;

      final archivedCount = archive.batches.length;
      final activeBatches = state.batches.sublist(archivedCount);
      if (activeBatches.isEmpty) return archive.metadata;

      final segment = _ArchiveSegmentDescriptor.create(
        index: archive.manifest.segments.length + 1,
        startRecord: archivedCount,
        recordCount: activeBatches.length,
        bytes: journalBytes,
        previousDigest: archive.manifest.segments.isEmpty
            ? null
            : archive.manifest.segments.last.digest,
      );
      await _publishArchiveSegment(segment, journalBytes);

      archive = archive.append(segment, pendingJournalBytes: journalBytes);
      await _publishArchiveManifest(archive.manifest);
      await handle.truncate(0);
      await handle.flush();

      archive = archive.commitPending();
      await _publishArchiveManifest(archive.manifest);
      await _deleteSnapshotProjections();
      return archive.metadata;
    });
  }

  Future<T> _withLockedFile<T>(
    Future<T> Function(RandomAccessFile handle) operation,
  ) async {
    await file.parent.create(recursive: true);
    final handle = await file.open(mode: FileMode.append);
    var locked = false;
    try {
      await _lockWithRetry(handle);
      locked = true;
      return await operation(handle);
    } finally {
      try {
        if (locked) await handle.unlock();
      } finally {
        await handle.close();
      }
    }
  }

  Future<void> _lockWithRetry(RandomAccessFile handle) async {
    const retryableLockErrors = {11, 32, 33};
    const maxAttempts = 400;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        await handle.lock(FileLock.exclusive);
        return;
      } on FileSystemException catch (error) {
        final code = error.osError?.errorCode;
        if (!retryableLockErrors.contains(code) || attempt == maxAttempts) {
          rethrow;
        }
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }
    }
  }

  Future<_EvidenceFileState> _readLocked(
    RandomAccessFile handle, {
    required bool recoverTail,
  }) async {
    var bytes = await _readBytes(handle);
    var archive = await _loadArchive();
    if (bytes.isEmpty &&
        archive.manifest.segments.isEmpty &&
        await _hasFinalizedOrphanSegments()) {
      throw const FormatException(
        'Evidence archive contains orphan segments without a recoverable '
        'manifest or active journal.',
      );
    }
    if (archive.hasPendingCompaction) {
      archive = await _recoverPendingCompaction(handle, bytes, archive);
      bytes = await _readBytes(handle);
    }
    final snapshot = await _loadSnapshot(
      bytes,
      archiveManifestDigest: archive.manifestDigest,
    );
    final start = snapshot?.journalByteLength ?? 0;
    final remaining = bytes.sublist(start);
    final lastNewline = remaining.lastIndexOf(0x0a);
    final committedEnd = start + (lastNewline < 0 ? 0 : lastNewline + 1);
    final batches =
        snapshot == null ? [...archive.batches] : [...snapshot.batches];
    var lineNumber = batches.length;

    if (committedEnd > start) {
      final committed = utf8.decode(bytes.sublist(start, committedEnd));
      for (final line in const LineSplitter().convert(committed)) {
        lineNumber++;
        if (line.trim().isNotEmpty) {
          batches.add(_decodeLine(line, lineNumber));
        }
      }
    }

    final tail = bytes.sublist(committedEnd);
    if (tail.isEmpty) {
      return _EvidenceFileState(
        batches,
        archiveManifestDigest: archive.manifestDigest,
        archivedRecordCount: archive.batches.length,
        completeTailWithoutNewline:
            committedEnd > 0 && bytes[committedEnd - 1] != 0x0a,
      );
    }

    try {
      final line = utf8.decode(tail);
      if (line.trim().isNotEmpty) {
        batches.add(_decodeLine(line, lineNumber + 1));
      }
      return _EvidenceFileState(
        batches,
        archiveManifestDigest: archive.manifestDigest,
        archivedRecordCount: archive.batches.length,
        completeTailWithoutNewline: true,
      );
    } on FormatException {
      if (!recoverTail) rethrow;
      await handle.truncate(committedEnd);
      await handle.flush();
      return _EvidenceFileState(
        batches,
        archiveManifestDigest: archive.manifestDigest,
        archivedRecordCount: archive.batches.length,
      );
    }
  }

  Future<List<int>> _readBytes(RandomAccessFile handle) async {
    final length = await handle.length();
    await handle.setPosition(0);
    return handle.read(length);
  }

  Future<_LearningEvidenceSnapshot?> _loadSnapshot(
    List<int> journalBytes, {
    required String archiveManifestDigest,
  }) async {
    final candidates = [
      snapshotFile,
      File('${snapshotFile.path}.backup'),
      File('${snapshotFile.path}.next'),
    ];
    for (final candidate in candidates) {
      if (!await candidate.exists()) continue;
      try {
        final decoded = jsonDecode(await candidate.readAsString());
        if (decoded is! Map<String, dynamic>) continue;
        final snapshot = _LearningEvidenceSnapshot.fromJson(decoded);
        if (snapshot.matchesStorage(
          journalBytes,
          archiveManifestDigest: archiveManifestDigest,
        )) {
          return snapshot;
        }
      } catch (_) {
        // Snapshot is a disposable projection. Replay falls back to JSONL.
      }
    }
    return null;
  }

  Future<void> _publishSnapshot(_LearningEvidenceSnapshot snapshot) async {
    await snapshotFile.parent.create(recursive: true);
    final next = File('${snapshotFile.path}.next');
    final backup = File('${snapshotFile.path}.backup');
    if (await next.exists()) await next.delete();

    final handle = await next.open(mode: FileMode.write);
    try {
      await handle.writeString('${jsonEncode(snapshot.toJson())}\n');
      await handle.flush();
    } finally {
      await handle.close();
    }

    if (await backup.exists()) await backup.delete();
    if (await snapshotFile.exists()) {
      await snapshotFile.rename(backup.path);
    }
    try {
      await next.rename(snapshotFile.path);
    } catch (_) {
      if (!await snapshotFile.exists() && await backup.exists()) {
        await backup.rename(snapshotFile.path);
      }
      rethrow;
    }
  }

  File get _archiveManifestFile => File(
        '${archiveDirectory.path}${Platform.pathSeparator}manifest.json',
      );

  Future<bool> _hasFinalizedOrphanSegments() async {
    if (!await archiveDirectory.exists()) return false;
    final pattern = RegExp(r'^segment-\d{6}\.jsonl$');
    await for (final entity in archiveDirectory.list()) {
      if (entity is File && pattern.hasMatch(entity.uri.pathSegments.last)) {
        return true;
      }
    }
    return false;
  }

  Future<_LearningEvidenceArchive> _loadArchive() async {
    final primary = _archiveManifestFile;
    final candidates = [primary, File('${primary.path}.backup')];
    var foundManifest = false;
    for (final candidate in candidates) {
      if (!await candidate.exists()) continue;
      foundManifest = true;
      try {
        final decoded = jsonDecode(await candidate.readAsString());
        if (decoded is! Map<String, dynamic>) {
          throw const FormatException('Archive manifest must be an object.');
        }
        final manifest = _ArchiveManifest.fromJson(decoded);
        final batches = <LearningEvidenceBatch>[];
        for (final segment in manifest.segments) {
          final segmentFile = File(
            '${archiveDirectory.path}${Platform.pathSeparator}'
            '${segment.fileName}',
          );
          if (!await segmentFile.exists()) {
            throw FormatException(
              'Missing evidence archive segment: ${segment.fileName}.',
            );
          }
          final bytes = await segmentFile.readAsBytes();
          if (bytes.length != segment.byteLength ||
              _sha256Bytes(bytes) != segment.digest) {
            throw FormatException(
              'Evidence archive segment digest mismatch: '
              '${segment.fileName}.',
            );
          }
          final segmentBatches = _decodeSegment(
            bytes,
            segment: segment,
            firstLineNumber: batches.length + 1,
          );
          batches.addAll(segmentBatches);
        }
        return _LearningEvidenceArchive(
          manifest: manifest,
          batches: List.unmodifiable(batches),
        );
      } catch (_) {
        if (candidate.path == candidates.last.path) rethrow;
      }
    }
    if (foundManifest) {
      throw const FormatException('No valid evidence archive manifest.');
    }
    return _LearningEvidenceArchive.empty();
  }

  List<LearningEvidenceBatch> _decodeSegment(
    List<int> bytes, {
    required _ArchiveSegmentDescriptor segment,
    required int firstLineNumber,
  }) {
    final text = utf8.decode(bytes);
    final lines = const LineSplitter()
        .convert(text)
        .where((line) => line.trim().isNotEmpty)
        .toList(growable: false);
    if (lines.length != segment.recordCount) {
      throw FormatException(
        'Evidence archive record count mismatch: ${segment.fileName}.',
      );
    }
    return [
      for (var index = 0; index < lines.length; index++)
        _decodeLine(lines[index], firstLineNumber + index),
    ];
  }

  Future<_LearningEvidenceArchive> _recoverPendingCompaction(
    RandomAccessFile handle,
    List<int> journalBytes,
    _LearningEvidenceArchive archive,
  ) async {
    final pendingLength = archive.manifest.pendingJournalByteLength;
    final pendingDigest = archive.manifest.pendingJournalPrefixDigest;
    if (pendingLength == 0 || pendingDigest == null) {
      throw const FormatException('Invalid pending archive recovery state.');
    }
    if (journalBytes.isNotEmpty) {
      if (journalBytes.length < pendingLength ||
          _sha256Bytes(journalBytes.sublist(0, pendingLength)) !=
              pendingDigest) {
        throw const FormatException(
          'Active journal does not match pending archive compaction.',
        );
      }
      final suffix = journalBytes.sublist(pendingLength);
      await handle.setPosition(0);
      if (suffix.isNotEmpty) await handle.writeFrom(suffix);
      await handle.truncate(suffix.length);
      await handle.flush();
    }
    final committed = archive.commitPending();
    await _publishArchiveManifest(committed.manifest);
    await _deleteSnapshotProjections();
    return committed;
  }

  Future<void> _publishArchiveSegment(
    _ArchiveSegmentDescriptor segment,
    List<int> bytes,
  ) async {
    await archiveDirectory.create(recursive: true);
    final target = File(
      '${archiveDirectory.path}${Platform.pathSeparator}${segment.fileName}',
    );
    if (await target.exists()) {
      if (_sha256Bytes(await target.readAsBytes()) == segment.digest) return;
      throw FormatException(
        'Orphan archive segment conflicts with ${segment.fileName}.',
      );
    }
    final next = File('${target.path}.next');
    if (await next.exists()) await next.delete();
    final handle = await next.open(mode: FileMode.write);
    try {
      await handle.writeFrom(bytes);
      await handle.flush();
    } finally {
      await handle.close();
    }
    if (_sha256Bytes(await next.readAsBytes()) != segment.digest) {
      throw const FileSystemException('Archive segment verification failed.');
    }
    await next.rename(target.path);
  }

  Future<void> _publishArchiveManifest(_ArchiveManifest manifest) async {
    await archiveDirectory.create(recursive: true);
    final primary = _archiveManifestFile;
    final next = File('${primary.path}.next');
    final backup = File('${primary.path}.backup');
    final backupNext = File('${backup.path}.next');
    final bytes = utf8.encode('${jsonEncode(manifest.toJson())}\n');

    await _writeFlushed(next, bytes);
    if (await primary.exists()) {
      if (await backup.exists()) await backup.delete();
      await primary.rename(backup.path);
    }
    await next.rename(primary.path);

    await _writeFlushed(backupNext, bytes);
    if (await backup.exists()) await backup.delete();
    await backupNext.rename(backup.path);
  }

  Future<void> _writeFlushed(File target, List<int> bytes) async {
    if (await target.exists()) await target.delete();
    final handle = await target.open(mode: FileMode.write);
    try {
      await handle.writeFrom(bytes);
      await handle.flush();
    } finally {
      await handle.close();
    }
  }

  Future<void> _deleteSnapshotProjections() async {
    for (final candidate in [
      snapshotFile,
      File('${snapshotFile.path}.backup'),
      File('${snapshotFile.path}.next'),
    ]) {
      if (await candidate.exists()) await candidate.delete();
    }
  }

  LearningEvidenceBatch _decodeLine(String line, int lineNumber) {
    try {
      final decoded = jsonDecode(line);
      if (decoded is! Map<String, dynamic>) throw const FormatException();
      return LearningEvidenceBatch.fromJson(decoded);
    } catch (_) {
      throw FormatException(
        'Invalid learning evidence at ${file.path}:$lineNumber.',
      );
    }
  }
}

class _LearningEvidenceSnapshot {
  const _LearningEvidenceSnapshot({
    required this.journalByteLength,
    required this.journalPrefixDigest,
    required this.archiveManifestDigest,
    required this.batches,
    required this.digest,
  });

  factory _LearningEvidenceSnapshot.create({
    required List<int> journalBytes,
    required List<LearningEvidenceBatch> batches,
    required String archiveManifestDigest,
  }) {
    final payload = _snapshotPayload(
      journalByteLength: journalBytes.length,
      journalPrefixDigest: _sha256Bytes(journalBytes),
      archiveManifestDigest: archiveManifestDigest,
      batches: batches,
    );
    return _LearningEvidenceSnapshot(
      journalByteLength: journalBytes.length,
      journalPrefixDigest: payload['journalPrefixDigest'] as String,
      archiveManifestDigest: archiveManifestDigest,
      batches: List.unmodifiable(batches),
      digest: _sha256Json(payload),
    );
  }

  factory _LearningEvidenceSnapshot.fromJson(Map<String, dynamic> json) {
    if (json['schemaVersion'] != _snapshotSchemaVersion) {
      throw const FormatException('Unsupported evidence snapshot version.');
    }
    final rawBatches = json['batches'];
    final rawSourceVersions = json['sourceSchemaVersions'];
    if (rawBatches is! List ||
        rawSourceVersions is! List ||
        rawSourceVersions.length != rawBatches.length ||
        rawSourceVersions.any((version) => version is! int)) {
      throw const FormatException(
        'Snapshot batches and source versions must be parallel arrays.',
      );
    }
    final batches = [
      for (var index = 0; index < rawBatches.length; index++)
        LearningEvidenceBatch.fromSnapshotJson(
          Map<String, dynamic>.from(rawBatches[index] as Map),
          sourceSchemaVersion: rawSourceVersions[index] as int,
        ),
    ];
    final journalByteLength = json['journalByteLength'];
    final journalPrefixDigest = json['journalPrefixDigest'];
    final archiveManifestDigest = json['archiveManifestDigest'];
    final recordCount = json['recordCount'];
    final lastCommandId = json['lastCommandId'];
    final expectedDigest = json['digest'];
    if (journalByteLength is! int ||
        journalByteLength < 0 ||
        journalPrefixDigest is! String ||
        archiveManifestDigest is! String ||
        recordCount != batches.length ||
        lastCommandId != (batches.isEmpty ? null : batches.last.commandId) ||
        expectedDigest is! String) {
      throw const FormatException('Invalid evidence snapshot metadata.');
    }
    final payload = _snapshotPayload(
      journalByteLength: journalByteLength,
      journalPrefixDigest: journalPrefixDigest,
      archiveManifestDigest: archiveManifestDigest,
      batches: batches,
    );
    if (_sha256Json(payload) != expectedDigest) {
      throw const FormatException('Evidence snapshot digest mismatch.');
    }
    return _LearningEvidenceSnapshot(
      journalByteLength: journalByteLength,
      journalPrefixDigest: journalPrefixDigest,
      archiveManifestDigest: archiveManifestDigest,
      batches: batches,
      digest: expectedDigest,
    );
  }

  final int journalByteLength;
  final String journalPrefixDigest;
  final String archiveManifestDigest;
  final List<LearningEvidenceBatch> batches;
  final String digest;

  bool matchesStorage(
    List<int> journalBytes, {
    required String archiveManifestDigest,
  }) {
    if (this.archiveManifestDigest != archiveManifestDigest ||
        journalByteLength > journalBytes.length) {
      return false;
    }
    return _sha256Bytes(journalBytes.sublist(0, journalByteLength)) ==
        journalPrefixDigest;
  }

  Map<String, dynamic> toJson() => {
        ..._snapshotPayload(
          journalByteLength: journalByteLength,
          journalPrefixDigest: journalPrefixDigest,
          archiveManifestDigest: archiveManifestDigest,
          batches: batches,
        ),
        'digest': digest,
      };
}

Map<String, dynamic> _snapshotPayload({
  required int journalByteLength,
  required String journalPrefixDigest,
  required String archiveManifestDigest,
  required List<LearningEvidenceBatch> batches,
}) =>
    {
      'schemaVersion': _snapshotSchemaVersion,
      'journalByteLength': journalByteLength,
      'journalPrefixDigest': journalPrefixDigest,
      'archiveManifestDigest': archiveManifestDigest,
      'recordCount': batches.length,
      'lastCommandId': batches.isEmpty ? null : batches.last.commandId,
      'sourceSchemaVersions': [
        for (final batch in batches) batch.sourceSchemaVersion,
      ],
      'batches': batches.map((batch) => batch.toJson()).toList(),
    };

String _sha256Bytes(List<int> bytes) => sha256.convert(bytes).toString();

String _sha256Json(Map<String, dynamic> value) =>
    _sha256Bytes(utf8.encode(jsonEncode(value)));

class _LearningEvidenceArchive {
  const _LearningEvidenceArchive({
    required this.manifest,
    required this.batches,
  });

  factory _LearningEvidenceArchive.empty() => _LearningEvidenceArchive(
        manifest: _ArchiveManifest.empty(),
        batches: const [],
      );

  final _ArchiveManifest manifest;
  final List<LearningEvidenceBatch> batches;

  bool get hasPendingCompaction => manifest.state == 'pending';
  String get manifestDigest => manifest.segments.isEmpty ? '' : manifest.digest;

  LearningEvidenceArchiveMetadata get metadata =>
      LearningEvidenceArchiveMetadata(
        segmentCount: manifest.segments.length,
        archivedRecordCount: manifest.recordCount,
        manifestDigest: manifestDigest,
      );

  _LearningEvidenceArchive append(
    _ArchiveSegmentDescriptor segment, {
    required List<int> pendingJournalBytes,
  }) {
    final nextManifest = _ArchiveManifest.create(
      state: 'pending',
      segments: [...manifest.segments, segment],
      pendingJournalByteLength: pendingJournalBytes.length,
      pendingJournalPrefixDigest: _sha256Bytes(pendingJournalBytes),
    );
    return _LearningEvidenceArchive(
      manifest: nextManifest,
      batches: batches,
    );
  }

  _LearningEvidenceArchive commitPending() => _LearningEvidenceArchive(
        manifest: _ArchiveManifest.create(
          state: 'committed',
          segments: manifest.segments,
        ),
        batches: batches,
      );
}

class _ArchiveManifest {
  const _ArchiveManifest({
    required this.state,
    required this.segments,
    required this.recordCount,
    required this.pendingJournalByteLength,
    required this.pendingJournalPrefixDigest,
    required this.digest,
  });

  factory _ArchiveManifest.empty() => _ArchiveManifest.create(
        state: 'committed',
        segments: const [],
      );

  factory _ArchiveManifest.create({
    required String state,
    required List<_ArchiveSegmentDescriptor> segments,
    int pendingJournalByteLength = 0,
    String? pendingJournalPrefixDigest,
  }) {
    final immutableSegments = List<_ArchiveSegmentDescriptor>.unmodifiable(
      segments,
    );
    final recordCount = immutableSegments.fold<int>(
      0,
      (total, segment) => total + segment.recordCount,
    );
    final payload = _archiveManifestPayload(
      state: state,
      segments: immutableSegments,
      recordCount: recordCount,
      pendingJournalByteLength: pendingJournalByteLength,
      pendingJournalPrefixDigest: pendingJournalPrefixDigest,
    );
    return _ArchiveManifest(
      state: state,
      segments: immutableSegments,
      recordCount: recordCount,
      pendingJournalByteLength: pendingJournalByteLength,
      pendingJournalPrefixDigest: pendingJournalPrefixDigest,
      digest: _sha256Json(payload),
    );
  }

  factory _ArchiveManifest.fromJson(Map<String, dynamic> json) {
    if (json['schemaVersion'] != _archiveManifestSchemaVersion) {
      throw const FormatException('Unsupported archive manifest version.');
    }
    final state = json['state'];
    final rawSegments = json['segments'];
    if ((state != 'committed' && state != 'pending') || rawSegments is! List) {
      throw const FormatException('Invalid archive manifest state.');
    }
    final segments = rawSegments
        .map(
          (item) => _ArchiveSegmentDescriptor.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList(growable: false);
    var expectedStart = 0;
    String? previousDigest;
    for (var index = 0; index < segments.length; index++) {
      final segment = segments[index];
      if (segment.index != index + 1 ||
          segment.startRecord != expectedStart ||
          segment.previousDigest != previousDigest) {
        throw const FormatException('Archive segment chain is not contiguous.');
      }
      expectedStart += segment.recordCount;
      previousDigest = segment.digest;
    }
    final recordCount = json['recordCount'];
    final segmentCount = json['segmentCount'];
    final pendingLength = json['pendingJournalByteLength'];
    final pendingDigest = json['pendingJournalPrefixDigest'];
    final expectedDigest = json['digest'];
    if (segmentCount != segments.length ||
        recordCount != expectedStart ||
        pendingLength is! int ||
        pendingLength < 0 ||
        expectedDigest is! String ||
        (state == 'committed' &&
            (pendingLength != 0 || pendingDigest != null)) ||
        (state == 'pending' &&
            (pendingLength == 0 || pendingDigest is! String))) {
      throw const FormatException('Invalid archive manifest metadata.');
    }
    final payload = _archiveManifestPayload(
      state: state as String,
      segments: segments,
      recordCount: recordCount as int,
      pendingJournalByteLength: pendingLength,
      pendingJournalPrefixDigest: pendingDigest as String?,
    );
    if (_sha256Json(payload) != expectedDigest) {
      throw const FormatException('Archive manifest digest mismatch.');
    }
    return _ArchiveManifest(
      state: state,
      segments: List.unmodifiable(segments),
      recordCount: recordCount,
      pendingJournalByteLength: pendingLength,
      pendingJournalPrefixDigest: pendingDigest,
      digest: expectedDigest,
    );
  }

  final String state;
  final List<_ArchiveSegmentDescriptor> segments;
  final int recordCount;
  final int pendingJournalByteLength;
  final String? pendingJournalPrefixDigest;
  final String digest;

  Map<String, dynamic> toJson() => {
        ..._archiveManifestPayload(
          state: state,
          segments: segments,
          recordCount: recordCount,
          pendingJournalByteLength: pendingJournalByteLength,
          pendingJournalPrefixDigest: pendingJournalPrefixDigest,
        ),
        'digest': digest,
      };
}

Map<String, dynamic> _archiveManifestPayload({
  required String state,
  required List<_ArchiveSegmentDescriptor> segments,
  required int recordCount,
  required int pendingJournalByteLength,
  required String? pendingJournalPrefixDigest,
}) =>
    {
      'schemaVersion': _archiveManifestSchemaVersion,
      'state': state,
      'segmentCount': segments.length,
      'recordCount': recordCount,
      'pendingJournalByteLength': pendingJournalByteLength,
      'pendingJournalPrefixDigest': pendingJournalPrefixDigest,
      'segments': segments.map((segment) => segment.toJson()).toList(),
    };

class _ArchiveSegmentDescriptor {
  const _ArchiveSegmentDescriptor({
    required this.index,
    required this.fileName,
    required this.startRecord,
    required this.recordCount,
    required this.byteLength,
    required this.digest,
    required this.previousDigest,
  });

  factory _ArchiveSegmentDescriptor.create({
    required int index,
    required int startRecord,
    required int recordCount,
    required List<int> bytes,
    required String? previousDigest,
  }) =>
      _ArchiveSegmentDescriptor(
        index: index,
        fileName: 'segment-${index.toString().padLeft(6, '0')}.jsonl',
        startRecord: startRecord,
        recordCount: recordCount,
        byteLength: bytes.length,
        digest: _sha256Bytes(bytes),
        previousDigest: previousDigest,
      );

  factory _ArchiveSegmentDescriptor.fromJson(Map<String, dynamic> json) {
    final index = json['index'];
    final fileName = json['fileName'];
    final startRecord = json['startRecord'];
    final recordCount = json['recordCount'];
    final byteLength = json['byteLength'];
    final digest = json['digest'];
    final previousDigest = json['previousDigest'];
    if (index is! int ||
        index < 1 ||
        fileName != 'segment-${index.toString().padLeft(6, '0')}.jsonl' ||
        startRecord is! int ||
        startRecord < 0 ||
        recordCount is! int ||
        recordCount < 1 ||
        byteLength is! int ||
        byteLength < 1 ||
        digest is! String ||
        (previousDigest != null && previousDigest is! String)) {
      throw const FormatException('Invalid archive segment descriptor.');
    }
    return _ArchiveSegmentDescriptor(
      index: index,
      fileName: fileName as String,
      startRecord: startRecord,
      recordCount: recordCount,
      byteLength: byteLength,
      digest: digest,
      previousDigest: previousDigest as String?,
    );
  }

  final int index;
  final String fileName;
  final int startRecord;
  final int recordCount;
  final int byteLength;
  final String digest;
  final String? previousDigest;

  Map<String, dynamic> toJson() => {
        'index': index,
        'fileName': fileName,
        'startRecord': startRecord,
        'recordCount': recordCount,
        'byteLength': byteLength,
        'digest': digest,
        'previousDigest': previousDigest,
      };
}

class _EvidenceFileState {
  const _EvidenceFileState(
    this.batches, {
    this.archiveManifestDigest = '',
    this.archivedRecordCount = 0,
    this.completeTailWithoutNewline = false,
  });

  final List<LearningEvidenceBatch> batches;
  final String archiveManifestDigest;
  final int archivedRecordCount;
  final bool completeTailWithoutNewline;
}

typedef FileStopShotEvidenceLog = FileLearningEvidenceLog;
