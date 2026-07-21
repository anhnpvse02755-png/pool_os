import 'dart:convert';

import 'package:crypto/crypto.dart';

const learningEligibilityProjectionVersion = 1;

class LearningEligibilityReasonContract {
  const LearningEligibilityReasonContract({
    required this.code,
    required this.policyVersion,
    this.dependencyId,
    this.expressionNodeId,
  });

  final String code;
  final String policyVersion;
  final String? dependencyId;
  final String? expressionNodeId;

  Map<String, dynamic> toJson() => {
        'code': code,
        'policyVersion': policyVersion,
        if (dependencyId != null) 'dependencyId': dependencyId,
        if (expressionNodeId != null) 'expressionNodeId': expressionNodeId,
      };
}

class LearningEligibilityItem {
  LearningEligibilityItem({
    required this.sourceKnowledgeId,
    required this.resolvedKnowledgeId,
    required this.sourceAvailable,
    required this.sourceDecisionId,
    required this.sourceDecisionPolicyVersion,
    required List<LearningEligibilityReasonContract> blockers,
  }) : blockers = List.unmodifiable(
          <LearningEligibilityReasonContract>[...blockers]
            ..sort(_compareReasons),
        );

  final String sourceKnowledgeId;
  final String resolvedKnowledgeId;
  final bool sourceAvailable;
  final String sourceDecisionId;
  final String sourceDecisionPolicyVersion;
  final List<LearningEligibilityReasonContract> blockers;

  Map<String, dynamic> toJson() => {
        'sourceKnowledgeId': sourceKnowledgeId,
        'resolvedKnowledgeId': resolvedKnowledgeId,
        'sourceAvailable': sourceAvailable,
        'sourceDecisionId': sourceDecisionId,
        'sourceDecisionPolicyVersion': sourceDecisionPolicyVersion,
        'blockers': blockers.map((item) => item.toJson()).toList(),
      };
}

int _compareReasons(
  LearningEligibilityReasonContract a,
  LearningEligibilityReasonContract b,
) {
  final code = a.code.compareTo(b.code);
  if (code != 0) return code;
  final dependency = (a.dependencyId ?? '').compareTo(b.dependencyId ?? '');
  if (dependency != 0) return dependency;
  final expression =
      (a.expressionNodeId ?? '').compareTo(b.expressionNodeId ?? '');
  if (expression != 0) return expression;
  return a.policyVersion.compareTo(b.policyVersion);
}

class LearningEligibilityProjection {
  const LearningEligibilityProjection._({
    required this.knowledgeVersion,
    required this.knowledgeDigest,
    required this.items,
    required this.digest,
  });

  factory LearningEligibilityProjection.create({
    required String knowledgeVersion,
    required String knowledgeDigest,
    required List<LearningEligibilityItem> items,
  }) {
    _requireText(knowledgeVersion, 'knowledgeVersion');
    _requireText(knowledgeDigest, 'knowledgeDigest');
    final ordered = [...items]
      ..sort((a, b) => a.sourceKnowledgeId.compareTo(b.sourceKnowledgeId));
    if (ordered.map((item) => item.sourceKnowledgeId).toSet().length !=
        ordered.length) {
      throw ArgumentError('Learning eligibility contains duplicate sources.');
    }
    for (final item in ordered) {
      _requireText(item.sourceKnowledgeId, 'sourceKnowledgeId');
      _requireText(item.resolvedKnowledgeId, 'resolvedKnowledgeId');
      _requireText(item.sourceDecisionId, 'sourceDecisionId');
      _requireText(
        item.sourceDecisionPolicyVersion,
        'sourceDecisionPolicyVersion',
      );
    }
    final payload = {
      'schemaVersion': learningEligibilityProjectionVersion,
      'knowledgeVersion': knowledgeVersion,
      'knowledgeDigest': knowledgeDigest,
      'items': ordered.map((item) => item.toJson()).toList(),
    };
    return LearningEligibilityProjection._(
      knowledgeVersion: knowledgeVersion,
      knowledgeDigest: knowledgeDigest,
      items: List.unmodifiable(ordered),
      digest: _digest(payload),
    );
  }

  final String knowledgeVersion;
  final String knowledgeDigest;
  final List<LearningEligibilityItem> items;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': learningEligibilityProjectionVersion,
        'knowledgeVersion': knowledgeVersion,
        'knowledgeDigest': knowledgeDigest,
        'items': items.map((item) => item.toJson()).toList(),
        'digest': digest,
      };
}

void _requireText(String value, String field) {
  if (value.trim().isEmpty) throw ArgumentError('$field must not be empty.');
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
