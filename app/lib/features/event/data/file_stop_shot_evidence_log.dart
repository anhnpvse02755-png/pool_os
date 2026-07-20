import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/stop_shot_contracts.dart';
import 'package:pool_os/features/event/domain/stop_shot_evidence_log.dart';

const _snapshotSchemaVersion = 1;

class FileLearningEvidenceLog implements SnapshottingLearningEvidenceLog {
  FileLearningEvidenceLog(this.file, {File? snapshotFile})
      : snapshotFile = snapshotFile ?? File('${file.path}.snapshot.json');

  final File file;
  final File snapshotFile;

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
    if (!await file.exists()) return const [];
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
      );
      await _publishSnapshot(snapshot);
      return LearningEvidenceSnapshotMetadata(
        recordCount: snapshot.batches.length,
        journalByteLength: snapshot.journalByteLength,
        digest: snapshot.digest,
      );
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
    final length = await handle.length();
    if (length == 0) return const _EvidenceFileState([]);

    final bytes = await _readBytes(handle);
    final snapshot = await _loadSnapshot(bytes);
    final start = snapshot?.journalByteLength ?? 0;
    final remaining = bytes.sublist(start);
    final lastNewline = remaining.lastIndexOf(0x0a);
    final committedEnd = start + (lastNewline < 0 ? 0 : lastNewline + 1);
    final batches = [...?snapshot?.batches];
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
        completeTailWithoutNewline: true,
      );
    } on FormatException {
      if (!recoverTail) rethrow;
      await handle.truncate(committedEnd);
      await handle.flush();
      return _EvidenceFileState(batches);
    }
  }

  Future<List<int>> _readBytes(RandomAccessFile handle) async {
    final length = await handle.length();
    await handle.setPosition(0);
    return handle.read(length);
  }

  Future<_LearningEvidenceSnapshot?> _loadSnapshot(
    List<int> journalBytes,
  ) async {
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
        if (snapshot.matchesJournal(journalBytes)) return snapshot;
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
    required this.batches,
    required this.digest,
  });

  factory _LearningEvidenceSnapshot.create({
    required List<int> journalBytes,
    required List<LearningEvidenceBatch> batches,
  }) {
    final payload = _snapshotPayload(
      journalByteLength: journalBytes.length,
      journalPrefixDigest: _sha256Bytes(journalBytes),
      batches: batches,
    );
    return _LearningEvidenceSnapshot(
      journalByteLength: journalBytes.length,
      journalPrefixDigest: payload['journalPrefixDigest'] as String,
      batches: List.unmodifiable(batches),
      digest: _sha256Json(payload),
    );
  }

  factory _LearningEvidenceSnapshot.fromJson(Map<String, dynamic> json) {
    if (json['schemaVersion'] != _snapshotSchemaVersion) {
      throw const FormatException('Unsupported evidence snapshot version.');
    }
    final rawBatches = json['batches'];
    if (rawBatches is! List) {
      throw const FormatException('Snapshot batches must be an array.');
    }
    final batches = rawBatches
        .map(
          (item) => LearningEvidenceBatch.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList(growable: false);
    final journalByteLength = json['journalByteLength'];
    final journalPrefixDigest = json['journalPrefixDigest'];
    final recordCount = json['recordCount'];
    final lastCommandId = json['lastCommandId'];
    final expectedDigest = json['digest'];
    if (journalByteLength is! int ||
        journalByteLength < 0 ||
        journalPrefixDigest is! String ||
        recordCount != batches.length ||
        lastCommandId != (batches.isEmpty ? null : batches.last.commandId) ||
        expectedDigest is! String) {
      throw const FormatException('Invalid evidence snapshot metadata.');
    }
    final payload = _snapshotPayload(
      journalByteLength: journalByteLength,
      journalPrefixDigest: journalPrefixDigest,
      batches: batches,
    );
    if (_sha256Json(payload) != expectedDigest) {
      throw const FormatException('Evidence snapshot digest mismatch.');
    }
    return _LearningEvidenceSnapshot(
      journalByteLength: journalByteLength,
      journalPrefixDigest: journalPrefixDigest,
      batches: batches,
      digest: expectedDigest,
    );
  }

  final int journalByteLength;
  final String journalPrefixDigest;
  final List<LearningEvidenceBatch> batches;
  final String digest;

  bool matchesJournal(List<int> journalBytes) {
    if (journalByteLength > journalBytes.length) return false;
    return _sha256Bytes(journalBytes.sublist(0, journalByteLength)) ==
        journalPrefixDigest;
  }

  Map<String, dynamic> toJson() => {
        ..._snapshotPayload(
          journalByteLength: journalByteLength,
          journalPrefixDigest: journalPrefixDigest,
          batches: batches,
        ),
        'digest': digest,
      };
}

Map<String, dynamic> _snapshotPayload({
  required int journalByteLength,
  required String journalPrefixDigest,
  required List<LearningEvidenceBatch> batches,
}) =>
    {
      'schemaVersion': _snapshotSchemaVersion,
      'journalByteLength': journalByteLength,
      'journalPrefixDigest': journalPrefixDigest,
      'recordCount': batches.length,
      'lastCommandId': batches.isEmpty ? null : batches.last.commandId,
      'batches': batches.map((batch) => batch.toJson()).toList(),
    };

String _sha256Bytes(List<int> bytes) => sha256.convert(bytes).toString();

String _sha256Json(Map<String, dynamic> value) =>
    _sha256Bytes(utf8.encode(jsonEncode(value)));

class _EvidenceFileState {
  const _EvidenceFileState(
    this.batches, {
    this.completeTailWithoutNewline = false,
  });

  final List<LearningEvidenceBatch> batches;
  final bool completeTailWithoutNewline;
}

typedef FileStopShotEvidenceLog = FileLearningEvidenceLog;
