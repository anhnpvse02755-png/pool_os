import 'package:pool_os/features/coach/domain/findings/finding.dart';
import 'package:pool_os/features/mastery/domain/models/mastery_models.dart';

/// Exposes Mastery measurements to Coach as facts. It does not choose the next
/// lesson; [CoachBrain] makes that decision from the ordered path facts.
List<Finding> produceMasteryFindings(MasterySnapshot snapshot) {
  final findings = <Finding>[];
  for (var pathIndex = 0; pathIndex < snapshot.paths.length; pathIndex++) {
    final path = snapshot.paths[pathIndex];
    for (var stepIndex = 0; stepIndex < path.steps.length; stepIndex++) {
      final step = path.steps[stepIndex];
      findings.add(Finding(
        metricId: 'mastery.entry.${step.step.entryId}',
        source: FindingSource.mastery,
        value: step.score,
        sampleSize: step.mastery.attempts +
            (step.mastery.completedDepth == null ? 0 : 1),
        observedAt: step.mastery.lastEvidenceAt,
        data: {
          'entryId': step.step.entryId,
          'pathId': path.path.id,
          'pathIndex': pathIndex,
          'stepIndex': stepIndex,
          'current': step.current,
          'locked': step.locked,
          'stage': step.depthComplete ? step.mastery.stage.name : 'learning',
          'requiredDepth': step.step.minimumDepth.name,
          'completedDepth': step.mastery.completedDepth?.name,
          'confidence': step.mastery.confidence,
          'attempts': step.mastery.attempts,
          'successes': step.mastery.successes,
          'methodologyId': step.mastery.methodologyId,
        },
      ));
    }
  }
  return findings;
}
