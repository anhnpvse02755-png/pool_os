import 'package:pool_os/contracts/ai_session_contracts.dart';
import 'package:pool_os/contracts/coach_context_contracts.dart';
import 'package:pool_os/contracts/coach_execution_contracts.dart';
import 'package:pool_os/contracts/coach_plan_contracts.dart';
import 'package:pool_os/contracts/coach_recommendation_contracts.dart';

class AISessionBuilder {
  const AISessionBuilder({
    this.minimumAIContractVersion = aiSessionMinimumVersion,
    this.requiredRuntimeContracts = requiredAISessionRuntimeContracts,
  });

  static const aiSessionMinimumVersion = 'ai-session/1.0.0';

  final String minimumAIContractVersion;
  final Map<String, int> requiredRuntimeContracts;

  AISessionContract build({
    required CoachContextContract context,
    required CoachPlanContract plan,
    required CoachRecommendationContract recommendation,
    required CoachExecutionRecordContract execution,
  }) {
    _validateCompatibility(
      context: context,
      plan: plan,
      recommendation: recommendation,
      execution: execution,
    );
    final ids = {
      context.digest,
      plan.id,
      recommendation.id,
      execution.id,
    };
    if (ids.length != 4) {
      throw ArgumentError('AISession contains duplicate semantic objects.');
    }
    final provenance = AISessionProvenance(
      knowledgeVersion: context.versions.knowledgeVersion,
      knowledgeDigest: context.versions.knowledgeDigest,
      contextDigest: context.digest,
      planDigest: plan.digest,
      recommendationDigest: recommendation.digest,
      executionDigest: execution.digest,
    );
    return AISessionContract.create(
      contextId: context.digest,
      planId: plan.id,
      recommendationId: recommendation.id,
      executionId: execution.id,
      knowledgeVersion: context.versions.knowledgeVersion,
      knowledgeDigest: context.versions.knowledgeDigest,
      contextDigest: context.digest,
      planDigest: plan.digest,
      recommendationDigest: recommendation.digest,
      executionDigest: execution.digest,
      provenance: provenance,
      requiredRuntimeContracts: requiredRuntimeContracts,
      minimumAIContractVersion: minimumAIContractVersion,
    );
  }

  void _validateCompatibility({
    required CoachContextContract context,
    required CoachPlanContract plan,
    required CoachRecommendationContract recommendation,
    required CoachExecutionRecordContract execution,
  }) {
    if (minimumAIContractVersion != aiSessionMinimumVersion) {
      throw ArgumentError('Unsupported minimum AI contract version.');
    }
    final supportedContracts = {
      'coachContext': coachContextContractVersion,
      'coachPlan': coachPlanContractVersion,
      'coachRecommendation': coachRecommendationContractVersion,
      'coachExecutionRecord': coachExecutionRecordContractVersion,
    };
    if (!_sameContracts(
          requiredAISessionRuntimeContracts,
          supportedContracts,
        ) ||
        !_sameContracts(requiredRuntimeContracts, supportedContracts)) {
      throw ArgumentError('Unsupported runtime contract set.');
    }
    if (plan.versions.contextContractVersion != coachContextContractVersion ||
        plan.versions.contextDigest != context.digest ||
        plan.versions.knowledgeVersion != context.versions.knowledgeVersion ||
        plan.versions.knowledgeDigest != context.versions.knowledgeDigest) {
      throw ArgumentError('AISession Plan is stale or incompatible.');
    }
    if (recommendation.versions.contextContractVersion !=
            coachContextContractVersion ||
        recommendation.versions.contextDigest != context.digest ||
        recommendation.versions.planContractVersion !=
            coachPlanContractVersion ||
        recommendation.versions.planDigest != plan.digest ||
        recommendation.versions.knowledgeVersion !=
            context.versions.knowledgeVersion ||
        recommendation.versions.knowledgeDigest !=
            context.versions.knowledgeDigest) {
      throw ArgumentError('AISession Recommendation is stale or incompatible.');
    }
    if (execution.versions.recommendationContractVersion !=
            coachRecommendationContractVersion ||
        execution.recommendationId != recommendation.id ||
        execution.recommendationDigest != recommendation.digest) {
      throw ArgumentError('AISession Execution is stale or incompatible.');
    }
  }

  bool _sameContracts(
    Map<String, int> contracts,
    Map<String, int> supportedContracts,
  ) {
    if (contracts.length != supportedContracts.length) {
      return false;
    }
    for (final entry in supportedContracts.entries) {
      if (contracts[entry.key] != entry.value) return false;
    }
    return true;
  }
}
