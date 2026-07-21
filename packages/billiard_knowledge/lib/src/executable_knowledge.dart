import 'dart:convert';

import 'package:crypto/crypto.dart';

class ExecutableKnowledgeException implements Exception {
  const ExecutableKnowledgeException(this.message);

  final String message;

  @override
  String toString() => 'ExecutableKnowledgeException: $message';
}

enum ExecutableKnowledgeKind {
  technique,
  mistake,
  concept;

  static ExecutableKnowledgeKind parse(String value) {
    for (final kind in values) {
      if (kind.name == value) return kind;
    }
    throw ExecutableKnowledgeException('Unsupported knowledge kind: $value.');
  }
}

enum MasteryCategory {
  foundation,
  coreCompetitive,
  advanced,
  elite;

  static MasteryCategory parse(String value) {
    for (final category in values) {
      if (category.name == value) return category;
    }
    throw ExecutableKnowledgeException('Unsupported mastery category: $value.');
  }
}

enum MasteryEvaluation {
  deterministic,
  probabilistic;

  static MasteryEvaluation parse(String value) {
    for (final evaluation in values) {
      if (evaluation.name == value) return evaluation;
    }
    throw ExecutableKnowledgeException(
        'Unsupported mastery evaluation: $value.');
  }
}

class MasteryPolicy {
  const MasteryPolicy({
    required this.category,
    required this.evaluation,
    this.thresholdPercent,
  });

  final MasteryCategory category;
  final MasteryEvaluation evaluation;
  final int? thresholdPercent;

  factory MasteryPolicy.fromJson(Map<String, dynamic> json) => MasteryPolicy(
        category: MasteryCategory.parse(_requiredString(json, 'category')),
        evaluation:
            MasteryEvaluation.parse(_requiredString(json, 'evaluation')),
        thresholdPercent: json['thresholdPercent'] as int?,
      );

  int requiredSuccessesFor(int attempts) {
    if (evaluation != MasteryEvaluation.deterministic ||
        thresholdPercent == null) {
      throw ExecutableKnowledgeException(
        '${category.name} does not define a deterministic threshold.',
      );
    }
    return (attempts * thresholdPercent! / 100).ceil();
  }
}

class ExecutableKnowledgePack {
  ExecutableKnowledgePack({
    required this.schemaVersion,
    required this.compilerVersion,
    required this.knowledgeVersion,
    required this.generatedAt,
    required this.contentDigest,
    required this.masteryPolicyVersion,
    required this.masteryPolicies,
    required this.entries,
  }) : _entriesById = {for (final entry in entries) entry.id: entry};

  final int schemaVersion;
  final String compilerVersion;
  final String knowledgeVersion;
  final DateTime generatedAt;
  final String contentDigest;
  final String masteryPolicyVersion;
  final Map<MasteryCategory, MasteryPolicy> masteryPolicies;
  final List<ExecutableKnowledgeEntry> entries;
  final Map<String, ExecutableKnowledgeEntry> _entriesById;

  factory ExecutableKnowledgePack.fromJsonString(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const ExecutableKnowledgeException('Pack root must be an object.');
    }
    return ExecutableKnowledgePack.fromJson(decoded);
  }

  factory ExecutableKnowledgePack.fromJson(Map<String, dynamic> json) {
    final digest = _requiredString(json, 'contentDigest');
    final payload = Map<String, dynamic>.from(json)..remove('contentDigest');
    final actual = sha256.convert(utf8.encode(jsonEncode(payload))).toString();
    if (actual != digest) {
      throw const ExecutableKnowledgeException(
        'Pack content digest does not match.',
      );
    }
    final rawEntries = json['entries'];
    if (rawEntries is! List || rawEntries.isEmpty) {
      throw const ExecutableKnowledgeException(
          'Pack entries must not be empty.');
    }
    final pack = ExecutableKnowledgePack(
      schemaVersion: _requiredInt(json, 'schemaVersion'),
      compilerVersion: _requiredString(json, 'compilerVersion'),
      knowledgeVersion: _requiredString(json, 'knowledgeVersion'),
      generatedAt: DateTime.parse(_requiredString(json, 'generatedAt')),
      contentDigest: digest,
      masteryPolicyVersion: _requiredString(json, 'masteryPolicyVersion'),
      masteryPolicies: _parseMasteryPolicies(
        _requiredObject(json, 'masteryPolicies'),
      ),
      entries: rawEntries
          .map((item) => ExecutableKnowledgeEntry.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList(growable: false),
    );
    pack.validate();
    return pack;
  }

  ExecutableKnowledgeEntry? byId(String id) => _entriesById[id];

  MasteryPolicy masteryPolicy(MasteryCategory category) {
    final policy = masteryPolicies[category];
    if (policy == null) {
      throw ExecutableKnowledgeException(
        'No mastery policy for ${category.name}.',
      );
    }
    return policy;
  }

  List<ExecutableKnowledgeEntry> withCapability(String capability) => entries
      .where((entry) => entry.capabilities.contains(capability))
      .toList(growable: false);

  void validate() {
    if (schemaVersion != 1) {
      throw ExecutableKnowledgeException(
        'Unsupported pack schema version: $schemaVersion.',
      );
    }
    if (_entriesById.length != entries.length) {
      throw const ExecutableKnowledgeException('Duplicate knowledge ID.');
    }
    for (final entry in entries) {
      if (entry.reviewState != 'verified') {
        throw ExecutableKnowledgeException(
          'Runtime only accepts verified knowledge: ${entry.id}.',
        );
      }
      for (final targetId in entry.relations) {
        if (!_entriesById.containsKey(targetId)) {
          throw ExecutableKnowledgeException(
            'Dangling relation ${entry.id} -> $targetId.',
          );
        }
      }
      final seenDependencies = <String>{};
      for (final dependencyId in entry.dependencies) {
        if (!seenDependencies.add(dependencyId)) {
          throw ExecutableKnowledgeException(
            'Duplicate dependency ${entry.id} -> $dependencyId.',
          );
        }
        if (dependencyId == entry.id) {
          throw ExecutableKnowledgeException(
            'Self dependency ${entry.id} -> $dependencyId.',
          );
        }
        if (!_entriesById.containsKey(dependencyId)) {
          throw ExecutableKnowledgeException(
            'Dangling dependency ${entry.id} -> $dependencyId.',
          );
        }
      }
      final expressionDependencies = entry.unlockExpression?.dependencyIds;
      if (expressionDependencies != null &&
          !_sameStrings(expressionDependencies, entry.dependencies)) {
        throw ExecutableKnowledgeException(
          '${entry.id} unlock expression does not match dependencies.',
        );
      }
      final payload = entry.payload;
      if (payload is TechniquePayload) {
        final policy = masteryPolicy(payload.masteryCategory);
        final required = policy.requiredSuccessesFor(
          payload.measurement.attempts,
        );
        if (payload.outcome.requiredSuccesses != required ||
            payload.outcome.requiredAttempts != payload.measurement.attempts) {
          throw ExecutableKnowledgeException(
            '${entry.id} Outcome threshold does not match '
            '${payload.masteryCategory.name} policy.',
          );
        }
      }
      if (payload is TechniquePayload &&
          payload.nextRecommendation.targetType == 'knowledge' &&
          !_entriesById.containsKey(payload.nextRecommendation.id)) {
        throw ExecutableKnowledgeException(
          'Dangling next recommendation ${entry.id} -> '
          '${payload.nextRecommendation.id}.',
        );
      }
    }
    _validateDependencyCycles();
  }

  void _validateDependencyCycles() {
    final visiting = <String>{};
    final visited = <String>{};

    void visit(String entryId) {
      if (visited.contains(entryId)) return;
      if (!visiting.add(entryId)) {
        throw ExecutableKnowledgeException(
          'Dependency cycle detected at $entryId.',
        );
      }
      final dependencies = [..._entriesById[entryId]!.dependencies]..sort();
      for (final dependencyId in dependencies) {
        visit(dependencyId);
      }
      visiting.remove(entryId);
      visited.add(entryId);
    }

    final entryIds = _entriesById.keys.toList()..sort();
    for (final entryId in entryIds) {
      visit(entryId);
    }
  }
}

class ExecutableKnowledgeEntry {
  const ExecutableKnowledgeEntry({
    required this.id,
    required this.kind,
    required this.reviewState,
    required this.title,
    required this.summary,
    required this.body,
    required this.capabilities,
    required this.relations,
    this.dependencies = const [],
    this.unlockExpression,
    required this.payload,
  });

  final String id;
  final ExecutableKnowledgeKind kind;
  final String reviewState;
  final String title;
  final String summary;
  final String body;
  final Set<String> capabilities;
  final List<String> relations;
  final List<String> dependencies;
  final UnlockExpression? unlockExpression;
  final ExecutableKnowledgePayload payload;

  factory ExecutableKnowledgeEntry.fromJson(Map<String, dynamic> json) {
    final kind = ExecutableKnowledgeKind.parse(_requiredString(json, 'kind'));
    return ExecutableKnowledgeEntry(
      id: _requiredString(json, 'id'),
      kind: kind,
      reviewState: _requiredString(json, 'reviewState'),
      title: _requiredString(json, 'title'),
      summary: _requiredString(json, 'summary'),
      body: _requiredString(json, 'body'),
      capabilities: _stringList(json, 'capabilities').toSet(),
      relations: _stringList(json, 'relations'),
      dependencies: json.containsKey('dependencies')
          ? _stringList(json, 'dependencies')
          : const [],
      unlockExpression: json.containsKey('unlockExpression')
          ? UnlockExpression.fromJson(
              _requiredObject(json, 'unlockExpression'),
            )
          : null,
      payload: ExecutableKnowledgePayload.fromJson(
        kind,
        _requiredObject(json, 'payload'),
      ),
    );
  }
}

sealed class UnlockExpression {
  const UnlockExpression({required this.nodeId});

  final String nodeId;

  List<String> get dependencyIds;

  factory UnlockExpression.fromJson(Map<String, dynamic> json) {
    final type = _requiredString(json, 'type');
    return switch (type) {
      'dependency' => UnlockDependencyExpression(
          nodeId: _requiredString(json, 'nodeId'),
          dependencyId: _requiredString(json, 'dependencyId'),
        ),
      'allOf' => UnlockAllOfExpression.fromJson(json),
      _ => throw ExecutableKnowledgeException(
          'Unsupported unlock expression type: $type.',
        ),
    };
  }
}

class UnlockDependencyExpression extends UnlockExpression {
  const UnlockDependencyExpression({
    required super.nodeId,
    required this.dependencyId,
  });

  final String dependencyId;

  @override
  List<String> get dependencyIds => [dependencyId];
}

class UnlockAllOfExpression extends UnlockExpression {
  UnlockAllOfExpression({
    required super.nodeId,
    required List<UnlockExpression> children,
  }) : children = List.unmodifiable(children) {
    if (children.isEmpty) {
      throw const ExecutableKnowledgeException(
        'allOf unlock expression must not be empty.',
      );
    }
  }

  final List<UnlockExpression> children;

  factory UnlockAllOfExpression.fromJson(Map<String, dynamic> json) {
    final rawChildren = json['children'];
    if (rawChildren is! List || rawChildren.isEmpty) {
      throw const ExecutableKnowledgeException(
        'allOf unlock expression must contain children.',
      );
    }
    return UnlockAllOfExpression(
      nodeId: _requiredString(json, 'nodeId'),
      children: rawChildren
          .map(
            (child) => UnlockExpression.fromJson(
              Map<String, dynamic>.from(child as Map),
            ),
          )
          .toList(growable: false),
    );
  }

  @override
  List<String> get dependencyIds {
    final result = [for (final child in children) ...child.dependencyIds]
      ..sort();
    return result;
  }
}

sealed class ExecutableKnowledgePayload {
  const ExecutableKnowledgePayload();

  factory ExecutableKnowledgePayload.fromJson(
    ExecutableKnowledgeKind kind,
    Map<String, dynamic> json,
  ) {
    return switch (kind) {
      ExecutableKnowledgeKind.technique => TechniquePayload.fromJson(json),
      ExecutableKnowledgeKind.mistake => MistakePayload.fromJson(json),
      ExecutableKnowledgeKind.concept => ConceptPayload.fromJson(json),
    };
  }
}

class TechniquePayload extends ExecutableKnowledgePayload {
  const TechniquePayload({
    required this.masteryCategory,
    required this.outcome,
    required this.measurement,
    required this.drill,
    required this.nextRecommendation,
  });

  final MasteryCategory masteryCategory;
  final OutcomeContract outcome;
  final MeasurementProtocol measurement;
  final DrillDefinition drill;
  final NextRecommendation nextRecommendation;

  factory TechniquePayload.fromJson(Map<String, dynamic> json) =>
      TechniquePayload(
        masteryCategory:
            MasteryCategory.parse(_requiredString(json, 'masteryCategory')),
        outcome: OutcomeContract.fromJson(_requiredObject(json, 'outcome')),
        measurement: MeasurementProtocol.fromJson(
          _requiredObject(json, 'measurement'),
        ),
        drill: DrillDefinition.fromJson(_requiredObject(json, 'drill')),
        nextRecommendation: NextRecommendation.fromJson(
          _requiredObject(json, 'nextRecommendation'),
        ),
      );
}

class MistakePayload extends ExecutableKnowledgePayload {
  const MistakePayload({
    required this.masteryCategory,
    required this.resolutionPolicy,
    required this.symptom,
    required this.correction,
    required this.causes,
  });

  final MasteryCategory masteryCategory;
  final MistakeResolutionPolicy resolutionPolicy;
  final String symptom;
  final String correction;
  final List<String> causes;

  factory MistakePayload.fromJson(Map<String, dynamic> json) => MistakePayload(
        masteryCategory:
            MasteryCategory.parse(_requiredString(json, 'masteryCategory')),
        resolutionPolicy: MistakeResolutionPolicy.fromJson(
          _requiredObject(json, 'resolutionPolicy'),
        ),
        symptom: _requiredString(json, 'symptom'),
        correction: _requiredString(json, 'correction'),
        causes: _stringList(json, 'causes', requireNonEmpty: true),
      );
}

class MistakeResolutionPolicy {
  const MistakeResolutionPolicy({
    required this.type,
    required this.requiredConsecutiveClean,
  });

  final String type;
  final int requiredConsecutiveClean;

  factory MistakeResolutionPolicy.fromJson(Map<String, dynamic> json) {
    final policy = MistakeResolutionPolicy(
      type: _requiredString(json, 'type'),
      requiredConsecutiveClean: _requiredInt(
        json,
        'requiredConsecutiveClean',
      ),
    );
    if (policy.type != 'consecutive_clean' ||
        policy.requiredConsecutiveClean < 1) {
      throw const ExecutableKnowledgeException(
        'Unsupported Mistake resolution policy.',
      );
    }
    return policy;
  }
}

class ConceptPayload extends ExecutableKnowledgePayload {
  const ConceptPayload({required this.explanation, required this.keyPoints});

  final String explanation;
  final List<String> keyPoints;

  factory ConceptPayload.fromJson(Map<String, dynamic> json) => ConceptPayload(
        explanation: _requiredString(json, 'explanation'),
        keyPoints: _stringList(json, 'keyPoints', requireNonEmpty: true),
      );
}

class OutcomeContract {
  const OutcomeContract({
    required this.description,
    required this.successRadiusCm,
    required this.requiredSuccesses,
    required this.requiredAttempts,
  });

  final String description;
  final int successRadiusCm;
  final int requiredSuccesses;
  final int requiredAttempts;

  factory OutcomeContract.fromJson(Map<String, dynamic> json) =>
      OutcomeContract(
        description: _requiredString(json, 'description'),
        successRadiusCm: _requiredInt(json, 'successRadiusCm'),
        requiredSuccesses: _requiredInt(json, 'requiredSuccesses'),
        requiredAttempts: _requiredInt(json, 'requiredAttempts'),
      );
}

class MeasurementProtocol {
  const MeasurementProtocol({
    required this.id,
    required this.drillId,
    required this.attempts,
    required this.successDefinition,
  });

  final String id;
  final String drillId;
  final int attempts;
  final String successDefinition;

  factory MeasurementProtocol.fromJson(Map<String, dynamic> json) =>
      MeasurementProtocol(
        id: _requiredString(json, 'id'),
        drillId: _requiredString(json, 'drillId'),
        attempts: _requiredInt(json, 'attempts'),
        successDefinition: _requiredString(json, 'successDefinition'),
      );
}

class DrillDefinition {
  const DrillDefinition({
    required this.id,
    required this.title,
    required this.instructions,
  });

  final String id;
  final String title;
  final List<String> instructions;

  factory DrillDefinition.fromJson(Map<String, dynamic> json) =>
      DrillDefinition(
        id: _requiredString(json, 'id'),
        title: _requiredString(json, 'title'),
        instructions: _stringList(json, 'instructions', requireNonEmpty: true),
      );
}

class NextRecommendation {
  const NextRecommendation({
    required this.id,
    required this.title,
    required this.targetType,
    this.blockedByActiveCorrectionCategory,
  });

  final String id;
  final String title;
  final String targetType;
  final MasteryCategory? blockedByActiveCorrectionCategory;

  factory NextRecommendation.fromJson(Map<String, dynamic> json) =>
      NextRecommendation(
        id: _requiredString(json, 'id'),
        title: _requiredString(json, 'title'),
        targetType: _requiredString(json, 'targetType'),
        blockedByActiveCorrectionCategory:
            json['blockedByActiveCorrectionCategory'] == null
                ? null
                : MasteryCategory.parse(
                    json['blockedByActiveCorrectionCategory'] as String,
                  ),
      );
}

Map<String, dynamic> _requiredObject(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value is! Map<String, dynamic>) {
    throw ExecutableKnowledgeException('$field must be an object.');
  }
  return value;
}

Map<MasteryCategory, MasteryPolicy> _parseMasteryPolicies(
  Map<String, dynamic> json,
) {
  final result = <MasteryCategory, MasteryPolicy>{};
  for (final value in json.values) {
    final policy = MasteryPolicy.fromJson(
      Map<String, dynamic>.from(value as Map),
    );
    if (result.containsKey(policy.category)) {
      throw ExecutableKnowledgeException(
        'Duplicate mastery policy: ${policy.category.name}.',
      );
    }
    result[policy.category] = policy;
  }
  return result;
}

String _requiredString(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value is! String || value.trim().isEmpty) {
    throw ExecutableKnowledgeException('$field must be a non-empty string.');
  }
  return value;
}

int _requiredInt(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value is! int) {
    throw ExecutableKnowledgeException('$field must be an integer.');
  }
  return value;
}

List<String> _stringList(
  Map<String, dynamic> json,
  String field, {
  bool requireNonEmpty = false,
}) {
  final value = json[field];
  if (value is! List || value.any((item) => item is! String)) {
    throw ExecutableKnowledgeException('$field must be a string array.');
  }
  if (requireNonEmpty && value.isEmpty) {
    throw ExecutableKnowledgeException('$field must not be empty.');
  }
  return value.cast<String>();
}

bool _sameStrings(List<String> left, List<String> right) {
  final canonicalLeft = [...left]..sort();
  final canonicalRight = [...right]..sort();
  if (canonicalLeft.length != canonicalRight.length) return false;
  for (var index = 0; index < canonicalLeft.length; index++) {
    if (canonicalLeft[index] != canonicalRight[index]) return false;
  }
  return true;
}
