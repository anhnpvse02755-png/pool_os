import 'package:billiard_knowledge/billiard_knowledge.dart';
import 'package:pool_os/contracts/stop_shot_contracts.dart';
import 'package:pool_os/features/event/domain/stop_shot_evidence_log.dart';
import 'package:pool_os/features/mastery/domain/learning_decision_engine.dart';

sealed class LearningSnapshot {
  const LearningSnapshot();

  ExecutableKnowledgePack get pack;
  ExecutableKnowledgeEntry get entry;
  DecisionRecord get decision;
}

class TechniqueSnapshot extends LearningSnapshot {
  const TechniqueSnapshot({
    required this.pack,
    required this.entry,
    required this.technique,
    required this.mastery,
    required this.decision,
  });

  @override
  final ExecutableKnowledgePack pack;
  @override
  final ExecutableKnowledgeEntry entry;
  final TechniquePayload technique;
  final MasteryAssessment mastery;
  @override
  final DecisionRecord decision;
}

class MistakeSnapshot extends LearningSnapshot {
  const MistakeSnapshot({
    required this.pack,
    required this.entry,
    required this.mistake,
    required this.assessment,
    required this.decision,
  });

  @override
  final ExecutableKnowledgePack pack;
  @override
  final ExecutableKnowledgeEntry entry;
  final MistakePayload mistake;
  final MistakeAssessment assessment;
  @override
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

  Future<LearningSnapshot> replay(String knowledgeId) async {
    final entry = pack.byId(knowledgeId);
    if (entry == null) {
      throw ExecutableKnowledgeException(
        'Unknown learning Knowledge entry: $knowledgeId.',
      );
    }
    final evaluation = engine.evaluateEntry(
      pack,
      entry,
      await evidenceLog.readAll(),
    );
    return switch (evaluation) {
      LearningEvaluation value => TechniqueSnapshot(
          pack: pack,
          entry: entry,
          technique: entry.payload as TechniquePayload,
          mastery: value.mastery,
          decision: value.decision,
        ),
      MistakeEvaluation value => MistakeSnapshot(
          pack: pack,
          entry: entry,
          mistake: entry.payload as MistakePayload,
          assessment: value.assessment,
          decision: value.decision,
        ),
    };
  }

  Future<TechniqueSnapshot> replayTechnique(String knowledgeId) async {
    final snapshot = await replay(knowledgeId);
    if (snapshot is! TechniqueSnapshot) {
      throw ExecutableKnowledgeException(
        '$knowledgeId is not a measurable Technique.',
      );
    }
    return snapshot;
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
    final snapshot = await replay(knowledgeId);
    if (snapshot is! MistakeSnapshot) {
      throw ExecutableKnowledgeException(
        '$knowledgeId is not an observable Mistake.',
      );
    }
    return snapshot;
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
