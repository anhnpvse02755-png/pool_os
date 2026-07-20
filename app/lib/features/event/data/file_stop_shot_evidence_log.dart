import 'dart:convert';
import 'dart:io';

import 'package:pool_os/contracts/stop_shot_contracts.dart';
import 'package:pool_os/features/event/domain/stop_shot_evidence_log.dart';

class FileLearningEvidenceLog implements LearningEvidenceLog {
  FileLearningEvidenceLog(this.file);

  final File file;

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

    await handle.setPosition(0);
    final bytes = await handle.read(length);
    final lastNewline = bytes.lastIndexOf(0x0a);
    final committedEnd = lastNewline < 0 ? 0 : lastNewline + 1;
    final batches = <LearningEvidenceBatch>[];
    var lineNumber = 0;

    if (committedEnd > 0) {
      final committed = utf8.decode(bytes.sublist(0, committedEnd));
      for (final line in const LineSplitter().convert(committed)) {
        lineNumber++;
        if (line.trim().isNotEmpty) {
          batches.add(_decodeLine(line, lineNumber));
        }
      }
    }

    final tail = bytes.sublist(committedEnd);
    if (tail.isEmpty) return _EvidenceFileState(batches);

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

class _EvidenceFileState {
  const _EvidenceFileState(
    this.batches, {
    this.completeTailWithoutNewline = false,
  });

  final List<LearningEvidenceBatch> batches;
  final bool completeTailWithoutNewline;
}

typedef FileStopShotEvidenceLog = FileLearningEvidenceLog;
