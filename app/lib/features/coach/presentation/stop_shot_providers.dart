import 'package:billiard_knowledge/billiard_knowledge.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/coach/application/learning_runtime.dart';
import 'package:pool_os/features/event/application/stop_shot_evidence_factory.dart';
import 'package:pool_os/features/event/domain/stop_shot_evidence_log.dart';
import 'package:uuid/uuid.dart';

const stopShotKnowledgeId = 'control.stop_shot';
const followShotKnowledgeId = 'control.follow_shot';
const poorSpeedControlMistakeId = 'mistake.poor_speed_control';

final stopShotPackProvider =
    FutureProvider<ExecutableKnowledgePack>((ref) async {
  final raw = await rootBundle.loadString(
    'packages/billiard_knowledge/assets/executable_pack_v0_6.json',
  );
  return ExecutableKnowledgePack.fromJsonString(raw);
});

final stopShotEvidenceLogProvider =
    FutureProvider<LearningEvidenceLog>((ref) async {
  return createLearningEvidenceLog();
});

final learningRuntimeProvider = FutureProvider<LearningRuntime>((ref) async {
  return LearningRuntime(
    pack: await ref.watch(stopShotPackProvider.future),
    evidenceLog: await ref.watch(stopShotEvidenceLogProvider.future),
  );
});

final techniqueControllerProvider = AsyncNotifierProvider.family<
    TechniqueController, TechniqueSnapshot, String>(TechniqueController.new);

final mistakeControllerProvider =
    AsyncNotifierProvider.family<MistakeController, MistakeSnapshot, String>(
        MistakeController.new);

final stopShotControllerProvider =
    techniqueControllerProvider(stopShotKnowledgeId);
final followShotControllerProvider =
    techniqueControllerProvider(followShotKnowledgeId);
final poorSpeedControlControllerProvider =
    mistakeControllerProvider(poorSpeedControlMistakeId);

class TechniqueController
    extends FamilyAsyncNotifier<TechniqueSnapshot, String> {
  LearningRuntime? _runtime;
  late String _knowledgeId;

  @override
  Future<TechniqueSnapshot> build(String arg) async {
    _knowledgeId = arg;
    final runtime = await ref.watch(learningRuntimeProvider.future);
    _runtime = runtime;
    return runtime.replayTechnique(arg);
  }

  Future<void> completeDrill(int successes) async {
    final runtime = _runtime;
    if (runtime == null || state.isLoading) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => runtime.recordCompletedDrill(
        knowledgeId: _knowledgeId,
        commandId: const Uuid().v4(),
        successes: successes,
      ),
    );
  }
}

class MistakeController extends FamilyAsyncNotifier<MistakeSnapshot, String> {
  LearningRuntime? _runtime;
  late String _knowledgeId;

  @override
  Future<MistakeSnapshot> build(String arg) async {
    _knowledgeId = arg;
    final runtime = await ref.watch(learningRuntimeProvider.future);
    _runtime = runtime;
    return runtime.replayMistake(arg);
  }

  Future<void> observe({required bool resolved, double confidence = 1}) async {
    final runtime = _runtime;
    if (runtime == null || state.isLoading) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => runtime.recordMistakeObservation(
        knowledgeId: _knowledgeId,
        commandId: const Uuid().v4(),
        resolved: resolved,
        confidence: confidence,
      ),
    );
  }
}
