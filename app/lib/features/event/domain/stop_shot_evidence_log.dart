import 'package:pool_os/contracts/stop_shot_contracts.dart';

abstract interface class LearningEvidenceLog {
  /// Returns false when this command was already appended.
  Future<bool> append(LearningEvidenceBatch batch);

  Future<List<LearningEvidenceBatch>> readAll();
}

abstract interface class SnapshottingLearningEvidenceLog
    implements LearningEvidenceLog {
  Future<LearningEvidenceSnapshotMetadata> createSnapshot();
}

abstract interface class CompactingLearningEvidenceLog
    implements SnapshottingLearningEvidenceLog {
  Future<LearningEvidenceArchiveMetadata> compactActiveJournal();
}

class LearningEvidenceSnapshotMetadata {
  const LearningEvidenceSnapshotMetadata({
    required this.recordCount,
    required this.journalByteLength,
    required this.digest,
  });

  final int recordCount;
  final int journalByteLength;
  final String digest;
}

class LearningEvidenceArchiveMetadata {
  const LearningEvidenceArchiveMetadata({
    required this.segmentCount,
    required this.archivedRecordCount,
    required this.manifestDigest,
  });

  final int segmentCount;
  final int archivedRecordCount;
  final String manifestDigest;
}

typedef StopShotEvidenceLog = LearningEvidenceLog;
