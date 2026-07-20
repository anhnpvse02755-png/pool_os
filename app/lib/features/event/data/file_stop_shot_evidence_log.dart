import 'dart:convert';
import 'dart:io';

import 'package:pool_os/contracts/stop_shot_contracts.dart';
import 'package:pool_os/features/event/domain/stop_shot_evidence_log.dart';

class FileLearningEvidenceLog implements LearningEvidenceLog {
  FileLearningEvidenceLog(this.file);

  final File file;

  @override
  Future<bool> append(LearningEvidenceBatch batch) async {
    final existing = await readAll();
    if (existing.any((item) => item.commandId == batch.commandId)) return false;
    await file.parent.create(recursive: true);
    await file.writeAsString(
      '${jsonEncode(batch.toJson())}\n',
      mode: FileMode.append,
      flush: true,
    );
    return true;
  }

  @override
  Future<List<LearningEvidenceBatch>> readAll() async {
    if (!await file.exists()) return const [];
    final lines = await file.readAsLines();
    return [
      for (var index = 0; index < lines.length; index++)
        if (lines[index].trim().isNotEmpty)
          _decodeLine(lines[index], index + 1),
    ];
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

typedef FileStopShotEvidenceLog = FileLearningEvidenceLog;
