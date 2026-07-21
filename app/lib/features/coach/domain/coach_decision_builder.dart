import 'package:pool_os/contracts/coach_context_contracts.dart';
import 'package:pool_os/contracts/coach_decision_contracts.dart';

class CoachDecisionBuilder {
  const CoachDecisionBuilder();

  CoachDecisionContract build(CoachContextContract context) {
    final mistakes = context.progress.state.mistakes
        .where((mistake) => mistake.state == 'persistent')
        .toList()
      ..sort((a, b) => a.knowledgeId.compareTo(b.knowledgeId));
    final techniques = context.progress.state.mastery
        .where((technique) => !technique.mastered)
        .toList()
      ..sort((a, b) => a.knowledgeId.compareTo(b.knowledgeId));
    final effectiveAt = context.experience.timeline.events
        .map((event) => event.occurredAt.toUtc())
        .reduce((a, b) => a.isAfter(b) ? a : b);
    final versions = CoachDecisionVersionBinding(
      contextContractVersion: coachContextContractVersion,
      contextDigest: context.digest,
      knowledgeVersion: context.progress.knowledgeVersion,
      knowledgeDigest: context.progress.knowledgeDigest,
      policyVersion: coachDecisionPolicyVersion,
    );

    if (mistakes.isNotEmpty) {
      final selected = mistakes.first;
      return CoachDecisionContract.create(
        effectiveAt: effectiveAt,
        action: CoachDecisionAction.correctMistake,
        targetKnowledgeId: selected.knowledgeId,
        reasons: [
          CoachDecisionReason(
            code: CoachDecisionReasonCode.persistentMistakeRequiresCorrection,
            knowledgeId: selected.knowledgeId,
            observedState: selected.state,
          ),
        ],
        trace: _trace(
          mistakeCount: mistakes.length,
          techniqueCount: techniques.length,
          outcomeCode: 'persistent_mistake_selected',
          knowledgeId: selected.knowledgeId,
        ),
        alternatives: [
          for (final mistake in mistakes.skip(1))
            CoachDecisionAlternative(
              action: CoachDecisionAction.correctMistake,
              knowledgeId: mistake.knowledgeId,
              reason: CoachDecisionAlternativeReason.lowerCanonicalPriority,
            ),
          for (final technique in techniques)
            CoachDecisionAlternative(
              action: CoachDecisionAction.practiceTechnique,
              knowledgeId: technique.knowledgeId,
              reason: CoachDecisionAlternativeReason.correctionPriority,
            ),
        ],
        versions: versions,
      );
    }

    if (techniques.isNotEmpty) {
      final selected = techniques.first;
      return CoachDecisionContract.create(
        effectiveAt: effectiveAt,
        action: CoachDecisionAction.practiceTechnique,
        targetKnowledgeId: selected.knowledgeId,
        reasons: [
          CoachDecisionReason(
            code: CoachDecisionReasonCode.masteryBelowThreshold,
            knowledgeId: selected.knowledgeId,
            observedState: 'inProgress',
          ),
        ],
        trace: _trace(
          mistakeCount: 0,
          techniqueCount: techniques.length,
          outcomeCode: 'unmastered_technique_selected',
          knowledgeId: selected.knowledgeId,
        ),
        alternatives: [
          for (final technique in techniques.skip(1))
            CoachDecisionAlternative(
              action: CoachDecisionAction.practiceTechnique,
              knowledgeId: technique.knowledgeId,
              reason: CoachDecisionAlternativeReason.lowerCanonicalPriority,
            ),
        ],
        versions: versions,
      );
    }

    return CoachDecisionContract.create(
      effectiveAt: effectiveAt,
      action: CoachDecisionAction.readyForNextCapability,
      targetKnowledgeId: null,
      reasons: const [
        CoachDecisionReason(
          code: CoachDecisionReasonCode.allTrackedCapabilitiesMastered,
        ),
      ],
      trace: _trace(
        mistakeCount: 0,
        techniqueCount: 0,
        outcomeCode: 'readiness_selected',
        knowledgeId: null,
      ),
      alternatives: const [],
      versions: versions,
    );
  }

  List<CoachDecisionTraceStep> _trace({
    required int mistakeCount,
    required int techniqueCount,
    required String outcomeCode,
    required String? knowledgeId,
  }) =>
      [
        const CoachDecisionTraceStep(
          sequence: 1,
          stage: CoachDecisionTraceStage.contextValidation,
          outcomeCode: 'context_valid',
        ),
        CoachDecisionTraceStep(
          sequence: 2,
          stage: CoachDecisionTraceStage.candidateCollection,
          outcomeCode: 'persistent_$mistakeCount.unmastered_$techniqueCount',
        ),
        CoachDecisionTraceStep(
          sequence: 3,
          stage: CoachDecisionTraceStage.selection,
          outcomeCode: outcomeCode,
          knowledgeId: knowledgeId,
        ),
        CoachDecisionTraceStep(
          sequence: 4,
          stage: CoachDecisionTraceStage.decision,
          outcomeCode: 'semantic_decision_emitted',
          knowledgeId: knowledgeId,
        ),
      ];
}
