import 'package:billiard_knowledge/billiard_knowledge.dart';
import 'package:pool_os/contracts/stop_shot_contracts.dart';
import 'package:pool_os/features/event/domain/stop_shot_evidence_log.dart';
import 'package:pool_os/features/mastery/domain/learning_decision_engine.dart';

class TechniqueSnapshot {
  const TechniqueSnapshot({
    required this.pack,
    required this.entry,
    required this.technique,
    required this.mastery,
    required this.decision,
  });

  final ExecutableKnowledgePack pack;
  final ExecutableKnowledgeEntry entry;
  final TechniquePayload technique;
  final MasteryAssessment mastery;
  final DecisionRecord decision;
}

class MistakeSnapshot {
  const MistakeSnapshot({
    required this.pack,
    required this.entry,
    required this.mistake,
    required this.assessment,
    required this.decision,
  });

  final ExecutableKnowledgePack pack;
  final ExecutableKnowledgeEntry entry;
  final MistakePayload mistake;
  final MistakeAssessment assessment;
  final DecisionRecord decision;
}

class LearningRuntime {
  const LearningRuntime({
    required this.pack,
    required this.evidenceLog,
    this.clock = DateTime.now,
    this.engine = const LearningDecisionEngine(),
  });

  final ExecutableKnowledgePack pack;
  final LearningEvidenceLog evidenceLog;
  final DateTime Function() clock;
  final LearningDecisionEngine engine;

  Future<TechniqueSnapshot> replayTechnique(String knowledgeId) async {
    final (entry, technique) = _technique(knowledgeId);
    final evaluation = engine.evaluate(
      pack,
      entry,
      technique,
      await evidenceLog.readAll(),
    );
    return TechniqueSnapshot(
      pack: pack,
      entry: entry,
      technique: technique,
      mastery: evaluation.mastery,
      decision: evaluation.decision,
    );
  }

  Future<TechniqueSnapshot> recordCompletedDrill({
    required String knowledgeId,
    required String commandId,
    required int successes,
  }) async {
    final (entry, technique) = _technique(knowledgeId);
    final attempts = technique.measurement.attempts;
    if (successes < 0 || successes > attempts) {
      throw RangeError.range(successes, 0, attempts, 'successes');
    }
    final now = clock().toUtc();
    final batch = LearningEvidenceBatch.createTechnique(
      batchId: 'batch.$commandId',
      commandId: commandId,
      observation: ObservationRecorded(
        observationId: '$commandId.observation',
        commandId: commandId,
        observationType: 'drill.success_rate',
        source: 'manual_drill_summary',
        confidence: 1,
        capturedAt: now,
        subjectId: entry.id,
        payload: {
          'successes': successes,
          'attempts': attempts,
          'rate': attempts == 0 ? 0 : successes / attempts,
        },
        knowledgeVersion: pack.knowledgeVersion,
      ),
      attempt: DrillAttemptCompleted(
        eventId: '$commandId.attempt',
        commandId: commandId,
        occurredAt: now,
        knowledgeId: entry.id,
        drillId: technique.drill.id,
        attempts: attempts,
        successes: successes,
        knowledgeVersion: pack.knowledgeVersion,
      ),
      measurement: OutcomeMeasured(
        eventId: '$commandId.outcome',
        commandId: commandId,
        occurredAt: now,
        outcomeId: '${entry.id}.outcome',
        successes: successes,
        attempts: attempts,
        achieved: successes >= technique.outcome.requiredSuccesses,
        knowledgeVersion: pack.knowledgeVersion,
      ),
    );
    await evidenceLog.append(batch);
    return replayTechnique(knowledgeId);
  }

  Future<MistakeSnapshot> replayMistake(String knowledgeId) async {
    final (entry, mistake) = _mistake(knowledgeId);
    final evaluation = engine.evaluateMistake(
      pack,
      entry,
      mistake,
      await evidenceLog.readAll(),
    );
    return MistakeSnapshot(
      pack: pack,
      entry: entry,
      mistake: mistake,
      assessment: evaluation.assessment,
      decision: evaluation.decision,
    );
  }

  Future<MistakeSnapshot> recordMistakeObservation({
    required String knowledgeId,
    required String commandId,
    required bool resolved,
    required double confidence,
    String source = 'human_review',
  }) async {
    final (entry, _) = _mistake(knowledgeId);
    if (confidence < 0 || confidence > 1) {
      throw RangeError.range(confidence, 0, 1, 'confidence');
    }
    final now = clock().toUtc();
    await evidenceLog.append(
      LearningEvidenceBatch.createObservation(
        batchId: 'batch.$commandId',
        commandId: commandId,
        observation: ObservationRecorded(
          observationId: '$commandId.observation',
          commandId: commandId,
          observationType: resolved ? 'mistake.resolved' : 'mistake.detected',
          source: source,
          confidence: confidence,
          capturedAt: now,
          subjectId: entry.id,
          payload: {'resolved': resolved},
          knowledgeVersion: pack.knowledgeVersion,
        ),
      ),
    );
    return replayMistake(knowledgeId);
  }

  (ExecutableKnowledgeEntry, TechniquePayload) _technique(String id) {
    final entry = pack.byId(id);
    if (entry == null ||
        entry.payload is! TechniquePayload ||
        !entry.capabilities.contains('mastery_policy')) {
      throw ExecutableKnowledgeException(
        '$id is not a measurable Technique.',
      );
    }
    return (entry, entry.payload as TechniquePayload);
  }

  (ExecutableKnowledgeEntry, MistakePayload) _mistake(String id) {
    final entry = pack.byId(id);
    if (entry == null ||
        entry.payload is! MistakePayload ||
        !entry.capabilities.contains('correction_policy')) {
      throw ExecutableKnowledgeException(
        '$id is not an observable Mistake.',
      );
    }
    return (entry, entry.payload as MistakePayload);
  }
}

typedef StopShotSnapshot = TechniqueSnapshot;
typedef StopShotRuntime = LearningRuntime;
