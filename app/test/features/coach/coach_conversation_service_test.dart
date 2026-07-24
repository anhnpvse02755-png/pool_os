import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/coach/application/coach_conversation_service.dart';
import 'package:pool_os/features/coach/domain/brain/coach_output.dart';
import 'package:pool_os/features/coach/domain/findings/finding.dart';

void main() {
  group('CoachConversationService', () {
    test('returns the existing primary action through the execution pipeline',
        () async {
      final turn = await CoachConversationService().ask(
        intent: CoachConversationIntent.nextAction,
        output: _output,
      );

      expect(turn.sequence, 1);
      expect(turn.promptKey, 'coach_v2_do_next');
      expect(turn.responseKey, 'coach_v2_action_practice');
      expect(turn.knowledgeId, 'technique.stop-shot');
    });

    test('falls back to the first active structured insight', () async {
      final turn = await CoachConversationService().ask(
        intent: CoachConversationIntent.nextAction,
        output: const CoachOutput(
          level: PlayerLevel(levelKey: 'coach_v2_level_unknown'),
          understanding: CoachUnderstanding(),
          feed: [
            CoachInsightV2(
              id: 'resolved',
              topic: CoachTopic.progress,
              priority: CoachPriority.celebrate,
              observationKey: 'resolved-key',
              lifecycle: CoachLifecycle.resolved,
            ),
            CoachInsightV2(
              id: 'active',
              topic: CoachTopic.training,
              priority: CoachPriority.improve,
              observationKey: 'coach_v2_obs_weak_shot',
              causeKey: 'coach_v2_cause_needs_practice',
              evidence: '20 shots',
            ),
          ],
        ),
      );

      expect(turn.responseKey, 'coach_v2_obs_weak_shot');
      expect(turn.detailKey, 'coach_v2_cause_needs_practice');
      expect(turn.evidence, '20 shots');
    });

    test('reports the existing player-level projection', () async {
      final turn = await CoachConversationService().ask(
        intent: CoachConversationIntent.playerLevel,
        output: _output,
      );

      expect(turn.responseKey, 'coach_v2_level_intermediate');
      expect(turn.detailKey, isNull);
    });

    test('reports canonical data coverage and preserves request order',
        () async {
      final service = CoachConversationService();
      final first = await service.ask(
        intent: CoachConversationIntent.dataCoverage,
        output: _output,
      );
      final second = await service.ask(
        intent: CoachConversationIntent.dataCoverage,
        output: _output,
      );

      expect(first.metric, '75%');
      expect(first.detailKey, 'coach_v2_provisional');
      expect([first.sequence, second.sequence], [1, 2]);
      expect(first.components.skip(1), second.components.skip(1));
    });
  });
}

const _output = CoachOutput(
  level: PlayerLevel(
    levelKey: 'coach_v2_level_intermediate',
    levelConfidence: 0.8,
  ),
  understanding: CoachUnderstanding(
    dataCompleteness: 0.75,
    missing: [FindingSource.readiness],
  ),
  primaryAction: CoachAction(
    labelKey: 'coach_v2_action_practice',
    knowledgeId: 'technique.stop-shot',
  ),
);
