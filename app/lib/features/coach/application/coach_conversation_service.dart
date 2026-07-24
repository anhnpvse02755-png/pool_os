import '../../../application/foundation/application_context.dart';
import '../../../application/foundation/application_handlers.dart';
import '../../../capabilities/coach/coach_capability_contracts.dart';
import '../../../framework/command/command_executor.dart';
import '../../../runtime/coach/coach_capability_runtime.dart';
import '../../../shared/foundation/identifier.dart';
import '../../../shared/foundation/result.dart';
import '../../../shared/foundation/value_object.dart';
import '../domain/brain/coach_output.dart';

enum CoachConversationIntent { nextAction, playerLevel, dataCoverage }

final class CoachConversationTurn extends ValueObject {
  const CoachConversationTurn({
    required this.sequence,
    required this.intent,
    required this.promptKey,
    required this.responseKey,
    this.detailKey,
    this.evidence,
    this.metric,
    this.actionLabelKey,
    this.knowledgeId,
  });

  final int sequence;
  final CoachConversationIntent intent;
  final String promptKey;
  final String responseKey;
  final String? detailKey;
  final String? evidence;
  final String? metric;
  final String? actionLabelKey;
  final String? knowledgeId;

  @override
  List<Object?> get components => [
        sequence,
        intent,
        promptKey,
        responseKey,
        detailKey,
        evidence,
        metric,
        actionLabelKey,
        knowledgeId,
      ];
}

final class CoachConversationService {
  CoachConversationService() {
    final capability = _CoachConversationCapability();
    const CoachCapabilityBootstrap().initialize(
      registry: CoachCapabilityRegistry([capability]),
      identity: capability.metadata.identity,
      compatibility: CoachCapabilityCompatibility(
        requiredVersion: capability.metadata.version,
      ),
    );
  }

  var _requestSequence = 0;

  Future<CoachConversationTurn> ask({
    required CoachConversationIntent intent,
    required CoachOutput output,
  }) async {
    _requestSequence += 1;
    final requestId = RuntimeIdentifier(
      namespace: 'product.coach-conversation.request',
      value: 'ask-$_requestSequence',
    );
    final execution =
        await CommandExecutor<_AskCoachCommand, CoachConversationTurn>(
      handler: const _AskCoachHandler(),
      handlerId: RuntimeIdentifier(
        namespace: 'product.coach-conversation.handler',
        value: 'answer-structured-intent',
      ),
    ).execute(
      command: _AskCoachCommand(
        sequence: _requestSequence,
        intent: intent,
        output: output,
      ),
      context: ApplicationExecutionContext(
        request: ApplicationRequestContext(
          requestId: requestId,
          correlationId: requestId,
          requestedAtUtc: DateTime.now().toUtc(),
        ),
        cancellationToken: const _NeverCancelled(),
      ),
    );
    return execution.result.fold(
      onSuccess: (turn) => turn,
      onFailure: (failure) => throw StateError(failure.code),
    );
  }
}

final class _CoachConversationCapability
    implements
        AdviceGenerationCapability,
        PerformanceReviewCapability,
        RecommendationRequestCapability {
  _CoachConversationCapability()
      : metadata = CoachCapabilityMetadata(
          identity: CoachCapabilityIdentity(_id('capability', 'conversation')),
          version: CoachCapabilityVersion(_id('version', 'v1')),
          kinds: const [
            CoachCapabilityKind.adviceGeneration,
            CoachCapabilityKind.performanceReview,
            CoachCapabilityKind.recommendationRequest,
          ],
        );

  @override
  final CoachCapabilityMetadata metadata;
}

final class _AskCoachCommand extends ValueObject {
  const _AskCoachCommand({
    required this.sequence,
    required this.intent,
    required this.output,
  });

  final int sequence;
  final CoachConversationIntent intent;
  final CoachOutput output;

  @override
  List<Object?> get components => [sequence, intent, output];
}

final class _AskCoachHandler
    implements CommandHandler<_AskCoachCommand, CoachConversationTurn> {
  const _AskCoachHandler();

  @override
  Future<Result<CoachConversationTurn>> handle(
    _AskCoachCommand command,
    ApplicationExecutionContext context,
  ) async {
    return Success(switch (command.intent) {
      CoachConversationIntent.nextAction => _nextAction(command),
      CoachConversationIntent.playerLevel => _playerLevel(command),
      CoachConversationIntent.dataCoverage => _dataCoverage(command),
    });
  }

  CoachConversationTurn _nextAction(_AskCoachCommand command) {
    final output = command.output;
    final action = output.primaryAction;
    if (action != null) {
      return CoachConversationTurn(
        sequence: command.sequence,
        intent: command.intent,
        promptKey: 'coach_v2_do_next',
        responseKey: action.labelKey,
        actionLabelKey: action.labelKey,
        knowledgeId: action.knowledgeId,
      );
    }
    final insight = _firstActiveInsight(output);
    return CoachConversationTurn(
      sequence: command.sequence,
      intent: command.intent,
      promptKey: 'coach_v2_do_next',
      responseKey: insight?.observationKey ?? 'coach_v2_all_clear',
      detailKey: _nonEmpty(insight?.causeKey),
      evidence: _nonEmpty(insight?.evidence),
      actionLabelKey: insight?.action?.labelKey,
      knowledgeId: insight?.action?.knowledgeId,
    );
  }

  CoachConversationTurn _playerLevel(_AskCoachCommand command) {
    final level = command.output.level;
    return CoachConversationTurn(
      sequence: command.sequence,
      intent: command.intent,
      promptKey: 'coach_v2_your_level',
      responseKey: level.levelKey,
      detailKey: level.isProvisional ? 'coach_v2_provisional' : null,
    );
  }

  CoachConversationTurn _dataCoverage(_AskCoachCommand command) {
    final understanding = command.output.understanding;
    return CoachConversationTurn(
      sequence: command.sequence,
      intent: command.intent,
      promptKey: 'coach_v2_understanding',
      responseKey: 'coach_v2_understanding',
      metric: '${(understanding.dataCompleteness * 100).round()}%',
      detailKey: understanding.missing.isEmpty
          ? 'coach_v2_all_clear'
          : 'coach_v2_provisional',
    );
  }

  CoachInsightV2? _firstActiveInsight(CoachOutput output) {
    for (final insight in output.feed) {
      if (insight.lifecycle == CoachLifecycle.active) return insight;
    }
    return null;
  }

  String? _nonEmpty(String? value) =>
      value == null || value.isEmpty ? null : value;
}

final class _NeverCancelled implements CancellationToken {
  const _NeverCancelled();

  @override
  bool get isCancellationRequested => false;
}

RuntimeIdentifier _id(String segment, String value) => RuntimeIdentifier(
      namespace: 'product.coach-conversation.$segment',
      value: value,
    );
