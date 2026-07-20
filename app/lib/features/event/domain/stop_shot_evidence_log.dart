import 'package:pool_os/contracts/stop_shot_contracts.dart';

abstract interface class LearningEvidenceLog {
  /// Returns false when this command was already appended.
  Future<bool> append(LearningEvidenceBatch batch);

  Future<List<LearningEvidenceBatch>> readAll();
}

typedef StopShotEvidenceLog = LearningEvidenceLog;
