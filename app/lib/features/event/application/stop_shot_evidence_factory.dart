import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pool_os/features/event/data/file_stop_shot_evidence_log.dart';
import 'package:pool_os/features/event/domain/stop_shot_evidence_log.dart';

Future<LearningEvidenceLog> createLearningEvidenceLog() async {
  final documents = await getApplicationDocumentsDirectory();
  return FileLearningEvidenceLog(
    File(
      '${documents.path}${Platform.pathSeparator}pool_os'
      '${Platform.pathSeparator}evidence'
      '${Platform.pathSeparator}stop_shot.jsonl',
    ),
  );
}

Future<LearningEvidenceLog> createStopShotEvidenceLog() =>
    createLearningEvidenceLog();
