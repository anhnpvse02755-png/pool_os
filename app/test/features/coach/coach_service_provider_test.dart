// EPIC 06 — Provider + service tests for CoachService.
//
// Single regression coverage for the AI Coach layer's public surface.

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/coach/domain/coach_pipeline.dart';
import 'package:pool_os/features/coach/domain/coach_request.dart';
import 'package:pool_os/features/coach/domain/coach_response.dart';
import 'package:pool_os/features/coach/domain/coach_service.dart';
import 'package:pool_os/features/coach/domain/data_sources/ai_data_sources.dart';
import 'package:pool_os/features/coach/domain/llm/capability.dart';
import 'package:pool_os/features/coach/domain/llm/llm_provider_adapter.dart';

CoachService _service() {
  return CoachService(defaultCoachPipeline(const MockAIAdapter()));
}

CoachRequest _req() => CoachRequest(
      playerId: 'p1',
      asOf: DateTime.utc(2026, 7, 31),
      data: AiDataSnapshot.empty,
    );

void main() {
  group('CoachService — 7 deliverable surfaces', () {
    test('coachDaily returns aggregated CoachResponse', () async {
      final r = await _service().coachDaily(_req());
      expect(r.playerId, 'p1');
      expect(r.contributions, isNotEmpty);
      expect(r.summary, contains('AI Coach'));
    });

    test('recommend returns CoachResponse with recommendation engine',
        () async {
      final r = await _service().recommend(_req());
      final ids = r.contributions.map((c) => c.engineId).toList();
      expect(ids, contains('recommendation'));
    });

    test('adviseStrategy returns planned (Wave 2)', () async {
      final r = await _service().adviseStrategy(_req());
      final ids = r.contributions.map((c) => c.engineId).toList();
      expect(ids, contains('strategy'));
    });

    test('analyzePatterns returns planned (Wave 2)', () async {
      final r = await _service().analyzePatterns(_req());
      final ids = r.contributions.map((c) => c.engineId).toList();
      expect(ids, contains('pattern'));
    });

    test('suggestEquipment returns planned (Wave 3)', () async {
      final r = await _service().suggestEquipment(_req());
      final ids = r.contributions.map((c) => c.engineId).toList();
      expect(ids, contains('equipment'));
    });

    test('suggestTraining returns planned (Wave 3)', () async {
      final r = await _service().suggestTraining(_req());
      final ids = r.contributions.map((c) => c.engineId).toList();
      expect(ids, contains('training'));
    });

    test('reviewMatch returns planned (Wave 3)', () async {
      final r = await _service().reviewMatch(_req());
      final ids = r.contributions.map((c) => c.engineId).toList();
      expect(ids, contains('match_review'));
    });
  });

  group('CoachResponse — contribution shape', () {
    test('every contribution has engineId and a status', () async {
      final r = await _service().coachDaily(_req());
      for (final c in r.contributions) {
        expect(c.engineId, isNotEmpty);
        // planned (post-Wave-1 engines) is a valid status.
        expect(c.status, isIn([
          CapabilityStatus.implemented,
          CapabilityStatus.notAvailable,
          CapabilityStatus.planned,
        ]));
      }
    });
  });
}