import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/coach_context_contracts.dart';
import 'package:pool_os/contracts/coach_planning_graph_contracts.dart';
import 'package:pool_os/contracts/ordered_recommendation_view_contracts.dart';

const intelligenceTraceContractVersion = 1;
const intelligenceTraceEntryContractVersion = 1;
const intelligenceTracePolicyVersion = 'intelligence-trace/1.0.0';

enum IntelligenceTraceStage { planning, recommendation }

class IntelligenceTraceEntryContract {
  const IntelligenceTraceEntryContract({
    required this.sequence,
    required this.stage,
    required this.ruleId,
    required this.inputReferences,
    required this.outputReferences,
    required this.reasonCode,
  });

  final int sequence;
  final IntelligenceTraceStage stage;
  final String ruleId;
  final List<String> inputReferences;
  final List<String> outputReferences;
  final String reasonCode;

  Map<String, dynamic> toJson() => {
        'schemaVersion': intelligenceTraceEntryContractVersion,
        'sequence': sequence,
        'stage': stage.name,
        'ruleId': ruleId,
        'inputReferences': inputReferences,
        'outputReferences': outputReferences,
        'reasonCode': reasonCode,
      };
}

class IntelligenceTraceContract {
  const IntelligenceTraceContract._({
    required this.id,
    required this.playerId,
    required this.contextDigest,
    required this.entries,
    required this.digest,
  });

  factory IntelligenceTraceContract.create({
    required CoachContextContract context,
    required List<IntelligenceTraceEntryContract> entries,
  }) {
    if (entries.isEmpty) {
      throw ArgumentError('Intelligence Trace requires entries.');
    }
    final ordered = [...entries]
      ..sort((a, b) => a.sequence.compareTo(b.sequence));
    final rules = <String>{};
    for (var index = 0; index < ordered.length; index++) {
      final entry = ordered[index];
      if (entry.sequence != index + 1 ||
          entry.ruleId.trim().isEmpty ||
          entry.reasonCode.trim().isEmpty ||
          entry.inputReferences.isEmpty ||
          entry.outputReferences.isEmpty ||
          entry.inputReferences.any((item) => item.trim().isEmpty) ||
          entry.outputReferences.any((item) => item.trim().isEmpty) ||
          !rules.add('${entry.sequence}:${entry.stage.name}')) {
        throw ArgumentError('Intelligence Trace entry is invalid.');
      }
    }
    final payload = {
      'schemaVersion': intelligenceTraceContractVersion,
      'playerId': context.profile.playerId,
      'contextDigest': context.digest,
      'entries': ordered.map((item) => item.toJson()).toList(),
      'policyVersion': intelligenceTracePolicyVersion,
    };
    final digest = _digest(payload);
    return IntelligenceTraceContract._(
      id: 'intelligence-trace.${digest.substring(0, 16)}',
      playerId: context.profile.playerId,
      contextDigest: context.digest,
      entries: List.unmodifiable(ordered),
      digest: digest,
    );
  }

  final String id;
  final String playerId;
  final String contextDigest;
  final List<IntelligenceTraceEntryContract> entries;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': intelligenceTraceContractVersion,
        'id': id,
        'playerId': playerId,
        'contextDigest': contextDigest,
        'entries': entries.map((item) => item.toJson()).toList(),
        'policyVersion': intelligenceTracePolicyVersion,
        'digest': digest,
      };
}

class IntelligenceTraceBuilder {
  const IntelligenceTraceBuilder();

  IntelligenceTraceContract build({
    required CoachContextContract context,
    CoachPlanningGraphContract? planningGraph,
    OrderedRecommendationViewContract? recommendationView,
  }) {
    if (planningGraph == null && recommendationView == null) {
      throw ArgumentError('Intelligence Trace requires observable outputs.');
    }
    if (planningGraph != null &&
        (planningGraph.playerId != context.profile.playerId ||
            planningGraph.versions.contextDigest != context.digest)) {
      throw ArgumentError('Planning Trace input is stale or foreign.');
    }
    if (recommendationView != null &&
        (recommendationView.playerId != context.profile.playerId ||
            recommendationView.contextDigest != context.digest)) {
      throw ArgumentError('Recommendation Trace input is stale or foreign.');
    }
    final entries = <IntelligenceTraceEntryContract>[];
    var sequence = 1;
    if (planningGraph != null) {
      for (final edge in planningGraph.edges) {
        entries.add(IntelligenceTraceEntryContract(
          sequence: sequence++,
          stage: IntelligenceTraceStage.planning,
          ruleId: edge.kind.name,
          inputReferences: [edge.fromNodeId],
          outputReferences: [edge.toNodeId],
          reasonCode: 'planning_dependency_applied',
        ));
      }
    }
    if (recommendationView != null) {
      for (final item in recommendationView.items) {
        entries.add(IntelligenceTraceEntryContract(
          sequence: sequence++,
          stage: IntelligenceTraceStage.recommendation,
          ruleId: item.band.name,
          inputReferences: [item.recommendationId],
          outputReferences: [item.recommendationId],
          reasonCode: item.reasons.first.name,
        ));
      }
    }
    return IntelligenceTraceContract.create(context: context, entries: entries);
  }
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
