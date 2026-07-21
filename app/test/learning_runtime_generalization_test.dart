import 'dart:io';

import 'package:billiard_knowledge/billiard_knowledge.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/stop_shot_contracts.dart';
import 'package:pool_os/features/coach/application/learning_runtime.dart';
import 'package:pool_os/features/event/domain/stop_shot_evidence_log.dart';

void main() {
  late ExecutableKnowledgePack pack;

  setUpAll(() {
    pack = ExecutableKnowledgePack.fromJsonString(
      File(
        '../packages/billiard_knowledge/test/fixtures/lr_1/generated/'
        'published_candidate.json',
      ).readAsStringSync(),
    );
  });

  group('LR-1 policy dispatch and deterministic ranking', () {
    test('advanced Technique uses its published policy without ID branching',
        () async {
      final log = _MemoryLearningEvidenceLog();
      final runtime = _runtime(pack, log);

      expect(await runtime.replay('technique.bank_shot'),
          isA<TechniqueSnapshot>());
      expect(
        await runtime.replay('mistake.bank_alignment_left'),
        isA<MistakeSnapshot>(),
      );

      final below = await runtime.recordCompletedDrill(
        knowledgeId: 'technique.bank_shot',
        commandId: 'bank-15',
        successes: 15,
      );
      expect(below.mastery.attempts, 20);
      expect(below.mastery.mastered, isFalse);
      expect(
        below.decision.recommendations.selected.id,
        'technique.bank_shot',
      );

      final achieved = await runtime.recordCompletedDrill(
        knowledgeId: 'technique.bank_shot',
        commandId: 'bank-16',
        successes: 16,
      );
      expect(achieved.mastery.mastered, isTrue);
      expect(
        achieved.decision.recommendations.selected.id,
        'status.bank_shot_complete',
      );
      expect(
        achieved.decision.trace
            .firstWhere((reason) => reason.code == 'OUTCOME_ACHIEVED')
            .parameters['masteryCategory'],
        'advanced',
      );
    });

    test('Evidence stays isolated across Techniques and Mistakes', () async {
      final log = _MemoryLearningEvidenceLog();
      final runtime = _runtime(pack, log);
      await runtime.recordCompletedDrill(
        knowledgeId: 'technique.bank_shot',
        commandId: 'bank-only',
        successes: 16,
      );
      await runtime.recordMistakeObservation(
        knowledgeId: 'mistake.bank_alignment_left',
        commandId: 'left-only',
        resolved: false,
        confidence: 1,
      );

      final kick = await runtime.replayTechnique('technique.kick_shot');
      final right = await runtime.replayMistake('mistake.bank_alignment_right');
      expect(kick.mastery.evidenceCount, 0);
      expect(kick.mastery.mastered, isFalse);
      expect(right.assessment.state.name, 'unobserved');
      expect(right.assessment.observationCount, 0);
    });

    test('equal policy scores use stable semantic ID after pack reorder',
        () async {
      final log = _MemoryLearningEvidenceLog();
      final runtime = _runtime(pack, log);
      await runtime.recordMistakeObservation(
        knowledgeId: 'mistake.bank_alignment_right',
        commandId: 'right-detected',
        resolved: false,
        confidence: 1,
      );
      await runtime.recordMistakeObservation(
        knowledgeId: 'mistake.bank_alignment_left',
        commandId: 'left-detected',
        resolved: false,
        confidence: 1,
      );
      final normal = await runtime.recordCompletedDrill(
        knowledgeId: 'technique.bank_shot',
        commandId: 'bank-ranked',
        successes: 16,
      );
      final reordered = await _runtime(_reversed(pack), log)
          .replayTechnique('technique.bank_shot');

      List<String> equalScoreCorrections(TechniqueSnapshot snapshot) =>
          snapshot.decision.recommendations.alternatives
              .where((candidate) => candidate.score == 75)
              .map((candidate) => candidate.id)
              .toList();

      expect(equalScoreCorrections(normal), [
        'mistake.bank_alignment_left',
        'mistake.bank_alignment_right',
      ]);
      expect(equalScoreCorrections(reordered), equalScoreCorrections(normal));
      expect(
        reordered.decision.recommendations.selected.id,
        normal.decision.recommendations.selected.id,
      );
    });

    test('unsupported entry, capability, and probabilistic policy stop loudly',
        () async {
      final log = _MemoryLearningEvidenceLog();
      final runtime = _runtime(pack, log);

      await expectLater(
        runtime.replay('concept.bank_geometry'),
        throwsA(isA<ExecutableKnowledgeException>()),
      );
      await expectLater(
        runtime.replay('unknown.learning.entry'),
        throwsA(isA<ExecutableKnowledgeException>()),
      );

      final bank = pack.byId('technique.bank_shot')!;
      final withoutCapability = _replaceEntry(
        pack,
        _copyEntry(bank, capabilities: const {}),
      );
      await expectLater(
        _runtime(withoutCapability, log).replay(bank.id),
        throwsA(isA<ExecutableKnowledgeException>()),
      );

      final technique = bank.payload as TechniquePayload;
      final probabilistic = _replaceEntry(
        pack,
        _copyEntry(
          bank,
          payload: TechniquePayload(
            masteryCategory: MasteryCategory.elite,
            outcome: technique.outcome,
            measurement: technique.measurement,
            drill: technique.drill,
            nextRecommendation: technique.nextRecommendation,
          ),
        ),
      );
      await expectLater(
        _runtime(probabilistic, log).replay(bank.id),
        throwsA(isA<ExecutableKnowledgeException>()),
      );
    });
  });
}

LearningRuntime _runtime(
  ExecutableKnowledgePack pack,
  LearningEvidenceLog log,
) =>
    LearningRuntime(
      pack: pack,
      evidenceLog: log,
      clock: () => DateTime.utc(2026, 7, 21, 12),
    );

ExecutableKnowledgePack _reversed(ExecutableKnowledgePack pack) =>
    ExecutableKnowledgePack(
      schemaVersion: pack.schemaVersion,
      compilerVersion: pack.compilerVersion,
      knowledgeVersion: pack.knowledgeVersion,
      generatedAt: pack.generatedAt,
      contentDigest: pack.contentDigest,
      masteryPolicyVersion: pack.masteryPolicyVersion,
      masteryPolicies: pack.masteryPolicies,
      entries: pack.entries.reversed.toList(growable: false),
    );

ExecutableKnowledgePack _replaceEntry(
  ExecutableKnowledgePack pack,
  ExecutableKnowledgeEntry replacement,
) =>
    ExecutableKnowledgePack(
      schemaVersion: pack.schemaVersion,
      compilerVersion: pack.compilerVersion,
      knowledgeVersion: pack.knowledgeVersion,
      generatedAt: pack.generatedAt,
      contentDigest: pack.contentDigest,
      masteryPolicyVersion: pack.masteryPolicyVersion,
      masteryPolicies: pack.masteryPolicies,
      entries: [
        for (final entry in pack.entries)
          if (entry.id == replacement.id) replacement else entry,
      ],
    );

ExecutableKnowledgeEntry _copyEntry(
  ExecutableKnowledgeEntry entry, {
  Set<String>? capabilities,
  ExecutableKnowledgePayload? payload,
}) =>
    ExecutableKnowledgeEntry(
      id: entry.id,
      kind: entry.kind,
      reviewState: entry.reviewState,
      title: entry.title,
      summary: entry.summary,
      body: entry.body,
      capabilities: capabilities ?? entry.capabilities,
      relations: entry.relations,
      dependencies: entry.dependencies,
      payload: payload ?? entry.payload,
    );

class _MemoryLearningEvidenceLog implements LearningEvidenceLog {
  final List<LearningEvidenceBatch> _batches = [];

  @override
  Future<bool> append(LearningEvidenceBatch batch) async {
    if (_batches.any((item) => item.commandId == batch.commandId)) return false;
    _batches.add(batch);
    return true;
  }

  @override
  Future<List<LearningEvidenceBatch>> readAll() async =>
      List.unmodifiable(_batches);
}
