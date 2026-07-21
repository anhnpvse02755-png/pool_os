import 'dart:convert';
import 'dart:io';

import 'package:billiard_knowledge/billiard_knowledge.dart';

import 'knowledge_compiler_v0.dart' as compiler;
import 'knowledge_publication.dart';
import 'knowledge_release_candidate.dart';

const learningRuntimeFixtureReviewer = 'LR-1 Conformance Reviewer';
const learningRuntimeFixtureDecidedAt = '2026-07-21T00:00:00.000Z';

void main(List<String> args) {
  final packageRoot = Directory.current.absolute;
  final check = args.contains('--check');
  try {
    final build = buildLearningRuntimeFixture(packageRoot);
    final outputRoot = Directory(
      _joinMany(packageRoot.path, ['test', 'fixtures', 'lr_1', 'generated']),
    );
    if (check) {
      _checkArtifacts(outputRoot, build.artifacts);
      stdout.writeln(
        'LR-1 Fixture Check PASS: ${build.proof['entryCount']} entries, '
        '${build.proof['candidatePackDigest']}.',
      );
    } else {
      _writeArtifacts(outputRoot, build.artifacts);
      stdout.writeln('Generated LR-1 fixture -> ${outputRoot.path}');
    }
  } on Object catch (error) {
    stderr.writeln(error);
    exitCode = 1;
  }
}

class LearningRuntimeFixtureBuild {
  const LearningRuntimeFixtureBuild({
    required this.artifacts,
    required this.proof,
  });

  final Map<String, String> artifacts;
  final Map<String, dynamic> proof;
}

LearningRuntimeFixtureBuild buildLearningRuntimeFixture(
  Directory packageRoot, {
  bool reverseSourceOrder = false,
}) {
  final authoringRoot = Directory(
    _joinMany(packageRoot.path, ['test', 'fixtures', 'lr_1', 'authoring']),
  );
  final files = authoringRoot
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.md'))
      .toList()
    ..sort((left, right) => left.path.compareTo(right.path));
  if (files.length != 5) {
    throw StateError('LR-1 requires exactly five authoring fixtures.');
  }
  final ordered = reverseSourceOrder ? files.reversed.toList() : files;
  final sources = ordered.map((file) => file.readAsStringSync()).toList();
  final compiledSources =
      sources.map(compiler.compileKnowledgeEntrySource).toList(growable: false);
  final candidates = compiledSources
      .map(KnowledgeEntryCandidate.fromCompiledSource)
      .toList(growable: false);
  final reviews = <String, EntryCandidateReviewDecision>{
    for (final candidate in candidates)
      candidate.entryId: EntryCandidateReviewDecision.create(
        entryId: candidate.entryId,
        candidateDigest: candidate.candidateDigest,
        outcome: EntryCandidateReviewOutcome.accepted,
        reviewer: learningRuntimeFixtureReviewer,
        decidedAt: learningRuntimeFixtureDecidedAt,
      ),
  };
  final rc = const KnowledgeReleaseCandidateBuilder().build(
    candidates: candidates,
    reviewsByEntryId: reviews,
  );
  if (rc.eligible.length != 5 || rc.quarantined.isNotEmpty) {
    throw StateError('LR-1 authoring did not produce five eligible entries.');
  }

  final policies = compiler.parseYamlObject(
    File(_joinMany(packageRoot.path, ['corpus', 'mastery_policies.yaml']))
        .readAsStringSync(),
  );
  final compiled = compiler.compileKnowledgeCorpus(
    sources,
    masteryPolicyDocument: policies,
  );
  final pack = ExecutableKnowledgePack.fromJsonString(compiled);
  final store = Directory.systemTemp.createTempSync('pool_os_lr_1_publish_');
  late final KnowledgePublicationMetadata publication;
  try {
    final pipeline = KnowledgePublicationPipeline(store);
    final review = PublicationReviewDecision.create(
      outcome: PublicationReviewOutcome.accepted,
      candidateContentDigest: pack.contentDigest,
      compilerVersion: pack.compilerVersion,
      releaseCandidateContentDigest: rc.releaseCandidate.contentDigest,
      reviewer: learningRuntimeFixtureReviewer,
      decidedAt: learningRuntimeFixtureDecidedAt,
    );
    final result = pipeline.submitCandidate(
      candidateId: 'lr-1-policy-dispatch',
      compile: () => compiled,
      review: review,
      releaseCandidateContentDigest: rc.releaseCandidate.contentDigest,
    );
    if (result.status != PublicationCandidateStatus.published ||
        result.publication == null) {
      throw StateError('LR-1 candidate publication failed.');
    }
    publication = pipeline.current();
  } finally {
    store.deleteSync(recursive: true);
  }

  final proof = <String, dynamic>{
    'schemaVersion': 1,
    'fixture': 'LR-1 Policy Dispatch and Deterministic Ranking',
    'status': 'PASS',
    'entryCount': pack.entries.length,
    'entryIds': pack.entries.map((entry) => entry.id).toList()..sort(),
    'entryReviews': 'accepted',
    'releaseCandidateDigest': rc.releaseCandidate.contentDigest,
    'candidatePackDigest': pack.contentDigest,
    'publicationSchemaVersion': publicationSchemaVersion,
    'publicationContentDigest': publication.contentDigest,
    'publicationReleaseCandidateDigest':
        publication.releaseCandidateContentDigest,
    'isolatedCandidatePublication': 'PASS',
    'productionActivation': false,
  };
  return LearningRuntimeFixtureBuild(
    artifacts: {
      'published_candidate.json': compiled,
      'proof.json': _pretty(proof),
    },
    proof: proof,
  );
}

void _writeArtifacts(Directory root, Map<String, String> artifacts) {
  root.createSync(recursive: true);
  for (final entry in artifacts.entries) {
    File(_join(root.path, entry.key)).writeAsStringSync(entry.value);
  }
}

void _checkArtifacts(Directory root, Map<String, String> artifacts) {
  final actual = root.existsSync()
      ? root
          .listSync()
          .whereType<File>()
          .map((file) => file.uri.pathSegments.last)
          .toSet()
      : <String>{};
  if (actual.length != artifacts.length ||
      !actual.containsAll(artifacts.keys)) {
    throw StateError('LR-1 generated artifact set drift.');
  }
  for (final entry in artifacts.entries) {
    final file = File(_join(root.path, entry.key));
    if (_normalizeNewlines(file.readAsStringSync()) != entry.value) {
      throw StateError('LR-1 generated artifact drift: ${entry.key}.');
    }
  }
}

String _pretty(Object value) =>
    '${const JsonEncoder.withIndent('  ').convert(value)}\n';

String _normalizeNewlines(String value) =>
    value.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

String _join(String first, String second) =>
    '$first${Platform.pathSeparator}$second';

String _joinMany(String first, Iterable<String> rest) =>
    rest.fold(first, (path, segment) => _join(path, segment));
