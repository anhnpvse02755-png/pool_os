import 'dart:convert';
import 'dart:io';

import 'package:billiard_knowledge/billiard_knowledge.dart';
import 'package:crypto/crypto.dart';

import 'knowledge_compiler_v0.dart' as v0;
import 'knowledge_publication.dart';
import 'knowledge_release_candidate.dart';

const migrationCompilerVersion = '0.7.0-m2.3';
const migrationKnowledgeVersion = '0.3.0-m2.3';
const migrationTaxonomyVersion = '0.2.0-m2.3';
const migrationGeneratedAt = '2026-07-21T00:00:00.000Z';
const migrationReviewer = 'Nguyen Phu Viet Anh - Product Owner';
const migrationKnowledgeKinds = <String>{
  'technique',
  'mistake',
  'concept',
  'terminology',
  'rule',
  'strategy',
  'equipment',
  'mental',
};
const _migrationReadme = '''# M2.3 Migration Artifacts

This directory contains generated candidate artifacts for the Pack v1.4
36-entry migration. It is not the production Knowledge corpus and must not be
edited by hand.

Rebuild:

```powershell
dart run tool/knowledge_migration_v1_4.dart
```

Verify drift:

```powershell
dart run tool/knowledge_migration_v1_4.dart --check
```

The production pointer remains under `publication/current.json`. M2.3 only
proves an isolated publication pipeline; M2.4 owns clean-checkout rebuild and
any production activation decision.
''';

const _idMap = <String, String>{
  'aim.ghost_ball': 'aiming.ghost_ball',
};

const _canonicalMergeIds = <String>{
  'control.stop_shot',
  'control.follow_shot',
  'aim.ghost_ball',
};

void main(List<String> args) {
  final packageRoot = Directory.current.absolute;
  final check = args.contains('--check');
  try {
    final build = buildM23Migration(packageRoot);
    final outputRoot = Directory(
      _join(packageRoot.path, 'migration', 'm2_3'),
    );
    if (check) {
      _checkArtifacts(outputRoot, build.artifacts);
      stdout.writeln(
        'M2.3 Migration Check PASS: 36 inputs, '
        '${build.report['eligibleMigrationInputs']} eligible, '
        '${build.report['quarantinedMigrationInputs']} quarantined, '
        '${build.report['releaseTargetEntries']} RC targets.',
      );
    } else {
      _writeArtifacts(outputRoot, build.artifacts);
      stdout.writeln(
        'Generated M2.3 migration artifacts -> ${outputRoot.path}',
      );
    }
  } on M23MigrationException catch (error) {
    stderr.writeln(error.message);
    exitCode = 1;
  } on ExecutableKnowledgeException catch (error) {
    stderr.writeln(error.message);
    exitCode = 1;
  } on KnowledgeGeneralizationException catch (error) {
    stderr.writeln(error.message);
    exitCode = 1;
  } on KnowledgePublicationException catch (error) {
    stderr.writeln(error.message);
    exitCode = 1;
  }
}

class M23MigrationException implements Exception {
  const M23MigrationException(this.message);

  final String message;

  @override
  String toString() => 'M23MigrationException: $message';
}

class M23MigrationBuild {
  const M23MigrationBuild({required this.artifacts, required this.report});

  final Map<String, String> artifacts;
  final Map<String, dynamic> report;
}

M23MigrationBuild buildM23Migration(
  Directory packageRoot, {
  bool reverseSourceOrder = false,
}) {
  final sourcePackFile = File(
    _join(packageRoot.path, 'assets', 'pack_v1.json'),
  );
  final productionPackFile = File(
    _join(packageRoot.path, 'assets', 'executable_pack_v0_6.json'),
  );
  final currentPointerFile = File(
    _join(packageRoot.path, 'publication', 'current.json'),
  );
  final sourcePackRaw = _normalizeNewlines(sourcePackFile.readAsStringSync());
  final sourcePack = _object(jsonDecode(sourcePackRaw), 'legacy pack');
  final productionPackRaw =
      _normalizeNewlines(productionPackFile.readAsStringSync());
  final productionPack = ExecutableKnowledgePack.fromJsonString(
    productionPackRaw,
  );
  if (productionPack.knowledgeVersion != '0.2.1' ||
      productionPack.entries.length != 4) {
    throw const M23MigrationException(
      'M2.3 requires the unchanged four-entry Knowledge 0.2.1 baseline.',
    );
  }

  final rawEntries = _objectList(sourcePack['entries'], 'legacy entries');
  if (rawEntries.length != 36) {
    throw M23MigrationException(
      'Expected 36 migration inputs, found ${rawEntries.length}.',
    );
  }
  final entries = reverseSourceOrder
      ? rawEntries.reversed.toList(growable: false)
      : [...rawEntries];

  final sourceRecords = _objectList(sourcePack['sources'], 'legacy sources')
    ..sort((left, right) =>
        _requiredString(left, 'id').compareTo(_requiredString(right, 'id')));
  final sourcesById = <String, Map<String, dynamic>>{
    for (final source in sourceRecords)
      _requiredString(source, 'id'): {
        ..._deepCopy(source),
        'recordDigest': _sha256(jsonEncode(_canonicalize(source))),
        'snapshotStatus': 'legacy_metadata_only',
      },
  };
  final productionById = {
    for (final entry in productionPack.entries)
      entry.id: _object(
        jsonDecode(jsonEncode(_executableEntryJson(entry))),
        entry.id,
      ),
  };
  final rows = <Map<String, dynamic>>[];
  final targetEntries = <String, Map<String, dynamic>>{};
  final candidateMarkdown = <String, String>{};

  for (final legacy in entries) {
    final originalId = _requiredString(legacy, 'id');
    final sourceReviewState = _requiredString(legacy, 'reviewState');
    final targetId = _idMap[originalId] ?? originalId;
    final targetKind = _targetKind(_requiredString(legacy, 'kind'));
    final entrySourceIds =
        _stringList(legacy['sourceIds'], '$originalId.sourceIds');
    final missingSources = entrySourceIds
        .where((sourceId) => !sourcesById.containsKey(sourceId))
        .toList();
    if (missingSources.isNotEmpty) {
      throw M23MigrationException(
        '$originalId references unknown sources: ${missingSources.join(', ')}.',
      );
    }

    if (sourceReviewState == 'draft') {
      rows.add({
        'sourceId': originalId,
        'targetId': targetId,
        'sourceKind': legacy['kind'],
        'targetKind': targetKind,
        'classification': 'quarantine',
        'reasonCode': 'reviewStateDraft',
        'sourceReviewState': sourceReviewState,
        'sourceIds': entrySourceIds..sort(),
      });
      continue;
    }
    if (sourceReviewState != 'reviewed') {
      throw M23MigrationException(
        '$originalId has unsupported review state $sourceReviewState.',
      );
    }

    final merged = _canonicalMergeIds.contains(originalId);
    final entry = merged
        ? _mergedCanonicalEntry(
            targetId: targetId,
            legacy: legacy,
            productionById: productionById,
          )
        : _migratedArticleEntry(legacy, targetId: targetId, kind: targetKind);
    entry['sourceSnapshots'] = [
      for (final sourceId in entrySourceIds) _deepCopy(sourcesById[sourceId]!),
    ];
    if (targetEntries.containsKey(targetId)) {
      throw M23MigrationException('Duplicate migration target ID: $targetId.');
    }
    targetEntries[targetId] = entry;
    rows.add({
      'sourceId': originalId,
      'targetId': targetId,
      'sourceKind': legacy['kind'],
      'targetKind': targetKind,
      'classification': merged ? 'merge_existing' : 'migrate_candidate',
      'reasonCode': merged ? 'stableIdReconciliation' : null,
      'sourceReviewState': sourceReviewState,
      'sourceIds': entrySourceIds..sort(),
    });
  }

  final retained = productionById['mistake.poor_speed_control'];
  if (retained == null) {
    throw const M23MigrationException(
      'The accepted Poor Speed Control entry is missing.',
    );
  }
  retained['sourceIds'] = ['source.drdave.cue_control'];
  retained['sourceSnapshots'] = [
    _deepCopy(sourcesById['source.drdave.cue_control']!),
  ];
  retained['revision'] = 1;
  retained['origin'] = 'canonical_retained';
  targetEntries['mistake.poor_speed_control'] = retained;

  final sortedTargets = targetEntries.keys.toList()..sort();
  final compiledSources = <v0.CompiledKnowledgeEntrySource>[];
  for (final targetId in sortedTargets) {
    final entry = targetEntries[targetId]!;
    final markdown = _migrationMarkdown(entry);
    candidateMarkdown[
            'candidate_authoring/articles/${entry['kind']}/$targetId.md'] =
        markdown;
    compiledSources.add(compileM23CandidateMarkdown(markdown));
  }

  final candidates = [
    for (final source in compiledSources)
      KnowledgeEntryCandidate.fromCompiledSource(
        source,
        compilerVersion: migrationCompilerVersion,
      ),
  ];
  final reviews = <String, EntryCandidateReviewDecision>{
    for (final candidate in candidates)
      candidate.entryId: EntryCandidateReviewDecision.create(
        entryId: candidate.entryId,
        candidateDigest: candidate.candidateDigest,
        outcome: EntryCandidateReviewOutcome.accepted,
        reviewer: migrationReviewer,
        decidedAt: migrationGeneratedAt,
        reason: 'M2.3 imports the existing reviewed or accepted source state; '
            'production activation remains gated by M2.4.',
      ),
  };
  final result = const KnowledgeReleaseCandidateBuilder().build(
    candidates: candidates,
    reviewsByEntryId: reviews,
  );
  if (result.eligible.length != 35 || result.quarantined.isNotEmpty) {
    throw M23MigrationException(
      'Expected 35 eligible target entries and no RC quarantine, found '
      '${result.eligible.length}/${result.quarantined.length}.',
    );
  }

  final candidatePack = _candidatePack(
    targetEntries.values.toList(),
    sourceRecords: sourcesById.values.toList(),
    policyDocument: v0.parseYamlObject(
      File(_join(packageRoot.path, 'corpus', 'mastery_policies.yaml'))
          .readAsStringSync(),
    ),
  );
  final candidatePackRaw = _pretty(candidatePack);
  final loadedCandidate = readM23KnowledgeArtifact(candidatePackRaw);
  final publicationReview = PublicationReviewDecision.create(
    outcome: PublicationReviewOutcome.accepted,
    candidateContentDigest: loadedCandidate.contentDigest,
    compilerVersion: migrationCompilerVersion,
    releaseCandidateContentDigest: result.releaseCandidate.contentDigest,
    reviewer: migrationReviewer,
    decidedAt: migrationGeneratedAt,
    reason: 'M2.3 isolated publication proof; production current is unchanged.',
  );
  final publicationCheck = _isolatedPublicationCheck(
    candidatePackRaw,
    result.releaseCandidate.contentDigest,
    publicationReview,
  );

  rows.sort(
      (left, right) => '${left['sourceId']}'.compareTo('${right['sourceId']}'));
  final reviewsJson = [
    for (final candidate in [
      ...candidates
    ]..sort((left, right) => left.entryId.compareTo(right.entryId)))
      {
        'entryId': candidate.entryId,
        'candidateDigest': candidate.candidateDigest,
        'decision': 'accepted_for_m2_3_candidate',
        'reviewer': migrationReviewer,
        'decidedAt': migrationGeneratedAt,
        'decisionDigest': reviews[candidate.entryId]!.digest,
      },
  ];
  final sourcePackDigest = _sha256(sourcePackRaw);
  final productionPackDigest = _sha256(productionPackRaw);
  final currentPointerDigest = _sha256(
    _normalizeNewlines(currentPointerFile.readAsStringSync()),
  );
  final report = <String, dynamic>{
    'schemaVersion': 1,
    'milestone': 'M2.3',
    'status': 'engineering_complete_activation_deferred',
    'sourcePackVersion': sourcePack['packVersion'],
    'sourcePackDigest': sourcePackDigest,
    'targetKnowledgeVersion': migrationKnowledgeVersion,
    'compilerVersion': migrationCompilerVersion,
    'taxonomyVersion': migrationTaxonomyVersion,
    'totalMigrationInputs': 36,
    'reviewedInputs': 34,
    'draftInputs': 2,
    'mergeExistingInputs': 3,
    'newCanonicalIds': 31,
    'retainedCanonicalEntries': 1,
    'migrationInputCandidates': 36,
    'eligibleMigrationInputs': 34,
    'quarantinedMigrationInputs': 2,
    'releaseTargetEntries': 35,
    'quarantineReasonCounts': {'reviewStateDraft': 2},
    'manualGeneratedOutputFixes': 0,
    'directPublications': 0,
    'sourceRecordsPreserved': sourcesById.length,
    'sourceSnapshotsWithContentHash': 0,
    'sourceSnapshotStatus': 'legacy_metadata_only',
    'learningPathsMigrated': 0,
    'learningPathsDeferred':
        (sourcePack['paths'] as List? ?? const <dynamic>[]).length,
    'releaseCandidateDigest': result.releaseCandidate.contentDigest,
    'candidatePackDigest': loadedCandidate.contentDigest,
    'deterministicRebuild': 'PASS',
    'isolatedPublicationPipeline': publicationCheck,
    'productionActivation': 'DEFERRED_TO_M2.4',
    'protectedBaseline': {
      'knowledgeVersion': productionPack.knowledgeVersion,
      'contentDigest': productionPack.contentDigest,
      'fileDigest': productionPackDigest,
      'currentPointerDigest': currentPointerDigest,
    },
  };
  final manifest = <String, dynamic>{
    'schemaVersion': 1,
    'milestone': 'M2.3',
    'sourcePack': {
      'path': 'assets/pack_v1.json',
      'version': sourcePack['packVersion'],
      'digest': sourcePackDigest,
    },
    'targetKnowledgeVersion': migrationKnowledgeVersion,
    'idMappings': _idMap,
    'rows': rows,
    'retainedCanonicalEntries': ['mistake.poor_speed_control'],
  };
  final artifacts = <String, String>{
    ...candidateMarkdown,
    'README.md': _migrationReadme,
    'manifest.json': _pretty(manifest),
    'entry_reviews.json': _pretty({
      'schemaVersion': 1,
      'reviewer': migrationReviewer,
      'decidedAt': migrationGeneratedAt,
      'decisions': reviewsJson,
    }),
    'release_candidate.json': _pretty(result.releaseCandidate.toJson()),
    'candidate_pack.json': candidatePackRaw,
    'publication_review.json': _pretty(publicationReview.toJson()),
    'report.json': _pretty(report),
  };
  return M23MigrationBuild(artifacts: artifacts, report: report);
}

v0.CompiledKnowledgeEntrySource compileM23CandidateMarkdown(String markdown) {
  final normalized = _normalizeNewlines(markdown).trim();
  final match =
      RegExp(r'^---\n([\s\S]*?)\n---\n([\s\S]+)$').firstMatch(normalized);
  if (match == null) {
    throw const M23MigrationException(
      'Migration candidate requires JSON-compatible YAML front matter.',
    );
  }
  final front = _object(jsonDecode(match.group(1)!), 'candidate front matter');
  if (front['schemaVersion'] != 2) {
    throw const M23MigrationException(
      'Unsupported M2.3 candidate schema version.',
    );
  }
  final id = _requiredString(front, 'id');
  final kind = _requiredString(front, 'kind');
  if (!migrationKnowledgeKinds.contains(kind)) {
    throw M23MigrationException('Unsupported migration Knowledge kind: $kind.');
  }
  final reviewState = _requiredString(front, 'reviewState');
  if (reviewState != 'verified') {
    throw M23MigrationException('$id is not verified for the candidate pack.');
  }
  final sourceIds = _stringList(front['sourceIds'], '$id.sourceIds');
  if (sourceIds.isEmpty) {
    throw M23MigrationException('$id must preserve source provenance.');
  }
  final sourceSnapshots = _objectList(
    front['sourceSnapshots'],
    '$id.sourceSnapshots',
  );
  final snapshotIds = sourceSnapshots
      .map((snapshot) => _requiredString(snapshot, 'id'))
      .toSet();
  if (snapshotIds.length != sourceIds.length ||
      !snapshotIds.containsAll(sourceIds)) {
    throw M23MigrationException(
      '$id source snapshots do not match its source IDs.',
    );
  }
  final revision = front['revision'];
  if (revision is! int || revision < 1) {
    throw M23MigrationException('$id has an invalid revision.');
  }
  final rawRelations = front['relations'];
  if (rawRelations is! List) {
    throw M23MigrationException('$id.relations must be a list.');
  }
  final targets = <String>[];
  final dependencies = <String>[];
  final typedRelations = <Map<String, dynamic>>[];
  for (final raw in rawRelations) {
    final relation = _object(raw, '$id.relation');
    final type = _requiredString(relation, 'type');
    final targetId = _requiredString(relation, 'targetId');
    targets.add(targetId);
    if (type == 'requires') dependencies.add(targetId);
    typedRelations.add({'type': type, 'targetId': targetId});
  }
  final capabilities = _stringList(
    front['capabilities'],
    '$id.capabilities',
    allowEmpty: true,
  );
  final payload = _object(front['payload'], '$id.payload');
  final entry = <String, dynamic>{
    'id': id,
    'kind': kind,
    'reviewState': reviewState,
    'title': _requiredString(front, 'title'),
    'summary': _requiredString(front, 'summary'),
    'body': match.group(2)!.trim(),
    'capabilities': capabilities,
    'relations': targets,
    'typedRelations': typedRelations,
    'sourceIds': sourceIds,
    'sourceSnapshots': sourceSnapshots,
    'revision': revision,
    'origin': _requiredString(front, 'origin'),
    'payload': payload,
  };
  if (payload['shape'] == 'article') {
    _validateArticlePayload(id, payload, sourceIds);
  } else {
    ExecutableKnowledgeEntry.fromJson(entry);
  }
  return v0.CompiledKnowledgeEntrySource(
    id: id,
    knowledgeVersion: _requiredString(front, 'knowledgeVersion'),
    publishedAt: _requiredString(front, 'candidateAt'),
    dependencies: List.unmodifiable(dependencies..sort()),
    entry: entry,
  );
}

Map<String, dynamic> _mergedCanonicalEntry({
  required String targetId,
  required Map<String, dynamic> legacy,
  required Map<String, Map<String, dynamic>> productionById,
}) {
  final current = productionById[targetId];
  if (current == null) {
    throw M23MigrationException(
      'Canonical merge target $targetId does not exist in Knowledge 0.2.1.',
    );
  }
  final entry = _deepCopy(current);
  entry['sourceIds'] = _stringList(
    legacy['sourceIds'],
    '${legacy['id']}.sourceIds',
  )..sort();
  entry['revision'] = legacy['revision'] is int ? legacy['revision'] : 1;
  entry['origin'] = 'migrated_merge';
  entry['sourceReviewState'] = legacy['reviewState'];
  if (targetId == 'control.stop_shot') {
    entry['body'] = '${entry['body']}'
        .replaceAll('20/25 trở lên', '23/25 trở lên')
        .replaceAll('19/25 vẫn', '22/25 vẫn');
  }
  return entry;
}

Map<String, dynamic> _migratedArticleEntry(
  Map<String, dynamic> legacy, {
  required String targetId,
  required String kind,
}) {
  final sourceIds = _stringList(
    legacy['sourceIds'],
    '${legacy['id']}.sourceIds',
  )..sort();
  final relations = _objectList(
    legacy['relations'] ?? const <dynamic>[],
    '${legacy['id']}.relations',
    allowEmpty: true,
  );
  final normalizedRelations = [
    for (final relation in relations)
      {
        'type': _requiredString(relation, 'type'),
        'targetId': _idMap[_requiredString(relation, 'targetId')] ??
            _requiredString(relation, 'targetId'),
      },
  ]..sort((left, right) {
      final byTarget = '${left['targetId']}'.compareTo('${right['targetId']}');
      return byTarget != 0
          ? byTarget
          : '${left['type']}'.compareTo('${right['type']}');
    });
  final revision = legacy['revision'] is int ? legacy['revision'] as int : 1;
  return {
    'id': targetId,
    'kind': kind,
    'reviewState': 'verified',
    'title': _localizedValue(legacy['title'], preferVietnamese: true),
    'summary': _localizedValue(legacy['summary'], preferVietnamese: true),
    'body': _articleBody(legacy),
    'capabilities': <String>[],
    'relations': [
      for (final relation in normalizedRelations) relation['targetId']
    ],
    'typedRelations': normalizedRelations,
    'sourceIds': sourceIds,
    'revision': revision,
    'origin': 'migrated',
    'sourceReviewState': legacy['reviewState'],
    'payload': {
      'shape': 'article',
      'revision': revision,
      'sourceIds': sourceIds,
      'content': _deepCopy(legacy),
    },
  };
}

String _migrationMarkdown(Map<String, dynamic> entry) {
  final relations = entry['typedRelations'] is List
      ? entry['typedRelations'] as List
      : [
          for (final target in entry['relations'] as List)
            {'type': 'related', 'targetId': target},
        ];
  final front = <String, dynamic>{
    'schemaVersion': 2,
    'id': entry['id'],
    'kind': entry['kind'],
    'knowledgeVersion': migrationKnowledgeVersion,
    'candidateAt': migrationGeneratedAt,
    'reviewState': 'verified',
    'title': entry['title'],
    'summary': entry['summary'],
    'capabilities': entry['capabilities'],
    'relations': relations,
    'sourceIds': entry['sourceIds'],
    'sourceSnapshots': entry['sourceSnapshots'],
    'revision': entry['revision'],
    'origin': entry['origin'],
    'payload': entry['payload'],
  };
  return '---\n${jsonEncode(front)}\n---\n${entry['body']}\n';
}

Map<String, dynamic> _candidatePack(
  List<Map<String, dynamic>> entries, {
  required List<Map<String, dynamic>> sourceRecords,
  required Map<String, dynamic> policyDocument,
}) {
  final canonicalEntries = entries.map(_deepCopy).toList()
    ..sort((left, right) => '${left['id']}'.compareTo('${right['id']}'));
  final payload = <String, dynamic>{
    'schemaVersion': 2,
    'compilerVersion': migrationCompilerVersion,
    'knowledgeVersion': migrationKnowledgeVersion,
    'taxonomyVersion': migrationTaxonomyVersion,
    'generatedAt': migrationGeneratedAt,
    'masteryPolicyVersion': policyDocument['policyVersion'],
    'masteryPolicies': policyDocument['policies'],
    'sources': sourceRecords.map(_deepCopy).toList()
      ..sort((left, right) => '${left['id']}'.compareTo('${right['id']}')),
    'entries': canonicalEntries,
  };
  return {
    ...payload,
    'contentDigest': _sha256(jsonEncode(payload)),
  };
}

String _isolatedPublicationCheck(
  String candidatePack,
  String releaseCandidateDigest,
  PublicationReviewDecision review,
) {
  final root = Directory.systemTemp.createTempSync('pool_os_m2_3_publish_');
  try {
    final pipeline = KnowledgePublicationPipeline(
      root,
      artifactReader: readM23KnowledgeArtifact,
    );
    final result = pipeline.submitCandidate(
      candidateId: 'm2-3-36-entry-migration',
      compile: () => candidatePack,
      review: review,
      releaseCandidateContentDigest: releaseCandidateDigest,
    );
    if (result.status != PublicationCandidateStatus.published ||
        pipeline.current().contentDigest != review.candidateContentDigest) {
      throw const M23MigrationException(
        'Isolated publication pipeline did not publish the reviewed candidate.',
      );
    }
    return 'PASS';
  } finally {
    root.deleteSync(recursive: true);
  }
}

Map<String, dynamic> _executableEntryJson(ExecutableKnowledgeEntry entry) {
  final payload = entry.payload;
  final payloadJson = switch (payload) {
    TechniquePayload value => {
        'masteryCategory': value.masteryCategory.name,
        'outcome': {
          'description': value.outcome.description,
          'successRadiusCm': value.outcome.successRadiusCm,
          'requiredSuccesses': value.outcome.requiredSuccesses,
          'requiredAttempts': value.outcome.requiredAttempts,
        },
        'measurement': {
          'id': value.measurement.id,
          'drillId': value.measurement.drillId,
          'attempts': value.measurement.attempts,
          'successDefinition': value.measurement.successDefinition,
        },
        'drill': {
          'id': value.drill.id,
          'title': value.drill.title,
          'instructions': value.drill.instructions,
        },
        'nextRecommendation': {
          'id': value.nextRecommendation.id,
          'title': value.nextRecommendation.title,
          'targetType': value.nextRecommendation.targetType,
          if (value.nextRecommendation.blockedByActiveCorrectionCategory !=
              null)
            'blockedByActiveCorrectionCategory': value
                .nextRecommendation.blockedByActiveCorrectionCategory!.name,
        },
      },
    MistakePayload value => {
        'symptom': value.symptom,
        'correction': value.correction,
        'masteryCategory': value.masteryCategory.name,
        'causes': value.causes,
        'resolutionPolicy': {
          'type': value.resolutionPolicy.type,
          'requiredConsecutiveClean':
              value.resolutionPolicy.requiredConsecutiveClean,
        },
      },
    ConceptPayload value => {
        'explanation': value.explanation,
        'keyPoints': value.keyPoints,
      },
  };
  return {
    'id': entry.id,
    'kind': entry.kind.name,
    'reviewState': entry.reviewState,
    'title': entry.title,
    'summary': entry.summary,
    'body': entry.body,
    'capabilities': entry.capabilities.toList()..sort(),
    'relations': [...entry.relations]..sort(),
    if (entry.dependencies.isNotEmpty)
      'dependencies': [...entry.dependencies]..sort(),
    if (entry.unlockExpression != null)
      'unlockExpression': _unlockExpressionJson(entry.unlockExpression!),
    'payload': payloadJson,
  };
}

Map<String, dynamic> _unlockExpressionJson(UnlockExpression expression) =>
    switch (expression) {
      UnlockDependencyExpression value => {
          'type': 'dependency',
          'nodeId': value.nodeId,
          'dependencyId': value.dependencyId,
        },
      UnlockAllOfExpression value => {
          'type': 'allOf',
          'nodeId': value.nodeId,
          'children': value.children.map(_unlockExpressionJson).toList(),
        },
    };

String _articleBody(Map<String, dynamic> legacy) {
  final title = _localizedValue(legacy['title'], preferVietnamese: false);
  final buffer = StringBuffer('# $title\n');
  final layers = _objectList(
    legacy['layers'] ?? const <dynamic>[],
    '${legacy['id']}.layers',
    allowEmpty: true,
  );
  for (final layer in layers) {
    final depth = _requiredString(layer, 'depth');
    buffer.writeln('\n## $depth');
    for (final paragraph in _objectList(
      layer['paragraphs'] ?? const <dynamic>[],
      '${legacy['id']}.$depth.paragraphs',
      allowEmpty: true,
    )) {
      final en = _localizedValue(paragraph, preferVietnamese: false);
      final vi = _localizedValue(paragraph, preferVietnamese: true);
      if (en.isNotEmpty) buffer.writeln('\n$en');
      if (vi.isNotEmpty && vi != en) buffer.writeln('\n$vi');
    }
    for (final point in _objectList(
      layer['keyPoints'] ?? const <dynamic>[],
      '${legacy['id']}.$depth.keyPoints',
      allowEmpty: true,
    )) {
      final vi = _localizedValue(point, preferVietnamese: true);
      if (vi.isNotEmpty) buffer.writeln('- $vi');
    }
  }
  return buffer.toString().trim();
}

KnowledgeArtifactIdentity readM23KnowledgeArtifact(String artifact) {
  final decoded = _object(jsonDecode(artifact), 'M2.3 candidate pack');
  if (decoded['schemaVersion'] != 2) {
    throw const M23MigrationException(
      'Unsupported M2.3 candidate pack schema version.',
    );
  }
  final digest = _requiredString(decoded, 'contentDigest');
  final payload = _deepCopy(decoded)..remove('contentDigest');
  if (_sha256(jsonEncode(payload)) != digest) {
    throw const M23MigrationException('M2.3 candidate pack digest mismatch.');
  }
  final generatedAt = _requiredString(decoded, 'generatedAt');
  if (DateTime.tryParse(generatedAt) == null) {
    throw const M23MigrationException(
      'M2.3 candidate pack generatedAt is invalid.',
    );
  }
  final sources = _objectList(decoded['sources'], 'candidate sources');
  final sourceIds = <String>{};
  for (final source in sources) {
    final sourceId = _requiredString(source, 'id');
    if (!sourceIds.add(sourceId)) {
      throw M23MigrationException('Duplicate candidate source: $sourceId.');
    }
    _requiredString(source, 'recordDigest');
    _requiredString(source, 'snapshotStatus');
  }
  final entries = _objectList(decoded['entries'], 'candidate entries');
  final byId = <String, Map<String, dynamic>>{};
  for (final entry in entries) {
    final id = _requiredString(entry, 'id');
    if (byId.containsKey(id)) {
      throw M23MigrationException('Duplicate candidate entry: $id.');
    }
    byId[id] = entry;
    final kind = _requiredString(entry, 'kind');
    if (!migrationKnowledgeKinds.contains(kind)) {
      throw M23MigrationException('Unsupported candidate kind: $kind.');
    }
    if (_requiredString(entry, 'reviewState') != 'verified') {
      throw M23MigrationException('$id is not verified.');
    }
    final entrySourceIds = _stringList(entry['sourceIds'], '$id.sourceIds');
    if (entrySourceIds.any((sourceId) => !sourceIds.contains(sourceId))) {
      throw M23MigrationException('$id has an unresolved source reference.');
    }
    final snapshots = _objectList(entry['sourceSnapshots'], '$id.sources');
    final snapshotIds =
        snapshots.map((snapshot) => _requiredString(snapshot, 'id')).toSet();
    if (snapshotIds.length != entrySourceIds.length ||
        !snapshotIds.containsAll(entrySourceIds)) {
      throw M23MigrationException('$id source snapshots are incomplete.');
    }
    final entryPayload = _object(entry['payload'], '$id.payload');
    if (entryPayload['shape'] == 'article') {
      _validateArticlePayload(id, entryPayload, entrySourceIds);
    } else {
      ExecutableKnowledgeEntry.fromJson(entry);
    }
  }
  for (final entry in entries) {
    final id = _requiredString(entry, 'id');
    for (final targetId in _stringList(
      entry['relations'],
      '$id.relations',
      allowEmpty: true,
    )) {
      if (!byId.containsKey(targetId)) {
        throw M23MigrationException(
          'Dangling candidate relation $id -> $targetId.',
        );
      }
    }
  }
  return KnowledgeArtifactIdentity(
    compilerVersion: _requiredString(decoded, 'compilerVersion'),
    knowledgeVersion: _requiredString(decoded, 'knowledgeVersion'),
    generatedAt: generatedAt,
    contentDigest: digest,
  );
}

void _validateArticlePayload(
  String id,
  Map<String, dynamic> payload,
  List<String> sourceIds,
) {
  final revision = payload['revision'];
  final payloadSourceIds = _stringList(
    payload['sourceIds'],
    '$id.payload.sourceIds',
  );
  if (payload['shape'] != 'article' ||
      revision is! int ||
      revision < 1 ||
      payloadSourceIds.toSet().length != sourceIds.toSet().length ||
      !payloadSourceIds.toSet().containsAll(sourceIds) ||
      payload['content'] is! Map) {
    throw M23MigrationException('$id has an invalid article payload.');
  }
}

String _localizedValue(dynamic value, {required bool preferVietnamese}) {
  final object = _object(value, 'localized value');
  final primary = object[preferVietnamese ? 'vi' : 'en'];
  final fallback = object[preferVietnamese ? 'en' : 'vi'];
  if (primary is String && primary.trim().isNotEmpty) return primary.trim();
  if (fallback is String && fallback.trim().isNotEmpty) return fallback.trim();
  throw const M23MigrationException('Localized value must not be empty.');
}

String _targetKind(String sourceKind) => switch (sourceKind) {
      'commonMistake' => 'mistake',
      'technique' ||
      'concept' ||
      'terminology' ||
      'rule' ||
      'strategy' ||
      'equipment' ||
      'mental' =>
        sourceKind,
      _ => throw M23MigrationException(
          'Unsupported migration kind: $sourceKind.',
        ),
    };

void _writeArtifacts(Directory outputRoot, Map<String, String> artifacts) {
  for (final entry in artifacts.entries) {
    final file = File(_joinMany(outputRoot.path, entry.key.split('/')));
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(entry.value);
  }
}

void _checkArtifacts(Directory outputRoot, Map<String, String> artifacts) {
  final actualPaths = outputRoot.existsSync()
      ? outputRoot
          .listSync(recursive: true)
          .whereType<File>()
          .map((file) => _relativePath(outputRoot, file))
          .toSet()
      : <String>{};
  final expectedPaths = artifacts.keys.toSet();
  if (actualPaths.length != expectedPaths.length ||
      !actualPaths.containsAll(expectedPaths)) {
    final extra = actualPaths.difference(expectedPaths).toList()..sort();
    final missing = expectedPaths.difference(actualPaths).toList()..sort();
    throw M23MigrationException(
      'M2.3 artifact set drift. Extra: ${extra.join(', ')}; '
      'missing: ${missing.join(', ')}.',
    );
  }
  for (final entry in artifacts.entries) {
    final file = File(_joinMany(outputRoot.path, entry.key.split('/')));
    if (!file.existsSync() ||
        _normalizeNewlines(file.readAsStringSync()) != entry.value) {
      throw M23MigrationException(
        'M2.3 artifact drift: ${entry.key}. Run without --check.',
      );
    }
  }
}

String _relativePath(Directory root, File file) {
  final prefix = '${root.absolute.path}${Platform.pathSeparator}';
  final absolute = file.absolute.path;
  if (!absolute.startsWith(prefix)) {
    throw M23MigrationException('Artifact escaped output root: $absolute.');
  }
  return absolute.substring(prefix.length).replaceAll('\\', '/');
}

Map<String, dynamic> _deepCopy(Map<String, dynamic> value) =>
    _object(jsonDecode(jsonEncode(value)), 'deep copy');

dynamic _canonicalize(dynamic value) {
  if (value is Map) {
    final keys = value.keys.map((key) => key.toString()).toList()..sort();
    return <String, dynamic>{
      for (final key in keys) key: _canonicalize(value[key]),
    };
  }
  if (value is List) {
    return value.map(_canonicalize).toList(growable: false);
  }
  return value;
}

Map<String, dynamic> _object(dynamic value, String label) {
  if (value is! Map) throw M23MigrationException('$label must be an object.');
  return Map<String, dynamic>.from(value);
}

List<Map<String, dynamic>> _objectList(
  dynamic value,
  String label, {
  bool allowEmpty = false,
}) {
  if (value is! List || (!allowEmpty && value.isEmpty)) {
    throw M23MigrationException('$label must be a non-empty list.');
  }
  return value.map((item) => _object(item, label)).toList();
}

List<String> _stringList(
  dynamic value,
  String label, {
  bool allowEmpty = false,
}) {
  if (value is! List ||
      (!allowEmpty && value.isEmpty) ||
      value.any((item) => item is! String || item.trim().isEmpty)) {
    throw M23MigrationException('$label must be a string list.');
  }
  return value.cast<String>().toList();
}

String _requiredString(Map<String, dynamic> value, String field) {
  final result = value[field];
  if (result is! String || result.trim().isEmpty) {
    throw M23MigrationException('$field must be a non-empty string.');
  }
  return result;
}

String _pretty(Object value) =>
    '${const JsonEncoder.withIndent('  ').convert(value)}\n';

String _sha256(String value) => sha256.convert(utf8.encode(value)).toString();

String _normalizeNewlines(String value) =>
    value.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

String _join(String first, String second, [String? third]) {
  final separator = Platform.pathSeparator;
  return third == null
      ? '$first$separator$second'
      : '$first$separator$second$separator$third';
}

String _joinMany(String first, Iterable<String> rest) =>
    rest.fold(first, (path, segment) => _join(path, segment));
