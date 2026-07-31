// EPIC 06 — EquipmentEngine (Deliverable 2.5).
//
// Reads equipment history through AiDataSnapshot (Phase 6.6 wires the
// concrete catalog) and emits a suggestion list. LLM wraps the
// narrative in MockAI mode.

import 'package:pool_os/features/coach/domain/coach_engine.dart';
import 'package:pool_os/features/coach/domain/coach_request.dart';
import 'package:pool_os/features/coach/domain/coach_response.dart';
import 'package:pool_os/features/coach/domain/llm/capability.dart';
import 'package:pool_os/features/coach/domain/llm/llm_provider_adapter.dart';

class EquipmentEngine implements CoachEngine {
  final LlmProviderAdapter _llm;

  const EquipmentEngine({required LlmProviderAdapter llm}) : _llm = llm;

  @override
  String get engineId => 'equipment';

  @override
  Future<CoachEngineContribution> run(CoachRequest request) async {
    final equipmentCount = request.data.equipment.length;
    final llmResult = _llm.complete(LlmRequest(
      capabilityId: 'equipment.suggest',
      prompt: 'Suggest equipment updates for the player.',
      context: <String, Object?>{
        'playerId': request.playerId,
        'equipmentCount': equipmentCount,
      },
    ));
    return CoachEngineContribution(
      engineId: engineId,
      status: llmResult.isImplemented
          ? CapabilityStatus.implemented
          : CapabilityStatus.notAvailable,
      reason: llmResult.reason,
      content: <String, Object?>{
        'equipmentReviewed': equipmentCount,
        if (llmResult.isImplemented) 'narrative': llmResult.value?.text,
      },
    );
  }
}